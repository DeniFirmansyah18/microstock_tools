import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Elevation, border radii, and soft diffused shadows for Wabi aesthetic
class AppDecorations {
  static BoxDecoration card({
    Color? color,
    double radius = 24.0,
    bool hasBorder = true,
    Border? customBorder,
    Gradient? gradient,
  }) => BoxDecoration(
    color: gradient == null ? (color ?? AppColors.surface) : null,
    gradient: gradient,
    borderRadius: BorderRadius.circular(radius),
    border: customBorder ?? (hasBorder ? Border.all(color: AppColors.borderLight, width: 0.9) : null),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.025),
        blurRadius: 18,
        offset: const Offset(0, 6),
      ),
    ],
  );

  static BoxDecoration floatingPill({Color? color, double radius = 36.0}) => BoxDecoration(
    color: color ?? AppColors.surface,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: AppColors.borderLight, width: 0.8),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 24,
        offset: const Offset(0, 10),
      ),
    ],
  );

  static BoxDecoration badgePill({Color? color, Color? borderColor}) => BoxDecoration(
    color: color ?? AppColors.surfaceMuted,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: borderColor ?? AppColors.borderSubtle, width: 0.6),
  );
}
