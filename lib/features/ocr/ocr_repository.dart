import 'package:dio/dio.dart' as dio;

import '../../core/api/api_client.dart';
import 'ocr_models.dart';

class OcrRepository {
  OcrRepository(this._client);

  final ApiClient _client;

  /// Uploads a photo of a professional card, diploma or ID document and
  /// returns a best-effort pre-fill of the onboarding fields.
  Future<OcrExtractedFields> extract(String imagePath) async {
    final formData = dio.FormData.fromMap({
      'document': await dio.MultipartFile.fromFile(imagePath),
    });

    final response = await _client.post<Map<String, dynamic>>('/ocr/extract', data: formData);
    return OcrExtractedFields.fromJson(response.data!);
  }
}
