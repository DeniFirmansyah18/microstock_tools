import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/glossy_orb.dart';
import '../../auth/providers/auth_provider.dart';
import '../../review_lab/screens/review_lab_screen.dart';
import '../../trends/models/trend_item.dart';
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
    if (widget.initialTrend != null) {
      _promptController.text = widget.initialTrend!.recommendedPrompt;
      _selectedStyle = widget.initialTrend!.tags.first;
    } else {
      _promptController.text = 'Delicious artisanal chocolate cupcake on vintage glass cloche stand, warm studio lighting';
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

    final ideas = await gemini.generatePromptIdeas(
      niche: _selectedStyle,
      forceMock: auth.isTesting || auth.apiKey.isEmpty,
    );

    if (mounted) {
      setState(() {
        _promptIdeas = ideas;
        _isLoadingIdeas = false;
      });
    }
  }

  Future<void> _generateImage() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    setState(() => _isGenerating = true);
    final auth = context.read<AuthProvider>();
    final imagen = ImagenService(apiKey: auth.apiKey);

    try {
      final bytes = await imagen.generateImage(
        prompt: prompt,
        forceMock: auth.isTesting || auth.apiKey.isEmpty,
      );

      if (mounted) {
        setState(() => _isGenerating = false);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ReviewLabScreen(
              imageBytes: bytes,
              prompt: prompt,
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
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
                            setState(() => _selectedStyle = style);
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
                    // "+" Attachment / Style Icon Button
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        size: 22,
                        color: AppColors.textPrimary,
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

                    const SizedBox(width: 8),

                    // Generate / Mic Button
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
