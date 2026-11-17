# Physical Device Verification & Platform Setup Matrix

**Project:** NeuroScript AI  
**Milestone:** 3  
**Platforms:** Android (API 26+) & iOS (iOS 15.5+)  

---

## 1. Physical Device Verification Matrix

| Capability / Subsystem | Physical Android (Phone / Tablet) | iOS Setup & Verification | Verification Status | Notes |
|---|---|---|---|---|
| **Camera Capture** | Verified (`android.permission.CAMERA`) | Configured (`NSCameraUsageDescription`, `ios/Podfile` target 15.5) | **PASS** | Viewfinder preview, multi-page capture counter, flash toggle |
| **Photo Gallery Ingestion** | Verified (`READ_MEDIA_IMAGES` / Photo Picker) | Configured (`NSPhotoLibraryUsageDescription`) | **PASS** | Multi-image selection up to 5 pages |
| **On-Device OCR (ML Kit)** | Verified via background isolate | Configured via Podfile GoogleMLKit pod bindings | **PASS** | 1-based numbered lines, tilt deskew |
| **Encrypted Database** | Verified (SQLCipher AES-256) | Verified (SQLCipher AES-256) | **PASS** | Key generated and protected via Secure Storage |
| **Per-Device Rate Limiting** | Verified (Unique UUID v4 per device) | Verified (Unique UUID v4 per device) | **PASS** | `InstallIdService` backed by hardware keystore |
| **Network Gateway Security** | Verified (`android.permission.INTERNET`) | Verified (NSAppTransportSecurity) | **PASS** | Authenticated via `X-Api-Key`, sliding window 20 req/min |
| **Accessibility & Scaling** | Verified at 1.0x, 1.5x, 2.0x text scale | Verified with Dynamic Type | **PASS** | 48dp+ tap targets, semantic labels |

---

## 2. iOS Configuration Details
- Deployment target pinned to `platform :ios, '15.5'` in `ios/Podfile` to support Google ML Kit vision text recognition frameworks.
- Added privacy disclosures to `ios/Runner/Info.plist`:
  - `NSCameraUsageDescription`: *"NeuroScript uses the camera to scan your study notes on your device."*
  - `NSPhotoLibraryUsageDescription`: *"NeuroScript needs photo library access to allow selecting handwritten study notes from your gallery."*

## 3. Android Configuration Details
- Permissions declared in `android/app/src/main/AndroidManifest.xml`:
  - `android.permission.INTERNET`: Required for ASP.NET Core cloud proxy communication.
  - `android.permission.CAMERA`: Required for camera viewfinder and photo capture.
  - `android.permission.READ_MEDIA_IMAGES`: Modern photo picker access on Android 13+.
  - `android.permission.READ_EXTERNAL_STORAGE` (maxSdkVersion 32): Legacy gallery compatibility.
- ProGuard rules configured in `android/app/proguard-rules.pro` to prevent R8 minification stripping of ML Kit classes in release APKs.
