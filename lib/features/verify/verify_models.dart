import '../pharmacists/pharmacist_models.dart';

sealed class VerifyResult {
  const VerifyResult();
}

class VerifyPharmacistResult extends VerifyResult {
  const VerifyPharmacistResult({required this.valid, required this.pharmacist, required this.proof});

  final bool valid;
  final Pharmacist pharmacist;
  final CryptographicProof proof;
}

class VerifyDocumentResult extends VerifyResult {
  const VerifyDocumentResult({required this.valid, required this.title, required this.proof});

  final bool valid;
  final String title;
  final CryptographicProof proof;
}

class VerifyNotFound extends VerifyResult {
  const VerifyNotFound({required this.message});

  final String message;
}
