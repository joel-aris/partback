import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/account/account_screen.dart';
import '../../features/account/candidacy_submit_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/verify_email_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/pharmacists/pharmacist_detail_screen.dart';
import '../../features/pharmacists/pharmacist_search_screen.dart';
import '../../features/verify/verify_result_screen.dart';
import '../../features/verify/verify_screen.dart';
import 'app_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/', builder: (context, state) => const HomeScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/verify', builder: (context, state) => const VerifyScreen())]),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/pharmacists',
                builder: (context, state) =>
                    PharmacistSearchScreen(initialQuery: state.uri.queryParameters['q']),
              ),
            ],
          ),
          StatefulShellBranch(routes: [GoRoute(path: '/account', builder: (context, state) => const AccountScreen())]),
        ],
      ),
      GoRoute(
        path: '/pharmacists/:id',
        builder: (context, state) => PharmacistDetailScreen(pharmacistId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/verify/result/:code',
        builder: (context, state) => VerifyResultScreen(code: state.pathParameters['code']!),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/verify-email', builder: (context, state) => const VerifyEmailScreen()),
      GoRoute(
        path: '/candidacy',
        builder: (context, state) => const CandidacySubmitScreen(),
      ),
    ],
  );
});
