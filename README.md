# NeuroScript AI: Privacy-Preserving Study Platform for Neurodivergent Learners

[![CI](https://github.com/zaintahir2025/neuroscript-ai/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/zaintahir2025/neuroscript-ai/actions/workflows/ci.yml)
[![GitHub Pages](https://img.shields.io/badge/Live%20Web%20App-GitHub%20Pages-blueviolet.svg)](https://zaintahir2025.github.io/neuroscript-ai/)
[![Flutter Version](https://img.shields.io/badge/Flutter-3.24%2B-blue.svg)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Release](https://img.shields.io/badge/Release-v0.3.0--m3-brightgreen.svg)](docs/EVALUATION.md)
[![Tests](https://img.shields.io/badge/Tests-107%20Passing-success.svg)](test/)

A specialized, accessible study application engineered for students with Attention Deficit Hyperactivity Disorder (ADHD), Dyslexia, and Autism Spectrum Conditions. Built with Flutter and an encrypted local SQLite database (Drift + SQLite3MultipleCiphers), NeuroScript AI delivers an offline-first learning system featuring optical camera & gallery document capture, on-device ML Kit OCR with 1-based line numbering, Leitner spaced repetition flashcards, 2D interactive concept maps, and neurodivergent-friendly UI/UX themes adhering strictly to WCAG 2.1 AA accessibility standards.

---

## Project Metadata

* **Institution:** Department of Computer Science, University of Engineering & Technology (UET) Taxila
* **Course:** CS-400 Final Year Project (Academic Year 2026–2027)
* **Supervisor:** Mr. Awais Mehmood
* **Engineering Team:**
  * **Zain Tahir** (Roll No. 23-CS-115) – Systems Architecture, Database Engineering, Frontend & Backend Implementation
  * **Ujala Sahar** (Roll No. 23-CS-135) – UI/UX Design System, Accessibility Auditing, User Acceptance Testing, Documentation
* **Delivery Scope:** Milestones 1, 2, and 3 are 100% complete, verified with 105 automated tests and production-hardened release builds.
* **Live Web Demonstration:** [https://zaintahir2025.github.io/neuroscript-ai/](https://zaintahir2025.github.io/neuroscript-ai/)

---

## Documentation Index

Comprehensive architecture, database, evaluation, and milestone documentation:

* **[Evaluation Matrix & Traceability](docs/EVALUATION.md)**: Requirement-by-requirement mapping to tests and evidence files.
* **[OCR Evaluation & Accuracy Report](docs/OCR_EVALUATION_REPORT.md)**: CER/WER benchmarks, continuous grayscale vs binarization analysis, and isolate performance.
* **[Physical Device Verification Matrix](docs/DEVICE_VERIFICATION_MATRIX.md)**: Physical Android & iOS hardware verification, permissions, and ML Kit setup.
* **Architectural Decision Records (ADRs)**:
  * [`ADR-001: Adoption of Drift ORM`](docs/adr/ADR-001-drift-orm.md)
  * [`ADR-002: Adoption of Riverpod State Management`](docs/adr/ADR-002-riverpod-state-management.md)
  * [`ADR-003: Pure-Dart 5-Box Leitner Spaced Repetition Engine`](docs/adr/ADR-003-leitner-srs-engine.md)
  * [`ADR-004: Migration to SQLite3MultipleCiphers (sqlite3mc)`](docs/adr/ADR-004-sqlite3mc-encryption-migration.md)
* **Master Milestone Execution Plan:** [`docs/NeuroScript_AI_Milestone_Execution_Plan.pdf`](docs/NeuroScript_AI_Milestone_Execution_Plan.pdf)
* **Database Relational Schema & ER Diagram:** [`docs/diagrams/database_er.md`](docs/diagrams/database_er.md)
* **System Architecture & Component Diagrams:** [`docs/diagrams/architecture.md`](docs/diagrams/architecture.md)
* **Data Contracts (Lesson Schema & OpenAPI):** [`docs/contracts/`](docs/contracts/)

---

## System Capabilities (Milestones 1, 2 & 3)

### 1. Optical Document Capture & Gallery Ingestion (FR-01)
- **Camera Viewfinder:** Live framing guide, multi-page capture counter (up to 5 pages), and flash control.
- **Gallery Import:** One-tap selection from the device photo library with multi-image support (up to 5 pages).
- **Multiple Entry Points:** Directly accessible from the Library screen via Floating Action Button, AppBar scanner icon, and empty-state action button.

### 2. Pure-Dart Background Isolate Preprocessing (FR-02)
- Resizes captured images to a maximum 1600px bounding box preserving aspect ratio.
- Preserves continuous 8-bit luminance gradients for Google ML Kit deep CNN feature extractors.
- Applies $1.35\times$ dynamic contrast boost and Gaussian spatial smoothing to suppress paper noise.
- Performs geometric rotation deskew between $0.75^\circ$ and $15.0^\circ$ using horizontal projection variance.

### 3. On-Device OCR & 1-Based Line Transcription (FR-03)
- Transcribes handwritten and printed lecture notes using Google ML Kit on-device vision models.
- Assigns deterministic 1-based line numbers (`L1`, `L2`, ...) to facilitate precise citation provenance in generated flashcards.

### 4. Interactive OCR Review & Line Editor (FR-04)
- Full-screen line review permitting learners to edit typos inline, merge split lines, insert missing lines, delete lines, or reorder lines.
- **Deduplication:** Automatically hashes note contents and prompts learners if a study set already exists, preventing duplicate lesson entries and navigating directly to the created study set.

### 5. Production-Hardened ASP.NET Core Proxy Gateway (Stage 4)
- **Authentication:** Enforces constant-time `X-Api-Key` cryptographic verification.
- **Per-Device Rate Limiting:** Unique device installation UUID (`InstallIdService`) stored in hardware secure storage; sliding-window rate limit (20 req/min) returning RFC-compliant `Retry-After` headers.
- **Payload Constraints:** Enforces 256 KB max request body size, 200 line maximum, and 25,000 character maximum.
- **Privacy Audit Logging:** Emits structured metadata logs (timestamp, masked install ID, line count, status, latency); never persists or logs raw student notes.
- **Containerization:** Ready for deployment with `server/NeuroScriptProxy/Dockerfile` and `server/docker-compose.yml`.

---

## Neurodivergent Accessibility Profiles

NeuroScript AI provides three dedicated, WCAG 2.1 AA compliant design systems:

| Dimension | ADHD Profile | Dyslexia Profile | Autism Profile |
| :--- | :--- | :--- | :--- |
| **Cognitive Goal** | Dopamine feedback, minimal clutter | Scotopic sensitivity, anti-glare | Low sensory arousal, predictability |
| **Primary Color** | Deep Indigo (`#3F51B5`) | Slate Blue (`#1E3A8A`) | Muted Sage Teal (`#3D6B7A`) |
| **Accent Color** | Warm Amber (`#FF9800`) | Warm Amber (`#FF9800`) | Ice Mist Soft Slate (`#607D8B`) |
| **Canvas Background** | Clean Minimal Grey (`#F8F9FA`) | Anti-Glare Warm Cream (`#FBF8EE`) | Uniform Ice Mist (`#EEF3F4`) |
| **Body Text** | Dark Charcoal (`#1F2937`) | Soft Charcoal (`#2B2D42`) | Deep Slate (`#1A2E35`) |
| **Typography** | Crisp Sans-Serif | Relaxed line-height (1.6), tracking +0.6 | Predictable structure, tracking +0.2 |
| **Study Sizing** | **5 cards per session** (strict cap) | 10 cards per session | 10 cards per session |
| **Touch Targets** | $\ge 48 \times 48\text{ dp}$ | $\ge 48 \times 48\text{ dp}$ | $\ge 48 \times 48\text{ dp}$ |

*All color combinations have been mathematically validated in `test/theme_wcag_test.dart` to exceed the WCAG 2.1 AA minimum contrast threshold of 4.5:1.*

---

## How to Verify & Reproduce

### 1. Static Analysis
Verify that zero warnings, errors, or lints exist:
```bash
flutter analyze
```

### 2. Automated Test Suite (105 Tests Passing)
Run all unit, widget, integration, and OCR benchmark tests:
```bash
flutter test
```

### 3. Backend Proxy Verification
Build and execute the backend ASP.NET Core solution and test suite:
```bash
dotnet build server/NeuroScriptProxy/NeuroScriptProxy.sln
```

### 4. Install Up-to-Date Release APK
The repository provides a single, unified, release APK located at:
```bash
release_apk/neuro_script.apk
```
Install directly onto any physical Android device:
```bash
adb install -r release_apk/neuro_script.apk
```
