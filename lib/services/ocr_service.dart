// On-device Latin text recognition for captured note pages (Milestone 3).

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

/// On-device text recognizer leveraging Google ML Kit C++ runtime (FR-03).
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

  /// Processes multiple pages with dual-pass ML Kit on-device recognition.
  Future<OcrResult> processPages(
    List<Uint8List> pages, {
    List<Uint8List>? fallbackRawPages,
  }) async {
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

    final isNativeMobile =
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;

    OcrPageRecognizer? engine = recognizer;

    if (engine == null) {
      if (isNativeMobile) {
        engine = MlKitPageRecognizer();
      } else {
        // Fallback for non-mobile hosts without physical camera or ML Kit native libs
        return OcrResult(
          lines: const [],
          fullText: '',
          pageCount: pages.length,
          timestamp: DateTime.now(),
        );
      }
    }

    final lines = <OcrLine>[];
    try {
      for (var pageIdx = 0; pageIdx < pages.length; pageIdx++) {
        final page = pages[pageIdx];
        var pageLines = await engine.recognize(page);

        // Pass 2: If 0 lines detected on preprocessed page, retry with the raw page
        if (pageLines.isEmpty &&
            fallbackRawPages != null &&
            pageIdx < fallbackRawPages.length) {
          final rawPage = fallbackRawPages[pageIdx];
          if (rawPage != page) {
            pageLines = await engine.recognize(rawPage);
          }
        }

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
