import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../state/auth_controller.dart';

class GmailScreen extends ConsumerStatefulWidget {
  const GmailScreen({super.key});

  @override
  ConsumerState<GmailScreen> createState() => _GmailScreenState();
}

class _GmailScreenState extends ConsumerState<GmailScreen> {
  bool _busy = false;

  Future<void> _signInGoogle() async {
    setState(() => _busy = true);
    try {
      final google = GoogleSignIn(scopes: ['email']);
      final acc = await google.signIn();
      if (acc == null) {
        setState(() => _busy = false);
        return;
      }
      final auth = await acc.authentication;
      final ok = await ref
          .read(authControllerProvider.notifier)
          .linkGoogle(auth.idToken ?? '', acc.email);
      if (!mounted) return;
      if (ok) context.push('/auth/name');
    } catch (e) {
      if (mounted) {
        final l = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.gmailSignInFailed(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _skip() => context.push('/auth/name');

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ResponsiveBox(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: context.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: context.hp(1)),
                const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Icon(Icons.mail_outline_rounded,
                      color: AppColors.primary, size: 52),
                ),
                SizedBox(height: context.hp(2.5)),
                Text(
                  l.gmailTitle,
                  style: GoogleFonts.poppins(
                    fontSize: context.sp(24),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: context.hp(1)),
                Text(
                  l.gmailSubtitle,
                  style: GoogleFonts.inter(
                    fontSize: context.sp(14),
                    color: AppColors.textSecondaryLight,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: context.hp(5)),
                _GoogleButton(loading: _busy, onPressed: _signInGoogle),
                SizedBox(height: context.hp(2)),
                Center(
                  child: TextButton(
                    onPressed: _busy ? null : _skip,
                    child: Text(
                      l.gmailSkip,
                      style: GoogleFonts.inter(
                        fontSize: context.sp(14),
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: context.hp(2)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onPressed;
  const _GoogleButton({required this.loading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: loading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: loading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF4285F4),
                        Color(0xFFEA4335),
                        Color(0xFFFBBC05),
                        Color(0xFF34A853),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Center(
                    child: Text(
                      'G',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  AppLocalizations.of(context).gmailContinueWith,
                  style: GoogleFonts.inter(
                    fontSize: context.sp(15),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
    );
  }
}
