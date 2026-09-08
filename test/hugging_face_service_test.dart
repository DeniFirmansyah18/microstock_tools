import 'package:flutter_test/flutter_test.dart';
import 'package:microstock_tools/features/generator/services/hugging_face_service.dart';

void main() {
  group('HuggingFaceService', () {
    final service = HuggingFaceService(token: 'hf_test_mock_token');

    test('generateImage generates mock JPEG in mock mode', () async {
      final bytes = await service.generateImage(
        prompt: 'Minimalist flat vector icon of an apple',
        forceMock: true,
      );

      expect(bytes, isNotNull);
      expect(bytes.length, greaterThan(100));
      // Verify valid JPEG magic bytes
      expect(bytes[0], 0xFF);
      expect(bytes[1], 0xD8);
    });
  });
}
