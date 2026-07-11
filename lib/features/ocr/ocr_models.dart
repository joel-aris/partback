class OcrExtractedFields {
  const OcrExtractedFields({
    this.firstName,
    this.lastName,
    this.ordinalNumber,
    this.licenseNumber,
    this.licenseExpiresAt,
  });

  final String? firstName;
  final String? lastName;
  final String? ordinalNumber;
  final String? licenseNumber;
  final String? licenseExpiresAt;

  bool get isEmpty =>
      firstName == null && lastName == null && ordinalNumber == null && licenseNumber == null && licenseExpiresAt == null;

  factory OcrExtractedFields.fromJson(Map<String, dynamic> json) {
    final fields = (json['fields'] as Map<String, dynamic>?) ?? const {};
    return OcrExtractedFields(
      firstName: fields['first_name']?.toString(),
      lastName: fields['last_name']?.toString(),
      ordinalNumber: fields['ordinal_number']?.toString(),
      licenseNumber: fields['license_number']?.toString(),
      licenseExpiresAt: fields['license_expires_at']?.toString(),
    );
  }
}
