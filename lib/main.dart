import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/home_screen.dart';
import 'core/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://xjsmaxhzdqvrzqkyuzmj.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhqc21heGh6ZHF2cnpxa3l1em1qIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI1NDUzODIsImV4cCI6MjA4ODEyMTM4Mn0.zu0RtGdyYI7f6xWt3sxPbMME3OXhwBY1TH6EGvjkFpY',
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
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
      initialLocation: authProvider.isAuthenticated ? '/home' : '/login',
      redirect: (context, state) {
        final authenticated = authProvider.isAuthenticated;
        final isLoggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/otp';

        if (!authenticated && !isLoggingIn) return '/login';
        if (authenticated && isLoggingIn) return '/home';
        return null;
      },
      routes: [
        GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
        GoRoute(path: '/otp', builder: (context, state) => const OtpScreen()),
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MoneyBic',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          surface: AppColors.surface,
          onSurface: AppColors.text,
        ),
      ),
    );
  }
}
