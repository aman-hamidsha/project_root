import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/application/auth_controller.dart';
import '../features/auth/domain/auth_state.dart';
import '../features/auth/presentation/pages/auth_loading_page.dart';
import '../features/auth/presentation/pages/crypto_scam_sim.dart';
import '../features/auth/presentation/pages/landing_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/signup_page.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/dashboard/presentation/pages/guide_page.dart';
import '../features/dashboard/presentation/pages/leaderboard_page.dart';
import '../features/dashboard/presentation/pages/settings_page.dart';
import '../features/lessons/presentation/pages/lessons_page.dart';
import '../features/quizzes/presentation/pages/quiz_page.dart';
import '../features/simulators/presentation/pages/email_sim_page.dart';
import '../features/simulators/presentation/pages/sms_sim_page.dart';
import '../features/simulators/presentation/pages/wifi_sim_page.dart';

/**
 * This file defines the appRouterProvider, which is a Riverpod provider that 
 * creates and configures a GoRouter instance for the application. 
 * The router defines the routes for the app and includes a redirect function 
 * to handle navigation based on the user's authentication state.
 */

final appRouterProvider = Provider<GoRouter>((ref) {
  // Riverpod provider that exposes GoRouter instance
  final authState = ref.watch(
    authControllerProvider,
  ); // reactive auth state (loading/authenticated/unauthenticated)

  return GoRouter(
    // create router configuration
    initialLocation: '/loading', // default route when app starts
    routes: [
      // list of all app routes
      GoRoute(
        path: '/loading',
        builder: (_, __) => const AuthLoadingPage(),
      ), // loading screen route
      GoRoute(
        path: '/',
        builder: (_, __) => const LandingPage(),
      ), // root route -> landing page
      GoRoute(
        path: '/landing',
        builder: (_, __) => const LandingPage(),
      ), // explicit landing route
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginPage(),
      ), // login page route
      GoRoute(
        path: '/signup',
        builder: (_, __) => const SignupPage(),
      ), // signup page route
      GoRoute(
        path: '/dashboard',
        builder: (_, __) => const DashboardPage(),
      ), // main authenticated dashboard
      GoRoute(
        path: '/guide',
        builder: (_, __) => const GuidePage(),
      ), // guide/tutorial page
      GoRoute(
        path: '/leaderboard', // leaderboard route
        builder: (_, __) => const LeaderboardPage(), // leaderboard UI
      ),
      GoRoute(
        path: '/settings',
        builder: (_, __) => const SettingsPage(),
      ), // settings page
      GoRoute(
        path: '/lessons',
        builder: (_, __) => const LessonsPage(),
      ), // lessons page
      GoRoute(
        path: '/quiz', // quiz route with query parameter
        builder:
            (_, state) => // access route state
            QuizPage(
              initialChapterId: state.uri.queryParameters['chapter'],
            ), // pass chapter ID from URL
      ),
      GoRoute(
        path: '/sim/crypto', // crypto scam simulation route
        builder: (_, __) => const CryptoScamSimPage(), // crypto sim UI
      ),
      GoRoute(
        path: '/sim/email',
        builder: (_, __) => const EmailSimPage(),
      ), // email phishing simulation
      GoRoute(
        path: '/sim/sms',
        builder: (_, __) => const SmsSimPage(),
      ), // SMS phishing simulation
      GoRoute(
        path: '/sim/wifi',
        builder: (_, __) => const WifiSimPage(),
      ), // public WiFi attack simulation
    ],
    redirect: (_, state) {
      // global redirect logic for route protection
      final location = state.matchedLocation; // current route path

      final isGuestRoute = <String>{
        // routes accessible without login
        '/',
        '/landing',
        '/login',
        '/signup',
      }.contains(location);

      final isProtectedRoute = <String>{
        // routes requiring authentication
        '/dashboard',
        '/guide',
        '/leaderboard',
        '/settings',
        '/lessons',
        '/quiz',
        '/sim/crypto',
        '/sim/email',
        '/sim/sms',
        '/sim/wifi',
      }.contains(location);

      if (authState.status == AuthStatus.loading) {
        // auth state still being determined
        return location == '/loading'
            ? null
            : '/loading'; // force loading screen unless already there
      }

      if (authState.status == AuthStatus.authenticated) {
        // user is logged in
        if (location == '/loading' || isGuestRoute) {
          // prevent access to guest/loading routes
          return '/dashboard'; // redirect to dashboard
        }

        return null; // allow navigation
      }

      if (location == '/loading' || isProtectedRoute) {
        // unauthenticated user accessing restricted routes
        return '/login'; // redirect to login
      }

      return null; // allow navigation for guest routes
    },
  );
});
