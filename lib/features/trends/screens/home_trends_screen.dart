import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/floating_dock.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/models/user_profile.dart';
import '../../generator/screens/prompt_studio_screen.dart';
import '../models/trend_item.dart';
import '../repositories/trend_repository.dart';

/// Screen 3: Home & Adobe Stock Market Research Dashboard matching reference Screen 3
class HomeTrendsScreen extends StatefulWidget {
  const HomeTrendsScreen({super.key});

  @override
  State<HomeTrendsScreen> createState() => _HomeTrendsScreenState();
}

class _HomeTrendsScreenState extends State<HomeTrendsScreen> {
  DockTab _currentTab = DockTab.home;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openPromptStudio([TrendItem? selectedTrend]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PromptStudioScreen(initialTrend: selectedTrend),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final trendRepo = context.watch<TrendRepository>();
    final trends = trendRepo.searchTrends(_searchQuery);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Scrollable content
            CustomScrollView(
              slivers: [
                // Top App Bar matching reference Screen 3
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // "Highlight" pill badge at top-left
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
                        const SizedBox(height: 12),

                        // Title row: "Home" + Notification Bell + User Avatar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Home',
                              style: AppTypography.screenTitle.copyWith(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Row(
                              children: [
                                // Bell Notification Icon
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.borderLight, width: 0.8),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.notifications_none_rounded,
                                      size: 22,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),

                                // User Avatar with Tier Indicator
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: auth.currentTier == UserTier.pro
                                          ? AppColors.accentBlue
                                          : AppColors.borderSubtle,
                                      width: 2.0,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    backgroundColor: const Color(0xFFE2E8F0),
                                    child: Text(
                                      auth.user?.displayName.isNotEmpty == true
                                          ? auth.user!.displayName.substring(0, 1).toUpperCase()
                                          : 'A',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Adobe Stock market demand banner
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: AppDecorations.card(
                            color: const Color(0xFFF0FDF4),
                            hasBorder: true,
                            customBorder: Border.all(color: const Color(0xFFDCFCE7), width: 1),
                            radius: 18,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.trending_up_rounded, color: AppColors.accentGreen, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Adobe Stock Market: 3D & Isometric queries surged +165% this week.',
                                  style: AppTypography.body.copyWith(
                                    fontSize: 13,
                                    color: const Color(0xFF166534),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Grid of curated trend cards matching reference Screen 3
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.88,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final trend = trends[index];
                        return _TrendGridCard(
                          trend: trend,
                          onTap: () => _openPromptStudio(trend),
                        );
                      },
                      childCount: trends.length,
                    ),
                  ),
                ),
              ],
            ),

            // Floating Navigation Dock pinned to bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: FloatingDock(
                currentTab: _currentTab,
                onTabSelected: (tab) {
                  setState(() => _currentTab = tab);
                },
                onAddPressed: () => _openPromptStudio(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Trend Card with 3D thumbnail and creator badge matching reference Screen 3
class _TrendGridCard extends StatelessWidget {
  final TrendItem trend;
  final VoidCallback onTap;

  const _TrendGridCard({
    required this.trend,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: AppDecorations.card(
          radius: 24,
          hasBorder: true,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 3D Visual element container matching reference
            Expanded(
              child: Center(
                child: _build3dIcon(trend),
              ),
            ),

            const SizedBox(height: 10),

            // Creator handle badge (e.g. "@lenny", "@joonas", "@blasto")
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: AppDecorations.badgePill(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(trend.accentColorHex).withValues(alpha: 0.3),
                    ),
                    child: Center(
                      child: Text(
                        trend.creatorHandle.substring(1, 2).toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Color(trend.accentColorHex),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    trend.creatorHandle,
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Title (e.g. "Habit wall", "Step counter grid", "Talk to books")
            Text(
              trend.title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.cardTitle.copyWith(
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 2),

            // Search Demand Metric
            Text(
              trend.searchVolumeDemand,
              style: AppTypography.caption.copyWith(
                color: AppColors.accentGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _build3dIcon(TrendItem trend) {
    switch (trend.iconType) {
      case 'grid':
        // Colorful mosaic grid as in Screen 3 (Step counter grid)
        return Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: const Color(0xFFFEE2E2),
          ),
          padding: const EdgeInsets.all(8),
          child: GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 3,
            crossAxisSpacing: 3,
            physics: const NeverScrollableScrollPhysics(),
            children: List.generate(9, (i) {
              final isRed = i % 2 == 0;
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: isRed ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                ),
              );
            }),
          ),
        );

      case 'food':
        return Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFEF3C7),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withValues(alpha: 0.2),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Text('🧁', style: TextStyle(fontSize: 34)),
          ),
        );

      case 'apple':
        return Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFD1FAE5),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withValues(alpha: 0.2),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Text('🍎', style: TextStyle(fontSize: 34)),
          ),
        );

      case 'avatar':
        // Spherical habit wall bubble
        return Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFDF4E3),
            border: Border.all(color: AppColors.borderLight, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Text('🖼️', style: TextStyle(fontSize: 32)),
          ),
        );

      case 'sphere':
      default:
        // Deep blue holographic sphere as in Screen 3 (Talk to books)
        return Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8), Color(0xFF0F172A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: 10,
                left: 14,
                child: Container(
                  width: 18,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }
}
