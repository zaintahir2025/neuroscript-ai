// ============================================================================
// NeuroScript AI: Privacy-Preserving Study Platform for Neurodivergent Learners
// File: lib/data/models/ocr_models.dart
//
// Description:
//   Data serialization models for optical character recognition (OCR) lines
//   and note transcription results (FR-03, FR-04).
//
// Key Concepts:
//   - 1-Based Ordered Lines: Every extracted text line maintains a canonical 1-based
//     index matching the physical handwritten note lines.
//   - Optional confidence: Android supplies recognition confidence; other paths may not.
//   - Immutability with copyWith: Supports interactive editing, merging, adding,
//     and deletion in the OCR Review Screen before lesson synthesis.
// ============================================================================

import 'dart:convert';

/// Represents a single 1-based numbered text line extracted via OCR from handwritten notes.
class OcrLine {
  const OcrLine({
    required this.lineNumber,
    required this.text,
    this.confidence,
  });

  /// 1-based line number corresponding to the physical position in the student note.
  final int lineNumber;

  /// The transcribed or edited textual content of this line.
  final String text;

  /// Recognition confidence score (0.0 to 1.0).
  final double? confidence;

  /// Creates a copy of this line with optional updated fields.
  OcrLine copyWith({int? lineNumber, String? text, double? confidence}) {
    return OcrLine(
      lineNumber: lineNumber ?? this.lineNumber,
      text: text ?? this.text,
      confidence: confidence ?? this.confidence,
    );
  }

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() => {
    'lineNumber': lineNumber,
    'text': text,
    'confidence': confidence,
  };

  /// Deserializes from a JSON map.
  factory OcrLine.fromJson(Map<String, dynamic> json) => OcrLine(
    lineNumber: json['lineNumber'] as int? ?? 1,
    text: json['text'] as String? ?? '',
    confidence: (json['confidence'] as num?)?.toDouble(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OcrLine &&
          runtimeType == other.runtimeType &&
          lineNumber == other.lineNumber &&
          text == other.text;

  @override
  int get hashCode => lineNumber.hashCode ^ text.hashCode;
}

/// Aggregated result of an optical acquisition and transcription session.
class OcrResult {
  const OcrResult({
    required this.lines,
    required this.fullText,
    this.pageCount = 1,
    required this.timestamp,
  });

  /// Ordered list of 1-based extracted lines.
  final List<OcrLine> lines;

  /// Concatenated raw transcript of all lines.
  final String fullText;

  /// Number of pages captured in the burst session (1 to 5).
  final int pageCount;

  /// Timestamp when optical acquisition was performed.
  final DateTime timestamp;

  /// Factory constructing an [OcrResult] directly from a list of plain string lines.
  factory OcrResult.fromLines(List<String> rawLines, {int pageCount = 1}) {
    final cleanLines = <OcrLine>[];
    for (var i = 0; i < rawLines.length; i++) {
      final lineText = rawLines[i].trim();
      if (lineText.isNotEmpty) {
        cleanLines.add(
          OcrLine(
            lineNumber: cleanLines.length + 1,
            text: lineText,
            confidence: null,
          ),
        );
      }
    }

    final fullText = cleanLines.map((l) => l.text).join('\n');
    return OcrResult(
      lines: cleanLines,
      fullText: fullText,
      pageCount: pageCount,
      timestamp: DateTime.now(),
    );
  }

  /// Serializes to JSON.
  Map<String, dynamic> toJson() => {
    'lines': lines.map((l) => l.toJson()).toList(),
    'fullText': fullText,
    'pageCount': pageCount,
    'timestamp': timestamp.toIso8601String(),
  };

  /// Deserializes from JSON.
  factory OcrResult.fromJson(Map<String, dynamic> json) {
    return OcrResult(
      lines: (json['lines'] as List<dynamic>? ?? [])
          .map((l) => OcrLine.fromJson(l as Map<String, dynamic>))
          .toList(),
      fullText: json['fullText'] as String? ?? '',
      pageCount: json['pageCount'] as int? ?? 1,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Encodes to raw JSON string.
  String toRawJson() => jsonEncode(toJson());
}
