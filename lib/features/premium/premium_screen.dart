import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/responsive.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/widgets/primary_button.dart';

class _Plan {
  final String name;
  final String price;
  final String period;
  final bool best;
  const _Plan(this.name, this.price, this.period, this.best);
}

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  int _selected = 1;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    final features = <String>[
      l.premiumFeatureIdentify,
      l.premiumFeatureUnlimited,
      l.premiumFeatureNoAds,
      l.premiumFeatureSpamFilter,
      l.premiumFeatureBadges,
      l.premiumFeaturePriority,
    ];

    final plans = <_Plan>[
      _Plan(l.premiumPlanMonthly, '\$4.99', l.premiumPeriodMonth, false),
      _Plan(l.premiumPlanYearly, '\$29.99', l.premiumPeriodYear, true),
      _Plan(l.premiumPlanLifetime, '\$79.99', l.premiumPeriodOneTime, false),
    ];

    return Scaffold(
      body: SafeArea(
        child: ResponsiveBox(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: context.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: context.hp(2)),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.40),
                        blurRadius: 32,
                        spreadRadius: 1,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.workspace_premium_rounded,
                              color: Colors.white, size: 30),
                          const SizedBox(width: 8),
                          Text(
                            l.premiumHeroTitle,
                            style: GoogleFonts.poppins(
                              fontSize: context.sp(18),
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l.premiumHeroSubtitle,
                        style: GoogleFonts.inter(
                          fontSize: context.sp(14),
                          color: Colors.white.withValues(alpha: 0.95),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
                SizedBox(height: context.hp(3)),
                ...features.map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.check_rounded,
                                color: AppColors.success, size: 16),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            f,
                            style: GoogleFonts.inter(
                              fontSize: context.sp(14),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )),
                SizedBox(height: context.hp(2)),
                Row(
                  children: List.generate(plans.length, (i) {
                    final p = plans[i];
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(
                            end: i < plans.length - 1 ? 8 : 0),
                        child: _PlanCard(
                          plan: p,
                          bestLabel: l.premiumBadgeBest,
                          selected: _selected == i,
                          onTap: () => setState(() => _selected = i),
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: context.hp(3)),
                PrimaryButton(
                  label: l.premiumUpgradeNow,
                  icon: Icons.bolt_rounded,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l.premiumNotWired)),
                    );
                  },
                ),
                SizedBox(height: context.hp(1.5)),
                Center(
                  child: Text(
                    l.premiumCancelAnytime,
                    style: GoogleFonts.inter(
                      fontSize: context.sp(11.5),
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ),
                SizedBox(height: context.hp(3)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final _Plan plan;
  final String bestLabel;
  final bool selected;
  final VoidCallback onTap;
  const _PlanCard({
    required this.plan,
    required this.bestLabel,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.tint : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Column(
          children: [
            if (plan.best)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  bestLabel,
                  style: GoogleFonts.inter(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            Text(
              plan.name,
              style: GoogleFonts.inter(
                fontSize: context.sp(12.5),
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              child: Text(
                plan.price,
                style: GoogleFonts.poppins(
                  fontSize: context.sp(18),
                  fontWeight: FontWeight.w800,
                  color: selected
                      ? AppColors.primary
                      : AppColors.textPrimaryLight,
                ),
              ),
            ),
            Text(
              plan.period,
              style: GoogleFonts.inter(
                fontSize: context.sp(11),
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
