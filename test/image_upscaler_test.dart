import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:microstock_tools/core/utils/image_upscaler.dart';

void main() {
  group('ImageUpscaler', () {
    late Uint8List testJpegBytes;

    setUp(() {
      // Create a simple 100x100 RGB image for testing
      final image = img.Image(width: 100, height: 100);
      img.fill(image, color: img.ColorRgb8(50, 150, 250));
      testJpegBytes = Uint8List.fromList(img.encodeJpg(image));
    });

    test('upscales image to target dimensions and returns valid JPEG', () async {
      final upscaledBytes = await ImageUpscaler.upscale(
        bytes: testJpegBytes,
        targetWidth: 200,
        targetHeight: 200,
      );

      expect(upscaledBytes, isNotNull);
      expect(upscaledBytes.length, greaterThan(0));

      final decoded = img.decodeJpg(upscaledBytes);
      expect(decoded, isNotNull);
      expect(decoded!.width, 200);
      expect(decoded.height, 200);
    });

    test('upscaleFactor multiplies dimensions cleanly', () async {
      final upscaledBytes = await ImageUpscaler.upscaleByFactor(
        bytes: testJpegBytes,
        factor: 2.0, // 100x100 -> 200x200
      );

      final decoded = img.decodeJpg(upscaledBytes);
      expect(decoded!.width, 200);
      expect(decoded.height, 200);
    });
  });
}
