import 'dart:convert';

import 'package:dio/dio.dart';

import '../constants/app_constants.dart';
import '../storage/token_storage.dart';
import 'hmac.dart';

class ApiClient {
  final Dio dio;
  final TokenStorage tokenStorage;

  void Function()? onUnauthorized;

  ApiClient._(this.dio, this.tokenStorage);

  factory ApiClient.create() {
    final tokens = TokenStorage();
    final dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiV1,
      connectTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json'},
      validateStatus: (s) => s != null && s < 500,
    ));
    final client = ApiClient._(dio, tokens);
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 1. Bearer token (used by every authenticated endpoint).
        final t = await tokens.read();
        if (t != null && t.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $t';
        }
        // 2. HMAC signature (required by sensitive endpoints). Adding it to
        //    every authenticated request is harmless — endpoints that don't
        //    enforce signing simply ignore the headers.
        final secret = await tokens.readDeviceSecret();
        if (secret != null && secret.isNotEmpty) {
          final ts = currentUnixSeconds();
          final nonce = randomNonce();
          final method = options.method;
          final path = _canonicalPath(options);
          final body = _canonicalBody(options.data);
          final canonical = buildCanonical(
            method: method, path: path, body: body,
            timestamp: ts, nonce: nonce,
          );
          options.headers['X-Request-Timestamp'] = ts;
          options.headers['X-Request-Nonce'] = nonce;
          options.headers['X-Request-Signature'] = signHmacSha256(secret, canonical);
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (response.statusCode == 401) {
          tokens.clear();
          client.onUnauthorized?.call();
        }
        handler.next(response);
      },
    ));
    return client;
  }
}

// The server signs against `req.originalUrl` which includes query string and
// the API version prefix. dio's baseUrl is `/api/v1` so we need to include it.
String _canonicalPath(RequestOptions options) {
  final uri = options.uri; // resolved against baseUrl
  final path = uri.path;
  final query = uri.query;
  return query.isEmpty ? path : '$path?$query';
}

String _canonicalBody(dynamic data) {
  if (data == null) return '';
  if (data is String) return data;
  return jsonEncode(data);
}
