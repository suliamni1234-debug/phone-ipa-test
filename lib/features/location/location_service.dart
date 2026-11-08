import 'dart:async';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/state/auth_controller.dart';

/// Result of a single location report attempt. `ok == true` means the latest
/// lat/lng was successfully PATCHed to the backend; otherwise [reason] tells
/// the caller why so it can be surfaced in the UI.
enum LocationFailure {
  none,
  servicesDisabled,
  permissionDenied,
  permissionDeniedForever,
  fixFailed,
  uploadFailed,
}

class LocationReport {
  final bool ok;
  final LocationFailure reason;
  final double? latitude;
  final double? longitude;
  const LocationReport(this.ok, this.reason, {this.latitude, this.longitude});

  String get message {
    switch (reason) {
      case LocationFailure.none:
        return 'Location updated.';
      case LocationFailure.servicesDisabled:
        return 'Turn on location services in your phone settings.';
      case LocationFailure.permissionDenied:
        return 'Location permission was denied.';
      case LocationFailure.permissionDeniedForever:
        return 'Location permission is blocked. Enable it from system settings.';
      case LocationFailure.fixFailed:
        return 'Could not get a GPS fix. Try outdoors or near a window.';
      case LocationFailure.uploadFailed:
        return 'Network problem — your location did not reach the server.';
    }
  }
}

/// Foreground-only periodic location reporter.
///
/// Background-while-app-closed updates would require ACCESS_BACKGROUND_LOCATION
/// + a foreground service and is heavily restricted by Play Store policy. We
/// instead refresh on every app resume and every [_kInterval] while the app
/// is in the foreground.
class LocationService {
  static const _kEnabled = 'location_sharing_enabled';
  static const _kLastReportAt = 'location_last_report_at';
  static const _kInterval = Duration(minutes: 15);

  final Dio _dio;
  LocationService(this._dio);

  Timer? _timer;

  static Future<bool> isEnabled() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kEnabled) ?? false;
  }

  static Future<void> setEnabled(bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kEnabled, v);
  }

  static Future<DateTime?> lastReportAt() async {
    final p = await SharedPreferences.getInstance();
    final ms = p.getInt(_kLastReportAt);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  static Future<void> _setLastReportAt(DateTime t) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kLastReportAt, t.millisecondsSinceEpoch);
  }

  /// Requests permission and returns the permission state.
  Future<LocationFailure> _permissionState() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return LocationFailure.servicesDisabled;
    }
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever) {
      return LocationFailure.permissionDeniedForever;
    }
    if (perm == LocationPermission.denied) {
      return LocationFailure.permissionDenied;
    }
    return LocationFailure.none;
  }

  /// Compatibility shim for code that just wants a yes/no.
  Future<bool> ensurePermission() async =>
      (await _permissionState()) == LocationFailure.none;

  /// Fetches the current location once and posts to the backend.
  Future<LocationReport> reportOnce() async {
    final pState = await _permissionState();
    if (pState != LocationFailure.none) {
      developer.log('reportOnce: permission $pState', name: 'location');
      return LocationReport(false, pState);
    }
    Position pos;
    try {
      pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 20),
        ),
      );
    } catch (e) {
      developer.log('reportOnce: fix failed — $e', name: 'location');
      return const LocationReport(false, LocationFailure.fixFailed);
    }
    try {
      final r = await _dio.patch('/users/me', data: {
        'latitude': pos.latitude,
        'longitude': pos.longitude,
      });
      developer.log(
        'reportOnce: PATCH /users/me -> ${r.statusCode} '
        'lat=${pos.latitude.toStringAsFixed(6)} '
        'lng=${pos.longitude.toStringAsFixed(6)}',
        name: 'location',
      );
      if (r.statusCode == 200) {
        await _setLastReportAt(DateTime.now());
        return LocationReport(
          true,
          LocationFailure.none,
          latitude: pos.latitude,
          longitude: pos.longitude,
        );
      }
      developer.log('reportOnce: server body=${r.data}', name: 'location');
      return const LocationReport(false, LocationFailure.uploadFailed);
    } catch (e) {
      developer.log('reportOnce: upload error — $e', name: 'location');
      return const LocationReport(false, LocationFailure.uploadFailed);
    }
  }

  /// Starts the periodic in-foreground reporter. Safe to call multiple times.
  void startPeriodic() {
    _timer?.cancel();
    _timer = Timer.periodic(_kInterval, (_) => reportOnce());
  }

  void stopPeriodic() {
    _timer?.cancel();
    _timer = null;
  }
}

final locationServiceProvider = Provider<LocationService>(
  (ref) => LocationService(ref.read(apiClientProvider).dio),
);
