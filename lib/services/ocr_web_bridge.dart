// ============================================================================
// NeuroScript AI: Privacy-Preserving Study Platform for Neurodivergent Learners
// File: lib/services/ocr_web_bridge.dart
//
// Description:
//   Client-side in-browser WASM OCR bridge for Flutter Web using Tesseract.js.
//   Executes completely offline inside a browser WebWorker.
// ============================================================================

import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

@JS('neuroscriptOcr')
external JSPromise<JSString>? _jsNeuroscriptOcr(
  JSString base64Data,
  JSString mimeType,
);

/// Dispatches an image byte buffer to the in-browser WASM OCR engine.
Future<List<Map<String, dynamic>>> runWebOcr(Uint8List imageBytes) async {
  try {
    final base64Str = base64Encode(imageBytes).toJS;
    final mimeType = 'image/jpeg'.toJS;
    final promise = _jsNeuroscriptOcr(base64Str, mimeType);
    if (promise == null) return const [];
    final jsRes = await promise.toDart;
    final jsonStr = jsRes.toDart;
    if (jsonStr.isEmpty) return const [];
    final decoded = jsonDecode(jsonStr);
    if (decoded is List) {
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return const [];
  } on Object {
    return const [];
  }
}
