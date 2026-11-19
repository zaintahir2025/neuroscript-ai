# AGENTS.md — Instructions & Honesty Rules for AI Agents

Guidelines and rules for AI assistants, agents, and contributors working in `neuroscript-ai`.

---

## 1. Honesty Rules (Zero Hallucination Policy)

1. **Never Invent Measurements or Results:** Never fabricate test scores, benchmark numbers, hardware validations, device logs, or dates.
2. **Explicit Uncertainty:** Any unmeasured or unverified capability MUST be marked as `"NOT MEASURED YET"` or `"NOT TESTED YET"`.
3. **No Superlatives:** Remove and avoid unsubstantiated marketing phrases (e.g., "production-hardened", "proven", "scientifically validated", "flawless"). State exact architectural facts and test outcomes instead.
4. **Evidence Requirement:** Benchmarks, CER/WER accuracy figures, and hardware matrices are only documented when backed by timestamped logs stored under `docs/evidence/`.

---

## 2. Technical Stack & Proposal Alignment

- **Target Platforms:** Mobile only — Android (API 24+) and iOS (iOS 14+). Do NOT re-introduce web, Windows, macOS, or Linux platform directories.
- **Frontend:** Flutter SDK (`>=3.47.5`), Dart SDK (`^3.13.4`).
- **State Management:** Riverpod (`3.5.0`).
- **Routing:** GoRouter (`18.1.4`).
- **Database:** Drift (`2.35.4`) on SQLite with `sqlite3mc` (SQLite3MultipleCiphers `3.9.1`) in SQLCipher-compatible mode (`PRAGMA cipher = 'sqlcipher'`). Master key in `FlutterSecureStorage` (`11.2.0`). Must fail closed on cipher inactive.
- **OCR:** Google ML Kit Text Recognition (`google_mlkit_text_recognition 1.0.3`) is the sole OCR engine. No Tesseract.js, web bridges, or vision Gemini OCR in client code.
- **Image Preprocessing:** Pure Dart (`image 4.13.1`) executed in a background isolate (grayscale, CLAHE/contrast, smoothing, deskew; binarization OFF by default).
- **Backend:** ASP.NET Core (.NET 10 LTS) in `server/NeuroScriptProxy/`. Gemini API is called strictly through the proxy; model name is configurable; API key is strictly read from environment variables (`GEMINI_API_KEY`).
- **Roadmap Items:** Record M4+ future items (e.g., `llamadart`, `all-MiniLM-L6-v2 on ONNX/TFLite`, `flutter_tts`) only in `docs/TECH_STACK.md`. Do not implement M4+ features prematurely.

---

## 3. Repository Structure

```
neuro_script/
├── android/                 # Android native project (API 24+)
├── assets/
│   ├── branding/            # App icons and logos
│   └── seed/                # Seed study units (JSON)
├── docs/
│   ├── adr/                 # Architecture Decision Records (ADR-001 through ADR-005)
│   ├── contracts/           # Lesson JSON schema & OpenAPI contracts
│   ├── diagrams/            # Architecture and database ER diagrams
│   ├── evaluation/          # Formal psychologist evaluation instruments (.docx)
│   ├── proposal/            # Project proposal and milestone documentation
│   ├── EVALUATION.md        # Traceability matrix and test results
│   ├── TECH_STACK.md        # Authoritative tech stack and version catalog
│   └── DEVICE_VERIFICATION_MATRIX.md # Platform setup and hardware status
├── ios/                     # iOS native project (iOS 15.5+ deployment target)
├── lib/
│   ├── app/                 # App root widget, theme dispatcher, global router
│   ├── core/                # Models, tokens, utilities, and base widgets
│   ├── data/                # Drift database, schema tables, and repositories
│   ├── features/            # Feature-first screens, controllers, and sub-widgets
│   └── services/            # OCR, isolate preprocessing, proxy, scheduler, seed
├── server/
│   ├── NeuroScriptProxy/    # ASP.NET Core .NET 10 LTS rate-limiting proxy
│   └── NeuroScriptProxy.Tests/ # xUnit proxy integration tests
└── test/                    # Unit, widget, and golden test suites mirroring lib/
```

---

## 4. Standard Developer Commands

Always run these commands before committing:

```bash
# Format code
dart format .

# Static code analysis
flutter analyze

# Flutter test suite (107 unit/widget tests)
flutter test

# Backend build and test
dotnet build server/NeuroScriptProxy/NeuroScriptProxy.sln
dotnet test server/NeuroScriptProxy/NeuroScriptProxy.sln

# Android debug APK build
flutter build apk --debug
```
