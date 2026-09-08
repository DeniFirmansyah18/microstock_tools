import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import '../theme/app_typography.dart';

enum DockTab {
  search,
  home,
  explore,
}

class FloatingDock extends StatelessWidget {
  final DockTab currentTab;
  final ValueChanged<DockTab> onTabSelected;
  final VoidCallback onAddPressed;

  const FloatingDock({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('floating_dock'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Main navigation pill
          Container(
            height: 58,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: AppDecorations.floatingPill(
              color: Colors.white.withValues(alpha: 0.95),
              radius: 32,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Search Tab
                _DockIcon(
                  icon: Icons.search_rounded,
                  isSelected: currentTab == DockTab.search,
                  onTap: () => onTabSelected(DockTab.search),
                ),
                const SizedBox(width: 4),

                // Home Tab (Active Pill)
                _DockHomePill(
                  isSelected: currentTab == DockTab.home,
                  onTap: () => onTabSelected(DockTab.home),
                ),
                const SizedBox(width: 4),

                // Explore Tab
                _DockIcon(
                  icon: Icons.auto_awesome_outlined,
                  isSelected: currentTab == DockTab.explore,
                  onTap: () => onTabSelected(DockTab.explore),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Action '+' circular floating button
          GestureDetector(
            key: const Key('dock_add_button'),
            onTap: onAddPressed,
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.matteBlack,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.16),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DockHomePill extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _DockHomePill({required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceMuted : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.home_filled,
              size: 20,
              color: isSelected ? AppColors.textPrimary : AppColors.textTertiary,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                'Home',
                style: AppTypography.buttonText.copyWith(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DockIcon extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _DockIcon({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? AppColors.surfaceMuted : Colors.transparent,
        ),
        child: Center(
          child: Icon(
            icon,
            size: 22,
            color: isSelected ? AppColors.textPrimary : AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}
