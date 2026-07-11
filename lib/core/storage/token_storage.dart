import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the Sanctum API token in the platform keychain/keystore.
/// Never store the token in shared_preferences: it must survive only in
/// secure, encrypted-at-rest storage per the mobile security requirements.
///
/// Every call is bounded by a timeout: on some platforms/environments the
/// underlying secure storage backend (Keychain/Keystore/libsecret/Web Crypto)
/// can stall waiting on a system service that isn't available. Since every
/// API request reads the token first (see ApiClient), a stuck read would
/// otherwise freeze the entire app rather than degrading to "logged out".
class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage}) : _storage = storage ?? const FlutterSecureStorage();

  static const _tokenKey = 'validika.access_token';
  static const _timeout = Duration(seconds: 3);

  final FlutterSecureStorage _storage;

  Future<String?> readToken() =>
      _storage.read(key: _tokenKey).timeout(_timeout, onTimeout: () => null);

  Future<void> writeToken(String token) =>
      _storage.write(key: _tokenKey, value: token).timeout(_timeout, onTimeout: () {});

  Future<void> clear() => _storage.delete(key: _tokenKey).timeout(_timeout, onTimeout: () {});
}
