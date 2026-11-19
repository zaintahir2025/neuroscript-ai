# System Architecture & Component Design

This document describes the architectural topology, data boundaries, state management lifecycles, and component interactions of NeuroScript AI.

---

## 1. System Context Diagram

NeuroScript AI employs an offline-first, hybrid cloud architecture. The Flutter client manages all user interactions, local encryption, optical character recognition, and spaced repetition scheduling on the student's mobile device. The cloud proxy acts as an ephemeral, rate-limiting boundary to upstream language models.

```mermaid
flowchart TB
    subgraph Device["Mobile Device (Android API 24+ / iOS 14+)"]
        ClientApp["NeuroScript AI Flutter App\n(Dart 3.13 / Flutter 3.47+)"]
        KeyStore["Hardware Keystore\n(KeyStore / Keychain)"]
        EncryptedDB[("Local Encrypted Database\n(Drift + sqlite3mc AES-256)")]
        MLKit["Google ML Kit\n(On-Device OCR)"]

        ClientApp <--> KeyStore
        ClientApp <--> EncryptedDB
        ClientApp --> MLKit
    end

    subgraph Cloud["Backend Gateway (Self-Hosted / Cloud)"]
        Proxy["ASP.NET Core Proxy Gateway\n(.NET 10 LTS)\nserver/NeuroScriptProxy"]
        AuditDB[("Stateless Audit Log\n(SQLite Metadata Only)")]

        Proxy --> AuditDB
    end

    subgraph External["Upstream AI Provider"]
        Gemini["Google Gemini API\n(Configurable Model)"]
    end

    ClientApp == "HTTPS + X-Api-Key\n(Only Confirmed Line Transcripts)" ==> Proxy
    Proxy == "HTTPS TLS 1.3\n(Server GEMINI_API_KEY)" ==> Gemini
```

---

## 2. Component Architecture

The mobile application follows a layered architectural pattern (Presentation, Controller, Domain/Repository, Data/Persistence, and Infrastructure Services):

```mermaid
classDiagram
    direction TB
    class PresentationLayer {
        <<UI Widgets>>
        LibraryScreen
        CaptureScreen
        OcrReviewScreen
        LessonOverviewScreen
        FlashcardReviewScreen
        ConceptMapScreen
        SettingsScreen
    }

    class ControllerLayer {
        <<Riverpod StateNotifiers>>
        ActiveProfileNotifier
        StudySessionNotifier
        CaptureController
        OcrReviewController
    }

    class RepositoryLayer {
        <<Domain Contracts>>
        UserProfileRepository
        StudySetRepository
        ReviewProgressRepository
        DocumentDeduplicationService
    }

    class DataLayer {
        <<Persistence>>
        AppDatabase (Drift)
        UserProfilesTable
        SourceNotesTable
        LessonsTable
        FlashcardsTable
        ReviewProgressTable
    }

    class InfrastructureServices {
        <<Platform & Hardware>>
        ImagePreprocessor (Dart Isolate)
        OcrService (ML Kit)
        ProxyService (HTTP Client)
        LeitnerScheduler (Deterministic SRS)
        KeyStorageService (SecureStorage)
    }

    PresentationLayer --> ControllerLayer : observes & dispatches
    ControllerLayer --> RepositoryLayer : invokes use-cases
    RepositoryLayer --> DataLayer : queries & persists
    RepositoryLayer --> InfrastructureServices : delegates platform tasks
    DataLayer --> InfrastructureServices : retrieves encryption key
```

---

## 3. Sequence Diagrams

### 3.1 Standard Note Capture to Study Unit Generation

```mermaid
sequenceDiagram
    autonumber
    actor Student
    participant UI as Capture & Review UI
    participant Isolate as Image Preprocessor (Isolate)
    participant MLKit as ML Kit OCR Engine
    participant Proxy as ASP.NET Core Proxy
    participant Gemini as Google Gemini API
    participant DB as Encrypted Database (sqlite3mc)

    Student->>UI: Capture document / select gallery photos
    UI->>Isolate: Dispatch raw image bytes
    Note over Isolate: Grayscale, CLAHE contrast, smoothing, deskew
    Isolate-->>UI: Preprocessed image
    UI->>MLKit: Transcribe preprocessed image
    MLKit-->>UI: Raw text blocks & coordinates
    Note over UI: Group lines & assign 1-based indices (L1, L2, ...)
    UI->>Student: Display OCR Review Screen
    Student->>UI: Edit text, merge split lines, confirm
    UI->>Proxy: POST /api/v1/lessons/generate (Lines, Title, Profile)
    Note over Proxy: Validate token bucket & API key
    Proxy->>Gemini: Closed-book structured prompt
    Gemini-->>Proxy: Validated JSON Lesson Contract
    Proxy-->>UI: HTTP 200 (Lesson JSON)
    UI->>DB: Atomic Transaction: Insert Note, Lesson, Flashcards, Initial SRS
    DB-->>UI: Transaction Committed
    UI->>Student: Navigate to Lesson Overview / Flashcard Review
```

### 3.2 Error & Offline Failure Path (Current Implementation)

```mermaid
sequenceDiagram
    autonumber
    actor Student
    participant UI as Study / Review UI
    participant Proxy as ASP.NET Core Proxy
    participant DB as Encrypted Database

    Student->>UI: Request Lesson Generation
    alt No Internet Connection
        UI->>UI: Catch SocketException / Timeout
        UI->>Student: Display "Offline Mode: Cannot reach AI service. Saved as raw note."
        UI->>DB: Save raw note transcript locally
    else Rate Limit Exceeded (HTTP 429)
        Proxy-->>UI: HTTP 429 Too Many Requests (Retry-After: 60)
        UI->>Student: Display "Rate limit exceeded. Please wait 60s before generating another lesson."
    else Invalid Request Payload (HTTP 400)
        Proxy-->>UI: HTTP 400 Bad Request (Validation ProblemDetails)
        UI->>Student: Display validation error (e.g., "Note exceeds 200 lines limit")
    else Upstream Gemini Error (HTTP 502 / 503)
        Proxy-->>UI: HTTP 502 Bad Gateway (Service Unavailable)
        UI->>Student: Display "AI service temporarily unavailable. Saved locally."
    end
```

---

## 4. State Management Flow (Riverpod)

NeuroScript AI uses Riverpod (`3.5.0`) for compile-safe, testable state management without global singletons.

1. **Unidirectional Data Flow:**
   * **State Providers / Notifiers:** Hold immutable state objects (e.g., `AsyncValue<List<LessonWithCards>>`).
   * **UI Consumers:** Use `ref.watch(provider)` to rebuild strictly when observed state changes.
   * **Intent Dispatch:** UI widgets invoke controller methods (e.g., `ref.read(studySessionControllerProvider.notifier).recordAnswer(cardId, isCorrect)`).

2. **Provider Invalidation Lifecycle:**
   * Repositories emit reactive streams via Drift ORM query watchers (`watch()`).
   * When a database transaction writes to `flashcards` or `review_progress`, Drift automatically notifies the stream subscriber.
   * Riverpod stream providers automatically re-evaluate and propagate updated collections to UI widgets without manual event buses.

3. **Scoped Accessibility Paging:**
   * ADHD micro-session counters are maintained within ephemeral `AutoDisposeNotifier` scopes.
   * Navigating away from a session resets ephemeral counters while committing progress to the persistent encrypted database.

---

## 5. Repository Directory Structure

```text
neuroscript-ai/
├── android/                         # Android native project (minSdkVersion 24)
├── assets/
│   ├── branding/                    # High-resolution logos and icons
│   └── seed/                        # Seed study units (JSON contracts)
├── docs/
│   ├── adr/                         # Architecture Decision Records (ADR-001 through ADR-005)
│   ├── contracts/                   # JSON Schema & OpenAPI specifications
│   ├── diagrams/                    # System topology and ER diagrams
│   ├── evaluation/                  # Formal psychologist evaluation instruments (.docx)
│   ├── images/                      # Real screenshots captured from emulator
│   ├── proposal/                    # Academic FYP proposal documentation
│   ├── ACCESSIBILITY_DESIGN.md      # WCAG 2.1 AA profiles & cognitive design
│   ├── API.md                       # ASP.NET Core proxy REST API specification
│   ├── ARCHITECTURE.md              # System context, sequence diagrams, and layout
│   ├── DATA_MODEL.md                # Drift relational database schema & ER model
│   ├── DEVELOPMENT.md               # Developer environment setup & workflows
│   ├── DEVICE_VERIFICATION_MATRIX.md # Physical hardware verification tracker
│   ├── EVALUATION.md                # Traceability matrix mapping claims to tests
│   ├── EXPERT_REVIEW.md             # Clinical evaluation protocol and change log
│   ├── FAQ.md                       # Frequently asked architectural questions
│   ├── GLOSSARY.md                  # Domain terminology & acronym definitions
│   ├── MANUAL_TODO.md               # Tracking register of unexecuted manual tasks
│   ├── PRIVACY_AND_SECURITY.md      # Encryption, keystore, and data privacy policies
│   ├── ROADMAP.md                   # Milestone execution plan (M1 through M6)
│   ├── TECH_STACK.md                # Pinned dependencies & planned roadmap catalog
│   ├── TESTING.md                   # Test suite documentation & reproduction steps
│   └── USER_GUIDE.md                # Student walkthrough with real screenshots
├── ios/                             # iOS native project (deployment target 15.5+)
├── lib/
│   ├── main.dart                    # Application entrypoint
│   ├── app/                         # App widget, global router, and theme dispatcher
│   ├── core/                        # Accessibility tokens, base widgets, and errors
│   ├── data/                        # Drift database, schema tables, and repositories
│   ├── features/                    # Feature modules (capture, ocr, library, study, settings)
│   └── services/                    # Background isolate preprocessing, ML Kit, proxy, scheduler
├── server/
│   ├── NeuroScriptProxy/            # ASP.NET Core .NET 10 LTS proxy service
│   │   ├── Controllers/             # REST API controllers
│   │   ├── Services/                # Gemini client, rate limiter, audit store
│   │   ├── Dockerfile               # Production container definition
│   │   └── Program.cs               # Service startup, CORS, and middleware configuration
│   └── NeuroScriptProxy.Tests/      # xUnit integration & rate limiter test suites
└── test/                            # Automated Flutter test suites mirroring lib/
```
