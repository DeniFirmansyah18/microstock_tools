import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:microstock_tools/core/theme/app_typography.dart';
import 'package:microstock_tools/features/auth/providers/auth_provider.dart';
import 'package:microstock_tools/features/trends/repositories/trend_repository.dart';
import 'package:microstock_tools/features/trends/screens/home_trends_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  AppTypography.useSystemFonts = true;

  testWidgets('HomeTrendsScreen renders Home title, trend cards, and floating dock', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider(isTesting: true)),
            Provider(create: (_) => TrendRepository()),
          ],
          child: const HomeTrendsScreen(),
        ),
      ),
    );

    // Verify header
    expect(find.text('Highlight'), findsOneWidget);
    expect(find.text('Home'), findsNWidgets(2));

    // Verify curated trend cards from reference Screen 3
    expect(find.text('Habit wall'), findsOneWidget);
    expect(find.text('Step counter grid'), findsOneWidget);
    expect(find.text('Talk to books'), findsOneWidget);

    // Verify creator handles
    expect(find.text('@lenny'), findsOneWidget);
    expect(find.text('@joonas'), findsOneWidget);
    expect(find.text('@blasto'), findsOneWidget);

    // Verify floating dock
    expect(find.byKey(const Key('floating_dock')), findsOneWidget);
    expect(find.byKey(const Key('dock_add_button')), findsOneWidget);
  });
}
