/// Evaluation result against Adobe Stock contributor submission criteria
class AdobeValidationResult {
  final bool isValid;
  final double megapixels;
  final double fileSizeMB;
  final List<String> errors;
  final List<String> warnings;

  const AdobeValidationResult({
    required this.isValid,
    required this.megapixels,
    required this.fileSizeMB,
    required this.errors,
    this.warnings = const [],
  });
}

/// Technical compliance validator for Adobe Stock Contributors:
/// - Resolution: 4 MP to 100 MP
/// - Maximum file size: 45 MB
/// - Standard: JPEG with sRGB
class AdobeValidator {
  static const double minMegapixels = 4.0;
  static const double maxMegapixels = 100.0;
  static const double maxFileSizeBytes = 45.0 * 1024 * 1024; // 45 MB

  static AdobeValidationResult validate({
    required int width,
    required int height,
    required int byteLength,
  }) {
    final megapixels = (width * height) / 1000000.0;
    final fileSizeMB = byteLength / (1024.0 * 1024.0);
    final errors = <String>[];
    final warnings = <String>[];

    if (megapixels < minMegapixels) {
      errors.add(
        'Resolution is ${megapixels.toStringAsFixed(2)} MP. Adobe Stock requires at least 4 MP.',
      );
    }
    if (megapixels > maxMegapixels) {
      errors.add(
        'Resolution is ${megapixels.toStringAsFixed(1)} MP. Adobe Stock allows at most 100 MP.',
      );
    }
    if (byteLength > maxFileSizeBytes) {
      errors.add(
        'File size is ${fileSizeMB.toStringAsFixed(1)} MB. Adobe Stock limit is 45 MB.',
      );
    }

    if (megapixels >= 4.0 && megapixels < 8.0) {
      warnings.add(
        'Meets baseline 4 MP, but 12 MP - 24 MP is recommended for premium stock placement.',
      );
    }

    return AdobeValidationResult(
      isValid: errors.isEmpty,
      megapixels: megapixels,
      fileSizeMB: fileSizeMB,
      errors: errors,
      warnings: warnings,
    );
  }
}
