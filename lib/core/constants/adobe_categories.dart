/// The official 21 standard categories accepted by Adobe Stock Contributor Portal
class AdobeCategories {
  static const List<String> list = [
    'Animals',
    'Buildings and Architecture',
    'Business',
    'Drinks',
    'Environment',
    'States of Mind',
    'Food',
    'Graphic Resources',
    'Hobbies and Leisure',
    'Industry',
    'Landscapes',
    'Lifestyle',
    'People',
    'Plants and Flowers',
    'Culture and Religion',
    'Science',
    'Social Issues',
    'Sports',
    'Technology',
    'Transport',
    'Travel',
  ];

  static bool isValid(String category) {
    return list.any((c) => c.toLowerCase() == category.trim().toLowerCase());
  }

  /// Automatically matches a prompt or topic string to the most relevant Adobe Stock category
  static String matchCategory(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('dog') || lower.contains('cat') || lower.contains('animal') || lower.contains('pet') || lower.contains('wildlife') || lower.contains('bird')) {
      return 'Animals';
    }
    if (lower.contains('tech') || lower.contains('robot') || lower.contains('cyber') || lower.contains('computer') || lower.contains('ai') || lower.contains('phone') || lower.contains('app')) {
      return 'Technology';
    }
    if (lower.contains('building') || lower.contains('architecture') || lower.contains('house') || lower.contains('city') || lower.contains('office room')) {
      return 'Buildings and Architecture';
    }
    if (lower.contains('food') || lower.contains('cake') || lower.contains('bread') || lower.contains('fruit') || lower.contains('meal') || lower.contains('restaurant')) {
      return 'Food';
    }
    if (lower.contains('drink') || lower.contains('coffee') || lower.contains('tea') || lower.contains('smoothie') || lower.contains('beverage') || lower.contains('cocktail')) {
      return 'Drinks';
    }
    if (lower.contains('flower') || lower.contains('plant') || lower.contains('tree') || lower.contains('garden') || lower.contains('leaf')) {
      return 'Plants and Flowers';
    }
    if (lower.contains('office') || lower.contains('meeting') || lower.contains('finance') || lower.contains('money') || lower.contains('market') || lower.contains('business')) {
      return 'Business';
    }
    if (lower.contains('vector') || lower.contains('icon') || lower.contains('isometric') || lower.contains('pattern') || lower.contains('background') || lower.contains('texture') || lower.contains('illustration')) {
      return 'Graphic Resources';
    }
    if (lower.contains('person') || lower.contains('people') || lower.contains('woman') || lower.contains('man') || lower.contains('team') || lower.contains('worker')) {
      return 'People';
    }
    if (lower.contains('travel') || lower.contains('vacation') || lower.contains('holiday') || lower.contains('beach') || lower.contains('airport')) {
      return 'Travel';
    }
    if (lower.contains('nature') || lower.contains('mountain') || lower.contains('landscape') || lower.contains('forest') || lower.contains('sea')) {
      return 'Landscapes';
    }

    return 'Graphic Resources';
  }
}
