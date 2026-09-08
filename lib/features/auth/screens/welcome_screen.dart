import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_typography.dart';
import '../models/user_profile.dart';
import '../providers/auth_provider.dart';
import '../../trends/screens/home_trends_screen.dart';

/// Screen 2: Welcome & Onboarding Screen matching the Wabi design reference
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _hfTokenController = TextEditingController();
  bool _isProKey = false;
  bool _isSigningIn = false;
  bool _isTestingKey = false;
  bool? _keyTestResult; // null = not tested, true = valid, false = invalid

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    _apiKeyController.dispose();
    _hfTokenController.dispose();
    super.dispose();
  }

  void _onSignIn(BuildContext context) async {
    if (_isSigningIn) return;
    setState(() => _isSigningIn = true);

    final auth = context.read<AuthProvider>();
    final success = await auth.signInWithGoogle();

    if (!mounted) return;
    setState(() => _isSigningIn = false);

    if (success) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeTrendsScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    } else {
      final errMsg = auth.error ?? 'Sign-in gagal. Periksa koneksi internet Anda.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errMsg),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _showApiKeyDialog(BuildContext context) {
    final auth = context.read<AuthProvider>();
    _apiKeyController.text = auth.apiKey;
    _hfTokenController.text = auth.hfToken;
    _isProKey = auth.currentTier == UserTier.pro;
    _keyTestResult = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
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
          child: SingleChildScrollView(
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
                const SizedBox(height: 20),
                Text(
                  'AI Engine & API Settings',
                  style: AppTypography.cardTitle,
                ),
                const SizedBox(height: 10),
                // Pollinations 100% Free Info Badge
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accentGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.accentGreen.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.accentGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Pollinations AI (FLUX.1) siap pakai: Generator gambar 100% GRATIS tanpa perlu API key!',
                          style: AppTypography.caption.copyWith(
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Gemini API Key (Teks & Ide Prompt)',
                  style: AppTypography.cardTitle.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Dapatkan gratis di aistudio.google.com/apikey untuk fitur riset & ide prompt.',
                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _apiKeyController,
                  obscureText: true,
                  onChanged: (_) => setModalState(() => _keyTestResult = null),
                  decoration: InputDecoration(
                    hintText: 'Paste Gemini API Key (e.g. AIzaSy...)',
                    hintStyle: AppTypography.body.copyWith(color: AppColors.textTertiary),
                    filled: true,
                    fillColor: AppColors.surfaceMuted,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: _keyTestResult == null
                        ? null
                        : Icon(
                            _keyTestResult! ? Icons.check_circle : Icons.cancel,
                            color: _keyTestResult! ? Colors.green : Colors.red,
                          ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 10),
                // Test Connection button
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                      side: BorderSide(color: AppColors.borderLight),
                    ),
                    onPressed: _isTestingKey
                        ? null
                        : () async {
                            setModalState(() {
                              _isTestingKey = true;
                              _keyTestResult = null;
                            });
                            final key = _apiKeyController.text.trim();
                            bool valid = false;
                            if (key.isNotEmpty) {
                              try {
                                final uri = Uri.parse(
                                  'https://generativelanguage.googleapis.com/v1beta/models?key=$key',
                                );
                                final res = await http.get(uri).timeout(
                                  const Duration(seconds: 8),
                                );
                                valid = res.statusCode == 200;
                              } catch (_) {
                                valid = false;
                              }
                            }
                            setModalState(() {
                              _isTestingKey = false;
                              _keyTestResult = valid;
                            });
                          },
                    icon: _isTestingKey
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.wifi_tethering_rounded, size: 18),
                    label: Text(
                      _isTestingKey ? 'Menguji koneksi...' : 'Test Koneksi Gemini',
                      style: AppTypography.buttonText.copyWith(fontSize: 13),
                    ),
                  ),
                ),
                if (_keyTestResult != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _keyTestResult!
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _keyTestResult! ? Icons.check_circle_rounded : Icons.error_rounded,
                          color: _keyTestResult! ? Colors.green : Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _keyTestResult!
                              ? 'API Key valid! Gemini siap digunakan.'
                              : 'API Key tidak valid atau tidak ada koneksi.',
                          style: AppTypography.caption.copyWith(
                            color: _keyTestResult! ? Colors.green.shade700 : Colors.red.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                Text(
                  'Hugging Face Token (Opsional - FLUX.1)',
                  style: AppTypography.cardTitle.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Dapatkan token gratis di huggingface.co/settings/tokens (Role: Read).',
                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _hfTokenController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Paste HF Token (hf_...)',
                    hintStyle: AppTypography.body.copyWith(color: AppColors.textTertiary),
                    filled: true,
                    fillColor: AppColors.surfaceMuted,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Free Tier (15 RPM)'),
                      selected: !_isProKey,
                      onSelected: (val) {
                        setModalState(() => _isProKey = !val);
                      },
                      selectedColor: AppColors.textPrimary,
                      labelStyle: TextStyle(
                        color: !_isProKey ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 10),
                    ChoiceChip(
                      label: const Text('Pro Tier (Paid)'),
                      selected: _isProKey,
                      onSelected: (val) {
                        setModalState(() => _isProKey = val);
                      },
                      selectedColor: AppColors.accentBlue,
                      labelStyle: TextStyle(
                        color: _isProKey ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.matteBlack,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      auth.setGeminiApiKey(_apiKeyController.text, isPro: _isProKey);
                      auth.setHuggingFaceToken(_hfTokenController.text);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Pengaturan API & Token tersimpan!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Text(
                      'Simpan Pengaturan',
                      style: AppTypography.buttonText.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Top-left "Highlight" pill badge (as in reference Screen 2)
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),

            // Main screen content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // Floating 3D bubbles cluster around center "+" button
                  AnimatedBuilder(
                    animation: _floatController,
                    builder: (context, child) {
                      final floatOffset = _floatController.value * 6.0;
                      return Transform.translate(
                        offset: Offset(0, floatOffset),
                        child: child,
                      );
                    },
                    child: _FloatingBubblesHub(
                      onTapCenter: () => _onSignIn(context),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Headline matching reference Screen 2:
                  // "Meet Wabi. / The first personal / software platform."
                  Column(
                    children: [
                      Text(
                        'Meet StockCraft.\nThe first personal\nAI studio.',
                        textAlign: TextAlign.center,
                        style: AppTypography.heroTitle.copyWith(
                          fontSize: 30,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Built for Adobe Stock contributors',
                        textAlign: TextAlign.center,
                        style: AppTypography.body,
                      ),
                    ],
                  ),

                  const Spacer(flex: 3),

                  // Bottom pill action buttons matching reference Screen 2
                  _GoogleSignInButton(
                    onPressed: _isSigningIn ? null : () => _onSignIn(context),
                    isLoading: _isSigningIn,
                  ),

                  const SizedBox(height: 12),

                  _AppleSignInButton(
                    onPressed: () => _onSignIn(context),
                  ),

                  const SizedBox(height: 12),

                  // Subtle settings trigger for Gemini API key
                  TextButton.icon(
                    onPressed: () => _showApiKeyDialog(context),
                    icon: const Icon(Icons.key_rounded, size: 16, color: AppColors.textTertiary),
                    label: Text(
                      'Configure Gemini Key (Free / Pro)',
                      style: AppTypography.caption,
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Floating ambient bubbles cluster with a circular frosted glass '+' button in the center
class _FloatingBubblesHub extends StatelessWidget {
  final VoidCallback onTapCenter;

  const _FloatingBubblesHub({required this.onTapCenter});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ambient satellite bubbles
          _bubble(-80, -50, 48, const Color(0xFFFB923C), '🪐'), // Orange planet
          _bubble(75, -60, 42, const Color(0xFF60A5FA), '🌊'),  // Blue wave
          _bubble(-95, 20, 36, const Color(0xFFA78BFA), '✨'),  // Purple sparkle
          _bubble(85, 30, 46, const Color(0xFFF472B6), '🎨'),   // Pink palette
          _bubble(-40, -85, 52, const Color(0xFF34D399), '🌿'), // Green leaf
          _bubble(40, -90, 50, const Color(0xFFFBBF24), '⚡'),  // Gold energy
          _bubble(0, 75, 40, const Color(0xFF38BDF8), '💎'),    // Cyan gem

          // Center '+' frosted glass circular button
          GestureDetector(
            onTap: onTapCenter,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.92),
                border: Border.all(
                  color: AppColors.borderLight,
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.add_rounded,
                  size: 32,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bubble(double x, double y, double size, Color color, String emoji) {
    return Transform.translate(
      offset: Offset(x, y),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.9), color.withValues(alpha: 0.6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            emoji,
            style: TextStyle(fontSize: size * 0.45),
          ),
        ),
      ),
    );
  }
}

/// "Continue with Google" pill button matching reference Screen 2
class _GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const _GoogleSignInButton({required this.onPressed, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: AppDecorations.floatingPill(
        color: AppColors.surface,
        radius: 28,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              else
                // Google Colored G Emblem
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  child: const Text(
                    'G',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4285F4),
                    ),
                  ),
                ),
              const SizedBox(width: 12),
              Text(
                isLoading ? 'Menghubungkan...' : 'Continue with Google',
                style: AppTypography.buttonText.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Continue with Apple" pill button matching reference Screen 2
class _AppleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _AppleSignInButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        color: AppColors.matteBlack,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.apple_rounded,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                'Continue with Apple',
                style: AppTypography.buttonText.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
