import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/state/auth_controller.dart';
import 'data/contacts_repository.dart';

class SyncStatus {
  final bool running;
  final int? lastUploaded;
  final DateTime? lastSuccessAt;
  final String? lastError;

  const SyncStatus({
    this.running = false,
    this.lastUploaded,
    this.lastSuccessAt,
    this.lastError,
  });

  bool get hasEverSynced => lastSuccessAt != null;

  SyncStatus copyWith({
    bool? running,
    int? lastUploaded,
    DateTime? lastSuccessAt,
    String? lastError,
    bool clearError = false,
  }) =>
      SyncStatus(
        running: running ?? this.running,
        lastUploaded: lastUploaded ?? this.lastUploaded,
        lastSuccessAt: lastSuccessAt ?? this.lastSuccessAt,
        lastError: clearError ? null : (lastError ?? this.lastError),
      );
}

class SyncStatusController extends StateNotifier<SyncStatus> {
  static const _kLastTime = 'sync_last_time';
  static const _kLastCount = 'sync_last_count';
  static const _kLastError = 'sync_last_error';

  final ContactsRepository _repo;

  SyncStatusController(this._repo) : super(const SyncStatus()) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final p = await SharedPreferences.getInstance();
    final t = p.getInt(_kLastTime);
    state = state.copyWith(
      lastSuccessAt: t == null ? null : DateTime.fromMillisecondsSinceEpoch(t),
      lastUploaded: p.getInt(_kLastCount),
      lastError: p.getString(_kLastError),
    );
  }

  Future<int?> sync() async {
    if (state.running) return null;
    state = state.copyWith(running: true, clearError: true);
    try {
      final n = await _repo.uploadDeviceContacts();
      final now = DateTime.now();
      final p = await SharedPreferences.getInstance();
      await p.setInt(_kLastTime, now.millisecondsSinceEpoch);
      await p.setInt(_kLastCount, n);
      await p.remove(_kLastError);
      state = SyncStatus(
        running: false,
        lastUploaded: n,
        lastSuccessAt: now,
      );
      return n;
    } catch (e) {
      final msg = e.toString();
      final p = await SharedPreferences.getInstance();
      await p.setString(_kLastError, msg);
      state = state.copyWith(running: false, lastError: msg);
      return null;
    }
  }
}

final syncStatusProvider =
    StateNotifierProvider<SyncStatusController, SyncStatus>(
  (ref) => SyncStatusController(ref.read(contactsRepositoryProvider)),
);
