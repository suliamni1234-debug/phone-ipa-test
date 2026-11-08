import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/storage/local_storage.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/responsive.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../main.dart' show localStorageProvider;
import '../../shared/widgets/primary_button.dart';
import '../auth/state/auth_controller.dart';
import '../profile/avatar_service.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  final _formKey = GlobalKey<FormState>();

  String? _avatarPath;
  bool _avatarBusy = false;

  @override
  void initState() {
    super.initState();
    final s = ref.read(authControllerProvider);
    _name = TextEditingController(text: s.name ?? '');
    _email = TextEditingController(text: s.gmail ?? '');
    AvatarService.readLocalPath().then((p) {
      if (mounted) setState(() => _avatarPath = p);
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l = AppLocalizations.of(context);
    final ok = await ref
        .read(authControllerProvider.notifier)
        .saveName(_name.text.trim());
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.profileUpdatedMsg)),
      );
      context.pop();
    } else {
      final err =
          ref.read(authControllerProvider).error ?? l.profileSaveFailedMsg;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err)),
      );
    }
  }

  Future<void> _pickAvatar() async {
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
    setState(() => _avatarBusy = true);
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
    } finally {
      if (mounted) setState(() => _avatarBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final auth = ref.watch(authControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.profileEditTitle)),
      body: SafeArea(
        child: ResponsiveBox(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: context.pagePadding),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: context.hp(2)),
                  Center(
                    child: GestureDetector(
                      onTap: _avatarBusy ? null : _pickAvatar,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColors.primary,
                            backgroundImage: _avatarPath != null
                                ? FileImage(File(_avatarPath!))
                                : null,
                            child: _avatarPath != null
                                ? null
                                : Text(
                                    (_name.text.isNotEmpty
                                            ? _name.text.characters.first
                                            : '?')
                                        .toUpperCase(),
                                    style: GoogleFonts.poppins(
                                      fontSize: 36,
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
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                              padding: const EdgeInsets.all(6),
                              child: _avatarBusy
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.camera_alt_rounded,
                                      color: Colors.white, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: context.hp(1)),
                  Center(
                    child: TextButton(
                      onPressed: _avatarBusy ? null : _pickAvatar,
                      child: Text(
                        _avatarPath == null
                            ? l.profileAddPicture
                            : l.profileChangePicture,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: context.hp(2)),
                  Builder(builder: (_) {
                    final storage = ref.watch(localStorageProvider);
                    final left = storage.nameChangeCooldownRemaining;
                    final locked = left > Duration.zero;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _name,
                          enabled: !locked,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            labelText: l.profileFullName,
                            prefixIcon: const Icon(Icons.person_outline_rounded),
                            suffixIcon: locked
                                ? Icon(Icons.lock_outline_rounded,
                                    color: AppColors.textSecondaryLight)
                                : null,
                            helperText: locked
                                ? _cooldownHelperText(l, left)
                                : l.profileFullNameHelper,
                            helperMaxLines: 2,
                          ),
                          textCapitalization: TextCapitalization.words,
                          validator: (v) {
                            final s = v?.trim() ?? '';
                            if (s.length < 2) return l.nameValidationShort;
                            return null;
                          },
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: auth.phoneE164 ?? '',
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: l.profilePhoneVerified,
                      prefixIcon: const Icon(Icons.phone_iphone_rounded),
                      suffixIcon: const Icon(Icons.verified_rounded,
                          color: AppColors.success),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _email,
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: l.profileGmailOptional,
                      prefixIcon: const Icon(Icons.mail_outline_rounded),
                    ),
                  ),
                  SizedBox(height: context.hp(3)),
                  Builder(builder: (_) {
                    final storage = ref.watch(localStorageProvider);
                    final history = storage.nameHistory;
                    if (history.isEmpty) return const SizedBox.shrink();
                    return _PreviousNamesSection(history: history);
                  }),
                  SizedBox(height: context.hp(2)),
                  Builder(builder: (_) {
                    final storage = ref.watch(localStorageProvider);
                    final locked = storage.nameChangeCooldownRemaining >
                        Duration.zero;
                    return PrimaryButton(
                      label: l.save,
                      loading: auth.loading,
                      onPressed: locked ? null : _save,
                    );
                  }),
                  SizedBox(height: context.hp(2)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _cooldownHelperText(AppLocalizations l, Duration left) {
  if (left.inDays >= 1) {
    final days = left.inDays + (left.inHours % 24 > 0 ? 1 : 0);
    return l.profileFullNameLockedDays(days);
  }
  final hours = left.inHours + (left.inMinutes % 60 > 0 ? 1 : 0);
  if (hours >= 1) {
    return l.profileFullNameLockedHours(hours);
  }
  final mins = left.inMinutes.clamp(1, 60);
  return l.profileFullNameLockedMinutes(mins);
}

class _PreviousNamesSection extends StatelessWidget {
  final List<NameHistoryEntry> history;
  const _PreviousNamesSection({required this.history});

  String _formatDate(DateTime t) {
    final l = t.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${l.year}-${two(l.month)}-${two(l.day)}';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    // Newest first.
    final entries = [...history]..sort((a, b) => b.at.compareTo(a.at));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history_rounded,
                  size: 18, color: AppColors.textSecondaryLight),
              const SizedBox(width: 6),
              Text(l.profilePreviousNames,
                  style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 4),
          for (final e in entries) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(e.name,
                      style: GoogleFonts.inter(fontSize: 13)),
                ),
                Text(_formatDate(e.at),
                    style: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: AppColors.textSecondaryLight)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
