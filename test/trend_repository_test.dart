import 'package:flutter_test/flutter_test.dart';
import 'package:microstock_tools/core/constants/adobe_categories.dart';
import 'package:microstock_tools/features/trends/repositories/trend_repository.dart';

void main() {
  group('AdobeCategories', () {
    test('contains exact 21 official Adobe Stock categories', () {
      expect(AdobeCategories.list.length, 21);
      expect(AdobeCategories.list, contains('Graphic Resources'));
      expect(AdobeCategories.list, contains('Technology'));
      expect(AdobeCategories.list, contains('Business'));
      expect(AdobeCategories.list, contains('Food'));
      expect(AdobeCategories.list, contains('Animals'));
    });

    test('validates valid category accurately', () {
      expect(AdobeCategories.isValid('Graphic Resources'), isTrue);
      expect(AdobeCategories.isValid('NonExistentCategory'), isFalse);
    });
  });

  group('TrendRepository', () {
    final repo = TrendRepository();

    test('provides curated trending styles for Adobe Stock', () {
      final trends = repo.getCuratedTrends();
      expect(trends.length, greaterThanOrEqualTo(5));

      final first = trends.first;
      expect(first.title, isNotEmpty);
      expect(first.creatorHandle, startsWith('@'));
      expect(first.searchVolumeDemand, isNotEmpty);
      expect(first.tags, isNotEmpty);
      expect(first.recommendedPrompt, isNotEmpty);
    });

    test('filters trends by keyword/niche', () {
      final filtered = repo.searchTrends('isometric');
      expect(filtered.any((t) => t.title.toLowerCase().contains('isometric') || t.tags.contains('isometric')), isTrue);
    });
  });
}
