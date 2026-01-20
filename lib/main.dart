import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/screens/initial_screen.dart';
import 'package:myapp/screens/login_screen.dart';
import 'package:myapp/screens/register_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://abtkeofifxcyadnydvdl.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFidGtlb2ZpZnhjeWFkbnlkdmRsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg4ODA4OTksImV4cCI6MjA4NDQ1Njg5OX0.8kqPmiBjCAYZ9_CqVK8DYf39rU5kfTplaYuCWKUwsjA',
  );
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Joseph',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      routerConfig: _router,
    );
  }
}

// Helper class to convert a Stream to a Listenable
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final _router = GoRouter(
  refreshListenable: GoRouterRefreshStream(supabase.auth.onAuthStateChange),
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) =>
          const InitialScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) =>
          const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (BuildContext context, GoRouterState state) =>
          const RegisterScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (BuildContext context, GoRouterState state) =>
          const HomeScreen(),
    ),
  ],
  redirect: (BuildContext context, GoRouterState state) {
    final session = supabase.auth.currentSession;
    final loggedIn = session != null;
    final onAuthRoute =
        state.matchedLocation == '/login' || state.matchedLocation == '/register';
    final onPublicHome = state.matchedLocation == '/';

    // If the user is not logged in and is trying to access a protected route like /home,
    // redirect them to the login page.
    if (!loggedIn && state.matchedLocation == '/home') {
      return '/login';
    }

    // If the user is logged in and is on a public route (like /, /login, or /register),
    // redirect them to the authenticated home page.
    if (loggedIn && (onAuthRoute || onPublicHome)) {
      return '/home';
    }

    // No redirect needed.
    return null;
  },
);
