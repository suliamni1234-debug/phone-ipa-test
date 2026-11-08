import 'package:call_log/call_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/responsive.dart';
import '../../l10n/generated/app_localizations.dart';
import 'call_history_service.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(callHistoryProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.historyTitle),
        actions: [
          IconButton(
            tooltip: l.historyRefresh,
            onPressed: () => ref.invalidate(callHistoryProvider),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveBox(
          child: async.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _ErrorState(
              message: e.toString(),
              onRetry: () => ref.invalidate(callHistoryProvider),
            ),
            data: (calls) {
              if (calls.isEmpty) {
                return _PermissionOrEmpty(ref: ref);
              }
              return RefreshIndicator(
                onRefresh: () async => ref.invalidate(callHistoryProvider),
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(
                      horizontal: context.pagePadding, vertical: 12),
                  itemCount: calls.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _CallTile(entry: calls[i]),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CallTile extends StatelessWidget {
  final CallLogEntry entry;
  const _CallTile({required this.entry});

  static String _initials(String? name, String? number) {
    final n = (name ?? '').trim();
    if (n.isNotEmpty) {
      final parts = n.split(RegExp(r'\s+'));
      if (parts.length == 1) return parts.first.characters.first.toUpperCase();
      return (parts.first.characters.first + parts.last.characters.first)
          .toUpperCase();
    }
    final num = (number ?? '').replaceAll(RegExp(r'[^0-9+]'), '');
    if (num.isEmpty) return '?';
    return num.characters.last;
  }

  ({IconData icon, Color color, String label}) _typeFor(
      CallType? t, AppLocalizations l) {
    switch (t) {
      case CallType.incoming:
        return (
          icon: Icons.call_received_rounded,
          color: AppColors.success,
          label: l.historyCallTypeIncoming,
        );
      case CallType.outgoing:
        return (
          icon: Icons.call_made_rounded,
          color: AppColors.primary,
          label: l.historyCallTypeOutgoing,
        );
      case CallType.missed:
        return (
          icon: Icons.call_missed_rounded,
          color: AppColors.spam,
          label: l.historyCallTypeMissed,
        );
      case CallType.rejected:
        return (
          icon: Icons.call_end_rounded,
          color: AppColors.warning,
          label: l.historyCallTypeRejected,
        );
      case CallType.blocked:
        return (
          icon: Icons.block_rounded,
          color: AppColors.spam,
          label: l.historyCallTypeBlocked,
        );
      case CallType.voiceMail:
        return (
          icon: Icons.voicemail_rounded,
          color: AppColors.info,
          label: l.historyCallTypeVoicemail,
        );
      default:
        return (
          icon: Icons.call_rounded,
          color: AppColors.textSecondaryLight,
          label: l.historyCallTypeCall,
        );
    }
  }

  String _timeAgo(int? ts, AppLocalizations l, String localeCode) {
    if (ts == null) return '';
    final d = DateTime.fromMillisecondsSinceEpoch(ts);
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return l.justNow;
    if (diff.inHours < 1) return l.minAgo(diff.inMinutes);
    if (diff.inDays < 1) return DateFormat.jm(localeCode).format(d);
    if (diff.inDays < 7) return DateFormat.E(localeCode).add_jm().format(d);
    return DateFormat.MMMd(localeCode).format(d);
  }

  String _duration(int? sec) {
    if (sec == null || sec == 0) return '';
    final m = sec ~/ 60;
    final s = sec % 60;
    if (m == 0) return '${s}s';
    return '${m}m ${s}s';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    final type = _typeFor(entry.callType, l);
    final displayName = (entry.name?.trim().isNotEmpty == true)
        ? entry.name!
        : (entry.number ?? l.unknown);
    final dur = _duration(entry.duration);
    return InkWell(
      onTap: () {
        final phone = entry.number;
        if (phone != null && phone.isNotEmpty) {
          context.push('/search/result?q=${Uri.encodeComponent(phone)}');
        }
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: type.color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                _initials(entry.name, entry.number),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w800,
                  color: type.color,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(type.icon, size: 13, color: type.color),
                      const SizedBox(width: 4),
                      Text(
                        type.label,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          color: type.color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (dur.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text('· $dur',
                            style: GoogleFonts.inter(
                                fontSize: 11.5,
                                color: AppColors.textSecondaryLight)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Text(
              _timeAgo(entry.timestamp, l, localeCode),
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.textSecondaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 220.ms);
  }
}

class _PermissionOrEmpty extends StatelessWidget {
  final WidgetRef ref;
  const _PermissionOrEmpty({required this.ref});

  Future<void> _grant() async {
    final ok = await CallHistoryService.requestPermission();
    if (ok) ref.invalidate(callHistoryProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96, height: 96,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.call_outlined,
                  size: 44, color: AppColors.primary),
            ),
            const SizedBox(height: 18),
            Text(l.historyEmptyTitle,
                style: GoogleFonts.poppins(
                    fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              l.historyEmptyBody,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  color: AppColors.textSecondaryLight, fontSize: 13),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _grant,
                icon: const Icon(Icons.shield_rounded),
                label: Text(l.historyAllowPhone),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined,
                size: 56, color: AppColors.textSecondaryLight),
            const SizedBox(height: 12),
            Text(l.historyLoadFailed,
                style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(message,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    color: AppColors.textSecondaryLight, fontSize: 12)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(l.tryAgain),
            ),
          ],
        ),
      ),
    );
  }
}
