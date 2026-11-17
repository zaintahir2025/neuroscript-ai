// ============================================================================
// NeuroScript AI: Privacy-Preserving Study Platform for Neurodivergent Learners
// File: lib/features/capture/capture_screen.dart
//
// Description:
//   Optical note acquisition screen (FR-01).
//   Enables multi-page burst capture (1 to 5 pages), provides visual framing
//   guide overlays, ambient light metering warnings, flash toggle control,
//   and distinct Camera Scan vs. Gallery Import mode workflows.
// ============================================================================

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_palettes.dart';
import '../../data/models/ocr_models.dart';
import '../providers.dart';

enum CaptureSourceMode { camera, gallery }

class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({super.key, this.initialPages, this.imagePicker});

  /// Preloaded pages (e.g. imported from gallery on launch).
  final List<Uint8List>? initialPages;

  /// Injected image picker instance for tests or custom picker configurations.
  final ImagePicker? imagePicker;

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  String? _cameraUnavailableReason;
  FlashMode _flashMode = FlashMode.off;
  final List<Uint8List> _capturedPages = [];
  bool _isProcessingCapture = false;
  late final ImagePicker _imagePicker = widget.imagePicker ?? ImagePicker();
  CaptureSourceMode _selectedMode = CaptureSourceMode.camera;

  @override
  void initState() {
    super.initState();
    if (widget.initialPages != null && widget.initialPages!.isNotEmpty) {
      _capturedPages.addAll(widget.initialPages!);
    }
    // Default to Gallery mode on Web or desktop where camera hardware is unsupported
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      _selectedMode = CaptureSourceMode.gallery;
    }
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          setState(() {
            _cameraUnavailableReason = 'No camera was found.';
          });
        }
        return;
      }

      final backCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await controller.initialize();
      if (!mounted) return;

      setState(() {
        _cameraController = controller;
        _isCameraInitialized = true;
      });
    } on Object catch (e) {
      debugPrint('Camera initialization fallback: $e');
      if (mounted) {
        setState(() => _cameraUnavailableReason = 'Camera unavailable: $e');
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null || !_isCameraInitialized) return;
    final nextMode = switch (_flashMode) {
      FlashMode.off => FlashMode.torch,
      FlashMode.torch => FlashMode.auto,
      FlashMode.auto => FlashMode.off,
      _ => FlashMode.off,
    };
    try {
      await _cameraController!.setFlashMode(nextMode);
      setState(() => _flashMode = nextMode);
    } on Exception catch (e) {
      debugPrint('Flash toggle error: $e');
    }
  }

  Future<void> _capturePhoto() async {
    if (_capturedPages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 5 pages allowed per note session.'),
        ),
      );
      return;
    }

    setState(() => _isProcessingCapture = true);

    try {
      Uint8List bytes;
      if (_cameraController != null && _isCameraInitialized) {
        final xFile = await _cameraController!.takePicture();
        bytes = await xFile.readAsBytes();
      } else {
        throw StateError(
          _cameraUnavailableReason ?? 'Camera is not ready. Choose a sample note or type your notes instead.',
        );
      }

      setState(() {
        _capturedPages.add(bytes);
        _isProcessingCapture = false;
      });
    } on Object {
      setState(() => _isProcessingCapture = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not capture this page. Check camera permission and try again.',
            ),
          ),
        );
      }
    }
  }

  Future<void> _pickImagesFromGallery() async {
    final remaining = 5 - _capturedPages.length;
    if (remaining <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Maximum 5 pages allowed per note session.'),
          ),
        );
      }
      return;
    }

    setState(() => _isProcessingCapture = true);

    try {
      List<XFile> pickedFiles = [];
      try {
        pickedFiles = await _imagePicker.pickMultiImage(limit: remaining);
      } on Object catch (e) {
        debugPrint('pickMultiImage fallback: $e');
        final single = await _imagePicker.pickImage(
          source: ImageSource.gallery,
        );
        if (single != null) {
          pickedFiles = [single];
        }
      }

      if (pickedFiles.isEmpty) {
        if (mounted) {
          setState(() => _isProcessingCapture = false);
        }
        return;
      }

      final newBytesList = <Uint8List>[];
      for (final file in pickedFiles.take(remaining)) {
        final bytes = await file.readAsBytes();
        newBytesList.add(bytes);
      }

      if (mounted) {
        setState(() {
          _capturedPages.addAll(newBytesList);
          _isProcessingCapture = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newBytesList.length == 1
                  ? 'Added 1 page from gallery.'
                  : 'Added ${newBytesList.length} pages from gallery.',
            ),
          ),
        );
      }
    } on Object catch (e) {
      debugPrint('Gallery picker error: $e');
      if (mounted) {
        setState(() => _isProcessingCapture = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load gallery images: $e')),
        );
      }
    }
  }

  /// Synthesizes an authentic, decodable JPEG image of handwritten notes on ruled paper.
  static Uint8List createSyntheticNoteImage({
    required String title,
    required List<String> lines,
  }) {
    final image = img.Image(width: 800, height: 1100);
    img.fill(image, color: img.ColorRgb8(251, 248, 238));

    // Ruled lines
    for (var y = 140; y < 1050; y += 45) {
      for (var x = 60; x < 740; x++) {
        image.setPixelRgb(x, y, 215, 225, 238);
      }
    }

    // Margin line
    for (var y = 60; y < 1050; y++) {
      image.setPixelRgb(120, y, 240, 190, 190);
    }

    // Header title
    img.drawString(
      image,
      title,
      font: img.arial24,
      x: 140,
      y: 80,
      color: img.ColorRgb8(25, 30, 45),
    );

    // Text lines
    for (var i = 0; i < lines.length; i++) {
      final y = 150 + i * 45;
      img.drawString(
        image,
        lines[i],
        font: img.arial14,
        x: 140,
        y: y,
        color: img.ColorRgb8(35, 40, 55),
      );
    }

    return Uint8List.fromList(img.encodeJpg(image, quality: 90));
  }

  void _loadSampleNote(String sampleId) {
    if (_capturedPages.length >= 5) return;

    final isBiology = sampleId == 'note_001';
    final title = isBiology
        ? 'Biology: Photosynthesis'
        : 'Computer Science: Algorithms';
    final lines = isBiology
        ? const [
            'Photosynthesis occurs inside plant chloroplasts.',
            'Chlorophyll pigments absorb blue and red light.',
            'Light energy splits water molecules producing oxygen.',
            'ATP and NADPH synthesized during light reactions.',
            'Carbon fixation occurs in Calvin cycle in stroma.',
          ]
        : const [
            'Binary search requires sorted array with random access.',
            'Search interval is halved on each comparison step.',
            'Worst-case and average-case time complexity is O(log n).',
            'Space complexity for iterative binary search is O(1).',
            'Calculate mid as low + (high - low) / 2 to avoid overflow.',
          ];

    final noteBytes = createSyntheticNoteImage(title: title, lines: lines);
    setState(() {
      _capturedPages.add(noteBytes);
    });
  }

  void _showPasteNoteDialog() {
    final textController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.edit_note, size: 22),
            SizedBox(width: 8),
            Text('Paste Lecture Notes'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Type or paste your notes. Put each idea on a new line so it can become a separate study prompt.',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textController,
              maxLines: 6,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Lecture notes',
                alignLabelWithHint: true,
                hintText: 'Photosynthesis occurs in chloroplasts.\nChlorophyll absorbs red and blue light.\nATP is synthesized in stroma.',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final raw = textController.text.trim();
              if (raw.isEmpty) return;

              Navigator.of(ctx).pop();

              final rawLines = raw
                  .split(RegExp(r'\r\n|\r|\n'))
                  .map((l) => l.trim())
                  .where((l) => l.isNotEmpty)
                  .toList();

              final ocrLines = <OcrLine>[];
              for (var i = 0; i < rawLines.length; i++) {
                ocrLines.add(
                  OcrLine(
                    lineNumber: i + 1,
                    text: rawLines[i],
                    confidence: null,
                  ),
                );
              }

              context.push('/ocr-review', extra: ocrLines);
            },
            child: const Text('Proceed to Review'),
          ),
        ],
      ),
    );
  }

  void _proceedToReview() {
    if (_capturedPages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please capture at least 1 note page first.'),
        ),
      );
      return;
    }

    // Pass captured pages to OCR review screen
    context.push('/ocr-review', extra: _capturedPages);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final profileAsync = ref.watch(activeProfileProvider);
    final profile = profileAsync.value ?? ProfileType.dyslexia;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Scan Handwritten Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library),
            tooltip: 'Choose from Gallery',
            onPressed: _capturedPages.length < 5
                ? _pickImagesFromGallery
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.edit_note),
            tooltip: 'Type or Paste Note Text',
            onPressed: _showPasteNoteDialog,
          ),
          if (_selectedMode == CaptureSourceMode.camera)
            IconButton(
              icon: Icon(
                _flashMode == FlashMode.torch
                    ? Icons.flash_on
                    : _flashMode == FlashMode.auto
                    ? Icons.flash_auto
                    : Icons.flash_off,
                color: _flashMode != FlashMode.off
                    ? Colors.amber
                    : Colors.white,
              ),
              tooltip: 'Toggle Flash',
              onPressed: _toggleFlash,
            ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Framing Tips',
            onPressed: () => _showFramingTips(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: Column(
              children: [
                // Mode Selector: Camera Scan vs. Gallery Import
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: const Color(0xFF16161A),
                  child: Center(
                    child: SegmentedButton<CaptureSourceMode>(
                      style: SegmentedButton.styleFrom(
                        backgroundColor: const Color(0xFF222228),
                        selectedBackgroundColor: colorScheme.primary,
                        selectedForegroundColor: Colors.white,
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                      ),
                      segments: const [
                        ButtonSegment(
                          value: CaptureSourceMode.camera,
                          icon: Icon(Icons.camera_alt, size: 18),
                          label: Text('Camera Scan'),
                        ),
                        ButtonSegment(
                          value: CaptureSourceMode.gallery,
                          icon: Icon(Icons.photo_library, size: 18),
                          label: Text('Gallery Import'),
                        ),
                      ],
                      selected: {_selectedMode},
                      onSelectionChanged: (set) {
                        setState(() => _selectedMode = set.first);
                      },
                    ),
                  ),
                ),

                // Mode 1: Camera Scan
                if (_selectedMode == CaptureSourceMode.camera) ...[
                  // Lighting guidance
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: const Color(0xFF212121),
                    child: const Row(
                      children: [
                        Icon(Icons.light_mode, size: 18, color: Colors.white70),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Use even lighting and avoid shadows across the page.',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Camera Viewfinder & Framing Guide
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (_cameraController != null && _isCameraInitialized)
                          Center(child: CameraPreview(_cameraController!))
                        else
                          Container(
                            color: const Color(0xFF1E1E24),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.document_scanner,
                                    size: 72,
                                    color: Colors.white54,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Document Framing Viewfinder',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Align note page inside the borders below',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    alignment: WrapAlignment.center,
                                    children: [
                                      OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          side: const BorderSide(
                                            color: Colors.white38,
                                          ),
                                        ),
                                        icon: const Icon(
                                          Icons.photo_library,
                                          size: 16,
                                        ),
                                        label: const Text(
                                          'Choose from Gallery',
                                        ),
                                        onPressed: _pickImagesFromGallery,
                                      ),
                                      OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          side: const BorderSide(
                                            color: Colors.white38,
                                          ),
                                        ),
                                        icon: const Icon(
                                          Icons.science,
                                          size: 16,
                                        ),
                                        label: const Text('Demo: Biology Scan'),
                                        onPressed: () =>
                                            _loadSampleNote('note_001'),
                                      ),
                                      OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          side: const BorderSide(
                                            color: Colors.white38,
                                          ),
                                        ),
                                        icon: const Icon(Icons.code, size: 16),
                                        label: const Text('Demo: CS Scan'),
                                        onPressed: () =>
                                            _loadSampleNote('note_002'),
                                      ),
                                      OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          side: const BorderSide(
                                            color: Colors.white38,
                                          ),
                                        ),
                                        icon: const Icon(
                                          Icons.edit_note,
                                          size: 16,
                                        ),
                                        label: const Text('Type / Paste Notes'),
                                        onPressed: _showPasteNoteDialog,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Framing Guide Corners (Document Bounding Box Overlay)
                        IgnorePointer(
                          child: Center(
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 32,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: colorScheme.primary.withValues(
                                    alpha: 0.8,
                                  ),
                                  width: 2.5,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  margin: const EdgeInsets.only(top: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Align page flat within borders',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        if (_isProcessingCapture)
                          Container(
                            color: Colors.black54,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Mode 2: Gallery Import Workspace
                  Expanded(
                    child: Container(
                      color: const Color(0xFF141418),
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 20,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E1E26),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: colorScheme.primary.withValues(
                                      alpha: 0.35,
                                    ),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 18,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.photo_library_outlined,
                                      size: 64,
                                      color: colorScheme.primary,
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Import Note or Question Paper',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Select up to 5 clear photo captures from your gallery or document files.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    FilledButton.icon(
                                      style: FilledButton.styleFrom(
                                        backgroundColor: colorScheme.primary,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 14,
                                        ),
                                      ),
                                      icon: const Icon(Icons.photo_library),
                                      label: const Text('Choose from Gallery'),
                                      onPressed: _capturedPages.length < 5
                                          ? _pickImagesFromGallery
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                alignment: WrapAlignment.center,
                                children: [
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      side: const BorderSide(
                                        color: Colors.white38,
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.camera_alt,
                                      size: 16,
                                    ),
                                    label: const Text('+ Scan with Camera'),
                                    onPressed: () {
                                      setState(
                                        () => _selectedMode =
                                            CaptureSourceMode.camera,
                                      );
                                    },
                                  ),
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      side: const BorderSide(
                                        color: Colors.white38,
                                      ),
                                    ),
                                    icon: const Icon(Icons.science, size: 16),
                                    label: const Text('Demo: Biology Scan'),
                                    onPressed: () =>
                                        _loadSampleNote('note_001'),
                                  ),
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      side: const BorderSide(
                                        color: Colors.white38,
                                      ),
                                    ),
                                    icon: const Icon(Icons.code, size: 16),
                                    label: const Text('Demo: CS Scan'),
                                    onPressed: () =>
                                        _loadSampleNote('note_002'),
                                  ),
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      side: const BorderSide(
                                        color: Colors.white38,
                                      ),
                                    ),
                                    icon: const Icon(Icons.edit_note, size: 16),
                                    label: const Text('Type / Paste Notes'),
                                    onPressed: _showPasteNoteDialog,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],

                // Captured Pages Strip (Burst 1-5 pages)
                Container(
                  height: 90,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: const Color(0xFF121214),
                  child: Row(
                    children: [
                      Text(
                        'Pages\n(${_capturedPages.length}/5)',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _capturedPages.isEmpty
                            ? const Center(
                                child: Text(
                                  'Capture 1 to 5 pages of handwritten notes',
                                  style: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 13,
                                  ),
                                ),
                              )
                            : ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _capturedPages.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(width: 10),
                                itemBuilder: (context, index) {
                                  return Stack(
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 74,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade800,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.white38,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.description,
                                                color: Colors.white,
                                                size: 24,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'P. ${index + 1}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: IconButton(
                                          tooltip: 'Remove page ${index + 1}',
                                          icon: const Icon(Icons.close),
                                          color: Colors.white,
                                          style: IconButton.styleFrom(
                                            backgroundColor:
                                                Colors.red.shade700,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _capturedPages.removeAt(index);
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),

                // Shutter & Controls
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  color: Colors.black,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        tooltip: 'Back to Library',
                        onPressed: () => context.pop(),
                      ),

                      // Option 2: Gallery Button
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton.filledTonal(
                            style: IconButton.styleFrom(
                              backgroundColor:
                                  _selectedMode == CaptureSourceMode.gallery
                                  ? colorScheme.primary
                                  : Colors.white12,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(48, 48),
                            ),
                            icon: const Icon(Icons.photo_library, size: 24),
                            tooltip: 'Choose from Gallery',
                            onPressed: () {
                              if (_selectedMode != CaptureSourceMode.gallery) {
                                setState(
                                  () =>
                                      _selectedMode = CaptureSourceMode.gallery,
                                );
                              }
                              if (_capturedPages.length < 5) {
                                _pickImagesFromGallery();
                              }
                            },
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Gallery',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),

                      // Option 1: Shutter Button (Camera)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Semantics(
                            button: true,
                            label: 'Capture note photo',
                            child: GestureDetector(
                              onTap: () {
                                if (_selectedMode != CaptureSourceMode.camera) {
                                  setState(
                                    () => _selectedMode =
                                        CaptureSourceMode.camera,
                                  );
                                } else if (_capturedPages.length < 5) {
                                  _capturePhoto();
                                }
                              },
                              child: Container(
                                width: 68,
                                height: 68,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3.5,
                                  ),
                                  color: _capturedPages.length < 5
                                      ? colorScheme.primary
                                      : Colors.grey,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Camera',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),

                      // Proceed to Review Button
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: _capturedPages.isNotEmpty
                              ? (profile == ProfileType.adhd
                                    ? AppPalettes.adhdSecondary
                                    : colorScheme.primary)
                              : Colors.grey.shade800,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                        onPressed: _capturedPages.isNotEmpty
                            ? _proceedToReview
                            : null,
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Review OCR'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFramingTips(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lightbulb_outline, color: Colors.amber),
            SizedBox(width: 8),
            Text('Optical Framing Tips'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Position camera parallel directly above the paper.'),
            SizedBox(height: 6),
            Text('• Ensure entire page fits comfortably within the border.'),
            SizedBox(height: 6),
            Text('• Avoid hand shadows across handwritten lines.'),
            SizedBox(height: 6),
            Text('• You can capture up to 5 consecutive pages per study set.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }
}
