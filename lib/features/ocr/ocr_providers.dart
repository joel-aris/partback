import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import 'ocr_repository.dart';

final ocrRepositoryProvider = Provider<OcrRepository>(
  (ref) => OcrRepository(ref.watch(apiClientProvider)),
);
