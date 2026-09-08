import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:microstock_tools/core/utils/adobe_validator.dart';
import 'package:microstock_tools/core/utils/exif_iptc_writer.dart';
import 'package:microstock_tools/core/utils/image_upscaler.dart';
import 'package:microstock_tools/features/auth/models/user_profile.dart';
import 'package:microstock_tools/features/auth/providers/auth_provider.dart';
import 'package:microstock_tools/features/generator/services/gemini_service.dart';
import 'package:microstock_tools/features/generator/services/imagen_service.dart';
import 'package:microstock_tools/features/trends/repositories/trend_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End Contributor Pipeline Test', () {
    test(
      'full flow: Auth -> Trends -> Prompt -> Generate -> Inspect -> Upscale -> IPTC Inject',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        // 1. Authenticate user
        final auth = AuthProvider(isTesting: true);
        await auth.signInWithGoogle(); // isTesting mode uses built-in mock data
        await auth.setGeminiApiKey('AIzaSyMockKeyForVerification', isPro: true);

        expect(auth.isLoggedIn, isTrue);
        expect(auth.currentTier, UserTier.pro);

        // 2. Select trending niche from Adobe Stock
        final trendRepo = TrendRepository();
        final trends = trendRepo.getCuratedTrends();
        expect(trends.isNotEmpty, isTrue);

        final selectedTrend = trends.first;
        expect(selectedTrend.title, 'Habit wall');

        // 3. Formulate prompt & ideas via Gemini
        final gemini = GeminiService(apiKey: auth.apiKey);
        final ideas = await gemini.generatePromptIdeas(
          niche: selectedTrend.tags.first,
          forceMock: true,
        );
        expect(ideas.isNotEmpty, isTrue);

        final finalPrompt = ideas.first;

        // 4. Generate image with Imagen 3
        final imagen = ImagenService(apiKey: auth.apiKey);
        final generatedBytes = await imagen.generateImage(
          prompt: finalPrompt,
          forceMock: true,
        );
        expect(generatedBytes.isNotEmpty, isTrue);

        // 5. Inspect AI defects
        final defectReport = await gemini.inspectDefects(
          imageBytes: generatedBytes,
          forceMock: true,
        );
        expect(defectReport.passed, isTrue);
        expect(defectReport.isWatermarkFree, isTrue);
        expect(defectReport.anatomyIntegrityScore, greaterThanOrEqualTo(90));

        // 6. Generate Adobe Stock metadata (Title, Category, Keywords)
        final metadata = await gemini.generateMetadata(
          prompt: finalPrompt,
          imageBytes: generatedBytes,
          forceMock: true,
        );
        expect(metadata.title.isNotEmpty, isTrue);
        expect(metadata.category.isNotEmpty, isTrue);
        expect(metadata.keywords.length, greaterThanOrEqualTo(30));

        // 7. High-Fidelity Upscale to ensure Adobe Stock 4MP-100MP compliance
        final upscaledBytes = await ImageUpscaler.upscaleByFactor(
          bytes: generatedBytes,
          factor: 2.0, // 2048x2048 -> 4096x4096 (16.77 MP)
          algorithm: UpscaleAlgorithm.linear,
        );

      final decoded = img.decodeJpg(upscaledBytes);
      expect(decoded, isNotNull);
      expect(decoded!.width, 4096);
      expect(decoded.height, 4096);

      // 8. Inject binary IPTC Core & XMP metadata directly into JPEG stream
      final finalStockReadyBytes = ExifIptcWriter.injectMetadata(
        jpegBytes: upscaledBytes,
        title: metadata.title,
        keywords: metadata.keywords,
        category: metadata.category,
        description: finalPrompt,
      );

      // 9. Final technical validation against official Adobe Stock rules
      final validation = AdobeValidator.validate(
        width: decoded.width,
        height: decoded.height,
        byteLength: finalStockReadyBytes.length,
      );

      expect(validation.isValid, isTrue);
      expect(validation.megapixels, closeTo(16.78, 0.05)); // >= 4.0 MP
      expect(validation.fileSizeMB, lessThan(45.0)); // < 45 MB
      expect(validation.errors, isEmpty);

      // 10. Verify embedded IPTC/XMP tags read back correctly
      final readBack = ExifIptcWriter.readMetadata(finalStockReadyBytes);
      expect(readBack.title, metadata.title);
      expect(readBack.category, metadata.category);
      expect(readBack.keywords.isNotEmpty, isTrue);
    });
  });
}
