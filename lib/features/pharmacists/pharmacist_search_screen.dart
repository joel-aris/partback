import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/state_views.dart';
import '../territories/territory_providers.dart';
import 'pharmacist_models.dart';
import 'pharmacist_providers.dart';
import 'widgets/license_status_badge.dart';

class PharmacistSearchScreen extends ConsumerStatefulWidget {
  const PharmacistSearchScreen({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  ConsumerState<PharmacistSearchScreen> createState() => _PharmacistSearchScreenState();
}

class _PharmacistSearchScreenState extends ConsumerState<PharmacistSearchScreen> {
  late final _searchController = TextEditingController(text: widget.initialQuery);
  Timer? _debounce;
  String _query = '';
  String? _provinceId;
  String? _communeId;

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery?.trim() ?? '';
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _query = value.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final params = PharmacistSearchParams(
      query: _query.isNotEmpty ? _query : null,
      provinceId: _provinceId,
      communeId: _communeId,
    );
    final results = ref.watch(pharmacistSearchProvider(params));

    return Scaffold(
      appBar: AppBar(title: Text('pharmacists.searchTitle'.tr())),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              onChanged: _onQueryChanged,
              decoration: InputDecoration(
                hintText: 'pharmacists.searchHint'.tr(),
                prefixIcon: const Icon(Icons.search_rounded),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _ProvinceFilterChip(
                    selectedId: _provinceId,
                    onChanged: (id) => setState(() {
                      _provinceId = id;
                      _communeId = null;
                    }),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
          Expanded(
            child: AsyncValueView(
              value: results,
              onRetry: () => ref.invalidate(pharmacistSearchProvider(params)),
              data: (pharmacists) {
                if (pharmacists.isEmpty) {
                  return EmptyView(message: 'pharmacists.noResults'.tr(), icon: Icons.local_pharmacy_outlined);
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: pharmacists.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => _PharmacistCard(pharmacist: pharmacists[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProvinceFilterChip extends ConsumerWidget {
  const _ProvinceFilterChip({required this.selectedId, required this.onChanged});

  final String? selectedId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provinces = ref.watch(provincesProvider);

    return provinces.when(
      data: (items) => DropdownMenu<String?>(
        initialSelection: selectedId,
        label: Text('pharmacists.province'.tr()),
        dropdownMenuEntries: [
          DropdownMenuEntry(value: null, label: 'pharmacists.province'.tr()),
          ...items.map((province) => DropdownMenuEntry(value: province.id, label: province.name)),
        ],
        onSelected: onChanged,
      ),
      loading: () => const SizedBox(width: 120, child: LinearProgressIndicator()),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _PharmacistCard extends StatelessWidget {
  const _PharmacistCard({required this.pharmacist});

  final Pharmacist pharmacist;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/pharmacists/${pharmacist.id}'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
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
                    Text(pharmacist.fullName, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      pharmacist.licenseNumber,
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                    ),
                    if (pharmacist.province != null)
                      Text(
                        pharmacist.province!.name,
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                      ),
                  ],
                ),
              ),
              LicenseStatusBadge(status: pharmacist.licenseStatus),
            ],
          ),
        ),
      ),
    );
  }
}
