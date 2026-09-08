# Adobe Stock Contributor AI Image Tool Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a production-grade Flutter Android & iOS app for microstock contributors to research Adobe Stock market trends, generate compliant illustrations with Imagen 3 & Gemini, inspect AI defects, upscale to 4MP-100MP, and automatically inject IPTC/XMP metadata into binary JPEGs with a Wabi-inspired UI.

**Architecture:** Feature-first modular Clean Architecture in pure Flutter/Dart. In-app image processing pipeline for Lanczos3/Bicubic upscaling, binary JPEG IPTC/XMP header injection, and client-side + Gemini Vision multimodal AI defect analysis.

**Tech Stack:** Flutter 3.41+, Dart 3.11+, `google_fonts`, `image`, `flutter_secure_storage`, `http`, `path_provider`, `share_plus`, `provider`.

**Spec:** [docs/superpowers/specs/2026-09-08-adobe-stock-ai-tool-design.md](file:///e:/PROJECT%20REACT/microstock_tools/docs/superpowers/specs/2026-09-08-adobe-stock-ai-tool-design.md)

## Global Constraints
- Target Platforms: Flutter Android & iOS.
- Resolution standard: 4 MP <= resolution <= 100 MP (e.g. 4096×4096 = 16.8 MP).
- File size limit: Maximum 45 MB per JPEG.
- Color profile: JPEG sRGB.
- Content integrity: Zero watermarks, timestamps, brand logos, or AI malformations.
- Metadata: IPTC Core `ObjectName` (Title), `Keywords` (35-50 tags), and XMP embedded directly in JPEG binary markers (`APP13` and `APP1`).
- UI/UX: Strict adherence to the Wabi Minimalist aesthetic (5 screens: Splash, Onboarding, Home Trends, Prompt Studio, Quality Lab).

---

### Task 1: Flutter Project Setup & Core Design System
**Files:**
- Create: `pubspec.yaml`
- Create: `lib/core/theme/app_colors.dart`
- Create: `lib/core/theme/app_typography.dart`
- Create: `lib/core/theme/app_decorations.dart`
- Test: `test/theme_test.dart`

**Interfaces:**
- Produces: `AppColors`, `AppTypography`, `AppDecorations` for all downstream UI components.

- [ ] **Step 1: Write failing theme test**
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:microstock_tools/core/theme/app_colors.dart';
import 'package:microstock_tools/core/theme/app_typography.dart';

void main() {
  test('AppColors provides Wabi palette tokens', () {
    expect(AppColors.background, isNotNull);
    expect(AppColors.surface, isNotNull);
    expect(AppColors.textPrimary, isNotNull);
    expect(AppColors.matteBlack, isNotNull);
  });

  test('AppTypography provides standard heading styles', () {
    expect(AppTypography.heroTitle.fontSize, 28.0);
    expect(AppTypography.cardTitle.fontSize, 18.0);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**
Run: `flutter test test/theme_test.dart`
Expected: FAIL (project/files not yet found).

- [ ] **Step 3: Setup pubspec.yaml and core design tokens**
Configure `pubspec.yaml` with required dependencies:
```yaml
name: microstock_tools
description: Adobe Stock Contributor AI Image Tool
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.3.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  google_fonts: ^6.2.1
  image: ^4.3.0
  flutter_secure_storage: ^9.2.2
  http: ^1.2.2
  path_provider: ^2.1.4
  share_plus: ^10.0.2
  provider: ^6.1.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
```
Create `lib/core/theme/app_colors.dart`:
```dart
import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFFBFBFD);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF3F3F6);
  static const Color textPrimary = Color(0xFF111114);
  static const Color textSecondary = Color(0xFF6E6E77);
  static const Color textTertiary = Color(0xFF9E9EA7);
  static const Color matteBlack = Color(0xFF16161A);
  static const Color borderLight = Color(0xFFECECED);
  static const Color borderSubtle = Color(0xFFE2E2E6);
  static const Color accentBlue = Color(0xFF2563EB);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentRed = Color(0xFFEF4444);
}
```
Create `lib/core/theme/app_typography.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  static TextStyle get heroTitle => GoogleFonts.plusJakartaSans(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.8,
    height: 1.15,
  );

  static TextStyle get screenTitle => GoogleFonts.plusJakartaSans(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle get cardTitle => GoogleFonts.plusJakartaSans(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  static TextStyle get body => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static TextStyle get buttonText => GoogleFonts.plusJakartaSans(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );

  static TextStyle get pillBadge => GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );
}
```
Create `lib/core/theme/app_decorations.dart`:
```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppDecorations {
  static BoxDecoration card({Color? color, double radius = 24.0, bool hasBorder = true}) => BoxDecoration(
    color: color ?? AppColors.surface,
    borderRadius: BorderRadius.circular(radius),
    border: hasBorder ? Border.all(color: AppColors.borderLight, width: 0.9) : null,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.025),
        blurRadius: 18,
        offset: const Offset(0, 6),
      ),
    ],
  );

  static BoxDecoration floatingPill({Color? color}) => BoxDecoration(
    color: color ?? AppColors.surface,
    borderRadius: BorderRadius.circular(36),
    border: Border.all(color: AppColors.borderLight, width: 0.8),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );
}
```

- [ ] **Step 4: Run test to verify it passes**
Run: `flutter test test/theme_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**
Run: `git add pubspec.yaml lib/core/theme/ test/theme_test.dart && git commit -m "feat: initialize project & Wabi design system"`

---

### Task 2: Adobe Stock Technical Validator & In-App Upscaler
**Files:**
- Create: `lib/core/utils/adobe_validator.dart`
- Create: `lib/core/utils/image_upscaler.dart`
- Test: `test/adobe_validator_test.dart`
- Test: `test/image_upscaler_test.dart`

**Interfaces:**
- Produces: `AdobeValidator.validate({required int width, required int height, required int byteLength})` -> `AdobeValidationResult`.
- Produces: `ImageUpscaler.upscale({required Uint8List bytes, required int targetWidth, required int targetHeight, InterpolationMethod method})` -> `Future<Uint8List>`.

- [ ] **Step 1: Write failing tests for validator and upscaler**
Write tests in `test/adobe_validator_test.dart` asserting:
- Resolution < 4MP fails.
- Resolution between 4MP and 100MP passes.
- File size > 45MB fails.
Write tests in `test/image_upscaler_test.dart` asserting:
- An input 500x500 test image upscaled to 2000x2000 results in valid JPEG bytes with dimensions 2000x2000 (4 Megapixels).

- [ ] **Step 2: Run tests to verify they fail**
Run: `flutter test test/adobe_validator_test.dart test/image_upscaler_test.dart`
Expected: FAIL.

- [ ] **Step 3: Implement AdobeValidator and ImageUpscaler**
Implement `AdobeValidator` with strict checks:
- Min megapixels: 4.0 MP (`(width * height) / 1,000,000 >= 4.0`).
- Max megapixels: 100.0 MP.
- Max file size: 45 * 1024 * 1024 bytes (45 MB).
Implement `ImageUpscaler` using pure Dart `image` package:
- Decode image.
- Apply `copyResize` with `Interpolation.cubic` or `Interpolation.average`.
- Apply slight unsharp sharpening filter.
- Encode to JPEG with 95% quality.

- [ ] **Step 4: Run tests to verify they pass**
Run: `flutter test test/adobe_validator_test.dart test/image_upscaler_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**
Run: `git add lib/core/utils/ test/ && git commit -m "feat: implement Adobe Stock technical validator & upscaler"`

---

### Task 3: Binary JPEG IPTC & XMP Metadata Injector & CSV Exporter
**Files:**
- Create: `lib/core/utils/exif_iptc_writer.dart`
- Create: `lib/features/metadata/adobe_csv_exporter.dart`
- Test: `test/exif_iptc_writer_test.dart`
- Test: `test/adobe_csv_exporter_test.dart`

**Interfaces:**
- Produces: `ExifIptcWriter.injectMetadata({required Uint8List jpegBytes, required String title, required List<String> keywords, required String category})` -> `Uint8List`.
- Produces: `AdobeCsvExporter.generateCsv(List<AdobeAssetRecord> records)` -> `String`.

- [ ] **Step 1: Write failing metadata writer tests**
Write tests asserting that:
- Injecting metadata into a JPEG byte sequence produces a valid JPEG starting with `0xFF, 0xD8` and ending with `0xFF, 0xD9`.
- The output contains the `APP13` marker (`0xFF, 0xED`) and Photoshop IPTC-NAA header with Title and Keywords strings.
- CSV exporter outputs header `Filename,Title,Keywords,Category` and escaped rows.

- [ ] **Step 2: Run tests to verify they fail**
Run: `flutter test test/exif_iptc_writer_test.dart test/adobe_csv_exporter_test.dart`
Expected: FAIL.

- [ ] **Step 3: Implement ExifIptcWriter and AdobeCsvExporter**
Implement binary marker injection:
- Finds position immediately after SOI (`0xFF, 0xD8`) or after JFIF `APP0`.
- Builds standard IPTC-NAA record:
  - Record 2, Tag 05 (ObjectName / Title): length + UTF-8 bytes.
  - Record 2, Tag 25 (Keywords): repeatable dataset per keyword.
  - Record 2, Tag 120 (Caption/Abstract): title/description.
- Wraps inside `8BIM` Photoshop marker in `APP13` (`0xFF, 0xED`).
- Injects `APP1` XMP packet with Dublin Core schema (`<dc:title>`, `<dc:subject>`, `<dc:description>`).
Implement `AdobeCsvExporter` formatting CSV rows.

- [ ] **Step 4: Run tests to verify they pass**
Run: `flutter test test/exif_iptc_writer_test.dart test/adobe_csv_exporter_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**
Run: `git add lib/core/utils/exif_iptc_writer.dart lib/features/metadata/adobe_csv_exporter.dart test/ && git commit -m "feat: implement binary JPEG IPTC/XMP metadata injector & CSV exporter"`

---

### Task 4: Adobe Stock Constants, Market Trends Repository & Gemini Service
**Files:**
- Create: `lib/core/constants/adobe_categories.dart`
- Create: `lib/features/trends/models/trend_item.dart`
- Create: `lib/features/trends/repositories/trend_repository.dart`
- Create: `lib/features/generator/services/gemini_service.dart`
- Create: `lib/features/generator/services/imagen_service.dart`
- Test: `test/trend_repository_test.dart`
- Test: `test/gemini_service_test.dart`

**Interfaces:**
- Produces: `AdobeCategories.list` (21 standard categories).
- Produces: `TrendRepository.getCuratedTrends()` -> `List<TrendItem>`.
- Produces: `GeminiService.generatePromptIdeas({required String niche})` -> `Future<List<String>>`.
- Produces: `GeminiService.inspectDefects({required Uint8List imageBytes})` -> `Future<DefectInspectionResult>`.
- Produces: `GeminiService.generateMetadata({required String prompt, required Uint8List imageBytes})` -> `Future<GeneratedMetadata>`.
- Produces: `ImagenService.generateImage({required String prompt, String aspectRatio})` -> `Future<Uint8List>`.

- [ ] **Step 1: Write failing tests for trends and AI services**
Assert category lookup, curated trend retrieval, prompt idea generation parsing, and defect inspection result parsing.

- [ ] **Step 2: Run tests to verify they fail**
Run: `flutter test test/trend_repository_test.dart test/gemini_service_test.dart`
Expected: FAIL.

- [ ] **Step 3: Implement AdobeCategories, TrendRepository, GeminiService, and ImagenService**
- Provide all 21 Adobe stock categories.
- Provide curated high-volume trend items with tags, demand volume, search keywords.
- Implement Gemini REST client targeting `gemini-2.0-flash` with robust JSON schema response parsing and offline fallback mock mode.
- Implement Imagen 3 REST client calling `imagen-3.0-generate-002` with mock generator fallback for tests.

- [ ] **Step 4: Run tests to verify they pass**
Run: `flutter test test/trend_repository_test.dart test/gemini_service_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**
Run: `git add lib/core/constants/ lib/features/trends/ lib/features/generator/ test/ && git commit -m "feat: add Adobe categories, trend repository, and Gemini/Imagen services"`

---

### Task 5: Auth & Quota Management (Screen 1 & Screen 2)
**Files:**
- Create: `lib/features/auth/models/user_profile.dart`
- Create: `lib/features/auth/providers/auth_provider.dart`
- Create: `lib/features/auth/screens/splash_screen.dart`
- Create: `lib/features/auth/screens/welcome_screen.dart`
- Test: `test/auth_provider_test.dart`
- Test: `test/auth_screens_test.dart`

**Interfaces:**
- Produces: `AuthProvider` managing `isLoggedIn`, `userProfile`, `apiKey`, `tier` (Free / Pro), and persistent storage.
- Produces: `SplashScreen` (Screen 1) and `WelcomeScreen` (Screen 2).

- [ ] **Step 1: Write failing tests for AuthProvider and Auth screens**
- [ ] **Step 2: Run tests to verify they fail**
Run: `flutter test test/auth_provider_test.dart test/auth_screens_test.dart`
Expected: FAIL.

- [ ] **Step 3: Implement AuthProvider, SplashScreen & WelcomeScreen**
- `SplashScreen`: Clean white background, top-left "Highlight" pill, center floral/dot geometric logo with subtle pulse/fade animation, navigates to Welcome/Home.
- `WelcomeScreen`: Ambient 3D floating bubbles around a central frosted glass `+` button, headline `"Meet StockCraft. The first personal software platform."`, pill buttons `"Continue with Google"` and `"Continue with Apple"`, bottom secure Gemini API key config dialog.

- [ ] **Step 4: Run tests to verify they pass**
Run: `flutter test test/auth_provider_test.dart test/auth_screens_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**
Run: `git add lib/features/auth/ test/ && git commit -m "feat: implement authentication, splash, and welcome screens"`

---

### Task 6: Home & Market Research Dashboard (Screen 3)
**Files:**
- Create: `lib/core/widgets/floating_dock.dart`
- Create: `lib/features/trends/screens/home_trends_screen.dart`
- Test: `test/home_trends_screen_test.dart`

**Interfaces:**
- Produces: `FloatingDock` navigation widget with Explore, Home pill, Bookmarks, and `+` FAB.
- Produces: `HomeTrendsScreen` (Screen 3).

- [ ] **Step 1: Write failing widget test for HomeTrendsScreen**
- [ ] **Step 2: Run test to verify it fails**
Run: `flutter test test/home_trends_screen_test.dart`
Expected: FAIL.

- [ ] **Step 3: Implement FloatingDock and HomeTrendsScreen**
- `HomeTrendsScreen`: Top bar with `"Highlight"` pill, bold `"Home"` title, bell notification icon, and user avatar with tier indicator.
- Grid cards displaying trending styles with 3D glossy spheres/icons, user badges (`@lenny`, `@joonas`, `@blasto`), titles (`"Habit wall"`, `"Step counter grid"`, `"Talk to books"` / Stock styles: `"3D Clay Characters"`, `"Isometric Tech"`, `"Pastel Papercraft"`), and search demand indicators.
- Bottom floating dock with active Home pill and circular `+` button that navigates directly to Prompt Studio.

- [ ] **Step 4: Run test to verify it passes**
Run: `flutter test test/home_trends_screen_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**
Run: `git add lib/core/widgets/floating_dock.dart lib/features/trends/screens/ test/ && git commit -m "feat: implement home market research dashboard & floating dock"`

---

### Task 7: Prompt Studio & Ideation (Screen 4)
**Files:**
- Create: `lib/core/widgets/glossy_orb.dart`
- Create: `lib/features/generator/screens/prompt_studio_screen.dart`
- Test: `test/prompt_studio_screen_test.dart`

**Interfaces:**
- Produces: `GlossyOrb` 3D gradient sphere widget.
- Produces: `PromptStudioScreen` (Screen 4) with prompt synthesis and generation trigger.

- [ ] **Step 1: Write failing widget test for PromptStudioScreen**
- [ ] **Step 2: Run test to verify it fails**
Run: `flutter test test/prompt_studio_screen_test.dart`
Expected: FAIL.

- [ ] **Step 3: Implement GlossyOrb & PromptStudioScreen**
- `GlossyOrb`: Custom painter / layered gradients simulating realistic 3D specular light reflections.
- `PromptStudioScreen`:
  - Hero card with pastel blue gradient border, title `"Artistic Mood Board"`, subtitle `"A digital space for prompt synthesis & stock inspiration."`, central glossy blue orb, subtext `"Because you thrive on creativity and self-expression."`, and action pill `"🔄 Refresh Ideas"`.
  - Floating bottom prompt bar: Pill with `+` action, text input `"What should we make?"`, mic/magic icon, and style modifier chips.
  - Triggers generation and navigates to Screen 5 (Quality Lab).

- [ ] **Step 4: Run test to verify it passes**
Run: `flutter test test/prompt_studio_screen_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**
Run: `git add lib/core/widgets/glossy_orb.dart lib/features/generator/screens/ test/ && git commit -m "feat: implement prompt studio & mood board screen"`

---

### Task 8: Quality Lab, Defect Inspector, Upscaler & Metadata (Screen 5)
**Files:**
- Create: `lib/features/inspector/models/defect_report.dart`
- Create: `lib/features/review_lab/screens/review_lab_screen.dart`
- Test: `test/review_lab_screen_test.dart`

**Interfaces:**
- Produces: `ReviewLabScreen` (Screen 5) coordinating inspection, upscaling, metadata editing, and final IPTC JPEG export.

- [ ] **Step 1: Write failing test for ReviewLabScreen**
- [ ] **Step 2: Run test to verify it fails**
Run: `flutter test test/review_lab_screen_test.dart`
Expected: FAIL.

- [ ] **Step 3: Implement DefectReport & ReviewLabScreen**
- Top segmented tabs: `[Quality Check]`, `[Upscale]`, `[Metadata]`, `[Export]`.
- Image preview hero card with pan/zoom.
- Interactive status card: `"All AI Defect Checks Passed"` with green checkmark and inspection breakdown (hands, focus, watermarks, sRGB).
- Upscale card: Displays Megapixels and MB, with 2x/4x high-fidelity upscale controls.
- Metadata card: Auto-generated Title, Category selector (21 Adobe categories), and ranked Keywords cloud with chips.
- Floating bottom action bar: `"Download JPEG (Embedded IPTC/XMP)"` and `"Export CSV"`.

- [ ] **Step 4: Run test to verify it passes**
Run: `flutter test test/review_lab_screen_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**
Run: `git add lib/features/inspector/ lib/features/review_lab/ test/ && git commit -m "feat: implement Quality Lab, Defect Inspector, Upscale & Metadata screen"`

---

### Task 9: App Wiring, End-to-End Testing & Verification
**Files:**
- Create: `lib/main.dart`
- Test: `test/end_to_end_test.dart`

**Interfaces:**
- Produces: Complete working Flutter application ready for launch and deployment.

- [ ] **Step 1: Write comprehensive end-to-end integration test**
- [ ] **Step 2: Run test to verify it fails**
- [ ] **Step 3: Implement main.dart and route configuration**
- [ ] **Step 4: Run full test suite and flutter analyze**
Run: `flutter test`
Run: `flutter analyze`
Expected: 0 errors, all tests PASS.
- [ ] **Step 5: Commit**
Run: `git add . && git commit -m "feat: finalize app integration and end-to-end verification"`
