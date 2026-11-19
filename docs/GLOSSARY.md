# Technical & Cognitive Domain Glossary

This document defines core technical terms, mathematical metrics, cognitive concepts, and domain acronyms utilized throughout NeuroScript AI.

---

## 1. Computer Vision & Machine Learning

### Optical Character Recognition (OCR)

The computational process of converting 2D pixel rasters of handwritten or printed text into machine-encoded character strings. In NeuroScript AI, OCR is executed entirely on-device using Google ML Kit Text Recognition (`google_mlkit_text_recognition 1.0.3`).

### Character Error Rate (CER)

A standardized distance metric quantifying transcription accuracy at the character level. Computed using the Levenshtein edit distance between ground truth $T$ and hypothesis $H$:

$$\text{CER} = \frac{S + D + I}{N}$$

Where $S$ is character substitutions, $D$ is deletions, $I$ is insertions, and $N$ is total characters in the reference string.

### Word Error Rate (WER)

A standardized distance metric quantifying transcription accuracy at the token or word level. Computed using Levenshtein distance on whitespace-delimited word sequences:

$$\text{WER} = \frac{S_w + D_w + I_w}{N_w}$$

### Small Language Model (SLM)

A parameter-efficient language model (typically 1B to 3B parameters, such as SmolLM2 or Llama 3.2 1B) quantized to 4-bit integer weights (GGUF format) designed to execute locally on consumer mobile hardware without internet access.

### Grounding Verification Score ($G$)

A deterministic mathematical verification metric $G \in [0.0, 1.0]$ assessing whether generated flashcard questions and answers are factually anchored in cited note lines without unfaithful LLM hallucinations:

$$G = \frac{|\text{Tokens}(\text{Answer}) \cap \text{Tokens}(\text{SourceLines})|}{|\text{Tokens}(\text{Answer})|}$$

---

## 2. Learning Science & Cognitive Terms

### Spaced Repetition System (SRS)

An evidence-based learning technique based on the Ebbinghaus forgetting curve. Information is reviewed at systematically increasing intervals to achieve optimal memory consolidation into long-term retention.

### Leitner 5-Box Method

A discrete spaced repetition algorithm where cards progress through 5 boxes:

* **Box 1:** Reviewed daily (1-day interval).
* **Box 2:** Reviewed every 3 days.
* **Box 3:** Reviewed weekly (7-day interval).
* **Box 4:** Reviewed bi-weekly (14-day interval).
* **Box 5:** Mastered; reviewed monthly (30-day interval).
* *Rule:* A correct answer promotes the card to the next box; an incorrect answer demotes the card back to Box 1.

### Active Recall

A learning strategy where the student actively stimulates memory retrieval (prompted by a question) before verifying the answer, creating stronger neural synaptic connections than passive reading.

### Executive Dysfunction

Impairment in cognitive processes governing planning, working memory, attention, and task initiation, frequently experienced by learners with ADHD.

### Scotopic Sensitivity (Meares-Irlen Syndrome)

A perceptual processing disorder where visual stress, glare, and letter vibration are triggered by high-contrast black text on bright white paper or displays.

---

## 3. Cryptography & Systems Architecture

### SQLCipher

An extension for SQLite that provides transparent, 256-bit AES encryption of database files, page by page, with HMAC-SHA1 or HMAC-SHA512 integrity checks.

### SQLite3MultipleCiphers (`sqlite3mc`)

An open-source, actively maintained C extension supporting multiple encryption algorithms for SQLite, including SQLCipher-compatible mode (`PRAGMA cipher = 'sqlcipher'`).

### Hardware Keystore

Operating-system-level secure enclaves (Android KeyStore and iOS Keychain) providing hardware-backed cryptographic key generation, isolation, and access control.
