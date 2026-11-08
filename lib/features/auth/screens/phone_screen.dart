import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/error_banner.dart';
import '../../../shared/widgets/primary_button.dart';
import '../state/auth_controller.dart';
import '../state/auth_state.dart';

class PhoneScreen extends ConsumerStatefulWidget {
  const PhoneScreen({super.key});

  @override
  ConsumerState<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends ConsumerState<PhoneScreen> {
  final _formKey = GlobalKey<FormState>();
  String _phone = '';
  String _country = 'IQ';
  String _dial = '964';
  String? _error;

  Future<void> _continue() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) {
      setState(() => _error = AppLocalizations.of(context).phoneInvalid);
      return;
    }
    final full = '+$_dial$_phone';
    final ok = await ref
        .read(authControllerProvider.notifier)
        .sendOtp(phoneE164: full, countryCode: _country);
    if (!mounted) return;
    if (ok) {
      context.push('/auth/otp');
    } else {
      final l = AppLocalizations.of(context);
      setState(() {
        _error = ref.read(authControllerProvider).error ?? l.failed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
        child: ResponsiveBox(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: context.pagePadding),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: context.hp(1)),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: const Icon(Icons.phone_iphone_rounded,
                            color: AppColors.primary, size: 52)
                        .animate()
                        .scale(
                          begin: const Offset(0.7, 0.7),
                          end: const Offset(1, 1),
                          duration: 450.ms,
                          curve: Curves.easeOutBack,
                        ),
                  ),
                  SizedBox(height: context.hp(2.5)),
                  Text(
                    l.phoneTitle,
                    style: GoogleFonts.poppins(
                      fontSize: context.sp(24),
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ).animate().fadeIn(duration: 320.ms).slideY(begin: 0.12, end: 0),
                  SizedBox(height: context.hp(1)),
                  Text(
                    l.phoneSubtitle,
                    style: GoogleFonts.inter(
                      fontSize: context.sp(14),
                      color: AppColors.textSecondaryLight,
                      height: 1.5,
                    ),
                  ).animate(delay: 60.ms).fadeIn(duration: 320.ms),
                  SizedBox(height: context.hp(3.5)),
                  Text(
                    l.phoneFieldLabel,
                    style: GoogleFonts.inter(
                      fontSize: context.sp(13),
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondaryLight,
                      letterSpacing: 0.2,
                    ),
                  ),
                  SizedBox(height: context.hp(1)),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _error != null
                            ? AppColors.danger
                            : AppColors.primary.withValues(alpha: 0.35),
                        width: _error != null ? 1.5 : 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_error != null
                                  ? AppColors.danger
                                  : AppColors.primary)
                              .withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: IntlPhoneField(
                      initialCountryCode: 'IQ',
                      showCountryFlag: true,
                      flagsButtonPadding:
                          const EdgeInsets.only(left: 12, right: 4),
                      dropdownIcon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textSecondaryLight,
                      ),
                      dropdownTextStyle: GoogleFonts.inter(
                        fontSize: context.sp(16),
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: l.phoneFieldHint,
                        hintStyle: GoogleFonts.inter(
                          fontSize: context.sp(15),
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondaryLight
                              .withValues(alpha: 0.6),
                        ),
                        isDense: true,
                        // IntlPhoneField sets maxLength internally, which makes
                        // Flutter reserve a character-counter line under the
                        // field. Hide it (and collapse the error-text line — we
                        // surface errors in the banner below) so the input stays
                        // a tight, single-line height.
                        counterText: '',
                        errorStyle: const TextStyle(
                            height: 0, fontSize: 0, color: Colors.transparent),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 4),
                      ),
                      style: GoogleFonts.inter(
                        fontSize: context.sp(16),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                      onChanged: (p) {
                        if (_error != null) setState(() => _error = null);
                        // Drop a national trunk "0" so we never build a number
                        // like +9640770… — E.164 has no leading trunk zero.
                        _phone = p.number.replaceFirst(RegExp(r'^0+'), '');
                        _dial = p.countryCode.replaceAll('+', '');
                        _country = p.countryISOCode;
                      },
                      invalidNumberMessage: l.phoneInvalid,
                    ),
                  ).animate(delay: 120.ms).fadeIn(duration: 320.ms),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    ErrorBanner(_error),
                  ],
                  SizedBox(height: context.hp(3)),
                  _ChannelSelector(
                    value: auth.channel,
                    onChanged: (c) =>
                        ref.read(authControllerProvider.notifier).setChannel(c),
                  ),
                  SizedBox(height: context.hp(4)),
                  PrimaryButton(
                    label: l.sendCode,
                    loading: auth.loading,
                    icon: Icons.arrow_forward_rounded,
                    onPressed: _continue,
                  ),
                  SizedBox(height: context.hp(2)),
                  Center(
                    child: Text(
                      l.termsAndPrivacyAgree,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: context.sp(11.5),
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                  SizedBox(height: context.hp(2)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChannelSelector extends StatelessWidget {
  final OtpChannel value;
  final ValueChanged<OtpChannel> onChanged;

  const _ChannelSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: _ChannelTile(
            icon: Icons.sms_rounded,
            label: l.channelSms,
            color: AppColors.primary,
            selected: value == OtpChannel.sms,
            onTap: () => onChanged(OtpChannel.sms),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ChannelTile(
            icon: Icons.chat_rounded,
            label: l.channelWhatsapp,
            color: const Color(0xFF25D366),
            selected: value == OtpChannel.whatsapp,
            onTap: () => onChanged(OtpChannel.whatsapp),
          ),
        ),
      ],
    );
  }
}

class _ChannelTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _ChannelTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.1) : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: context.sp(14),
                fontWeight: FontWeight.w600,
                color: selected ? color : AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
