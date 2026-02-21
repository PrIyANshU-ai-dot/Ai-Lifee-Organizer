import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_life_organizer/app_shell.dart';
import 'package:ai_life_organizer/features/auth/presentation/providers/auth_providers.dart';
import 'package:ai_life_organizer/features/auth/presentation/screens/login_screen.dart';
import 'package:ai_life_organizer/features/auth/presentation/screens/signup_screen.dart';
import 'package:ai_life_organizer/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:ai_life_organizer/features/goals/presentation/screens/create_goal_screen.dart';
import 'package:ai_life_organizer/features/insights/presentation/screens/insights_screen.dart';

/// Route paths as constants for type-safe navigation.
class AppRoutes {
  AppRoutes._();
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/';
  static const String createGoal = '/goals/create';
  static const String insights = '/insights';
}

/// GoRouter configuration with auth redirect and refresh logic.
/// Uses Riverpod to watch auth state and rebuild router when auth changes.
final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(currentUserProvider);
  
  // Refresh router when auth state changes
  ref.listen(currentUserProvider, (previous, next) {
    // Router will automatically rebuild when provider changes
  });

  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation == AppRoutes.login || 
                         state.matchedLocation == AppRoutes.signup;

      // Redirect to login if not authenticated and not on auth route
      if (!isLoggedIn && !isAuthRoute) {
        return AppRoutes.login;
      }
      
      // Redirect to home if authenticated and on auth route
      if (isLoggedIn && isAuthRoute) {
        return AppRoutes.home;
      }
      
      return null; // No redirect needed
    },
    routes: [
      // Auth routes (no shell)
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      
      // Authenticated routes (with shell)
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const AppShell(child: DashboardScreen()),
      ),
      GoRoute(
        path: AppRoutes.createGoal,
        name: 'createGoal',
        builder: (context, state) => const AppShell(child: CreateGoalScreen()),
      ),
      GoRoute(
        path: AppRoutes.insights,
        name: 'insights',
        builder: (context, state) => const AppShell(child: InsightsScreen()),
      ),
    ],
    // Error handling
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.matchedLocation,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
