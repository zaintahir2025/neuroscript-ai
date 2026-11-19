# Manual Verification Register & Physical Testing Action Items

This document tracks all physical hardware tests, empirical benchmark logging, and clinical evaluation tasks that cannot be executed in automated CI environments and must be completed manually on physical hardware or with human participants.

---

## 1. Physical Device Hardware Verification Matrix

Automated tests and headless emulators execute cleanly in CI, but physical retail device verification remains pending until physical handsets are provisioned:

| Action Item | Target Platform | Test Description | Required Hardware | Status | Tracking Issue |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **HW-01** | Android | Verify camera autofocus, shutter release, and multi-page capture on physical device. | Google Pixel 7 (Android 14) | **NOT TESTED YET** | [docs/DEVICE_VERIFICATION_MATRIX.md](DEVICE_VERIFICATION_MATRIX.md) |
| **HW-02** | Android | Verify `EncryptedSharedPreferences` / KeyStore persistence across application cold reboots. | Samsung Galaxy S22 (Android 13) | **NOT TESTED YET** | [docs/DEVICE_VERIFICATION_MATRIX.md](DEVICE_VERIFICATION_MATRIX.md) |
| **HW-03** | iOS | Verify native camera capture, photo library permissions, and Keychain isolation on iOS. | iPhone 13 (iOS 16+) | **NOT TESTED YET** | [docs/DEVICE_VERIFICATION_MATRIX.md](DEVICE_VERIFICATION_MATRIX.md) |
| **HW-04** | Android / iOS | Measure physical device battery consumption and thermals during 10-minute continuous Leitner review. | Retail physical smartphone | **NOT TESTED YET** | [docs/DEVICE_VERIFICATION_MATRIX.md](DEVICE_VERIFICATION_MATRIX.md) |

---

## 2. Real-World OCR Handwriting Benchmarks

* **Objective:** Collect empirical Character Error Rate (CER) and Word Error Rate (WER) measurements across authentic student handwritten notes.
* **Requirements:**
  1. Gather a 50-sample handwritten lecture note corpus across engineering, medicine, and humanities disciplines.
  2. Photograph pages under standardized indoor lighting (300 lux, 45-degree angle).
  3. Execute on-device ML Kit OCR with isolate preprocessing.
  4. Compare transcripts against double-keyed ground-truth text.
  5. Store timestamped accuracy logs under `docs/evidence/ocr_benchmarks_raw.csv`.
* **Current Status:** **NOT MEASURED YET**.

---

## 3. Clinical & Educational Psychologist Evaluations

* **Objective:** Administer the formal psychologist review instrument to evaluate cognitive accessibility, sensory overload reduction, and study pacing.
* **Requirements:**
  1. Recruit 2 certified educational psychologists or disability accessibility officers.
  2. Provide evaluation instrument: [`docs/evaluation/NeuroScript_AI_Psychologist_Evaluation_Form.docx`](evaluation/NeuroScript_AI_Psychologist_Evaluation_Form.docx).
  3. Record Likert-scale feedback and qualitative recommendations.
  4. Log feedback and architectural responses in [docs/EXPERT_REVIEW.md](EXPERT_REVIEW.md).
* **Current Status:** **NOT TESTED YET (Scheduled for Milestone 6)**.

---

## 4. Student Usability Cohort Study

* **Objective:** Evaluate usability, task completion rate, and System Usability Scale (SUS) scores across student cohorts with ADHD, Dyslexia, and Autism.
* **Requirements:**
  1. Ethical consent clearance through institutional review board.
  2. Cohort of 12 university student participants (4 ADHD, 4 Dyslexia, 4 Autism).
  3. Structured 14-day study journal tracking flashcard retention and perceived cognitive fatigue.
  4. Post-trial System Usability Scale (SUS) survey administration.
* **Current Status:** **NOT TESTED YET (Scheduled for Milestone 6)**.
