import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/state_views.dart';
import 'pharmacist_models.dart';
import 'pharmacist_providers.dart';
import 'widgets/crypto_proof_card.dart';
import 'widgets/license_status_badge.dart';

class PharmacistDetailScreen extends ConsumerWidget {
  const PharmacistDetailScreen({super.key, required this.pharmacistId});

  final String pharmacistId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(pharmacistDetailProvider(pharmacistId));

    return Scaffold(
      appBar: AppBar(title: Text('pharmacist.detailTitle'.tr())),
      body: AsyncValueView(
        value: result,
        onRetry: () => ref.invalidate(pharmacistDetailProvider(pharmacistId)),
        data: (data) => _PharmacistDetailBody(pharmacist: data.pharmacist, proof: data.proof),
      ),
    );
  }
}

class _PharmacistDetailBody extends StatelessWidget {
  const _PharmacistDetailBody({required this.pharmacist, required this.proof});

  final Pharmacist pharmacist;
  final CryptographicProof proof;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(
          child: CircleAvatar(
            radius: 48,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
            backgroundImage: pharmacist.photoUrl != null ? NetworkImage(pharmacist.photoUrl!) : null,
            child: pharmacist.photoUrl == null
                ? Icon(Icons.person_rounded, size: 40, color: theme.colorScheme.primary)
                : null,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            pharmacist.fullName,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 6),
        Center(child: LicenseStatusBadge(status: pharmacist.licenseStatus)),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('pharmacist.identity'.tr(), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const Divider(height: 20),
                _InfoRow(label: 'pharmacist.ordinalNumber'.tr(), value: pharmacist.ordinalNumber),
                _InfoRow(label: 'pharmacist.licenseNumber'.tr(), value: pharmacist.licenseNumber),
                if (pharmacist.province != null)
                  _InfoRow(label: 'pharmacists.province'.tr(), value: pharmacist.province!.name),
                if (pharmacist.city != null) _InfoRow(label: 'pharmacists.city'.tr(), value: pharmacist.city!.name),
                if (pharmacist.commune != null)
                  _InfoRow(label: 'pharmacists.commune'.tr(), value: pharmacist.commune!.name),
                _InfoRow(label: 'pharmacist.address'.tr(), value: pharmacist.professionalAddress),
                _InfoRow(label: 'pharmacist.phone'.tr(), value: pharmacist.professionalPhone),
                _InfoRow(label: 'pharmacist.email'.tr(), value: pharmacist.professionalEmail),
                _InfoRow(label: 'pharmacist.establishment'.tr(), value: pharmacist.pharmacyEstablishment),
                if ((pharmacist.specialization ?? '').isNotEmpty)
                  _InfoRow(label: 'pharmacist.specialization'.tr(), value: pharmacist.specialization!),
                if (pharmacist.registeredAt != null)
                  _InfoRow(label: 'pharmacist.registeredAt'.tr(), value: pharmacist.registeredAt!),
                if (pharmacist.practiceStartedAt != null)
                  _InfoRow(label: 'pharmacist.practiceStartedAt'.tr(), value: pharmacist.practiceStartedAt!),
                if (pharmacist.licenseExpiresAt != null)
                  _InfoRow(label: 'pharmacist.licenseExpiresAt'.tr(), value: pharmacist.licenseExpiresAt!),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        CryptoProofCard(
          proof: proof,
          verificationHash: pharmacist.verificationHash,
          signature: pharmacist.qrCodeSignature,
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
