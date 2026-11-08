import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/responsive.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../main.dart';
import '../ads/rewarded_ad_service.dart';
import '../auth/state/auth_controller.dart';
import '../contacts/data/contacts_repository.dart';
import '../contacts/quota_provider.dart';
import '../protect/protect_controller.dart' show homeDialCodeFromE164;

class SearchResultScreen extends ConsumerStatefulWidget {
  final String query;
  const SearchResultScreen({super.key, required this.query});

  @override
  ConsumerState<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends ConsumerState<SearchResultScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _data;
  LookupResult? _quotaBlocked;
  bool _adInProgress = false;
  late String _normalizedPhone;

  @override
  void initState() {
    super.initState();
    final dialCode =
        homeDialCodeFromE164(ref.read(localStorageProvider).userPhone);
    _normalizedPhone = _normalize(widget.query, dialCode);
    _load();
  }

  /// Expands any common format to full +E.164 using the user's home dial
  /// code (e.g. "964"), mirroring the native resolver, so all of these find
  /// the same number: +9647701234567, 009647701234567, 9647701234567,
  /// 07701234567, 7701234567. The backend does the same expansion — this just
  /// keeps the displayed/cached phone canonical too.
  static String _normalize(String input, String? dialCode) {
    final s = input.trim();
    if (s.isEmpty) return s;
    final hasPlus = s.startsWith('+');
    var digits = s.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';
    if (hasPlus) return '+$digits';
    if (digits.startsWith('00')) return '+${digits.substring(2)}';
    final dc = dialCode?.replaceAll(RegExp(r'[^0-9]'), '');
    if (dc == null || dc.isEmpty) return '+$digits';
    if (digits.startsWith('0')) digits = digits.substring(1);
    if (digits.startsWith(dc)) return '+$digits';
    return '+$dc$digits';
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _quotaBlocked = null;
    });
    try {
      final repo = ref.read(contactsRepositoryProvider);
      final res = await repo.lookup(_normalizedPhone);
      if (!res.ok) {
        // 429 — quota exceeded
        ref.read(searchQuotaProvider.notifier).updateFromMap(res.quota);
        setState(() {
          _quotaBlocked = res;
          _loading = false;
        });
        return;
      }
      ref.read(searchQuotaProvider.notifier).updateFromMap(res.quota);
      setState(() {
        _data = res.data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _watchAdForReward() async {
    setState(() => _adInProgress = true);
    final svc = RewardedAdService();
    await svc.showRewarded(
      onEarnedReward: () async {
        final granted =
            await ref.read(searchQuotaProvider.notifier).claimAdReward();
        if (!mounted) return;
        setState(() => _adInProgress = false);
        final l = AppLocalizations.of(context);
        if (granted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(l.searchAdAddedLoading),
          ));
          _load();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(l.searchAdFail),
          ));
        }
      },
      onFailed: (msg) {
        if (!mounted) return;
        setState(() => _adInProgress = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      },
    );
  }

  String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_quotaBlocked != null) {
      final q = _quotaBlocked!.quota ?? const {};
      final reset = q['resets_at'] is String
          ? DateTime.tryParse(q['resets_at'] as String)?.toLocal()
          : null;
      final canWatchAd = q['can_watch_ad'] == true;
      return Scaffold(
        appBar: AppBar(title: Text(l.callerInfoTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 96, height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.timer_off_rounded,
                      size: 48, color: AppColors.warning),
                ),
                const SizedBox(height: 18),
                Text(l.searchQuotaTitle,
                    style: GoogleFonts.poppins(
                        fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(
                  l.searchQuotaBody(
                    '${q['used'] ?? '?'}',
                    '${q['limit'] ?? 20}',
                  ),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: AppColors.textSecondaryLight),
                ),
                if (reset != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    l.searchQuotaReset(_relTime(l, reset)),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                        color: AppColors.textSecondaryLight, fontSize: 13),
                  ),
                ],
                const SizedBox(height: 22),
                if (canWatchAd)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _adInProgress ? null : _watchAdForReward,
                      icon: _adInProgress
                          ? const SizedBox(
                              width: 18, height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.play_circle_outline_rounded),
                      label: Text(l.searchWatchAdForReward),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      l.searchAdMaxUsed,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.callerInfoTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off_outlined,
                    size: 56, color: AppColors.textSecondaryLight),
                const SizedBox(height: 12),
                Text(l.callerInfoLoadFailed,
                    style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(_error!, textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                        color: AppColors.textSecondaryLight, fontSize: 12)),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: _load, child: Text(l.tryAgain)),
              ],
            ),
          ),
        ),
      );
    }

    final data = _data ?? const {};
    final topName = data['name'] as String?;
    final names = (data['names'] as List?)?.cast<dynamic>() ?? const [];
    final counts = (data['counts'] as Map?)?.cast<String, dynamic>() ?? const {};
    final seenBy = _asInt(data['seen_by']);
    final spamReports = _asInt(data['spam_reports']);
    final isSpam = spamReports >= 3;
    final phone = (data['phone'] as String?) ?? _normalizedPhone;
    final isRegistered = data['is_registered'] == true;
    final registeredName = data['registered_name'] as String?;
    final registeredEmail = data['registered_email'] as String?;
    final registeredSince = data['registered_since'] as String?;
    final country = (data['country'] as Map?)?.cast<String, dynamic>();

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: Column(
        children: [
          _CallerHero(
            name: topName,
            phone: phone,
            isSpam: isSpam,
            isRegistered: isRegistered,
            registeredName: registeredName,
            seenBy: seenBy,
            spamReports: spamReports,
            initials: topName == null ? null : _initials(topName),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: ResponsiveBox(
                child: SingleChildScrollView(
                  padding:
                      EdgeInsets.symmetric(horizontal: context.pagePadding),
                  child: Column(
                    children: [
                      SizedBox(height: context.hp(2.5)),
                      if (names.length > 1) _AlsoKnownAs(names: names, counts: counts),
                if (isRegistered)
                  _InfoCard(
                    title: l.callerInfoRegisteredAccount,
                    children: [
                      _InfoRow(l.callerInfoLoginName, registeredName ?? '—'),
                      _InfoRow(l.callerInfoEmail, registeredEmail ?? '—'),
                      _InfoRow(l.callerInfoMemberSince,
                          registeredSince == null ? '—' : _fmtDate(registeredSince)),
                    ],
                  ),
                if (isRegistered) SizedBox(height: context.hp(2)),
                _InfoCard(
                  title: l.callerInfoAbout,
                  children: [
                    _InfoRow(l.callerInfoMostLikelyName, topName ?? '—'),
                    _InfoRow(l.callerInfoCountry,
                        country == null
                            ? l.unknown
                            : '${country['name']} (${country['code']})'),
                    _InfoRow(l.callerInfoSeenBy,
                        seenBy == 0 ? l.callerInfoNobodyYet : l.callerInfoUsersCount(seenBy)),
                    _InfoRow(l.callerInfoDifferentNames, '${names.length}'),
                  ],
                ),
                SizedBox(height: context.hp(2)),
                if (names.isNotEmpty)
                  _UploadersCard(names: names, counts: counts),
                if (names.isNotEmpty) SizedBox(height: context.hp(2)),
                _InfoCard(
                  title: l.callerInfoCommunityReports,
                  children: [
                    _InfoRow(l.callerInfoSpamReports, '$spamReports'),
                    _InfoRow(l.callerInfoStatus,
                        isSpam ? l.callerInfoFlagged : l.callerInfoNotFlagged),
                  ],
                ),
                      SizedBox(height: context.hp(4)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Coerces a JSON value (number, numeric string, null) to int. Backend SUM()
/// results come back as DECIMAL strings, which would crash an `as num` cast.
int _asInt(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toInt();
  if (v is String) return num.tryParse(v)?.toInt() ?? 0;
  return 0;
}

String _fmtDate(String iso) {
  final d = DateTime.tryParse(iso)?.toLocal();
  if (d == null) return iso;
  return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

class _UploadersCard extends StatelessWidget {
  final List<dynamic> names;
  final Map<String, dynamic> counts;
  const _UploadersCard({required this.names, required this.counts});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final entries = names
        .map((n) => MapEntry(n.toString(), _asInt(counts[n.toString()])))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.length;
    final shown = entries.take(_kMaxDisplayedNames).toList();
    final hidden = total - shown.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.callerInfoHowOthers,
              style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
              hidden > 0
                  ? l.callerInfoTopOf(_kMaxDisplayedNames, total)
                  : l.callerInfoNamesAcross(total),
              style: GoogleFonts.inter(
                  fontSize: 11.5, color: AppColors.textSecondaryLight)),
          const SizedBox(height: 12),
          ...shown.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Container(
                      width: 6, height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.primary, shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(e.key,
                          style: GoogleFonts.inter(
                              fontSize: 13.5, fontWeight: FontWeight.w600)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.tint,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        l.callerInfoPeopleCount(e.value),
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          if (hidden > 0) ...[
            const SizedBox(height: 4),
            Text(l.callerInfoHiddenMore(hidden),
                style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textSecondaryLight)),
          ],
        ],
      ),
    );
  }
}

String _relTime(AppLocalizations l, DateTime t) {
  final d = t.difference(DateTime.now());
  if (d.isNegative) return l.searchRelMoment;
  if (d.inMinutes < 60) return l.searchRelMinutes(d.inMinutes);
  if (d.inHours < 24) {
    final mins = d.inMinutes - d.inHours * 60;
    return l.searchRelHoursMinutes(d.inHours, mins);
  }
  return l.searchRelDays(d.inDays);
}

/// Gradient "glass" hero that mirrors the native caller-ID overlay so the app
/// screen reads as a seamless continuation of it: blue→indigo (red for spam)
/// gradient, decorative orbs, a glow-ring glass avatar, name, number, and a
/// frosted status chip.
class _CallerHero extends StatelessWidget {
  final String? name;
  final String phone;
  final bool isSpam;
  final bool isRegistered;
  final String? registeredName;
  final int seenBy;
  final int spamReports;
  final String? initials;
  const _CallerHero({
    required this.name,
    required this.phone,
    required this.isSpam,
    required this.isRegistered,
    required this.registeredName,
    required this.seenBy,
    required this.spamReports,
    required this.initials,
  });

  static Widget _orb(double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [
            Colors.white.withValues(alpha: 0.18),
            Colors.white.withValues(alpha: 0.0),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final topPad = MediaQuery.of(context).padding.top;
    final colors = isSpam
        ? const [Color(0xFFF15B60), Color(0xFF8F1A22)]
        : const [Color(0xFF2E7CF6), Color(0xFF123A8F)];
    final statusLabel = isSpam
        ? l.callerInfoSpamFlag(spamReports)
        : (isRegistered
            ? l.callerInfoRegistered
            : (seenBy > 0 ? l.callerInfoIdentified : l.callerInfoNotInDir));
    final statusIcon = isSpam
        ? Icons.report_rounded
        : (isRegistered
            ? Icons.verified_user_rounded
            : (seenBy > 0
                ? Icons.verified_rounded
                : Icons.help_outline_rounded));

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: topPad, bottom: 26),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius:
            const BorderRadius.vertical(bottom: Radius.circular(34)),
        boxShadow: [
          BoxShadow(
            color: colors.last.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius:
            const BorderRadius.vertical(bottom: Radius.circular(34)),
        child: Stack(
          children: [
            Positioned(top: -50, right: -40, child: _orb(150)),
            Positioned(bottom: -30, left: -30, child: _orb(120)),
            Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 20),
                    ),
                    Expanded(
                      child: Text(
                        l.callerInfoTitle,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  width: 124,
                  height: 124,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                        width: 1),
                  ),
                  child: Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.28),
                          Colors.white.withValues(alpha: 0.12),
                        ],
                      ),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                          width: 2),
                    ),
                    child: Center(
                      child: initials == null
                          ? const Icon(Icons.person_rounded,
                              color: Colors.white, size: 52)
                          : Text(
                              initials!,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 38,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ),
                )
                    .animate()
                    .scale(
                      begin: const Offset(0.7, 0.7),
                      end: const Offset(1, 1),
                      duration: 320.ms,
                      curve: Curves.easeOutBack,
                    )
                    .fadeIn(),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    name ?? l.unknown,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (isRegistered && registeredName != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    l.callerInfoVerifiedUser,
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  phone,
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: Colors.white, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        statusLabel,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Maximum names to render in "Also saved as" / "How others saved this number".
/// The full list is still on the backend; we just cap the UI for readability
/// and privacy.
const int _kMaxDisplayedNames = 3;

class _AlsoKnownAs extends StatelessWidget {
  final List<dynamic> names;
  final Map<String, dynamic> counts;
  const _AlsoKnownAs({required this.names, required this.counts});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    // Show the most popular names first, capped to _kMaxDisplayedNames.
    final ranked = names.map((n) => n.toString()).toList()
      ..sort((a, b) => _asInt(counts[b]).compareTo(_asInt(counts[a])));
    final shown = ranked.take(_kMaxDisplayedNames).toList();
    final hidden = ranked.length - shown.length;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.tint,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.callerInfoAlsoSavedAs,
              style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6, runSpacing: 6,
            children: [
              ...shown.map((name) {
                final c = counts[name];
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.bgLight,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(name,
                        style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryDark)),
                    if (c != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text('$c',
                            style: GoogleFonts.inter(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ]),
                );
              }),
              if (hidden > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(l.callerInfoMoreNotShown(hidden),
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _InfoCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: context.sp(14),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String k;
  final String v;
  const _InfoRow(this.k, this.v);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              k,
              style: GoogleFonts.inter(
                fontSize: context.sp(13.5),
                color: AppColors.textSecondaryLight,
              ),
            ),
          ),
          Text(
            v,
            style: GoogleFonts.inter(
              fontSize: context.sp(13.5),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
