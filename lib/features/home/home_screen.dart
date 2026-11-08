import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/responsive.dart';
import '../../l10n/generated/app_localizations.dart';
import 'package:call_log/call_log.dart';
import 'package:intl/intl.dart';

import '../ads/rewarded_ad_service.dart';
import '../auth/state/auth_controller.dart';
import '../contacts/quota_provider.dart';
import '../contacts/sync_status.dart' show syncStatusProvider;
import '../history/call_history_service.dart';
import '../profile/avatar_service.dart';
import '../protect/protect_controller.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _avatarPath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeSyncContacts();
      ref.read(searchQuotaProvider.notifier).refresh();
      ref.read(protectControllerProvider.notifier).refreshFromNative();
      _loadAvatar();
    });
  }

  Future<void> _maybeSyncContacts() async {
    if (await Permission.contacts.isGranted) {
      await ref.read(syncStatusProvider.notifier).sync();
    }
  }

  Future<void> _loadAvatar() async {
    final p = await AvatarService.readLocalPath();
    if (!mounted) return;
    setState(() => _avatarPath = p);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ResponsiveBox(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _HeroHeader(avatarPath: _avatarPath),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                      context.pagePadding, 16, context.pagePadding, 8),
                  child: _SearchBar(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                      context.pagePadding, 16, context.pagePadding, 8),
                  child: Text(
                    AppLocalizations.of(context).homeQuickActions,
                    style: GoogleFonts.poppins(
                      fontSize: context.sp(13),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: context.pagePadding),
                  child: const _ActionGrid(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                      context.pagePadding, 16, context.pagePadding, 8),
                  child: const _StatCards(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                      context.pagePadding, 24, context.pagePadding, 8),
                  child: Row(
                    children: [
                      Text(
                        AppLocalizations.of(context).homeRecentCalls,
                        style: GoogleFonts.poppins(
                          fontSize: context.sp(16),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => context.push('/history'),
                        child: Text(AppLocalizations.of(context).homeSeeAll),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                      context.pagePadding, 4, context.pagePadding, 24),
                  child: const _RecentCallsPreview(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroHeader extends ConsumerWidget {
  final String? avatarPath;
  const _HeroHeader({required this.avatarPath});

  String _initial(String? name) {
    final n = (name ?? '').trim();
    if (n.isEmpty) return '?';
    return n.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final l = AppLocalizations.of(context);
    final name = (auth.name?.trim().isNotEmpty == true)
        ? auth.name!
        : l.homeHelloFallbackName;
    return Container(
      margin: EdgeInsets.fromLTRB(
          context.pagePadding, context.hp(1.5), context.pagePadding, 0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 30,
            spreadRadius: 0,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative translucent circles for depth.
          Positioned(
            top: -34,
            right: -24,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -16,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 14, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _HeaderAvatar(
                        avatarPath: avatarPath, initial: _initial(auth.name)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.homeHello,
                            style: GoogleFonts.inter(
                              fontSize: context.sp(12.5),
                              color: Colors.white.withValues(alpha: 0.85),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: context.sp(22),
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () => context.push('/settings'),
                        icon: const Icon(Icons.settings_outlined,
                            color: Colors.white),
                        tooltip: l.homeSettingsTooltip,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const _HeaderQuotaRow(),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms).slideY(
          begin: -0.04,
          end: 0,
          duration: 350.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

class _HeaderAvatar extends StatelessWidget {
  final String? avatarPath;
  final String initial;
  const _HeaderAvatar({required this.avatarPath, required this.initial});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48, height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
        image: avatarPath != null
            ? DecorationImage(
                image: FileImage(File(avatarPath!)),
                fit: BoxFit.cover,
              )
            : null,
      ),
      alignment: Alignment.center,
      child: avatarPath != null
          ? null
          : Text(
              initial,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
    );
  }
}

class _HeaderQuotaRow extends ConsumerWidget {
  const _HeaderQuotaRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final q = ref.watch(searchQuotaProvider);
    return q.when(
      loading: () => const SizedBox(height: 28),
      error: (_, __) => const SizedBox(height: 28),
      data: (quota) {
        final remaining = quota.remaining;
        final limit = quota.limit;
        final progress = limit == 0 ? 0.0 : remaining / limit;
        final l = AppLocalizations.of(context);
        return Row(
          children: [
            const Icon(Icons.bolt_rounded, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              l.homeSearchesLeft(remaining, limit),
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 5,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SearchBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    // iOS-style filled rounded search field: no hard border, soft shadow, pill
    // shape.
    return GestureDetector(
      onTap: () => context.push('/search'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
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
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: AppColors.textSecondaryLight),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l.homeSearchHint,
                style: GoogleFonts.inter(
                  fontSize: context.sp(14),
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ),
            const _QuotaPill(),
          ],
        ),
      ),
    );
  }
}

class _ActionGrid extends StatelessWidget {
  const _ActionGrid();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ActionTile(
                icon: Icons.contacts_rounded,
                color: AppColors.primary,
                label: l.homeActionContacts,
                subtitle: l.homeActionContactsSubtitle,
                onTap: () => context.push('/contacts'),
                animateDelayMs: 0,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionTile(
                icon: Icons.history_rounded,
                color: AppColors.info,
                label: l.homeActionHistory,
                subtitle: l.homeActionHistorySubtitle,
                onTap: () => context.push('/history'),
                animateDelayMs: 60,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionTile(
                icon: Icons.block_rounded,
                color: AppColors.spam,
                label: l.homeActionBlock,
                subtitle: l.homeActionBlockSubtitle,
                onTap: () => context.push('/protect'),
                animateDelayMs: 120,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionTile(
                icon: Icons.star_rounded,
                color: AppColors.warning,
                label: l.homeActionPremium,
                subtitle: l.homeActionPremiumSubtitle,
                onTap: () => context.push('/premium'),
                animateDelayMs: 180,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final int animateDelayMs;
  const _ActionTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.animateDelayMs = 0,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color, Color.lerp(color, Colors.black, 0.25)!],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.30),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 14),
            Text(label,
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w800, fontSize: 14.5)),
            Text(subtitle,
                style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: AppColors.textSecondaryLight)),
          ],
        ),
      )
          .animate()
          .fadeIn(
              duration: 280.ms, delay: Duration(milliseconds: animateDelayMs))
          .slideY(
              begin: 0.05,
              end: 0,
              duration: 280.ms,
              delay: Duration(milliseconds: animateDelayMs),
              curve: Curves.easeOutCubic),
    );
  }
}

class _RecentCallsPreview extends ConsumerWidget {
  const _RecentCallsPreview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(recentCallsPreviewProvider);
    return async.when(
      loading: () => const _RecentCallsSkeleton(),
      error: (_, __) => _RecentCallsEmpty(
        title: l.homeRecentLoadFailedTitle,
        body: l.homeRecentLoadFailedBody,
      ),
      data: (calls) {
        if (calls.isEmpty) {
          return _RecentCallsEmpty(
            title: l.homeRecentEmptyTitle,
            body: l.homeRecentEmptyBody,
          );
        }
        return Column(
          children: [
            for (final c in calls)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _PreviewCallTile(entry: c),
              ),
          ],
        );
      },
    );
  }
}

class _PreviewCallTile extends StatelessWidget {
  final CallLogEntry entry;
  const _PreviewCallTile({required this.entry});

  ({IconData icon, Color color}) _typeFor(CallType? t) {
    switch (t) {
      case CallType.incoming:
        return (icon: Icons.call_received_rounded, color: AppColors.success);
      case CallType.outgoing:
        return (icon: Icons.call_made_rounded, color: AppColors.primary);
      case CallType.missed:
        return (icon: Icons.call_missed_rounded, color: AppColors.spam);
      case CallType.rejected:
        return (icon: Icons.call_end_rounded, color: AppColors.warning);
      case CallType.blocked:
        return (icon: Icons.block_rounded, color: AppColors.spam);
      default:
        return (icon: Icons.call_rounded, color: AppColors.textSecondaryLight);
    }
  }

  String _timeAgo(BuildContext context, int? ts) {
    if (ts == null) return '';
    final l = AppLocalizations.of(context);
    final d = DateTime.fromMillisecondsSinceEpoch(ts);
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return l.justNow;
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return DateFormat.jm().format(d);
    if (diff.inDays < 7) return DateFormat.E().format(d);
    return DateFormat.MMMd().format(d);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = _typeFor(entry.callType);
    final displayName = (entry.name?.trim().isNotEmpty == true)
        ? entry.name!
        : (entry.number ?? l.unknown);
    return InkWell(
      onTap: () {
        final phone = entry.number;
        if (phone != null && phone.isNotEmpty) {
          context.push('/search/result?q=${Uri.encodeComponent(phone)}');
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: t.color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(t.icon, color: t.color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700, fontSize: 13.5)),
                  if (entry.number != null &&
                      entry.name?.trim().isNotEmpty == true)
                    Text(entry.number!,
                        style: GoogleFonts.inter(
                            fontSize: 11.5,
                            color: AppColors.textSecondaryLight)),
                ],
              ),
            ),
            Text(_timeAgo(context, entry.timestamp),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textSecondaryLight,
                  fontWeight: FontWeight.w600,
                )),
          ],
        ),
      ),
    );
  }
}

class _RecentCallsSkeleton extends StatelessWidget {
  const _RecentCallsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: const Center(
        child: SizedBox(
          width: 22, height: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

class _RecentCallsEmpty extends StatelessWidget {
  final String title;
  final String body;
  const _RecentCallsEmpty({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                )
                    .animate(onPlay: (c) => c.repeat())
                    .scale(
                      begin: const Offset(0.85, 0.85),
                      end: const Offset(1.05, 1.05),
                      duration: 1500.ms,
                      curve: Curves.easeInOut,
                    )
                    .then()
                    .scale(
                      begin: const Offset(1.05, 1.05),
                      end: const Offset(0.85, 0.85),
                      duration: 1500.ms,
                      curve: Curves.easeInOut,
                    ),
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.call_outlined,
                      color: AppColors.primary, size: 28),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w800,
                fontSize: context.sp(15),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                body,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: context.sp(12),
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuotaPill extends ConsumerStatefulWidget {
  const _QuotaPill();

  @override
  ConsumerState<_QuotaPill> createState() => _QuotaPillState();
}

class _QuotaPillState extends ConsumerState<_QuotaPill> {
  bool _adInProgress = false;

  Future<void> _watchAd() async {
    setState(() => _adInProgress = true);
    final svc = RewardedAdService();
    await svc.showRewarded(
      onEarnedReward: () async {
        final granted =
            await ref.read(searchQuotaProvider.notifier).claimAdReward();
        if (!mounted) return;
        setState(() => _adInProgress = false);
        final l = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(granted ? l.homeWatchAdSuccess : l.homeWatchAdFail),
        ));
      },
      onFailed: (msg) {
        if (!mounted) return;
        setState(() => _adInProgress = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = ref.watch(searchQuotaProvider);
    return q.when(
      loading: () => const SizedBox(width: 0, height: 0),
      error: (_, __) => const SizedBox(width: 0, height: 0),
      data: (quota) {
        final exhausted = quota.exhausted;
        if (exhausted && quota.canWatchAd) {
          return InkWell(
            onTap: _adInProgress ? null : _watchAd,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_adInProgress)
                    const SizedBox(
                      width: 12, height: 12,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  else
                    const Icon(Icons.play_circle_outline_rounded,
                        size: 14, color: Colors.white),
                  const SizedBox(width: 5),
                  Text(
                    AppLocalizations.of(context).homeWatchAdPlusOne,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        final color = exhausted ? AppColors.danger : AppColors.primary;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '${quota.remaining}/${quota.limit}',
            style: GoogleFonts.inter(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        );
      },
    );
  }
}

class _StatCards extends ConsumerWidget {
  const _StatCards();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // "Spam blocked" = calls the native screener rejected for us PLUS any
    // numbers the user has manually added to the block list. This way the
    // counter reflects activity even before the default-screener flow is
    // wired up on a particular device.
    final protect = ref.watch(protectControllerProvider);
    final spamBlocked = protect.blockedCount + protect.blockList.length;

    // "Identified" = searches the user has run in the rolling 24h window.
    // Each successful /lookup or /search increments quota.used server-side,
    // so this number ticks up as the user actually uses the app.
    final quotaAsync = ref.watch(searchQuotaProvider);
    final identified = quotaAsync.maybeWhen(
      data: (q) => q.used,
      orElse: () => 0,
    );

    final l = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            color: AppColors.primary,
            icon: Icons.shield_rounded,
            value: '$spamBlocked',
            label: l.homeStatSpamBlocked,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            color: AppColors.success,
            icon: Icons.person_search_rounded,
            value: '$identified',
            label: l.homeStatIdentified,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String value;
  final String label;
  const _StatCard({
    required this.color,
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    // Vivid gradient-filled stat card with white text — reads clearly as a
    // premium dashboard tile.
    final dark = Color.lerp(color, Colors.black, 0.22)!;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, dark],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: context.sp(26),
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: context.sp(12.5),
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}
