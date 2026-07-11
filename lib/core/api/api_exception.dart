import 'package:dio/dio.dart';

/// A human-readable error surfaced to the UI. Never let a raw
/// "Request failed with status code 422" reach the user: this class always
/// carries the exact message/validation errors returned by the Laravel API.
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode, this.fieldErrors = const {}, this.data});

  final String message;
  final int? statusCode;
  final Map<String, List<String>> fieldErrors;

  /// Raw decoded response body, when the caller needs more than the message
  /// (e.g. the 423 "2FA required" login response also carries the user payload).
  final Map<String, dynamic>? data;

  bool get isUnauthorized => statusCode == 401;
  bool get isValidation => statusCode == 422;
  bool get isNetwork => statusCode == null;

  factory ApiException.fromDioException(DioException error) {
    final response = error.response;

    if (response == null) {
      return switch (error.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout => const ApiException(
          "Le serveur met trop de temps a repondre. Verifiez votre connexion.",
        ),
        DioExceptionType.connectionError => const ApiException(
          "Impossible de joindre le serveur VALIDIKA. Verifiez votre connexion internet.",
        ),
        _ => ApiException(error.message ?? "Une erreur reseau inattendue est survenue."),
      };
    }

    final data = response.data;
    String message = "Une erreur est survenue (code ${response.statusCode}).";
    final fieldErrors = <String, List<String>>{};

    if (data is Map) {
      final apiMessage = data['message'];
      if (apiMessage is String && apiMessage.isNotEmpty) {
        message = apiMessage;
      }

      final errors = data['errors'];
      if (errors is Map) {
        for (final entry in errors.entries) {
          final value = entry.value;
          if (value is List) {
            fieldErrors[entry.key.toString()] = value.map((e) => e.toString()).toList();
          }
        }

        if (fieldErrors.isNotEmpty) {
          final firstList = fieldErrors.values.first;
          if (firstList.isNotEmpty) {
            message = firstList.first;
          }
        }
      }
    }

    return ApiException(
      message,
      statusCode: response.statusCode,
      fieldErrors: fieldErrors,
      data: data is Map ? Map<String, dynamic>.from(data) : null,
    );
  }

  @override
  String toString() => message;
}
