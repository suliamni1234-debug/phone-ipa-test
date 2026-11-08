import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage {
  english('en', 'English'),
  arabic('ar', 'العربية');

  final String code;
  final String label;
  const AppLanguage(this.code, this.label);

  static AppLanguage fromCode(String code) =>
      AppLanguage.values.firstWhere((l) => l.code == code, orElse: () => english);
}

enum CallerIdDisplayStyle {
  fullScreen('full_screen', 'Full screen'),
  classicPopup('classic_popup', 'Classic popup');

  final String code;
  final String label;
  const CallerIdDisplayStyle(this.code, this.label);

  static CallerIdDisplayStyle fromCode(String code) =>
      CallerIdDisplayStyle.values
          .firstWhere((s) => s.code == code, orElse: () => fullScreen);
}

class UserPrefs {
  static const _kThemeMode = 'pref_theme_mode';
  static const _kLanguage = 'pref_language';
  static const _kNotifications = 'pref_notifications_enabled';
  static const _kCallerIdOverlay = 'pref_caller_id_overlay';
  static const _kAfterCallScreen = 'pref_after_call_screen';
  static const _kShowAlternateNumbers = 'pref_show_alternate_numbers';
  static const _kCallerIdDisplayStyle = 'pref_caller_id_display_style';
  static const _kIdentifyOnOtherApps = 'pref_identify_on_other_apps';
  static const _kGroupCallsInHistory = 'pref_group_calls_in_history';
  static const _kShowFrequentContacts = 'pref_show_frequent_contacts';
  static const _kShowCallsFromOtherApps = 'pref_show_calls_from_other_apps';
  static const _kCallAlertNotification = 'pref_call_alert_notification';
  static const _kMissedCallNotification = 'pref_missed_call_notification';
  static const _kRemindMissedCalls = 'pref_remind_missed_calls';

  final SharedPreferences _prefs;
  UserPrefs(this._prefs);

  static Future<UserPrefs> init() async {
    final prefs = await SharedPreferences.getInstance();
    return UserPrefs(prefs);
  }

  ThemeMode get themeMode {
    final raw = _prefs.getString(_kThemeMode) ?? 'light';
    switch (raw) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final raw = switch (mode) {
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
      ThemeMode.light => 'light',
    };
    await _prefs.setString(_kThemeMode, raw);
  }

  AppLanguage get language =>
      AppLanguage.fromCode(_prefs.getString(_kLanguage) ?? 'en');

  Future<void> setLanguage(AppLanguage lang) =>
      _prefs.setString(_kLanguage, lang.code);

  bool get notificationsEnabled => _prefs.getBool(_kNotifications) ?? true;

  Future<void> setNotificationsEnabled(bool v) =>
      _prefs.setBool(_kNotifications, v);

  bool get callerIdOverlay => _prefs.getBool(_kCallerIdOverlay) ?? true;

  Future<void> setCallerIdOverlay(bool v) =>
      _prefs.setBool(_kCallerIdOverlay, v);

  bool get afterCallScreen => _prefs.getBool(_kAfterCallScreen) ?? true;

  Future<void> setAfterCallScreen(bool v) =>
      _prefs.setBool(_kAfterCallScreen, v);

  bool get showAlternateNumbers => _prefs.getBool(_kShowAlternateNumbers) ?? true;

  Future<void> setShowAlternateNumbers(bool v) =>
      _prefs.setBool(_kShowAlternateNumbers, v);

  CallerIdDisplayStyle get callerIdDisplayStyle =>
      CallerIdDisplayStyle.fromCode(
          _prefs.getString(_kCallerIdDisplayStyle) ?? 'full_screen');

  Future<void> setCallerIdDisplayStyle(CallerIdDisplayStyle s) =>
      _prefs.setString(_kCallerIdDisplayStyle, s.code);

  bool get identifyOnOtherApps => _prefs.getBool(_kIdentifyOnOtherApps) ?? true;

  Future<void> setIdentifyOnOtherApps(bool v) =>
      _prefs.setBool(_kIdentifyOnOtherApps, v);

  bool get groupCallsInHistory => _prefs.getBool(_kGroupCallsInHistory) ?? true;

  Future<void> setGroupCallsInHistory(bool v) =>
      _prefs.setBool(_kGroupCallsInHistory, v);

  bool get showFrequentContacts => _prefs.getBool(_kShowFrequentContacts) ?? true;

  Future<void> setShowFrequentContacts(bool v) =>
      _prefs.setBool(_kShowFrequentContacts, v);

  bool get showCallsFromOtherApps =>
      _prefs.getBool(_kShowCallsFromOtherApps) ?? true;

  Future<void> setShowCallsFromOtherApps(bool v) =>
      _prefs.setBool(_kShowCallsFromOtherApps, v);

  bool get callAlertNotification =>
      _prefs.getBool(_kCallAlertNotification) ?? true;

  Future<void> setCallAlertNotification(bool v) =>
      _prefs.setBool(_kCallAlertNotification, v);

  bool get missedCallNotification =>
      _prefs.getBool(_kMissedCallNotification) ?? true;

  Future<void> setMissedCallNotification(bool v) =>
      _prefs.setBool(_kMissedCallNotification, v);

  bool get remindMissedCalls => _prefs.getBool(_kRemindMissedCalls) ?? false;

  Future<void> setRemindMissedCalls(bool v) =>
      _prefs.setBool(_kRemindMissedCalls, v);
}
