import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/api/api_exception.dart';
import '../ocr/ocr_providers.dart';
import 'account_providers.dart';

/// Public candidacy submission form (no login required, mirrors the web
/// `/candidature` flow). Includes a "Scanner un document" shortcut that
/// calls the OCR endpoint to pre-fill the name fields from a photo of an
/// ID, diploma or professional card.
class CandidacySubmitScreen extends ConsumerStatefulWidget {
  const CandidacySubmitScreen({super.key});

  @override
  ConsumerState<CandidacySubmitScreen> createState() => _CandidacySubmitScreenState();
}

class _CandidacySubmitScreenState extends ConsumerState<CandidacySubmitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  String? _cvPath;
  String? _cvName;
  String? _motivationPath;
  String? _motivationName;

  bool _scanning = false;
  bool _submitting = false;
  bool _submitted = false;
  String? _scanMessage;
  String? _errorMessage;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _scanDocument() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(source: ImageSource.camera, maxWidth: 2000, imageQuality: 90);
    if (photo == null) return;

    setState(() {
      _scanning = true;
      _scanMessage = null;
    });

    try {
      final fields = await ref.read(ocrRepositoryProvider).extract(photo.path);
      if (fields.firstName != null) _firstNameController.text = fields.firstName!;
      if (fields.lastName != null) _lastNameController.text = fields.lastName!;

      setState(() {
        _scanMessage = (fields.firstName != null || fields.lastName != null)
            ? 'candidacy.scanSuccess'.tr()
            : 'candidacy.scanEmpty'.tr();
      });
    } on ApiException catch (error) {
      setState(() => _scanMessage = error.message);
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  Future<void> _pickCv() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'doc', 'docx']);
    final file = result?.files.single;
    if (file?.path == null) return;
    setState(() {
      _cvPath = file!.path;
      _cvName = file.name;
    });
  }

  Future<void> _pickMotivationLetter() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'doc', 'docx']);
    final file = result?.files.single;
    if (file?.path == null) return;
    setState(() {
      _motivationPath = file!.path;
      _motivationName = file.name;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_cvPath == null) {
      setState(() => _errorMessage = 'candidacy.cvRequired'.tr());
      return;
    }

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    try {
      await ref
          .read(candidacyRepositoryProvider)
          .submit(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            address: _addressController.text.trim(),
            notes: _notesController.text.trim(),
            cvPath: _cvPath!,
            motivationLetterPath: _motivationPath,
          );
      if (mounted) setState(() => _submitted = true);
    } on ApiException catch (error) {
      setState(() => _errorMessage = error.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_submitted) {
      return Scaffold(
        appBar: AppBar(title: Text('candidacy.title'.tr())),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_rounded, size: 48, color: theme.colorScheme.primary),
                const SizedBox(height: 12),
                Text('candidacy.submitSuccess'.tr(), textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('candidacy.title'.tr())),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'candidacy.subtitle'.tr(),
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: _scanning ? null : _scanDocument,
                  icon: _scanning
                      ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.document_scanner_outlined),
                  label: Text(_scanning ? 'common.loading'.tr() : 'candidacy.scanCta'.tr()),
                ),
                if (_scanMessage != null) ...[
                  const SizedBox(height: 6),
                  Text(_scanMessage!, style: theme.textTheme.bodySmall),
                ],
                const SizedBox(height: 20),
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(labelText: 'candidacy.firstName'.tr()),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'candidacy.firstName'.tr() : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(labelText: 'candidacy.lastName'.tr()),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'candidacy.lastName'.tr() : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: 'auth.email'.tr()),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'auth.email'.tr();
                    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim()) ? null : 'auth.email'.tr();
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(labelText: 'pharmacist.phone'.tr()),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(labelText: 'pharmacist.address'.tr()),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: InputDecoration(labelText: 'candidacy.notes'.tr()),
                ),
                const SizedBox(height: 20),
                _FilePickerTile(label: 'candidacy.cv'.tr(), fileName: _cvName, onPick: _pickCv),
                const SizedBox(height: 10),
                _FilePickerTile(
                  label: 'candidacy.motivationLetter'.tr(),
                  fileName: _motivationName,
                  onPick: _pickMotivationLetter,
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(_errorMessage!, style: TextStyle(color: theme.colorScheme.error)),
                ],
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text('candidacy.submit'.tr()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilePickerTile extends StatelessWidget {
  const _FilePickerTile({required this.label, required this.fileName, required this.onPick});

  final String label;
  final String? fileName;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OutlinedButton.icon(
      onPressed: onPick,
      icon: const Icon(Icons.attach_file_rounded),
      label: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          fileName ?? label,
          overflow: TextOverflow.ellipsis,
          style: fileName == null ? null : theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
