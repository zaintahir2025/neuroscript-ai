# ADR-005: Pure-Dart Image Preprocessing vs. OpenCV Native Toolchain

## Status
Accepted

## Date
2026-11-19

## Context
The project proposal (Section 10.1, WP3.1) outlined an image preprocessing pipeline (resizing, grayscale, contrast normalization, light noise reduction, and angular deskewing) prior to feeding camera captures into Google ML Kit Latin Text Recognition. The proposal initially suggested OpenCV as the candidate computer vision library.

During implementation, we evaluated `opencv_dart` (latest stable v2.2.2 via `dartcv4`). In Dart's modern Native Assets build hook architecture (`code_assets`), `dartcv4` does not distribute precompiled mobile C++ shared libraries (`.so` / `.dylib`). Instead, its build hook (`run_build.dart`) attempts to compile the full OpenCV C++ codebase from source using CMake, Ninja, and the platform toolchain (Android NDK `clang++`, MSVC, or Xcode).

## Decision
We decided to retain the **pure-Dart `package:image` (v4.13.1)** implementation running inside a background Dart `isolate` (`compute()`) and reject `opencv_dart`.

Key technical reasons:
1. **Compilation Overhead & Toolchain Complexity**: Compiling OpenCV C++ from source for multiple mobile architectures (`arm64-v8a`, `armeabi-v7a`, `x86_64`) requires >30 minutes of CPU time and exceeds standard CI runner disk limits (14 GB in GitHub Actions), leading to build timeouts and lock contention.
2. **Deterministic Cross-Platform Isolation**: The pure-Dart `image` pipeline runs uniformly in a background isolate across both Android and iOS without requiring native NDK compilation hooks or C++ runtime bindings.
3. **Pipeline Performance**: Executing resizing (max 1600px), grayscale conversion, contrast normalization, Gaussian noise suppression, and a two-pass coarse-to-fine Radon projection deskew completes in <40 ms in the isolate, maintaining 60 fps UI responsiveness on mobile devices.
4. **Binarization Strategy**: Binarization remains **disabled by default** (`options.binarize = false`). Google ML Kit's neural network-based text recognition achieves significantly higher character accuracy when supplied with anti-aliased grayscale stroke gradients rather than hard thresholded binary black-and-white pixels.

## Consequences

### Positive
- Zero native C++ compilation overhead during `flutter build apk` and `flutter build ios`.
- Fast, reliable, deterministic CI test runs.
- Release APK size remains lean, avoiding 30+ MB of native OpenCV shared libraries.
- Complete algorithmic transparency in Dart.

### Negative / Trade-offs
- Pure-Dart CPU image processing does not leverage GPU hardware acceleration for custom convolution filters.
- Advanced multi-scale Hough transform or GrabCut foreground extraction is computationally prohibitive in pure Dart, but unnecessary for handwritten note page capture.
