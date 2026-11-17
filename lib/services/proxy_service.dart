// ============================================================================
// NeuroScript AI: Privacy-Preserving Study Platform for Neurodivergent Learners
// File: lib/services/proxy_service.dart
//
// Description:
//   HTTP client for the ASP.NET Core rate-limited proxy gateway (Stage 4, FR-05).
//   Sends confirmed OCR lines to the backend proxy compiler (Stage 4),
//   enforcing authentication, handling token bucket rate limits, and deserializing
//   the lesson schema contract.
// ============================================================================

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/app_config.dart';
import '../data/models/lesson_model.dart';
import '../data/models/ocr_models.dart';

/// Typed exception for rate limit errors (HTTP 429).
class RateLimitException implements Exception {
  const RateLimitException(this.message, {this.retryAfterSeconds = 60});
  final String message;
  final int retryAfterSeconds;

  @override
  String toString() =>
      'RateLimitException: $message (Retry after: $retryAfterSeconds s)';
}

/// Typed exception for proxy server errors.
class ProxyException implements Exception {
  const ProxyException(this.message, {this.statusCode = 500, this.errorCode});
  final String message;
  final int statusCode;
  final String? errorCode;

  @override
  String toString() => 'ProxyException ($statusCode, $errorCode): $message';
}

/// Client service communicating with the ASP.NET Core gateway.
class ProxyService {
  ProxyService({
    required this.config,
    http.Client? httpClient,
    this.installId = 'neuroscript-local-install-01',
  }) : _client = httpClient ?? http.Client();

  final AppConfig config;
  final http.Client _client;
  final String installId;

  /// Checks proxy gateway availability and LLM provider status.
  Future<Map<String, dynamic>> checkHealth() async {
    final uri = Uri.parse('${config.proxyBaseUrl}/health');
    try {
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw ProxyException(
        'Proxy health check failed: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    } on http.ClientException catch (e) {
      throw ProxyException('Cannot connect to proxy gateway: $e');
    } on TimeoutException {
      throw const ProxyException('Proxy health check timed out.');
    } catch (e) {
      if (e is ProxyException) rethrow;
      throw ProxyException('Cannot connect to proxy gateway: $e');
    }
  }

  /// Sends 1-based ordered OCR lines to the proxy to generate a verified study lesson.
  Future<LessonModel> generateLesson({
    required String noteHash,
    required List<OcrLine> ocrLines,
    required String profileName,
    String mode = 'standard',
  }) async {
    // If configured for offline/seed generator mode, synthesize on-device directly
    if (config.generatorMode == GeneratorMode.seed) {
      return _generateLocalFallback(noteHash, ocrLines, profileName);
    }

    final lines = ocrLines.map((l) => l.text).toList();
    final uri = Uri.parse('${config.proxyBaseUrl}/api/v1/lessons/generate');

    if (config.apiKey.isEmpty) {
      throw const ProxyException(
        'Proxy API key is not configured. Set API_KEY for this build.',
        statusCode: 401,
        errorCode: 'UNAUTHORIZED',
      );
    }

    final payload = {
      'noteHash': noteHash,
      'lines': lines,
      'profile': profileName,
      'mode': mode,
      'clientVersion': '0.3.0-m3',
    };

    try {
      final response = await _client
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'X-Api-Key': config.apiKey,
              'X-Install-Id': installId,
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return LessonModel.fromJson(data);
      } else if (response.statusCode == 429) {
        final retryAfter =
            int.tryParse(response.headers['retry-after'] ?? '60') ?? 60;
        throw RateLimitException(
          'Generation rate limit exceeded. Please wait.',
          retryAfterSeconds: retryAfter,
        );
      } else {
        String errorDetail = 'Status ${response.statusCode}';
        String? errCode;
        try {
          final errJson = jsonDecode(response.body) as Map<String, dynamic>;
          errorDetail = errJson['detail'] as String? ?? errorDetail;
          errCode = errJson['errorCode'] as String?;
        } on Exception catch (_) {}

        throw ProxyException(
          errorDetail,
          statusCode: response.statusCode,
          errorCode: errCode,
        );
      }
    } on http.ClientException catch (e) {
      debugPrint(
        'Proxy HTTP client exception: $e. Using local synthesis fallback.',
      );
      return _generateLocalFallback(noteHash, ocrLines, profileName);
    } on TimeoutException {
      debugPrint('Proxy timed out. Using local synthesis fallback.');
      return _generateLocalFallback(noteHash, ocrLines, profileName);
    } catch (e) {
      if (e is RateLimitException || e is ProxyException) {
        rethrow;
      }
      debugPrint(
        'Proxy connection failed: $e. Using local synthesis fallback.',
      );
      return _generateLocalFallback(noteHash, ocrLines, profileName);
    }
  }

  /// On-device mock compilation fallback when proxy server is unreachable or offline.
  LessonModel _generateLocalFallback(
    String noteHash,
    List<OcrLine> ocrLines,
    String profileName,
  ) {
    final flashcards = <FlashcardModel>[];
    final nodes = <ConceptNodeModel>[];
    final edges = <ConceptEdgeModel>[];

    final firstLine = ocrLines.isNotEmpty ? ocrLines.first.text : 'Study Notes';
    final title = firstLine.length > 40
        ? '${firstLine.substring(0, 37)}...'
        : firstLine;

    for (var i = 0; i < ocrLines.length; i++) {
      final line = ocrLines[i];
      final lineNum = line.lineNumber;
      final text = line.text;

      String q;
      String a;
      if (text.contains(':')) {
        final parts = text.split(':');
        q = 'What is ${parts[0].trim()}?';
        a = parts.sublist(1).join(':').trim();
      } else if (text.contains(' - ')) {
        final parts = text.split(' - ');
        q = 'What defines ${parts[0].trim()}?';
        a = parts.sublist(1).join(' - ').trim();
      } else {
        q = 'Key concept from line $lineNum';
        a = text;
      }

      flashcards.add(
        FlashcardModel(
          id: 'c$lineNum',
          question: q,
          answer: a,
          sourceLines: [lineNum],
          chunks: [q, a],
          // This deterministic fallback is a demo scaffold, not grounding validation.
          groundingScore: null,
          verified: false,
        ),
      );

      final label = text.length > 28 ? '${text.substring(0, 25)}...' : text;
      nodes.add(
        ConceptNodeModel(id: 'n$lineNum', label: label, sourceLines: [lineNum]),
      );
    }

    for (var i = 0; i < nodes.length - 1; i++) {
      edges.add(
        ConceptEdgeModel(
          from: nodes[i].id,
          to: nodes[i + 1].id,
          label: i % 2 == 0 ? 'leads to' : 'requires',
        ),
      );
    }

    return LessonModel(
      schemaVersion: 1,
      title: title,
      meta: LessonMeta(
        profile: profileName,
        source: 'mock',
        promptVersion: 'v1',
      ),
      conceptMap: ConceptMapModel(nodes: nodes, edges: edges),
      flashcards: flashcards,
      rawNotes: ocrLines.map((l) => l.text).join('\n'),
    );
  }
}
