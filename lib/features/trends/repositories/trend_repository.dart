import '../models/trend_item.dart';

class TrendRepository {
  static final List<TrendItem> _curatedTrends = [
    const TrendItem(
      id: 'trend_habit_wall',
      title: 'Habit wall',
      creatorHandle: '@lenny',
      category: 'Graphic Resources',
      searchVolumeDemand: '+185% demand',
      tags: ['habit tracker', 'clay', 'minimalist', 'ui card', 'gamification'],
      recommendedPrompt: 'Cute 3D isometric clay habit tracking cards on a clean white background, soft ambient shadows, minimalist aesthetic, commercial stock illustration',
      iconType: 'avatar',
      accentColorHex: 0xFFF59E0B,
      stylePreset: 'Clay Style',
    ),
    const TrendItem(
      id: 'trend_step_counter',
      title: 'Step counter grid',
      creatorHandle: '@joonas',
      category: 'Technology',
      searchVolumeDemand: '+142% demand',
      tags: ['isometric', 'step counter', 'fitness grid', '3d mosaic', 'colorful'],
      recommendedPrompt: '3D colorful isometric mosaic step counter tiles, vibrant red and green gradient cubes, clean product UI presentation, soft lighting',
      iconType: 'grid',
      accentColorHex: 0xFFEF4444,
      stylePreset: '3D Isometric',
    ),
    const TrendItem(
      id: 'trend_talk_to_books',
      title: 'Talk to books',
      creatorHandle: '@blasto',
      category: 'Science',
      searchVolumeDemand: '+120% demand',
      tags: ['ai assistant', 'voice orb', 'deep blue', 'glowing sphere', 'future'],
      recommendedPrompt: 'Glossy 3D holographic dark blue sphere with subtle internal neural light reflections, modern AI concept art, studio lighting on pure white background',
      iconType: 'sphere',
      accentColorHex: 0xFF2563EB,
      stylePreset: '3D Isometric',
    ),
    const TrendItem(
      id: 'trend_baking_inspiration',
      title: 'Artisan bakery cake',
      creatorHandle: '@stock_master',
      category: 'Food',
      searchVolumeDemand: '+210% demand',
      tags: ['cake', 'bakery', 'glass cloche', 'dessert', 'cupcake', 'confectionery'],
      recommendedPrompt: 'Delicious artisanal chocolate cupcake on a ceramic white pedestal covered by a vintage glass cloche stand, warm natural side lighting, sharp focus, stock photography quality',
      iconType: 'food',
      accentColorHex: 0xFFD97706,
      stylePreset: 'Artisan Food',
    ),
    const TrendItem(
      id: 'trend_clean_meal_planner',
      title: 'Meal planner recipes',
      creatorHandle: '@nutrition_ai',
      category: 'Lifestyle',
      searchVolumeDemand: '+164% demand',
      tags: ['meal plan', 'healthy food', 'apple', 'diet', 'vegetables', 'clean eating'],
      recommendedPrompt: 'Stylized 3D glossy red apple with fresh green leaf, minimalist meal prep recipe icon, studio lighting, crisp shadows, commercial vector 3d style',
      iconType: 'apple',
      accentColorHex: 0xFF10B981,
      stylePreset: 'Clean Vector',
    ),
    const TrendItem(
      id: 'trend_isometric_smart_city',
      title: 'Sustainable smart city',
      creatorHandle: '@eco_design',
      category: 'Environment',
      searchVolumeDemand: '+135% demand',
      tags: ['solar energy', 'wind turbine', 'green city', 'isometric', 'clean architecture'],
      recommendedPrompt: 'High-detail 3D isometric green smart city with solar panels, electric vehicles, and vertical gardens, bright morning daylight, clean stock vector aesthetic',
      iconType: 'grid',
      accentColorHex: 0xFF059669,
      stylePreset: '3D Isometric',
    ),
  ];

  List<TrendItem> getCuratedTrends() => List.unmodifiable(_curatedTrends);

  List<TrendItem> searchTrends(String query) {
    if (query.trim().isEmpty) return getCuratedTrends();
    final q = query.toLowerCase().trim();
    return _curatedTrends.where((t) {
      return t.title.toLowerCase().contains(q) ||
          t.category.toLowerCase().contains(q) ||
          t.tags.any((tag) => tag.toLowerCase().contains(q));
    }).toList();
  }
}
