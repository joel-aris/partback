import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class LicenseStatusBadge extends StatelessWidget {
  const LicenseStatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = LicenseStatusColors.forStatus(context, status);
    final label = switch (status) {
      'active' => 'license.active'.tr(),
      'expired' => 'license.expired'.tr(),
      'suspended' => 'license.suspended'.tr(),
      'revoked' => 'license.revoked'.tr(),
      _ => status,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }
}
