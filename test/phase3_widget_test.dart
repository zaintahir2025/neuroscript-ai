// ============================================================================
// NeuroScript AI: Phase 3 Capture & OCR Review Widget Tests
// File: test/phase3_widget_test.dart
// ============================================================================

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neuro_script/data/database/database.dart';
import 'package:neuro_script/data/models/ocr_models.dart';
import 'package:neuro_script/features/capture/capture_screen.dart';
import 'package:neuro_script/features/ocr_review/ocr_review_screen.dart';
import 'package:neuro_script/features/providers.dart';

class _FakeImagePicker extends ImagePicker {
  _FakeImagePicker(this.files);
  final List<XFile> files;

  @override
  Future<List<XFile>> pickMultiImage({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    int? limit,
    bool requestFullMetadata = true,
  }) async {
    return files;
  }
}

Widget createTestApp(Widget child, AppDatabase db) {
  return ProviderScope(
    overrides: [appDatabaseProvider.overrideWithValue(db)],
    child: MaterialApp(home: child),
  );
}

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.memory());
  tearDown(() => db.close());

  group('Phase 3 - Capture Screen Widget Tests (FR-01)', () {
    testWidgets(
      'CaptureScreen renders viewfinder, controls, and burst thumbnails',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1000));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(createTestApp(const CaptureScreen(), db));
        await tester.pumpAndSettle();

        // Verify app bar title
        expect(find.text('Scan Handwritten Note'), findsOneWidget);

        // Verify ambient lighting banner
        expect(find.textContaining('Use even lighting'), findsOneWidget);

        // Verify viewfinder and sample note buttons
        expect(find.text('Demo: Biology Scan'), findsOneWidget);
        expect(find.text('Demo: CS Scan'), findsOneWidget);

        // Verify shutter button
        expect(find.byIcon(Icons.camera_alt), findsOneWidget);

        // Verify initial empty pages state
        expect(find.text('Pages\n(0/5)'), findsOneWidget);

        // Tap sample note button to simulate page capture
        await tester.tap(find.text('Demo: Biology Scan'));
        await tester.pumpAndSettle();

        // Pages counter should increment to 1/5
        expect(find.text('Pages\n(1/5)'), findsOneWidget);
        expect(find.text('P. 1'), findsOneWidget);

        // Review OCR button is now active
        expect(find.text('Review OCR'), findsOneWidget);
      },
    );

    testWidgets(
      'CaptureScreen displays both Camera and Gallery options clearly',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1000));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(createTestApp(const CaptureScreen(), db));
        await tester.pumpAndSettle();

        // 1. Camera option verified (shutter icon + label)
        expect(find.byIcon(Icons.camera_alt), findsOneWidget);
        expect(find.text('Camera'), findsOneWidget);

        // 2. Gallery option verified (gallery icon + label in bottom controls, appbar, viewfinder)
        expect(find.byIcon(Icons.photo_library), findsNWidgets(3));
        expect(find.text('Gallery'), findsOneWidget);
        expect(find.text('Choose from Gallery'), findsOneWidget);
      },
    );

    testWidgets(
      'CaptureScreen can pick images from Gallery and enable Review OCR',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1000));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final fakePicker = _FakeImagePicker([
          XFile.fromData(Uint8List.fromList([1, 2, 3]), name: 'page1.jpg'),
          XFile.fromData(Uint8List.fromList([4, 5, 6]), name: 'page2.jpg'),
        ]);

        await tester.pumpWidget(
          createTestApp(CaptureScreen(imagePicker: fakePicker), db),
        );
        await tester.pumpAndSettle();

        expect(find.text('Pages\n(0/5)'), findsOneWidget);

        // Tap the "Choose from Gallery" button in viewfinder
        await tester.tap(find.text('Choose from Gallery'));
        await tester.pumpAndSettle();

        // 2 pages from gallery should be added
        expect(find.text('Pages\n(2/5)'), findsOneWidget);
        expect(find.text('P. 1'), findsOneWidget);
        expect(find.text('P. 2'), findsOneWidget);
        expect(find.text('Review OCR'), findsOneWidget);
      },
    );

    testWidgets(
      'CaptureScreen preloads initial pages (e.g. from gallery selection)',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1000));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final preloaded = [
          Uint8List.fromList([10, 20, 30]),
        ];

        await tester.pumpWidget(
          createTestApp(CaptureScreen(initialPages: preloaded), db),
        );
        await tester.pumpAndSettle();

        expect(find.text('Pages\n(1/5)'), findsOneWidget);
        expect(find.text('P. 1'), findsOneWidget);
        expect(find.text('Review OCR'), findsOneWidget);
      },
    );
  });

  group('Phase 3 - OCR Review Screen Widget Tests (FR-04)', () {
    testWidgets(
      'OcrReviewScreen renders numbered lines, allows editing, merging, and deleting',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1200));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final sampleLines = [
          const OcrLine(
            lineNumber: 1,
            text: 'First line of biology lecture note.',
          ),
          const OcrLine(
            lineNumber: 2,
            text: 'Chloroplasts absorb blue light wavelengths.',
          ),
          const OcrLine(
            lineNumber: 3,
            text: 'ATP energy is produced in stroma.',
          ),
        ];

        await tester.pumpWidget(
          createTestApp(OcrReviewScreen(initialLines: sampleLines), db),
        );
        await tester.pumpAndSettle();

        // Verify header and line count
        expect(find.text('3 Numbered Lines Transcribed'), findsOneWidget);
        expect(find.text('L1'), findsOneWidget);
        expect(find.text('L2'), findsOneWidget);
        expect(find.text('L3'), findsOneWidget);

        // Verify line texts
        expect(
          find.text('First line of biology lecture note.'),
          findsOneWidget,
        );
        expect(
          find.text('Chloroplasts absorb blue light wavelengths.'),
          findsOneWidget,
        );

        // Delete the first line
        final deleteButtons = find.byIcon(Icons.delete_outline);
        expect(deleteButtons, findsNWidgets(3));
        await tester.tap(deleteButtons.first);
        await tester.pumpAndSettle();

        // Verify line count decremented to 2 and lines are renumbered
        expect(find.text('2 Numbered Lines Transcribed'), findsOneWidget);
        expect(find.text('L1'), findsOneWidget);
        expect(find.text('L2'), findsOneWidget);
        expect(find.text('L3'), findsNothing);

        // Merge remaining two lines
        final mergeButtons = find.byIcon(Icons.merge_type);
        expect(mergeButtons, findsOneWidget);
        await tester.tap(mergeButtons.first);
        await tester.pumpAndSettle();

        // Verify only 1 line remains with combined text
        expect(find.text('1 Numbered Lines Transcribed'), findsOneWidget);
        expect(
          find.textContaining(
            'Chloroplasts absorb blue light wavelengths. ATP energy is produced in stroma.',
          ),
          findsOneWidget,
        );

        // Verify Generate button is present
        expect(
          find.textContaining('Confirm & Generate Lesson'),
          findsOneWidget,
        );
      },
    );
  });
}
