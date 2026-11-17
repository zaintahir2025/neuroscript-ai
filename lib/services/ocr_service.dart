// On-device Latin text recognition for captured note pages.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';

import '../data/models/ocr_models.dart';

abstract interface class OcrPageRecognizer {
  Future<List<RecognizedOcrLine>> recognize(Uint8List imageBytes);
  Future<void> close();
}

class RecognizedOcrLine {
  const RecognizedOcrLine(this.text, {this.confidence});

  final String text;
  final double? confidence;
}

class MlKitPageRecognizer implements OcrPageRecognizer {
  MlKitPageRecognizer() : _recognizer = TextRecognizer();

  final TextRecognizer _recognizer;

  @override
  Future<List<RecognizedOcrLine>> recognize(Uint8List imageBytes) async {
    final directory = await getTemporaryDirectory();
    final file = File(
      '${directory.path}${Platform.pathSeparator}neuroscript_ocr_${DateTime.now().microsecondsSinceEpoch}.jpg',
    );
    try {
      await file.writeAsBytes(imageBytes, flush: true);
      final result = await _recognizer.processImage(
        InputImage.fromFilePath(file.path),
      );
      return [
        for (final block in result.blocks)
          for (final line in block.lines)
            RecognizedOcrLine(line.text, confidence: line.confidence),
      ];
    } finally {
      if (await file.exists()) await file.delete();
    }
  }

  @override
  Future<void> close() => _recognizer.close();
}

class OcrService {
  const OcrService({this.recognizer});

  /// Injectable adapter keeps ordering and aggregation testable without a device.
  final OcrPageRecognizer? recognizer;

  Future<OcrResult> transcribeImage(Uint8List imageBytes) =>
      processPages([imageBytes]);

  Future<OcrResult> processPages(List<Uint8List> pages) async {
    if (pages.length > 5) {
      throw ArgumentError.value(pages.length, 'pages', 'Maximum is 5 pages.');
    }
    if (pages.isEmpty) {
      return OcrResult(
        lines: const [],
        fullText: '',
        pageCount: 0,
        timestamp: DateTime.now(),
      );
    }
    if ((kIsWeb ||
            (defaultTargetPlatform != TargetPlatform.android &&
                defaultTargetPlatform != TargetPlatform.iOS)) &&
        recognizer == null) {
      throw UnsupportedError(
        'On-device OCR is available on Android and iOS. On this device, go back and type or paste your notes instead.',
      );
    }

    final engine = recognizer ?? MlKitPageRecognizer();
    final lines = <OcrLine>[];
    try {
      for (final page in pages) {
        final pageLines = await engine.recognize(page);
        for (final line in pageLines) {
          final text = line.text.trim();
          if (text.isEmpty) continue;
          lines.add(
            OcrLine(
              lineNumber: lines.length + 1,
              text: text,
              confidence: line.confidence?.clamp(0.0, 1.0).toDouble(),
            ),
          );
        }
      }
    } finally {
      await engine.close();
    }

    return OcrResult(
      lines: lines,
      fullText: lines.map((line) => line.text).join('\n'),
      pageCount: pages.length,
      timestamp: DateTime.now(),
    );
  }

  OcrResult parseRawTranscript(String rawText, {int pageCount = 1}) {
    final lines = rawText
        .split(RegExp(r'\r\n|\r|\n'))
        .map((text) => text.trim())
        .where((text) => text.isNotEmpty)
        .toList(growable: false)
        .asMap()
        .entries
        .map(
          (entry) => OcrLine(
            lineNumber: entry.key + 1,
            text: entry.value,
            confidence: null,
          ),
        )
        .toList(growable: false);
    return OcrResult(
      lines: lines,
      fullText: lines.map((line) => line.text).join('\n'),
      pageCount: pageCount,
      timestamp: DateTime.now(),
    );
  }
}
