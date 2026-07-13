import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/state_views.dart';
import '../pharmacists/widgets/crypto_proof_card.dart';
import '../pharmacists/widgets/license_status_badge.dart';
import 'verify_models.dart';
import 'verify_providers.dart';

class VerifyResultScreen extends ConsumerWidget {
  const VerifyResultScreen({super.key, required this.code});

  final String code;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(verifyResultProvider(code));

    return Scaffold(
      appBar: AppBar(title: Text('verify.title'.tr())),
      body: AsyncValueView(
        value: result,
        onRetry: () => ref.invalidate(verifyResultProvider(code)),
        data: (value) => _ResultBody(result: value),
      ),
    );
  }
}

class _ResultBody extends StatelessWidget {
  const _ResultBody({required this.result});

  final VerifyResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return switch (result) {
      VerifyPharmacistResult(:final valid, :final pharmacist, :final proof) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _StatusBanner(valid: valid),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                    backgroundImage: pharmacist.photoUrl != null ? NetworkImage(pharmacist.photoUrl!) : null,
                    child: pharmacist.photoUrl == null
                        ? Icon(Icons.person_rounded, color: theme.colorScheme.primary)
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(pharmacist.fullName, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                        Text(pharmacist.licenseNumber, style: theme.textTheme.bodySmall),
                        const SizedBox(height: 4),
                        LicenseStatusBadge(status: pharmacist.licenseStatus),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => context.push('/pharmacists/${pharmacist.id}'),
            child: Text('pharmacist.detailTitle'.tr()),
          ),
          const SizedBox(height: 16),
          CryptoProofCard(
            proof: proof,
            verificationHash: pharmacist.verificationHash,
            signature: pharmacist.qrCodeSignature,
          ),
        ],
      ),
      VerifyDocumentResult(:final valid, :final title, :final proof) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _StatusBanner(valid: valid),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.description_outlined),
              title: Text(title),
            ),
          ),
          const SizedBox(height: 16),
          CryptoProofCard(proof: proof, overallValid: valid),
        ],
      ),
      VerifyNotFound(:final message) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off_rounded, size: 48, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
              const SizedBox(height: 12),
              Text(
                message.isNotEmpty ? message : 'verify.resultNotFound'.tr(),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    };
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.valid});

  final bool valid;

  @override
  Widget build(BuildContext context) {
    final color = valid ? const Color(0xFF1A7F37) : Theme.of(context).colorScheme.error;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Icon(valid ? Icons.verified_rounded : Icons.gpp_bad_rounded, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              valid ? 'verify.resultValid'.tr() : 'verify.resultCompromised'.tr(),
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
