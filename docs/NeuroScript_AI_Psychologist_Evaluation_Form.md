# NEUROSCRIPT AI
## PSYCHOLOGIST’S PROFESSIONAL EVALUATION & ATTESTATION PROTOCOL
**Clinical Usability, Cognitive Accessibility & Educational Safety Review**  
*Bachelor of Science in Computer Science (BS CS 2023–2027) | Course: CS-400 (Final Year Project Part 1)*  
*Department of Computer Science, University of Engineering & Technology (UET) Taxila, Pakistan*

---

### Purpose of this Document
This formal evaluation document records an independent, professional assessment conducted by a qualified psychologist. The evaluation assesses the pedagogical relevance, visual accessibility, executive function supports, sensory comfort, and clinical safety of **NeuroScript AI** (Working Prototype v0.3.0). The ratings, written qualitative feedback, readiness recommendation, and official attestation contained in this document will be permanently incorporated into the students' **Final Year Project (FYP-1) Final Examination Report**.

---

### SECTION 1: PROJECT DETAILS & ACADEMIC SUPERVISION

| Administrative Item | Academic & Project Specification |
| :--- | :--- |
| **Project Title** | **NeuroScript AI**: Privacy-Preserving Adaptive Study Platform for Neurodivergent Learners |
| **Student Developers** | **Ujala Sahar** (Registration No: `23-CS-135`)<br>**Zain Tahir** (Registration No: `23-CS-115`) |
| **Project Supervisor** | **Sir Awais (Mr. Awais Mehmood)**, Assistant Professor, Department of Computer Science |
| **Academic Institution** | **University of Engineering & Technology (UET) Taxila**, Punjab, Pakistan |
| **Degree & Academic Stage** | Bachelor of Science in Computer Science (BS CS)<br>Session: 2026–2027 (CS-400 Final Year Project Part 1) |
| **Software Version Evaluated**| **NeuroScript AI Prototype v0.3.0 (Milestone 3 Working Build)** |

---

### SECTION 2: ABOUT THE PROJECT (AIMS, ARCHITECTURE & HCI)

#### 2.1 The Clinical & Educational Need
In higher education classrooms, traditional lecture delivery requires students to listen, comprehend, synthesize, and write simultaneously. For neurodivergent university students—specifically those diagnosed with **Attention Deficit Hyperactivity Disorder (ADHD)**, **Dyslexia**, and **Autism Spectrum Disorder (ASD)**—this process is hindered by:
* **Dysgraphia & Reading Fatigue**: Physical handwriting is often messy, disorganized, and irregularly spaced. Revising from visually cluttered notes causes severe reading fatigue, perceptual distortion, and tracking loss.
* **Executive Dysfunction & Task Initiation**: The daunting task of organizing chaotic handwritten notes into structured study guides creates an insurmountable barrier to initiating study sessions.
* **Sensory Overwhelm**: Bright white screens, erratic animations, intrusive ads, and noisy alerts cause sensory overload and cognitive avoidance.
* **Risks of Commercial Generative AI**: Generic commercial AI tools (e.g., ChatGPT, Knowt) hallucinate incorrect formulas, dates, and definitions—an unacceptable risk for exam preparation. Furthermore, these platforms require uploading private personal notes to remote cloud servers, violating student privacy.

#### 2.2 System Architecture & End-to-End Workflow
NeuroScript AI resolves these barriers through a privacy-preserving, hybrid edge architecture:

```
[Student's Handwritten Notes]
            │
            ▼
┌──────────────────────────────────────────────┐
│ STEP 1: On-Device Camera / Gallery Capture   │ (Offline image preprocessing)
└──────────────────────────────────────────────┘
            │
            ▼
┌──────────────────────────────────────────────┐
│ STEP 2: On-Device Optical Character Rec (OCR)│ (ML Kit / WASM - Zero cloud transfer)
└──────────────────────────────────────────────┘
            │
            ▼
┌──────────────────────────────────────────────┐
│ STEP 3: Human-in-the-Loop Line Editor        │ (Student verifies & edits split lines,
│         (Safeguard for Dysgraphic Writing)   │  omissions, or non-standard spelling)
└──────────────────────────────────────────────┘
            │
            ▼
┌──────────────────────────────────────────────┐
│ STEP 4: Factual Grounding & Synthesis Engine │ (Every flashcard & concept node links
│         ("Where is this from?" Line Tracking)│  back to exact verified note line numbers)
└──────────────────────────────────────────────┘
            │
            ▼
┌──────────────────────────────────────────────┐
│ STEP 5: Active Recall & Spaced Repetition    │ (SM-2 Algorithm: 1, 3, 7, 14, 30 days;
│         (Tri-Modal Adaptive HCI Profiles)    │  Flashcards, concept maps, progress stats)
└──────────────────────────────────────────────┘
            │
            ▼
┌──────────────────────────────────────────────┐
│ STEP 6: Encrypted Local Storage (SQLCipher)  │ (AES-256 encrypted SQLite database;
│         (100% Private, On-Device, No Account)│  Zero data profiling, offline-first)
└──────────────────────────────────────────────┘
```

#### 2.3 Tri-Modal Neurodivergent Adaptive Interfaces (HCI)
Rather than treating all learners identically, NeuroScript AI dynamically adapts its entire interface based on three specialized cognitive profiles:

1. **Dyslexia Profile**:
   * **Visual Accommodation**: Anti-glare warm cream canvas (`#FBF8EE`), avoiding harsh pure white contrast.
   * **Typography**: Increased letter tracking, 1.6x line spacing, weighted letter stems, and left-aligned text chunking to alleviate visual crowding and line-skipping.
   * **Dysgraphic Tolerance**: A dedicated, numbered-line review screen allows learners to easily edit OCR transcription mistakes before generating study sets.

2. **ADHD Profile**:
   * **Micro-Burst Study Sessions**: Strict session caps of **5 cards at a time**, preventing cognitive fatigue and task abandonment.
   * **Single-Card Focus**: Active recall flip-card presentation with only two unambiguous responses: *"Got it"* (confident recall) and *"Not yet"* (re-queue for spaced review).
   * **Distraction-Free Environment**: Complete removal of countdown timers, gamified pressure streaks, and intrusive notifications.

3. **Autism Spectrum Profile**:
   * **Sensory Comfort**: Subdued, low-saturation slate and teal color palette (`#2A4365` / `#1F7A8C`).
   * **Zero Jitter / Reduced Motion**: Complete elimination of sudden screen transitions, confetti animations, or unexpected audio prompts.
   * **Literal Communication**: Strictly explicit, literal wording for all system prompts and flashcards, eliminating ambiguous idioms or metaphors.
   * **Structural Clarity**: Interactive concept maps visually illustrating hierarchical and lateral relationships between topics.

4. **Privacy-First Data Architecture**:
   * All student notes, transcriptions, generated cards, and study progress metrics are stored locally on the device in an SQLite database encrypted with **SQLCipher (AES-256)**.
   * No mandatory accounts, no telemetry profiling, and full offline functionality.

---

### SECTION 3: EVALUATOR'S PROFESSIONAL CREDENTIALS

*Please record your professional credentials below:*

| Credential Field | Evaluator's Information |
| :--- | :--- |
| **Psychologist's Full Name** | ______________________________________________________________________ |
| **Highest Qualification(s) & Degrees** | ______________________________________________________________________ |
| **Clinical Designation / Title** | ______________________________________________________________________ |
| **PMDC / License / Registration No.** | ______________________________________________________________________ |
| **Clinic / Hospital / Academic Institution** | ______________________________________________________________________ |
| **Years of Clinical / Educational Experience** | ______________________________________________________________________ |
| **Main Clinical & Practice Area(s)** | [ &nbsp; ] Dyslexia & Specific Learning Disorders (SLD)<br>[ &nbsp; ] ADHD & Executive Function Coaching<br>[ &nbsp; ] Autism Spectrum Disorder (ASD)<br>[ &nbsp; ] Adolescent & University Student Mental Health<br>[ &nbsp; ] Other: __________________________________________________ |

---

### SECTION 4: CLINICAL & PEDAGOGICAL QUESTIONNAIRE
*(To be completed during or immediately following the live application walkthrough)*

#### Rating Scale:
* **1 = Strongly Disagree (SD)**: Major clinical concern or unacceptable design choice.
* **2 = Disagree (D)**: Does not adequately meet clinical/educational standards.
* **3 = Neutral (N)**: Acceptable, but no clear clinical advantage demonstrated.
* **4 = Agree (A)**: Clinically sound, accessible, and pedagogically beneficial.
* **5 = Strongly Agree (SA)**: Exemplary implementation of neuro-inclusive design principles.
* **N/A = Unable to Judge**: Feature not demonstrated or outside specific area of expertise.

---

#### 4.1 Evaluation Matrix

| # | Evaluation Criteria & App Feature | 1 (SD) | 2 (D) | 3 (N) | 4 (A) | 5 (SA) | N/A |
| :-: | :--- | :-: | :-: | :-: | :-: | :-: | :-: |
| **A. Pedagogical Need & Cognitive Relevance** | | | | | | |
| **1** | **Need Significance**: Difficulty organizing and revising from unstructured handwritten lecture notes is a significant cause of academic stress, executive fatigue, and avoidance for LD students. | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] |
| **2** | **Active Recall Chunking**: Transforming dense lecture text into single-concept active recall flashcards (*'Got it'* / *'Not yet'*) is an effective cognitive strategy for neurodivergent learners. | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] |
| **3** | **Spaced Repetition Schedule**: The automated SM-2 spaced repetition revision intervals (1, 3, 7, 14, 30 days) provide an appropriate memory consolidation structure that prevents stressful cramming. | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] |
| **B. Dyslexia-Specific Reading Accommodations** | | | | | | |
| **4** | **Visual Accessibility**: The warm cream background (`#FBF8EE`), widened character/line spacing, and left-aligned text chunking effectively reduce visual crowding, glare, and letter distortion. | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] |
| **5** | **Dysgraphic Error Tolerance**: The human-in-the-loop line review screen is an appropriate clinical safeguard that allows students with messy handwriting to easily inspect and edit transcription errors. | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] |
| **6** | **Cognitive Readability**: The option to scale text dynamically up to 2.0x without UI clipping or horizontal scrolling supports students with visual tracking difficulties. | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] |
| **C. ADHD Focus & Executive Function Accommodations** | | | | | | |
| **7** | **Executive Initiation**: Converting raw notes into immediate flashcards reduces the daunting activation barrier required to begin a revision session. | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] |
| **8** | **Micro-Burst Session Cap**: Restricting study sessions to **5 cards per burst** with isolated single-card focus aligns well with limited sustained attention spans and prevents cognitive fatigue. | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] |
| **9** | **Distraction-Free Environment**: The absence of ticking timer countdowns, intrusive pop-up ads, and aggressive gamified streaks protects ADHD students from anxiety and attention diversion. | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] |
| **D. Autism Spectrum Sensory Comfort & Predictability** | | | | | | |
| **10** | **Sensory Safety**: The subdued slate/teal color scheme, predictable screen layout, and total absence of jarring audio alerts or erratic animations provide a sensory-comfortable environment. | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] |
| **11** | **Literal & Clear Communication**: The use of direct, literal phrasing for study questions and instructions without confusing idioms or sarcasm suits autistic cognitive processing. | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] |
| **12** | **Concept Map Structural Clarity**: Providing interactive visual concept maps with explicit hierarchical nodes supports students who comprehend relationships better through visual-spatial models. | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] |
| **E. Safety, Privacy & Ethical Guardrails** | | | | | | |
| **13** | **Factual Grounding & Anti-Hallucination**: The *"Where is this from?"* source line verification linking every card back to original note lines is an essential safeguard against AI misinformation. | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] |
| **14** | **Ethical Non-Diagnostic Framing**: The application appropriately positions its profiles as customizable study aids rather than formal medical or diagnostic classifications. | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] |
| **15** | **Data Safeguarding & Privacy**: Storing all notes and progress in a locally encrypted database (SQLCipher AES-256) without requiring online accounts properly protects vulnerable student data. | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] |

---

### SECTION 5: WRITTEN CLINICAL FEEDBACK & OBSERVATIONS
*(Please provide your detailed qualitative observations in the dedicated response spaces below)*

#### 5.1 Overall Professional Assessment & Value
*What is your professional evaluation of the NeuroScript AI concept? How valuable is it to turn disorganized handwritten notes into factually verified, active recall study materials for neurodivergent university students?*

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                        │
│                                                                                        │
│                                                                                        │
│                                                                                        │
│                                                                                        │
│                                                                                        │
│                                                                                        │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

#### 5.2 Suitability by Neurodivergent Profile (Dyslexia, ADHD, Autism)
*Are the specific interface accommodations (e.g., cream background, line spacing, 5-card session limit, literal wording, concept maps) clinically appropriate? What nuances should the team consider regarding individual differences?*

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                        │
│                                                                                        │
│                                                                                        │
│                                                                                        │
│                                                                                        │
│                                                                                        │
│                                                                                        │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

#### 5.3 Potential Clinical Risks, Student Over-Reliance & Safeguards
*What potential psychological or practical risks (e.g., over-reliance on automated cards, revision anxiety from missed intervals, frustration from handwritten OCR errors) should the development team address?*

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                        │
│                                                                                        │
│                                                                                        │
│                                                                                        │
│                                                                                        │
│                                                                                        │
│                                                                                        │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

#### 5.4 Top Three Actionable Recommendations for Development
*What are the three most critical improvements the development team should prioritize before initiating a supervised usability trial with university students?*

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│ 1.                                                                                     │
│                                                                                        │
│ 2.                                                                                     │
│                                                                                        │
│ 3.                                                                                     │
│                                                                                        │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

---

### SECTION 6: FORMAL CLINICAL ATTESTATION & OFFICIAL SIGN-OFF
*(To be permanently bound into Appendix A of the FYP-1 Final Examination Report)*

#### 6.1 Clinical Readiness Recommendation for Supervised Usability Pilot:
*(Please select the statement that best reflects your professional opinion)*  
* [ &nbsp; ] **RECOMMENDED (READY AS-IS)**: The application is pedagogically sound, cognitively accessible, and suitable for a supervised university student usability trial as demonstrated.  
* [ &nbsp; ] **RECOMMENDED WITH MINOR ADJUSTMENTS**: The application is suitable for pilot testing following the minor improvements noted in Section 5 above.  
* [ &nbsp; ] **REQUIRES SUBSTANTIAL REVISION**: The application requires major clinical, pedagogical, or interface modifications before safe testing with neurodivergent students.  
* [ &nbsp; ] **NOT RECOMMENDED**: The conceptual approach or user interface is not clinically suitable for the targeted student cohort.  

#### 6.2 Formal Attestation Declaration:
> *"I hereby confirm that I have personally evaluated the **NeuroScript AI** assistive learning application prototype (v0.3.0) and reviewed its design principles, cognitive user interfaces, pedagogical structures, and privacy safeguards. The ratings, qualitative remarks, and recommendations recorded in this document represent my independent professional judgment based upon the demonstration and clinical materials presented to me. I understand that this completed and signed document will be incorporated into the academic Final Year Project Part 1 (FYP-1) report submitted by the students to the Department of Computer Science, University of Engineering & Technology (UET) Taxila."*

#### 6.3 Permission for Academic Reporting:
*(Please select one)*  
* [ &nbsp; ] **Full Attribution**: I permit the students to include my name, qualifications, clinical designation, and this completed form in their academic FYP-1 report.  
* [ &nbsp; ] **Anonymous Attribution**: I prefer my feedback to be cited anonymously in the report (clinical role and professional designation only).  

---

#### 6.4 Official Signature & Institutional Seal Block

| Evaluator Identification | Signature & Verification |
| :--- | :--- |
| **Psychologist's Full Name:**<br><br>__________________________________________________ | **Official Signature:**<br><br><br>__________________________________________________ |
| **Professional Designation & Dept:**<br><br>__________________________________________________ | **Date & Place:**<br><br>Date: ____________________ &nbsp;&nbsp;&nbsp;&nbsp; Place: _________________ |
| **Official Clinical Stamp / Institutional Seal:**<br><br><br><br><br>*(Affix Official Stamp Here)*<br><br><br> | **Contact Information (Email / Phone - Optional):**<br><br>__________________________________________________ |

---
*Disclaimer: NeuroScript AI is an assistive study-support software developed for academic research purposes. It provides cognitive and sensory accommodations and does not claim to diagnose, treat, or clinically cure any learning or neurological condition.*
