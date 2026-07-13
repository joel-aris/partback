import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../pharmacist_models.dart';

/// Displays a pharmacist's cryptographic proof: a valid/invalid badge plus
/// expandable details (hash, signature, Merkle root...), each abbreviated
/// with a copy action, per cahier des charges 4.5/5.4.
class CryptoProofCard extends StatefulWidget {
  const CryptoProofCard({
    super.key,
    required this.proof,
    this.verificationHash,
    this.signature,
    this.overallValid,
  });

  final CryptographicProof proof;
  final String? verificationHash;
  final String? signature;

  /// Overrides `proof.valid` for the header badge. Needed for documents,
  /// whose `cryptographic_proof` doesn't carry a `valid` field of its own —
  /// the caller passes the verification result's own top-level `valid`
  /// instead (see `verify_result_screen.dart`).
  final bool? overallValid;

  @override
  State<CryptoProofCard> createState() => _CryptoProofCardState();
}

class _CryptoProofCardState extends State<CryptoProofCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final proof = widget.proof;
    final isValid = widget.overallValid ?? proof.valid ?? false;
    final validColor = isValid ? const Color(0xFF1A7F37) : theme.colorScheme.error;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isValid ? Icons.verified_rounded : Icons.gpp_bad_rounded,
                  color: validColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'pharmacist.proofTitle'.tr(),
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: validColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    isValid ? 'pharmacist.proofValid'.tr() : 'pharmacist.proofInvalid'.tr(),
                    style: theme.textTheme.labelMedium?.copyWith(color: validColor, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _ProofRow(
              label: 'pharmacist.hash'.tr(),
              value: widget.verificationHash,
              valid: proof.hashValid,
            ),
            _ProofRow(
              label: 'pharmacist.signature'.tr(),
              value: widget.signature,
              valid: proof.signatureValid,
            ),
            _ProofRow(
              label: 'pharmacist.merkleRoot'.tr(),
              value: proof.merkleRoot,
              valid: proof.merkleValid,
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  if (proof.merkleProofNodes != null)
                    _DetailLine(label: 'pharmacist.merkleNodes'.tr(), value: '${proof.merkleProofNodes}'),
                  if (proof.proofVersion != null)
                    _DetailLine(label: 'pharmacist.proofVersion'.tr(), value: proof.proofVersion!),
                  if (proof.verifiedAt != null)
                    _DetailLine(label: 'pharmacist.verifiedAt'.tr(), value: proof.verifiedAt!),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => setState(() => _expanded = !_expanded),
                child: Text(_expanded ? 'common.hideDetails'.tr() : 'common.showDetails'.tr()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProofRow extends StatelessWidget {
  const _ProofRow({required this.label, required this.value, required this.valid});

  final String label;
  final String? value;

  /// null means the API didn't provide this indicator (e.g. document
  /// proofs don't carry hash/signature/Merkle validity) — shown as a
  /// neutral dash, never as a false "invalid" cross.
  final bool? valid;

  String _abbreviate(String value) {
    if (value.length <= 18) return value;
    return '${value.substring(0, 10)}...${value.substring(value.length - 6)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayValue = value;
    final neutralColor = theme.colorScheme.onSurface.withValues(alpha: 0.4);
    final icon = valid == null
        ? Icons.remove_circle_outline_rounded
        : (valid! ? Icons.check_circle_rounded : Icons.cancel_rounded);
    final color = valid == null ? neutralColor : (valid! ? const Color(0xFF1A7F37) : theme.colorScheme.error);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                Text(
                  displayValue != null ? _abbreviate(displayValue) : '—',
                  style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
          if (displayValue != null)
            IconButton(
              icon: const Icon(Icons.copy_rounded, size: 18),
              tooltip: 'common.copy'.tr(),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: displayValue));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('common.copied'.tr())));
                }
              },
            ),
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodySmall)),
        ],
      ),
    );
  }
}
