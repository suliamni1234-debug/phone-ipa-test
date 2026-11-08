import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/local_storage.dart';
import '../../../main.dart' show localStorageProvider;
import '../data/auth_repository.dart';
import '../data/http_auth_repository.dart';
import '../../contacts/data/contacts_repository.dart';
import 'auth_state.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final c = ApiClient.create();
  c.onUnauthorized = () {
    // The token is gone or invalid. Redirect to phone login.
    // (Imported lazily to avoid a circular import on the router.)
    // ignore: unused_local_variable
    final go = _onUnauthorizedRedirect;
    go?.call();
  };
  return c;
});

// Set from main.dart once the router exists, so the API layer can navigate.
void Function()? _onUnauthorizedRedirect;
void setOnUnauthorizedRedirect(void Function()? cb) =>
    _onUnauthorizedRedirect = cb;

final authRepositoryProvider =
    Provider<AuthRepository>((ref) => HttpAuthRepository(ref.read(apiClientProvider)));

final contactsRepositoryProvider =
    Provider<ContactsRepository>((ref) => ContactsRepository(ref.read(apiClientProvider)));

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  final ContactsRepository _contactsRepo;
  final LocalStorage _local;
  AuthController(this._repo, this._contactsRepo, this._local)
      : super(AuthState(
          name: _local.userName,
          gmail: _local.userGmail,
          phoneE164: _local.userPhone,
        ));

  void setChannel(OtpChannel c) => state = state.copyWith(channel: c);

  Future<bool> sendOtp({
    required String phoneE164,
    required String countryCode,
  }) async {
    state = state.copyWith(
      loading: true,
      clearError: true,
      clearDevOtp: true,
      phoneE164: phoneE164,
      countryCode: countryCode,
    );
    await _local.setUserPhone(phoneE164);
    try {
      final dev = await _repo.sendOtp(phoneE164: phoneE164, channel: state.channel);
      state = state.copyWith(loading: false, otpSent: true, devOtpCode: dev);
      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> verifyOtp(String code) async {
    if (state.phoneE164 == null) return false;
    state = state.copyWith(loading: true, clearError: true);
    try {
      final ok = await _repo.verifyOtp(
        phoneE164: state.phoneE164!,
        code: code,
      );
      state = state.copyWith(loading: false, otpVerified: ok);
      if (!ok) state = state.copyWith(error: 'Wrong code, try again.');
      return ok;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return false;
    }
  }

  // Upload device contacts to the backend. Safe to call multiple times — the
  // backend is idempotent. Returns the number of rows written.
  Future<int> syncContacts() => _contactsRepo.uploadDeviceContacts();

  Future<bool> linkGoogle(String idToken, String email) async {
    state = state.copyWith(loading: true, clearError: true);
    await _local.setUserGmail(email);
    try {
      await _repo.linkGoogle(idToken: idToken);
      state = state.copyWith(loading: false, gmail: email);
      return true;
    } catch (e) {
      // Keep the email saved locally — backend will be retried later.
      state = state.copyWith(loading: false, gmail: email, error: e.toString());
      return false;
    }
  }

  /// Saves the user's display name. Persists locally first so it survives
  /// app restarts and works offline, then best-effort syncs to the backend.
  ///
  /// Enforces a [kNameChangeCooldown] gap between changes. Same name as
  /// current is a no-op success. The previous name (if any) is appended to
  /// [LocalStorage.nameHistory] and is never deleted.
  Future<bool> saveName(String name) async {
    final trimmed = name.trim();
    final current = _local.userName ?? '';
    if (trimmed == current) {
      // No-op — don't burn the cooldown or duplicate history.
      return true;
    }
    final left = _local.nameChangeCooldownRemaining;
    if (left > Duration.zero && current.isNotEmpty) {
      state = state.copyWith(error: _formatCooldown(left));
      return false;
    }
    state = state.copyWith(loading: true, clearError: true);
    final now = DateTime.now();
    if (current.isNotEmpty) {
      await _local.appendNameHistory(current, now);
    }
    await _local.setUserName(trimmed);
    await _local.setNameChangedAt(now);
    state = state.copyWith(name: trimmed);
    try {
      await _repo.updateProfile(name: trimmed);
    } catch (_) {
      // Backend unreachable — that's OK, the name is already saved locally.
    }
    state = state.copyWith(loading: false);
    return true;
  }

  String _formatCooldown(Duration d) {
    if (d.inDays >= 1) {
      final days = d.inDays + (d.inHours % 24 > 0 ? 1 : 0);
      return 'You can change your name again in $days day${days == 1 ? '' : 's'}.';
    }
    final hours = d.inHours + (d.inMinutes % 60 > 0 ? 1 : 0);
    if (hours >= 1) {
      return 'You can change your name again in $hours hour${hours == 1 ? '' : 's'}.';
    }
    final mins = d.inMinutes.clamp(1, 60);
    return 'You can change your name again in $mins minute${mins == 1 ? '' : 's'}.';
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(
    ref.read(authRepositoryProvider),
    ref.read(contactsRepositoryProvider),
    ref.read(localStorageProvider),
  ),
);
