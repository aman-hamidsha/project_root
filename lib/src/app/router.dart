import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/application/auth_controller.dart';
import '../features/auth/domain/auth_state.dart';
import '../features/auth/presentation/pages/auth_loading_page.dart';
import '../features/auth/presentation/pages/landing_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/signup_page.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/quizzes/presentation/pages/quiz_page.dart';
import '../features/simulators/presentation/pages/email_sim_page.dart';
import '../features/simulators/presentation/pages/sms_sim_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/loading',
    routes: [
      GoRoute(path: '/loading', builder: (_, __) => const AuthLoadingPage()),
      GoRoute(path: '/', builder: (_, __) => const LandingPage()),
      GoRoute(path: '/landing', builder: (_, __) => const LandingPage()),
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/signup', builder: (_, __) => const SignupPage()),
      GoRoute(path: '/dashboard', builder: (_, __) => const DashboardPage()),
      GoRoute(path: '/quiz', builder: (_, __) => const QuizPage()),
      GoRoute(path: '/sim/email', builder: (_, __) => const EmailSimPage()),
      GoRoute(path: '/sim/sms', builder: (_, __) => const SmsSimPage()),
    ],
    redirect: (_, state) {
      final location = state.matchedLocation;
      final isGuestRoute = <String>{'/', '/landing', '/login', '/signup'}
          .contains(location);
      final isProtectedRoute = <String>{
        '/dashboard',
        '/quiz',
        '/sim/email',
        '/sim/sms',
      }.contains(location);

      if (authState.status == AuthStatus.loading) {
        return location == '/loading' ? null : '/loading';
      }

      if (authState.status == AuthStatus.authenticated) {
        if (location == '/loading' || isGuestRoute) {
          return '/dashboard';
        }

        return null;
      }

      if (location == '/loading' || isProtectedRoute) {
        return '/landing';
      }

      return null;
    },
  );
});
