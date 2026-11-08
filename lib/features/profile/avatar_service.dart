import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/state/auth_controller.dart';

/// Manages the user's profile picture: pick from gallery/camera,
/// save a local copy, and upload to the backend.
class AvatarService {
  static const _kAvatarPath = 'avatar_local_path';
  static const _kAvatarUrl = 'avatar_remote_url';

  final Dio _dio;
  AvatarService(this._dio);

  static Future<String?> readLocalPath() async {
    final p = await SharedPreferences.getInstance();
    final path = p.getString(_kAvatarPath);
    if (path == null) return null;
    return File(path).existsSync() ? path : null;
  }

  static Future<String?> readRemoteUrl() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kAvatarUrl);
  }

  static Future<void> _saveLocalPath(String path) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kAvatarPath, path);
  }

  static Future<void> _saveRemoteUrl(String url) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kAvatarUrl, url);
  }

  /// Returns the local path to the saved avatar, or null if cancelled.
  Future<String?> pickAndUpload({required ImageSource source}) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 88,
    );
    if (picked == null) return null;

    final dir = await getApplicationDocumentsDirectory();
    final ext = picked.path.split('.').last.toLowerCase();
    final safeExt = const {'jpg', 'jpeg', 'png', 'webp'}.contains(ext) ? ext : 'jpg';
    final dest = File('${dir.path}/avatar.$safeExt');
    await File(picked.path).copy(dest.path);
    await _saveLocalPath(dest.path);

    // Upload (best-effort). If the network is down the local copy is still kept.
    try {
      final form = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(
          dest.path,
          filename: 'avatar.$safeExt',
        ),
      });
      final r = await _dio.post('/users/me/avatar', data: form);
      String? url;
      if (r.data is Map) {
        final user = (r.data as Map)['user'];
        if (user is Map && user['avatar_url'] is String) {
          url = user['avatar_url'] as String;
        }
      }
      if (url != null && url.isNotEmpty) {
        await _saveRemoteUrl(url);
      }
    } catch (_) {
      // Swallow upload errors — the picture is already saved locally.
    }
    return dest.path;
  }
}

final avatarServiceProvider = Provider<AvatarService>(
  (ref) => AvatarService(ref.read(apiClientProvider).dio),
);
