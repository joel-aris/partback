import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import '../pharmacists/pharmacist_models.dart';
import 'verify_models.dart';

class VerifyRepository {
  VerifyRepository(this._client);

  final ApiClient _client;

  Future<VerifyResult> verify(String code) async {
    try {
      final response = await _client.get<Map<String, dynamic>>('/verify/${Uri.encodeComponent(code)}');
      final body = response.data!;
      final type = body['type']?.toString();
      final valid = body['valid'] as bool? ?? false;

      if (type == 'pharmacist') {
        return VerifyPharmacistResult(
          valid: valid,
          pharmacist: Pharmacist.fromJson(body['data'] as Map<String, dynamic>),
          proof: CryptographicProof.fromJson(body['cryptographic_proof'] as Map<String, dynamic>),
        );
      }

      if (type == 'document') {
        final data = body['data'] as Map<String, dynamic>? ?? {};
        return VerifyDocumentResult(
          valid: valid,
          title: data['title']?.toString() ?? '',
          proof: CryptographicProof.fromJson(body['cryptographic_proof'] as Map<String, dynamic>),
        );
      }

      return VerifyNotFound(message: body['message']?.toString() ?? '');
    } on ApiException catch (error) {
      if (error.statusCode == 404) {
        return VerifyNotFound(message: error.message);
      }
      rethrow;
    }
  }
}
