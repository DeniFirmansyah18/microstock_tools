import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

enum UpscaleAlgorithm {
  cubic,
  linear,
  nearest,
  average,
}

/// In-app pure Dart image upscaler with Adobe Stock JPEG compliance
class ImageUpscaler {
  /// Upscales an image given in [bytes] to [targetWidth] and [targetHeight].
  /// Encodes output into JPEG format (95% quality sRGB).
  static Future<Uint8List> upscale({
    required Uint8List bytes,
    required int targetWidth,
    required int targetHeight,
    UpscaleAlgorithm algorithm = UpscaleAlgorithm.cubic,
    int jpegQuality = 95,
  }) async {
    return compute(_processUpscale, _UpscaleParams(
      bytes: bytes,
      targetWidth: targetWidth,
      targetHeight: targetHeight,
      algorithm: algorithm,
      quality: jpegQuality,
    ));
  }

  /// Upscales by a scalar multiplication factor (e.g. 2.0x, 4.0x)
  static Future<Uint8List> upscaleByFactor({
    required Uint8List bytes,
    required double factor,
    UpscaleAlgorithm algorithm = UpscaleAlgorithm.cubic,
    int jpegQuality = 95,
  }) async {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw Exception('Unable to decode image bytes for upscaling.');
    }

    final targetWidth = (decoded.width * factor).round();
    final targetHeight = (decoded.height * factor).round();

    return upscale(
      bytes: bytes,
      targetWidth: targetWidth,
      targetHeight: targetHeight,
      algorithm: algorithm,
      jpegQuality: jpegQuality,
    );
  }

  static Uint8List _processUpscale(_UpscaleParams params) {
    final original = img.decodeImage(params.bytes);
    if (original == null) {
      throw Exception('Failed to decode source image.');
    }

    img.Interpolation interpolation;
    switch (params.algorithm) {
      case UpscaleAlgorithm.cubic:
        interpolation = img.Interpolation.cubic;
        break;
      case UpscaleAlgorithm.linear:
        interpolation = img.Interpolation.linear;
        break;
      case UpscaleAlgorithm.average:
        interpolation = img.Interpolation.average;
        break;
      case UpscaleAlgorithm.nearest:
        interpolation = img.Interpolation.nearest;
        break;
    }

    final resized = img.copyResize(
      original,
      width: params.targetWidth,
      height: params.targetHeight,
      interpolation: interpolation,
    );

    return Uint8List.fromList(img.encodeJpg(resized, quality: params.quality));
  }
}

class _UpscaleParams {
  final Uint8List bytes;
  final int targetWidth;
  final int targetHeight;
  final UpscaleAlgorithm algorithm;
  final int quality;

  _UpscaleParams({
    required this.bytes,
    required this.targetWidth,
    required this.targetHeight,
    required this.algorithm,
    required this.quality,
  });
}
