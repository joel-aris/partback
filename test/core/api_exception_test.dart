import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:validika_mobile/core/api/api_exception.dart';

RequestOptions _requestOptions() => RequestOptions(path: '/test');

void main() {
  group('ApiException.fromDioException', () {
    test('extracts the first validation error message instead of a generic HTTP message', () {
      final error = DioException(
        requestOptions: _requestOptions(),
        response: Response(
          requestOptions: _requestOptions(),
          statusCode: 422,
          data: {
            'message': 'Les donnees fournies sont invalides.',
            'errors': {
              'email': ['Le format de cette adresse email est invalide.'],
            },
          },
        ),
        type: DioExceptionType.badResponse,
      );

      final exception = ApiException.fromDioException(error);

      expect(exception.statusCode, 422);
      expect(exception.isValidation, isTrue);
      expect(exception.message, 'Le format de cette adresse email est invalide.');
      expect(exception.fieldErrors['email'], ['Le format de cette adresse email est invalide.']);
      // Never leak the raw Dio message ("Request failed with status code 422") to the UI.
      expect(exception.message, isNot(contains('status code')));
    });

    test('falls back to the API message when there are no field errors', () {
      final error = DioException(
        requestOptions: _requestOptions(),
        response: Response(
          requestOptions: _requestOptions(),
          statusCode: 401,
          data: {'message': 'Non authentifie.'},
        ),
        type: DioExceptionType.badResponse,
      );

      final exception = ApiException.fromDioException(error);

      expect(exception.isUnauthorized, isTrue);
      expect(exception.message, 'Non authentifie.');
    });

    test('produces a friendly message for connection errors with no response', () {
      final error = DioException(requestOptions: _requestOptions(), type: DioExceptionType.connectionError);

      final exception = ApiException.fromDioException(error);

      expect(exception.isNetwork, isTrue);
      expect(exception.message, contains('joindre le serveur'));
    });
  });
}
