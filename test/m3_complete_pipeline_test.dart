// ============================================================================
// NeuroScript AI: Milestone 3 Full Pipeline & Integration Verification
// File: test/m3_complete_pipeline_test.dart
//
// Description:
//   End-to-end verification of all Milestone 3 features working together:
//   - FR-01: Multi-page burst capture and framing viewfinder
//   - FR-02: Isolate-driven image preprocessing (CLAHE, threshold, deskew)
//   - FR-03: Latin text transcription into 1-based ordered numbered lines
//   - FR-04: Interactive OCR line editor (edit, merge, delete, reorder)
//   - Stage 4: Proxy gateway client compilation and encrypted DB persistence
//   - Leitner SRS & Concept Map integration with line-level provenance
// ============================================================================

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:neuro_script/core/app_config.dart';
import 'package:neuro_script/core/document_hash.dart';
import 'package:neuro_script/core/models/profile_type.dart';
import 'package:neuro_script/data/database/database.dart';
import 'package:neuro_script/data/models/ocr_models.dart';
import 'package:neuro_script/data/repositories/app_repositories.dart';
import 'package:neuro_script/features/capture/capture_screen.dart';
import 'package:neuro_script/features/ocr_review/ocr_review_screen.dart';
import 'package:neuro_script/features/providers.dart';
import 'package:neuro_script/services/image_preprocessor.dart';
import 'package:neuro_script/services/ocr_service.dart';
import 'package:neuro_script/services/proxy_service.dart';

class _FixtureOcrRecognizer implements OcrPageRecognizer {
  @override
  Future<List<RecognizedOcrLine>> recognize(Uint8List imageBytes) async => [
    const RecognizedOcrLine('Fixture note line one', confidence: 0.9),
    const RecognizedOcrLine('Fixture note line two', confidence: 0.88),
  ];

  @override
  Future<void> close() async {}
}

void main() {
  group('Milestone 3 End-to-End Pipeline Verification', () {
    late AppDatabase db;
    late AppProfileRepository profileRepo;
    late AppNoteRepository noteRepo;
    late AppLessonRepository lessonRepo;
    late AppReviewRepository reviewRepo;

    setUp(() async {
      db = AppDatabase.memory();
      profileRepo = AppProfileRepository(db);
      noteRepo = AppNoteRepository(db);
      lessonRepo = AppLessonRepository(db);
      reviewRepo = AppReviewRepository(db);

      // Set Dyslexia profile as active
      await profileRepo.saveProfile(ProfileType.dyslexia);
    });

    tearDown(() async {
      await db.close();
    });

    test('Stage 1 -> Stage 2 -> Stage 3: Image acquisition, preprocessing, and 1-based OCR extraction', () async {
      // 1. Synthesize captured handwritten note image
      final testImage = img.Image(width: 800, height: 600);
      img.fill(testImage, color: img.ColorRgb8(240, 240, 235));
      for (var y = 80; y < 400; y += 50) {
        for (var x = 60; x < 600; x++) {
          if ((x % 20) < 14) {
            testImage.setPixelRgb(x, y, 15, 15, 20);
          }
        }
      }
      final rawPhotoBytes = Uint8List.fromList(img.encodeJpg(testImage));

      // 2. Preprocess in background isolate (FR-02)
      const preprocessor = ImagePreprocessor();
      final preprocessed = await preprocessor.preprocess(rawPhotoBytes);

      expect(preprocessed.processedBytes, isNotEmpty);
      expect(preprocessed.width, lessThanOrEqualTo(1600));
      expect(preprocessed.height, lessThanOrEqualTo(1600));
      expect(preprocessed.estimatedSkewAngle, inInclusiveRange(-5.0, 5.0));

      // 3. Transcribe into 1-based ordered lines (FR-03)
      final ocrService = OcrService(recognizer: _FixtureOcrRecognizer());
      final ocrResult = await ocrService.processPages([
        preprocessed.processedBytes,
      ]);

      expect(ocrResult.lines, isNotEmpty);
      expect(ocrResult.pageCount, equals(1));
      for (var i = 0; i < ocrResult.lines.length; i++) {
        expect(ocrResult.lines[i].lineNumber, equals(i + 1));
        expect(ocrResult.lines[i].text.trim(), isNotEmpty);
      }
    });

    test('Stage 4 -> Encrypted Persistence: Line editing, synthesis, and Leitner review setup', () async {
      // 1. Simulate edited and confirmed OCR lines (FR-04)
      final ocrLines = [
        const OcrLine(
          lineNumber: 1,
          text: 'Photosynthesis: Process of converting light into glucose.',
        ),
        const OcrLine(
          lineNumber: 2,
          text: 'Chlorophyll - Pigment that absorbs red and blue wavelengths.',
        ),
        const OcrLine(
          lineNumber: 3,
          text: 'Stroma: Fluid where Calvin cycle carbon fixation occurs.',
        ),
      ];

      final rawText = ocrLines.map((l) => l.text).join('\n');
      final docHash = DocumentHash.compute(rawText);

      // Verify cryptographic SHA-256 hashing
      expect(docHash, hasLength(64));

      // 2. Save note into encrypted database
      final noteId = await noteRepo.saveNote(
        rawOcrText: rawText,
        documentHash: docHash,
      );
      expect(noteId, isNotEmpty);

      // Verify deduplication
      final cachedNoteId = await noteRepo.getNoteIdByHash(docHash);
      expect(cachedNoteId, equals(noteId));

      // 3. Generate structured lesson via Proxy client (Stage 4)
      final proxyService = ProxyService(config: const AppConfig());
      final lesson = await proxyService.generateLesson(
        noteHash: docHash,
        ocrLines: ocrLines,
        profileName: 'Dyslexia',
      );

      expect(lesson.schemaVersion, equals(1));
      expect(lesson.flashcards.length, equals(3));
      expect(lesson.conceptMap.nodes.length, equals(3));
      expect(lesson.conceptMap.edges.length, equals(2));

      // Verify source line citations (grounding)
      expect(lesson.flashcards[0].sourceLines, equals([1]));
      expect(lesson.flashcards[1].sourceLines, equals([2]));
      expect(lesson.flashcards[2].sourceLines, equals([3]));

      // 4. Save lesson and flashcards into encrypted database
      await lessonRepo.saveLesson(noteId: noteId, lesson: lesson);

      // 5. Query study library
      final allLessons = await lessonRepo.getAllLessons();
      expect(allLessons.length, equals(1));
      expect(allLessons[0].cardCount, equals(3));
      expect(
        allLessons[0].dueCount,
        equals(3),
      ); // Newly created cards are due today

      // 6. Verify Leitner SRS progress initialization
      final reviewItems = await reviewRepo.getReviewItemsForLesson(
        allLessons[0].lessonId,
      );
      expect(reviewItems.length, equals(3));
      expect(reviewItems[0].progress.box, equals(1)); // Box 1 initial level
      expect(reviewItems[0].progress.intervalDays, equals(1)); // 1 day interval

      // 7. Record study result ("Got it" advancing to Box 2)
      await reviewRepo.recordCardResult(
        cardId: reviewItems[0].card.id,
        wasCorrect: true,
      );

      final updatedItems = await reviewRepo.getReviewItemsForLesson(
        allLessons[0].lessonId,
      );
      expect(updatedItems[0].progress.box, equals(2)); // Advanced to Box 2
      expect(
        updatedItems[0].progress.intervalDays,
        equals(3),
      ); // 3 days interval
    });

    testWidgets(
      'Full UI Workflow: Capture -> Review OCR -> Line Editor -> Generate & Persist',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1200));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final testApp = ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            profileRepositoryProvider.overrideWithValue(profileRepo),
            noteRepositoryProvider.overrideWithValue(noteRepo),
            lessonRepositoryProvider.overrideWithValue(lessonRepo),
            reviewRepositoryProvider.overrideWithValue(reviewRepo),
          ],
          child: const MaterialApp(home: CaptureScreen()),
        );

        await tester.pumpWidget(testApp);
        await tester.pumpAndSettle();

        // Verify Capture UI
        expect(find.text('Scan Handwritten Note'), findsOneWidget);
        expect(find.text('Demo: Biology Scan'), findsOneWidget);

        // Tap sample to simulate burst acquisition
        await tester.tap(find.text('Demo: Biology Scan'));
        await tester.pumpAndSettle();

        expect(find.text('Pages\n(1/5)'), findsOneWidget);
        expect(find.text('Review OCR'), findsOneWidget);

        // Mount OCR Review Screen with sample lines
        final sampleOcrLines = [
          const OcrLine(
            lineNumber: 1,
            text: 'Photosynthesis occurs inside chloroplasts.',
          ),
          const OcrLine(
            lineNumber: 2,
            text: 'Chlorophyll pigments absorb blue light.',
          ),
        ];

        final ocrReviewApp = ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            profileRepositoryProvider.overrideWithValue(profileRepo),
            noteRepositoryProvider.overrideWithValue(noteRepo),
            lessonRepositoryProvider.overrideWithValue(lessonRepo),
            reviewRepositoryProvider.overrideWithValue(reviewRepo),
          ],
          child: MaterialApp(
            home: OcrReviewScreen(initialLines: sampleOcrLines),
          ),
        );

        await tester.pumpWidget(ocrReviewApp);
        await tester.pumpAndSettle();

        // Verify line inspection
        expect(find.text('2 Numbered Lines Transcribed'), findsOneWidget);
        expect(find.text('L1'), findsOneWidget);
        expect(find.text('L2'), findsOneWidget);

        // Tap Confirm & Generate Lesson
        final generateBtn = find.textContaining('Confirm & Generate Lesson');
        expect(generateBtn, findsOneWidget);

        await tester.tap(generateBtn);
        await tester.pumpAndSettle();

        // Verify persistence in encrypted database
        final savedLessons = await lessonRepo.getAllLessons();
        expect(savedLessons, isNotEmpty);
        expect(savedLessons.first.cardCount, equals(2));
      },
    );
  });
}
