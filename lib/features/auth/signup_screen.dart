import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/mythrix_logo.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_button.dart';
import 'widgets/auth_layout.dart';
import 'widgets/oauth_buttons.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _workspace = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _workspace.dispose();
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await AuthService.instance.signUp(
        email: _email.text.trim(),
        password: _pass.text,
        fullName: _name.text.trim(),
        workspaceName: _workspace.text.trim(),
      );
      if (mounted) context.go(AppRoutes.dashboard);
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
                Text('Create your MYTHRIX workspace',
                    style: theme.textTheme.headlineMedium),
                AppSpacing.vGapXs,
                Text(
                  'Free 14-day trial. No card required.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
                AppSpacing.vGapXl,
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _name,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Your name',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                    AppSpacing.hGapMd,
                    Expanded(
                      child: TextFormField(
                        controller: _workspace,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Workspace',
                          prefixIcon: Icon(Icons.workspaces_outline),
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                AppSpacing.vGapMd,
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Work email',
                    prefixIcon: Icon(Icons.mail_outline_rounded),
                  ),
                  validator: (v) => v == null || !v.contains('@')
                      ? 'Enter a valid email'
                      : null,
                ),
                AppSpacing.vGapMd,
                TextFormField(
                  controller: _pass,
                  obscureText: _obscure,
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
                      v == null || v.length < 8 ? 'Min 8 characters' : null,
                ),
                if (_error != null) ...[
                  AppSpacing.vGapMd,
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
                    ),
                    child: Text(_error!, style: const TextStyle(color: AppColors.danger)),
                  ),
                ],
                AppSpacing.vGapLg,
                GradientButton(
                  label: 'Create workspace',
                  expand: true,
                  loading: _loading,
                  onPressed: _loading ? null : _submit,
                ),
                AppSpacing.vGapLg,
                OAuthButtons(onProvider: (p) async {
                  await AuthService.instance.signInWithProvider(p);
                  if (mounted) context.go(AppRoutes.dashboard);
                }),
                AppSpacing.vGapLg,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account?',
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.login),
                      child: const Text('Sign in'),
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
