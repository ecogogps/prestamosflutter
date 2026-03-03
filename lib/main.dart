
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:myapp/providers/auth_provider.dart';
import 'package:myapp/screens/login_screen.dart';
import 'package:myapp/screens/otp_screen.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/core/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://xjsmaxhzdqvrzqkyuzmj.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhqc21heGh6ZHF2cnpxa3l1em1qIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI1NDUzODIsImV4cCI6MjA4ODEyMTM4Mn0.zu0RtGdyYI7f6xWt3sxPbMME3OXhwBY1TH6EGvjkFpY',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
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
      initialLocation: '/login',
      redirect: (context, state) {
        final isAuthenticated = authProvider.isAuthenticated;
        final isLoggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/otp';

        if (!isAuthenticated && !isLoggingIn) {
          return '/login';
        }
        if (isAuthenticated && isLoggingIn) {
          return '/home';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/otp',
          builder: (context, state) {
            // Extraer el número de teléfono de los parámetros de consulta
            final phone = state.uri.queryParameters['phone'] ?? '';
            return OtpScreen(phoneNumber: phone);
          },
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MoneyBic',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.primary,
          surface: const Color(0细2C3136),
        ),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}
