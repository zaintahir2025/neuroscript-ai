// ============================================================================
// NeuroScript AI: Privacy-Preserving Study Platform for Neurodivergent Learners
// File: lib/services/install_id_service.dart
//
// Description:
//   Hardware-isolated, persistent installation identifier generator.
//   Ensures each device has a unique, pseudonymous installation UUID stored
//   in hardware-backed secure storage. Prevents multiple devices from sharing
//   a single rate-limit bucket on the cloud proxy.
// ============================================================================

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class InstallIdService {
  static const String storageKey = 'neuroscript_device_install_id';
  static String? _cachedMemoryId;

  /// Retrieves the existing device install ID or generates a fresh cryptographically
  /// secure UUID v4, persisting it to hardware-backed secure storage.
  static Future<String> getOrCreateInstallId({
    FlutterSecureStorage? secureStorage,
  }) async {
    if (_cachedMemoryId != null) {
      return _cachedMemoryId!;
    }

    final storage = secureStorage ?? const FlutterSecureStorage();
    try {
      final existing = await storage
          .read(key: storageKey)
          .timeout(const Duration(milliseconds: 300), onTimeout: () => null);
      if (existing != null && existing.trim().isNotEmpty) {
        _cachedMemoryId = existing.trim();
        return _cachedMemoryId!;
      }

      final generated = 'inst_${const Uuid().v4()}';
      await storage
          .write(key: storageKey, value: generated)
          .timeout(const Duration(milliseconds: 300), onTimeout: () {});
      _cachedMemoryId = generated;
      return generated;
    } on Object {
      // In environments where secure storage is unavailable (e.g. headless unit tests),
      // fallback to a volatile memory identifier.
      _cachedMemoryId ??= 'inst_mem_${const Uuid().v4()}';
      return _cachedMemoryId!;
    }
  }

  /// Clears the in-memory cache (primarily for unit test isolation).
  static void resetCache() {
    _cachedMemoryId = null;
  }
}
