// ============================================================================
// NeuroScript AI: Phase 3 Optical Character Recognition & Preprocessing Tests
// File: test/phase3_ocr_test.dart
// ============================================================================

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:neuro_script/data/models/ocr_models.dart';
import 'package:neuro_script/services/image_preprocessor.dart';
import 'package:neuro_script/services/ocr_service.dart';

class _FakeRecognizer implements OcrPageRecognizer {
  _FakeRecognizer(this.pages);
  final List<List<RecognizedOcrLine>> pages;
  int _index = 0;

  @override
  Future<List<RecognizedOcrLine>> recognize(Uint8List imageBytes) async =>
      pages[_index++];

  @override
  Future<void> close() async {}
}

void main() {
  group('Phase 3 - Image Preprocessing Pipeline (FR-02)', () {
    test(
      'ImagePreprocessor resizes, binarizes, and calculates deskew in isolate',
      () async {
        // 1. Synthesize a mock handwritten note image (800x600 with mock dark ink lines)
        final testImage = img.Image(width: 800, height: 600);
        img.fill(
          testImage,
          color: img.ColorRgb8(245, 245, 240),
        ); // light paper background

        // Draw dark horizontal strokes simulating handwritten text
        for (var y = 100; y < 500; y += 40) {
          for (var x = 80; x < 720; x++) {
            if ((x % 30) < 22) {
              testImage.setPixelRgb(x, y, 20, 20, 25); // dark ink
              testImage.setPixelRgb(x, y + 1, 20, 20, 25);
            }
          }
        }

        final rawJpgBytes = img.encodeJpg(testImage);

        const preprocessor = ImagePreprocessor();
        final result = await preprocessor.preprocess(rawJpgBytes);

        // Verify processing invariants
        expect(result.processedBytes, isNotEmpty);
        expect(result.width, lessThanOrEqualTo(1600));
        expect(result.height, lessThanOrEqualTo(1600));
        expect(result.estimatedSkewAngle, inInclusiveRange(-5.0, 5.0));
        expect(result.stageSummary, contains('global thresholding'));
      },
    );

    test(
      'ImagePreprocessor detects and deskews angular tilt on rotated documents',
      () async {
        // Create an image with clear text line structure
        final base = img.Image(width: 800, height: 600);
        img.fill(base, color: img.ColorRgb8(250, 250, 250));
        for (var y = 120; y < 480; y += 45) {
          for (var x = 100; x < 700; x++) {
            if ((x % 20) < 16) {
              base.setPixelRgb(x, y, 15, 15, 15);
              base.setPixelRgb(x, y + 1, 15, 15, 15);
              base.setPixelRgb(x, y + 2, 15, 15, 15);
            }
          }
        }

        // Rotate by 5.0 degrees
        final rotated = img.copyRotate(
          base,
          angle: 5.0,
          interpolation: img.Interpolation.linear,
        );
        final rawBytes = img.encodeJpg(rotated);

        const preprocessor = ImagePreprocessor();
        final result = await preprocessor.preprocess(
          rawBytes,
          options: const PreprocessingOptions(autoDeskew: true),
        );

        expect(result.wasRotated, isTrue);
        expect(result.estimatedSkewAngle.abs(), inInclusiveRange(2.0, 8.0));
        expect(result.stageSummary, contains('rotation deskew applied'));
      },
    );

    test('ImagePreprocessor returns 0.0 tilt for blank or low-contrast images safely', () async {
      final blank = img.Image(width: 400, height: 400);
      img.fill(blank, color: img.ColorRgb8(240, 240, 240));
      final rawBytes = img.encodeJpg(blank);

      const preprocessor = ImagePreprocessor();
      final result = await preprocessor.preprocess(rawBytes);

      expect(result.estimatedSkewAngle, equals(0.0));
      expect(result.wasRotated, isFalse);
    });
  });

  group('Phase 3 - OCR Transcription Engine (FR-03)', () {
    test(
      'OcrService extracts 1-based ordered numbered lines from captured pages',
      () async {
        final ocrService = OcrService(
          recognizer: _FakeRecognizer([
            [
              const RecognizedOcrLine('First line', confidence: 0.87),
              const RecognizedOcrLine('Second line'),
            ],
          ]),
        );
        final result = await ocrService.processPages([
          Uint8List.fromList([1, 2, 3, 4]),
        ]);

        expect(result.lines, isNotEmpty);
        expect(result.pageCount, equals(1));
        expect(result.fullText, equals('First line\nSecond line'));

        // Verify strict 1-based ordering
        for (var i = 0; i < result.lines.length; i++) {
          final line = result.lines[i];
          expect(line.lineNumber, equals(i + 1));
          expect(line.text.trim(), isNotEmpty);
        }
        expect(result.lines.first.confidence, closeTo(0.87, 0.001));
        expect(result.lines.last.confidence, isNull);
      },
    );

    test(
      'OCR preserves page order and continuously numbers multiple pages',
      () async {
        final service = OcrService(
          recognizer: _FakeRecognizer([
            [const RecognizedOcrLine('Page one')],
            [const RecognizedOcrLine('Page two')],
          ]),
        );
        final result = await service.processPages([
          Uint8List.fromList([1]),
          Uint8List.fromList([2]),
        ]);

        expect(result.lines.map((line) => line.lineNumber), [1, 2]);
        expect(result.lines.map((line) => line.text), ['Page one', 'Page two']);
        expect(result.pageCount, 2);
      },
    );

    test('OcrService parses raw multi-line transcripts accurately', () {
      const ocrService = OcrService();
      const rawText = '''
        First line of biology notes
        Second line about cellular respiration
        Third line explaining ATP synthesis
      ''';

      final result = ocrService.parseRawTranscript(rawText);

      expect(result.lines.length, equals(3));
      expect(result.lines[0].lineNumber, equals(1));
      expect(result.lines[0].text, equals('First line of biology notes'));
      expect(result.lines[1].lineNumber, equals(2));
      expect(result.lines[2].lineNumber, equals(3));
      expect(result.fullText, contains('cellular respiration'));
    });
  });

  group('Phase 3 - OCR Data Models Serialization', () {
    test('OcrLine serializes and deserializes accurately', () {
      const line = OcrLine(
        lineNumber: 4,
        text: 'ATP and NADPH are synthesized during light reactions.',
        confidence: 0.96,
      );

      final json = line.toJson();
      final restored = OcrLine.fromJson(json);

      expect(restored.lineNumber, equals(4));
      expect(restored.text, equals(line.text));
      expect(restored.confidence, closeTo(0.96, 0.001));

      final updated = line.copyWith(text: 'Updated line text');
      expect(updated.lineNumber, equals(4));
      expect(updated.text, equals('Updated line text'));
    });

    test('OcrResult serializes and deserializes accurately', () {
      final lines = [
        const OcrLine(lineNumber: 1, text: 'Heading'),
        const OcrLine(lineNumber: 2, text: 'Detail item'),
      ];
      final ocrResult = OcrResult(
        lines: lines,
        fullText: 'Heading\nDetail item',
        pageCount: 2,
        timestamp: DateTime(2026, 11, 8, 12, 0),
      );

      final json = ocrResult.toJson();
      final restored = OcrResult.fromJson(json);

      expect(restored.lines.length, equals(2));
      expect(restored.lines[0].lineNumber, equals(1));
      expect(restored.lines[1].lineNumber, equals(2));
      expect(restored.pageCount, equals(2));
      expect(restored.fullText, equals('Heading\nDetail item'));
    });
  });
}
