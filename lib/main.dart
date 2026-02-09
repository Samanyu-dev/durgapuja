import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'firebase_options.dart';
import 'utils/colors.dart';
import 'router.dart';
import 'providers/auth_provider.dart';
import 'l10n/app_localizations.dart';
import 'services/logging_service.dart';
import 'services/language_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize logging service
  LoggingService.initialize();
  
  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
    LoggingService.logInfo('Environment variables loaded successfully');
  } catch (e) {
    LoggingService.logError('Failed to load environment variables: $e');
  }

  // Initialize Firebase with error handling
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    LoggingService.logInfo('Firebase initialized successfully');
  } catch (e) {
    LoggingService.logError('Firebase initialization failed: $e');
    // Don't crash the app, continue in test mode
  }

  // Set up error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    LoggingService.logError('Flutter Error: ${details.exception}');
    FlutterError.presentError(details);
  };

  // Set up unhandled exception handling
  PlatformDispatcher.instance.onError = (error, stack) {
    LoggingService.logError('Unhandled Exception: $error\nStack: $stack');
    return true;
  };

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LanguageService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        final isBn = languageService.currentLanguage == AppLanguage.bn;

        return MaterialApp.router(
          title: 'Durga Idol Maker',
          theme: ThemeData(
            primaryColor: AppColors.primaryBrown,
            useMaterial3: true,
            scaffoldBackgroundColor: AppColors.backgroundCream,
          ),
          locale: isBn ? const Locale('bn') : const Locale('en'),
          supportedLocales: const [
            Locale('en'),
            Locale('bn'),
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: router,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

