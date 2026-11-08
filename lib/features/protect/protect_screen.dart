import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/responsive.dart';
import '../../l10n/generated/app_localizations.dart';
import 'protect_controller.dart';
import 'protect_storage.dart';

class ProtectScreen extends ConsumerStatefulWidget {
  const ProtectScreen({super.key});

  @override
  ConsumerState<ProtectScreen> createState() => _ProtectScreenState();
}

class _ProtectScreenState extends ConsumerState<ProtectScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(protectControllerProvider.notifier).refreshFromNative();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = ref.watch(protectControllerProvider);
    final controller = ref.read(protectControllerProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: ResponsiveBox(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: context.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: context.hp(2)),
                Text(
                  l.protectTitle,
                  style: GoogleFonts.poppins(
                    fontSize: context.sp(28),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: context.hp(0.5)),
                Text(
                  l.protectSubtitle,
                  style: GoogleFonts.inter(
                    fontSize: context.sp(13.5),
                    color: AppColors.textSecondaryLight,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: context.hp(2.5)),
                _ShieldCard(
                  active: state.isDefaultScreener,
                  blockedCount: state.blockedCount,
                ).animate().fadeIn(duration: 350.ms).slideY(
                    begin: 0.06, end: 0, duration: 350.ms, curve: Curves.easeOutCubic),
                if (!state.isDefaultScreener) ...[
                  const SizedBox(height: 12),
                  _SetDefaultBanner(
                    label: l.protectSetDefaultBanner,
                    onTap: () async {
                      final ok = await controller.requestCallScreenerRole();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(ok
                            ? l.protectScreeningEnabledMsg
                            : l.protectScreeningNeededMsg),
                      ));
                    },
                  ),
                ],
                // Caller-ID popup needs the "display over other apps"
                // permission even once the app is the default screener.
                if (state.isDefaultScreener && !state.hasOverlayPermission) ...[
                  const SizedBox(height: 12),
                  _SetDefaultBanner(
                    label: l.protectCallerIdBanner,
                    icon: Icons.layers_rounded,
                    onTap: () async {
                      final ok = await controller.requestOverlayPermission();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(ok
                            ? l.protectCallerIdEnabledMsg
                            : l.protectCallerIdNeededMsg),
                      ));
                    },
                  ),
                ],
                SizedBox(height: context.hp(3)),
                _SectionTitle(l.protectSettingsSection),
                const SizedBox(height: 10),
                ..._stagger([
                  _ToggleTile(
                    icon: Icons.report_rounded,
                    color: AppColors.spam,
                    title: l.protectBlockSpamTitle,
                    subtitle: l.protectBlockSpamBody,
                    value: state.settings.blockSpam,
                    onChanged: controller.setBlockSpam,
                  ),
                  _ToggleTile(
                    icon: Icons.no_accounts_rounded,
                    color: AppColors.warning,
                    title: l.protectBlockScamTitle,
                    subtitle: l.protectBlockScamBody,
                    value: state.settings.blockScam,
                    onChanged: controller.setBlockScam,
                  ),
                  _ToggleTile(
                    icon: Icons.phone_disabled_rounded,
                    color: AppColors.info,
                    title: l.protectSilenceUnknownTitle,
                    subtitle: l.protectSilenceUnknownBody,
                    value: state.settings.silenceUnknown,
                    onChanged: controller.setSilenceUnknown,
                  ),
                  _ToggleTile(
                    icon: Icons.travel_explore_rounded,
                    color: AppColors.success,
                    title: l.protectIntlFilterTitle,
                    subtitle: l.protectIntlFilterBody,
                    value: state.settings.intlSpamFilter,
                    onChanged: controller.setIntlSpamFilter,
                  ),
                ]),
                SizedBox(height: context.hp(2)),
                Row(
                  children: [
                    Expanded(child: _SectionTitle(l.protectBlockListSection)),
                    TextButton.icon(
                      onPressed: () => _showAddDialog(context, controller),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: Text(l.protectAddNumber),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (state.blockList.isEmpty)
                  _EmptyBlockList()
                else
                  Column(
                    children: state.blockList
                        .map((e) => _BlockedTile(
                              entry: e,
                              onRemove: () => controller.unblockNumber(e.number),
                            ))
                        .toList(),
                  ),
                SizedBox(height: context.hp(4)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Fades each tile in with a small staggered delay.
  List<Widget> _stagger(List<Widget> tiles) {
    return [
      for (var i = 0; i < tiles.length; i++)
        tiles[i].animate(delay: (60 * i).ms).fadeIn(duration: 300.ms).slideX(
            begin: 0.05, end: 0, duration: 300.ms, curve: Curves.easeOutCubic),
    ];
  }

  Future<void> _showAddDialog(
      BuildContext context, ProtectController controller) async {
    final l = AppLocalizations.of(context);
    final numberController = TextEditingController();
    final nameController = TextEditingController();
    final result = await showDialog<_AddDialogResult>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.protectBlockDialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: numberController,
              autofocus: true,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s()]')),
              ],
              decoration: InputDecoration(
                labelText: l.phoneFieldLabel,
                hintText: l.protectBlockDialogPhoneHint,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: l.protectBlockDialogNameLabel,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
          FilledButton(
            onPressed: () => Navigator.pop(
              ctx,
              _AddDialogResult(
                  number: numberController.text, name: nameController.text),
            ),
            child: Text(l.protectBlockButton),
          ),
        ],
      ),
    );
    if (result == null) return;
    final number = result.number.trim();
    if (number.isEmpty) return;
    final added = await controller.blockNumber(
      number,
      name: result.name.trim().isEmpty ? null : result.name.trim(),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(added ? l.protectAddedToBlockList : l.protectAlreadyBlocked),
    ));
  }
}

class _AddDialogResult {
  final String number;
  final String name;
  _AddDialogResult({required this.number, required this.name});
}

class _ShieldCard extends StatelessWidget {
  final bool active;
  final int blockedCount;
  const _ShieldCard({required this.active, required this.blockedCount});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final gradient = active
        ? const [AppColors.primary, AppColors.primaryDark]
        : const [Color(0xFF64748B), Color(0xFF334155)];
    final glow = active
        ? AppColors.primary.withValues(alpha: 0.45)
        : Colors.black.withValues(alpha: 0.25);

    Widget iconBadge = Container(
      width: 66,
      height: 66,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.5),
      ),
      child: const Icon(Icons.verified_user_rounded,
          size: 34, color: Colors.white),
    );
    if (active) {
      iconBadge = iconBadge
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.07, 1.07),
            duration: 1400.ms,
            curve: Curves.easeInOut,
          );
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: glow,
            blurRadius: 30,
            spreadRadius: 1,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -36,
            right: -28,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -44,
            left: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                iconBadge,
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        active
                            ? l.protectShieldActive
                            : l.protectShieldInactive,
                        style: GoogleFonts.poppins(
                          fontSize: context.sp(18),
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        active
                            ? l.protectShieldActiveBody(blockedCount)
                            : l.protectShieldInactiveBody,
                        style: GoogleFonts.inter(
                          fontSize: context.sp(12.5),
                          height: 1.35,
                          color: Colors.white.withValues(alpha: 0.92),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SetDefaultBanner extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _SetDefaultBanner({
    required this.label,
    required this.onTap,
    this.icon = Icons.warning_amber_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.warning.withValues(alpha: 0.16),
              AppColors.warning.withValues(alpha: 0.06),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: AppColors.warning, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: context.sp(13),
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondaryLight),
          ],
        ),
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(
          duration: 1800.ms,
          color: AppColors.warning.withValues(alpha: 0.15),
        );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: context.sp(15),
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: value ? color.withValues(alpha: 0.4) : Colors.transparent,
          ),
          boxShadow: [
            BoxShadow(
              color: value
                  ? color.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color, Color.lerp(color, Colors.black, 0.25)!],
                ),
                borderRadius: BorderRadius.circular(13),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.30),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.inter(
                          fontSize: context.sp(14.5),
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: GoogleFonts.inter(
                          fontSize: context.sp(12.5),
                          color: AppColors.textSecondaryLight,
                          height: 1.3)),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Switch(
              value: value,
              activeThumbColor: AppColors.primary,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyBlockList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.spam.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.block_rounded,
                size: 30, color: AppColors.spam),
          ),
          const SizedBox(height: 14),
          Text(
            l.protectEmptyBlockListTitle,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w800,
              fontSize: context.sp(14.5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l.protectEmptyBlockListBody,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: context.sp(12.5),
              color: AppColors.textSecondaryLight,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _BlockedTile extends StatelessWidget {
  final BlockedNumber entry;
  final VoidCallback onRemove;
  const _BlockedTile({required this.entry, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final label =
        (entry.name != null && entry.name!.isNotEmpty) ? entry.name! : entry.number;
    final sub =
        (entry.name != null && entry.name!.isNotEmpty) ? entry.number : l.protectBlockedSubtitle;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.spam.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(Icons.block_rounded,
                  color: AppColors.spam, size: 20),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.inter(
                          fontSize: context.sp(14.5),
                          fontWeight: FontWeight.w700)),
                  Text(sub,
                      style: GoogleFonts.inter(
                          fontSize: context.sp(12.5),
                          color: AppColors.textSecondaryLight)),
                ],
              ),
            ),
            IconButton(
              tooltip: l.protectUnblock,
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline_rounded),
              color: AppColors.spam,
            ),
          ],
        ),
      ),
    );
  }
}
