# NEUROSCRIPT AI
## Psychologist's Professional Evaluation & Clinical Usability Attestation Form
*Final Year Project (FYP Part 1) — Department of Computer Science, UET Taxila (Session 2026–2027)*

---

### Purpose of this Document
This document records an independent, professional clinical evaluation of the **NeuroScript AI** assistive study application. It captures expert feedback from a qualified psychologist on the pedagogical soundness, cognitive accessibility, usability, and clinical safety of the application's multi-modal interfaces. This signed form serves as official academic evidence for the Final Year Project Part 1 (FYP-1) examination and report.

---

### 1. Project Details

| Field | Detail |
| :--- | :--- |
| **Project Title** | **NeuroScript AI**: Privacy-Preserving Study Platform for Neurodivergent Learners |
| **Student Developers** | **Ujala Sahar** (Reg. No: `23-CS-135`) & **Zain Tahir** (Reg. No: `23-CS-115`) |
| **Project Supervisor** | **Sir Awais (Mr. Awais Mehmood)**, Assistant Professor, Department of Computer Science |
| **Academic Institution** | **University of Engineering & Technology (UET) Taxila**, Pakistan |
| **Degree Program** | Bachelor of Science in Computer Science (BS CS, 2023–2027) |
| **Prototype Demonstrated** | Version 0.3.0 (Milestone 3 Working Functional Build) |

---

### 2. About the Project (Aims & Objectives)

**NeuroScript AI** is an intelligent, privacy-preserving mobile assistive learning application engineered specifically for university and college students experiencing learning differences, notably **Attention Deficit Hyperactivity Disorder (ADHD)**, **Dyslexia**, and **Autism Spectrum Disorder (ASD)**.

#### Core Problem Addressed
In fast-paced higher education classrooms, traditional note-taking results in messy, disorganized handwritten notes. For neurodivergent learners, studying from unstructured notes triggers executive dysfunction, reading fatigue, and sensory overwhelm. While generic commercial AI tools exist, they frequently hallucinate incorrect exam facts, lack specialized neuro-accessible interfaces, and compromise student privacy by transmitting private notes to public cloud servers.

#### Key Project Objectives & Technical Pillars
1. **On-Device Handwritten OCR**: Employs computer vision to extract handwritten physical lecture notes into editable, numbered lines directly on the device, allowing students to verify text prior to study set synthesis.
2. **Active Recall & Spaced Repetition**: Automatically synthesizes bite-sized active recall flashcards and visual concept maps scheduled according to an SM-2 spaced repetition algorithm (intervals: 1, 3, 7, 14, 30 days) to maximize long-term retention.
3. **Factual Grounding & Anti-Hallucination**: Incorporates a transparent mathematical source-verification engine (*"Where is this from?"*). Every generated card and concept map node directly links to exact source note lines, ensuring strict academic integrity.
4. **Tri-Modal Neurodivergent HCI**:
   * **Dyslexia Profile**: High-contrast warm cream anti-glare background, weighted typography, widened character/line spacing, and left-aligned text chunking.
   * **ADHD Profile**: High-focus micro-burst study sessions (5 cards maximum), one-card-at-a-time active recall, and zero peripheral clutter.
   * **Autism Profile**: Predictable layout patterns, literal and structured phrasing, calm slate/teal palette, and elimination of erratic animations or jarring transitions.
5. **Privacy-Preserving Edge Architecture**: All student notes, cards, and review metrics reside in a local SQLite database encrypted with **SQLCipher (AES-256)**, requiring zero mandatory account registration or cloud tracking.

---

### 3. Evaluator's Professional Details

| Information Field | Evaluator's Response |
| :--- | :--- |
| **Full Name** | __________________________________________________ |
| **Professional Qualification(s)** | __________________________________________________ |
| **Designation / Clinical Role** | __________________________________________________ |
| **Registration / License No.** | __________________________________________________ |
| **Clinic / Hospital / Institution** | __________________________________________________ |
| **Years of Clinical / Educational Experience** | __________________________________________________ |
| **Area(s) of Practice / Specialization** | [ &nbsp; ] Dyslexia & SLD &nbsp;&nbsp;&nbsp; [ &nbsp; ] ADHD &nbsp;&nbsp;&nbsp; [ &nbsp; ] Autism Spectrum &nbsp;&nbsp;&nbsp; [ &nbsp; ] Student Mental Health |

---

### 4. Expert Usability & Clinical Questionnaire
*(Designed for a focused 10–12 minute live demonstration and testing session)*

#### Part A: Structured Ratings
*Please indicate your degree of agreement with each statement:*  
**1 = Strongly Disagree (SD)** | **2 = Disagree (D)** | **3 = Neutral (N)** | **4 = Agree (A)** | **5 = Strongly Agree (SA)** | **N/A = Unable to Judge**

| # | Evaluation Criteria | 1 (SD) | 2 (D) | 3 (N) | 4 (A) | 5 (SA) | N/A |
| :-: | :--- | :-: | :-: | :-: | :-: | :-: | :-: |
| **Q1** | **Need Relevance**: Messy, unstructured lecture notes represent a real, substantial academic barrier for students with ADHD, Dyslexia, and Autism. | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] |
| **Q2** | **Active Recall**: Breaking dense lecture notes into single-concept flashcards with active recall ('Got it' / 'Not yet') is pedagogically effective for these learners. | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] |
| **Q3** | **Spaced Repetition**: The automated spaced-repetition revision schedule (1, 3, 7, 14, 30 days) is clinically sound for preventing cramming and cognitive fatigue. | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] |
| **Q4** | **Source Grounding**: Directly tracing each flashcard to original handwritten note lines (*"Where is this from?"*) effectively mitigates misinformation and builds student confidence. | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] |
| **Q5** | **Dyslexia Suitability**: The warm cream background, increased line/letter spacing, and left-aligned text chunking meaningfully reduce visual stress and reading distortion. | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] |
| **Q6** | **ADHD Suitability**: Capping study sessions to 5 cards with isolated single-card presentation supports executive initiation and sustained attention without overstimulation. | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] |
| **Q7** | **Autism Suitability**: The predictable layouts, literal wording, structured concept maps, and absence of distracting animations provide sensory comfort. | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] |
| **Q8** | **Privacy & Trust**: Keeping student notes locally encrypted (SQLCipher AES-256) without mandatory cloud profiling provides appropriate safeguarding. | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] | [ &nbsp; ] |

---

#### Part B: Qualitative Clinical Impressions

**1. Most Beneficial Feature:**  
*In your professional opinion, which demonstrated feature or user interface design is most advantageous for neurodivergent learners?*  
__________________________________________________________________________________________________  
__________________________________________________________________________________________________  

**2. Potential Cognitive Friction / Areas of Caution:**  
*Did you observe any design element, wording, or transition that could potentially cause confusion, sensory fatigue, or academic over-reliance?*  
__________________________________________________________________________________________________  
__________________________________________________________________________________________________  

**3. Priority Recommendation:**  
*What is the single most critical improvement the development team should prioritize before testing with university students?*  
__________________________________________________________________________________________________  
__________________________________________________________________________________________________  

---

### 5. Professional Feedback, Attestation & Official Sign-Off
*(To be permanently incorporated into the Final Year Project Examination Report)*

#### Clinical Readiness Recommendation for Supervised Student Usability Pilot:
*(Please select one)*  
* [ &nbsp; ] **RECOMMENDED (Ready As-Is)**: The product is suitable for a supervised university student usability trial as demonstrated.  
* [ &nbsp; ] **RECOMMENDED WITH MINOR ADJUSTMENTS**: The product is suitable for pilot testing following minor improvements noted above.  
* [ &nbsp; ] **REQUIRES SUBSTANTIAL REVISION**: The product requires significant modifications before safe testing with vulnerable student groups.  
* [ &nbsp; ] **NOT RECOMMENDED**: The conceptual design or execution is not clinically appropriate for the intended student cohort.  

#### Formal Attestation Statement:
> *"I hereby confirm that I have evaluated the **NeuroScript AI** assistive learning application prototype (v0.3.0) and reviewed its design principles, cognitive user interfaces, pedagogical structures, and privacy safeguards. The ratings, observations, and recommendations recorded in this document represent my independent professional judgment based upon the demonstration and clinical materials presented. I understand this document serves as expert stakeholder evaluation for academic documentation in the students' Final Year Project (FYP Part 1) at the Department of Computer Science, University of Engineering & Technology (UET) Taxila."*

#### Academic Reporting Consent:
*(Please select one)*  
* [ &nbsp; ] **Permitted**: I permit the students to include my name, qualifications, designation, and this completed form in their academic FYP-1 report.  
* [ &nbsp; ] **Anonymous**: I prefer my feedback to be included in the academic report anonymously (clinical title/designation only).  

---

#### Signature & Institutional Seal Block

| Evaluator Field | Detail & Signature |
| :--- | :--- |
| **Psychologist's Full Name** | __________________________________________________ |
| **Professional Designation & Dept.** | __________________________________________________ |
| **Signature** | __________________________________________________ |
| **Date & Place** | Date: ___________________ &nbsp;&nbsp;&nbsp;&nbsp; City/Place: ___________________ |
| **Official Stamp / Clinical Seal** | <br><br>*(Place Official Clinic / Institutional Stamp Here)*<br><br><br> |

---
*NeuroScript AI is an assistive study-support software application developed for academic research purposes. It is not a diagnostic instrument or clinical medical device.*
