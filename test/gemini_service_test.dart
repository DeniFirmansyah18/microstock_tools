import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:microstock_tools/features/generator/services/gemini_service.dart';
import 'package:microstock_tools/features/generator/services/imagen_service.dart';

void main() {
  group('GeminiService', () {
    final service = GeminiService(apiKey: 'MOCK_API_KEY');

    test('generates prompt ideas in mock/fallback mode', () async {
      final ideas = await service.generatePromptIdeas(
        niche: '3D Isometric Business',
        forceMock: true,
      );

      expect(ideas.length, greaterThanOrEqualTo(3));
      expect(ideas.first, contains('3D'));
    });

    test('inspectDefects checks anatomy, focus, and watermarks', () async {
      final fakeBytes = Uint8List.fromList([1, 2, 3, 4]);
      final report = await service.inspectDefects(
        imageBytes: fakeBytes,
        forceMock: true,
      );

      expect(report.passed, isTrue);
      expect(report.anatomyIntegrityScore, greaterThanOrEqualTo(90));
      expect(report.isWatermarkFree, isTrue);
      expect(report.isFocusSharp, isTrue);
    });

    test('generateMetadata produces compliant title, valid category, and ranked keywords', () async {
      final fakeBytes = Uint8List.fromList([1, 2, 3, 4]);
      final meta = await service.generateMetadata(
        prompt: 'Cute 3D isometric robot working on laptop',
        imageBytes: fakeBytes,
        forceMock: true,
      );

      expect(meta.title, isNotEmpty);
      expect(meta.category, isNotEmpty);
      expect(meta.keywords.length, greaterThanOrEqualTo(30));
      // Top 5 keywords should be highly relevant
      expect(meta.keywords, contains('3d'));
      expect(meta.keywords, contains('robot'));
    });
  });

  group('ImagenService', () {
    final imagen = ImagenService(apiKey: 'MOCK_API_KEY');

    test('generateImage creates JPEG bytes in mock mode', () async {
      final bytes = await imagen.generateImage(
        prompt: 'High resolution vector icon of a golden trophy',
        forceMock: true,
      );

      expect(bytes, isNotNull);
      expect(bytes.length, greaterThan(100));
      // Valid JPEG header
      expect(bytes[0], 0xFF);
      expect(bytes[1], 0xD8);
    });
  });
}
