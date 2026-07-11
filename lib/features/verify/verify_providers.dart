import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import 'verify_models.dart';
import 'verify_repository.dart';

final verifyRepositoryProvider = Provider<VerifyRepository>((ref) => VerifyRepository(ref.watch(apiClientProvider)));

final verifyResultProvider = FutureProvider.family<VerifyResult, String>((ref, code) {
  return ref.watch(verifyRepositoryProvider).verify(code);
});
