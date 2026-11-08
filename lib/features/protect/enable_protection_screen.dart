import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/responsive.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../main.dart';
import '../../shared/widgets/primary_button.dart';
import '../location/location_service.dart';
import 'protect_controller.dart';

class EnableProtectionScreen extends ConsumerStatefulWidget {
  const EnableProtectionScreen({super.key});

  @override
  ConsumerState<EnableProtectionScreen> createState() =>
      _EnableProtectionScreenState();
}

class _EnableProtectionScreenState
    extends ConsumerState<EnableProtectionScreen> {
  bool _busy = false;
  bool _shareLocation = true;
  bool _autoPromptDone = false;

  @override
  void initState() {
    super.initState();
    // For new users landing on this screen, immediately surface the OS
    // "Set as default call screener" dialog. If they accept we finish the
    // protection setup and route to home; if they decline the screen stays
    // visible so they can read the benefits and tap Enable Protection later.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _autoPromptDone) return;
      _autoPromptDone = true;
      final state = ref.read(protectControllerProvider);
      if (state.isDefaultScreener) return;
      setState(() => _busy = true);
      final ok = await ref
          .read(protectControllerProvider.notifier)
          .requestCallScreenerRole();
      if (!mounted) {
        return;
      }
      if (ok) {
        // Also ask for the overlay permission so the caller-ID popup can show
        // over the incoming-call screen.
        await ref
            .read(protectControllerProvider.notifier)
            .requestOverlayPermission();
        if (!mounted) return;
      }
      setState(() => _busy = false);
      if (!ok) return; // declined — stay on screen so user can read & retry
      if (_shareLocation) {
        final loc = ref.read(locationServiceProvider);
        final report = await loc.reportOnce();
        if (report.ok) {
          await LocationService.setEnabled(true);
          loc.startPeriodic();
        }
      }
      if (!mounted) return;
      await ref.read(localStorageProvider).setProtectionAsked(true);
      if (mounted) context.go('/home');
    });
  }

  Future<void> _enable() async {
    setState(() => _busy = true);
    final loc = ref.read(locationServiceProvider);
    final ok = await ref
        .read(protectControllerProvider.notifier)
        .requestCallScreenerRole();
    if (ok && mounted) {
      // Grant the caller-ID popup the "display over other apps" permission.
      await ref
          .read(protectControllerProvider.notifier)
          .requestOverlayPermission();
    }
    if (_shareLocation) {
      final report = await loc.reportOnce();
      if (report.ok) {
        await LocationService.setEnabled(true);
        loc.startPeriodic();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(report.message),
        ));
      }
    }
    if (!mounted) return;
    setState(() => _busy = false);
    await ref.read(localStorageProvider).setProtectionAsked(true);
    if (!mounted) return;
    if (!ok) {
      final l = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l.enableProtectionLaterMsg),
      ));
    }
    if (mounted) context.go('/home');
  }

  Future<void> _skip() async {
    await ref.read(localStorageProvider).setProtectionAsked(true);
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final shieldSize = (context.wp(38)).clamp(116.0, 168.0);
    final iconSize = shieldSize * 0.5;

    return Scaffold(
      body: SafeArea(
        child: ResponsiveBox(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: context.pagePadding),
            child: Column(
              children: [
                SizedBox(height: context.hp(2)),
                Align(
                  alignment: AlignmentDirectional.topEnd,
                  child: TextButton(
                    onPressed: _busy ? null : _skip,
                    child: Text(
                      l.onboardingSkip,
                      style: GoogleFonts.inter(
                        fontSize: context.sp(14),
                        color: AppColors.textSecondaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                    children: [
                      SizedBox(height: context.hp(1)),
                      Container(
                        width: shieldSize,
                        height: shieldSize,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.verified_user_rounded,
                          size: iconSize,
                          color: AppColors.primary,
                        ),
                      ).animate().scale(
                            begin: const Offset(0.6, 0.6),
                            end: const Offset(1, 1),
                            duration: 500.ms,
                            curve: Curves.easeOutBack,
                          ),
                      SizedBox(height: context.hp(3)),
                      Text(
                        l.enableProtectionTitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: context.sp(26),
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.2, end: 0),
                      SizedBox(height: context.hp(1.5)),
                      Text(
                        l.enableProtectionBody,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: context.sp(14.5),
                          height: 1.5,
                          color: AppColors.textSecondaryLight,
                        ),
                      ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
                      SizedBox(height: context.hp(3)),
                      _LocationToggle(
                        value: _shareLocation,
                        onChanged: (v) =>
                            setState(() => _shareLocation = v),
                      ),
                      SizedBox(height: context.hp(2)),
                      _Bullet(
                        icon: Icons.report_rounded,
                        color: AppColors.spam,
                        title: l.enableProtectionBulletSpamTitle,
                        subtitle: l.enableProtectionBulletSpamBody,
                      ),
                      const SizedBox(height: 12),
                      _Bullet(
                        icon: Icons.phone_disabled_rounded,
                        color: AppColors.info,
                        title: l.enableProtectionBulletSilenceTitle,
                        subtitle: l.enableProtectionBulletSilenceBody,
                      ),
                      const SizedBox(height: 12),
                      _Bullet(
                        icon: Icons.travel_explore_rounded,
                        color: AppColors.success,
                        title: l.enableProtectionBulletIntlTitle,
                        subtitle: l.enableProtectionBulletIntlBody,
                      ),
                      SizedBox(height: context.hp(1)),
                    ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: context.hp(3)),
                  child: Column(
                    children: [
                      PrimaryButton(
                        label: l.enableProtectionTitle,
                        icon: Icons.shield_rounded,
                        loading: _busy,
                        onPressed: _enable,
                      ),
                      SizedBox(height: context.hp(1.2)),
                      Text(
                        l.enableProtectionFootnote,
                        style: GoogleFonts.inter(
                          fontSize: context.sp(12),
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LocationToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _LocationToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.location_on_rounded,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.enableProtectionShareLocation,
                  style: GoogleFonts.inter(
                    fontSize: context.sp(14),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  l.enableProtectionShareLocationSub,
                  style: GoogleFonts.inter(
                    fontSize: context.sp(12),
                    color: AppColors.textSecondaryLight,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  const _Bullet({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: context.sp(14.5),
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: context.sp(12.5),
                  color: AppColors.textSecondaryLight,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
