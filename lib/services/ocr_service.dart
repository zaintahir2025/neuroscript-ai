// On-device Latin text recognition for captured note pages with Gemini Vision AI fallback.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http/http.dart' as http;
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

/// On-device text recognizer leveraging Google ML Kit C++ runtime.
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

/// Intelligent Cloud AI Vision OCR recognizer powered by Google Gemini Vision.
/// High precision transcription for handwritten notes, printed test questions,
/// multi-column papers, and complex notation.
class GeminiVisionRecognizer implements OcrPageRecognizer {
  GeminiVisionRecognizer({
    required this.apiKey,
    this.model = 'gemini-2.5-flash',
    http.Client? httpClient,
  }) : _client = httpClient ?? http.Client();

  final String apiKey;
  final String model;
  final http.Client _client;

  @override
  Future<List<RecognizedOcrLine>> recognize(Uint8List imageBytes) async {
    if (apiKey.trim().isEmpty) {
      throw StateError(
        'Gemini API key is required for cloud vision transcription.',
      );
    }

    final base64Image = base64Encode(imageBytes);
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=${apiKey.trim()}',
    );

    final payload = {
      'contents': [
        {
          'parts': [
            {
              'text':
                  'You are a high-precision OCR transcription engine. Extract and transcribe every line of text, question, instruction, heading, bullet point, option, and formula from this note or question paper image verbatim.\n'
                  'Rules:\n'
                  '1. Transcribe line by line preserving logical line breaks.\n'
                  '2. Do not omit any text, numbers, or questions.\n'
                  '3. Do not add introductory or concluding commentary, summaries, or conversational text.\n'
                  '4. Return ONLY the transcribed lines of text.',
            },
            {
              'inline_data': {'mime_type': 'image/jpeg', 'data': base64Image},
            },
          ],
        },
      ],
      'generationConfig': {'temperature': 0.1},
    };

    final response = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      // If 2.5-flash is not available, try falling back to 1.5-flash
      if (model != 'gemini-1.5-flash') {
        final fallback = GeminiVisionRecognizer(
          apiKey: apiKey,
          model: 'gemini-1.5-flash',
          httpClient: _client,
        );
        return fallback.recognize(imageBytes);
      }
      throw Exception(
        'Gemini Vision OCR failed (HTTP ${response.statusCode}): ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = decoded['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      return const [];
    }

    final content = candidates.first['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>?;
    if (parts == null || parts.isEmpty) {
      return const [];
    }

    final rawText = parts.first['text'] as String? ?? '';
    final rawLines = rawText
        .split(RegExp(r'\r\n|\r|\n'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    return [
      for (final line in rawLines) RecognizedOcrLine(line, confidence: 0.98),
    ];
  }

  @override
  Future<void> close() async {
    _client.close();
  }
}

class OcrService {
  const OcrService({this.recognizer});

  /// Injectable adapter keeps ordering and aggregation testable without a device.
  final OcrPageRecognizer? recognizer;

  Future<OcrResult> transcribeImage(Uint8List imageBytes) =>
      processPages([imageBytes]);

  /// Processes multiple pages with dual-pass ML Kit and optional Smart AI Vision fallback.
  Future<OcrResult> processPages(
    List<Uint8List> pages, {
    List<Uint8List>? fallbackRawPages,
    String? geminiApiKey,
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
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);

    OcrPageRecognizer? engine = recognizer;

    if (engine == null) {
      if (!isNativeMobile) {
        if (geminiApiKey != null && geminiApiKey.trim().isNotEmpty) {
          engine = GeminiVisionRecognizer(apiKey: geminiApiKey.trim());
        } else {
          throw UnsupportedError(
            'On-device OCR is available on Android and iOS. On Web or desktop, please activate Smart AI Vision (Gemini) or type your notes.',
          );
        }
      } else {
        engine = MlKitPageRecognizer();
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

        // Pass 3: If still empty and a Gemini API key is provided and we were using local ML Kit, try Smart Vision AI
        if (pageLines.isEmpty &&
            geminiApiKey != null &&
            geminiApiKey.trim().isNotEmpty &&
            engine is! GeminiVisionRecognizer) {
          final aiEngine = GeminiVisionRecognizer(apiKey: geminiApiKey.trim());
          try {
            final rawBytes =
                (fallbackRawPages != null && pageIdx < fallbackRawPages.length)
                ? fallbackRawPages[pageIdx]
                : page;
            pageLines = await aiEngine.recognize(rawBytes);
          } on Exception catch (e) {
            debugPrint('Smart AI Vision fallback notice: $e');
          } finally {
            await aiEngine.close();
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
