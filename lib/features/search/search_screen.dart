import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/responsive.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/widgets/primary_button.dart';
import '../ads/rewarded_ad_service.dart';
import '../auth/state/auth_controller.dart';
import '../contacts/quota_provider.dart';

enum _SearchMode { number, name }

/// Coerces a JSON value (number, numeric string, null) into an int. The
/// backend used to return SUM() as a DECIMAL string, which would crash an
/// `as num` cast and white-screen the page.
int _asInt(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toInt();
  if (v is String) {
    final n = num.tryParse(v);
    return n?.toInt() ?? 0;
  }
  return 0;
}

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  _SearchMode _mode = _SearchMode.number;
  String _dial = '1'; // Country dialing code without the leading +
  String _isoCountry = 'US';
  bool _searching = false;
  List<Map<String, dynamic>> _userMatches = const [];
  List<Map<String, dynamic>> _directoryMatches = const [];
  String? _error;
  Map<String, dynamic>? _nameQuotaBlocked; // non-null when /search returned 429
  bool _adInProgress = false;

  @override
  void dispose() {
    _ctrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _go() async {
    if (_mode == _SearchMode.number) {
      final digits = _phoneCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
      if (digits.length < 4) {
        setState(() => _error = AppLocalizations.of(context).searchEnterNumber);
        return;
      }
      final full = '+$_dial$digits';
      context.push('/search/result?q=${Uri.encodeComponent(full)}');
      return;
    }
    final q = _ctrl.text.trim();
    if (q.length < 2) return;
    setState(() {
      _searching = true;
      _error = null;
      _userMatches = const [];
      _directoryMatches = const [];
      _nameQuotaBlocked = null;
    });
    try {
      final repo = ref.read(contactsRepositoryProvider);
      final res = await repo.searchByName(q);
      if (!res.ok) {
        ref.read(searchQuotaProvider.notifier).updateFromMap(res.quota);
        setState(() {
          _nameQuotaBlocked = res.quota ?? const {};
          _searching = false;
        });
        return;
      }
      ref.read(searchQuotaProvider.notifier).updateFromMap(res.quota);
      final data = res.data ?? const {};
      final users = (data['users'] as List?)?.cast<dynamic>() ?? const [];
      final dir = (data['results'] as List?)?.cast<dynamic>() ?? const [];
      setState(() {
        _userMatches = users.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        _directoryMatches =
            dir.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        _searching = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _searching = false;
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
            content: Text(l.searchAdAdded),
          ));
          _go();
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

  void _openResult(String phone) {
    context.push('/search/result?q=${Uri.encodeComponent(phone)}');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.searchTitle)),
      body: SafeArea(
        child: ResponsiveBox(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: context.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: context.hp(2)),
                _ModeToggle(
                  value: _mode,
                  onChanged: (m) => setState(() {
                    _mode = m;
                    _error = null;
                    _nameQuotaBlocked = null;
                  }),
                ),
                SizedBox(height: context.hp(2)),
                if (_mode == _SearchMode.number)
                  IntlPhoneField(
                    controller: _phoneCtrl,
                    autofocus: true,
                    initialCountryCode: _isoCountry,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      labelText: l.searchPhoneField,
                    ),
                    style: GoogleFonts.inter(fontSize: context.sp(15)),
                    dropdownTextStyle:
                        GoogleFonts.inter(fontSize: context.sp(15)),
                    onChanged: (p) {
                      _dial = p.countryCode.replaceAll('+', '');
                      _isoCountry = p.countryISOCode;
                    },
                    onSubmitted: (_) => _go(),
                    invalidNumberMessage: l.searchInvalidPhone,
                  )
                else
                  TextField(
                    controller: _ctrl,
                    autofocus: true,
                    onSubmitted: (_) => _go(),
                    decoration: InputDecoration(
                      hintText: l.searchTypeName,
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _ctrl.text.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _ctrl.clear();
                                setState(() {
                                  _userMatches = const [];
                                  _error = null;
                                });
                              },
                            ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                SizedBox(height: context.hp(2)),
                PrimaryButton(
                  label: l.search,
                  icon: Icons.search_rounded,
                  loading: _searching,
                  onPressed: _go,
                ),
                SizedBox(height: context.hp(2)),
                if (_error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                    ),
                    child: Text(_error!,
                        style: GoogleFonts.inter(color: AppColors.danger, fontSize: 12)),
                  ),
                Expanded(
                  child: _nameQuotaBlocked != null
                      ? _QuotaBlockedView(
                          quota: _nameQuotaBlocked!,
                          adInProgress: _adInProgress,
                          onWatchAd: _watchAdForReward,
                        )
                      : (_userMatches.isEmpty && _directoryMatches.isEmpty)
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _mode == _SearchMode.number
                                    ? Icons.phone_rounded
                                    : Icons.person_search_rounded,
                                size: 40,
                                color: AppColors.textSecondaryLight,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _mode == _SearchMode.number
                                    ? l.searchEmptyNumberHint
                                    : (_searching
                                        ? ' '
                                        : l.searchEmptyNameHint),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                    color: AppColors.textSecondaryLight,
                                    fontSize: context.sp(13)),
                              ),
                            ],
                          ),
                        )
                      : ListView(
                          children: [
                            if (_userMatches.isNotEmpty) ...[
                              _SectionHeader(
                                  label: l.searchRegisteredUsers(
                                      _userMatches.length),
                                  color: AppColors.primary),
                              const SizedBox(height: 8),
                              ..._userMatches.map((u) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: _UserMatchTile(
                                      name: (u['registered_name'] as String?) ??
                                          l.searchUnnamedUser,
                                      phone:
                                          (u['phone_e164'] as String?) ?? '',
                                      onTap: () => _openResult(
                                          (u['phone_e164'] as String?) ?? ''),
                                    ),
                                  )),
                              const SizedBox(height: 12),
                            ],
                            if (_directoryMatches.isNotEmpty) ...[
                              _SectionHeader(
                                  label: l.searchEveryonesContacts(
                                      _directoryMatches.length),
                                  color: AppColors.textSecondaryLight),
                              const SizedBox(height: 8),
                              ..._directoryMatches.map((d) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: _DirectoryMatchTile(
                                      topName: (d['top_name'] as String?) ??
                                          l.searchUnknown,
                                      phone:
                                          (d['phone_e164'] as String?) ?? '',
                                      uploads: _asInt(d['uploads']),
                                      onTap: () => _openResult(
                                          (d['phone_e164'] as String?) ?? ''),
                                    ),
                                  )),
                            ],
                            const SizedBox(height: 24),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UserMatchTile extends StatelessWidget {
  final String name;
  final String phone;
  final VoidCallback onTap;
  const _UserMatchTile({required this.name, required this.phone, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final initials = _initials(name);
    return InkWell(
      onTap: onTap,
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
                color: AppColors.tint,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(initials,
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Flexible(
                      child: Text(name,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700, fontSize: 14.5)),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.verified_rounded,
                        color: AppColors.primary, size: 16),
                  ]),
                  const SizedBox(height: 2),
                  _HiddenPhone(phone: phone),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondaryLight),
          ],
        ),
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first).toUpperCase();
  }
}

/// Hides the phone number until the user taps "Show number". Until then only
/// a small pill button is rendered in place of the number. The button's tap
/// is swallowed so the parent tile's onTap (navigate to caller info) does
/// not also fire when the user just wants to peek at the number.
class _HiddenPhone extends StatefulWidget {
  final String phone;
  const _HiddenPhone({required this.phone});

  @override
  State<_HiddenPhone> createState() => _HiddenPhoneState();
}

class _HiddenPhoneState extends State<_HiddenPhone> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (_revealed) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: Text(
          widget.phone,
          style: GoogleFonts.inter(
            fontSize: 12.5,
            color: AppColors.textSecondaryLight,
          ),
        ),
      );
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () => setState(() => _revealed = true),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.tint,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.visibility_outlined,
                size: 13,
                color: AppColors.primary,
              ),
              const SizedBox(width: 5),
              Text(
                l.searchShowNumber,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final Color color;
  const _SectionHeader({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _DirectoryMatchTile extends StatelessWidget {
  final String topName;
  final String phone;
  final int uploads;
  final VoidCallback onTap;
  const _DirectoryMatchTile({
    required this.topName,
    required this.phone,
    required this.uploads,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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
                color: AppColors.textSecondaryLight.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.person_outline_rounded,
                  color: AppColors.textSecondaryLight),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(topName,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700, fontSize: 14.5)),
                  const SizedBox(height: 2),
                  _HiddenPhone(phone: phone),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.tint,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                AppLocalizations.of(context).searchUploads(uploads),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondaryLight),
          ],
        ),
      ),
    );
  }
}

class _QuotaBlockedView extends StatelessWidget {
  final Map<String, dynamic> quota;
  final bool adInProgress;
  final VoidCallback onWatchAd;
  const _QuotaBlockedView({
    required this.quota,
    required this.adInProgress,
    required this.onWatchAd,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final canWatchAd = quota['can_watch_ad'] == true;
    final reset = quota['resets_at'] is String
        ? DateTime.tryParse(quota['resets_at'] as String)?.toLocal()
        : null;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
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
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              l.searchQuotaBody(
                '${quota['used'] ?? '?'}',
                '${quota['limit'] ?? 20}',
              ),
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: AppColors.textSecondaryLight),
            ),
            if (reset != null) ...[
              const SizedBox(height: 6),
              Text(
                l.searchQuotaReset(_relTimeShort(l, reset)),
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
                  onPressed: adInProgress ? null : onWatchAd,
                  icon: adInProgress
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
    );
  }

  static String _relTimeShort(AppLocalizations l, DateTime t) {
    final d = t.difference(DateTime.now());
    if (d.isNegative) return l.searchRelMoment;
    if (d.inMinutes < 60) return l.searchRelMinutes(d.inMinutes);
    if (d.inHours < 24) {
      final mins = d.inMinutes - d.inHours * 60;
      return l.searchRelHoursMinutes(d.inHours, mins);
    }
    return l.searchRelDays(d.inDays);
  }
}

class _ModeToggle extends StatelessWidget {
  final _SearchMode value;
  final ValueChanged<_SearchMode> onChanged;
  const _ModeToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModeChip(
              icon: Icons.phone_rounded,
              label: l.searchModeNumber,
              selected: value == _SearchMode.number,
              onTap: () => onChanged(_SearchMode.number),
            ),
          ),
          Expanded(
            child: _ModeChip(
              icon: Icons.person_search_rounded,
              label: l.searchModeName,
              selected: value == _SearchMode.name,
              onTap: () => onChanged(_SearchMode.name),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ModeChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 16,
                color: selected ? Colors.white : AppColors.textSecondaryLight),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color:
                    selected ? Colors.white : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
