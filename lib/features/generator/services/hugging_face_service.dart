import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

/// Free image generation service using Hugging Face Serverless Inference API.
///
/// Features:
/// - Uses black-forest-labs/FLUX.1-schnell model.
/// - Requires a free Hugging Face User Access Token (read token).
/// - Returns raw PNG/JPEG image bytes.
class HuggingFaceService {
  final String token;
  final http.Client _client;

  HuggingFaceService({
    required this.token,
    http.Client? client,
  }) : _client = client ?? http.Client();

  // Primary endpoint: Hugging Face Router
  static const String _primaryUrl =
      'https://router.huggingface.co/hf-inference/models/black-forest-labs/FLUX.1-schnell';
  static const String _fallbackUrl =
      'https://api-inference.huggingface.co/models/black-forest-labs/FLUX.1-schnell';

  /// Generates an image using Hugging Face FLUX.1-schnell.
  Future<Uint8List> generateImage({
    required String prompt,
    String aspectRatio = '1:1',
    bool forceMock = false,
  }) async {
    if (forceMock || token.isEmpty || token.startsWith('MOCK')) {
      return _generateMockImage(prompt);
    }

    final enhancedPrompt =
        '$prompt, sharp focus, clean studio lighting, sRGB, '
        'commercial stock illustration, highly detailed, no text, no watermark';

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'image/png, image/jpeg, image/*',
    };

    final body = jsonEncode({
      'inputs': enhancedPrompt,
      'parameters': {
        'num_inference_steps': 4,
      },
    });

    // Try primary router endpoint first
    try {
      final response = await _client
          .post(
            Uri.parse(_primaryUrl),
            headers: headers,
            body: body,
          )
          .timeout(const Duration(seconds: 45));

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        return response.bodyBytes;
      }

      // If 404 or router redirected, try fallback endpoint
      if (response.statusCode != 200) {
        debugPrint(
            'HuggingFace router error ${response.statusCode}: ${response.body}. Trying fallback...');
        final fallbackResponse = await _client
            .post(
              Uri.parse(_fallbackUrl),
              headers: headers,
              body: body,
            )
            .timeout(const Duration(seconds: 45));

        if (fallbackResponse.statusCode == 200 &&
            fallbackResponse.bodyBytes.isNotEmpty) {
          return fallbackResponse.bodyBytes;
        }

        throw Exception(
          'Hugging Face API returned ${fallbackResponse.statusCode}: ${fallbackResponse.body}',
        );
      }
    } catch (e) {
      debugPrint('HuggingFaceService exception: $e');
      rethrow;
    }

    throw Exception('Hugging Face image generation failed with unknown error.');
  }

  /// Generates a lightweight compliant mock JPEG for unit tests.
  Uint8List _generateMockImage(String prompt) {
    final image = img.Image(width: 512, height: 512);
    img.fill(image, color: img.ColorRgb8(245, 245, 250));
    img.fillCircle(
      image,
      x: 256,
      y: 256,
      radius: 120,
      color: img.ColorRgb8(168, 85, 247),
    );
    return Uint8List.fromList(img.encodeJpg(image, quality: 85));
  }
}
