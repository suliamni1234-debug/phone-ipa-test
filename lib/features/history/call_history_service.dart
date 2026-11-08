import 'dart:io' show Platform;

import 'package:call_log/call_log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

/// Lightweight wrapper around the `call_log` plugin. Asks for the READ_CALL_LOG
/// permission on demand, reads the device's call log, and exposes a Riverpod
/// async provider so screens can simply watch a refreshable list.
class CallHistoryService {
  /// Returns the most recent calls (default 100). Returns an empty list if
  /// the user denies the permission rather than throwing — that way the UI
  /// can offer an "Allow" CTA instead of crashing.
  static Future<List<CallLogEntry>> fetch({int limit = 100}) async {
    // iOS gives apps no access to the call log; the plugin is Android-only.
    if (!Platform.isAndroid) return const [];
    final status = await Permission.phone.request();
    if (!status.isGranted) return const [];
    final entries = await CallLog.query();
    final list = entries.toList()
      ..sort((a, b) => (b.timestamp ?? 0).compareTo(a.timestamp ?? 0));
    if (list.length > limit) return list.sublist(0, limit);
    return list;
  }

  static Future<bool> hasPermission() async {
    if (!Platform.isAndroid) return false;
    return Permission.phone.status.then((s) => s.isGranted);
  }

  static Future<bool> requestPermission() async {
    if (!Platform.isAndroid) return false;
    final s = await Permission.phone.request();
    return s.isGranted;
  }
}

/// Async provider over the device call log. Pull-to-refresh / re-fetch via
/// `ref.invalidate(callHistoryProvider)`.
final callHistoryProvider = FutureProvider<List<CallLogEntry>>((ref) async {
  return CallHistoryService.fetch();
});

/// Convenience provider for the home-screen preview (first N entries).
final recentCallsPreviewProvider =
    FutureProvider<List<CallLogEntry>>((ref) async {
  final all = await ref.watch(callHistoryProvider.future);
  return all.take(5).toList();
});
