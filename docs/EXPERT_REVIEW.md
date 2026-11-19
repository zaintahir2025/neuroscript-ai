# Educational Psychologist Evaluation Protocol & Expert Review Log

This document describes the expert clinical review protocol, methodology, evaluation instruments, and the tracking log of changes made in response to expert psychologist feedback.

---

## 1. Expert Review Purpose & Scope

NeuroScript AI implements accessibility design systems tailored for university students diagnosed with or exhibiting traits of:

* **Attention Deficit Hyperactivity Disorder (ADHD)**
* **Dyslexia**
* **Autism Spectrum Conditions (ASC)**

While the user interface design tokens strictly comply with published W3C WCAG 2.1 AA standards and the British Dyslexia Association guidelines, formal clinical validity requires review by qualified educational psychologists, special educational needs coordinators (SENCOs), and clinical accessibility practitioners.

---

## 2. Evaluation Instruments & Review Protocol

The formal psychologist evaluation instruments are stored in the repository under `docs/evaluation/`:

1. **[NeuroScript_AI_Psychologist_Evaluation_Form.docx](evaluation/NeuroScript_AI_Psychologist_Evaluation_Form.docx):**
   * Multi-dimensional questionnaire evaluating:
     * Visual sensory arousal and cognitive load.
     * Scotopic anti-glare effectiveness of the warm cream (`#FBF8EE`) palette.
     * Pacing suitability of the 5-card micro-session cap for ADHD learners.
     * Predictability and emotional safety of the structured Autism UI.
2. **[NeuroScript_AI_Psychologist_Review_Form_Final.docx](evaluation/NeuroScript_AI_Psychologist_Review_Form_Final.docx):**
   * Finalized semi-structured interview rubric for qualitative clinical evaluation and scoring.

### Review Procedure

1. **Participant Briefing:** Evaluators receive an ethical consent form, app overview, and demonstration device (or emulator video capture).
2. **Interactive Walkthrough:** The psychologist reviews each of the three profiles across the core journey (Onboarding $\to$ Profile Selection $\to$ Library $\to$ OCR Review $\to$ Flashcards $\to$ Concept Map).
3. **Assessment Scoring:** The evaluator completes the Likert-scale questions and records open-ended clinical qualitative feedback.
4. **Architectural Handoff:** Recommendations are reviewed by the engineering team, assigned tracking issues, and logged below.

---

## 3. Changes Made After Expert Review

> [!NOTE]
> **Status: Awaiting First Review Cycle (Scheduled for Milestone 6)**
> The table below serves as the permanent register for tracking modifications made directly in response to psychologist and accessibility expert recommendations. It will be populated as evaluation forms are completed.

| ID | Date | Reviewer Role / Credential | Feedback / Clinical Concern | Architectural Change Made | Commit / PR Reference |
| :--- | :--- | :--- | :--- | :--- | :--- |
| *REV-01* | *Pending M6* | *Educational Psychologist* | *Awaiting review cycle* | *To be determined* | *Pending* |
| *REV-02* | *Pending M6* | *SEN Accessibility Specialist* | *Awaiting review cycle* | *To be determined* | *Pending* |

---

## 4. Post-Review Action Template

When logging changes following an expert review session, maintain this template:

```markdown
### Review Session [Date]
* **Reviewer:** [Anonymized ID, e.g., Psych-A]
* **Qualification:** [e.g., Chartered Educational Psychologist, HCPC registered]
* **Key Observations:**
  1. [Observation 1]
  2. [Observation 2]
* **Action Items Implemented:**
  * [Action 1: e.g., Adjusted letter tracking from +0.4 to +0.6 in Dyslexia text style]
  * [Action 2: e.g., Added toggle to disable all pulse animations in ADHD profile]
* **Verification:** [Test file or golden test verifying change]
```
