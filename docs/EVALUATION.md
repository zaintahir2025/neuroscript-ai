# NeuroScript AI — Milestone 1, 2 & 3 Evaluation Matrix

This document provides a comprehensive, evidence-backed evaluation matrix mapping every requirement from the **NeuroScript AI Milestone Execution Plan** and **Project Proposal** to its concrete source implementation, automated tests, and verification status.

---

## 1. Evaluation Verification Summary

- **Target Scope**:
  - **Milestone 1**: Project Planning, Design System, Contracts & System Architecture
  - **Milestone 2**: Encrypted Local Storage (SQLCipher/sqlite3mc AES-256), 5-Box Leitner Study Engines & Multi-Profile UI
  - **Milestone 3**: Optical Acquisition (Burst Camera), Isolate Preprocessing, 1-Based OCR Line Transcription, Line Editor & ASP.NET Core Proxy Gateway
- **Branch**: `main`
- **Release Version**: `v0.3.0-m3`
- **Automated Test Results**: **99 tests passed, 0 failures** (`flutter test`, verified 2026-11-10)
- **Static Analysis**: **0 issues found** (`flutter analyze` with hardened rules)
- **Code Formatting**: **100% compliant** (`dart format --output=none --set-exit-if-changed lib test`)
- **Backend Proxy Build**: **0 errors, 0 warnings** (`dotnet build server/NeuroScriptProxy/NeuroScriptProxy.csproj`)
- **Continuous Integration**: Automated GitHub Actions workflow (`.github/workflows/ci.yml`)

---

## 2. Requirement Traceability Matrix (Milestones 1, 2 & 3)

| Requirement / WP | Description & Technical Criteria | Implementation Files | Automated Evidence & Tests | Evaluation Status |
| :--- | :--- | :--- | :--- | :---: |
| **WP1.1: WCAG 2.1 AA Themes** | Multi-profile design systems (ADHD, Dyslexia, Autism) with verified contrast ratios $\ge 4.5:1$, scotopic anti-glare warm backgrounds, zero vibrating colors, and minimum 48 dp touch targets. | [`lib/core/models/profile_type.dart`](file:///lib/core/models/profile_type.dart)<br>[`lib/core/theme/app_palettes.dart`](file:///lib/core/theme/app_palettes.dart)<br>[`lib/core/theme/app_theme.dart`](file:///lib/core/theme/app_theme.dart) | [`test/theme_wcag_test.dart`](file:///test/theme_wcag_test.dart)<br>(14 automated WCAG contrast tests) | **VERIFIED** |
| **WP1.2: System Architecture** | Formal declarative JSON schema contract for study units, unidirectional Riverpod state flow, declarative GoRouter navigation, and responsive layouts. | [`docs/contracts/lesson.schema.json`](file:///docs/contracts/lesson.schema.json)<br>[`lib/core/routing/app_router.dart`](file:///lib/core/routing/app_router.dart)<br>[`lib/features/providers.dart`](file:///lib/features/providers.dart) | [`test/seed_contract_test.dart`](file:///test/seed_contract_test.dart)<br>[`test/router_guard_test.dart`](file:///test/router_guard_test.dart) (13 tests) | **VERIFIED** |
| **WP1.3: Architectural Decisions** | Documented rationale for core architectural choices (Drift ORM, Riverpod DI, Leitner SRS, SQLite3MC encryption). | [`docs/adr/ADR-001-drift-orm.md`](file:///docs/adr/ADR-001-drift-orm.md)<br>[`docs/adr/ADR-002-riverpod-state-management.md`](file:///docs/adr/ADR-002-riverpod-state-management.md)<br>[`docs/adr/ADR-003-leitner-srs-engine.md`](file:///docs/adr/ADR-003-leitner-srs-engine.md)<br>[`docs/adr/ADR-004-sqlite3mc-encryption-migration.md`](file:///docs/adr/ADR-004-sqlite3mc-encryption-migration.md) | Architectural documentation suite | **VERIFIED** |
| **WP2.1: Fail-Closed Database Encryption** | AES-256 on-disk encryption via SQLite3MultipleCiphers (`sqlite3mc`). 256-bit cryptographically secure key in `FlutterSecureStorage`. Fail-closed exception (`DatabaseEncryptionException`) if cipher inactive. Disabled ADB backup. | [`lib/data/database/database.dart`](file:///lib/data/database/database.dart)<br>[`android/app/src/main/AndroidManifest.xml`](file:///android/app/src/main/AndroidManifest.xml) | [`test/encryption_verification_test.dart`](file:///test/encryption_verification_test.dart)<br>(Disk 16-byte header check, wrong-key rejection, secure wipe) | **VERIFIED** |
| **WP2.1: Relational Schema & Cascades** | Strict foreign-key cascade deletes across `SourceNotes` $\to$ `Lessons` $\to$ `Flashcards` $\to$ `ReviewProgress`. Unique index on `documentHash`. Schema migrations. | [`lib/data/database/database.dart`](file:///lib/data/database/database.dart)<br>[`lib/data/repositories/app_repositories.dart`](file:///lib/data/repositories/app_repositories.dart) | [`test/cascade_delete_test.dart`](file:///test/cascade_delete_test.dart)<br>[`test/migration_test.dart`](file:///test/migration_test.dart)<br>[`test/repository_test.dart`](file:///test/repository_test.dart) | **VERIFIED** |
| **WP2.1: Cryptographic Document Hashing** | SHA-256 normalization invariance (trimming, whitespace collapse, case invariance, line-ending normalization) preventing duplicate note ingestion. | [`lib/core/document_hash.dart`](file:///lib/core/document_hash.dart) | [`test/document_hash_test.dart`](file:///test/document_hash_test.dart)<br>(Whitespace, casing, determinism tests) | **VERIFIED** |
| **WP2.2: 5-Box Leitner SRS Engine** | Pure-Dart spaced repetition system with empirical intervals (1 $\to$ 3 $\to$ 7 $\to$ 14 $\to$ 30 days). Correct answers advance one box; incorrect answers reset to Box 1. Queue capped at 5 for ADHD and 10 for Dyslexia/Autism. | [`lib/services/leitner_scheduler.dart`](file:///lib/services/leitner_scheduler.dart) | [`test/scheduler_test.dart`](file:///test/scheduler_test.dart)<br>(15 unit test scenarios with `MockClock`) | **VERIFIED** |
| **WP2.3: Idempotent Seed Curriculum** | Automated seeding of curated curriculum JSON files from assets into encrypted database. Atomic transaction rollback on malformed JSON. Exactly 0 duplicates on subsequent runs. | [`lib/services/seed_importer.dart`](file:///lib/services/seed_importer.dart)<br>[`assets/seed/*.json`](file:///assets/seed/) | [`test/seed_importer_test.dart`](file:///test/seed_importer_test.dart)<br>[`test/seed_contract_test.dart`](file:///test/seed_contract_test.dart) | **VERIFIED** |
| **WP2.3: Honest Grounding Attribution** | Seed lessons explicitly authored by human subject experts have `groundingScore` set to `null` and render "Seed lesson (author-written)" badge, adhering to honest evaluation standards. | [`assets/seed/*.json`](file:///assets/seed/)<br>[`lib/features/common/where_is_this_from_sheet.dart`](file:///lib/features/common/where_is_this_from_sheet.dart)<br>[`lib/features/lesson/lesson_overview_screen.dart`](file:///lib/features/lesson/lesson_overview_screen.dart) | Verified in seed files and UI widgets | **VERIFIED** |
| **WP2.4: Study Dashboard & Library** | Study progress banner, due count metrics, search filtering, multi-criteria sorting, Note Transcript Details bottom sheet with SHA-256 hash inspection, and concept map launcher. | [`lib/features/library/library_screen.dart`](file:///lib/features/library/library_screen.dart)<br>[`lib/features/common/where_is_this_from_sheet.dart`](file:///lib/features/common/where_is_this_from_sheet.dart) | [`test/widget_test.dart`](file:///test/widget_test.dart)<br>(Tests 3, 9, 10) | **VERIFIED** |
| **WP2.4: Soft-Delete Trash & Recovery** | Move study sets to Recently Deleted trash with instant badge counter update, full restore to active library, or permanent cryptographic cascading purge. | [`lib/features/library/library_screen.dart`](file:///lib/features/library/library_screen.dart)<br>[`lib/data/repositories/app_repositories.dart`](file:///lib/data/repositories/app_repositories.dart) | [`test/widget_test.dart`](file:///test/widget_test.dart) (Test 9)<br>[`test/repository_test.dart`](file:///test/repository_test.dart) | **VERIFIED** |
| **WP2.4: Flashcard Set Editor** | Full set editing interface: edit lesson title, modify existing card questions/answers, delete individual cards, add new cards, with validation and persistence. | [`lib/features/lesson/edit_lesson_screen.dart`](file:///lib/features/lesson/edit_lesson_screen.dart)<br>[`lib/core/routing/app_router.dart`](file:///lib/core/routing/app_router.dart) | [`test/widget_test.dart`](file:///test/widget_test.dart) (Test 8)<br>[`test/repository_test.dart`](file:///test/repository_test.dart) | **VERIFIED** |
| **WP2.5: Active Recall Review Session** | Interactive card flipping, visual box level indicator, dual response actions ("Not yet" / "Got it!"), Leitner progression, and provenance modal showing exact source line citations. | [`lib/features/review/flashcard_review_screen.dart`](file:///lib/features/review/flashcard_review_screen.dart) | [`test/widget_test.dart`](file:///test/widget_test.dart) (Test 4)<br>[`test/journey_test.dart`](file:///test/journey_test.dart) | **VERIFIED** |
| **WP2.5: Interactive Concept Map Graph** | CustomPainter rendering nodes and labelled directed edges, pinch-to-zoom and pan via `InteractiveViewer`, and tapping nodes to view line provenance. | [`lib/features/concept_map/concept_map_screen.dart`](file:///lib/features/concept_map/concept_map_screen.dart) | [`test/widget_test.dart`](file:///test/widget_test.dart) (Test 5) | **VERIFIED** |
| **WP2.5: Accessibility & Text Scaling** | Layout responsiveness: zero `RenderFlex` overflows at standard 1.0x and high-contrast 2.0x text scaling across all primary screens. | All screen files under [`lib/features/`](file:///lib/features/) | [`test/golden_test.dart`](file:///test/golden_test.dart)<br>(1.0x & 2.0x text scale verification) | **VERIFIED** |
| **FR-01: Optical Camera Capture** | Camera preview, up to five captured pages, flash control, fixed framing guide, lighting advice, and sample/text input. Automatic edge detection and ambient-light sensing are not implemented. Physical camera operation still needs an Android/iOS device check. | [`lib/features/capture/capture_screen.dart`](file:///lib/features/capture/capture_screen.dart) | [`test/phase3_widget_test.dart`](file:///test/phase3_widget_test.dart)<br>[`test/m3_complete_pipeline_test.dart`](file:///test/m3_complete_pipeline_test.dart) | **IMPLEMENTED; DEVICE CHECK NEEDED** |
| **FR-02: Isolate Preprocessing** | Pure-Dart isolate pipeline: resize to 1600px, grayscale, global contrast boost, Gaussian smoothing, global thresholding, and coarse skew estimation. It does not yet implement the specified OpenCV CLAHE/bilateral/adaptive-threshold/deskew correction. | [`lib/services/image_preprocessor.dart`](file:///lib/services/image_preprocessor.dart) | [`test/phase3_ocr_test.dart`](file:///test/phase3_ocr_test.dart)<br>[`test/m3_complete_pipeline_test.dart`](file:///test/m3_complete_pipeline_test.dart) | **PARTIAL** |
| **FR-03: 1-Based OCR Line Transcription** | On-device Google ML Kit Latin recognition is wired for Android/iOS; confidence remains absent where the native API does not provide it. The iOS Runner still needs the Latin OCR resource bundle and linker setup. Desktop/web use typed notes or demos. Android runtime OCR has not been exercised on a device in this environment. | [`lib/services/ocr_service.dart`](file:///lib/services/ocr_service.dart)<br>[`lib/data/models/ocr_models.dart`](file:///lib/data/models/ocr_models.dart) | [`test/phase3_ocr_test.dart`](file:///test/phase3_ocr_test.dart)<br>[`test/m3_complete_pipeline_test.dart`](file:///test/m3_complete_pipeline_test.dart) | **ANDROID IMPLEMENTED; DEVICE CHECK NEEDED; IOS SETUP INCOMPLETE** |
| **FR-04: Interactive OCR Line Review** | Editable numbered line review screen allowing learners to edit typos inline, merge split lines, add missing lines, delete lines, and drag-and-drop reorder lines. | [`lib/features/ocr_review/ocr_review_screen.dart`](file:///lib/features/ocr_review/ocr_review_screen.dart) | [`test/phase3_widget_test.dart`](file:///test/phase3_widget_test.dart)<br>[`test/m3_complete_pipeline_test.dart`](file:///test/m3_complete_pipeline_test.dart) | **VERIFIED** |
| **Stage 4: ASP.NET Core Proxy Gateway** | Rate-limited (.NET 8) API gateway with token-bucket algorithm, client auth (`X-Api-Key`, `X-Install-Id`), `GET /health`, and `POST /api/v1/lessons/generate`. | [`server/NeuroScriptProxy/`](file:///server/NeuroScriptProxy/)<br>[`lib/services/proxy_service.dart`](file:///lib/services/proxy_service.dart) | [`test/phase3_proxy_test.dart`](file:///test/phase3_proxy_test.dart)<br>Live server test verified | **VERIFIED** |

---

## 3. Scope Boundaries & Next Milestones (M4 through M6)

| Roadmap Phase | Description | Status |
| :--- | :--- | :---: |
| **Milestone 4A** | Live Google Gemini 2.5 Flash Cloud Synthesis (using user-provided API Key) | Architecture & client ready; awaiting key insertion |
| **Milestone 4B** | On-Device Composite Grounding Engine (Lexical $L$, Entity $X$, all-MiniLM-L6-v2 Semantic $Sem$) | Scheduled for M4 |
| **Milestone 4C** | On-Device SLM Fallback (LlamaDart / SmolLM2 1B) & Offline `PendingJobs` Queue | Scheduled for M4 |
| **Milestone 5** | Text-to-Speech (TTS) Read-Aloud Engine & Literal Simplification for Autism | Scheduled for M5 |
| **Milestone 6** | User Acceptance Testing (ADHD, Dyslexia, Autism cohorts) & SUS Benchmark Evaluation | Scheduled for M6 |

---

## 4. How to Reproduce & Verify

All evaluation evidence is 100% reproducible locally using standard tools:

```bash
# 1. Verify static code analysis (0 issues, 0 warnings)
flutter analyze

# 2. Verify code formatting (0 unformatted files)
dart format --output=none --set-exit-if-changed lib test

# 3. Execute the full test suite (99 tests pass)
flutter test

# 4. Build the ASP.NET Core Proxy Gateway
dotnet build server/NeuroScriptProxy/NeuroScriptProxy.csproj

# 5. Build reproducible debug Android APK
flutter build apk --debug
```
