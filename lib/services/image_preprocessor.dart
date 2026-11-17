// ============================================================================
// NeuroScript AI: Privacy-Preserving Study Platform for Neurodivergent Learners
// File: lib/services/image_preprocessor.dart
//
// Description:
//   Pure-Dart image enhancement and preprocessing pipeline (FR-02).
//   Executes inside a background isolate via [compute] to maintain 60fps UI responsiveness.
//
// Processing Stages:
//   1. Resize: Scales high-resolution camera captures to standard max 1600px dimension.
//   2. Grayscale Conversion: Eliminates chrominance noise and isolates ink luminance.
//   3. Global Contrast Boost: Increases contrast to help separate ink from paper.
//   4. Gaussian Smoothing: Softens some camera noise and paper texture.
//   5. Global Thresholding: Converts pixels to black or white using image luminance.
//   6. Skew Estimation: Reports a coarse angle estimate; it does not rotate the image.
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Encapsulates the output of the optical preprocessing stage.
class PreprocessedImageResult {
  const PreprocessedImageResult({
    required this.processedBytes,
    required this.width,
    required this.height,
    required this.estimatedSkewAngle,
    required this.stageSummary,
  });

  /// High-contrast binarized image bytes ready for OCR transcription.
  final Uint8List processedBytes;

  /// Width in pixels of the processed image.
  final int width;

  /// Height in pixels of the processed image.
  final int height;

  /// Estimated tilt/skew angle in degrees (0.0 means perfectly horizontal).
  final double estimatedSkewAngle;

  /// Diagnostic description of applied enhancements.
  final String stageSummary;
}

/// Service executing image enhancement in an isolate.
class ImagePreprocessor {
  const ImagePreprocessor();

  /// Preprocesses captured raw photo bytes in a background isolate.
  Future<PreprocessedImageResult> preprocess(Uint8List rawBytes) async {
    return compute(_isolatePipeline, rawBytes);
  }

  /// Top-level or static function executing inside the Dart worker isolate.
  static PreprocessedImageResult _isolatePipeline(Uint8List rawBytes) {
    // 1. Decode raw bytes
    final original = img.decodeImage(rawBytes);
    if (original == null) {
      throw Exception('Failed to decode image bytes for preprocessing.');
    }

    // 2. Resize to max bounding box of 1600x1600 while preserving aspect ratio
    const maxDim = 1600;
    img.Image resized;
    if (original.width > maxDim || original.height > maxDim) {
      if (original.width >= original.height) {
        resized = img.copyResize(original, width: maxDim);
      } else {
        resized = img.copyResize(original, height: maxDim);
      }
    } else {
      resized = original;
    }

    // 3. Grayscale conversion
    final gray = img.grayscale(resized);

    // 4. Contrast normalization (boost contrast to emphasize ink strokes)
    final highContrast = img.adjustColor(
      gray,
      contrast: 1.35,
      brightness: 1.05,
    );

    // 5. Gentle Gaussian blur to suppress camera sensor noise and paper grain
    final denoised = img.gaussianBlur(highContrast, radius: 1);

    // 6. Adaptive binarization (Otsu-style luminance split)
    // Compute average luminance
    var totalLuminance = 0;
    final pixelCount = denoised.width * denoised.height;
    for (var y = 0; y < denoised.height; y++) {
      for (var x = 0; x < denoised.width; x++) {
        final p = denoised.getPixel(x, y);
        totalLuminance += p.r.toInt();
      }
    }

    final avgLuminance = (totalLuminance / pixelCount).clamp(60, 200).toInt();
    final threshold = (avgLuminance * 0.88).toInt();

    // Apply binarization
    for (var y = 0; y < denoised.height; y++) {
      for (var x = 0; x < denoised.width; x++) {
        final p = denoised.getPixel(x, y);
        final lum = p.r.toInt();
        if (lum > threshold) {
          // Paper background -> White
          denoised.setPixelRgb(x, y, 255, 255, 255);
        } else {
          // Ink stroke -> Deep Charcoal
          denoised.setPixelRgb(x, y, 20, 20, 20);
        }
      }
    }

    // 7. Deskew estimation (heuristic horizontal projection variance)
    final estimatedSkew = _estimateSkewAngle(denoised);

    // 8. Encode to JPEG bytes
    final outputJpg = Uint8List.fromList(img.encodeJpg(denoised, quality: 85));

    return PreprocessedImageResult(
      processedBytes: outputJpg,
      width: denoised.width,
      height: denoised.height,
      estimatedSkewAngle: estimatedSkew,
      stageSummary:
          'Global contrast boost, Gaussian smoothing, global thresholding, estimated skew ($estimatedSkew°; not corrected)',
    );
  }

  /// Calculates horizontal black-pixel projection variance across a subset of lines
  /// to estimate document tilt between -5° and +5°.
  static double _estimateSkewAngle(img.Image image) {
    // Sample horizontal line density
    var maxVariance = 0.0;
    var bestAngle = 0.0;

    // Scan minor angle increments (-2.0 to +2.0 degrees)
    for (var angle = -2.0; angle <= 2.0; angle += 1.0) {
      final rad = angle * (3.141592653589793 / 180.0);
      final sinA = rad;
      final step = (image.height / 30).floor().clamp(5, 50);

      final rowCounts = <int>[];
      for (var y = step; y < image.height - step; y += step) {
        var darkCount = 0;
        for (var x = 0; x < image.width; x += 10) {
          final sampleY = (y + (x - image.width / 2) * sinA).round();
          if (sampleY >= 0 && sampleY < image.height) {
            final p = image.getPixel(x, sampleY);
            if (p.r < 100) darkCount++;
          }
        }
        rowCounts.add(darkCount);
      }

      // Calculate variance of row ink density
      if (rowCounts.isNotEmpty) {
        final mean = rowCounts.reduce((a, b) => a + b) / rowCounts.length;
        final variance =
            rowCounts
                .map((c) => (c - mean) * (c - mean))
                .reduce((a, b) => a + b) /
            rowCounts.length;

        if (variance > maxVariance) {
          maxVariance = variance;
          bestAngle = angle;
        }
      }
    }

    return bestAngle;
  }
}
