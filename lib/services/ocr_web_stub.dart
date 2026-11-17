// ============================================================================
// NeuroScript AI: Privacy-Preserving Study Platform for Neurodivergent Learners
// File: lib/services/ocr_web_stub.dart
//
// Description:
//   Fallback stub for non-web platforms (Android, iOS, Desktop, and Tests).
//   Ensures the Android release APK has zero JS or web overhead.
// ============================================================================

import 'dart:typed_data';

/// Non-web fallback returns empty list so native Google ML Kit handles recognition.
Future<List<Map<String, dynamic>>> runWebOcr(Uint8List imageBytes) async {
  return const [];
}
