import 'package:dio/dio.dart' as dio;

import '../../core/api/api_client.dart';
import 'candidacy_models.dart';

class CandidacyRepository {
  CandidacyRepository(this._client);

  final ApiClient _client;

  Future<List<CandidacyItem>> mine() async {
    final response = await _client.get<Map<String, dynamic>>('/auth/candidacies');
    final items = response.data?['data'];
    if (items is! List) return const [];
    return items.whereType<Map<String, dynamic>>().map(CandidacyItem.fromJson).toList();
  }

  /// Public submission (no login required), mirrors `POST /candidacies`
  /// used by the web candidacy form.
  Future<void> submit({
    required String firstName,
    required String lastName,
    required String email,
    String? phone,
    String? address,
    String? notes,
    required String cvPath,
    String? motivationLetterPath,
  }) async {
    final formData = dio.FormData.fromMap({
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      if (address != null && address.isNotEmpty) 'address': address,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
      'cv': await dio.MultipartFile.fromFile(cvPath),
      if (motivationLetterPath != null) 'motivation_letter': await dio.MultipartFile.fromFile(motivationLetterPath),
    });

    await _client.post<Map<String, dynamic>>('/candidacies', data: formData);
  }
}
