import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/state/user_prefs_controller.dart';
import '../../core/storage/token_storage.dart';
import '../../core/storage/user_prefs.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/responsive.dart';
import '../../l10n/generated/app_localizations.dart';
import '../auth/state/auth_controller.dart';
import '../location/location_service.dart';
import '../profile/avatar_service.dart';
import '../protect/protect_controller.dart';

String _languageName(AppLocalizations l, AppLanguage lang) => switch (lang) {
      AppLanguage.english => l.languageEnglish,
      AppLanguage.arabic => l.languageArabic,
    };

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String? _avatarPath;
  bool _locationEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadAsyncBits();
  }

  Future<void> _loadAsyncBits() async {
    final p = await AvatarService.readLocalPath();
    final loc = await LocationService.isEnabled();
    if (!mounted) return;
    setState(() {
      _avatarPath = p;
      _locationEnabled = loc;
    });
  }

  Future<void> _toggleLocation(bool v) async {
    if (!v) {
      await LocationService.setEnabled(false);
      ref.read(locationServiceProvider).stopPeriodic();
      if (mounted) setState(() => _locationEnabled = false);
      return;
    }

    final l = AppLocalizations.of(context);
    // Show an in-app rationale dialog before asking the OS, so the user always
    // sees a clear "Allow" prompt inside the app — even if Android has marked
    // the permission as permanently denied and won't surface the system dialog.
    final allow = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.location_on_rounded,
            color: AppColors.primary, size: 36),
        title: Text(l.shareLocationDialogTitle),
        content: Text(l.shareLocationDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.shareLocationNotNow),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.shareLocationAllow),
          ),
        ],
      ),
    );
    if (allow != true || !mounted) return;

    final svc = ref.read(locationServiceProvider);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(l.locationGetting),
      duration: const Duration(seconds: 2),
    ));
    final report = await svc.reportOnce();
    if (!mounted) return;
    if (!report.ok) {
      if (report.reason == LocationFailure.permissionDeniedForever) {
        await _showBlockedDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(report.message),
        ));
      }
      return;
    }
    await LocationService.setEnabled(true);
    svc.startPeriodic();
    if (!mounted) return;
    setState(() => _locationEnabled = true);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(AppLocalizations.of(context).locationSaved(
        report.latitude!.toStringAsFixed(4),
        report.longitude!.toStringAsFixed(4),
      )),
    ));
  }

  /// Shown when Android has permanently denied the location permission. The
  /// OS won't show its own dialog any more, so we explain the situation here
  /// and offer a single button to open the system permission page.
  Future<void> _showBlockedDialog() async {
    final l = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.location_off_rounded,
            color: AppColors.danger, size: 36),
        title: Text(l.locationBlockedTitle),
        content: Text(l.locationBlockedBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await openAppSettings();
            },
            child: Text(l.openPermissions),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final prefs = ref.watch(userPrefsControllerProvider);
    final protect = ref.watch(protectControllerProvider);
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: SafeArea(
        child: ResponsiveBox(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: context.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: context.hp(2)),
                _ProfileCard(
                  name: auth.name ?? l.yourName,
                  phone: auth.phoneE164 ?? '—',
                  email: auth.gmail,
                  avatarPath: _avatarPath,
                  onTap: () => _openProfileMenu(
                    name: auth.name ?? l.yourName,
                    phone: auth.phoneE164 ?? '—',
                  ),
                ),
                SizedBox(height: context.hp(3)),

                _Section(l.sectionGeneral, [
                  _Tile(
                    Icons.phone_in_talk_outlined,
                    l.tileCalls,
                    onTap: () => context.push('/settings/calls'),
                  ),
                  _Tile(
                    Icons.dark_mode_outlined,
                    l.tileTheme,
                    trailing: _themeLabel(l, prefs.themeMode),
                    onTap: () => _pickTheme(context, ref),
                  ),
                  _Tile(
                    Icons.language_outlined,
                    l.tileLanguage,
                    trailing: _languageName(l, prefs.language),
                    onTap: () => _pickLanguage(context, ref),
                  ),
                  _Tile(
                    Icons.notifications_outlined,
                    l.tileNotifications,
                    trailing: prefs.notificationsEnabled
                        ? l.notificationsOn
                        : l.notificationsOff,
                    onTap: () => _editNotifications(context, ref),
                  ),
                  _SwitchTile(
                    icon: Icons.location_on_outlined,
                    label: l.shareLocation,
                    subtitle: l.shareLocationSubtitle,
                    value: _locationEnabled,
                    onChanged: _toggleLocation,
                  ),
                ]),

                _Section(l.sectionCallsAndCallerId, [
                  _SwitchTile(
                    icon: Icons.call_outlined,
                    label: l.callerIdOverlay,
                    subtitle: l.callerIdOverlaySubtitle,
                    value: prefs.callerIdOverlay,
                    onChanged: (v) => ref
                        .read(userPrefsControllerProvider.notifier)
                        .setCallerIdOverlay(v),
                  ),
                  _SwitchTile(
                    icon: Icons.history_toggle_off_rounded,
                    label: l.afterCallScreen,
                    subtitle: l.afterCallScreenSubtitle,
                    value: prefs.afterCallScreen,
                    onChanged: (v) => ref
                        .read(userPrefsControllerProvider.notifier)
                        .setAfterCallScreen(v),
                  ),
                  _SwitchTile(
                    icon: Icons.dialpad_rounded,
                    label: l.showAlternateNumbers,
                    subtitle: l.showAlternateNumbersSubtitle,
                    value: prefs.showAlternateNumbers,
                    onChanged: (v) => ref
                        .read(userPrefsControllerProvider.notifier)
                        .setShowAlternateNumbers(v),
                  ),
                  _Tile(
                    Icons.verified_user_outlined,
                    protect.isDefaultScreener
                        ? l.defaultCallScreener
                        : l.setAsDefaultCallScreener,
                    trailing: protect.isDefaultScreener
                        ? l.callScreenerActive
                        : l.callScreenerOff,
                    onTap: () async {
                      if (protect.isDefaultScreener) {
                        await openAppSettings();
                        return;
                      }
                      final ok = await ref
                          .read(protectControllerProvider.notifier)
                          .requestCallScreenerRole();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(ok
                              ? l.callScreenerSetSuccess
                              : l.callScreenerSetFailure),
                        ));
                      }
                    },
                  ),
                ]),

                _Section(l.sectionBlockAndSpam, [
                  _SwitchTile(
                    icon: Icons.report_gmailerrorred_outlined,
                    label: l.blockSpam,
                    subtitle: l.blockSpamSubtitle,
                    value: protect.settings.blockSpam,
                    onChanged: (v) => ref
                        .read(protectControllerProvider.notifier)
                        .setBlockSpam(v),
                  ),
                  _SwitchTile(
                    icon: Icons.warning_amber_rounded,
                    label: l.blockScam,
                    subtitle: l.blockScamSubtitle,
                    value: protect.settings.blockScam,
                    onChanged: (v) => ref
                        .read(protectControllerProvider.notifier)
                        .setBlockScam(v),
                  ),
                  _SwitchTile(
                    icon: Icons.help_outline_rounded,
                    label: l.silenceUnknown,
                    subtitle: l.silenceUnknownSubtitle,
                    value: protect.settings.silenceUnknown,
                    onChanged: (v) => ref
                        .read(protectControllerProvider.notifier)
                        .setSilenceUnknown(v),
                  ),
                  _SwitchTile(
                    icon: Icons.public_rounded,
                    label: l.intlSpamFilter,
                    subtitle: l.intlSpamFilterSubtitle,
                    value: protect.settings.intlSpamFilter,
                    onChanged: (v) => ref
                        .read(protectControllerProvider.notifier)
                        .setIntlSpamFilter(v),
                  ),
                  _Tile(
                    Icons.block_rounded,
                    l.manageBlockList,
                    trailing: '${protect.blockList.length}',
                    onTap: () => context.go('/protect'),
                  ),
                ]),

                _Section(l.sectionSupport, [
                  _Tile(Icons.help_outline_rounded, l.helpCenter,
                      onTap: () => context.push('/settings/help')),
                  _Tile(Icons.description_outlined, l.termsOfService,
                      onTap: () => context.push('/settings/terms')),
                  _Tile(Icons.shield_outlined, l.privacyPolicy,
                      onTap: () => context.push('/settings/privacy')),
                ]),

                _Section(l.sectionAccount, [
                  _Tile(
                    Icons.delete_outline_rounded,
                    l.deleteAccount,
                    color: AppColors.danger,
                    onTap: () => _confirmDeleteAccount(context),
                  ),
                ]),

                SizedBox(height: context.hp(3)),
                Center(
                  child: Text(
                    l.appVersion,
                    style: GoogleFonts.inter(
                      fontSize: context.sp(11.5),
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ),
                SizedBox(height: context.hp(2)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openProfileMenu({
    required String name,
    required String phone,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: AppColors.bgLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _ProfileMenuSheet(
        name: name,
        phone: phone,
        avatarPath: _avatarPath,
        onChangePicture: () async {
          Navigator.pop(ctx);
          await _changeAvatarFlow();
        },
        onEditProfile: () async {
          Navigator.pop(ctx);
          await context.push('/settings/profile');
          _loadAsyncBits();
        },
        onManageBlocking: () {
          Navigator.pop(ctx);
          context.go('/protect');
        },
        onUpgradePremium: () {
          Navigator.pop(ctx);
          context.go('/premium');
        },
        onWhoSearchedMe: () {
          Navigator.pop(ctx);
          context.push('/settings/who-searched-me');
        },
      ),
    );
  }

  Future<void> _changeAvatarFlow() async {
    final l = AppLocalizations.of(context);
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l.chooseFromGallery),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: Text(l.takeAPhoto),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (source == null) return;
    try {
      final path =
          await ref.read(avatarServiceProvider).pickAndUpload(source: source);
      if (!mounted) return;
      if (path != null) {
        setState(() => _avatarPath = path);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.profilePictureUpdated)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.couldNotSetPicture(e.toString()))),
      );
    }
  }

  String _themeLabel(AppLocalizations l, ThemeMode m) => switch (m) {
        ThemeMode.dark => l.themeDark,
        ThemeMode.light => l.themeLight,
        ThemeMode.system => l.themeSystem,
      };

  Future<void> _pickTheme(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final current = ref.read(userPrefsControllerProvider).themeMode;
    final picked = await showDialog<ThemeMode>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l.tileTheme),
        children: [
          for (final m in ThemeMode.values)
            RadioListTile<ThemeMode>(
              title: Text(_themeLabel(l, m)),
              value: m,
              groupValue: current,
              onChanged: (v) => Navigator.pop(ctx, v),
            ),
        ],
      ),
    );
    if (picked != null) {
      await ref.read(userPrefsControllerProvider.notifier).setThemeMode(picked);
    }
  }

  Future<void> _pickLanguage(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final current = ref.read(userPrefsControllerProvider).language;
    final picked = await showDialog<AppLanguage>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l.languageDialogTitle),
        children: [
          for (final lang in AppLanguage.values)
            RadioListTile<AppLanguage>(
              title: Text(_languageName(l, lang)),
              value: lang,
              groupValue: current,
              onChanged: (v) => Navigator.pop(ctx, v),
            ),
        ],
      ),
    );
    if (picked != null) {
      await ref.read(userPrefsControllerProvider.notifier).setLanguage(picked);
      if (context.mounted) {
        final updated = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(updated
              .languageSetTo(_languageName(updated, picked))),
        ));
      }
    }
  }

  Future<void> _editNotifications(BuildContext context, WidgetRef ref) async {
    final enabled = ref.read(userPrefsControllerProvider).notificationsEnabled;
    final result = await showModalBottomSheet<_NotifResult>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => _NotificationsSheet(initialEnabled: enabled),
    );
    if (result == null) return;
    if (result.toggled != null) {
      await ref
          .read(userPrefsControllerProvider.notifier)
          .setNotificationsEnabled(result.toggled!);
    }
    if (result.openSystemSettings) {
      await openAppSettings();
    }
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.deleteAccountTitle),
        content: Text(l.deleteAccountBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.delete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await TokenStorage().clear();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l.accountDeleted),
      ));
      context.go('/auth/phone');
    }
  }
}

class _NotifResult {
  final bool? toggled;
  final bool openSystemSettings;
  _NotifResult({this.toggled, this.openSystemSettings = false});
}

class _NotificationsSheet extends StatefulWidget {
  final bool initialEnabled;
  const _NotificationsSheet({required this.initialEnabled});

  @override
  State<_NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends State<_NotificationsSheet> {
  late bool _enabled = widget.initialEnabled;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.tileNotifications,
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(
              l.notificationsSheetSubtitle,
              style: GoogleFonts.inter(
                  fontSize: 13, color: AppColors.textSecondaryLight),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              value: _enabled,
              onChanged: (v) => setState(() => _enabled = v),
              title: Text(l.enableNotifications),
              activeThumbColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
            ),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(
                  context,
                  _NotifResult(toggled: _enabled, openSystemSettings: true)),
              icon: const Icon(Icons.settings_outlined),
              label: Text(l.openSystemSettings),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(context, _NotifResult(toggled: _enabled)),
              child: Text(l.save),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String name;
  final String phone;
  final String? email;
  final String? avatarPath;
  final VoidCallback onTap;
  const _ProfileCard({
    required this.name,
    required this.phone,
    this.email,
    this.avatarPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.tint,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.10),
              blurRadius: 24,
              spreadRadius: 1,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                image: avatarPath != null
                    ? DecorationImage(
                        image: FileImage(File(avatarPath!)),
                        fit: BoxFit.cover,
                      )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: avatarPath != null
                  ? null
                  : Text(
                      name.isNotEmpty
                          ? name.characters.first.toUpperCase()
                          : '?',
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: context.sp(17),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    phone,
                    style: GoogleFonts.inter(
                      fontSize: context.sp(12.5),
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  if (email != null)
                    Text(
                      email!,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: context.sp(12.5),
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: AppColors.textSecondaryLight),
          ],
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
  final String? trailing;
  final Color? color;
  final VoidCallback onTap;
  const _Tile(this.icon, this.label,
      {this.trailing, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textPrimaryLight;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: c, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: c,
                ),
              ),
            ),
            if (trailing != null)
              Text(
                trailing!,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            const SizedBox(width: 6),
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

class _ProfileMenuSheet extends StatelessWidget {
  final String name;
  final String phone;
  final String? avatarPath;
  final VoidCallback onChangePicture;
  final VoidCallback onEditProfile;
  final VoidCallback onManageBlocking;
  final VoidCallback onUpgradePremium;
  final VoidCallback onWhoSearchedMe;

  const _ProfileMenuSheet({
    required this.name,
    required this.phone,
    required this.avatarPath,
    required this.onChangePicture,
    required this.onEditProfile,
    required this.onManageBlocking,
    required this.onUpgradePremium,
    required this.onWhoSearchedMe,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: GestureDetector(
                onTap: onChangePicture,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.primary,
                      backgroundImage: avatarPath != null
                          ? FileImage(File(avatarPath!))
                          : null,
                      child: avatarPath != null
                          ? null
                          : Text(
                              name.isNotEmpty
                                  ? name.characters.first.toUpperCase()
                                  : '?',
                              style: GoogleFonts.poppins(
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(Icons.camera_alt_rounded,
                            color: Colors.white, size: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                name,
                style: GoogleFonts.poppins(
                    fontSize: 17, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 2),
            Center(
              child: Text(
                phone,
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textSecondaryLight),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: TextButton.icon(
                onPressed: onChangePicture,
                icon: const Icon(Icons.image_outlined, size: 18),
                label: Text(
                  avatarPath == null ? l.addPicture : l.changePicture,
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 4),
            OutlinedButton.icon(
              onPressed: onEditProfile,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: Text(l.tileEditProfile),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _MenuTile(
                    icon: Icons.block_rounded,
                    label: l.manageBlocking,
                    subtitle: l.manageBlockingSubtitle,
                    onTap: onManageBlocking,
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 14),
                  _MenuTile(
                    icon: Icons.workspace_premium_rounded,
                    label: l.upgradeToPremium,
                    subtitle: l.upgradeToPremiumSubtitle,
                    color: AppColors.warning,
                    onTap: onUpgradePremium,
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 14),
                  _MenuTile(
                    icon: Icons.visibility_outlined,
                    label: l.whoSearchedMe,
                    subtitle: l.whoSearchedMeSubtitle,
                    onTap: onWhoSearchedMe,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color? color;
  final VoidCallback onTap;
  const _MenuTile({
    required this.icon,
    required this.label,
    this.subtitle,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: c.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: c, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
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
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppColors.textSecondaryLight),
          ],
        ),
      ),
    );
  }
}
