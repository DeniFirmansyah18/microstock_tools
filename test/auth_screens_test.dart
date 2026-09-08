import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:microstock_tools/core/theme/app_typography.dart';
import 'package:microstock_tools/features/auth/providers/auth_provider.dart';
import 'package:microstock_tools/features/auth/screens/splash_screen.dart';
import 'package:microstock_tools/features/auth/screens/welcome_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  AppTypography.useSystemFonts = true;

  group('Auth Screens Widget Tests', () {
    testWidgets('SplashScreen renders Highlight badge and brand icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => AuthProvider(isTesting: true),
            child: const SplashScreen(autoNavigate: false),
          ),
        ),
      );

      expect(find.text('Highlight'), findsOneWidget);
      expect(find.byKey(const Key('splash_brand_logo')), findsOneWidget);
    });

    testWidgets('WelcomeScreen renders headline and Google/Apple action buttons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => AuthProvider(isTesting: true),
            child: const WelcomeScreen(),
          ),
        ),
      );

      expect(find.text('Highlight'), findsOneWidget);
      expect(find.textContaining('Meet StockCraft'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Continue with Apple'), findsOneWidget);
    });
  });
}
