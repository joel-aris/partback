import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_exception.dart';
import '../../core/widgets/password_field.dart';
import 'auth_controller.dart';
import 'auth_repository.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();

  bool _submitting = false;
  bool _awaitingOtp = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    try {
      final result = await ref
          .read(authControllerProvider.notifier)
          .login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            otp: _awaitingOtp ? _otpController.text.trim() : null,
          );

      if (!mounted) return;

      switch (result) {
        case LoginSuccess(:final requiresEmailVerification):
          if (requiresEmailVerification) {
            context.go('/verify-email');
          } else {
            context.go('/account');
          }
        case LoginRequires2fa(:final requiresSetup, :final message):
          setState(() {
            if (requiresSetup) {
              _errorMessage = message;
            } else {
              _awaitingOtp = true;
              _errorMessage = 'auth.otpRequired'.tr();
            }
          });
      }
    } on ApiException catch (error) {
      setState(() => _errorMessage = error.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('auth.loginTitle'.tr())),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'auth.loginSubtitle'.tr(),
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _emailController,
                      enabled: !_awaitingOtp,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: InputDecoration(labelText: 'auth.email'.tr()),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'auth.email'.tr();
                        final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim());
                        return valid ? null : 'auth.email'.tr();
                      },
                    ),
                    const SizedBox(height: 14),
                    PasswordField(
                      controller: _passwordController,
                      enabled: !_awaitingOtp,
                      autofillHints: const [AutofillHints.password],
                      labelText: 'auth.password'.tr(),
                      validator: (value) => (value == null || value.length < 8) ? 'auth.passwordHint'.tr() : null,
                    ),
                    if (_awaitingOtp) ...[
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        decoration: InputDecoration(labelText: 'auth.otpLabel'.tr()),
                        validator: (value) => (value == null || value.length != 6) ? 'auth.otpLabel'.tr() : null,
                      ),
                    ],
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(_errorMessage!, style: TextStyle(color: theme.colorScheme.error)),
                    ],
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(_awaitingOtp ? 'auth.otpButton'.tr() : 'auth.loginButton'.tr()),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('auth.noAccount'.tr()),
                        TextButton(
                          onPressed: () => context.push('/register'),
                          child: Text('auth.registerLink'.tr()),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
