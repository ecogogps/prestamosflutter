
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/core/app_colors.dart';
import 'package:myapp/providers/auth_provider.dart';
import 'package:myapp/screens/login_screen.dart';
import 'package:myapp/screens/otp_screen.dart';
import 'package:myapp/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://xjsmaxhzdqvrzqkyuzmj.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhqc21heGh6ZHF2cnpxa3l1em1qIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI1NDUzODIsImV4cCI6MjA4ODEyMTM4Mn0.zu0RtGdyYI7f6xWt3sxPbMME3OXhwBY1TH6EGvjkFpY',
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthProvider _authProvider;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider();
    
    _router = GoRouter(
      refreshListenable: _authProvider,
      initialLocation: '/',
      redirect: (context, state) {
        final bool loggedIn = _authProvider.isAuthenticated;
        final bool loggingIn = state.matchedLocation == '/';
        final bool verifyingOtp = state.matchedLocation == '/otp';

        if (!loggedIn) {
          if (!loggingIn && !verifyingOtp) return '/';
          return null;
        }

        if (loggingIn || verifyingOtp) return '/home';

        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/otp',
          builder: (context, state) {
            final phoneNumber = state.uri.queryParameters['phone'] ?? '';
            return OtpScreen(phoneNumber: phoneNumber);
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
    return ChangeNotifierProvider.value(
      value: _authProvider,
      child: MaterialApp.router(
        title: 'MoneyBic',
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            onPrimary: Colors.black,
            surface: Color(0xFF2C3136),
            onSurface: AppColors.text,
            background: AppColors.background,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF2C3136),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            hintStyle: const TextStyle(color: Colors.white54),
          ),
        ),
      ),
    );
  }
}
