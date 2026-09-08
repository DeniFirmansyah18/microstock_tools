import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/glossy_orb.dart';
import '../../auth/providers/auth_provider.dart';
import '../../review_lab/screens/review_lab_screen.dart';
import '../../trends/models/trend_item.dart';
import '../models/image_provider_type.dart';
import '../services/gemini_service.dart';
import '../services/imagen_service.dart';

/// Screen 4: Prompt Studio & Mood Board Ideation matching reference Screen 4
class PromptStudioScreen extends StatefulWidget {
  final TrendItem? initialTrend;

  const PromptStudioScreen({
    super.key,
    this.initialTrend,
  });

  @override
  State<PromptStudioScreen> createState() => _PromptStudioScreenState();
}

class _PromptStudioScreenState extends State<PromptStudioScreen> {
  final TextEditingController _promptController = TextEditingController();
  List<String> _promptIdeas = [];
  bool _isLoadingIdeas = false;
  bool _isGenerating = false;
  String _selectedStyle = '3D Isometric';

  /// Keeps track of the trend that triggered navigation to this screen.
  /// Used to generate context-aware Gemini prompt ideas.
  TrendItem? _activeTrend;

  final List<String> _stylePresets = [
    '3D Isometric',
    'Clay Style',
    'Artisan Food',
    'Clean Vector',
    'Paper Cutout',
    'Cinematic Studio',
  ];

  @override
  void initState() {
    super.initState();
    final trend = widget.initialTrend;
    if (trend != null) {
      _activeTrend = trend;
      _promptController.text = trend.recommendedPrompt;

      // Smart style selection: prefer explicit stylePreset, then fall back
      // to scanning tags for a known preset name.
      final preset = trend.stylePreset;
      if (preset != null && _stylePresets.contains(preset)) {
        _selectedStyle = preset;
      } else {
        // Fallback: find first tag that matches a known style preset
        final tagMatch = trend.tags.firstWhere(
          (t) => _stylePresets.any(
            (p) => p.toLowerCase().contains(t.toLowerCase()) ||
                t.toLowerCase().contains(p.toLowerCase()),
          ),
          orElse: () => '',
        );
        if (tagMatch.isNotEmpty) {
          final matched = _stylePresets.firstWhere(
            (p) => p.toLowerCase().contains(tagMatch.toLowerCase()) ||
                tagMatch.toLowerCase().contains(p.toLowerCase()),
            orElse: () => _selectedStyle,
          );
          _selectedStyle = matched;
        }
      }
    } else {
      _promptController.text =
          'Delicious artisanal chocolate cupcake on vintage glass cloche stand, warm studio lighting';
    }

    _loadPromptIdeas();
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _loadPromptIdeas() async {
    setState(() => _isLoadingIdeas = true);
    final auth = context.read<AuthProvider>();
    final gemini = GeminiService(apiKey: auth.apiKey);

    // Build a rich niche string so Gemini generates highly relevant ideas.
    // If a trend was selected, combine its title, category, and tags.
    // Otherwise fall back to the selected style chip.
    final String niche;
    if (_activeTrend != null) {
      final t = _activeTrend!;
      niche = '${t.title}, ${t.category}, ${t.tags.join(', ')}';
    } else {
      niche = _selectedStyle;
    }

    final ideas = await gemini.generatePromptIdeas(
      niche: niche,
      forceMock: auth.isTesting || auth.apiKey.isEmpty,
    );

    if (mounted) {
      setState(() {
        _promptIdeas = ideas;
        _isLoadingIdeas = false;
      });
    }
  }

  bool _enableReasoning = true;
  bool _isReasoning = false;
  String _generationStageText = '';

  Future<void> _optimizePromptWithReasoning() async {
    final current = _promptController.text.trim();
    if (current.isEmpty) return;

    final auth = context.read<AuthProvider>();
    setState(() {
      _isReasoning = true;
      _generationStageText = '🧠 Menalar komposisi visual dengan Gemini...';
    });

    final gemini = GeminiService(apiKey: auth.apiKey);
    final optimized = await gemini.enhancePromptWithReasoning(
      rawPrompt: current,
      stylePreset: _selectedStyle,
      forceMock: auth.isTesting,
    );

    if (mounted) {
      setState(() {
        _isReasoning = false;
        _generationStageText = '';
        _promptController.text = optimized;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✨ Prompt berhasil dinalar & dioptimalkan dengan Gemini AI!'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.matteBlack,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _generateImage() async {
    final rawPrompt = _promptController.text.trim();
    if (rawPrompt.isEmpty) return;

    final auth = context.read<AuthProvider>();
    final provider = auth.selectedImageProvider;

    // If provider requires a key that is missing, guide the user
    if (provider == ImageProviderType.huggingFace && auth.hfToken.isEmpty) {
      _showHfTokenSheet();
      return;
    }

    if (provider == ImageProviderType.gemini && auth.apiKey.isEmpty) {
      _showGeminiKeySheet();
      return;
    }

    setState(() {
      _isGenerating = true;
      _generationStageText = _enableReasoning
          ? '🧠 Tahap 1/2: Menalar logika & komposisi visual...'
          : '🎨 Merender gambar stock...';
    });

    String executionPrompt = rawPrompt;

    // Stage 1: Reasoning Brain (Gemini 3.7 Flash)
    if (_enableReasoning) {
      setState(() => _isReasoning = true);
      try {
        final gemini = GeminiService(apiKey: auth.apiKey);
        executionPrompt = await gemini.enhancePromptWithReasoning(
          rawPrompt: rawPrompt,
          stylePreset: _selectedStyle,
          forceMock: auth.isTesting,
        );
      } catch (e) {
        debugPrint('Prompt reasoning exception: $e');
      } finally {
        if (mounted) {
          setState(() {
            _isReasoning = false;
            _generationStageText = '🎨 Tahap 2/2: Merender stock illustration via ${provider.displayName}...';
          });
        }
      }
    }

    // Stage 2: Visual Engine (Pollinations FLUX.1 / HF / Gemini)
    final imagen = ImagenService(
      apiKey: auth.apiKey,
      hfToken: auth.hfToken,
      provider: provider,
    );

    final bytes = await imagen.generateImage(
      prompt: executionPrompt,
      forceMock: auth.isTesting,
    );

    if (mounted) {
      setState(() {
        _isGenerating = false;
        _generationStageText = '';
      });

      if (imagen.fallbackOccurred && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '💡 Gemini memerlukan Google Cloud Billing aktif. '
              'Gambar dialihkan secara otomatis ke Pollinations AI (FLUX) agar tetap tampil sesuai prompt!',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.matteBlack,
            duration: Duration(seconds: 4),
          ),
        );
      }

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ReviewLabScreen(
            imageBytes: bytes,
            prompt: executionPrompt,
          ),
        ),
      );
    }
  }

  void _showProviderSelectionSheet(BuildContext context) {
    final auth = context.read<AuthProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Pilih Model Generator Gambar',
              style: AppTypography.cardTitle,
            ),
            const SizedBox(height: 6),
            Text(
              'Pilih engine AI untuk meng-generate stock illustration:',
              style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ...ImageProviderType.values.map((p) {
              final isSelected = auth.selectedImageProvider == p;
              return GestureDetector(
                onTap: () {
                  auth.setSelectedImageProvider(p);
                  Navigator.pop(ctx);
                  if (p == ImageProviderType.huggingFace && auth.hfToken.isEmpty) {
                    _showHfTokenSheet();
                  } else if (p == ImageProviderType.gemini && auth.apiKey.isEmpty) {
                    _showGeminiKeySheet();
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.surfaceMuted
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppColors.matteBlack : AppColors.borderLight,
                      width: isSelected ? 1.5 : 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: p == ImageProviderType.pollinations
                              ? AppColors.accentGreen.withValues(alpha: 0.12)
                              : p == ImageProviderType.huggingFace
                                  ? Colors.purple.withValues(alpha: 0.12)
                                  : AppColors.accentAmber.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          p == ImageProviderType.pollinations
                              ? Icons.eco_rounded
                              : p == ImageProviderType.huggingFace
                                  ? Icons.smart_toy_rounded
                                  : Icons.bolt_rounded,
                          size: 18,
                          color: p == ImageProviderType.pollinations
                              ? AppColors.accentGreen
                              : p == ImageProviderType.huggingFace
                                  ? Colors.purple
                                  : AppColors.accentAmber,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  p.displayName,
                                  style: AppTypography.cardTitle.copyWith(
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: p.isFree
                                        ? AppColors.accentGreen.withValues(alpha: 0.12)
                                        : AppColors.accentAmber.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    p.badgeLabel,
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: p.isFree
                                          ? AppColors.accentGreen
                                          : AppColors.accentAmber,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              p.description,
                              style: AppTypography.caption.copyWith(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.matteBlack,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showHfTokenSheet() {
    final auth = context.read<AuthProvider>();
    final controller = TextEditingController(text: auth.hfToken);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hugging Face User Token', style: AppTypography.cardTitle),
            const SizedBox(height: 6),
            Text(
              'Dapatkan token gratis di huggingface.co/settings/tokens (pilih Role: Read).',
              style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Paste HF Token (hf_...)',
                filled: true,
                fillColor: AppColors.surfaceMuted,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.matteBlack,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () {
                  auth.setHuggingFaceToken(controller.text);
                  Navigator.pop(ctx);
                },
                child: const Text('Simpan Token', style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: TextButton(
                onPressed: () {
                  auth.setSelectedImageProvider(ImageProviderType.pollinations);
                  Navigator.pop(ctx);
                },
                child: const Text(
                  'Gunakan Pollinations AI saja (100% Gratis, Tanpa Token)',
                  style: TextStyle(color: AppColors.accentGreen, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGeminiKeySheet() {
    final auth = context.read<AuthProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Google Gemini Image (Nano Banana)', style: AppTypography.cardTitle),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accentAmber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.accentAmber, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Gemini Image (Nano Banana 2) memerlukan akun Google Cloud dengan Billing aktif. '
                      'Untuk hasil gambar gratis tanpa billing, gunakan Pollinations AI (FLUX).',
                      style: AppTypography.caption.copyWith(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () {
                  auth.setSelectedImageProvider(ImageProviderType.pollinations);
                  Navigator.pop(ctx);
                },
                child: const Text(
                  'Gunakan Pollinations AI (FLUX) — Gratis',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a contextual banner showing which trend triggered the current ideas session.
  List<Widget> _buildTrendBanner(TrendItem trend) {
    return [
      Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Color(trend.accentColorHex).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Color(trend.accentColorHex).withValues(alpha: 0.22),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.trending_up_rounded,
              size: 16,
              color: Color(trend.accentColorHex),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: AppTypography.caption.copyWith(fontSize: 12),
                  children: [
                    const TextSpan(
                      text: 'Ideas for: ',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    TextSpan(
                      text: trend.title,
                      style: TextStyle(
                        color: Color(trend.accentColorHex),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: '  •  ${trend.searchVolumeDemand}',
                      style: const TextStyle(
                        color: AppColors.accentGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Tap to clear trend context and switch to free-form mode
            GestureDetector(
              onTap: () => setState(() => _activeTrend = null),
              child: const Icon(
                Icons.close_rounded,
                size: 14,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: "Highlight" pill badge & Close/Back button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.38),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Highlight',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Hero Mood Board Card matching reference Screen 4
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F9FF),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: const Color(0xFFBAE6FD),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.06),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                    child: Column(
                      children: [
                        // Card Blue Heading
                        Text(
                          'Artistic Mood Board',
                          textAlign: TextAlign.center,
                          style: AppTypography.cardTitle.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0369A1),
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'A digital space for collaging and inspiration.',
                          textAlign: TextAlign.center,
                          style: AppTypography.body.copyWith(
                            fontSize: 14,
                            color: const Color(0xFF0284C7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Center 3D Glossy Metallic Blue Orb
                        GlossyOrb(
                          size: 132,
                          onTap: _loadPromptIdeas,
                        ),

                        const SizedBox(height: 28),

                        // Motivational subtext
                        Text(
                          'Because you thrive on creativity and self-expression.',
                          textAlign: TextAlign.center,
                          style: AppTypography.caption.copyWith(
                            fontSize: 13,
                            color: const Color(0xFF0284C7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 18),

                        // "Refresh Ideas" action pill button
                        GestureDetector(
                          onTap: _loadPromptIdeas,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(0xFFBAE6FD),
                                width: 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_isLoadingIdeas)
                                  const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                else
                                  const Icon(
                                    Icons.refresh_rounded,
                                    size: 16,
                                    color: Color(0xFF0369A1),
                                  ),
                                const SizedBox(width: 8),
                                Text(
                                  'Refresh Ideas',
                                  style: AppTypography.buttonText.copyWith(
                                    fontSize: 13,
                                    color: const Color(0xFF0369A1),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Style Presets Chips row
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _stylePresets.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final style = _stylePresets[index];
                        final isSelected = _selectedStyle == style;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedStyle = style;
                              // When user manually picks a style, detach from trend context
                              // so Gemini generates ideas for the chosen style, not the old trend.
                              _activeTrend = null;
                            });
                            _loadPromptIdeas();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.matteBlack : AppColors.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? AppColors.matteBlack : AppColors.borderLight,
                                width: 0.8,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                style,
                                style: AppTypography.caption.copyWith(
                                  color: isSelected ? Colors.white : AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Prompt Idea Cards generated by Gemini
                  // Show trend context banner when navigated from a trend card
                  if (_activeTrend != null) ..._buildTrendBanner(_activeTrend!),

                  Text(
                    'Recommended Ideas for Adobe Stock:',
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  ..._promptIdeas.map((idea) => GestureDetector(
                    onTap: () => setState(() => _promptController.text = idea),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: AppDecorations.card(radius: 16),
                      child: Row(
                        children: [
                          const Icon(Icons.lightbulb_outline_rounded, size: 18, color: AppColors.accentAmber),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              idea,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.body.copyWith(
                                fontSize: 13,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textTertiary),
                        ],
                      ),
                    ),
                  )),
                ],
              ),
            ),

            // Live 2-Stage Generation Status Banner
            if (_generationStageText.isNotEmpty)
              Positioned(
                left: 20,
                right: 20,
                bottom: 130,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.matteBlack,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _generationStageText,
                          style: AppTypography.caption.copyWith(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // AI Engine / Model Selector Pill + AI Reasoning Toggle Pill
            Positioned(
              left: 16,
              right: 16,
              bottom: 92,
              child: Row(
                children: [
                  // Engine Selector
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      final provider = auth.selectedImageProvider;
                      return GestureDetector(
                        onTap: () => _showProviderSelectionSheet(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.borderLight, width: 0.8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                provider == ImageProviderType.pollinations
                                    ? Icons.eco_rounded
                                    : provider == ImageProviderType.huggingFace
                                        ? Icons.smart_toy_rounded
                                        : Icons.bolt_rounded,
                                size: 14,
                                color: provider == ImageProviderType.pollinations
                                    ? AppColors.accentGreen
                                    : provider == ImageProviderType.huggingFace
                                        ? Colors.purple
                                        : AppColors.accentAmber,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                provider.displayName,
                                style: AppTypography.caption.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: provider.isFree
                                      ? AppColors.accentGreen.withValues(alpha: 0.12)
                                      : AppColors.accentAmber.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  provider.badgeLabel,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: provider.isFree
                                        ? AppColors.accentGreen
                                        : AppColors.accentAmber,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 14,
                                color: AppColors.textTertiary,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const Spacer(),

                  // AI Reasoning Toggle Pill
                  GestureDetector(
                    onTap: () => setState(() => _enableReasoning = !_enableReasoning),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _enableReasoning ? AppColors.matteBlack : AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _enableReasoning ? AppColors.matteBlack : AppColors.borderLight,
                          width: 0.8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.psychology_rounded,
                            size: 14,
                            color: _enableReasoning ? Colors.amber.shade300 : AppColors.textTertiary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _enableReasoning ? 'Reasoning: ON' : 'Reasoning: OFF',
                            style: AppTypography.caption.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                              color: _enableReasoning ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Floating Bottom Prompt Bar matching reference Screen 4
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: Container(
                height: 60,
                decoration: AppDecorations.floatingPill(
                  color: Colors.white,
                  radius: 32,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    // "+" Attachment / Engine Switcher Button
                    GestureDetector(
                      onTap: () => _showProviderSelectionSheet(context),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.tune_rounded,
                          size: 18,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Text Field "What should we make?"
                    Expanded(
                      child: TextField(
                        controller: _promptController,
                        style: AppTypography.body.copyWith(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'What should we make?',
                          hintStyle: AppTypography.body.copyWith(
                            fontSize: 14,
                            color: AppColors.textTertiary,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                      ),
                    ),

                    const SizedBox(width: 6),

                    // One-tap Reasoning Optimizer button
                    GestureDetector(
                      onTap: (_isGenerating || _isReasoning) ? null : _optimizePromptWithReasoning,
                      child: Tooltip(
                        message: 'Nalar & perjelas prompt dengan Gemini AI',
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: _isReasoning
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.8,
                                      color: AppColors.accentAmber,
                                    ),
                                  )
                                : const Icon(
                                    Icons.auto_fix_high_rounded,
                                    size: 16,
                                    color: AppColors.accentAmber,
                                  ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Generate / Action Button
                    GestureDetector(
                      onTap: _isGenerating ? null : _generateImage,
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.matteBlack,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: _isGenerating
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.auto_awesome_rounded,
                                  size: 18,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
