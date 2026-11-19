# Frequently Asked Questions (FAQ)

This document answers common architectural, privacy, clinical, and operational questions regarding NeuroScript AI.

---

## 1. Architecture & Design Decisions

### Why use a hybrid architecture instead of a pure cloud service?

A pure cloud architecture requires sending every handwritten image, transcript, and flashcard review log to remote servers, violating student privacy and failing when internet connectivity is absent in university lecture halls. NeuroScript AI performs optical scanning, OCR, encrypted persistence, and Leitner spaced repetition entirely on-device. The cloud proxy is contacted only on demand when compiling raw notes into structured study sets.

### Why is an ASP.NET Core proxy used instead of calling Gemini directly from Flutter?

Calling an external LLM API directly from a mobile client requires embedding secret API keys inside the client binary or reverse-engineering APK packages. The proxy:

1. **Isolates Secrets:** The `GEMINI_API_KEY` remains securely stored in the server's environment.
2. **Enforces Abuse Limits:** Applies token-bucket rate limiting per device installation ID.
3. **Guarantees Schema Compliance:** Sanitizes prompts and verifies JSON schema adherence before sending responses to the mobile app.

### Why did you migrate from sqlcipher_flutter_libs to sqlite3mc?

`sqlcipher_flutter_libs` is end-of-life and lacks ongoing upstream maintenance. `sqlite3mc` (SQLite3MultipleCiphers 3.9.1) is actively maintained, supports Dart Native Assets and build hooks, and provides complete SQLCipher-compatible 256-bit AES encryption (`PRAGMA cipher = 'sqlcipher'`). See [`docs/adr/ADR-004-sqlite3mc-encryption-migration.md`](adr/ADR-004-sqlite3mc-encryption-migration.md).

---

## 2. Privacy & Data Security

### What is stored on my mobile device?

All raw note transcripts, SHA-256 document hashes, lesson titles, concept map graphs, flashcards, and spaced repetition review metrics are stored in a local SQLite database encrypted with 256-bit AES via `sqlite3mc`. The database encryption key is kept in hardware-backed keystores (`FlutterSecureStorage`).

### What leaves my phone and goes to the server?

Only confirmed text lines from your notes (sent as a JSON array), the active profile type, and an anonymous device installation UUID are transmitted to the backend proxy over HTTPS when you tap "Generate Lesson". Raw camera photos, gallery images, and Leitner review intervals never leave your device.

### Does Google train foundational models on my lecture notes?

The proxy transmits note lines to the Google Gemini API. Under Google's Developer Terms, enterprise and paid-tier API calls are not used to train Google products. In the free/unpaid tier, prompts may be logged for quality improvement unless enterprise covenants apply. We strongly recommend deploying the proxy with paid enterprise credentials for institutional student deployments ([docs/PRIVACY_AND_SECURITY.md](PRIVACY_AND_SECURITY.md)).

---

## 3. Cognitive Accommodation & Accessibility

### Is NeuroScript AI a clinical diagnostic tool?

**No.** NeuroScript AI does not diagnose ADHD, Dyslexia, or Autism Spectrum conditions. The three profiles are visual, sensory, and pacing accommodations built upon published accessibility literature (e.g. W3C WCAG 2.1 AA and British Dyslexia Association guidelines). Learners are free to select whichever profile feels most comfortable.

### Why are ADHD study sessions capped at 5 cards?

Learners with ADHD frequently experience executive dysfunction and dopamine fatigue when facing large, open-ended study decks. By hard-capping sessions at 5 cards, the learner achieves immediate task completion, receives positive visual reinforcement, and avoids task paralysis.

### How does the Dyslexia profile help with reading?

The Dyslexia profile replaces stark white backgrounds (`#FFFFFF`) with a warm, anti-glare cream tone (`#FBF8EE`), which mitigates scotopic visual sensitivity (Meares-Irlen syndrome). Furthermore, it increases letter tracking (+0.6) and relaxes line height (1.6) using dark charcoal text (`#2B2D42`) to prevent visual crowding.

---

## 4. Operational Guarantees & Limitations

### Can I use the app completely offline?

**Yes for existing sets; partially for new sets:**

* **Offline Capabilities:** You can open your library, study existing flashcards, flip cards, advance through Leitner boxes, explore concept maps, and adjust settings with zero internet connectivity.
* **Online Requirement (Today):** Generating a new study set from raw note lines currently requires reaching the backend proxy. Milestone 4C will introduce an on-device SLM fallback for fully offline lesson compilation.

### What happens if I uninstall the app?

Because the 256-bit encryption key is stored in the operating system's secure keystore (KeyStore / Keychain), uninstalling the application purges the key. If you reinstall the app, a new encrypted database will be created. Previously unbacked-up encrypted databases cannot be recovered.

### How accurate is the OCR on messy handwriting?

Google ML Kit provides deep convolutional feature extraction on Latin script. However, optical accuracy varies with penmanship clarity, ink contrast, and camera lighting. NeuroScript AI provides an **Interactive Line Review Screen** specifically so you can review, edit typos, merge lines, and confirm text before flashcards are generated.
