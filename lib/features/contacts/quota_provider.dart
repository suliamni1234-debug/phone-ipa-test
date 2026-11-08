import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/state/auth_controller.dart';

class SearchQuota {
  final int used;
  final int limit;
  final int baseLimit;
  final int bonusCount;
  final int remaining;
  final DateTime? resetsAt;
  final bool canWatchAd;

  const SearchQuota({
    required this.used,
    required this.limit,
    required this.baseLimit,
    required this.bonusCount,
    required this.remaining,
    this.resetsAt,
    required this.canWatchAd,
  });

  bool get exhausted => remaining <= 0;

  factory SearchQuota.fromMap(Map<String, dynamic> m) => SearchQuota(
        used: (m['used'] as num?)?.toInt() ?? 0,
        limit: (m['limit'] as num?)?.toInt() ?? 20,
        baseLimit: (m['base_limit'] as num?)?.toInt() ?? 20,
        bonusCount: (m['bonus_count'] as num?)?.toInt() ?? 0,
        remaining: (m['remaining'] as num?)?.toInt() ?? 20,
        resetsAt: m['resets_at'] is String
            ? DateTime.tryParse(m['resets_at'] as String)?.toLocal()
            : null,
        canWatchAd: m['can_watch_ad'] == true,
      );
}

class SearchQuotaController extends StateNotifier<AsyncValue<SearchQuota>> {
  final Ref _ref;
  SearchQuotaController(this._ref) : super(const AsyncValue.loading()) {
    refresh();
  }

  Future<void> refresh() async {
    try {
      final repo = _ref.read(contactsRepositoryProvider);
      final m = await repo.quotaStatus();
      if (m == null) {
        state = AsyncValue.error('No data', StackTrace.current);
      } else {
        state = AsyncValue.data(SearchQuota.fromMap(m));
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Update locally after a known successful lookup so UI doesn't have to
  // round-trip the server again.
  void updateFromMap(Map<String, dynamic>? quotaMap) {
    if (quotaMap == null) return;
    state = AsyncValue.data(SearchQuota.fromMap(quotaMap));
  }

  // Server-side bonus grant after a rewarded ad. Returns whether +1 was added.
  Future<bool> claimAdReward() async {
    try {
      final repo = _ref.read(contactsRepositoryProvider);
      final res = await repo.claimAdReward();
      if (res == null) return false;
      final q = res['quota'];
      if (q is Map) {
        state = AsyncValue.data(
          SearchQuota.fromMap(Map<String, dynamic>.from(q)),
        );
      } else {
        await refresh();
      }
      return res['granted'] != null;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final searchQuotaProvider =
    StateNotifierProvider<SearchQuotaController, AsyncValue<SearchQuota>>(
  (ref) => SearchQuotaController(ref),
);
