import '../../core/api/api_client.dart';
import 'territory_models.dart';

class TerritoryRepository {
  TerritoryRepository(this._client);

  final ApiClient _client;

  Future<List<Territory>> provinces() async {
    final response = await _client.get<Map<String, dynamic>>('/territories/provinces');
    return _parse(response.data);
  }

  Future<List<Territory>> cities({String? provinceId}) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/territories/cities',
      queryParameters: provinceId != null ? {'provinces': provinceId} : null,
    );
    return _parse(response.data, parentKey: 'province_id');
  }

  Future<List<Territory>> communes({String? cityId}) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/territories/communes',
      queryParameters: cityId != null ? {'cities': cityId} : null,
    );
    return _parse(response.data, parentKey: 'city_id');
  }

  List<Territory> _parse(Map<String, dynamic>? body, {String? parentKey}) {
    final items = body?['data'];
    if (items is! List) {
      return const [];
    }
    return items
        .whereType<Map<String, dynamic>>()
        .map((json) => Territory.fromJson(json, parentKey: parentKey))
        .toList();
  }
}
