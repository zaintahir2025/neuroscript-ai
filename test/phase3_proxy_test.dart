// ============================================================================
// NeuroScript AI: Phase 3 Proxy Gateway Client & Synthesis Tests
// File: test/phase3_proxy_test.dart
// ============================================================================

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:neuro_script/core/app_config.dart';
import 'package:neuro_script/data/models/ocr_models.dart';
import 'package:neuro_script/services/proxy_service.dart';

void main() {
  group('Phase 3 - Proxy Gateway Service (Stage 4 / FR-05)', () {
    test(
      'remote requests fail clearly when no API key is configured',
      () async {
        var sentRequest = false;
        final service = ProxyService(
          config: const AppConfig(
            generatorMode: GeneratorMode.remote,
            proxyBaseUrl: 'http://localhost:5000',
          ),
          httpClient: MockClient((request) async {
            sentRequest = true;
            return http.Response('', 200);
          }),
        );

        await expectLater(
          service.generateLesson(
            noteHash: 'test_hash',
            ocrLines: [const OcrLine(lineNumber: 1, text: 'Sample line')],
            profileName: 'ADHD',
          ),
          throwsA(
            isA<ProxyException>().having(
              (error) => error.errorCode,
              'errorCode',
              'UNAUTHORIZED',
            ),
          ),
        );
        expect(sentRequest, isFalse);
      },
    );

    test('ProxyService successfully deserializes 200 OK lesson response matching contract', () async {
      final mockHttpClient = MockClient((request) async {
        if (request.url.path == '/api/v1/lessons/generate') {
          // Assert headers
          expect(request.headers['X-Api-Key'], isNotEmpty);
          expect(request.headers['X-Install-Id'], isNotEmpty);

          final mockResponseJson = {
            'schemaVersion': 1,
            'title': 'Photosynthesis Synthesis',
            'meta': {
              'profile': 'Dyslexia',
              'source': 'cloud',
              'promptVersion': 'v1',
            },
            'conceptMap': {
              'nodes': [
                {
                  'id': 'n1',
                  'label': 'Chloroplasts',
                  'sourceLines': [1],
                },
                {
                  'id': 'n2',
                  'label': 'Chlorophyll',
                  'sourceLines': [2],
                },
              ],
              'edges': [
                {'from': 'n1', 'to': 'n2', 'label': 'contains'},
              ],
            },
            'flashcards': [
              {
                'id': 'c1',
                'question': 'Where does photosynthesis occur?',
                'answer': 'Inside plant chloroplasts.',
                'sourceLines': [1],
                'chunks': [
                  'Where does photosynthesis occur?',
                  'Inside chloroplasts.',
                ],
                'groundingScore': 0.95,
                'verified': true,
              },
            ],
            'verificationQuestion': {
              'question': 'What organelle hosts photosynthesis?',
              'sourceLines': [1],
            },
          };

          return http.Response(
            jsonEncode(mockResponseJson),
            200,
            headers: {
              'content-type': 'application/json',
              'X-RateLimit-Limit': '20',
              'X-RateLimit-Remaining': '19',
            },
          );
        }
        return http.Response('Not Found', 404);
      });

      final service = ProxyService(
        config: const AppConfig(
          generatorMode: GeneratorMode.remote,
          proxyBaseUrl: 'http://localhost:5000',
          apiKey: 'test-api-key',
        ),
        httpClient: mockHttpClient,
        installId: 'test-install-uuid',
      );

      final ocrLines = [
        const OcrLine(
          lineNumber: 1,
          text: 'Photosynthesis occurs inside chloroplasts.',
        ),
        const OcrLine(
          lineNumber: 2,
          text: 'Chlorophyll pigments absorb blue and red light.',
        ),
      ];

      final lesson = await service.generateLesson(
        noteHash: 'abc123hash',
        ocrLines: ocrLines,
        profileName: 'Dyslexia',
      );

      expect(lesson.schemaVersion, equals(1));
      expect(lesson.title, equals('Photosynthesis Synthesis'));
      expect(lesson.flashcards.length, equals(1));
      expect(
        lesson.flashcards[0].question,
        contains('Where does photosynthesis occur?'),
      );
      expect(lesson.flashcards[0].sourceLines, equals([1]));
      expect(lesson.conceptMap.nodes.length, equals(2));
      expect(lesson.conceptMap.edges.length, equals(1));
    });

    test('ProxyService handles HTTP 429 RateLimitException with Retry-After header', () async {
      final mockHttpClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'type': 'https://neuroscript.uet.edu.pk/errors/rate-limited',
            'title': 'Rate Limit Exceeded',
            'status': 429,
            'detail': 'Rate limit exceeded. Please retry after 45 seconds.',
            'errorCode': 'RATE_LIMITED',
          }),
          429,
          headers: {
            'content-type': 'application/problem+json',
            'retry-after': '45',
          },
        );
      });

      final service = ProxyService(
        config: const AppConfig(
          generatorMode: GeneratorMode.remote,
          proxyBaseUrl: 'http://localhost:5000',
          apiKey: 'test-api-key',
        ),
        httpClient: mockHttpClient,
      );

      expect(
        () async => await service.generateLesson(
          noteHash: 'test_hash',
          ocrLines: [const OcrLine(lineNumber: 1, text: 'Sample line')],
          profileName: 'ADHD',
        ),
        throwsA(
          isA<RateLimitException>().having(
            (e) => e.retryAfterSeconds,
            'retryAfterSeconds',
            equals(45),
          ),
        ),
      );
    });

    test('ProxyService falls back to local synthesis when offline', () async {
      // Mock client that throws SocketException (simulating airplane mode / proxy offline)
      final mockHttpClient = MockClient((request) async {
        throw http.ClientException('Connection refused');
      });

      final service = ProxyService(
        config: const AppConfig(proxyBaseUrl: 'http://unreachable-proxy:5000'),
        httpClient: mockHttpClient,
      );

      final ocrLines = [
        const OcrLine(
          lineNumber: 1,
          text: 'Operating Systems: Manages hardware resources.',
        ),
        const OcrLine(
          lineNumber: 2,
          text: 'Virtual memory - Provides process isolation.',
        ),
      ];

      final lesson = await service.generateLesson(
        noteHash: 'offline_hash',
        ocrLines: ocrLines,
        profileName: 'Autism',
        allowOfflineFallback: true,
      );

      expect(lesson.title, isNotEmpty);
      expect(lesson.flashcards.length, equals(2));
      expect(lesson.flashcards[0].sourceLines, equals([1]));
      expect(lesson.flashcards[1].sourceLines, equals([2]));
      expect(lesson.conceptMap.nodes.length, equals(2));
      expect(lesson.conceptMap.edges.length, equals(1));
      expect(lesson.meta.source, equals('offline-basic'));
    });
  });
}
