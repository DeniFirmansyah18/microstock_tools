import 'package:flutter_test/flutter_test.dart';
import 'package:microstock_tools/features/generator/services/gemini_service.dart';

void main() {
  group('Prompt Reasoning Engine', () {
    final service = GeminiService(apiKey: 'MOCK_API_KEY');

    test('enhancePromptWithReasoning expands short prompt with stock criteria',
        () async {
      final enhanced = await service.enhancePromptWithReasoning(
        rawPrompt: 'kucing barista kopi di kafe',
        stylePreset: '3D Isometric',
        forceMock: true,
      );

      expect(enhanced, isNotEmpty);
      expect(enhanced, contains('3D Isometric'));
      expect(enhanced, contains('commercial stock illustration'));
      expect(enhanced, contains('lighting'));
      expect(enhanced, contains('no text'));
      expect(enhanced, contains('no watermarks'));
    });

    test('enhancePromptWithReasoning works with different style presets',
        () async {
      final enhanced = await service.enhancePromptWithReasoning(
        rawPrompt: 'fresh artisan sourdough bread',
        stylePreset: 'Artisan Food',
        forceMock: true,
      );

      expect(enhanced, contains('Artisan Food'));
      expect(enhanced, contains('clean background'));
    });
  });
}
