import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/responsive.dart';
import '../../core/storage/token_storage.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../main.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future.delayed(AppConstants.splashDuration);
    if (!mounted) return;

    final storage = ref.read(localStorageProvider);
    final hasToken = await TokenStorage().hasToken();

    if (!storage.onboardingDone) {
      context.go('/onboarding');
    } else if (!storage.permissionsAsked) {
      context.go('/permissions');
    } else if (!hasToken) {
      // JWT is the source of truth. If it's missing, force re-login even if
      // a stale isLoggedIn flag was restored by Android Auto Backup.
      await storage.setLoggedIn(false);
      context.go('/auth/phone');
    } else if (!storage.protectionAsked) {
      context.go('/enable-protection');
    } else {
      context.go('/home');
    }

    // Cold-launched from a caller-ID overlay tap: now that we've landed on an
    // authenticated screen, open the number-info screen on top of it.
    final pending = pendingLookupNumber;
    if (hasToken && pending != null && pending.isNotEmpty && mounted) {
      pendingLookupNumber = null;
      context.push('/search/result?q=${Uri.encodeQueryComponent(pending)}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final logoSize = (context.wp(32)).clamp(96.0, 160.0);

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Container(
        decoration: const BoxDecoration(color: AppColors.primary),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: -context.wp(20),
                left: -context.wp(20),
                child: Container(
                  width: context.wp(70),
                  height: context.wp(70),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                ).animate().fadeIn(duration: 1200.ms).scale(
                      begin: const Offset(0.6, 0.6),
                      end: const Offset(1, 1),
                      duration: 1400.ms,
                      curve: Curves.easeOutBack,
                    ),
              ),
              Positioned(
                bottom: -context.wp(30),
                right: -context.wp(30),
                child: Container(
                  width: context.wp(85),
                  height: context.wp(85),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    shape: BoxShape.circle,
                  ),
                ).animate().fadeIn(duration: 1500.ms),
              ),
              Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: context.pagePadding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo wrapped in expanding radar "ping" rings.
                      SizedBox(
                        width: logoSize * 2.6,
                        height: logoSize * 2.6,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            _PingRing(size: logoSize * 1.3, delay: 600.ms),
                            _PingRing(size: logoSize * 1.3, delay: 1300.ms),
                            _PingRing(size: logoSize * 1.3, delay: 2000.ms),
                            Hero(
                              tag: 'app-logo',
                              child: Container(
                                padding: EdgeInsets.all(
                                    context.wp(5).clamp(14.0, 24.0)),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 30,
                                      offset: const Offset(0, 12),
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  AppConstants.logoAsset,
                                  width: logoSize,
                                  height: logoSize,
                                ),
                              ),
                            )
                                .animate()
                                .scale(
                                  begin: const Offset(0.6, 0.6),
                                  end: const Offset(1, 1),
                                  duration: 700.ms,
                                  curve: Curves.easeOutBack,
                                )
                                .fadeIn(duration: 450.ms),
                          ],
                        ),
                      ),
                      SizedBox(height: context.hp(2)),
                      Text(
                        AppConstants.appName,
                        style: GoogleFonts.poppins(
                          fontSize: context.sp(30),
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      )
                          .animate(delay: 500.ms)
                          .fadeIn(duration: 600.ms)
                          .slideY(begin: 0.25, end: 0, duration: 600.ms),
                      SizedBox(height: context.hp(1.4)),
                      Text(
                        AppLocalizations.of(context).appTagline,
                        style: GoogleFonts.inter(
                          fontSize: context.sp(15),
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w500,
                        ),
                      )
                          .animate(delay: 800.ms)
                          .fadeIn(duration: 600.ms)
                          .slideY(begin: 0.3, end: 0, duration: 600.ms),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 32,
                left: 0,
                right: 0,
                child: Center(
                  child: SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(
                        Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ).animate(delay: 1500.ms).fadeIn(duration: 400.ms),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 500.ms),
    );
  }
}

/// An expanding, fading ring that radiates out from the logo — a radar "ping"
/// effect that loops while the splash is on screen.
class _PingRing extends StatelessWidget {
  final double size;
  final Duration delay;

  const _PingRing({required this.size, required this.delay});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.45),
          width: 2,
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat(), delay: delay)
        .scaleXY(begin: 0.6, end: 1.9, duration: 2000.ms, curve: Curves.easeOut)
        .fadeOut(begin: 0.6, duration: 2000.ms, curve: Curves.easeOut);
  }
}
