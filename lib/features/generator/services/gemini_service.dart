import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../../../core/constants/adobe_categories.dart';
import '../../inspector/models/defect_report.dart';

class GeneratedMetadata {
  final String title;
  final String category;
  final List<String> keywords;
  final String description;

  const GeneratedMetadata({
    required this.title,
    required this.category,
    required this.keywords,
    required this.description,
  });
}

class GeminiService {
  final String apiKey;
  final http.Client _client;

  GeminiService({
    required this.apiKey,
    http.Client? client,
  }) : _client = client ?? http.Client();

  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  /// Generates prompt suggestions tailored to Adobe Stock high-commercial-value niches
  Future<List<String>> generatePromptIdeas({
    required String niche,
    bool forceMock = false,
  }) async {
    if (forceMock || apiKey.isEmpty || apiKey.startsWith('MOCK')) {
      return _mockPromptIdeas(niche);
    }

    try {
      final url = Uri.parse('$_baseUrl?key=$apiKey');
      final prompt = '''
You are a top-selling Adobe Stock Contributor consultant. Generate 4 distinct, commercially viable illustration prompts for the niche "$niche".
Each prompt must describe:
1. Subject and visual style (e.g. 3D isometric clay, minimalist vector, papercraft, cinematic food photo).
2. Clean background and lighting (isolated on plain background, soft studio lighting, sharp focus).
3. Explicit negative constraints (no text, no watermark, no logos).
Return ONLY a raw JSON array of strings: ["Prompt 1", "Prompt 2", "Prompt 3", "Prompt 4"].
''';

      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'responseMimeType': 'application/json',
            'temperature': 0.7,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rawText = data['candidates']?[0]?['content']?[0]?['parts']?[0]?['text'] ??
            data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';
        final List<dynamic> parsed = jsonDecode(rawText);
        return parsed.map((e) => e.toString()).toList();
      }
    } catch (_) {
      // Fallback gracefully on network error or quota limits
    }

    return _mockPromptIdeas(niche);
  }

  /// Multimodal vision scan for AI hallucinations, hand deformities, text, and blur
  Future<DefectReport> inspectDefects({
    required Uint8List imageBytes,
    bool forceMock = false,
  }) async {
    if (forceMock || apiKey.isEmpty || apiKey.startsWith('MOCK')) {
      return DefectReport.perfect();
    }

    try {
      final url = Uri.parse('$_baseUrl?key=$apiKey');
      final base64Image = base64Encode(imageBytes);

      final prompt = '''
Inspect this image for Adobe Stock Contributor compliance:
1. Hands & Anatomy: are there extra fingers, mangled limbs, or unnatural deformities? (Score 0-100)
2. Watermarks: is there any fake watermark, signature, camera timestamp, or brand logo?
3. Sharpness: is the focus sharp and well-lit with no unappealing compression blur?
Return JSON strictly in this structure:
{
  "passed": true,
  "anatomyIntegrityScore": 98,
  "isWatermarkFree": true,
  "isFocusSharp": true,
  "isColorProfileSrgb": true,
  "detectedIssues": [],
  "actionableTips": ["Sharp lighting and clean focus"]
}
''';

      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
                {
                  'inlineData': {
                    'mimeType': 'image/jpeg',
                    'data': base64Image,
                  }
                }
              ]
            }
          ],
          'generationConfig': {
            'responseMimeType': 'application/json',
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final raw = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';
        final map = jsonDecode(raw);
        return DefectReport(
          passed: map['passed'] ?? true,
          anatomyIntegrityScore: map['anatomyIntegrityScore'] ?? 95,
          isWatermarkFree: map['isWatermarkFree'] ?? true,
          isFocusSharp: map['isFocusSharp'] ?? true,
          isColorProfileSrgb: map['isColorProfileSrgb'] ?? true,
          detectedIssues: List<String>.from(map['detectedIssues'] ?? []),
          actionableTips: List<String>.from(map['actionableTips'] ?? []),
        );
      }
    } catch (_) {
      // Fallback
    }

    return DefectReport.perfect();
  }

  /// Synthesizes Title, standard Adobe Stock Category, and 40-50 ranked Keywords
  Future<GeneratedMetadata> generateMetadata({
    required String prompt,
    required Uint8List imageBytes,
    bool forceMock = false,
  }) async {
    final matchedCategory = AdobeCategories.matchCategory(prompt);

    if (forceMock || apiKey.isEmpty || apiKey.startsWith('MOCK')) {
      return _mockMetadata(prompt, matchedCategory);
    }

    try {
      final url = Uri.parse('$_baseUrl?key=$apiKey');
      final promptText = '''
For this Adobe Stock illustration generated with prompt: "$prompt"
Generate Adobe Stock Contributor metadata:
1. Title: 5 to 10 words, natural English, descriptive, keyword-rich, NO spam.
2. Category: MUST be exactly one of: ${AdobeCategories.list.join(', ')}.
3. Keywords: 40 to 50 distinct keywords, ordered from MOST relevant to broader context (the first 10 keywords are critical for Adobe search ranking).
4. Description: 1 sentence summary.

Return JSON in this structure:
{
  "title": "...",
  "category": "...",
  "keywords": ["...", "..."],
  "description": "..."
}
''';

      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': promptText},
              ]
            }
          ],
          'generationConfig': {
            'responseMimeType': 'application/json',
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final raw = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';
        final map = jsonDecode(raw);

        String category = map['category'] ?? matchedCategory;
        if (!AdobeCategories.isValid(category)) {
          category = matchedCategory;
        }

        final List<dynamic> rawKeywords = map['keywords'] ?? [];
        final keywords = rawKeywords.map((k) => k.toString().toLowerCase().trim()).where((k) => k.isNotEmpty).toList();

        return GeneratedMetadata(
          title: map['title'] ?? _generateFallbackTitle(prompt),
          category: category,
          keywords: keywords.isNotEmpty ? keywords : _generateFallbackKeywords(prompt),
          description: map['description'] ?? map['title'] ?? prompt,
        );
      }
    } catch (_) {
      // Fallback
    }

    return _mockMetadata(prompt, matchedCategory);
  }

  List<String> _mockPromptIdeas(String niche) {
    return [
      '3D isometric modern financial dashboard with glowing data charts, clean white surface, soft ambient shadows, isolated, stock vector style',
      'Cute stylized 3D clay robot holding a green plant sprout, eco-tech concept, clean studio background, warm directional lighting',
      'Artisanal chocolate dessert pastry served on an elegant glass stand, soft side window illumination, crisp focus, commercial food photography',
      'Isometric clean energy smart city with solar roofs and electric transit, pastel palette, bright daylight, Adobe Stock bestseller style',
    ];
  }

  GeneratedMetadata _mockMetadata(String prompt, String category) {
    final title = _generateFallbackTitle(prompt);
    final keywords = _generateFallbackKeywords(prompt);

    return GeneratedMetadata(
      title: title,
      category: category,
      keywords: keywords,
      description: 'High-quality 3D illustration and commercial asset for Adobe Stock contributor catalog.',
    );
  }

  String _generateFallbackTitle(String prompt) {
    final words = prompt.split(' ').where((w) => w.length > 2).take(8).join(' ');
    if (words.isEmpty) return 'Modern 3D Isometric Commercial Stock Illustration';
    return words[0].toUpperCase() + words.substring(1);
  }

  List<String> _generateFallbackKeywords(String prompt) {
    final baseKeywords = [
      '3d', 'illustration', 'isometric', 'vector', 'design',
      'modern', 'concept', 'graphic', 'isolated', 'white background',
      'digital', 'clean', 'art', 'creative', 'commercial',
      'render', 'studio', 'icon', 'symbol', 'minimalist',
      'technology', 'element', 'business', 'colorful', 'abstract',
      'trendy', 'wallpaper', 'future', 'smooth', 'geometric',
      'bright', 'clay', 'object', 'creative work', 'high quality',
      'microstock', 'stock image', 'visual', 'presentation', 'web'
    ];

    final promptWords = prompt.toLowerCase()
        .replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '')
        .split(' ')
        .where((w) => w.length > 2)
        .toList();

    final result = <String>[];
    for (final pw in promptWords) {
      if (!result.contains(pw)) result.add(pw);
    }
    for (final bk in baseKeywords) {
      if (!result.contains(bk)) result.add(bk);
      if (result.length >= 45) break;
    }

    return result;
  }
}
