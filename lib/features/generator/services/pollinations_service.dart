import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

/// Free image generation service using Pollinations.ai (FLUX.1 / SDXL).
///
/// Features:
/// - 100% Free, NO API key or registration required.
/// - Uses state-of-the-art FLUX.1 model.
/// - Produces high-fidelity commercial stock illustrations matching prompts.
class PollinationsService {
  final http.Client _client;

  PollinationsService({http.Client? client})
      : _client = client ?? http.Client();

  static const String _baseUrl = 'https://image.pollinations.ai/prompt';

  /// Generates an image using Pollinations AI (FLUX.1).
  ///
  /// Returns raw JPEG/PNG image bytes.
  Future<Uint8List> generateImage({
    required String prompt,
    String aspectRatio = '1:1',
    bool forceMock = false,
  }) async {
    if (forceMock) {
      return _generateMockImage(prompt);
    }

    // Determine dimensions to meet Adobe Stock >= 4 Megapixel requirement
    int width = 2048;
    int height = 2048;
    if (aspectRatio == '16:9') {
      width = 2688;
      height = 1512;
    } else if (aspectRatio == '9:16') {
      width = 1512;
      height = 2688;
    } else if (aspectRatio == '4:3') {
      width = 2400;
      height = 1800;
    } else if (aspectRatio == '3:4') {
      width = 1800;
      height = 2400;
    }

    // Adobe Stock–optimized commercial prompt
    final enhancedPrompt =
        '$prompt, sharp focus, clean commercial lighting, sRGB, '
        'high resolution, highly detailed, commercial stock photography illustration, '
        'no text, no watermark, no logo';

    final seed = Random().nextInt(1000000);
    final encodedPrompt = Uri.encodeComponent(enhancedPrompt);
    final uri = Uri.parse(
      '$_baseUrl/$encodedPrompt?width=$width&height=$height&model=flux&nologo=true&seed=$seed',
    );

    try {
      final response = await _client.get(
        uri,
        headers: {
          'Accept': 'image/jpeg, image/png, image/*',
          'User-Agent': 'StockCraft/1.0',
        },
      ).timeout(const Duration(seconds: 40));

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        return response.bodyBytes;
      } else {
        throw Exception(
          'Pollinations AI returned HTTP ${response.statusCode}: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      debugPrint('PollinationsService exception: $e');
      rethrow;
    }
  }

  /// Generates a lightweight compliant mock JPEG for unit tests.
  Uint8List _generateMockImage(String prompt) {
    final image = img.Image(width: 512, height: 512);
    img.fill(image, color: img.ColorRgb8(240, 243, 246));
    img.fillCircle(
      image,
      x: 256,
      y: 256,
      radius: 120,
      color: img.ColorRgb8(59, 130, 246),
    );
    return Uint8List.fromList(img.encodeJpg(image, quality: 85));
  }
}
