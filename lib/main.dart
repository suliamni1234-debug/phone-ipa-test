import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_colors.dart';
import 'l10n/generated/app_localizations.dart';
import 'features/ads/rewarded_ad_service.dart';
import 'core/state/user_prefs_controller.dart';
import 'core/storage/local_storage.dart';
import 'core/storage/token_storage.dart';
import 'core/storage/user_prefs.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/state/auth_controller.dart';
import 'features/location/location_service.dart';
import 'features/protect/protect_bridge.dart';
import 'features/protect/protect_controller.dart';
import 'features/protect/protect_storage.dart';

final localStorageProvider = Provider<LocalStorage>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});

/// A number handed over by the native caller-ID overlay during a cold start,
/// before the splash has finished routing. The splash drains this (once it has
/// landed the user on an authenticated screen) and opens the info screen on
/// top — pushing earlier would be wiped by the splash's `context.go`.
String? pendingLookupNumber;

/// Opens the number-info (search result) screen for a number handed over by
/// the native caller-ID overlay while the app is already running. Pushed onto
/// the current stack so the user returns to wherever they were on back.
void _openLookup(String number) {
  final n = number.trim();
  if (n.isEmpty) return;
  appRouter.push('/search/result?q=${Uri.encodeQueryComponent(n)}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await initializeDateFormatting('ar', null);

  // ignore: unawaited_futures
  initAdMob();

  final storage = await LocalStorage.init();
  final protectStorage = await ProtectStorage.init();
  final userPrefs = await UserPrefs.init();

  setOnUnauthorizedRedirect(() async {
    await storage.setLoggedIn(false);
    await TokenStorage().clear();
    appRouter.go('/auth/phone');
  });

  // Caller-ID overlay → app: when the user taps the incoming-call popup, the
  // native side asks us to open the number-info screen. Register the handler
  // before the first frame, then drain anything captured during a cold start.
  final protectBridge = ProtectBridge();
  protectBridge.listenForLookups(_openLookup);
  WidgetsBinding.instance.addPostFrameCallback((_) {
    // Cold start from an overlay tap: stash the number; the splash opens it
    // once it has routed the user to an authenticated screen.
    protectBridge.drainPendingLookup((number) {
      pendingLookupNumber = number.trim();
    });
  });

  runApp(
    ProviderScope(
      overrides: [
        localStorageProvider.overrideWithValue(storage),
        protectStorageProvider.overrideWithValue(protectStorage),
        userPrefsProvider.overrideWithValue(userPrefs),
      ],
      child: const CallerApp(),
    ),
  );
}

class CallerApp extends ConsumerStatefulWidget {
  const CallerApp({super.key});

  @override
  ConsumerState<CallerApp> createState() => _CallerAppState();
}

class _CallerAppState extends ConsumerState<CallerApp>
    with WidgetsBindingObserver {
  // Sync `AppColors.brightness` (so adaptive color getters resolve correctly)
  // and the Android system chrome (status bar / nav bar) to the resolved
  // theme. Called from build() *before* MaterialApp is constructed so
  // descendants see the right brightness on their very first paint.
  void _applySystemChromeFor(Brightness resolvedBrightness) {
    final isDark = resolvedBrightness == Brightness.dark;
    AppColors.brightness = resolvedBrightness;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: isDark ? Colors.black : Colors.white,
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
    ));
  }

  @override
  void didChangePlatformBrightness() {
    // System theme toggled while the app is open. Force a rebuild so
    // MaterialApp.builder runs again with the new resolved brightness.
    if (mounted) setState(() {});
  }
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _kickLocationIfEnabled();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _kickLocationIfEnabled();
    } else if (state == AppLifecycleState.paused) {
      ref.read(locationServiceProvider).stopPeriodic();
    }
  }

  Future<void> _kickLocationIfEnabled() async {
    if (!await LocationService.isEnabled()) return;
    final svc = ref.read(locationServiceProvider);
    // Fire-and-forget — failures are logged by the service.
    unawaited(svc.reportOnce().then((_) {}));
    svc.startPeriodic();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(
      userPrefsControllerProvider.select((s) => s.themeMode),
    );
    final language = ref.watch(
      userPrefsControllerProvider.select((s) => s.language),
    );
    // Resolve effective brightness PROACTIVELY so descendant widgets that
    // read AppColors.surfaceLight/etc. during their first build see the
    // correct value. We can't rely on Theme.of(context).brightness here
    // because MaterialApp is below this widget — instead reproduce the same
    // resolution logic ourselves using PlatformDispatcher's brightness.
    final platformBrightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final effective = switch (themeMode) {
      ThemeMode.dark => Brightness.dark,
      ThemeMode.light => Brightness.light,
      ThemeMode.system => platformBrightness,
    };
    _applySystemChromeFor(effective);
    return MaterialApp.router(
      title: 'Yellow Fast Call',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      locale: Locale(language.code),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: appRouter,
    );
  }
}
