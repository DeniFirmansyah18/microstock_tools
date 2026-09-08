import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import 'welcome_screen.dart';

/// Screen 1: Minimalist Splash Screen matching the Wabi design reference
class SplashScreen extends StatefulWidget {
  final bool autoNavigate;

  const SplashScreen({
    super.key,
    this.autoNavigate = true,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );

    _animController.forward();

    if (widget.autoNavigate) {
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const WelcomeScreen(),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 500),
            ),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Top-left "Highlight" pill badge (as in reference Screen 1)
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

            // Center signature emblem container
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: GestureDetector(
                    onTap: () {
                      if (mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                        );
                      }
                    },
                    child: Container(
                      key: const Key('splash_brand_logo'),
                      width: 104,
                      height: 104,
                      decoration: AppDecorations.card(
                        radius: 28,
                        hasBorder: true,
                      ),
                      padding: const EdgeInsets.all(18),
                      child: const Center(
                        child: _BrandClusterIcon(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Signature geometric floral cluster icon from reference Screen 1
class _BrandClusterIcon extends StatelessWidget {
  const _BrandClusterIcon();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Top row: 3 dots
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dot(15),
            const SizedBox(width: 4),
            _dot(15),
            const SizedBox(width: 4),
            _dot(15),
          ],
        ),
        const SizedBox(height: 4),
        // Bottom row: 2 dots nested
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dot(15),
            const SizedBox(width: 4),
            _dot(15),
          ],
        ),
      ],
    );
  }

  Widget _dot(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.matteBlack,
        shape: BoxShape.circle,
      ),
    );
  }
}
