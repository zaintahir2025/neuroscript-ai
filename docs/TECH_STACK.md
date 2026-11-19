# NeuroScript AI: Technical Stack & Dependency Manifest

Authoritative inventory of technologies, frameworks, libraries, and tools utilized in **NeuroScript AI**, aligned with **Section 10.1** of the Project Proposal and upgraded to latest stable releases.

---

## 1. Master Tech Stack Matrix

| Proposal Item | Package / Tool | Chosen Version | Status | Notes |
| :--- | :--- | :--- | :--- | :--- |
| **Mobile Application Framework** | Flutter SDK / Dart SDK | Flutter >=3.47.5 / Dart ^3.13.4 | Implemented (M1) | Mobile-only targets: Android (API 24+) and iOS (iOS 14+). Non-mobile platforms (web, windows, linux, macos) pruned. |
| **State Management** | `flutter_riverpod` | `3.5.0` | Implemented (M1-M3) | Reactive unidirectional state management, scoped repository dependency injection, and fine-tuning state holders. |
| **Application Routing** | `go_router` | `18.1.4` | Implemented (M1) | Declarative route hierarchy with deep linking and navigation transitions. |
| **Relational Database ORM** | `drift` / `drift_dev` | `2.35.4` / `2.35.3` | Implemented (M2) | Reactive compile-time type-safe SQLite ORM with atomic transactions and foreign key cascades. |
| **Database Encryption Engine** | `sqlite3` + `sqlite3mc` build hook | `3.9.1` | Implemented (M2) | SQLite3MultipleCiphers in SQLCipher-compatible mode (`PRAGMA cipher = 'sqlcipher'`), fail-closed validation (`SELECT sqlite3mc_version()`). Replaces EOL `sqlcipher_flutter_libs` (ADR-004). |
| **Hardware Key Persistence** | `flutter_secure_storage` | `11.2.0` | Implemented (M2) | 256-bit AES master encryption key storage backed by Android Keystore and Apple Keychain. |
| **Cryptographic Hashing** | `crypto` | `^3.0.8` | Implemented (M2) | SHA-256 document hashing for note deduplication and revision tracking. |
| **OCR Text Recognition** | `google_mlkit_text_recognition` | `1.0.3` | Implemented (M3) | On-device Google ML Kit Latin script recognizer. Sole OCR engine; all web/Tesseract.js remnants removed. |
| **Image Preprocessing** | `image` (pure Dart) | `4.13.1` | Implemented (M3) | Resizing, grayscale, contrast normalization, smoothing, and 2-pass Radon deskew in background isolate. Binarization OFF by default. Evaluated `opencv_dart 2.2.2` (ADR-005). |
| **Camera Viewfinder** | `camera` | `^0.12.2` | Implemented (M3) | Real-time camera capture pipeline with burst mode support. |
| **Media Library Picker** | `image_picker` | `^1.2.4` | Implemented (M3) | Gallery image selection for handwritten note import. |
| **HTTP Client (App)** | `http` | `^1.6.0` | Implemented (M3) | REST client communicating with the ASP.NET Core proxy endpoint. |
| **Backend Web Framework** | ASP.NET Core (.NET 10 LTS) | `.NET 10.0` (C# 14) | Implemented (M3) | Ephemeral rate-limiting reverse proxy with 256 KB body cap, HSTS, HTTPS redirection, and restricted CORS. |
| **Backend Testing Suite** | `xUnit` + `Microsoft.AspNetCore.Mvc.Testing` | `2.9.3` / `10.0.0` | Implemented (M3) | Integration and unit testing for proxy endpoints, sliding-window rate limiter, and authentication guards. |
| **Cloud AI Lesson Generator** | Google Gemini API (Proxy-Only) | `gemini-2.5-flash` (configurable) | Implemented (M3/M4A) | Called strictly through ASP.NET Core proxy (`GeminiLessonGenerator`). Model name in configuration; API key only in environment variables. |
| **On-Device Small Language Model (SLM)** | `llamadart` | *Planned* | Planned for M4C | On-device SLM inference runtime (e.g., Gemma 2B / SmolLM 135M) for zero-network, fully private study compilation. |
| **On-Device Embedding & Semantic Grounding** | `all-MiniLM-L6-v2` via ONNX Runtime / TFLite | *Planned* | Planned for M4B | Sentence embedding cosine similarity validator to cross-check flashcard Q&A against source OCR lines for hallucination prevention. |
| **Text-To-Speech (TTS) Engine** | `flutter_tts` | *Planned* | Planned for M5 | Native speech synthesis engine providing dyslexia audio read-aloud support. |
| **Design Language & Icons** | `cupertino_icons` / Material Design 3 | `^2.0.0` | Implemented (M1) | High-contrast WCAG 2.1 AA compliant UI tokens across ADHD, Dyslexia, and Autism profiles. |

---

## 2. Platform Targets

* **Primary Targets:** Android mobile & tablet devices (API 24 / Android 7.0+), iOS devices (iOS 14.0+).
* **Removed Platforms:** Web, Windows, macOS, Linux, and GitHub Pages workflows have been removed from the repository to maintain strict alignment with the mobile-first final year project scope.
