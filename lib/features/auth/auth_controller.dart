import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import 'auth_models.dart';
import 'auth_repository.dart';

enum AuthStatus { authenticated, unauthenticated }

class AuthState {
  const AuthState({required this.status, this.user, this.requiresEmailVerification = false});

  final AuthStatus status;
  final AuthUser? user;
  final bool requiresEmailVerification;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  static const unauthenticated = AuthState(status: AuthStatus.unauthenticated);
}

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository(ref.watch(apiClientProvider)));

final authControllerProvider = AsyncNotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthController extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    ref.watch(apiClientProvider).onUnauthorized.listen((_) {
      state = const AsyncData(AuthState.unauthenticated);
    });

    final token = await ref.read(tokenStorageProvider).readToken();
    if (token == null || token.isEmpty) {
      return AuthState.unauthenticated;
    }

    try {
      final user = await ref.read(authRepositoryProvider).me();
      return AuthState(
        status: AuthStatus.authenticated,
        user: user,
        requiresEmailVerification: !user.emailVerified,
      );
    } catch (_) {
      await ref.read(tokenStorageProvider).clear();
      return AuthState.unauthenticated;
    }
  }

  Future<LoginResult> login({required String email, required String password, String? otp}) async {
    final result = await ref.read(authRepositoryProvider).login(email: email, password: password, otp: otp);

    if (result is LoginSuccess) {
      await ref.read(tokenStorageProvider).writeToken(result.token);
      state = AsyncData(
        AuthState(
          status: AuthStatus.authenticated,
          user: result.user,
          requiresEmailVerification: result.requiresEmailVerification,
        ),
      );
    }

    return result;
  }

  Future<AuthUser> register({required String name, required String email, required String password}) {
    return ref.read(authRepositoryProvider).register(name: name, email: email, password: password);
  }

  Future<void> logout() async {
    try {
      await ref.read(authRepositoryProvider).logout();
    } catch (_) {
      // Best-effort server-side revocation: the local session is cleared regardless.
    }
    await ref.read(tokenStorageProvider).clear();
    state = const AsyncData(AuthState.unauthenticated);
  }

  Future<void> verifyEmail(String code) async {
    await ref.read(authRepositoryProvider).verifyEmail(code);
    final current = state.value;
    if (current?.user != null) {
      state = AsyncData(AuthState(status: AuthStatus.authenticated, user: current!.user));
    }
  }

  Future<void> resendVerification() => ref.read(authRepositoryProvider).resendVerification();
}
