import 'dart:convert';
import 'dart:typed_data';

class EmbeddedMetadata {
  final String title;
  final List<String> keywords;
  final String category;
  final String description;

  const EmbeddedMetadata({
    required this.title,
    required this.keywords,
    required this.category,
    this.description = '',
  });
}

/// Binary JPEG metadata injector supporting standard Adobe Stock IPTC Core (APP13)
/// and XMP (APP1) segments.
class ExifIptcWriter {
  static const int _soi = 0xD8;
  static const int _app0 = 0xE0;
  static const int _app1 = 0xE1;
  static const int _app13 = 0xED;

  /// Injects IPTC and XMP metadata directly into the JPEG binary stream.
  /// Pre-existing scan/quantization tables and image data are completely preserved.
  static Uint8List injectMetadata({
    required Uint8List jpegBytes,
    required String title,
    required List<String> keywords,
    required String category,
    String? description,
  }) {
    if (jpegBytes.length < 4 || jpegBytes[0] != 0xFF || jpegBytes[1] != _soi) {
      throw Exception('Invalid JPEG bytes: SOI marker missing.');
    }

    final desc = description ?? title;

    // 1. Build IPTC-NAA data
    final iptcPayload = _buildIptcPayload(title: title, keywords: keywords, description: desc);
    final app13Segment = _buildApp13Segment(iptcPayload);

    // 2. Build XMP data
    final xmpPayload = _buildXmpPayload(
      title: title,
      keywords: keywords,
      category: category,
      description: desc,
    );
    final app1Segment = _buildApp1Segment(xmpPayload);

    // 3. Locate injection point (immediately after SOI or after existing APP0 JFIF marker)
    int insertionIndex = 2; // after 0xFF, 0xD8
    if (jpegBytes.length > 4 && jpegBytes[2] == 0xFF && jpegBytes[3] == _app0) {
      final app0Length = (jpegBytes[4] << 8) | jpegBytes[5];
      insertionIndex = 4 + app0Length;
    }

    // 4. Assemble new byte stream
    final builder = BytesBuilder(copy: false);
    builder.add(jpegBytes.sublist(0, insertionIndex));
    builder.add(app1Segment);
    builder.add(app13Segment);
    builder.add(jpegBytes.sublist(insertionIndex));

    return builder.takeBytes();
  }

  /// Parses embedded IPTC and XMP metadata back from JPEG bytes
  static EmbeddedMetadata readMetadata(Uint8List bytes) {
    String title = '';
    final keywords = <String>[];
    String category = '';
    String description = '';

    // Fast extraction from XMP XML block
    final str = utf8.decode(bytes, allowMalformed: true);
    final xmpIndex = str.indexOf('<x:xmpmeta');
    if (xmpIndex != -1) {
      final xmpEnd = str.indexOf('</x:xmpmeta>', xmpIndex);
      if (xmpEnd != -1) {
        final xmp = str.substring(xmpIndex, xmpEnd + 12);

        // Extract Title
        final titleMatch = RegExp(r'<dc:title>[\s\S]*?<rdf:li[^>]*>([\s\S]*?)<\/rdf:li>').firstMatch(xmp);
        if (titleMatch != null) {
          title = _unescapeXml(titleMatch.group(1)!.trim());
        }

        // Extract Description
        final descMatch = RegExp(r'<dc:description>[\s\S]*?<rdf:li[^>]*>([\s\S]*?)<\/rdf:li>').firstMatch(xmp);
        if (descMatch != null) {
          description = _unescapeXml(descMatch.group(1)!.trim());
        }

        // Extract Category
        final catMatch = RegExp(r'<photoshop:Category>([\s\S]*?)<\/photoshop:Category>').firstMatch(xmp);
        if (catMatch != null) {
          category = _unescapeXml(catMatch.group(1)!.trim());
        }

        // Extract Keywords
        final kwMatches = RegExp(r'<rdf:li>([^<]+)<\/rdf:li>').allMatches(xmp);
        for (final m in kwMatches) {
          final kw = _unescapeXml(m.group(1)!.trim());
          if (kw != title && kw != description && !keywords.contains(kw)) {
            keywords.add(kw);
          }
        }
      }
    }

    return EmbeddedMetadata(
      title: title,
      keywords: keywords,
      category: category,
      description: description,
    );
  }

  static Uint8List _buildIptcPayload({
    required String title,
    required List<String> keywords,
    required String description,
  }) {
    final builder = BytesBuilder(copy: false);

    // Dataset 2:05 (ObjectName / Title)
    _writeIptcTag(builder, 2, 5, utf8.encode(title));

    // Dataset 2:25 (Keywords - repeatable)
    for (final kw in keywords) {
      if (kw.trim().isNotEmpty) {
        _writeIptcTag(builder, 2, 25, utf8.encode(kw.trim()));
      }
    }

    // Dataset 2:120 (Caption / Abstract)
    if (description.isNotEmpty) {
      _writeIptcTag(builder, 2, 120, utf8.encode(description));
    }

    return builder.takeBytes();
  }

  static void _writeIptcTag(BytesBuilder builder, int record, int tag, List<int> data) {
    builder.addByte(0x1C); // Tag marker
    builder.addByte(record);
    builder.addByte(tag);
    final len = data.length;
    builder.addByte((len >> 8) & 0xFF);
    builder.addByte(len & 0xFF);
    builder.add(data);
  }

  static Uint8List _buildApp13Segment(Uint8List iptcData) {
    final builder = BytesBuilder(copy: false);
    // Photoshop 3.0\0 header
    final header = ascii.encode('Photoshop 3.0\x00');
    builder.add(header);

    // 8BIM Resource Block for IPTC-NAA (0x0404)
    builder.add(ascii.encode('8BIM'));
    builder.addByte(0x04);
    builder.addByte(0x04);
    builder.addByte(0x00); // Empty pascal string name (1 byte length = 0)
    builder.addByte(0x00); // 2-byte word alignment padding

    final len = iptcData.length;
    builder.addByte((len >> 24) & 0xFF);
    builder.addByte((len >> 16) & 0xFF);
    builder.addByte((len >> 8) & 0xFF);
    builder.addByte(len & 0xFF);
    builder.add(iptcData);

    if (len % 2 != 0) {
      builder.addByte(0x00); // Even padding
    }

    final payload = builder.takeBytes();
    final totalLen = payload.length + 2; // + 2 for length itself

    final segment = BytesBuilder(copy: false);
    segment.addByte(0xFF);
    segment.addByte(_app13);
    segment.addByte((totalLen >> 8) & 0xFF);
    segment.addByte(totalLen & 0xFF);
    segment.add(payload);

    return segment.takeBytes();
  }

  static String _buildXmpPayload({
    required String title,
    required List<String> keywords,
    required String category,
    required String description,
  }) {
    final kwXml = keywords.map((k) => '     <rdf:li>${_escapeXml(k)}</rdf:li>').join('\n');
    return '<?xpacket begin="\uFEFF" id="W5M0MpCehiHzreSzNTczkc9d"?>\n'
        '<x:xmpmeta xmlns:x="adobe:ns:meta/" x:xmptk="Adobe Stock Contributor Tool">\n'
        ' <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">\n'
        '  <rdf:Description rdf:about=""\n'
        '    xmlns:dc="http://purl.org/dc/elements/1.1/"\n'
        '    xmlns:photoshop="http://ns.adobe.com/photoshop/1.0/">\n'
        '   <dc:title>\n'
        '    <rdf:Alt>\n'
        '     <rdf:li xml:lang="x-default">${_escapeXml(title)}</rdf:li>\n'
        '    </rdf:Alt>\n'
        '   </dc:title>\n'
        '   <dc:description>\n'
        '    <rdf:Alt>\n'
        '     <rdf:li xml:lang="x-default">${_escapeXml(description)}</rdf:li>\n'
        '    </rdf:Alt>\n'
        '   </dc:description>\n'
        '   <dc:subject>\n'
        '    <rdf:Bag>\n'
        '$kwXml\n'
        '    </rdf:Bag>\n'
        '   </dc:subject>\n'
        '   <photoshop:Category>${_escapeXml(category)}</photoshop:Category>\n'
        '  </rdf:Description>\n'
        ' </rdf:RDF>\n'
        '</x:xmpmeta>\n'
        '<?xpacket end="w"?>';
  }

  static Uint8List _buildApp1Segment(String xmpXml) {
    final builder = BytesBuilder(copy: false);
    builder.add(ascii.encode('http://ns.adobe.com/xap/1.0/\x00'));
    builder.add(utf8.encode(xmpXml));

    final payload = builder.takeBytes();
    final totalLen = payload.length + 2;

    final segment = BytesBuilder(copy: false);
    segment.addByte(0xFF);
    segment.addByte(_app1);
    segment.addByte((totalLen >> 8) & 0xFF);
    segment.addByte(totalLen & 0xFF);
    segment.add(payload);

    return segment.takeBytes();
  }

  static String _escapeXml(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  static String _unescapeXml(String input) {
    return input
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'")
        .replaceAll('&amp;', '&');
  }
}
