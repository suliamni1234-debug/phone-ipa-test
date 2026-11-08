import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Cooldown between name changes. The UI shows the user how long they have to
/// wait, and `AuthController.saveName` enforces it.
const Duration kNameChangeCooldown = Duration(days: 7);

/// One past name. We keep these forever — see [LocalStorage.nameHistory].
class NameHistoryEntry {
  final String name;
  final DateTime at;
  const NameHistoryEntry(this.name, this.at);

  Map<String, dynamic> toJson() =>
      {'name': name, 'at': at.toIso8601String()};

  static NameHistoryEntry fromJson(Map<String, dynamic> j) =>
      NameHistoryEntry(j['name'] as String, DateTime.parse(j['at'] as String));
}

class LocalStorage {
  static const _kOnboardingDone = 'onboarding_done';
  static const _kPermissionsAsked = 'permissions_asked';
  static const _kIsLoggedIn = 'is_logged_in';
  static const _kProtectionAsked = 'protection_asked';
  static const _kUserName = 'user_name';
  static const _kUserGmail = 'user_gmail';
  static const _kUserPhone = 'user_phone';
  static const _kNameHistory = 'user_name_history';
  static const _kNameChangedAt = 'user_name_changed_at';

  final SharedPreferences _prefs;
  LocalStorage(this._prefs);

  static Future<LocalStorage> init() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorage(prefs);
  }

  bool get onboardingDone => _prefs.getBool(_kOnboardingDone) ?? false;
  Future<void> setOnboardingDone(bool v) => _prefs.setBool(_kOnboardingDone, v);

  bool get permissionsAsked => _prefs.getBool(_kPermissionsAsked) ?? false;
  Future<void> setPermissionsAsked(bool v) => _prefs.setBool(_kPermissionsAsked, v);

  bool get isLoggedIn => _prefs.getBool(_kIsLoggedIn) ?? false;
  Future<void> setLoggedIn(bool v) => _prefs.setBool(_kIsLoggedIn, v);

  bool get protectionAsked => _prefs.getBool(_kProtectionAsked) ?? false;
  Future<void> setProtectionAsked(bool v) => _prefs.setBool(_kProtectionAsked, v);

  String? get userName => _prefs.getString(_kUserName);
  Future<void> setUserName(String? v) => v == null || v.isEmpty
      ? _prefs.remove(_kUserName)
      : _prefs.setString(_kUserName, v);

  /// Every name the user has ever set, oldest first. We append on every
  /// successful change and never delete — the user explicitly asked for this.
  List<NameHistoryEntry> get nameHistory {
    final raw = _prefs.getStringList(_kNameHistory) ?? const [];
    return raw
        .map((s) {
          try {
            return NameHistoryEntry.fromJson(
                jsonDecode(s) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<NameHistoryEntry>()
        .toList();
  }

  Future<void> appendNameHistory(String name, DateTime at) async {
    final list = _prefs.getStringList(_kNameHistory) ?? <String>[];
    list.add(jsonEncode(NameHistoryEntry(name, at).toJson()));
    await _prefs.setStringList(_kNameHistory, list);
  }

  /// Timestamp of the most recent successful name change. Used to enforce
  /// [kNameChangeCooldown]. Null if the user has never changed their name
  /// after the initial sign-up name.
  DateTime? get nameChangedAt {
    final ms = _prefs.getInt(_kNameChangedAt);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<void> setNameChangedAt(DateTime t) =>
      _prefs.setInt(_kNameChangedAt, t.millisecondsSinceEpoch);

  /// Remaining cooldown before the user is allowed to change their name
  /// again. Returns `Duration.zero` if they can change it now.
  Duration get nameChangeCooldownRemaining {
    final last = nameChangedAt;
    if (last == null) return Duration.zero;
    final elapsed = DateTime.now().difference(last);
    final left = kNameChangeCooldown - elapsed;
    return left.isNegative ? Duration.zero : left;
  }

  String? get userGmail => _prefs.getString(_kUserGmail);
  Future<void> setUserGmail(String? v) => v == null || v.isEmpty
      ? _prefs.remove(_kUserGmail)
      : _prefs.setString(_kUserGmail, v);

  String? get userPhone => _prefs.getString(_kUserPhone);
  Future<void> setUserPhone(String? v) => v == null || v.isEmpty
      ? _prefs.remove(_kUserPhone)
      : _prefs.setString(_kUserPhone, v);

  static const _kLocationReminderSnoozedUntil = 'location_reminder_snoozed_until';

  /// When the user dismisses the location reminder, the banner is suppressed
  /// until this timestamp. Returns null if it has never been snoozed.
  DateTime? get locationReminderSnoozedUntil {
    final ms = _prefs.getInt(_kLocationReminderSnoozedUntil);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<void> snoozeLocationReminder(Duration d) => _prefs.setInt(
        _kLocationReminderSnoozedUntil,
        DateTime.now().add(d).millisecondsSinceEpoch,
      );
}
