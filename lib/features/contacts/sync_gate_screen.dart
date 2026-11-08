import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/responsive.dart';
import 'sync_status.dart';

/// Blocking gate after sign-in: the user must grant contacts permission AND
/// a successful upload must finish before they can continue. Required for
/// the caller-ID directory to actually be useful.
class SyncGateScreen extends ConsumerStatefulWidget {
  const SyncGateScreen({super.key});

  @override
  ConsumerState<SyncGateScreen> createState() => _SyncGateScreenState();
}

class _SyncGateScreenState extends ConsumerState<SyncGateScreen> {
  bool _permissionGranted = false;
  bool _checkingPermission = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    final granted = await Permission.contacts.isGranted;
    setState(() {
      _permissionGranted = granted;
      _checkingPermission = false;
    });
    if (granted) {
      _runSync();
    }
  }

  Future<void> _grantAndSync() async {
    final r = await Permission.contacts.request();
    setState(() => _permissionGranted = r.isGranted);
    if (r.isGranted) {
      _runSync();
    } else if (r.isPermanentlyDenied) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Permission permanently denied. Open settings to enable Contacts.'),
      ));
      openAppSettings();
    }
  }

  Future<void> _runSync() async {
    final n = await ref.read(syncStatusProvider.notifier).sync();
    if (!mounted) return;
    if (n != null && n >= 0) {
      // Success — auto-advance after a short delay so the user sees the
      // success state.
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      context.go('/auth/gmail');
    }
  }

  @override
  Widget build(BuildContext context) {
    final sync = ref.watch(syncStatusProvider);

    return Scaffold(
      body: SafeArea(
        child: ResponsiveBox(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: context.pagePadding),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildIcon(sync),
                    const SizedBox(height: 24),
                    Text(
                      _title(sync),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: context.sp(22),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _subtitle(sync),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: context.sp(14),
                        color: AppColors.textSecondaryLight,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildAction(sync),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(SyncStatus s) {
    if (_checkingPermission || s.running) {
      return const SizedBox(
        width: 96, height: 96,
        child: CircularProgressIndicator(strokeWidth: 4),
      );
    }
    if (s.lastError != null) {
      return Container(
        width: 96, height: 96,
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.cloud_off_outlined,
            size: 48, color: AppColors.danger),
      );
    }
    if (s.hasEverSynced) {
      return Container(
        width: 96, height: 96,
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.cloud_done_outlined,
            size: 48, color: AppColors.success),
      );
    }
    return Container(
      width: 96, height: 96,
      decoration: BoxDecoration(
        color: AppColors.tint,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.contacts_rounded,
          size: 48, color: AppColors.primary),
    );
  }

  String _title(SyncStatus s) {
    if (_checkingPermission) return 'Preparing…';
    if (!_permissionGranted) return 'Allow contacts access';
    if (s.running) return 'Syncing your contacts';
    if (s.lastError != null) return 'Sync failed';
    if (s.hasEverSynced) return 'All set!';
    return 'Ready to sync';
  }

  String _subtitle(SyncStatus s) {
    if (_checkingPermission) return ' ';
    if (!_permissionGranted) {
      return 'Yellow Fast Call needs your contacts to identify unknown callers and detect spam. Your contacts stay encrypted in transit.';
    }
    if (s.running) {
      return 'Uploading to the server. This usually takes a few seconds.';
    }
    if (s.lastError != null) {
      return s.lastError!;
    }
    if (s.hasEverSynced) {
      return 'Uploaded ${s.lastUploaded ?? 0} contacts. Continuing…';
    }
    return 'Tap to start';
  }

  Widget _buildAction(SyncStatus s) {
    if (_checkingPermission || s.running) return const SizedBox.shrink();

    if (!_permissionGranted) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _grantAndSync,
          icon: const Icon(Icons.lock_open_rounded),
          label: const Text('Allow contacts access'),
        ),
      );
    }

    if (s.lastError != null) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _runSync,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You can\'t continue until contacts are synced.',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      );
    }

    if (s.hasEverSynced) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => context.go('/auth/gmail'),
          child: const Text('Continue'),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _runSync,
        icon: const Icon(Icons.cloud_upload_outlined),
        label: const Text('Start sync'),
      ),
    );
  }
}
