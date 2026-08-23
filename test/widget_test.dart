import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:durgapuja/main.dart';
import 'package:durgapuja/providers/auth_provider.dart';
import 'package:durgapuja/providers/locale_provider.dart';
import 'package:durgapuja/services/language_service.dart';

void main() {
  testWidgets('App smoke test - renders without crashing', (WidgetTester tester) async {
    // Build the app with required providers
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider(testMode: true)),
          ChangeNotifierProvider(create: (_) => LanguageService()),
        ],
        child: const MyApp(),
      ),
    );

    // Wait for any async initialization
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verify the app renders by checking for MaterialApp
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('App shows debug banner disabled', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider(testMode: true)),
          ChangeNotifierProvider(create: (_) => LanguageService()),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 2));

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.debugShowCheckedModeBanner, isFalse);
  });
}
