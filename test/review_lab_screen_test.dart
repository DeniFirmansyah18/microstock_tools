import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';
import 'package:microstock_tools/core/theme/app_typography.dart';
import 'package:microstock_tools/features/auth/providers/auth_provider.dart';
import 'package:microstock_tools/features/review_lab/screens/review_lab_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  AppTypography.useSystemFonts = true;

  testWidgets('ReviewLabScreen renders inspection status, metadata, and export actions', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final image = img.Image(width: 100, height: 100);
    img.fill(image, color: img.ColorRgb8(240, 180, 100));
    final testBytes = Uint8List.fromList(img.encodeJpg(image));

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => AuthProvider(isTesting: true),
          child: ReviewLabScreen(
            imageBytes: testBytes,
            prompt: 'Artisan cupcake dessert on glass pedestal',
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Tab Bar
    expect(find.text('Quality Check'), findsOneWidget);
    expect(find.text('Upscale'), findsOneWidget);
    expect(find.text('Metadata'), findsOneWidget);
    expect(find.text('Export'), findsOneWidget);

    // Verify Inspection Card
    expect(find.textContaining('AI Defect Check Passed'), findsOneWidget);

    // Verify Adobe Stock Compliance Details
    expect(find.textContaining('Adobe Stock Compliance'), findsOneWidget);

    // Verify Action Bar
    expect(find.text('Download IPTC JPEG'), findsOneWidget);
  });
}
