import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _kJwt = 'auth_jwt';
  static const _kDeviceSecret = 'device_secret';
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> save(String token) => _storage.write(key: _kJwt, value: token);
  Future<String?> read() => _storage.read(key: _kJwt);
  Future<void> clear() => _storage.deleteAll();
  Future<bool> hasToken() async => (await read())?.isNotEmpty ?? false;

  Future<void> saveDeviceSecret(String secret) =>
      _storage.write(key: _kDeviceSecret, value: secret);
  Future<String?> readDeviceSecret() => _storage.read(key: _kDeviceSecret);
}
