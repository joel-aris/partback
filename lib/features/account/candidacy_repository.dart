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
}
