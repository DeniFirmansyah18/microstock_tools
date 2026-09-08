import 'package:flutter_test/flutter_test.dart';
import 'package:microstock_tools/features/generator/services/pollinations_service.dart';

void main() {
  group('PollinationsService', () {
    final service = PollinationsService();

    test('generateImage generates mock JPEG in mock mode', () async {
      final bytes = await service.generateImage(
        prompt: 'Isometric cozy coffee shop illustration',
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
