# NeuroScript AI Documentation Index

This directory contains the complete technical specifications, architectural diagrams, privacy models, accessibility rationale, and operational guides for NeuroScript AI.

---

## Audience Guide

Documentation is organized to serve three primary stakeholder groups:

* **`[Examiners]`**: Academic evaluators, university supervisors, and technical reviewers assessing milestone completion, design decisions, and system verification.
* **`[Psychologist/Non-Tech]`**: Educational psychologists, accessibility auditors, clinicians, and learners evaluating cognitive accommodation, user experience, and safety.
* **`[Developers]`**: Software engineers and contributors installing, building, testing, and extending the codebase.

---

## Document Index

| Document | Target Audience | Summary |
| :--- | :--- | :--- |
| **[ARCHITECTURE.md](ARCHITECTURE.md)** | `[Examiners]` `[Developers]` | System context, component hierarchy, Riverpod state flow, sequence diagrams, and directory map. |
| **[DATA_MODEL.md](DATA_MODEL.md)** | `[Examiners]` `[Developers]` | Mermaid Entity-Relationship diagram, Drift tables, columns, foreign keys, cascade rules, and schema rationale. |
| **[API.md](API.md)** | `[Examiners]` `[Developers]` | ASP.NET Core proxy REST endpoints, JSON Schema contract compliance, status codes, and rate limiting. |
| **[PRIVACY_AND_SECURITY.md](PRIVACY_AND_SECURITY.md)** | `[Examiners]` `[Psychologist/Non-Tech]` `[Developers]` | On-device encryption (sqlite3mc AES-256), secure storage key lifecycle, zero-note server policy, and third-party terms. |
| **[ACCESSIBILITY_DESIGN.md](ACCESSIBILITY_DESIGN.md)** | `[Examiners]` `[Psychologist/Non-Tech]` | Design choices for ADHD, Dyslexia, and Autism profiles, WCAG 2.1 AA evidence, and clinical review status. |
| **[USER_GUIDE.md](USER_GUIDE.md)** | `[Psychologist/Non-Tech]` | Plain-language step-by-step walkthrough with real screenshots for university students. |
| **[DEVELOPMENT.md](DEVELOPMENT.md)** | `[Developers]` | Development environment setup, standard commands, code style rules, and contribution workflow. |
| **[TESTING.md](TESTING.md)** | `[Examiners]` `[Developers]` | Catalog of 110 Flutter tests and 9 backend tests, reproduction commands, and coverage scope. |
| **[ROADMAP.md](ROADMAP.md)** | `[Examiners]` `[Developers]` | Detailed milestone breakdown (M1–M6), demonstration criteria, verified status, and future deliverables. |
| **[EVALUATION.md](EVALUATION.md)** | `[Examiners]` | Requirement-by-requirement traceability matrix mapping claims to automated tests and verified evidence. |
| **[EXPERT_REVIEW.md](EXPERT_REVIEW.md)** | `[Examiners]` `[Psychologist/Non-Tech]` | Educational psychologist evaluation protocol, instrument links, and post-review modification log. |
| **[TECH_STACK.md](TECH_STACK.md)** | `[Examiners]` `[Developers]` | Authoritative catalog of all proposal dependencies, chosen pinned versions, and planned packages. |
| **[GLOSSARY.md](GLOSSARY.md)** | `[Examiners]` `[Psychologist/Non-Tech]` `[Developers]` | Domain definitions for OCR, CER/WER, Leitner systems, grounding scores, SLMs, and SQLCipher. |
| **[FAQ.md](FAQ.md)** | `[Examiners]` `[Psychologist/Non-Tech]` `[Developers]` | Frequently asked questions regarding architectural trade-offs, privacy, and system boundaries. |
| **[MANUAL_TODO.md](MANUAL_TODO.md)** | `[Examiners]` `[Developers]` | Tracking register of physical hardware benchmarks and clinical trials awaiting execution. |
| **[DEVICE_VERIFICATION_MATRIX.md](DEVICE_VERIFICATION_MATRIX.md)** | `[Examiners]` `[Developers]` | Hardware verification matrix documenting real device testing status and platform support. |
| **[requirements.md](requirements.md)** | `[Examiners]` | Formal System Requirements Specification (SRS) detailing FR-01 through FR-15 and NFR-01 through NFR-08. |
| **[personas.md](personas.md)** | `[Psychologist/Non-Tech]` `[Examiners]` | Evidence-based learner personas for ADHD (Bilal), Dyslexia (Sara), and Autism (Hamza). |
| **[contracts/lesson.schema.json](contracts/lesson.schema.json)** | `[Developers]` `[Examiners]` | Universal JSON Schema draft-07 contract defining valid lesson synthesis output structure. |
| **[contracts/proxy-api.openapi.yaml](contracts/proxy-api.openapi.yaml)** | `[Developers]` `[Examiners]` | OpenAPI 3.0 specification for the backend rate-limiting proxy gateway. |
