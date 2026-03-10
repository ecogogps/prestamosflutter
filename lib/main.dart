import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/home_screen.dart';
import 'screens/solicitar_screen.dart';
import 'screens/prestamos_screen.dart';
import 'screens/perfil_screen.dart';
import 'screens/loan_details_screen.dart';
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    final GoRouter router = GoRouter(
      initialLocation: authProvider.isAuthenticated ? '/' : '/login',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final bool loggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/otp';
        if (!authProvider.isAuthenticated) {
          return loggingIn ? null : '/login';
        }
        if (loggingIn) {
          return '/';
        }
        return null;
      },
      routes: [
        ShellRoute(
          builder: (context, state, child) {
            return Scaffold(
              body: child,
              bottomNavigationBar: state.matchedLocation == '/login' || state.matchedLocation == '/otp' || state.matchedLocation.startsWith('/loan-details')
                  ? null
                  : SafeArea(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF181B1F),
                          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
                        ),
                        child: NavigationBar(
                          backgroundColor: Colors.transparent,
                          indicatorColor: const Color(0xFF71AF57).withOpacity(0.2),
                          selectedIndex: _getSelectedIndex(state.matchedLocation),
                          onDestinationSelected: (index) {
                            switch (index) {
                              case 0: context.go('/'); break;
                              case 1: context.go('/prestamos'); break;
                              case 2: context.go('/perfil'); break;
                            }
                          },
                          destinations: const [
                            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: Color(0xFF71AF57)), label: 'Inicio'),
                            NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet, color: Color(0xFF71AF57)), label: 'Préstamos'),
                            NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person, color: Color(0xFF71AF57)), label: 'Perfil'),
                          ],
                        ),
                      ),
                    ),
            );
          },
          routes: [
            GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
            GoRoute(path: '/prestamos', builder: (context, state) => const PrestamosScreen()),
            GoRoute(path: '/perfil', builder: (context, state) => const PerfilScreen()),
          ],
        ),
        GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
        GoRoute(
          path: '/otp',
          builder: (context, state) {
            final phone = state.uri.queryParameters['phone'] ?? '';
            return OtpScreen(phoneNumber: phone);
          },
        ),
        GoRoute(path: '/solicitar', builder: (context, state) => const SolicitarScreen()),
        GoRoute(
          path: '/loan-details',
          builder: (context, state) {
            final loan = state.extra as Map<String, dynamic>;
            return LoanDetailsScreen(loan: loan);
          },
        ),
      ],
    );

    return MaterialApp.router(
      title: 'MoneyBic',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF71AF57),
        scaffoldBackgroundColor: const Color(0xFF181B1F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF71AF57),
          brightness: Brightness.dark,
          primary: const Color(0xFF71AF57),
        ),
      ),
      routerConfig: router,
    );
  }

  int _getSelectedIndex(String location) {
    if (location == '/') return 0;
    if (location == '/prestamos') return 1;
    if (location == '/perfil') return 2;
    return 0;
  }
}