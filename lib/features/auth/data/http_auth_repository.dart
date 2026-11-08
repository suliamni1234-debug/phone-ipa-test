import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../state/auth_state.dart';
import 'auth_repository.dart';

class HttpAuthRepository implements AuthRepository {
  final ApiClient _api;
  HttpAuthRepository(this._api);

  String _msg(Response r, String fallback) {
    final data = r.data;
    if (data is Map && data['message'] is String) return data['message'] as String;
    return fallback;
  }

  @override
  Future<String?> sendOtp({required String phoneE164, required OtpChannel channel}) async {
    final r = await _api.dio.post('/auth/otp/send', data: {
      'phone': phoneE164,
      'channel': channel == OtpChannel.whatsapp ? 'whatsapp' : 'sms',
    });
    if (r.statusCode != 200) {
      throw Exception(_msg(r, 'Could not send code (${r.statusCode}).'));
    }
    if (r.data is Map && r.data['dev_code'] is String) {
      return r.data['dev_code'] as String;
    }
    return null;
  }

  @override
  Future<bool> verifyOtp({required String phoneE164, required String code}) async {
    final r = await _api.dio.post('/auth/otp/verify', data: {
      'phone': phoneE164,
      'code': code,
    });
    if (r.statusCode == 200 && r.data is Map && r.data['token'] is String) {
      await _api.tokenStorage.save(r.data['token'] as String);
      final secret = r.data['device_secret'];
      if (secret is String && secret.isNotEmpty) {
        await _api.tokenStorage.saveDeviceSecret(secret);
      }
      return true;
    }
    return false;
  }

  @override
  Future<void> linkGoogle({required String idToken}) async {
    final r = await _api.dio.post('/auth/google', data: {'idToken': idToken});
    if (r.statusCode != 200) {
      throw Exception(_msg(r, 'Google sign-in failed (${r.statusCode}).'));
    }
  }

  @override
  Future<void> updateProfile({required String name}) async {
    final r = await _api.dio.patch('/users/me', data: {'name': name});
    if (r.statusCode != 200) {
      throw Exception(_msg(r, 'Could not save profile (${r.statusCode}).'));
    }
  }
}
