# Changelog

All notable changes to the **NeuroScript AI** project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [0.3.0] - 2026-11-19

### Milestone 3 Release & Tech Stack Alignment (`v0.3.0-m3`)

#### Optical Acquisition & Isolate Image Preprocessing

* **Optical Document Capture (FR-01):** Implemented camera viewfinder with rectangular framing guide, flash toggle, and multi-page capture counter (up to 5 pages). Added gallery image picker for importing existing lecture photos.
* **Background Isolate Pipeline (FR-02):** Built pure-Dart background isolate image preprocessor (`lib/services/image_preprocessor.dart`) performing bounded resizing (max 1600px), continuous grayscale luminance gradient preservation, CLAHE dynamic contrast boost, Gaussian smoothing, and projection variance deskew. Binarization remains OFF by default to preserve CNN edge features. Authored [docs/adr/ADR-005-pure-dart-image-preprocessing.md](docs/adr/ADR-005-pure-dart-image-preprocessing.md).
* **On-Device OCR Engine (FR-03):** Integrated Google ML Kit Text Recognition (`google_mlkit_text_recognition 1.0.3`) as the sole OCR engine. Pruned deprecated Tesseract.js, `ocr_web_bridge.dart`, `ocr_web_stub.dart`, and client-side Gemini vision remnants.
* **1-Based Line Transcription Editor (FR-04):** Built full-screen line editor assigning deterministic 1-based line identifiers (`L1`, `L2`, ...) with inline typo editing, line merging, insertion, deletion, and SHA-256 deduplication.

#### Backend Proxy Gateway (.NET 10 LTS)

* **.NET 10 LTS Upgrade:** Upgraded backend proxy project, Dockerfile, and CI workflow to .NET 10.0 LTS.
* **Gemini Cloud Compiler (M4A):** Implemented `GeminiLessonGenerator` calling Google Gemini API in a closed-book manner. Model name is loaded from configuration; API key is strictly read from environment variables (`GEMINI_API_KEY`).
* **Startup & Security Hardening:** Service fails startup in production if keys are missing. Enforced HTTPS redirection, HSTS, and restricted CORS origins (never `AllowAnyOrigin`).
* **Rate Limiting & Problem Details:** Enforced 20 req/min sliding-window token bucket returning RFC 7807 `application/problem+json` and `Retry-After` headers.

#### Platform & Stack Alignment

* **Target Platforms:** Aligned strictly with proposal mobile targets (Android API 24+, iOS 14+). Pruned `web/`, `windows/`, `linux/`, `macos/`, and legacy Pages deployment workflows.
* **Dependency Updates:** Pinned Flutter SDK `>=3.47.5`, Dart SDK `^3.13.4`, Riverpod `3.5.0`, GoRouter `18.1.4`, Drift `2.35.4`, `sqlite3` `3.9.1` with `sqlite3mc` build hook, `flutter_secure_storage` `11.2.0`, and `cupertino_icons` `^2.0.0`.
* **Testing:** Expanded test suite to **110 passing Flutter tests** and **9 passing C# backend tests** (119 total).

---

## [0.2.0+2] - 2026-11-01

### Milestone 1 & Milestone 2 Evaluation Release (`v0.2.1-m2`)

#### Security & Cryptography

* **Migrated from EOL SQLCipher:** Removed deprecated `sqlcipher_flutter_libs ^0.7.0+eol` and migrated to `sqlite3` (3.x) with SQLite3MultipleCiphers (`sqlite3mc`).
* **Fail-Closed Cipher Runtime:** Validates active cipher status via `PRAGMA cipher = 'sqlcipher';`. Throws typed `DatabaseEncryptionException` on failure; plaintext fallback is strictly prohibited.
* **Hardware-Backed Key Generation:** Automatically generates a 256-bit AES key via `Random.secure()` and stores it in `FlutterSecureStorage` (Android KeyStore / iOS Keychain).
* **Disk Header & Reopen Tests:** Added tests in `test/encryption_verification_test.dart` verifying that on-disk DB files do not contain the plaintext `"SQLite format 3\0"` header and that reopening with an incorrect key fails closed.
* **Android Backup Hardening:** Configured `android:allowBackup="false"` in `AndroidManifest.xml` to prevent ADB backup extraction.

#### Spaced Repetition (SRS) & Cognitive Accessibility

* **Pure-Dart 5-Box Leitner Engine:** Implemented `LeitnerScheduler` with intervals of 1, 3, 7, 14, and 30 days.
* **Profile-Driven Queue Capping:** Strictly caps review queues at 5 cards per session for ADHD learners to eliminate review anxiety; caps at 10 cards for Dyslexia and Autism.
* **Injected Clock Seam:** Abstracted `Clock` interface allows deterministic simulation of multi-day review schedules in unit tests.
* **Honest Attribution:** Set `groundingScore: null` for human-authored seed lessons and display "Seed lesson (author-written)" badge in provenance sheets.

#### Relational Database & Drift ORM

* **Foreign-Key Cascade Enforcement:** Foreign-key cascade constraints cleanly purge child flashcards and review progress records when parent lessons or notes are deleted.
* **Deterministic Deduplication:** Computes normalized SHA-256 `documentHash` on notes, preventing duplicate note insertion while returning canonical IDs.
* **Schema Migration Scaffold:** Migrated schema from version 1 to 2, introducing soft-delete (`is_deleted`) support for lessons.
* **Eliminated N+1 Queries:** Replaced sequential per-card progress lookups with batch SQL in-clause queries.

#### User Interface & Multi-Profile Design Systems

* **WCAG 2.1 AA Compliance:** Engineered three independent color palettes for ADHD (dopamine anchors), Dyslexia (anti-glare warm cream #FBF8EE, soft charcoal #2B2D42), and Autism (calm sage, low sensory noise).
* **Responsive Text Scaling:** Verified zero `RenderFlex` overflows at 1.0x and 2.0x text scaling across all screens.
* **Flashcard Set Editor:** Added `/lesson/:id/edit` screen to edit set titles, update questions/answers, and add/remove cards.
* **Soft-Delete Trash & Recovery:** Implemented Recently Deleted bottom sheet with badge indicators, restoring lessons or permanently purging them.
* **Concept Map Graph:** Interactive node-edge visualization with pan/zoom (`InteractiveViewer`) and node provenance inspection.
