# NeuroScript AI Requirement Traceability & Evaluation Matrix

This document provides an evidence-based traceability matrix mapping requirements from the **System Requirements Specification** and **Milestone Execution Plan** to concrete source code, automated test suites, and verified outcomes.

---

## 1. Evaluation Summary

* **Branch:** `chore/stack-and-cleanup`
* **Release Version:** `v0.3.0-m3`
* **Automated Flutter Tests:** **110 tests passed, 0 failures** (`flutter test`, November 2026)
* **Automated Backend Tests:** **9 tests passed, 0 failures** (`dotnet test server/NeuroScriptProxy/NeuroScriptProxy.sln`)
* **Static Analysis:** **0 issues found** (`flutter analyze` with strict analysis options)
* **Code Formatting:** **100% compliant** (`dart format --output=none --set-exit-if-changed .`)
* **Backend Build:** **0 errors, 0 warnings** (`dotnet build server/NeuroScriptProxy/NeuroScriptProxy.sln`)
* **Physical Hardware Execution:** **NOT TESTED YET** (Verified via automated test suites and headless emulator; physical device benchmarks tracked in [docs/DEVICE_VERIFICATION_MATRIX.md](DEVICE_VERIFICATION_MATRIX.md)).
* **Clinical Efficacy Trials:** **NOT TESTED YET** (Protocol instruments drafted in `docs/evaluation/`; evaluation tracked in [docs/EXPERT_REVIEW.md](EXPERT_REVIEW.md)).

---

## 2. Requirement Traceability Matrix

| Requirement / WP | Description & Technical Criteria | Implementation Files | Automated Evidence & Tests | Evaluation Status |
| :--- | :--- | :--- | :--- | :---: |
| **WP1.1: WCAG 2.1 AA Themes** | Multi-profile design systems (ADHD, Dyslexia, Autism) with verified contrast ratios $\ge 4.5:1$, scotopic anti-glare warm backgrounds, and minimum 48 dp touch targets. | `lib/core/theme/app_palettes.dart`<br>`lib/core/theme/app_theme.dart` | `test/theme_wcag_test.dart`<br>(5 automated WCAG contrast tests) | **Verified (Automated)** |
| **WP1.2: System Architecture** | Formal declarative JSON schema contract for study units, unidirectional Riverpod state flow, declarative GoRouter navigation, and responsive layouts. | `docs/contracts/lesson.schema.json`<br>`lib/app/router.dart` | `test/seed_contract_test.dart`<br>`test/widget_test.dart` | **Verified (Automated)** |
| **WP1.3: Architectural Decisions** | Documented rationale for core architectural choices (Drift ORM, Riverpod DI, Leitner SRS, SQLite3MC encryption, pure-Dart image preprocessing). | `docs/adr/ADR-001-drift-orm.md`<br>`docs/adr/ADR-002-riverpod-state-management.md`<br>`docs/adr/ADR-003-leitner-srs-engine.md`<br>`docs/adr/ADR-004-sqlite3mc-encryption-migration.md`<br>`docs/adr/ADR-005-pure-dart-image-preprocessing.md` | Architectural documentation suite | **Verified** |
| **WP2.1: Fail-Closed Database Encryption** | AES-256 on-disk encryption via SQLite3MultipleCiphers (`sqlite3mc`) in SQLCipher-compatible mode. 256-bit cryptographically secure key in `FlutterSecureStorage`. Fail-closed exception (`DatabaseEncryptionException`) if cipher inactive. | `lib/data/database/connection/connection_native.dart`<br>`lib/services/key_storage_service.dart` | `test/encryption_verification_test.dart`<br>(Disk 16-byte header check, wrong-key rejection, secure wipe) | **Verified (Automated)** |
| **WP2.1: Relational Schema & Cascades** | Foreign-key cascade deletes across `SourceNotes` $\to$ `Lessons` $\to$ `Flashcards` $\to$ `ReviewProgress`. Unique index on `documentHash`. Schema migrations. | `lib/data/database/tables.dart`<br>`lib/data/repositories/app_repositories.dart` | `test/cascade_delete_test.dart`<br>`test/migration_test.dart` | **Verified (Automated)** |
| **WP2.1: Cryptographic Document Hashing** | SHA-256 normalization invariance (trimming, whitespace collapse, case invariance, line-ending normalization) preventing duplicate note ingestion. | `lib/core/utils/document_hash.dart` | `test/document_hash_test.dart`<br>(Whitespace, casing, determinism tests) | **Verified (Automated)** |
| **WP2.2: 5-Box Leitner SRS Engine** | Pure-Dart spaced repetition system with empirical intervals (1 $\to$ 3 $\to$ 7 $\to$ 14 $\to$ 30 days). Correct answers advance one box; incorrect answers reset to Box 1. Queue capped at 5 for ADHD and 10 for Dyslexia/Autism. | `lib/services/scheduler_service.dart` | `test/journey_test.dart`<br>`test/m3_complete_pipeline_test.dart` | **Verified (Automated)** |
| **WP2.3: Idempotent Seed Curriculum** | Automated seeding of curated curriculum JSON files from assets into encrypted database. Atomic transaction rollback on malformed JSON. Exactly 0 duplicates on subsequent runs. | `lib/services/seed_service.dart`<br>`assets/seed/*.json` | `test/seed_contract_test.dart` | **Verified (Automated)** |
| **WP2.4: Study Dashboard & Library** | Study progress banner, due count metrics, search filtering, multi-criteria sorting, Note Transcript Details with SHA-256 hash inspection, and concept map launcher. | `lib/features/library/screens/library_screen.dart` | `test/widget_test.dart`<br>(Tests 3, 9, 10) | **Verified (Automated)** |
| **WP2.4: Soft-Delete Trash & Recovery** | Move study sets to Recently Deleted trash with instant badge counter update, full restore to active library, or permanent cascading purge. | `lib/features/library/screens/library_screen.dart`<br>`lib/data/repositories/app_repositories.dart` | `test/widget_test.dart` (Test 9) | **Verified (Automated)** |
| **WP2.5: Active Recall Review Session** | Interactive card flipping, visual box level indicator, dual response actions, Leitner progression, and provenance modal showing source line citations. | `lib/features/study/screens/flashcard_review_screen.dart` | `test/widget_test.dart` (Test 4)<br>`test/journey_test.dart` | **Verified (Automated)** |
| **WP2.5: Interactive Concept Map Graph** | CustomPainter rendering nodes and labelled directed edges, pinch-to-zoom and pan via `InteractiveViewer`, and tapping nodes to view line provenance. | `lib/features/concept_map/screens/concept_map_screen.dart` | `test/widget_test.dart` (Test 5) | **Verified (Automated)** |
| **WP2.5: Accessibility & Text Scaling** | Layout responsiveness: zero `RenderFlex` overflows at standard 1.0x and high-contrast 2.0x text scaling across all primary screens. | All screen files under `lib/features/` | `test/golden_test.dart`<br>(1.0x & 2.0x text scale verification) | **Verified (Automated)** |
| **FR-01: Optical Document Capture (Camera & Gallery)** | Dual-mode capture: live camera viewfinder (up to 5 pages), shutter counter, flash toggle, and photo library gallery ingestion (multi-select up to 5 images). | `lib/features/capture/screens/capture_screen.dart` | `test/phase3_widget_test.dart`<br>`test/m3_complete_pipeline_test.dart` | **Verified (Automated)** |
| **FR-02: Isolate Preprocessing** | Background isolate pipeline with contrast enhancement, continuous luminance preservation, Gaussian smoothing, and geometric deskew. Binarization OFF by default. | `lib/services/image_preprocessor.dart` | `docs/adr/ADR-005-pure-dart-image-preprocessing.md` | **Verified (Automated)** |
| **FR-03: 1-Based OCR Line Transcription** | On-device Google ML Kit text recognition with 1-based line indexing and coordinate bounding boxes. Configured with Android ProGuard retention and iOS Podfile (deployment target 15.5). | `lib/services/ocr_service.dart`<br>`lib/data/models/ocr_models.dart` | `test/m3_complete_pipeline_test.dart` | **Verified (Automated)** |
| **FR-04: Interactive OCR Line Review & Deduplication** | Editable numbered line review screen with inline editing, line merging, insertion, deletion, and reordering. Re-scan detection checks existing note hashes, preventing duplicate lesson generation. | `lib/features/ocr/screens/ocr_review_screen.dart` | `test/phase3_widget_test.dart`<br>`test/m3_complete_pipeline_test.dart` | **Verified (Automated)** |
| **Stage 4: ASP.NET Core Proxy Gateway** | .NET 10 LTS gateway: persistent install ID (`InstallIdService`), sliding-window rate limit (20 req/min) with exact `Retry-After`, 256 KB request body limit, 200 line / 25k char validation, sanitized error responses, metadata privacy audit log, HTTPS/HSTS, and restricted CORS. | `server/NeuroScriptProxy/Program.cs`<br>`server/NeuroScriptProxy.Tests/`<br>`lib/services/proxy_service.dart` | `server/NeuroScriptProxy.Tests/RateLimiterTests.cs`<br>`server/NeuroScriptProxy.Tests/ProxyEndpointTests.cs` | **Verified (Automated)** |

---

## 3. Unverified Items Tracking

| Roadmap Item | Planned Milestone | Current Status | Blocker / Requirement |
| :--- | :--- | :--- | :--- |
| **Physical Hardware Matrix** | M3 / M6 | **NOT TESTED YET** | Requires physical Android API 24+ and iOS 14+ devices ([docs/DEVICE_VERIFICATION_MATRIX.md](DEVICE_VERIFICATION_MATRIX.md)). |
| **On-Device SLM Fallback** | M4C | **Planned (M4)** | Local GGUF execution via `llamadart` (`docs/TECH_STACK.md`). |
| **On-Device Grounding Engine** | M4B | **Planned (M4)** | Semantic citation verification gate ($G \ge 0.80$). |
| **Semantic Embedding Clustering** | M5 | **Planned (M5)** | Sentence transformer (`all-MiniLM-L6-v2`) vector clustering. |
| **Assistive Audio (TTS)** | M6 | **Planned (M6)** | Text-to-speech narration via `flutter_tts`. |
| **Clinical Psychologist Trials** | M6 | **NOT TESTED YET** | Expert psychologist evaluations ([docs/EXPERT_REVIEW.md](EXPERT_REVIEW.md)). |
