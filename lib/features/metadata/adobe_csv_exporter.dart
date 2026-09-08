/// Data model for an Adobe Stock asset entry in batch CSV upload
class AdobeAssetRecord {
  final String filename;
  final String title;
  final List<String> keywords;
  final String category;

  const AdobeAssetRecord({
    required this.filename,
    required this.title,
    required this.keywords,
    required this.category,
  });
}

/// Generates RFC 4180 compliant CSV files accepted by Adobe Stock Contributor Portal
class AdobeCsvExporter {
  /// Header format expected by Adobe Stock:
  /// Filename,Title,Keywords,Category
  static String generateCsv(List<AdobeAssetRecord> records) {
    final buffer = StringBuffer();
    buffer.writeln('Filename,Title,Keywords,Category');

    for (final record in records) {
      final safeFilename = _escapeCsv(record.filename);
      final safeTitle = _escapeCsv(record.title);
      final safeKeywords = _escapeCsv(record.keywords.join(', '));
      final safeCategory = _escapeCsv(record.category);

      buffer.writeln('$safeFilename,$safeTitle,$safeKeywords,$safeCategory');
    }

    return buffer.toString();
  }

  static String _escapeCsv(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      final escaped = field.replaceAll('"', '""');
      return '"$escaped"';
    }
    return '"$field"';
  }
}
