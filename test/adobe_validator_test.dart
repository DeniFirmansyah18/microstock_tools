import 'package:flutter_test/flutter_test.dart';
import 'package:microstock_tools/core/utils/adobe_validator.dart';

void main() {
  group('AdobeValidator', () {
    test('rejects image below 4 Megapixels', () {
      // 1024 x 1024 = 1.048 MP (< 4.0 MP)
      final result = AdobeValidator.validate(
        width: 1024,
        height: 1024,
        byteLength: 1024 * 500, // 500 KB
      );

      expect(result.isValid, isFalse);
      expect(result.megapixels, closeTo(1.05, 0.02));
      expect(result.errors.any((e) => e.contains('4 MP')), isTrue);
    });

    test('accepts image between 4MP and 100MP under 45MB', () {
      // 2048 x 2048 = 4.194 MP (>= 4.0 MP)
      final result = AdobeValidator.validate(
        width: 2048,
        height: 2048,
        byteLength: 2 * 1024 * 1024, // 2 MB
      );

      expect(result.isValid, isTrue);
      expect(result.megapixels, closeTo(4.19, 0.02));
      expect(result.errors, isEmpty);
    });

    test('accepts upscaled high-res image (e.g. 4096 x 4096 = 16.77 MP)', () {
      final result = AdobeValidator.validate(
        width: 4096,
        height: 4096,
        byteLength: 8 * 1024 * 1024, // 8 MB
      );

      expect(result.isValid, isTrue);
      expect(result.megapixels, closeTo(16.78, 0.05));
    });

    test('rejects image exceeding 45 MB ceiling', () {
      final result = AdobeValidator.validate(
        width: 4096,
        height: 4096,
        byteLength: 46 * 1024 * 1024, // 46 MB
      );

      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.contains('45 MB')), isTrue);
    });

    test('rejects image exceeding 100 Megapixels', () {
      // 11000 x 10000 = 110 MP
      final result = AdobeValidator.validate(
        width: 11000,
        height: 10000,
        byteLength: 20 * 1024 * 1024,
      );

      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.contains('100 MP')), isTrue);
    });
  });
}
