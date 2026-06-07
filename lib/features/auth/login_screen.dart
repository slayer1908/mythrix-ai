import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/snack.dart';
import '../../core/widgets/mythrix_logo.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_button.dart';
import 'widgets/auth_layout.dart';
import 'widgets/oauth_buttons.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController(text: 'demo@mythrix.ai');
  final _passCtrl = TextEditingController(text: 'password123');
  bool _loading = false;
  String? _error;
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await AuthService.instance.signInWithEmail(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      if (!mounted) return;
      context.go(AppRoutes.dashboard);
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Something went wrong. Try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _oauth(SocialProvider p) async {
    setState(() => _loading = true);
    await AuthService.instance.signInWithProvider(p);
    if (mounted) context.go(AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: AuthLayout(
        child: GlassCard(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Form(
            key: _form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: MythrixLogo(size: 36)),
                AppSpacing.vGapXl,
                Text('Welcome back', style: theme.textTheme.headlineMedium),
                AppSpacing.vGapXs,
                Text(
                  'Sign in to your MYTHRIX workspace.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
                AppSpacing.vGapXl,

                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(
                    labelText: 'Work email',
                    prefixIcon: Icon(Icons.mail_outline_rounded),
                  ),
                  validator: (v) =>
                      v == null || !v.contains('@') ? 'Enter a valid email' : null,
                ),
                AppSpacing.vGapMd,
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  autofillHints: const [AutofillHints.password],
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.length < 6 ? 'Min 6 characters' : null,
                  onFieldSubmitted: (_) => _submit(),
                ),
                AppSpacing.vGapSm,
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Snack.info(context, 'Password reset arrives with Firebase Auth in Phase 1. Use the demo credentials shown.'),
                    child: const Text('Forgot password?'),
                  ),
                ),
                if (_error != null) ...[
                  AppSpacing.vGapXs,
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.danger, size: 18),
                        AppSpacing.hGapSm,
                        Expanded(
                          child: Text(
                            _error!,
                            style: const TextStyle(color: AppColors.danger),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                AppSpacing.vGapLg,
                GradientButton(
                  label: 'Sign in',
                  expand: true,
                  loading: _loading,
                  onPressed: _loading ? null : _submit,
                ),
                AppSpacing.vGapLg,
                Row(
                  children: [
                    Expanded(child: Container(height: 1, color: Colors.white10)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: Text('OR',
                          style: theme.textTheme.labelSmall?.copyWith(color: Colors.white54)),
                    ),
                    Expanded(child: Container(height: 1, color: Colors.white10)),
                  ],
                ),
                AppSpacing.vGapLg,
                OAuthButtons(
                  onProvider: _loading ? null : _oauth,
                ),
                AppSpacing.vGapLg,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("New to MYTHRIX?",
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.signup),
                      child: const Text('Create an account'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
