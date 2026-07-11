import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import 'territory_models.dart';
import 'territory_repository.dart';

final territoryRepositoryProvider = Provider<TerritoryRepository>(
  (ref) => TerritoryRepository(ref.watch(apiClientProvider)),
);

/// Cached for the app session: provinces rarely change and are reused across
/// the pharmacist search filters (cahier des charges 8, "cache des territoires").
final provincesProvider = FutureProvider<List<Territory>>((ref) {
  return ref.watch(territoryRepositoryProvider).provinces();
});

final citiesProvider = FutureProvider.family<List<Territory>, String?>((ref, provinceId) {
  return ref.watch(territoryRepositoryProvider).cities(provinceId: provinceId);
});

final communesProvider = FutureProvider.family<List<Territory>, String?>((ref, cityId) {
  return ref.watch(territoryRepositoryProvider).communes(cityId: cityId);
});
