import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// A password TextFormField with a show/hide toggle (eye icon), so users can
/// check what they actually typed before submitting.
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    required this.labelText,
    this.enabled = true,
    this.autofillHints,
    this.helperText,
    this.validator,
  });

  final TextEditingController controller;
  final String labelText;
  final bool enabled;
  final List<String>? autofillHints;
  final String? helperText;
  final String? Function(String?)? validator;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      enabled: widget.enabled,
      obscureText: _obscure,
      autofillHints: widget.autofillHints,
      decoration: InputDecoration(
        labelText: widget.labelText,
        helperText: widget.helperText,
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
          tooltip: _obscure ? 'auth.showPassword'.tr() : 'auth.hidePassword'.tr(),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
      validator: widget.validator,
    );
  }
}
