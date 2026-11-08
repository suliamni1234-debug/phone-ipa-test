import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Builds the canonical payload exactly the same way the server does, so the
/// HMAC produced here matches what `requireSignedRequest` expects.
///
///   method '\n' path '\n' body '\n' timestamp '\n' nonce
String buildCanonical({
  required String method,
  required String path,
  required String body,
  required String timestamp,
  required String nonce,
}) =>
    '${method.toUpperCase()}\n$path\n$body\n$timestamp\n$nonce';

String signHmacSha256(String secret, String canonical) {
  final h = Hmac(sha256, utf8.encode(secret));
  return h.convert(utf8.encode(canonical)).toString();
}

String randomNonce([int bytes = 16]) {
  final r = Random.secure();
  final out = List<int>.generate(bytes, (_) => r.nextInt(256));
  return base64Url.encode(out).replaceAll('=', '');
}

String currentUnixSeconds() =>
    (DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000).toString();
