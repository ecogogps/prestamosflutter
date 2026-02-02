import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/providers/auth_provider.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/screens/login_screen.dart';
import 'package:myapp/screens/register_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    _router = GoRouter(
      refreshListenable: authProvider,
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          name: 'register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
      ],
      redirect: (context, state) {
        final bool loggedIn = authProvider.isAuthenticated;
        final bool isLoggingIn = state.matchedLocation == '/' || state.matchedLocation == '/register';

        // Si no está autenticado e intenta acceder a una ruta protegida, redirigir a login
        if (!loggedIn && !isLoggingIn) {
          return '/';
        }

        // Si está autenticado y está en una ruta de autenticación, redirigir a home
        if (loggedIn && isLoggingIn) {
          return '/home';
        }

        return null; // No se necesita redirección
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Joseph',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      routerConfig: _router,
    );
  }
}
