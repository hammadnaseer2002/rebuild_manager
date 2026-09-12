import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/project_provider.dart';
import 'providers/rates_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/rates/initial_rates_setup_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RatesProvider()),
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
      ],
      child: MaterialApp(
        title: 'Home Rebuild',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1B5E3B),
            primary: const Color(0xFF1B5E3B),
          ),
          textTheme: GoogleFonts.interTextTheme(),
          scaffoldBackgroundColor: const Color(0xFFF8F9FA),
          useMaterial3: true,
        ),
        home: const _AppStartup(),
      ),
    );
  }
}

/// Loads rates + DB data before deciding which screen to show:
///   • First install (rates not set yet) → InitialRatesSetupScreen
///   • Returning user (rates already saved) → DashboardScreen
class _AppStartup extends StatefulWidget {
  const _AppStartup();

  @override
  State<_AppStartup> createState() => _AppStartupState();
}

class _AppStartupState extends State<_AppStartup> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    // Load rates first, then projects
    await context.read<RatesProvider>().loadRates();
    await context.read<ProjectProvider>().loadProjectsFromDb();
    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    // Splash screen while loading
    if (!_ready) {
      return const Scaffold(
        backgroundColor: Color(0xFF1B5E3B),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.home_work_outlined, color: Colors.white, size: 64),
              SizedBox(height: 16),
              Text(
                'Home Rebuild',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 32),
              CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ],
          ),
        ),
      );
    }

    // Route based on whether the user has set rates before
    final ratesReady = context.read<RatesProvider>().isSetupDone;
    if (ratesReady) {
      return const DashboardScreen();
    } else {
      return const InitialRatesSetupScreen();
    }
  }
}
