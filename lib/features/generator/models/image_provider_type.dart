/// Supported image generation providers in StockCraft.
enum ImageProviderType {
  pollinations(
    id: 'pollinations',
    displayName: 'Pollinations AI (FLUX.1)',
    badgeLabel: '100% GRATIS',
    description: 'Gratis tanpa API key & tanpa kartu kredit. Cepat & akurat.',
    isFree: true,
    requiresKey: false,
  ),
  huggingFace(
    id: 'hugging_face',
    displayName: 'Hugging Face (FLUX.1)',
    badgeLabel: 'TOKEN GRATIS',
    description: 'Model FLUX.1-schnell via token Hugging Face gratis.',
    isFree: true,
    requiresKey: true,
  ),
  gemini(
    id: 'gemini',
    displayName: 'Google Gemini (Nano Banana 2)',
    badgeLabel: 'BILLING GOOGLE',
    description: 'Gemini 3.1 Flash Image. Memerlukan Google Cloud billing aktif.',
    isFree: false,
    requiresKey: true,
  );

  final String id;
  final String displayName;
  final String badgeLabel;
  final String description;
  final bool isFree;
  final bool requiresKey;

  const ImageProviderType({
    required this.id,
    required this.displayName,
    required this.badgeLabel,
    required this.description,
    required this.isFree,
    required this.requiresKey,
  });

  static ImageProviderType fromId(String? id) {
    return ImageProviderType.values.firstWhere(
      (e) => e.id == id,
      orElse: () => ImageProviderType.pollinations,
    );
  }
}
