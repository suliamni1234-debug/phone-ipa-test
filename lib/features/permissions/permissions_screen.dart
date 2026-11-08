import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/responsive.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../main.dart';
import '../../shared/widgets/primary_button.dart';

/// Pre-permission explainer. We never show our own "Allow" toggles here —
/// instead we explain *why* each permission is useful (with extra detail for
/// location) and then trigger the real Android system prompts in sequence when
/// the user taps Continue. The OS dialogs are the only place the user grants.
class PermissionsScreen extends ConsumerStatefulWidget {
  const PermissionsScreen({super.key});

  @override
  ConsumerState<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends ConsumerState<PermissionsScreen> {
  bool _requesting = false;

  Future<void> _continue() async {
    if (_requesting) return;
    setState(() => _requesting = true);
    try {
      // Ask the OS for each permission, one after another. The system dialogs
      // handle the actual Allow/Deny — we don't gate on the result, the user
      // can adjust later in Settings.
      await Permission.contacts.request();
      await Permission.phone.request();
      await Permission.locationWhenInUse.request();
    } catch (_) {
      // Ignore — even if a request throws we still let the user move on.
    }
    await ref.read(localStorageProvider).setPermissionsAsked(true);
    if (mounted) context.go('/auth/phone');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: ResponsiveBox(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                      context.pagePadding, context.hp(2), context.pagePadding, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: const Icon(Icons.verified_user_rounded,
                                color: AppColors.primary, size: 52)
                            .animate()
                            .scale(
                              begin: const Offset(0.7, 0.7),
                              end: const Offset(1, 1),
                              duration: 450.ms,
                              curve: Curves.easeOutBack,
                            ),
                      ),
                      SizedBox(height: context.hp(2.5)),
                      Text(
                        l.permWhyTitle,
                        style: GoogleFonts.poppins(
                          fontSize: context.sp(26),
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ).animate().fadeIn(duration: 350.ms).slideY(
                          begin: 0.15, end: 0, duration: 350.ms),
                      SizedBox(height: context.hp(1)),
                      Text(
                        l.permWhySubtitle,
                        style: GoogleFonts.inter(
                          fontSize: context.sp(14),
                          color: AppColors.textSecondaryLight,
                          height: 1.5,
                        ),
                      ).animate(delay: 80.ms).fadeIn(duration: 350.ms),
                      SizedBox(height: context.hp(3)),

                      _PermCard(
                        icon: Icons.contacts_rounded,
                        color: AppColors.primary,
                        title: l.permContactsTitle,
                        description: l.permContactsDesc,
                        delayMs: 0,
                      ),
                      const SizedBox(height: 12),
                      _PermCard(
                        icon: Icons.phone_in_talk_rounded,
                        color: AppColors.success,
                        title: l.permPhoneTitle,
                        description: l.permPhoneDesc,
                        delayMs: 80,
                      ),
                      const SizedBox(height: 12),
                      _PermCard(
                        icon: Icons.location_on_rounded,
                        color: AppColors.warning,
                        title: l.permLocationTitle,
                        description: l.permLocationDesc,
                        delayMs: 160,
                      ),

                      SizedBox(height: context.hp(2.5)),
                      _LocationDetailCard(l: l),
                      SizedBox(height: context.hp(2)),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(context.pagePadding, 8,
                    context.pagePadding, context.hp(2)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PrimaryButton(
                      label: l.permAllowAll,
                      loading: _requesting,
                      icon: Icons.lock_open_rounded,
                      onPressed: _continue,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l.permFooterNote,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: context.sp(11.5),
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
    );
  }
}

class _PermCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final int delayMs;

  const _PermCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.delayMs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: context.sp(15),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: context.sp(13),
                    color: AppColors.textSecondaryLight,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: delayMs))
        .fadeIn(duration: 320.ms)
        .slideX(begin: 0.06, end: 0, duration: 320.ms, curve: Curves.easeOutCubic);
  }
}

/// The "many details" location explainer the user asked for: a highlighted card
/// listing concrete reasons we use location plus a privacy reassurance.
class _LocationDetailCard extends StatelessWidget {
  final AppLocalizations l;
  const _LocationDetailCard({required this.l});

  @override
  Widget build(BuildContext context) {
    final reasons = [
      l.permLocationReason1,
      l.permLocationReason2,
      l.permLocationReason3,
      l.permLocationReason4,
    ];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.warning.withValues(alpha: 0.12),
            AppColors.warning.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.travel_explore_rounded,
                    color: AppColors.warning, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l.permWhyLocationHeading,
                  style: GoogleFonts.poppins(
                    fontSize: context.sp(15.5),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (final r in reasons)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 1),
                    child: Icon(Icons.check_circle_rounded,
                        color: AppColors.warning, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      r,
                      style: GoogleFonts.inter(
                        fontSize: context.sp(13.5),
                        height: 1.4,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lock_rounded,
                    color: AppColors.textSecondaryLight, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l.permLocationPrivacyNote,
                    style: GoogleFonts.inter(
                      fontSize: context.sp(12),
                      height: 1.4,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate(delay: 220.ms)
        .fadeIn(duration: 380.ms)
        .slideY(begin: 0.08, end: 0, duration: 380.ms, curve: Curves.easeOutCubic);
  }
}
