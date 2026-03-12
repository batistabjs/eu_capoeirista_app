import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/events_list_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa formatação de datas em pt_BR
  await initializeDateFormatting('pt_BR', null);

  // Inicializa o AuthService (tenta sign-in silencioso)
  await AuthService().initialize();

  runApp(const GoogleCalendarApp());
}

class GoogleCalendarApp extends StatelessWidget {
  const GoogleCalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eu Capoeirista',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const AppRouter(),
    );
  }
}

class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _authService.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    _authService.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_authService.isLoading) {
      return const _SplashScreen();
    }

    if (_authService.isAuthenticated) {
      return const EventsListScreen();
    }

    return const LoginScreen();
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentBlue.withOpacity(0.15),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.calendar_month_outlined,
                color: AppTheme.accentBlue,
                size: 32,
              ),
            ),
            const SizedBox(height: 24),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: AppTheme.accentBlue,
                strokeWidth: 2,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Carregando...',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
