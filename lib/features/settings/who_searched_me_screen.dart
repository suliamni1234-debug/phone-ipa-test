import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/responsive.dart';
import '../../l10n/generated/app_localizations.dart';

class WhoSearchedMeScreen extends ConsumerWidget {
  const WhoSearchedMeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    // Demo data — replace with real API once the backend endpoint is ready.
    final searches = <_SearchEntry>[
      _SearchEntry(name: 'John Smith', when: 'Today, 14:32', city: 'New York'),
      _SearchEntry(name: l.unknown, when: 'Today, 09:15', city: 'Cairo'),
      _SearchEntry(
          name: 'Ahmed Ali', when: 'Yesterday, 21:04', city: 'Riyadh'),
      _SearchEntry(
          name: l.unknown, when: '2 days ago', city: 'Dubai'),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l.whoSearchedMeTitle)),
      body: SafeArea(
        child: ResponsiveBox(
          child: ListView(
            padding: EdgeInsets.symmetric(
                horizontal: context.pagePadding, vertical: context.hp(2)),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.tint,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.visibility_outlined,
                          color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.whoSearchedMePeopleCount(searches.length),
                            style: GoogleFonts.poppins(
                                fontSize: 14.5, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l.whoSearchedMeLast7Days,
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.textSecondaryLight),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: context.hp(2)),
              Text(
                l.whoSearchedMeRecentSearches,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < searches.length; i++) ...[
                      _SearchTile(entry: searches[i]),
                      if (i != searches.length - 1)
                        const Divider(height: 1, indent: 64, endIndent: 14),
                    ],
                  ],
                ),
              ),
              SizedBox(height: context.hp(3)),
              FilledButton.icon(
                onPressed: () => context.push('/premium'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.workspace_premium_rounded),
                label: Text(l.premiumUnlockHistory),
              ),
              SizedBox(height: context.hp(2)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchEntry {
  final String name;
  final String when;
  final String city;
  _SearchEntry({required this.name, required this.when, required this.city});
}

class _SearchTile extends StatelessWidget {
  final _SearchEntry entry;
  const _SearchTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final initial = entry.name.isNotEmpty
        ? entry.name.characters.first.toUpperCase()
        : '?';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            child: Text(
              initial,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: GoogleFonts.inter(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.when} · ${entry.city}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded,
              size: 14, color: AppColors.textSecondaryLight),
        ],
      ),
    );
  }
}
