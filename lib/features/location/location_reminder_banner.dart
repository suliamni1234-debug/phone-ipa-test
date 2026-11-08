import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../main.dart';
import 'location_service.dart';

/// Non-intrusive card that prompts the user to share location when it is
/// either disabled or stale (last reported > [_staleAfter] ago).
///
/// Reminder cadence:
/// - Shows whenever location is OFF or the stored last-report is stale.
/// - User taps "Not now" -> snoozed for [_snoozeDuration].
/// - User taps "Turn on" -> calls [LocationService.reportOnce]; on success
///   the banner hides itself (the underlying state changes).
///
/// Tunables — change these in one place.
const Duration _staleAfter = Duration(days: 3);
const Duration _snoozeDuration = Duration(days: 3);

class LocationReminderBanner extends ConsumerStatefulWidget {
  const LocationReminderBanner({super.key});

  @override
  ConsumerState<LocationReminderBanner> createState() =>
      _LocationReminderBannerState();
}

class _LocationReminderBannerState
    extends ConsumerState<LocationReminderBanner> {
  bool _show = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _evaluate();
  }

  Future<void> _evaluate() async {
    final storage = ref.read(localStorageProvider);
    final snoozedUntil = storage.locationReminderSnoozedUntil;
    if (snoozedUntil != null && DateTime.now().isBefore(snoozedUntil)) {
      if (mounted) setState(() => _show = false);
      return;
    }
    final enabled = await LocationService.isEnabled();
    final last = await LocationService.lastReportAt();
    final stale = last == null ||
        DateTime.now().difference(last) > _staleAfter;
    if (!mounted) return;
    setState(() => _show = !enabled || stale);
  }

  Future<void> _enable() async {
    setState(() => _busy = true);
    final report = await ref.read(locationServiceProvider).reportOnce();
    if (!mounted) return;
    setState(() => _busy = false);
    if (report.ok) {
      await LocationService.setEnabled(true);
      ref.read(locationServiceProvider).startPeriodic();
      if (mounted) {
        final l = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l.locationSaved(
            report.latitude!.toStringAsFixed(4),
            report.longitude!.toStringAsFixed(4),
          )),
        ));
        setState(() => _show = false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(report.message),
      ));
    }
  }

  Future<void> _snooze() async {
    await ref
        .read(localStorageProvider)
        .snoozeLocationReminder(_snoozeDuration);
    if (mounted) setState(() => _show = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_show) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: BoxDecoration(
        color: AppColors.tint,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
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
            child: const Icon(Icons.location_on_outlined,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.locReminderTitle,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                    color: AppColors.primaryDark,
                  ),
                ),
                Text(
                  l.locReminderBody,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _busy ? null : _snooze,
            child: Text(l.locReminderNotNow),
          ),
          FilledButton(
            onPressed: _busy ? null : _enable,
            child: _busy
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Text(l.locReminderTurnOn),
          ),
        ],
      ),
    );
  }
}
