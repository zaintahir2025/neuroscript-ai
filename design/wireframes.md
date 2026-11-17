# Screen Wireframes and Interaction Architecture

This document records the screen hierarchy and interaction flows used by NeuroScript AI across mobile, tablet, desktop, and web layouts.

---

## 1. Master Screen Inventory

The application currently includes 12 core views and supporting modal sheets:

1. **Splash & Startup (`/splash`)**: Initial platform initialization, secure key extraction from `flutter_secure_storage`, and routing gate.
2. **Onboarding (`/onboarding`)**: Short welcome introducing privacy, source references, concept maps, and accessibility profiles.
3. **Profile Selection (`/profile_select`)**: Choose a profile and preview its palette and study adaptations.
4. **Library (`/library`)**: Dashboard with due counts, searchable study sets, filters, and review entry points.
5. **Lesson Overview (`/lesson/:id`)**: Lesson summary, source attribution, and primary study actions.
6. **Edit Study Set (`/lesson/:id/edit`)**: Edit a set title and its flashcards.
7. **Flashcard Review (`/review/:id`)**: Short active-recall session with a visible card count, source links, and Leitner response actions.
8. **Concept Map (`/concept_map/:id`)**: Interactive graph with node line-provenance inspection.
9. **Progress & Analytics (`/progress`)**: Mastery metrics, Leitner box distribution (Boxes 1–5), and per-set completion meters.
10. **Settings & Accessibility (`/settings`)**: Profile switching, text size, reduced motion, high-contrast outlines, privacy information, and local data controls.
11. **Capture Notes (`/capture`)**: Camera preview, multi-page capture, typed notes, and sample inputs (Milestone 3).
12. **OCR Document Review (`/ocr-review`)**: Numbered line-by-line inspection interface for captured notes (Milestone 3).

Supporting sheets include source evidence, recently deleted sets, concept map selection, and note details.

---

## 2. Screen Wireframe Specifications

### 2.1 Onboarding and Profile Selection
```text
+-------------------------------------------------------+
|  NeuroScript AI                                       |
|  Personalized, Grounded Study for Neurodivergent Minds|
|                                                       |
|  +-------------------------------------------------+  |
|  | [O] ADHD Focus Profile                          |  |
|  |     Chunked 5-card sessions, high-contrast      |  |
|  |     visual dividers, dopamine progress rings.   |  |
|  +-------------------------------------------------+  |
|                                                       |
|  +-------------------------------------------------+  |
|  | [A] Dyslexia Reading Profile                    |  |
|  |     Warm anti-glare background, widened line    |  |
|  |     spacing, line-level source provenance.      |  |
|  +-------------------------------------------------+  |
|                                                       |
|  +-------------------------------------------------+  |
|  | [S] Autism Predictability Profile               |  |
|  |     Calm low-saturation tones, literal wording, |  |
|  |     deterministic layouts, zero autoplay motion.|  |
|  +-------------------------------------------------+  |
|                                                       |
|  [           Confirm Profile & Continue           ]   |
+-------------------------------------------------------+
```

### 2.2 Flashcard Review with Line-Level Provenance Sheet
```text
+-------------------------------------------------------+
| <- Lesson Overview               Card 2 of 5   [TTS]  |
| ===================================================== |
| Progress: [====                ] 40% Completed        |
|                                                       |
| +---------------------------------------------------+ |
| |                                                   | |
| |  Question:                                        | |
| |  What is the primary role of chlorophyll in the   | |
| |  light-dependent reactions?                       | |
| |                                                   | |
| |  [ Tap to Reveal Answer ]                         | |
| |                                                   | |
| |  [?] Where is this from? (Lines 3-4)              | |
| +---------------------------------------------------+ |
|                                                       |
| [  Not Yet (Reset Box 1)  ]    [  Got It (Advance)  ] |
+-------------------------------------------------------+
| MODAL SHEET: "Where is this from?"                    |
| Source Note: "Biology Lecture - Photosynthesis"       |
| Document Hash: 8f4a1c...                              |
|                                                       |
| Line 2: Light energy is absorbed by pigments.         |
| Line 3: > Chlorophyll absorbs blue and red wavelengths|
| Line 4: > and converts light into chemical energy ATP.|
| Line 5: Carbon fixation occurs in the stroma later.   |
|                                                       |
| [                      Close Sheet                  ] |
+-------------------------------------------------------+
```

### 2.3 Interactive Semantic Concept Map
```text
+-------------------------------------------------------+
| <- Lesson Overview           Concept Map      [Reset] |
| ===================================================== |
| +---------------------------------------------------+ |
| |                                                   | |
| |   [Light Energy] ----(activates)---> [Chlorophyll]| |
| |                                             |     | |
| |                                        (synthesizes)|
| |                                             v     | |
| |   [Stroma (Calvin)] <---(supplies)---- [ATP/NADPH]| |
| |                                                   | |
| +---------------------------------------------------+ |
| Hint: Pinch to zoom, drag to pan canvas.              |
| Selected Node: Chlorophyll (Cited in Source Lines 3, 4)|
| [ View Source Evidence ]                              |
+-------------------------------------------------------+
```

---

## 3. WCAG 2.1 AA Ergonomics & Touch Target Verification

* **Touch Targets:** All interactive buttons (`AppButton`, card flip targets, chip selectors) adhere to a minimum bounding box of $48 \times 48\text{ dp}$.
* **Contrast Compliance:** All text and card boundaries meet or exceed the $4.5:1$ contrast threshold for standard body text and $3.0:1$ for large titles.
* **Non-Reliance on Color Alone:** State indicators (such as card mastery, review scheduling, and validation badges) combine color cues with explicit typography, icons, and numerical badges.
