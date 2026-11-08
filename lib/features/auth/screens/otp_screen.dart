import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/error_banner.dart';
import '../../../shared/widgets/primary_button.dart';
import '../state/auth_controller.dart';
import '../state/auth_state.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _ctrl = TextEditingController();
  Timer? _timer;
  int _seconds = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _seconds = AppConstants.otpResendCooldown.inSeconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_seconds <= 0) {
        _timer?.cancel();
      } else {
        setState(() => _seconds--);
      }
    });
  }

  Future<void> _verify(String code) async {
    setState(() => _error = null);
    final ok = await ref.read(authControllerProvider.notifier).verifyOtp(code);
    if (!mounted) return;
    if (ok) {
      // Send the user to the blocking sync gate. They cannot continue to the
      // rest of the app until contacts are uploaded successfully.
      context.go('/auth/sync');
    } else {
      final l = AppLocalizations.of(context);
      setState(() {
        _error = ref.read(authControllerProvider).error ?? l.otpWrongCode;
      });
      _ctrl.clear();
    }
  }

  Future<void> _resend() async {
    final auth = ref.read(authControllerProvider);
    if (auth.phoneE164 == null) return;
    await ref.read(authControllerProvider.notifier).sendOtp(
          phoneE164: auth.phoneE164!,
          countryCode: auth.countryCode ?? '',
        );
    _startCountdown();
    if (mounted) {
      final l = AppLocalizations.of(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.otpCodeSentAgain)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final l = AppLocalizations.of(context);
    final channelLabel = auth.channel == OtpChannel.whatsapp
        ? l.channelWhatsapp
        : l.channelSms;

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
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.30),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.lock_outline_rounded,
                      color: Colors.white, size: 30),
                ),
                SizedBox(height: context.hp(2.5)),
                Text(
                  l.otpTitle,
                  style: GoogleFonts.poppins(
                    fontSize: context.sp(24),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: context.hp(1)),
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(
                      fontSize: context.sp(14),
                      color: AppColors.textSecondaryLight,
                      height: 1.5,
                    ),
                    children: [
                      TextSpan(text: l.otpSentVia(channelLabel)),
                      TextSpan(
                        text: auth.phoneE164 ?? '',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                if (auth.devOtpCode != null) ...[
                  SizedBox(height: context.hp(2)),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.tint,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.bug_report_outlined,
                            color: AppColors.primary, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l.otpDevMode,
                                style: GoogleFonts.inter(
                                  fontSize: context.sp(11),
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                auth.devOtpCode!,
                                style: GoogleFonts.inter(
                                  fontSize: context.sp(20),
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryDark,
                                  letterSpacing: 4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            _ctrl.text = auth.devOtpCode!;
                            _verify(auth.devOtpCode!);
                          },
                          child: Text(l.otpUse),
                        ),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: context.hp(4)),
                PinCodeTextField(
                  appContext: context,
                  length: 6,
                  controller: _ctrl,
                  keyboardType: TextInputType.number,
                  animationType: AnimationType.fade,
                  textStyle: GoogleFonts.inter(
                    fontSize: context.sp(20),
                    fontWeight: FontWeight.w700,
                  ),
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(14),
                    fieldHeight: context.sp(56),
                    fieldWidth: context.sp(46),
                    borderWidth: 1.5,
                    activeColor:
                        _error != null ? AppColors.danger : AppColors.primary,
                    selectedColor: AppColors.primary,
                    inactiveColor:
                        _error != null ? AppColors.danger.withValues(alpha: 0.5) : AppColors.border,
                    errorBorderColor: AppColors.danger,
                    activeFillColor: AppColors.tint,
                    selectedFillColor: AppColors.tint,
                    inactiveFillColor: AppColors.surfaceLight,
                  ),
                  enableActiveFill: true,
                  onCompleted: _verify,
                  onChanged: (_) {
                    if (_error != null) setState(() => _error = null);
                  },
                ),
                if (_error != null) ...[
                  SizedBox(height: context.hp(1.5)),
                  ErrorBanner(_error),
                ],
                SizedBox(height: context.hp(2)),
                Center(
                  child: _seconds > 0
                      ? Text(
                          l.otpResendIn(_seconds),
                          style: GoogleFonts.inter(
                            fontSize: context.sp(13),
                            color: AppColors.textSecondaryLight,
                          ),
                        )
                      : TextButton(
                          onPressed: _resend,
                          child: Text(
                            l.otpResend,
                            style: GoogleFonts.inter(
                              fontSize: context.sp(14),
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                ),
                SizedBox(height: context.hp(3)),
                PrimaryButton(
                  label: l.otpVerify,
                  loading: auth.loading,
                  onPressed: () => _verify(_ctrl.text),
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
