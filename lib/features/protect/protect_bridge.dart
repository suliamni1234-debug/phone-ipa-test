import 'package:flutter/services.dart';

import 'protect_storage.dart';

/// Thin wrapper over the platform method channel used to push protect
/// settings + block list to the native Android side, and to request the
/// app become the default call-screening role.
class ProtectBridge {
  static const _channel = MethodChannel('caller/protect');

  Future<void> syncToNative({
    required ProtectSettings settings,
    required List<BlockedNumber> blockList,
    String? apiBaseUrl,
    String? authToken,
    String? deviceSecret,
    String? homeDialCode,
    bool callerIdEnabled = true,
  }) async {
    try {
      await _channel.invokeMethod('sync', {
        ...settings.toJson(),
        'blockList': blockList.map((e) => e.number).toList(),
        // Caller-ID config: lets the native side look up names against the
        // backend directory while a call is ringing. Null entries are ignored
        // natively so we never wipe a stored token with a partial sync.
        if (apiBaseUrl != null) 'apiBaseUrl': apiBaseUrl,
        if (authToken != null) 'authToken': authToken,
        if (deviceSecret != null) 'deviceSecret': deviceSecret,
        if (homeDialCode != null) 'homeDialCode': homeDialCode,
        'callerIdEnabled': callerIdEnabled,
      });
    } on PlatformException {
      // Native side may be unavailable in unit tests / non-Android. Swallow
      // so app keeps working — settings still persist in SharedPreferences.
    } on MissingPluginException {
      // Same as above (e.g. running on web/desktop).
    }
  }

  /// Returns true if the user accepted the role prompt or the app already
  /// holds it, false otherwise.
  Future<bool> requestCallScreenerRole() async {
    try {
      final res = await _channel.invokeMethod<bool>('requestCallScreenerRole');
      return res ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<bool> isDefaultCallScreener() async {
    try {
      final res = await _channel.invokeMethod<bool>('isDefaultCallScreener');
      return res ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Whether the app can draw the caller-ID popup over other apps
  /// (SYSTEM_ALERT_WINDOW). Required for the overlay to appear on the
  /// incoming-call screen.
  Future<bool> hasOverlayPermission() async {
    try {
      final res = await _channel.invokeMethod<bool>('hasOverlayPermission');
      return res ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Opens the system "Display over other apps" settings screen and resolves
  /// with the permission state once the user returns.
  Future<bool> requestOverlayPermission() async {
    try {
      final res = await _channel.invokeMethod<bool>('requestOverlayPermission');
      return res ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Registers a handler for native → Flutter calls. Currently the native
  /// side fires `openLookup` with a phone number when the caller-ID overlay
  /// (or its "View full details" button) is tapped, so the app can open the
  /// number-info screen. Safe to call once at startup.
  void listenForLookups(void Function(String number) onLookup) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'openLookup') {
        final number = call.arguments as String?;
        if (number != null && number.isNotEmpty) onLookup(number);
      }
      return null;
    });
  }

  /// Drains a number captured by an overlay tap that launched the app from
  /// cold (before [listenForLookups]'s handler existed). Call once after the
  /// first frame.
  Future<void> drainPendingLookup(void Function(String number) onLookup) async {
    try {
      final n = await _channel.invokeMethod<String>('consumePendingLookup');
      if (n != null && n.isNotEmpty) onLookup(n);
    } on PlatformException {
      // Native unavailable (tests / non-Android) — nothing to drain.
    } on MissingPluginException {
      // Same as above.
    }
  }

  /// Reads the blocked-call counter the native screening service has been
  /// incrementing in its own SharedPreferences. Falls back to 0.
  Future<int> readBlockedCount() async {
    try {
      final res = await _channel.invokeMethod<int>('blockedCount');
      return res ?? 0;
    } on PlatformException {
      return 0;
    } on MissingPluginException {
      return 0;
    }
  }
}
