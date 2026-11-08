import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/responsive.dart';

/// A soft red inline error card. Use it to surface a failure message clearly
/// (red, with an icon) instead of a transient snackbar. Renders nothing when
/// [message] is null/empty so it can be dropped straight into a Column.
class ErrorBanner extends StatelessWidget {
  final String? message;

  const ErrorBanner(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    final msg = message;
    if (msg == null || msg.trim().isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.danger, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              msg,
              style: GoogleFonts.inter(
                fontSize: context.sp(13),
                height: 1.4,
                fontWeight: FontWeight.w600,
                color: AppColors.danger,
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 260.ms)
        .slideY(begin: -0.15, end: 0, duration: 260.ms, curve: Curves.easeOut);
  }
}
