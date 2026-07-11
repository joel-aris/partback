import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import 'pharmacist_models.dart';
import 'pharmacist_repository.dart';

final pharmacistRepositoryProvider = Provider<PharmacistRepository>(
  (ref) => PharmacistRepository(ref.watch(apiClientProvider)),
);

class PharmacistSearchParams {
  const PharmacistSearchParams({this.query, this.provinceId, this.communeId});

  final String? query;
  final String? provinceId;
  final String? communeId;

  @override
  bool operator ==(Object other) =>
      other is PharmacistSearchParams &&
      other.query == query &&
      other.provinceId == provinceId &&
      other.communeId == communeId;

  @override
  int get hashCode => Object.hash(query, provinceId, communeId);
}

final pharmacistSearchProvider = FutureProvider.family<List<Pharmacist>, PharmacistSearchParams>((ref, params) {
  return ref
      .watch(pharmacistRepositoryProvider)
      .search(query: params.query, provinceId: params.provinceId, communeId: params.communeId);
});

final pharmacistDetailProvider = FutureProvider.family<PharmacistSearchResult, String>((ref, id) {
  return ref.watch(pharmacistRepositoryProvider).get(id);
});
