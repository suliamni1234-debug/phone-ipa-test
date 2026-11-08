import 'package:go_router/go_router.dart';

import '../../features/auth/screens/gmail_screen.dart';
import '../../features/contacts/contacts_screen.dart';
import '../../features/contacts/sync_gate_screen.dart';
import '../../features/history/history_screen.dart';
import '../../features/auth/screens/name_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/auth/screens/phone_screen.dart';
import '../../features/home/app_shell.dart';
import '../../features/home/home_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/permissions/permissions_screen.dart';
import '../../features/premium/premium_screen.dart';
import '../../features/protect/enable_protection_screen.dart';
import '../../features/protect/protect_screen.dart';
import '../../features/search/search_result_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/settings/legal_page_screen.dart';
import '../../features/settings/calls_settings_screen.dart';
import '../../features/settings/profile_edit_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/settings/who_searched_me_screen.dart';
import '../../features/splash/splash_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
    GoRoute(path: '/permissions', builder: (_, __) => const PermissionsScreen()),

    GoRoute(path: '/auth/phone', builder: (_, __) => const PhoneScreen()),
    GoRoute(path: '/auth/otp', builder: (_, __) => const OtpScreen()),
    GoRoute(path: '/auth/sync', builder: (_, __) => const SyncGateScreen()),
    GoRoute(path: '/auth/gmail', builder: (_, __) => const GmailScreen()),
    GoRoute(path: '/auth/name', builder: (_, __) => const NameScreen()),

    GoRoute(
        path: '/enable-protection',
        builder: (_, __) => const EnableProtectionScreen()),

    GoRoute(path: '/contacts', builder: (_, __) => const ContactsScreen()),
    GoRoute(path: '/history', builder: (_, __) => const HistoryScreen()),
    GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
    GoRoute(
      path: '/search/result',
      builder: (ctx, state) => SearchResultScreen(
        query: state.uri.queryParameters['q'] ?? '',
      ),
    ),
    GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
    GoRoute(
        path: '/settings/profile',
        builder: (_, __) => const ProfileEditScreen()),
    GoRoute(
        path: '/settings/who-searched-me',
        builder: (_, __) => const WhoSearchedMeScreen()),
    GoRoute(
        path: '/settings/calls',
        builder: (_, __) => const CallsSettingsScreen()),
    GoRoute(
      path: '/settings/terms',
      builder: (_, __) => const LegalPageScreen(
        kind: LegalPageKind.termsOfService,
      ),
    ),
    GoRoute(
      path: '/settings/privacy',
      builder: (_, __) => const LegalPageScreen(
        kind: LegalPageKind.privacyPolicy,
      ),
    ),
    GoRoute(
      path: '/settings/help',
      builder: (_, __) => const LegalPageScreen(
        kind: LegalPageKind.help,
      ),
    ),

    StatefulShellRoute.indexedStack(
      builder: (_, __, shell) => AppShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/protect', builder: (_, __) => const ProtectScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/premium', builder: (_, __) => const PremiumScreen()),
          ],
        ),
      ],
    ),
  ],
);
