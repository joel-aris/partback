import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import 'candidacy_models.dart';
import 'candidacy_repository.dart';

final candidacyRepositoryProvider = Provider<CandidacyRepository>(
  (ref) => CandidacyRepository(ref.watch(apiClientProvider)),
);

final myCandidaciesProvider = FutureProvider<List<CandidacyItem>>((ref) {
  return ref.watch(candidacyRepositoryProvider).mine();
});
