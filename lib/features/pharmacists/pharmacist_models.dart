class NamedRef {
  const NamedRef({required this.id, required this.name});

  final String id;
  final String name;

  static NamedRef? fromJson(dynamic json) {
    if (json is! Map) return null;
    final id = json['id'];
    final name = json['name'];
    if (id == null || name == null) return null;
    return NamedRef(id: id.toString(), name: name.toString());
  }
}

class Pharmacist {
  const Pharmacist({
    required this.id,
    required this.publicId,
    required this.photoUrl,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.ordinalNumber,
    required this.sex,
    required this.province,
    required this.city,
    required this.commune,
    required this.professionalAddress,
    required this.professionalPhone,
    required this.professionalEmail,
    required this.professionalStatus,
    required this.registeredAt,
    required this.practiceStartedAt,
    required this.licenseNumber,
    required this.licenseStatus,
    required this.licenseExpiresAt,
    required this.pharmacyEstablishment,
    required this.specialization,
    required this.qrCodeToken,
    required this.verificationHash,
    required this.qrCodeSignature,
  });

  final String id;
  final String publicId;
  final String? photoUrl;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String ordinalNumber;
  final String sex;
  final NamedRef? province;
  final NamedRef? city;
  final NamedRef? commune;
  final String professionalAddress;
  final String professionalPhone;
  final String professionalEmail;
  final String professionalStatus;
  final String? registeredAt;
  final String? practiceStartedAt;
  final String licenseNumber;
  final String licenseStatus;
  final String? licenseExpiresAt;
  final String pharmacyEstablishment;
  final String? specialization;
  final String qrCodeToken;
  final String? verificationHash;
  final String? qrCodeSignature;

  String get fullName => [firstName, middleName, lastName].where((part) => (part ?? '').isNotEmpty).join(' ');

  factory Pharmacist.fromJson(Map<String, dynamic> json) {
    return Pharmacist(
      id: json['id'].toString(),
      publicId: json['public_id']?.toString() ?? '',
      photoUrl: json['photo']?.toString(),
      firstName: json['first_name']?.toString() ?? '',
      middleName: json['middle_name']?.toString(),
      lastName: json['last_name']?.toString() ?? '',
      ordinalNumber: json['ordinal_number']?.toString() ?? '',
      sex: json['sex']?.toString() ?? '',
      province: NamedRef.fromJson(json['province']),
      city: NamedRef.fromJson(json['city']),
      commune: NamedRef.fromJson(json['commune']),
      professionalAddress: json['professional_address']?.toString() ?? '',
      professionalPhone: json['professional_phone']?.toString() ?? '',
      professionalEmail: json['professional_email']?.toString() ?? '',
      professionalStatus: json['professional_status']?.toString() ?? '',
      registeredAt: json['registered_at']?.toString(),
      practiceStartedAt: json['practice_started_at']?.toString(),
      licenseNumber: json['license_number']?.toString() ?? '',
      licenseStatus: json['license_status']?.toString() ?? '',
      licenseExpiresAt: json['license_expires_at']?.toString(),
      pharmacyEstablishment: json['pharmacy_establishment']?.toString() ?? '',
      specialization: json['specialization']?.toString(),
      qrCodeToken: json['qr_code_token']?.toString() ?? '',
      verificationHash: json['verification_hash']?.toString(),
      qrCodeSignature: json['qr_code_signature']?.toString(),
    );
  }
}

class CryptographicProof {
  const CryptographicProof({
    required this.valid,
    required this.hashValid,
    required this.signatureValid,
    required this.merkleValid,
    required this.merkleRoot,
    required this.merkleProofNodes,
    required this.proofVersion,
    required this.signatureAlgorithm,
    required this.publicKeyFingerprint,
    required this.verifiedAt,
  });

  // Nullable: the backend only returns the full Merkle-enriched proof for
  // pharmacists. For documents, `cryptographic_proof` omits `valid`,
  // `hash_valid`, `signature_valid` and `merkle_valid` entirely, so these
  // must stay null ("not provided by the API") rather than default to
  // false ("proven invalid") — otherwise a genuinely valid signed document
  // renders with a red "invalid" badge and crossed-out rows for no reason.
  final bool? valid;
  final bool? hashValid;
  final bool? signatureValid;
  final bool? merkleValid;
  final String? merkleRoot;
  final int? merkleProofNodes;
  final String? proofVersion;
  final String? signatureAlgorithm;
  final String? publicKeyFingerprint;
  final String? verifiedAt;

  factory CryptographicProof.fromJson(Map<String, dynamic> json) {
    return CryptographicProof(
      valid: json['valid'] as bool?,
      hashValid: json['hash_valid'] as bool?,
      signatureValid: json['signature_valid'] as bool?,
      merkleValid: json['merkle_valid'] as bool?,
      merkleRoot: json['merkle_root']?.toString(),
      merkleProofNodes: json['merkle_proof_nodes'] as int?,
      proofVersion: json['proof_version']?.toString(),
      signatureAlgorithm: json['signature_algorithm']?.toString(),
      publicKeyFingerprint: json['public_key_fingerprint']?.toString(),
      verifiedAt: json['verified_at']?.toString(),
    );
  }
}
