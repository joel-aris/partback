import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'auth_models.dart';

/// Outcome of a login attempt. VALIDIKA's `/auth/login` can succeed outright,
/// or come back as HTTP 423 asking for 2FA setup/verification before a token
/// is issued (see backend AuthController::login).
sealed class LoginResult {
  const LoginResult();
}

class LoginSuccess extends LoginResult {
  const LoginSuccess({required this.token, required this.user, required this.requiresEmailVerification});

  final String token;
  final AuthUser user;
  final bool requiresEmailVerification;
}

class LoginRequires2fa extends LoginResult {
  const LoginRequires2fa({required this.requiresSetup, required this.message});

  final bool requiresSetup;
  final String message;
}

class AuthRepository {
  AuthRepository(this._client);

  final ApiClient _client;

  Future<AuthUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/auth/register',
      data: {'name': name, 'email': email, 'password': password, 'password_confirmation': password},
    );

    return AuthUser.fromJson(response.data!['user'] as Map<String, dynamic>);
  }

  Future<LoginResult> login({required String email, required String password, String? otp}) async {
    try {
      final response = await _client.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'email': email, 'password': password, if (otp != null && otp.isNotEmpty) 'otp': otp},
      );

      final data = response.data!;
      return LoginSuccess(
        token: data['access_token'] as String,
        user: AuthUser.fromJson(data['user'] as Map<String, dynamic>),
        requiresEmailVerification: data['requires_email_verification'] as bool? ?? false,
      );
    } on ApiException catch (error) {
      if (error.statusCode == 423) {
        final data = error.data ?? {};
        return LoginRequires2fa(
          requiresSetup: data['requires_2fa_setup'] as bool? ?? false,
          message: error.message,
        );
      }
      rethrow;
    }
  }

  Future<void> logout() => _client.post('/auth/logout');

  Future<AuthUser> me() async {
    final response = await _client.get<Map<String, dynamic>>('/auth/me');
    return AuthUser.fromJson(response.data!['user'] as Map<String, dynamic>);
  }

  Future<void> verifyEmail(String code) => _client.post('/auth/verify-email', data: {'code': code});

  Future<void> resendVerification() => _client.post('/auth/resend-verification');
}
