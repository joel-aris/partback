import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/state_views.dart';
import '../auth/auth_controller.dart';
import 'account_providers.dart';
import 'candidacy_models.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text('account.title'.tr())),
      body: authState.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(error: error, onRetry: () => ref.invalidate(authControllerProvider)),
        data: (state) {
          if (!state.isAuthenticated) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_outline_rounded, size: 48, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 12),
                    Text('account.notLoggedIn'.tr(), textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.push('/login'),
                      child: Text('account.loginCta'.tr()),
                    ),
                  ],
                ),
              ),
            );
          }

          final user = state.user!;
          final candidacies = ref.watch(myCandidaciesProvider);

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myCandidaciesProvider),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(radius: 26, child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?')),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                              Text(user.email, style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('account.myCandidacies'.tr(), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                AsyncValueView(
                  value: candidacies,
                  onRetry: () => ref.invalidate(myCandidaciesProvider),
                  data: (items) {
                    if (items.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: EmptyView(message: 'account.noCandidacies'.tr(), icon: Icons.assignment_outlined),
                      );
                    }
                    return Column(children: items.map((item) => _CandidacyTile(item: item)).toList());
                  },
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () => _confirmLogout(context, ref),
                  icon: const Icon(Icons.logout_rounded),
                  label: Text('common.logout'.tr()),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('account.logoutConfirmTitle'.tr()),
        content: Text('account.logoutConfirmBody'.tr()),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('common.cancel'.tr())),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text('common.confirm'.tr())),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authControllerProvider.notifier).logout();
    }
  }
}

class _CandidacyTile extends StatelessWidget {
  const _CandidacyTile({required this.item});

  final CandidacyItem item;

  Color _statusColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return switch (item.status) {
      'accepted' => const Color(0xFF1A7F37),
      'rejected' => scheme.error,
      _ => const Color(0xFFB35900),
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('${item.firstName} ${item.lastName}', style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(999)),
                  child: Text(
                    'candidacy.status.${item.status}'.tr(),
                    style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                ),
              ],
            ),
            if ((item.adminNotes ?? '').isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                '${'account.adminNotes'.tr()}: ${item.adminNotes}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
