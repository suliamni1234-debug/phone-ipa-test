import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/state/user_prefs_controller.dart';
import '../../core/storage/user_prefs.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/responsive.dart';
import '../../l10n/generated/app_localizations.dart';

String _displayStyleLabel(AppLocalizations l, CallerIdDisplayStyle s) {
  switch (s) {
    case CallerIdDisplayStyle.fullScreen:
      return l.callsDisplayFullScreen;
    case CallerIdDisplayStyle.classicPopup:
      return l.callsDisplayClassicPopup;
  }
}

class CallsSettingsScreen extends ConsumerWidget {
  const CallsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final prefs = ref.watch(userPrefsControllerProvider);
    final ctrl = ref.read(userPrefsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l.callsTitle)),
      body: SafeArea(
        child: ResponsiveBox(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: context.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: context.hp(2)),

                _Section(l.callsSectionGeneral, [
                  _Tile(
                    icon: Icons.build_circle_outlined,
                    label: l.callsTroubleshootTitle,
                    subtitle: l.callsTroubleshootSub,
                    onTap: () => _openTroubleshoot(context),
                  ),
                  _Tile(
                    icon: Icons.aspect_ratio_rounded,
                    label: l.callsDisplayStyleTitle,
                    subtitle: l.callsDisplayStyleSub,
                    trailing: _displayStyleLabel(l, prefs.callerIdDisplayStyle),
                    onTap: () => _pickDisplayStyle(context, ref),
                  ),
                  _SwitchTile(
                    icon: Icons.apps_rounded,
                    label: l.callsIdentifyOtherAppsTitle,
                    subtitle: l.callsIdentifyOtherAppsSub,
                    value: prefs.identifyOnOtherApps,
                    onChanged: ctrl.setIdentifyOnOtherApps,
                  ),
                ]),

                _Section(l.callsSectionHistory, [
                  _SwitchTile(
                    icon: Icons.layers_rounded,
                    label: l.callsGroupCallsTitle,
                    subtitle: l.callsGroupCallsSub,
                    value: prefs.groupCallsInHistory,
                    onChanged: ctrl.setGroupCallsInHistory,
                  ),
                  _SwitchTile(
                    icon: Icons.star_outline_rounded,
                    label: l.callsShowFrequentTitle,
                    subtitle: l.callsShowFrequentSub,
                    value: prefs.showFrequentContacts,
                    onChanged: ctrl.setShowFrequentContacts,
                  ),
                  _SwitchTile(
                    icon: Icons.call_merge_rounded,
                    label: l.callsShowFromOtherAppsTitle,
                    subtitle: l.callsShowFromOtherAppsSub,
                    value: prefs.showCallsFromOtherApps,
                    onChanged: ctrl.setShowCallsFromOtherApps,
                  ),
                ]),

                _Section(l.callsSectionNotifications, [
                  _SwitchTile(
                    icon: Icons.notifications_active_outlined,
                    label: l.callsAlertNotifTitle,
                    subtitle: l.callsAlertNotifSub,
                    value: prefs.callAlertNotification,
                    onChanged: ctrl.setCallAlertNotification,
                  ),
                  _SwitchTile(
                    icon: Icons.phone_missed_outlined,
                    label: l.callsMissedNotifTitle,
                    subtitle: l.callsMissedNotifSub,
                    value: prefs.missedCallNotification,
                    onChanged: ctrl.setMissedCallNotification,
                  ),
                  _SwitchTile(
                    icon: Icons.alarm_rounded,
                    label: l.callsRemindMissedTitle,
                    subtitle: l.callsRemindMissedSub,
                    value: prefs.remindMissedCalls,
                    onChanged: ctrl.setRemindMissedCalls,
                  ),
                ]),

                SizedBox(height: context.hp(3)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDisplayStyle(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final current = ref.read(userPrefsControllerProvider).callerIdDisplayStyle;
    final picked = await showModalBottomSheet<CallerIdDisplayStyle>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.callsDisplayStyleTitle,
                  style: GoogleFonts.poppins(
                      fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(
                l.callsDisplayStylePickerSub,
                style: GoogleFonts.inter(
                    fontSize: 12.5, color: AppColors.textSecondaryLight),
              ),
              const SizedBox(height: 16),
              _StyleOption(
                style: CallerIdDisplayStyle.fullScreen,
                selected: current == CallerIdDisplayStyle.fullScreen,
                onTap: () =>
                    Navigator.pop(ctx, CallerIdDisplayStyle.fullScreen),
              ),
              const SizedBox(height: 10),
              _StyleOption(
                style: CallerIdDisplayStyle.classicPopup,
                selected: current == CallerIdDisplayStyle.classicPopup,
                onTap: () =>
                    Navigator.pop(ctx, CallerIdDisplayStyle.classicPopup),
              ),
            ],
          ),
        ),
      ),
    );
    if (picked != null) {
      await ref
          .read(userPrefsControllerProvider.notifier)
          .setCallerIdDisplayStyle(picked);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l.callsDisplayStyleChanged(_displayStyleLabel(l, picked))),
        ));
      }
    }
  }

  Future<void> _openTroubleshoot(BuildContext context) async {
    final l = AppLocalizations.of(context);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: AppColors.bgLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.callsTroubleshootTitle,
                  style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(
                l.callsTroubleshootIntro,
                style: GoogleFonts.inter(
                    fontSize: 12.5, color: AppColors.textSecondaryLight),
              ),
              const SizedBox(height: 14),
              _TipRow(
                icon: Icons.security_rounded,
                text: l.callsTipDefault,
              ),
              _TipRow(
                icon: Icons.layers_outlined,
                text: l.callsTipOverlay,
              ),
              _TipRow(
                icon: Icons.notifications_active_outlined,
                text: l.callsTipNotifications,
              ),
              _TipRow(
                icon: Icons.battery_saver_rounded,
                text: l.callsTipBattery,
              ),
              _TipRow(
                icon: Icons.contacts_outlined,
                text: l.callsTipPermissions,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await openAppSettings();
                },
                icon: const Icon(Icons.settings_outlined),
                label: Text(l.callsOpenAppSettings),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section(this.title, this.children);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, top: 16, bottom: 8),
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final String? trailing;
  final VoidCallback onTap;
  const _Tile({
    required this.icon,
    required this.label,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textPrimaryLight, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        subtitle!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(
                  trailing!,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppColors.textSecondaryLight),
          ],
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchTile({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textPrimaryLight, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        subtitle!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondaryLight,
                        ),
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
      ),
    );
  }
}

class _StyleOption extends StatelessWidget {
  final CallerIdDisplayStyle style;
  final bool selected;
  final VoidCallback onTap;
  const _StyleOption({
    required this.style,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final preview = style == CallerIdDisplayStyle.fullScreen
        ? _fullScreenPreview()
        : _classicPopupPreview();
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.tint : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            SizedBox(width: 64, height: 88, child: preview),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _displayStyleLabel(l, style),
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    style == CallerIdDisplayStyle.fullScreen
                        ? l.callsDisplayFullScreenSub
                        : l.callsDisplayClassicPopupSub,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color:
                  selected ? AppColors.primary : AppColors.textSecondaryLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _fullScreenPreview() => Container(
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.phone_in_talk_rounded,
            color: Colors.white, size: 22),
      );

  Widget _classicPopupPreview() => Container(
        decoration: BoxDecoration(
          color: AppColors.bgLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 3),
            Container(
              height: 6,
              width: 28,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        ),
      );
}

class _TipRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _TipRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.tint,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                color: AppColors.textPrimaryLight,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
