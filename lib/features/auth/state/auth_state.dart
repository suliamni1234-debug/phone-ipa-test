enum OtpChannel { sms, whatsapp }

class AuthState {
  final String? phoneE164;
  final String? countryCode;
  final OtpChannel channel;
  final bool otpSent;
  final bool otpVerified;
  final String? gmail;
  final String? name;
  final bool loading;
  final String? error;
  final String? devOtpCode;

  const AuthState({
    this.phoneE164,
    this.countryCode,
    this.channel = OtpChannel.sms,
    this.otpSent = false,
    this.otpVerified = false,
    this.gmail,
    this.name,
    this.loading = false,
    this.error,
    this.devOtpCode,
  });

  AuthState copyWith({
    String? phoneE164,
    String? countryCode,
    OtpChannel? channel,
    bool? otpSent,
    bool? otpVerified,
    String? gmail,
    String? name,
    bool? loading,
    String? error,
    String? devOtpCode,
    bool clearError = false,
    bool clearDevOtp = false,
  }) =>
      AuthState(
        phoneE164: phoneE164 ?? this.phoneE164,
        countryCode: countryCode ?? this.countryCode,
        channel: channel ?? this.channel,
        otpSent: otpSent ?? this.otpSent,
        otpVerified: otpVerified ?? this.otpVerified,
        gmail: gmail ?? this.gmail,
        name: name ?? this.name,
        loading: loading ?? this.loading,
        error: clearError ? null : (error ?? this.error),
        devOtpCode: clearDevOtp ? null : (devOtpCode ?? this.devOtpCode),
      );
}
