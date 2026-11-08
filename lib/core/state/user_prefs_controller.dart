import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/user_prefs.dart';

class UserPrefsState {
  final ThemeMode themeMode;
  final AppLanguage language;
  final bool notificationsEnabled;
  final bool callerIdOverlay;
  final bool afterCallScreen;
  final bool showAlternateNumbers;
  final CallerIdDisplayStyle callerIdDisplayStyle;
  final bool identifyOnOtherApps;
  final bool groupCallsInHistory;
  final bool showFrequentContacts;
  final bool showCallsFromOtherApps;
  final bool callAlertNotification;
  final bool missedCallNotification;
  final bool remindMissedCalls;

  const UserPrefsState({
    required this.themeMode,
    required this.language,
    required this.notificationsEnabled,
    required this.callerIdOverlay,
    required this.afterCallScreen,
    required this.showAlternateNumbers,
    required this.callerIdDisplayStyle,
    required this.identifyOnOtherApps,
    required this.groupCallsInHistory,
    required this.showFrequentContacts,
    required this.showCallsFromOtherApps,
    required this.callAlertNotification,
    required this.missedCallNotification,
    required this.remindMissedCalls,
  });

  UserPrefsState copyWith({
    ThemeMode? themeMode,
    AppLanguage? language,
    bool? notificationsEnabled,
    bool? callerIdOverlay,
    bool? afterCallScreen,
    bool? showAlternateNumbers,
    CallerIdDisplayStyle? callerIdDisplayStyle,
    bool? identifyOnOtherApps,
    bool? groupCallsInHistory,
    bool? showFrequentContacts,
    bool? showCallsFromOtherApps,
    bool? callAlertNotification,
    bool? missedCallNotification,
    bool? remindMissedCalls,
  }) =>
      UserPrefsState(
        themeMode: themeMode ?? this.themeMode,
        language: language ?? this.language,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        callerIdOverlay: callerIdOverlay ?? this.callerIdOverlay,
        afterCallScreen: afterCallScreen ?? this.afterCallScreen,
        showAlternateNumbers: showAlternateNumbers ?? this.showAlternateNumbers,
        callerIdDisplayStyle:
            callerIdDisplayStyle ?? this.callerIdDisplayStyle,
        identifyOnOtherApps: identifyOnOtherApps ?? this.identifyOnOtherApps,
        groupCallsInHistory: groupCallsInHistory ?? this.groupCallsInHistory,
        showFrequentContacts:
            showFrequentContacts ?? this.showFrequentContacts,
        showCallsFromOtherApps:
            showCallsFromOtherApps ?? this.showCallsFromOtherApps,
        callAlertNotification:
            callAlertNotification ?? this.callAlertNotification,
        missedCallNotification:
            missedCallNotification ?? this.missedCallNotification,
        remindMissedCalls: remindMissedCalls ?? this.remindMissedCalls,
      );
}

final userPrefsProvider = Provider<UserPrefs>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});

final userPrefsControllerProvider =
    StateNotifierProvider<UserPrefsController, UserPrefsState>((ref) {
  return UserPrefsController(ref.watch(userPrefsProvider));
});

class UserPrefsController extends StateNotifier<UserPrefsState> {
  final UserPrefs _prefs;
  UserPrefsController(this._prefs)
      : super(UserPrefsState(
          themeMode: _prefs.themeMode,
          language: _prefs.language,
          notificationsEnabled: _prefs.notificationsEnabled,
          callerIdOverlay: _prefs.callerIdOverlay,
          afterCallScreen: _prefs.afterCallScreen,
          showAlternateNumbers: _prefs.showAlternateNumbers,
          callerIdDisplayStyle: _prefs.callerIdDisplayStyle,
          identifyOnOtherApps: _prefs.identifyOnOtherApps,
          groupCallsInHistory: _prefs.groupCallsInHistory,
          showFrequentContacts: _prefs.showFrequentContacts,
          showCallsFromOtherApps: _prefs.showCallsFromOtherApps,
          callAlertNotification: _prefs.callAlertNotification,
          missedCallNotification: _prefs.missedCallNotification,
          remindMissedCalls: _prefs.remindMissedCalls,
        ));

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _prefs.setThemeMode(mode);
  }

  Future<void> setLanguage(AppLanguage lang) async {
    state = state.copyWith(language: lang);
    await _prefs.setLanguage(lang);
  }

  Future<void> setNotificationsEnabled(bool v) async {
    state = state.copyWith(notificationsEnabled: v);
    await _prefs.setNotificationsEnabled(v);
  }

  Future<void> setCallerIdOverlay(bool v) async {
    state = state.copyWith(callerIdOverlay: v);
    await _prefs.setCallerIdOverlay(v);
  }

  Future<void> setAfterCallScreen(bool v) async {
    state = state.copyWith(afterCallScreen: v);
    await _prefs.setAfterCallScreen(v);
  }

  Future<void> setShowAlternateNumbers(bool v) async {
    state = state.copyWith(showAlternateNumbers: v);
    await _prefs.setShowAlternateNumbers(v);
  }

  Future<void> setCallerIdDisplayStyle(CallerIdDisplayStyle s) async {
    state = state.copyWith(callerIdDisplayStyle: s);
    await _prefs.setCallerIdDisplayStyle(s);
  }

  Future<void> setIdentifyOnOtherApps(bool v) async {
    state = state.copyWith(identifyOnOtherApps: v);
    await _prefs.setIdentifyOnOtherApps(v);
  }

  Future<void> setGroupCallsInHistory(bool v) async {
    state = state.copyWith(groupCallsInHistory: v);
    await _prefs.setGroupCallsInHistory(v);
  }

  Future<void> setShowFrequentContacts(bool v) async {
    state = state.copyWith(showFrequentContacts: v);
    await _prefs.setShowFrequentContacts(v);
  }

  Future<void> setShowCallsFromOtherApps(bool v) async {
    state = state.copyWith(showCallsFromOtherApps: v);
    await _prefs.setShowCallsFromOtherApps(v);
  }

  Future<void> setCallAlertNotification(bool v) async {
    state = state.copyWith(callAlertNotification: v);
    await _prefs.setCallAlertNotification(v);
  }

  Future<void> setMissedCallNotification(bool v) async {
    state = state.copyWith(missedCallNotification: v);
    await _prefs.setMissedCallNotification(v);
  }

  Future<void> setRemindMissedCalls(bool v) async {
    state = state.copyWith(remindMissedCalls: v);
    await _prefs.setRemindMissedCalls(v);
  }
}
