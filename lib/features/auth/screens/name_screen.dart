import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/storage/local_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/responsive.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../main.dart';
import '../../../shared/widgets/primary_button.dart';
import '../state/auth_controller.dart';

class NameScreen extends ConsumerStatefulWidget {
  const NameScreen({super.key});

  @override
  ConsumerState<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends ConsumerState<NameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    if (!_formKey.currentState!.validate()) return;
    final ok =
        await ref.read(authControllerProvider.notifier).saveName(_ctrl.text.trim());
    if (!mounted) return;
    if (ok) {
      final storage = ref.read(localStorageProvider);
      await storage.setLoggedIn(true);
      if (!mounted) return;
      if (!storage.protectionAsked) {
        context.go('/enable-protection');
      } else {
        context.go('/home');
      }
    } else {
      if (mounted) {
        final l = AppLocalizations.of(context);
        final err = ref.read(authControllerProvider).error ?? l.failed;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(err)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(authControllerProvider).loading;
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(),
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
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.tint,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.person_outline_rounded,
                        color: AppColors.primary, size: 30),
                  ),
                  SizedBox(height: context.hp(2.5)),
                  Text(
                    l.nameTitle,
                    style: GoogleFonts.poppins(
                      fontSize: context.sp(24),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: context.hp(1)),
                  Text(
                    l.nameSubtitle,
                    style: GoogleFonts.inter(
                      fontSize: context.sp(14),
                      color: AppColors.textSecondaryLight,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: context.hp(4)),
                  TextFormField(
                    controller: _ctrl,
                    textInputAction: TextInputAction.done,
                    textCapitalization: TextCapitalization.words,
                    onFieldSubmitted: (_) => _finish(),
                    decoration: InputDecoration(
                      labelText: l.nameFieldLabel,
                      prefixIcon: const Icon(Icons.person_rounded),
                    ),
                    validator: (v) {
                      final s = v?.trim() ?? '';
                      if (s.length < 2) return l.nameValidationShort;
                      if (s.length > 60) return l.nameValidationLong;
                      return null;
                    },
                  ),
                  SizedBox(height: context.hp(4)),
                  PrimaryButton(
                    label: l.finish,
                    loading: loading,
                    onPressed: _finish,
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
