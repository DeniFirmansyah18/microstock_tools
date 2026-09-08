import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:microstock_tools/core/theme/app_typography.dart';
import 'package:microstock_tools/features/auth/providers/auth_provider.dart';
import 'package:microstock_tools/features/generator/screens/prompt_studio_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  AppTypography.useSystemFonts = true;

  testWidgets('PromptStudioScreen renders Mood Board card, Glossy Orb, and prompt bar', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => AuthProvider(isTesting: true),
          child: const PromptStudioScreen(),
        ),
      ),
    );

    // Verify Screen 4 components matching reference
    expect(find.text('Highlight'), findsOneWidget);
    expect(find.text('Artistic Mood Board'), findsOneWidget);
    expect(find.text('A digital space for collaging and inspiration.'), findsOneWidget);
    expect(find.text('Because you thrive on creativity and self-expression.'), findsOneWidget);
    expect(find.text('Refresh Ideas'), findsOneWidget);

    // Verify 3D Glossy Orb centerpiece
    expect(find.byKey(const Key('glossy_orb_widget')), findsOneWidget);

    // Verify floating prompt bar
    expect(find.text('What should we make?'), findsOneWidget);
  });
}
