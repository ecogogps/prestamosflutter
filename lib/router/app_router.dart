import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/providers/auth_provider.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/screens/login_screen.dart';
import 'package:myapp/screens/register_screen.dart';

GoRouter createAppRouter(AuthProvider authProvider) {
  return GoRouter(
    refreshListenable: authProvider,
    debugLogDiagnostics: true,
    initialLocation: '/login',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginScreen();
        },
        routes: [
          GoRoute(
            path: 'home',
            builder: (BuildContext context, GoRouterState state) {
              return const HomeScreen();
            },
          ),
          GoRoute(
            path: 'login',
            builder: (BuildContext context, GoRouterState state) {
              return const LoginScreen();
            },
          ),
          GoRoute(
            path: 'register',
            builder: (BuildContext context, GoRouterState state) {
              return const RegisterScreen();
            },
          ),
        ],
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final bool loggedIn = authProvider.isAuthenticated;
      final String location = state.uri.toString();

      final isAuthRoute = location.startsWith('/login') || location.startsWith('/register');

      if (!loggedIn && !isAuthRoute) {
        return '/login';
      }

      if (loggedIn && isAuthRoute) {
        return '/home';
      }

      return null;
    },
  );
}
