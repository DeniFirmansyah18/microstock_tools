import 'package:flutter_test/flutter_test.dart';
import 'package:microstock_tools/features/metadata/adobe_csv_exporter.dart';

void main() {
  group('AdobeCsvExporter', () {
    test('generates valid RFC 4180 Adobe Stock metadata CSV', () {
      final records = [
        AdobeAssetRecord(
          filename: 'illustration_001.jpg',
          title: '3D Isometric Modern Smartphone Concept',
          keywords: ['3d', 'isometric', 'smartphone', 'mobile', 'technology', 'ui'],
          category: 'Technology',
        ),
        AdobeAssetRecord(
          filename: 'illustration_002.jpg',
          title: 'Organic Green Smoothie in Glass Bottle, Healthy',
          keywords: ['smoothie', 'green', 'healthy', 'organic', 'drink'],
          category: 'Drinks',
        ),
      ];

      final csv = AdobeCsvExporter.generateCsv(records);

      expect(csv, startsWith('Filename,Title,Keywords,Category'));
      expect(csv.contains('illustration_001.jpg'), isTrue);
      expect(csv.contains('"3D Isometric Modern Smartphone Concept"'), isTrue);
      expect(csv.contains('"3d, isometric, smartphone, mobile, technology, ui"'), isTrue);
      expect(csv.contains('Technology'), isTrue);
      // Ensure proper newline separation
      final lines = csv.trim().split('\n');
      expect(lines.length, 3); // Header + 2 rows
    });
  });
}
