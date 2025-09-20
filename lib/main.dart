import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'providers/auth_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/sync_provider.dart';
import 'providers/language_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/api_service.dart';
import 'services/preferences_service.dart';

void main() {
  // Initialize API service
  ApiService().initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => SyncProvider()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return MaterialApp(
            title: 'Family Expense Tracker',
            locale: languageProvider.currentLocale,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''), // English
              Locale('my', ''), // Myanmar
            ],
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            home: const AuthWrapper(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isInitializing = true;
  bool _shouldShowLogin = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      final prefsService = await PreferencesService.getInstance();
      final authProvider = context.read<AuthProvider>();
      
      // Check if user has seen onboarding and chosen offline mode
      final hasSeenOnboarding = await prefsService.hasSeenOnboarding();
      final offlinePreference = await prefsService.getOfflinePreference();
      
      // If user has chosen offline mode, go directly to home
      if (hasSeenOnboarding && offlinePreference) {
        setState(() {
          _shouldShowLogin = false;
          _isInitializing = false;
        });
        return;
      }
      
      // If user is authenticated, go to home
      if (authProvider.isAuthenticated) {
        setState(() {
          _shouldShowLogin = false;
          _isInitializing = false;
        });
        return;
      }
      
      // Otherwise, show login screen
      setState(() {
        _shouldShowLogin = true;
        _isInitializing = false;
      });
    } catch (e) {
      // On error, default to login screen
      setState(() {
        _shouldShowLogin = true;
        _isInitializing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If authenticated, always show home
        if (authProvider.isAuthenticated) {
          return const HomeScreen();
        }

        // If not authenticated but user chose offline mode, show home
        if (!_shouldShowLogin) {
          return const OfflineHomeWrapper();
        }

        // Otherwise show login
        return const LoginScreen();
      },
    );
  }
}
