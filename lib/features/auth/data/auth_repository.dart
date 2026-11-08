import '../state/auth_state.dart';

/// Auth repository.
/// `sendOtp` returns the OTP code in development mode (so the UI can show it),
/// or null in production where the code only goes out via SMS / WhatsApp.
abstract class AuthRepository {
  Future<String?> sendOtp({required String phoneE164, required OtpChannel channel});
  Future<bool> verifyOtp({required String phoneE164, required String code});
  Future<void> linkGoogle({required String idToken});
  Future<void> updateProfile({required String name});
}

class MockAuthRepository implements AuthRepository {
  @override
  Future<String?> sendOtp({
    required String phoneE164,
    required OtpChannel channel,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));
    return null;
  }

  @override
  Future<bool> verifyOtp({
    required String phoneE164,
    required String code,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    // dev: any 6-digit code passes
    return RegExp(r'^\d{6}$').hasMatch(code);
  }

  @override
  Future<void> linkGoogle({required String idToken}) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> updateProfile({required String name}) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
