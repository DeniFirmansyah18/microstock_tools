import 'package:flutter/material.dart';

/// Interactive 3D glossy metallic orb with refraction & specular highlights (as in reference Screen 4)
class GlossyOrb extends StatefulWidget {
  final double size;
  final VoidCallback? onTap;

  const GlossyOrb({
    super.key,
    this.size = 140.0,
    this.onTap,
  });

  @override
  State<GlossyOrb> createState() => _GlossyOrbState();
}

class _GlossyOrbState extends State<GlossyOrb> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key('glossy_orb_widget'),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: child,
          );
        },
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Diffuse ambient drop shadow
              Positioned(
                bottom: 2,
                child: Container(
                  width: widget.size * 0.82,
                  height: widget.size * 0.24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.elliptical(widget.size * 0.82, widget.size * 0.24)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1E40AF).withValues(alpha: 0.35),
                        blurRadius: 28,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),

              // Main 3D Glossy Sphere Body
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    center: Alignment(-0.35, -0.35),
                    radius: 0.95,
                    colors: [
                      Color(0xFF93C5FD), // Light blue top reflection
                      Color(0xFF3B82F6), // Vibrant cerulean body
                      Color(0xFF1D4ED8), // Deep cobalt
                      Color(0xFF0F172A), // Dark shadow rim
                    ],
                    stops: [0.0, 0.35, 0.75, 1.0],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 1.2,
                  ),
                ),
              ),

              // Primary Specular Light Glint (top-left)
              Positioned(
                top: widget.size * 0.16,
                left: widget.size * 0.22,
                child: Container(
                  width: widget.size * 0.32,
                  height: widget.size * 0.20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.elliptical(widget.size * 0.32, widget.size * 0.20),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.85),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

              // Subtle bottom crescent light bounce
              Positioned(
                bottom: widget.size * 0.12,
                child: Container(
                  width: widget.size * 0.5,
                  height: widget.size * 0.14,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.elliptical(widget.size * 0.5, widget.size * 0.14),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        const Color(0xFF60A5FA).withValues(alpha: 0.5),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
