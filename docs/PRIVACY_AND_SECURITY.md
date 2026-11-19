# Privacy Architecture & Security Guarantees

This document details the data boundaries, local encryption, cloud telemetry policies, and third-party interactions governing the NeuroScript AI platform.

---

## 1. Threat Model & Design Principles

University students studying lecture notes frequently transcribe course materials that may contain personal academic reflections or proprietary institutional intellectual property. NeuroScript AI enforces a strict **Zero-Trust, Local-First** data isolation model:

1. **Local-First Sovereign Storage:** The mobile device is the primary source of truth. All notes, transcripts, lessons, concept maps, and spaced repetition review logs are encrypted at rest.
2. **Stateless Ephemeral Cloud Processing:** The backend proxy acts solely as an authorized gateway. It processes note text in memory during structured compilation and immediately discards the content once the response is emitted.
3. **No Ambient Surveillance:** No background telemetry, crash reporters, or third-party advertising SDKs are included in the mobile client or server.

---

## 2. On-Device Storage Architecture

### 2.1 Database Encryption (`sqlite3mc`)

* **Cryptographic Engine:** SQLite3MultipleCiphers (`3.9.1`) operating in SQLCipher-compatible mode.
* **Cipher Suite:** AES-256 in CBC mode with PBKDF2 HMAC-SHA512 key derivation.
* **Initialization Pragmas:**

  ```sql
  PRAGMA cipher = 'sqlcipher';
  PRAGMA key = '<256-bit-base64-key>';
  ```

* **Fail-Closed Guarantee:**
  * When opening the database (`lib/data/database/connection/connection_native.dart`), the connection initializes the cipher and verifies the key by querying `sqlite_master`.
  * If the cipher is inactive or the key is invalid, the operation throws a fatal `DatabaseEncryptionException`, aborting initialization and preventing plaintext file generation.

### 2.2 Key Management Lifecycle (`FlutterSecureStorage`)

* **Key Generation:** A cryptographically secure 256-bit random key is generated using `Random.secure()` on first application launch.
* **Storage Location:**
  * **Android:** AES-encrypted storage using the Android KeyStore provider (`EncryptedSharedPreferences`).
  * **iOS:** Hardware-backed Keychain Services with accessibility flag `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`.
* **Key Isolation:** The master key is never written to regular shared preferences, logs, or unencrypted local files.

### 2.3 Automated Cryptographic Evidence

The encryption implementation is verified by automated integration tests in `test/encryption_verification_test.dart`:

| Test Name | Verification Method | Result |
| :--- | :--- | :--- |
| **Header Inspection** | Inspects the first 16 bytes of the on-disk `.db` file; asserts bytes do **NOT** match the standard plaintext SQLite magic header `SQLite format 3\0`. | **Verified Passing** |
| **Wrong Key Rejection** | Attempts to reopen an encrypted database file with an altered key; asserts that the operation throws and fails closed. | **Verified Passing** |
| **Secure Key Generation** | Asserts that `KeyStorageService` creates and retrieves a valid 256-bit base64-encoded key across app launches. | **Verified Passing** |

---

## 3. Data Transmission & Cloud Boundary

### 3.1 What Leaves the Device and When

Data leaves the user's mobile device **only** when the user explicitly triggers AI lesson generation by tapping "Generate Lesson" on the OCR Review screen.

| Data Item | Transmitted? | Destination | Protocol | Purpose |
| :--- | :--- | :--- | :--- | :--- |
| **Raw Camera Images** | **No** | None (Local only) | N/A | Processed and discarded on-device. |
| **Confirmed Note Text Lines** | **Yes** (on demand) | Backend Proxy | HTTPS TLS 1.3 | Sent as JSON array for lesson compilation. |
| **SHA-256 Note Hash** | **Yes** (on demand) | Backend Proxy | HTTPS TLS 1.3 | Included in request body for idempotent validation. |
| **Active Profile Type** | **Yes** (on demand) | Backend Proxy | HTTPS TLS 1.3 | Tailors lesson chunking (`ADHD`, `Dyslexia`, `Autism`). |
| **Installation UUID** | **Yes** (on demand) | Backend Proxy | HTTPS TLS 1.3 | Sent via `X-Install-Id` for rate limiting. |
| **Flashcard Review History** | **No** | None (Local only) | N/A | SRS intervals remain private on-device. |

---

## 4. Backend Proxy Server Data Policy

The ASP.NET Core proxy gateway (`server/NeuroScriptProxy/`) adheres to strict data minimization:

1. **Stateless Operations:**
   * The proxy maintains no database of user notes, study units, or student text.
   * Note contents exist strictly in volatile RAM for the duration of the HTTP request.
2. **Anonymous Metadata Audit Logging:**
   * To monitor rate limits and service health, the proxy writes structured audit logs to an internal SQLite store:

     ```text
     Timestamp: 2026-11-19T09:30:00Z
     ClientId: 1a2b...9z8y (Masked Install ID)
     Profile: Dyslexia
     LineCount: 15
     CharCount: 1240
     Status: 200
     Latency: 1420ms
     ```

   * Notice: Student note lines, card questions, answers, and concepts are **never logged**.

---

## 5. Third-Party Interactions (Google Gemini API)

The backend proxy communicates with the Google Gemini API to compile structured lessons.

### Google Gemini API Terms of Service & Privacy Terms

* Under the [Google Generative AI Developer Terms of Service](https://ai.google.dev/terms):
  * **Paid Tier (Vertex AI / Pay-as-you-go):** Google states: *"Google does not use your customer data (prompts, completions, or embeddings) to train Google products or foundational models without your explicit permission."*
  * **Free / Unpaid Tier:** Google's terms indicate that prompt and response data may be reviewed by human reviewers and used to train Google products unless configured otherwise or when using commercial enterprise agreements.
* **NeuroScript AI Recommendation:** In production deployments handling confidential student records, universities should configure paid enterprise project API credentials to guarantee non-training covenants.

---

## 6. Known Security Limitations & Gaps

1. **Keystore Loss on Application Uninstall:**
   * If a student uninstalls the mobile app, Android KeyStore and iOS Keychain entries for the application are purged by the operating system. Because the database master key is lost, previously stored local encrypted databases cannot be decrypted upon reinstallation.
2. **Proxy Rate Limiting Scope:**
   * The proxy's sliding-window token bucket currently operates in-memory (and in local SQLite). In horizontally scaled multi-instance proxy deployments, a shared Redis cache would be required for global rate enforcement.
3. **Model Memorization Risk:**
   * While the proxy prompt instructs Gemini in a closed-book manner to synthesize exclusively from provided lines, foundational cloud LLMs operate beyond the local trust boundary. Local SLM execution (M4C) will eliminate this third-party dependency.
