/// Represents a trending visual style or high-demand keyword cluster on Adobe Stock
class TrendItem {
  final String id;
  final String title;
  final String creatorHandle;
  final String category;
  final String searchVolumeDemand;
  final List<String> tags;
  final String recommendedPrompt;
  final String iconType;
  final int accentColorHex;

  /// Maps this trend to a specific style preset chip in PromptStudioScreen.
  /// Must match one of: '3D Isometric', 'Clay Style', 'Artisan Food',
  /// 'Clean Vector', 'Paper Cutout', 'Cinematic Studio'.
  final String? stylePreset;

  const TrendItem({
    required this.id,
    required this.title,
    required this.creatorHandle,
    required this.category,
    required this.searchVolumeDemand,
    required this.tags,
    required this.recommendedPrompt,
    this.iconType = 'sphere',
    this.accentColorHex = 0xFF2563EB,
    this.stylePreset,
  });
}
