import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:microstock_tools/core/utils/exif_iptc_writer.dart';

void main() {
  group('ExifIptcWriter', () {
    late Uint8List sourceJpeg;

    setUp(() {
      final image = img.Image(width: 80, height: 80);
      img.fill(image, color: img.ColorRgb8(200, 100, 50));
      sourceJpeg = Uint8List.fromList(img.encodeJpg(image));
    });

    test('injects IPTC App13 and XMP App1 into JPEG without corrupting image', () {
      final injected = ExifIptcWriter.injectMetadata(
        jpegBytes: sourceJpeg,
        title: 'Futuristic Isometric Cyberpunk City Illustration',
        keywords: [
          'isometric',
          'cyberpunk',
          'city',
          'neon',
          'future',
          '3d illustration',
        ],
        category: 'Graphic Resources',
        description: 'Modern 3d rendered cyberpunk scene for microstock.',
      );

      // Must start with SOI and end with EOI
      expect(injected[0], 0xFF);
      expect(injected[1], 0xD8);
      expect(injected[injected.length - 2], 0xFF);
      expect(injected[injected.length - 1], 0xD9);

      // Must decode successfully as valid image
      final decoded = img.decodeJpg(injected);
      expect(decoded, isNotNull);
      expect(decoded!.width, 80);
      expect(decoded.height, 80);

      // Must contain IPTC and XMP marker signatures
      final binaryString = String.fromCharCodes(injected);
      expect(binaryString.contains('Photoshop 3.0'), isTrue);
      expect(binaryString.contains('Futuristic Isometric Cyberpunk City Illustration'), isTrue);
      expect(binaryString.contains('http://ns.adobe.com/xap/1.0/'), isTrue);
      expect(binaryString.contains('isometric'), isTrue);
      expect(binaryString.contains('Graphic Resources'), isTrue);
    });

    test('parses embedded metadata back accurately', () {
      final injected = ExifIptcWriter.injectMetadata(
        jpegBytes: sourceJpeg,
        title: 'Minimalist Coffee Cup On Pastel Background',
        keywords: ['coffee', 'cup', 'minimalist', 'pastel', 'drink'],
        category: 'Drinks',
      );

      final parsed = ExifIptcWriter.readMetadata(injected);
      expect(parsed.title, 'Minimalist Coffee Cup On Pastel Background');
      expect(parsed.keywords, containsAll(['coffee', 'cup', 'minimalist', 'pastel', 'drink']));
      expect(parsed.category, 'Drinks');
    });
  });
}
