import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/auth_provider.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/screens/login_screen.dart';
import 'package:myapp/screens/register_screen.dart';
import 'package:myapp/screens/initial_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AuthProvider _authProvider;
  late GoRouter _goRouter;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider();
    _goRouter = GoRouter(
      initialLocation: '/',
      refreshListenable: _authProvider,
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const InitialScreen(),
        ),
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
      redirect: (BuildContext context, GoRouterState state) {
        final bool loggedIn = _authProvider.isLoggedIn;
        final String location = state.matchedLocation;

        // Si no está logueado y no está en una página pública, redirige a login
        if (!loggedIn &&
            location != '/login' &&
            location != '/register' &&
            location != '/') {
          return '/login';
        }

        // Si está logueado y en una página pública, redirige a home
        if (loggedIn &&
            (location == '/login' ||
                location == '/register' ||
                location == '/')) {
          return '/home';
        }

        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _authProvider,
      child: MaterialApp.router(
        title: 'Flutter Joseph',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Poppins',
          scaffoldBackgroundColor: Colors.white,
        ),
        routerConfig: _goRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
