import 'package:flutter_test/flutter_test.dart';
import 'package:microstock_tools/core/theme/app_colors.dart';
import 'package:microstock_tools/core/theme/app_typography.dart';
import 'package:microstock_tools/core/theme/app_decorations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  AppTypography.useSystemFonts = true;

  test('AppColors provides Wabi aesthetic tokens', () {
    expect(AppColors.background, isNotNull);
    expect(AppColors.surface, isNotNull);
    expect(AppColors.textPrimary, isNotNull);
    expect(AppColors.matteBlack, isNotNull);
    expect(AppColors.borderLight, isNotNull);
  });

  test('AppTypography provides standard heading styles', () {
    expect(AppTypography.heroTitle.fontSize, 28.0);
    expect(AppTypography.cardTitle.fontSize, 18.0);
    expect(AppTypography.body.fontSize, 14.0);
  });

  test('AppDecorations creates rounded card and floating pill', () {
    final cardDeco = AppDecorations.card();
    expect(cardDeco.borderRadius, isNotNull);

    final pillDeco = AppDecorations.floatingPill();
    expect(pillDeco.borderRadius, isNotNull);
  });
}
