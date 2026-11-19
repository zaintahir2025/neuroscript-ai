# Physical Device Verification & Platform Setup Matrix

**Project:** NeuroScript AI  
**Milestone:** 3  
**Platforms:** Android (API 24+) & iOS (iOS 14+)  
**Verification Posture:** Honest evaluation status. No dated physical device hardware run logs currently exist in `docs/evidence/`. Capabilities are configured in platform manifests/properties and verified via automated unit and widget test suites. Physical device field testing is scheduled for Milestone 6.

---

## 1. Physical Device Verification Matrix

| Capability / Subsystem | Physical Android (Phone / Tablet) | iOS Setup & Verification | Verification Status | Notes |
|---|---|---|---|---|
| **Camera Capture** | Configured (`android.permission.CAMERA`) | Configured (`NSCameraUsageDescription`, `ios/Podfile` target 15.5) | **NOT TESTED YET** | Configured in manifests. Camera mocked in automated tests. Physical hardware testing scheduled for M6. |
| **Photo Gallery Ingestion** | Configured (`READ_MEDIA_IMAGES` / Photo Picker) | Configured (`NSPhotoLibraryUsageDescription`) | **NOT TESTED YET** | Photo picker configured. Multi-image selection tested via mock widgets in CI. Physical hardware testing scheduled for M6. |
| **On-Device OCR (ML Kit)** | Configured via Google ML Kit Android dependencies | Configured via `Podfile` GoogleMLKit pod bindings | **NOT TESTED YET** | Google ML Kit Latin recognizer integrated. Physical device inference latency NOT MEASURED YET. |
| **Encrypted Database** | Configured (sqlite3mc SQLCipher-compatible mode) | Configured (sqlite3mc SQLCipher-compatible mode) | **NOT TESTED YET** | AES-256 encryption verified in automated unit tests (`encryption_verification_test.dart`). Physical disk extraction on rooted hardware NOT TESTED YET. |
| **Per-Device Rate Limiting** | Configured (UUID v4 in `FlutterSecureStorage`) | Configured (UUID v4 in Keychain) | **NOT TESTED YET** | `InstallIdService` logic verified in unit tests. Physical device hardware keystore persistence NOT TESTED YET. |
| **Network Gateway Security** | Configured (`android.permission.INTERNET`) | Configured (`NSAppTransportSecurity`) | **NOT TESTED YET** | Proxy endpoint and TLS verified via backend test suite. Physical cellular/WiFi gateway round-trip NOT TESTED YET. |
| **Accessibility & Scaling** | Configured (Material 3 high-contrast tokens) | Configured (Dynamic Type scaling) | **NOT TESTED YET** | 1.0x and 2.0x text scaling verified via golden unit tests. Physical device screen reader (TalkBack / VoiceOver) audit NOT TESTED YET. |

---

## 2. Platform Configuration Details

### 2.1 iOS Configuration

- Deployment target pinned to `platform :ios, '15.5'` in `ios/Podfile` to support Google ML Kit vision text recognition frameworks.
- Privacy disclosures configured in `ios/Runner/Info.plist`:
  - `NSCameraUsageDescription`: *"NeuroScript uses the camera to scan your study notes on your device."*
  - `NSPhotoLibraryUsageDescription`: *"NeuroScript needs photo library access to allow selecting handwritten study notes from your gallery."*

### 2.2 Android Configuration

- Permissions declared in `android/app/src/main/AndroidManifest.xml`:
  - `android.permission.INTERNET`: Required for ASP.NET Core cloud proxy communication.
  - `android.permission.CAMERA`: Required for camera viewfinder and photo capture.
  - `android.permission.READ_MEDIA_IMAGES`: Modern photo picker access on Android 13+.
  - `android.permission.READ_EXTERNAL_STORAGE` (maxSdkVersion 32): Legacy gallery compatibility.
- ProGuard rules configured in `android/app/proguard-rules.pro` to prevent R8 minification stripping of ML Kit classes in release APKs.
