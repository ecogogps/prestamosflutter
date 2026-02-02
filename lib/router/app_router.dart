import 'package:go_router/go_router.dart';
import 'package:myapp/providers/auth_provider.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/screens/login_screen.dart';
import 'package:myapp/screens/register_screen.dart';

class AppRouter {
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/login',
      refreshListenable: authProvider,
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
      ],
      redirect: (context, state) {
        final isLoggedIn = authProvider.isAuthenticated;
        final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';

        // If user is not logged in and not on an auth page, redirect to login
        if (!isLoggedIn && !isAuthRoute) {
          return '/login';
        }

        // If user is logged in and tries to go to an auth page, redirect to home
        if (isLoggedIn && isAuthRoute) {
          return '/home';
        }

        return null; // No redirect needed
      },
    );
  }
}
