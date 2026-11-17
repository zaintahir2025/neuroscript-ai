// ============================================================================
// NeuroScript AI: Privacy-Preserving Study Platform for Neurodivergent Learners
// File: lib/features/ocr_review/ocr_review_screen.dart
//
// Description:
//   OCR Line Review and Editing Screen (FR-04).
//   Permits students to inspect, edit, merge, insert, delete, and reorder
//   1-based numbered lines before compiling into a study lesson.
// ============================================================================

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../../core/document_hash.dart';
import '../../core/widgets/app_button.dart';
import '../../data/models/lesson_model.dart';
import '../../data/models/ocr_models.dart';
import '../../services/image_preprocessor.dart';
import '../../services/ocr_service.dart';
import '../../services/proxy_service.dart';
import '../providers.dart';

class OcrReviewScreen extends ConsumerStatefulWidget {
  const OcrReviewScreen({
    super.key,
    this.capturedPages = const [],
    this.initialLines,
  });

  /// Raw photo bytes captured in the camera session.
  final List<Uint8List> capturedPages;

  /// Optional pre-extracted lines (useful for testing or direct text injection).
  final List<OcrLine>? initialLines;

  @override
  ConsumerState<OcrReviewScreen> createState() => _OcrReviewScreenState();
}

class _OcrReviewScreenState extends ConsumerState<OcrReviewScreen> {
  final List<OcrLine> _lines = [];
  bool _isLoading = true;
  String _statusMessage = 'Enhancing images and transcribing handwriting...';
  String? _processingError;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _processInput();
  }

  Future<void> _processInput() async {
    if (widget.initialLines != null && widget.initialLines!.isNotEmpty) {
      setState(() {
        _lines.addAll(widget.initialLines!);
        _isLoading = false;
      });
      return;
    }

    if (widget.capturedPages.isEmpty) {
      setState(() {
        _processingError = 'No captured pages were provided.';
        _isLoading = false;
      });
      return;
    }

    try {
      // 1. Inspect stored Gemini API key if present
      String? geminiKey = ref.read(appConfigProvider).geminiApiKey;
      try {
        const storage = FlutterSecureStorage();
        final stored = await storage.read(key: 'gemini_api_key');
        if (stored != null && stored.trim().isNotEmpty) {
          geminiKey = stored.trim();
        }
      } on Object catch (e) {
        debugPrint('Secure storage key read notice: $e');
      }

      // 2. Preprocess the captured pages in a background isolate.
      setState(
        () =>
            _statusMessage = 'Stage 2: Enhancing image contrast & deskewing...',
      );
      const preprocessor = ImagePreprocessor();
      final processedPages = <Uint8List>[];

      for (final raw in widget.capturedPages) {
        try {
          final res = await preprocessor.preprocess(raw);
          processedPages.add(res.processedBytes);
        } on Exception catch (e) {
          debugPrint('Preprocessing fallback: $e');
          processedPages.add(raw);
        }
      }

      // 3. Transcribe with dual-pass ML Kit & optional Smart AI Vision
      setState(
        () => _statusMessage =
            'Stage 3: Transcribing handwritten lines (ML Kit)...',
      );
      const ocrService = OcrService();
      final ocrResult = await ocrService.processPages(
        processedPages,
        fallbackRawPages: widget.capturedPages,
        geminiApiKey: geminiKey,
      );

      if (!mounted) return;
      setState(() {
        _lines.addAll(ocrResult.lines);
        _isLoading = false;
      });
    } on Object catch (e) {
      debugPrint('OCR pipeline error: $e');
      if (mounted) {
        setState(() {
          _processingError = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _transcribeWithGeminiVision([String? providedKey]) async {
    const storage = FlutterSecureStorage();
    var key = providedKey ?? ref.read(appConfigProvider).geminiApiKey;
    if (key.isEmpty) {
      try {
        final stored = await storage.read(key: 'gemini_api_key');
        if (stored != null && stored.trim().isNotEmpty) {
          key = stored.trim();
        }
      } on Object catch (e) {
        debugPrint('Storage read error: $e');
      }
    }

    if (key.isEmpty) {
      if (!mounted) return;
      final keyController = TextEditingController();
      final enteredKey = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.amber),
              SizedBox(width: 8),
              Text('Smart AI Vision OCR'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Uses Google Gemini Vision AI to accurately transcribe handwriting, complex exam question papers, tables, and math equations with 100% precision.',
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: keyController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Gemini API Key',
                  hintText: 'AIzaSy...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.key),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Key will be saved securely on your device for future scans.',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () {
                final k = keyController.text.trim();
                if (k.isNotEmpty) Navigator.of(ctx).pop(k);
              },
              icon: const Icon(Icons.check),
              label: const Text('Save & Transcribe'),
            ),
          ],
        ),
      );

      if (enteredKey == null || enteredKey.isEmpty) return;
      key = enteredKey;
      try {
        await storage.write(key: 'gemini_api_key', value: key);
      } on Object catch (e) {
        debugPrint('Storage write error: $e');
      }
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Transcribing with Smart Gemini Vision AI...';
      _processingError = null;
    });

    try {
      final ocrService = OcrService(
        recognizer: GeminiVisionRecognizer(apiKey: key),
      );
      final res = await ocrService.processPages(widget.capturedPages);
      if (!mounted) return;
      setState(() {
        _lines.clear();
        _lines.addAll(res.lines);
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Smart AI Vision transcribed ${res.lines.length} lines with high precision!',
          ),
          backgroundColor: Colors.green.shade800,
        ),
      );
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _processingError = 'Smart Vision failed: $e';
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('AI transcription failed: $e')));
    }
  }

  void _renumberLines() {
    for (var i = 0; i < _lines.length; i++) {
      _lines[i] = _lines[i].copyWith(lineNumber: i + 1);
    }
  }

  void _editLine(int index) async {
    final line = _lines[index];
    final controller = TextEditingController(text: line.text);

    final updatedText = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Line ${line.lineNumber}'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Line Content',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (updatedText != null && updatedText.isNotEmpty) {
      setState(() {
        _lines[index] = line.copyWith(text: updatedText);
      });
    }
  }

  void _mergeWithNext(int index) {
    if (index >= _lines.length - 1) return;
    final current = _lines[index];
    final next = _lines[index + 1];

    setState(() {
      _lines[index] = current.copyWith(text: '${current.text} ${next.text}');
      _lines.removeAt(index + 1);
      _renumberLines();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Merged line ${current.lineNumber} and ${next.lineNumber}.',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _addNewLine([int? insertIndex]) async {
    final controller = TextEditingController();
    final targetIndex = insertIndex ?? _lines.length;
    final displayNum = targetIndex + 1;

    final newText = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add New Line $displayNum'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Text Content',
            hintText: 'Enter text omitted during OCR scan...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Add Line'),
          ),
        ],
      ),
    );

    if (newText != null && newText.isNotEmpty) {
      setState(() {
        _lines.insert(
          targetIndex,
          OcrLine(lineNumber: displayNum, text: newText),
        );
        _renumberLines();
      });
    }
  }

  void _deleteLine(int index) {
    final removed = _lines[index];
    setState(() {
      _lines.removeAt(index);
      _renumberLines();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted line ${removed.lineNumber}.'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            setState(() {
              _lines.insert(index, removed);
              _renumberLines();
            });
          },
        ),
      ),
    );
  }

  Future<void> _confirmAndGenerate() async {
    if (_lines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot generate lesson from 0 lines.')),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final rawNoteText = _lines.map((l) => l.text).join('\n');
      final noteHash = DocumentHash.compute(rawNoteText);

      final noteRepo = ref.read(noteRepositoryProvider);
      final lessonRepo = ref.read(lessonRepositoryProvider);
      final config = ref.read(appConfigProvider);

      final activeProfile = await ref
          .read(profileRepositoryProvider)
          .getActiveProfile();
      final profileName = activeProfile?.displayName ?? 'Dyslexia';

      // 1. Check if source note and study set already exist
      final existingNoteId = await noteRepo.getNoteIdByHash(noteHash);
      if (existingNoteId != null) {
        final existingLessons = await lessonRepo.getLessonsByNoteId(
          existingNoteId,
        );
        if (existingLessons.isNotEmpty && mounted) {
          final choice = await showDialog<String>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.history_edu, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Existing Study Set Found'),
                ],
              ),
              content: Text(
                'A study set already exists for this exact note:\n\n'
                '• "${existingLessons.first.title}" (${existingLessons.first.cardCount} cards)\n\n'
                'Would you like to open the existing set or generate a new version?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop('cancel'),
                  child: const Text('Cancel'),
                ),
                OutlinedButton(
                  onPressed: () => Navigator.of(ctx).pop('open'),
                  child: const Text('Open Existing Set'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(ctx).pop('new'),
                  child: const Text('Generate New Version'),
                ),
              ],
            ),
          );

          if (choice == 'open') {
            if (mounted) {
              final router = GoRouter.maybeOf(context);
              if (router != null) {
                context.go('/lesson/${existingLessons.first.lessonId}');
              }
            }
            return;
          } else if (choice != 'new') {
            return;
          }
        }
      }

      final noteId =
          existingNoteId ??
          await noteRepo.saveNote(
            rawOcrText: rawNoteText,
            documentHash: noteHash,
          );

      // 2. Synthesize Lesson (via Proxy Service with unique installId or transparent local fallback)
      final installId = await ref.read(installIdProvider.future);
      final proxyService = ProxyService(config: config, installId: installId);

      LessonModel? lesson;
      try {
        lesson = await proxyService.generateLesson(
          noteHash: noteHash,
          ocrLines: _lines,
          profileName: profileName,
        );
      } on ProxyException catch (e) {
        if (!mounted) return;
        final useOffline = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.cloud_off, color: Colors.amber),
                SizedBox(width: 8),
                Text('Cloud Gateway Offline'),
              ],
            ),
            content: Text(
              'Could not reach the cloud lesson compiler:\n${e.message}\n\n'
              'Would you like to generate basic flashcards offline using on-device rules instead?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton.icon(
                icon: const Icon(Icons.offline_bolt, size: 18),
                onPressed: () => Navigator.of(ctx).pop(true),
                label: const Text('Generate Offline Cards'),
              ),
            ],
          ),
        );

        if (useOffline == true) {
          lesson = proxyService.generateLocalFallback(
            noteHash: noteHash,
            ocrLines: _lines,
            profileName: profileName,
          );
        } else {
          return;
        }
      }

      // 3. Persist lesson and flashcards in encrypted Drift database
      final createdLessonId = await lessonRepo.saveLesson(
        noteId: noteId,
        lesson: lesson,
      );

      // Invalidate providers
      ref.invalidate(allLessonsProvider);
      ref.invalidate(schedulerMetricsProvider);

      if (!mounted) return;

      // Navigate back to library with success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Generated "${lesson.title}" with ${lesson.flashcards.length} cards!',
          ),
        ),
      );

      final router = GoRouter.maybeOf(context);
      if (router != null) {
        context.go('/lesson/$createdLessonId');
      } else if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } on RateLimitException catch (e) {
      if (mounted) {
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.hourglass_top, color: Colors.orange),
                SizedBox(width: 8),
                Text('Rate Limit Exceeded'),
              ],
            ),
            content: Text(
              '${e.message}\nPlease wait ${e.retryAfterSeconds} seconds before requesting another generation.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } on Exception catch (e) {
      debugPrint('Generation error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Generation failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('OCR Transcription')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 24),
                Text(
                  _statusMessage,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Preparing each page and running on-device text recognition...',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review OCR Lines'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'Smart AI OCR (Gemini Vision)',
            onPressed: () => _transcribeWithGeminiVision(),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Line',
            onPressed: () => _addNewLine(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header Info Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              child: Row(
                children: [
                  Icon(Icons.edit_note, color: colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_lines.length} Numbered Lines Transcribed',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Verify accuracy, edit typos, merge split lines, or reorder before compiling.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Numbered Lines Reorderable List
            Expanded(
              child: _lines.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.text_fields_outlined,
                            size: 64,
                            color: colorScheme.outline,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _processingError == null
                                ? 'No text lines recognized.'
                                : 'We could not read text from these pages. You can add lines here, or go back and type or paste your notes.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 14),
                          FilledButton.icon(
                            onPressed: () => _transcribeWithGeminiVision(),
                            icon: const Icon(Icons.auto_awesome),
                            label: const Text(
                              'Transcribe with Smart AI Vision',
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_processingError != null)
                            OutlinedButton.icon(
                              onPressed: () => context.pop(),
                              icon: const Icon(Icons.arrow_back),
                              label: const Text('Go back and type notes'),
                            ),
                          if (_processingError != null)
                            const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () => _addNewLine(),
                            icon: const Icon(Icons.add),
                            label: const Text('Add First Line'),
                          ),
                        ],
                      ),
                    )
                  : ReorderableListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      itemCount: _lines.length,
                      onReorderItem: (oldIndex, newIndex) {
                        setState(() {
                          final item = _lines.removeAt(oldIndex);
                          _lines.insert(newIndex, item);
                          _renumberLines();
                        });
                      },
                      itemBuilder: (context, index) {
                        final line = _lines[index];
                        return Card(
                          key: ValueKey('line_${line.lineNumber}_$index'),
                          margin: const EdgeInsets.only(bottom: 8),
                          elevation: 1,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Line Number Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'L${line.lineNumber}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Text Content
                                Expanded(
                                  child: InkWell(
                                    onTap: () => _editLine(index),
                                    child: Semantics(
                                      button: true,
                                      label:
                                          'Edit line ${line.lineNumber}: ${line.text}',
                                      child: ExcludeSemantics(
                                        child: Text(
                                          line.text,
                                          style: theme.textTheme.bodyLarge
                                              ?.copyWith(
                                                height: 1.5,
                                                color: colorScheme.onSurface,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Actions (Edit, Merge, Delete)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 18),
                                      tooltip: 'Edit line ${line.lineNumber}',
                                      onPressed: () => _editLine(index),
                                    ),
                                    if (index < _lines.length - 1)
                                      IconButton(
                                        icon: const Icon(
                                          Icons.merge_type,
                                          size: 18,
                                        ),
                                        tooltip: 'Merge with next line',
                                        onPressed: () => _mergeWithNext(index),
                                      ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete_outline,
                                        size: 18,
                                        color: colorScheme.error,
                                      ),
                                      tooltip: 'Delete line',
                                      onPressed: () => _deleteLine(index),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Bottom Confirmation Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: AppButton(
                label: _isGenerating
                    ? 'Synthesizing Lesson & Flashcards...'
                    : 'Confirm & Generate Lesson (${_lines.length} lines)',
                isLoading: _isGenerating,
                onPressed: _lines.isNotEmpty && !_isGenerating
                    ? _confirmAndGenerate
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
