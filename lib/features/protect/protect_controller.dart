import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_phone_field/countries.dart';

import '../../core/constants/app_constants.dart';
import '../../core/storage/local_storage.dart';
import '../../core/storage/token_storage.dart';
import 'protect_bridge.dart';
import 'protect_storage.dart';

/// Derives the home country dialing code (e.g. "964") from the user's own
/// registered phone in E.164 form, by finding the longest known dial code that
/// prefixes it. Used so the native caller-ID resolver can expand a local
/// incoming number like "7724239917" to "+9647724239917" before lookup.
String? homeDialCodeFromE164(String? e164) {
  if (e164 == null) return null;
  final digits = e164.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return null;
  String? best;
  for (final c in countries) {
    if (digits.startsWith(c.dialCode) &&
        (best == null || c.dialCode.length > best.length)) {
      best = c.dialCode;
    }
  }
  return best;
}

class ProtectState {
  final ProtectSettings settings;
  final List<BlockedNumber> blockList;
  final int blockedCount;
  final bool isDefaultScreener;
  final bool hasOverlayPermission;

  const ProtectState({
    required this.settings,
    required this.blockList,
    required this.blockedCount,
    required this.isDefaultScreener,
    required this.hasOverlayPermission,
  });

  static const empty = ProtectState(
    settings: ProtectSettings.defaults,
    blockList: [],
    blockedCount: 0,
    isDefaultScreener: false,
    hasOverlayPermission: false,
  );

  /// Caller ID is fully live only when the app is the default screener AND it
  /// can draw the popup over other apps.
  bool get callerIdReady => isDefaultScreener && hasOverlayPermission;

  ProtectState copyWith({
    ProtectSettings? settings,
    List<BlockedNumber>? blockList,
    int? blockedCount,
    bool? isDefaultScreener,
    bool? hasOverlayPermission,
  }) =>
      ProtectState(
        settings: settings ?? this.settings,
        blockList: blockList ?? this.blockList,
        blockedCount: blockedCount ?? this.blockedCount,
        isDefaultScreener: isDefaultScreener ?? this.isDefaultScreener,
        hasOverlayPermission: hasOverlayPermission ?? this.hasOverlayPermission,
      );
}

final protectStorageProvider = Provider<ProtectStorage>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});

final protectBridgeProvider = Provider<ProtectBridge>((ref) => ProtectBridge());

final protectControllerProvider =
    StateNotifierProvider<ProtectController, ProtectState>((ref) {
  return ProtectController(
    ref.watch(protectStorageProvider),
    ref.watch(protectBridgeProvider),
  );
});

class ProtectController extends StateNotifier<ProtectState> {
  final ProtectStorage _storage;
  final ProtectBridge _bridge;
  final TokenStorage _tokens = TokenStorage();

  ProtectController(this._storage, this._bridge) : super(ProtectState.empty) {
    _load();
  }

  Future<void> _load() async {
    final settings = _storage.readSettings();
    final list = _storage.readBlockList();
    final localCount = _storage.readBlockedCount();
    state = state.copyWith(
      settings: settings,
      blockList: list,
      blockedCount: localCount,
    );
    final isDefault = await _bridge.isDefaultCallScreener();
    final hasOverlay = await _bridge.hasOverlayPermission();
    final nativeCount = await _bridge.readBlockedCount();
    // Reconcile: native side is authoritative for blocked count since it's
    // the one actually rejecting calls in the background.
    if (nativeCount != localCount) {
      await _storage.writeBlockedCount(nativeCount);
    }
    state = state.copyWith(
      isDefaultScreener: isDefault,
      hasOverlayPermission: hasOverlay,
      blockedCount: nativeCount,
    );
    await _push();
  }

  Future<void> refreshFromNative() async {
    final isDefault = await _bridge.isDefaultCallScreener();
    final hasOverlay = await _bridge.hasOverlayPermission();
    final nativeCount = await _bridge.readBlockedCount();
    if (nativeCount != state.blockedCount) {
      await _storage.writeBlockedCount(nativeCount);
    }
    state = state.copyWith(
      isDefaultScreener: isDefault,
      hasOverlayPermission: hasOverlay,
      blockedCount: nativeCount,
    );
    // Re-push so any token refreshed since launch reaches the native side.
    await _push();
  }

  /// Asks for the "Display over other apps" permission, then refreshes state.
  Future<bool> requestOverlayPermission() async {
    final ok = await _bridge.requestOverlayPermission();
    state = state.copyWith(hasOverlayPermission: ok);
    return ok;
  }

  Future<void> setBlockSpam(bool v) =>
      _updateSettings(state.settings.copyWith(blockSpam: v));

  Future<void> setBlockScam(bool v) =>
      _updateSettings(state.settings.copyWith(blockScam: v));

  Future<void> setSilenceUnknown(bool v) =>
      _updateSettings(state.settings.copyWith(silenceUnknown: v));

  Future<void> setIntlSpamFilter(bool v) =>
      _updateSettings(state.settings.copyWith(intlSpamFilter: v));

  Future<void> _updateSettings(ProtectSettings next) async {
    state = state.copyWith(settings: next);
    await _storage.writeSettings(next);
    await _push();
  }

  /// Adds a number. Returns false if already in the list.
  Future<bool> blockNumber(String rawNumber, {String? name}) async {
    final normalized = _normalize(rawNumber);
    if (normalized.isEmpty) return false;
    if (state.blockList.any((e) => _normalize(e.number) == normalized)) {
      return false;
    }
    final entry = BlockedNumber(
      number: normalized,
      name: name,
      addedAt: DateTime.now().millisecondsSinceEpoch,
    );
    final next = [entry, ...state.blockList];
    state = state.copyWith(blockList: next);
    await _storage.writeBlockList(next);
    await _push();
    return true;
  }

  Future<void> unblockNumber(String number) async {
    final normalized = _normalize(number);
    final next = state.blockList
        .where((e) => _normalize(e.number) != normalized)
        .toList(growable: false);
    if (next.length == state.blockList.length) return;
    state = state.copyWith(blockList: next);
    await _storage.writeBlockList(next);
    await _push();
  }

  Future<bool> requestCallScreenerRole() async {
    final ok = await _bridge.requestCallScreenerRole();
    state = state.copyWith(isDefaultScreener: ok);
    return ok;
  }

  Future<void> _push() async {
    // Hand the native caller-ID resolver the credentials it needs to query the
    // backend directory while a call is ringing (the Flutter engine isn't
    // running then). Token/secret may be null before login — the native side
    // ignores nulls so an existing token isn't wiped.
    final token = await _tokens.read();
    final secret = await _tokens.readDeviceSecret();
    final ls = await LocalStorage.init();
    final dialCode = homeDialCodeFromE164(ls.userPhone);
    await _bridge.syncToNative(
      settings: state.settings,
      blockList: state.blockList,
      apiBaseUrl: AppConstants.apiBaseUrl,
      authToken: token,
      deviceSecret: secret,
      homeDialCode: dialCode,
    );
  }

  /// Strips spaces, dashes, parens, leading 00 etc. Keeps a leading '+'.
  static String _normalize(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return '';
    final hasPlus = trimmed.startsWith('+');
    final digits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';
    return hasPlus ? '+$digits' : digits;
  }
}
