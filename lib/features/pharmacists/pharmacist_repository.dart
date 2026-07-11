import '../../core/api/api_client.dart';
import 'pharmacist_models.dart';

class PharmacistSearchResult {
  const PharmacistSearchResult({required this.pharmacist, required this.proof});

  final Pharmacist pharmacist;
  final CryptographicProof proof;
}

class PharmacistRepository {
  PharmacistRepository(this._client);

  final ApiClient _client;

  Future<List<Pharmacist>> search({String? query, String? provinceId, String? communeId, int perPage = 30}) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/pharmacists',
      queryParameters: {
        if (query != null && query.isNotEmpty) 'q': query,
        'province': ?provinceId,
        'commune': ?communeId,
        'per_page': perPage,
      },
    );

    final items = response.data?['data'];
    if (items is! List) return const [];
    return items.whereType<Map<String, dynamic>>().map(Pharmacist.fromJson).toList();
  }

  Future<PharmacistSearchResult> get(String id) async {
    final response = await _client.get<Map<String, dynamic>>('/pharmacists/$id');
    final body = response.data!;
    return PharmacistSearchResult(
      pharmacist: Pharmacist.fromJson(body['data'] as Map<String, dynamic>),
      proof: CryptographicProof.fromJson(body['cryptographic_proof'] as Map<String, dynamic>),
    );
  }
}
