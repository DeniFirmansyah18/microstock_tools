/// Comprehensive diagnostic report assessing an AI illustration against Adobe Stock quality guidelines
class DefectReport {
  final bool passed;
  final int anatomyIntegrityScore;
  final bool isWatermarkFree;
  final bool isFocusSharp;
  final bool isColorProfileSrgb;
  final List<String> detectedIssues;
  final List<String> actionableTips;

  const DefectReport({
    required this.passed,
    required this.anatomyIntegrityScore,
    required this.isWatermarkFree,
    required this.isFocusSharp,
    required this.isColorProfileSrgb,
    this.detectedIssues = const [],
    this.actionableTips = const [],
  });

  factory DefectReport.perfect() => const DefectReport(
    passed: true,
    anatomyIntegrityScore: 98,
    isWatermarkFree: true,
    isFocusSharp: true,
    isColorProfileSrgb: true,
    detectedIssues: [],
    actionableTips: [
      'Artwork exceeds Adobe Stock baseline sharpness standards.',
      'Zero artificial watermarks or logos detected.',
    ],
  );
}
