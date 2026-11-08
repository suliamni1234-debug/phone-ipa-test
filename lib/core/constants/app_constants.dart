class AppConstants {
  static const String appName = 'Yellow Fast Call';
  static const String appTagline = 'Know who is calling';

  // Local development backend.
  // - Physical Android device on your Wi-Fi → your PC's LAN IP
  // - Android emulator → 10.0.2.2 maps to host machine localhost
  // - Production → swap to https://api.yellowfastcall.com
  static const String apiBaseUrl = 'http://192.168.0.47:4000';
  static const String apiVersion = 'v1';

  static String get apiV1 => '$apiBaseUrl/api/$apiVersion';

  static const Duration splashDuration = Duration(milliseconds: 2500);
  static const Duration otpResendCooldown = Duration(seconds: 45);

  static const String logoAsset = 'assets/images/logo.png';
}
