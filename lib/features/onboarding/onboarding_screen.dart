import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/responsive.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../main.dart';
import '../../shared/widgets/primary_button.dart';

class _Slide {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  const _Slide(this.icon, this.color, this.title, this.subtitle);
}

List<_Slide> _buildSlides(AppLocalizations l) => [
      _Slide(
        Icons.person_search_rounded,
        AppColors.primary,
        l.onboardingSlide1Title,
        l.onboardingSlide1Subtitle,
      ),
      _Slide(
        Icons.shield_rounded,
        AppColors.success,
        l.onboardingSlide2Title,
        l.onboardingSlide2Subtitle,
      ),
      _Slide(
        Icons.lock_rounded,
        AppColors.info,
        l.onboardingSlide3Title,
        l.onboardingSlide3Subtitle,
      ),
    ];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(localStorageProvider).setOnboardingDone(true);
    if (!mounted) return;
    context.go('/permissions');
  }

  void _next(int slideCount) {
    if (_index == slideCount - 1) {
      _finish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final slides = _buildSlides(l);
    final isLast = _index == slides.length - 1;
    final iconCircleSize = (context.wp(45)).clamp(140.0, 220.0);
    final iconSize = iconCircleSize * 0.5;

    return Scaffold(
      body: SafeArea(
        child: ResponsiveBox(
          child: Column(
            children: [
              Align(
                alignment: AlignmentDirectional.topEnd,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextButton(
                    onPressed: _finish,
                    child: Text(
                      l.onboardingSkip,
                      style: GoogleFonts.inter(
                        fontSize: context.sp(14),
                        color: AppColors.textSecondaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemCount: slides.length,
                  itemBuilder: (_, i) {
                    final s = slides[i];
                    return Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: context.pagePadding),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: iconCircleSize,
                            height: iconCircleSize,
                            decoration: BoxDecoration(
                              color: s.color.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(s.icon, size: iconSize, color: s.color),
                          ).animate().scale(
                                begin: const Offset(0.6, 0.6),
                                end: const Offset(1, 1),
                                duration: 500.ms,
                                curve: Curves.easeOutBack,
                              ),
                          SizedBox(height: context.hp(5)),
                          Text(
                            s.title,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: context.sp(26),
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 400.ms)
                              .slideY(begin: 0.2, end: 0),
                          SizedBox(height: context.hp(2)),
                          Text(
                            s.subtitle,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: context.sp(15),
                              height: 1.5,
                              color: AppColors.textSecondaryLight,
                            ),
                          ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  context.pagePadding,
                  0,
                  context.pagePadding,
                  context.hp(4),
                ),
                child: Column(
                  children: [
                    SmoothPageIndicator(
                      controller: _controller,
                      count: slides.length,
                      effect: ExpandingDotsEffect(
                        activeDotColor: AppColors.primary,
                        dotColor: AppColors.border,
                        dotHeight: 8,
                        dotWidth: 8,
                        expansionFactor: 4,
                      ),
                    ),
                    SizedBox(height: context.hp(3)),
                    PrimaryButton(
                      label: isLast ? l.onboardingGetStarted : l.next,
                      onPressed: () => _next(slides.length),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
