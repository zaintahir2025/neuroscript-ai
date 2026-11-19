# ==============================================================================
# Script: generate_perfect_psychologist_form.ps1
# Generates a comprehensive, beautifully styled, and executive-ready Word document
# (.docx) for the Psychologist's Professional Evaluation & Attestation.
# Specifically tailored for NeuroScript AI (FYP Part 1) at UET Taxila.
# ==============================================================================

$outputDocx = "c:\Users\Zain\StudioProjects\neuro_script\docs\NeuroScript_AI_Psychologist_Evaluation_Form.docx"

Write-Host "Starting Word Automation Engine..."
$word = New-Object -ComObject Word.Application
$word.Visible = $false
$word.DisplayAlerts = 0

try {
    $doc = $word.Documents.Add()

    # Page Setup: Standard Letter / A4 with clean 0.75 inch (54 pt) margins
    $doc.PageSetup.TopMargin = 54
    $doc.PageSetup.BottomMargin = 54
    $doc.PageSetup.LeftMargin = 54
    $doc.PageSetup.RightMargin = 54

    # Color Palette Constants (Word BGR format)
    # Primary Navy: #0F3B5F -> BGR: 0x5F3B0F
    # Secondary Teal: #1F7A8C -> BGR: 0x8C7A1F
    # Dark Slate Text: #2D3748 -> BGR: 0x48372D
    # Muted Gray: #718096 -> BGR: 0x968071
    # Light Box Fill: #F8FAFC -> BGR: 0xFCFAF8
    # Accent Warm Cream: #FDFBF7 -> BGR: 0xF7FBFD
    # Border Gray: #CBD5E1 -> BGR: 0xE1D5CB

    $NAVY = 0x5F3B0F
    $TEAL = 0x8C7A1F
    $TEXT_DARK = 0x48372D
    $GRAY_MUTED = 0x968071
    $BG_LIGHT = 0xFCFAF8
    $BORDER_COLOR = 0xE1D5CB

    # Setup Header & Footer
    $section = $doc.Sections.Item(1)
    $headerRange = $section.Headers.Item(1).Range
    $headerRange.Font.Name = "Calibri"
    $headerRange.Font.Size = 8.5
    $headerRange.Font.Color = $GRAY_MUTED
    $headerRange.Text = "NEUROSCRIPT AI  |  Psychologist's Professional Evaluation & Clinical Usability Protocol (FYP-1)"
    $headerRange.ParagraphFormat.Alignment = 0 # Left

    $footerRange = $section.Footers.Item(1).Range
    $footerRange.Font.Name = "Calibri"
    $footerRange.Font.Size = 8.5
    $footerRange.Font.Color = $GRAY_MUTED
    $footerRange.Text = "Department of Computer Science, University of Engineering & Technology (UET) Taxila  |  Confidential & Academic Evaluation"
    $footerRange.ParagraphFormat.Alignment = 1 # Center

    $selection = $word.Selection

    # Helper Functions
    function Write-DocHeader {
        $selection.ParagraphFormat.Alignment = 1 # Center
        $selection.ParagraphFormat.SpaceBefore = 0
        $selection.ParagraphFormat.SpaceAfter = 2

        $selection.Font.Name = "Calibri"
        $selection.Font.Size = 20
        $selection.Font.Bold = $true
        $selection.Font.Color = $NAVY
        $selection.TypeText("NEUROSCRIPT AI")
        $selection.TypeParagraph()

        $selection.Font.Size = 13
        $selection.Font.Bold = $true
        $selection.Font.Color = $TEAL
        $selection.ParagraphFormat.SpaceAfter = 4
        $selection.TypeText("PSYCHOLOGIST'S PROFESSIONAL EVALUATION & ATTESTATION")
        $selection.TypeParagraph()

        $selection.Font.Size = 10
        $selection.Font.Bold = $false
        $selection.Font.Italic = $true
        $selection.Font.Color = $GRAY_MUTED
        $selection.ParagraphFormat.SpaceAfter = 14
        $selection.TypeText("Clinical Usability, Accessibility & Educational Safety Review for Students with ADHD, Dyslexia & Autism`nFinal Year Project (FYP-1) - Department of Computer Science, UET Taxila (Session 2026-2027)")
        $selection.TypeParagraph()
    }

    function Write-SectionHeading($num, $title) {
        $selection.ParagraphFormat.Alignment = 0 # Left
        $selection.ParagraphFormat.SpaceBefore = 14
        $selection.ParagraphFormat.SpaceAfter = 6
        $selection.Font.Name = "Calibri"
        $selection.Font.Size = 12.5
        $selection.Font.Bold = $true
        $selection.Font.Italic = $false
        $selection.Font.Color = $NAVY
        $sectionTitle = "SECTION " + $num + ": " + $title
        $selection.TypeText($sectionTitle)
        $selection.TypeParagraph()
    }

    function Write-SubHeading($title) {
        $selection.ParagraphFormat.Alignment = 0
        $selection.ParagraphFormat.SpaceBefore = 8
        $selection.ParagraphFormat.SpaceAfter = 4
        $selection.Font.Name = "Calibri"
        $selection.Font.Size = 10.5
        $selection.Font.Bold = $true
        $selection.Font.Color = $TEAL
        $selection.TypeText($title)
        $selection.TypeParagraph()
    }

    function Write-BodyText($text, $boldPrefix = "", $spaceAfter = 4) {
        $selection.ParagraphFormat.Alignment = 0
        $selection.ParagraphFormat.SpaceBefore = 0
        $selection.ParagraphFormat.SpaceAfter = $spaceAfter

        if ($boldPrefix -ne "") {
            $selection.Font.Name = "Calibri"
            $selection.Font.Size = 10
            $selection.Font.Bold = $true
            $selection.Font.Color = $TEXT_DARK
            $selection.TypeText($boldPrefix)
        }

        $selection.Font.Name = "Calibri"
        $selection.Font.Size = 10
        $selection.Font.Bold = $false
        $selection.Font.Color = $TEXT_DARK
        $selection.TypeText($text)
        $selection.TypeParagraph()
    }

    function Add-FeedbackBox($promptText, $linesHeight = 6) {
        $selection.ParagraphFormat.Alignment = 0
        $selection.ParagraphFormat.SpaceBefore = 6
        $selection.ParagraphFormat.SpaceAfter = 2
        $selection.Font.Name = "Calibri"
        $selection.Font.Size = 10
        $selection.Font.Bold = $true
        $selection.Font.Color = $NAVY
        $selection.TypeText($promptText)
        $selection.TypeParagraph()

        # Add a bordered shaded 1-cell box with generous writing height
        $boxTable = $doc.Tables.Add($selection.Range, 1, 1)
        $boxTable.Borders.Enable = 1
        $boxTable.Borders.InsideColor = $BORDER_COLOR
        $boxTable.Borders.OutsideColor = $BORDER_COLOR
        $boxTable.Rows.Item(1).Height = ($linesHeight * 15) # height in points
        $boxTable.Rows.Item(1).HeightRule = 1 # wdRowHeightAtLeast

        $cell = $boxTable.Cell(1, 1)
        $cell.Shading.BackgroundPatternColor = $BG_LIGHT
        $cell.Range.Font.Name = "Calibri"
        $cell.Range.Font.Size = 9.5
        $cell.Range.Font.Italic = $true
        $cell.Range.Font.Color = 0x00A0A0A0
        $cell.Range.Text = "Write your professional clinical remarks, observations, and recommendations here...`n`n`n`n`n"
        $cell.Range.ParagraphFormat.SpaceBefore = 4
        $cell.Range.ParagraphFormat.SpaceAfter = 4

        $boxTable.Columns.Item(1).Width = 504 # Full width within margins

        $selection.SetRange($boxTable.Range.End, $boxTable.Range.End)
        $selection.TypeParagraph()
    }

    # =============================================================
    # 1. HEADER
    # =============================================================
    Write-DocHeader

    # Purpose Banner
    Write-BodyText "Purpose & Context of Evaluation: " "DOCUMENT PURPOSE: " 2
    Write-BodyText "This official evaluation form records an independent professional review by a licensed clinical/educational psychologist. The goal is to rigorously examine the pedagogical validity, cognitive accessibility, visual accommodations, and ethical safeguards of NeuroScript AI. The psychologist's structured ratings, written qualitative feedback, and signed attestation will be permanently bound into the academic report for Final Year Project Part 1 (FYP-1). Completing this form takes approximately 10 to 15 minutes." "" 8

    # =============================================================
    # SECTION 1: PROJECT DETAILS
    # =============================================================
    Write-SectionHeading "1" "PROJECT IDENTIFICATION & ACADEMIC DETAILS"

    $projTable = $doc.Tables.Add($selection.Range, 5, 2)
    $projTable.Borders.Enable = 1
    $projTable.Borders.InsideColor = $BORDER_COLOR
    $projTable.Borders.OutsideColor = $NAVY

    $pData = @(
        @("Project Title", "NeuroScript AI: Privacy-Preserving Study Platform for Neurodivergent Learners"),
        @("Student Developers", "Ujala Sahar (Registration No: 23-CS-135)`nZain Tahir (Registration No: 23-CS-115)"),
        @("Project Supervisor", "Sir Awais (Mr. Awais Mehmood), Assistant Professor, Dept. of Computer Science"),
        @("Academic Institution", "Department of Computer Science, University of Engineering & Technology (UET) Taxila"),
        @("Degree & Project Stage", "Bachelor of Science in Computer Science (BS CS 2023-2027)`nCourse Code: CS-400 (Final Year Project Part 1)  |  Prototype Evaluated: v0.3.0 (Milestone 3)")
    )

    for ($r = 0; $r -lt 5; $r++) {
        $c1 = $projTable.Cell($r + 1, 1)
        $c1.Range.Text = $pData[$r][0]
        $c1.Range.Font.Name = "Calibri"
        $c1.Range.Font.Size = 9.5
        $c1.Range.Font.Bold = $true
        $c1.Range.Font.Color = $NAVY
        $c1.Shading.BackgroundPatternColor = 0x00F0EAE0 # Soft warm gray

        $c2 = $projTable.Cell($r + 1, 2)
        $c2.Range.Text = $pData[$r][1]
        $c2.Range.Font.Name = "Calibri"
        $c2.Range.Font.Size = 9.5
        $c2.Range.Font.Bold = $false
        $c2.Range.Font.Color = $TEXT_DARK
    }
    $projTable.Columns.Item(1).Width = 135
    $projTable.Columns.Item(2).Width = 369

    $selection.SetRange($projTable.Range.End, $projTable.Range.End)
    $selection.TypeParagraph()

    # =============================================================
    # SECTION 2: ABOUT THE PROJECT (AIMS, ARCHITECTURE & HCI)
    # =============================================================
    Write-SectionHeading "2" "ABOUT THE PROJECT (AIMS, ARCHITECTURE & HCI DESIGN)"
    Write-BodyText "NeuroScript AI is an assistive mobile study platform engineered to bridge the severe gap between unorganized classroom lecture notes and accessible, autonomous studying for students with learning differences—specifically Dyslexia, Attention Deficit Hyperactivity Disorder (ADHD), and Autism Spectrum Disorder (ASD)." "" 4

    Write-SubHeading "2.1 The Clinical & Pedagogical Problem"
    Write-BodyText "During fast-paced university lectures, neurodivergent students struggle with rapid handwriting, dysgraphia, visual-spatial organization, and working memory saturation. The resulting handwritten notes are often messy, fragmented, and visually chaotic. Revising from such notes triggers intense executive dysfunction, cognitive avoidance, and exam anxiety. While commercial tools exist, they have critical shortcomings: generic AI assistants (ChatGPT, Knowt) hallucinate incorrect facts and expose private student data to the cloud, while traditional flashcard apps (Quizlet, Anki) require laborious manual card typing that overwhelms students with ADHD." "" 4

    Write-SubHeading "2.2 End-to-End System Architecture & Workflow"
    Write-BodyText "1. On-Device Handwritten Note Capture & OCR: " "Step 1 - Note Digitization: " 2
    Write-BodyText "The student captures handwritten pages using the camera or gallery. Text is transcribed on-device using Google ML Kit (Android/iOS) or private client-side WebAssembly (Web). Zero image data is sent to external clouds." "" 3

    Write-BodyText "2. Human-in-the-Loop OCR Review & Line Editor: " "Step 2 - Verification of Dysgraphic Writing: " 2
    Write-BodyText "Recognizing that students with dyslexia or dysgraphia produce non-standard spelling and messy handwriting, the app presents an editable, numbered-line review screen. Students easily verify, tap-to-edit, merge, or re-order transcribed lines before any AI generation occurs." "" 3

    Write-BodyText "3. Active Recall & Spaced Repetition (SM-2): " "Step 3 - Pedagogical Material Synthesis: " 2
    Write-BodyText "The verified notes are synthesized into bite-sized active recall flashcards ('Got it' / 'Not yet') and hierarchical concept maps. Revisions are scheduled over evidence-based spaced intervals (1, 3, 7, 14, 30 days) to prevent cramming and consolidate long-term memory." "" 3

    Write-BodyText "4. Factual Grounding & Anti-Hallucination Verification: " "Step 4 - 'Where is this from?' Source Tracing: " 2
    Write-BodyText "Every flashcard and concept map node contains a direct mathematical grounding link back to the exact handwritten note lines it originated from. Students can tap 'Where is this from?' at any time to verify the fact against their own notes, eliminating AI hallucinations and fostering academic trust." "" 3

    Write-BodyText "5. Tri-Modal Neurodivergent Adaptive Interfaces (HCI): " "Step 5 - Specialized Cognitive Profiles: " 2
    Write-BodyText "• Dyslexia Profile: Warm anti-glare cream background (RGB 251, 248, 238), weighted typography, widened character/line spacing, and left-aligned text chunking to alleviate visual crowding and reading distortion.`n• ADHD Profile: High-focus interface with micro-burst review sessions capped at 5 cards, single-card display, instant feedback, and zero distracting animations or gamified clutter.`n• Autism Profile: Predictable, consistent navigation, literal wording without confusing metaphors, sensory-comfortable muted slate/teal palette, and complete elimination of sudden sounds or erratic motion." "" 4

    Write-BodyText "6. Privacy-First Edge Security: " "Step 6 - Local Data Protection: " 2
    Write-BodyText "All student notes, transcripts, generated cards, and study metrics are stored locally in an SQLCipher AES-256 encrypted SQLite database. No account is required, and no student profiling occurs." "" 8

    # =============================================================
    # SECTION 3: PSYCHOLOGIST'S DETAILS
    # =============================================================
    Write-SectionHeading "3" "EVALUATOR'S CLINICAL & PROFESSIONAL CREDENTIALS"
    Write-BodyText "Please provide your professional details below to validate this expert evaluation:" "" 4

    $evalTable = $doc.Tables.Add($selection.Range, 4, 2)
    $evalTable.Borders.Enable = 1
    $evalTable.Borders.InsideColor = $BORDER_COLOR
    $evalTable.Borders.OutsideColor = $NAVY

    $eData = @(
        @("Psychologist's Full Name:", "Designation / Academic Role:"),
        @("Highest Qualifications / Degrees:", "PMDC / License / Registration No:"),
        @("Clinic / Hospital / University:", "Years of Clinical / Educational Experience:"),
        @("Main Clinical Specialization(s):", "[  ] Dyslexia & SLD     [  ] ADHD     [  ] Autism Spectrum (ASD)`n[  ] Cognitive Psychology     [  ] Student Mental Health")
    )

    for ($r = 0; $r -lt 4; $r++) {
        $c1 = $evalTable.Cell($r + 1, 1)
        $c1.Range.Text = $eData[$r][0] + " "
        $c1.Range.Font.Name = "Calibri"
        $c1.Range.Font.Size = 9.5
        $c1.Range.Font.Bold = $true
        $c1.Range.Font.Color = $NAVY

        $c2 = $evalTable.Cell($r + 1, 2)
        $c2.Range.Text = $eData[$r][1] + " "
        $c2.Range.Font.Name = "Calibri"
        $c2.Range.Font.Size = 9.5
        if ($r -eq 3) {
            $c2.Range.Font.Bold = $false
            $c2.Range.Font.Color = $TEXT_DARK
        } else {
            $c2.Range.Font.Bold = $true
            $c2.Range.Font.Color = $NAVY
        }
    }
    $evalTable.Columns.Item(1).Width = 252
    $evalTable.Columns.Item(2).Width = 252

    $selection.SetRange($evalTable.Range.End, $evalTable.Range.End)
    $selection.TypeParagraph()

    # =============================================================
    # SECTION 4: PSYCHOLOGIST QUESTIONNAIRE
    # =============================================================
    Write-SectionHeading "4" "CLINICAL & PEDAGOGICAL QUESTIONNAIRE"
    Write-BodyText "Please evaluate the demonstrated application (NeuroScript AI v0.3.0) against established psychological, cognitive, and educational standards. For each statement, tick one rating box: " "" 2
    Write-BodyText "1 = Strongly Disagree (SD)  |  2 = Disagree (D)  |  3 = Neutral (N)  |  4 = Agree (A)  |  5 = Strongly Agree (SA)  |  N/A = Unable to Judge" "" 6

    $qTable = $doc.Tables.Add($selection.Range, 16, 7)
    $qTable.Borders.Enable = 1
    $qTable.Borders.InsideColor = $BORDER_COLOR
    $qTable.Borders.OutsideColor = $NAVY

    # Table Header
    $qHeaders = @("Evaluation Criteria & Specific App Features", "1`nSD", "2`nD", "3`nN", "4`nA", "5`nSA", "N/A`nN/A")
    for ($c = 0; $c -lt 7; $c++) {
        $cItem = $qTable.Cell(1, $c + 1)
        $cItem.Range.Text = $qHeaders[$c]
        $cItem.Range.Font.Name = "Calibri"
        $cItem.Range.Font.Size = 8.5
        $cItem.Range.Font.Bold = $true
        $cItem.Range.Font.Color = $NAVY
        $cItem.Range.ParagraphFormat.Alignment = 1
        $cItem.Shading.BackgroundPatternColor = 0x00EFEFEF
    }

    $qRows = @(
        # Pedagogical & General Cognitive Relevance
        "1. Academic Need: Inability to easily read and revise from messy handwritten notes is a major cause of academic distress and executive fatigue for LD students.",
        "2. Active Recall Suitability: Breaking complex lectures into one-concept flashcards with 'Got it' / 'Not yet' active recall is pedagogically sound for these learners.",
        "3. Spaced Repetition Logic: The evidence-based review schedule (1, 3, 7, 14, 30 days) is clinically sound for consolidating long-term memory without cramming.",
        # Dyslexia Specific
        "4. Dyslexia Visual Accommodations: The anti-glare warm cream palette (RGB 251, 248, 238), weighted font, and widened letter/line spacing reduce reading distortion.",
        "5. Dyslexic Handwriting Tolerance: Providing an editable, numbered line review screen is an effective safeguard for students with dysgraphia and irregular handwriting.",
        "6. Text Chunking for Dyslexia: Presenting information in short, left-aligned chunks prevents perceptual crowding and tracking loss across lines.",
        # ADHD Specific
        "7. ADHD Executive Initiation: The streamlined note-to-card workflow reduces the high cognitive activation barrier required to start studying.",
        "8. ADHD Micro-Burst Sessions: Restricting review sessions to 5 cards per session with single-card focus effectively manages limited sustained attention spans.",
        "9. Distraction-Free Design: The deliberate absence of noisy notifications, timer countdown anxiety, and gamified popups helps ADHD students maintain flow.",
        # Autism Specific
        "10. Sensory Comfort: The calm slate/teal palette, predictable layout hierarchy, and complete absence of flashing motion create a sensory-safe environment.",
        "11. Literal & Explicit Wording: Using direct, literal phrasing for study cards without confusing idioms or metaphors accommodates autistic cognitive communication.",
        "12. Concept Map Structure: Visual concept maps provide explicit structural relationships between concepts, aiding autistic visual-spatial learning styles.",
        # Safety, Ethics & Privacy
        "13. Factual Grounding Trust: The 'Where is this from?' source tracing feature linking every card to exact note lines is critical for building student trust.",
        "14. Ethical Non-Diagnostic Framing: The app responsibly positions its profiles as customizable study aids rather than diagnostic clinical labels.",
        "15. Privacy & Data Safeguarding: On-device SQLCipher AES-256 encryption without mandatory cloud account registration appropriately protects sensitive student data."
    )

    for ($i = 0; $i -lt 15; $i++) {
        $rowNum = $i + 2
        $cText = $qTable.Cell($rowNum, 1)
        $cText.Range.Text = $qRows[$i]
        $cText.Range.Font.Name = "Calibri"
        $cText.Range.Font.Size = 8.5
        $cText.Range.Font.Bold = $false
        $cText.Range.Font.Color = $TEXT_DARK
        $cText.Range.ParagraphFormat.Alignment = 0

        for ($c = 2; $c -le 7; $c++) {
            $cBox = $qTable.Cell($rowNum, $c)
            $cBox.Range.Text = "[  ]"
            $cBox.Range.Font.Name = "Calibri"
            $cBox.Range.Font.Size = 8.5
            $cBox.Range.Font.Color = $TEXT_DARK
            $cBox.Range.ParagraphFormat.Alignment = 1
        }
    }

    $qTable.Columns.Item(1).Width = 288
    for ($c = 2; $c -le 7; $c++) {
        $qTable.Columns.Item($c).Width = 36
    }

    $selection.SetRange($qTable.Range.End, $qTable.Range.End)
    $selection.TypeParagraph()

    # =============================================================
    # SECTION 5: WRITTEN PROFESSIONAL FEEDBACK (GENEROUS SPACES)
    # =============================================================
    Write-SectionHeading "5" "PSYCHOLOGIST'S WRITTEN CLINICAL FEEDBACK & OBSERVATIONS"
    Write-BodyText "Please provide detailed qualitative feedback in the dedicated sections below. These written remarks will be included in the students' FYP-1 final thesis report:" "" 4

    Add-FeedbackBox "5.1 Overall Professional Assessment & Perceived Value:`nHow effective is the concept of transforming handwritten notes into verified active-recall materials for neurodivergent university students? What are its primary clinical and educational strengths?" 6

    Add-FeedbackBox "5.2 Suitability by Neurodivergent Profile (Dyslexia, ADHD, Autism):`nAre the specific accommodations (cream palette, chunking, 5-card micro-sessions, literal wording, concept maps) clinically appropriate? What nuances should the team consider regarding individual differences?" 6

    Add-FeedbackBox "5.3 Identified Clinical Risks, Potential Over-reliance & Safeguards:`nWhat potential risks (e.g., student over-reliance on AI, anxiety from revision reminders, frustration from OCR handwriting errors) must the team guard against? What psychological safeguards are advised?" 6

    Add-FeedbackBox "5.4 Top Three Actionable Recommendations for Development:`nWhat are the three most critical improvements the team should implement before conducting supervised usability trials with university students?" 6

    # =============================================================
    # SECTION 6: FORMAL ATTESTATION & SIGNATURES (REPORT APPENDIX)
    # =============================================================
    Write-SectionHeading "6" "FORMAL CLINICAL ATTESTATION & OFFICIAL SIGN-OFF"
    Write-BodyText "This section constitutes the official certification of expert evaluation to be bound into Appendix A of the Final Year Project Part 1 (FYP-1) examination submission at UET Taxila." "" 4

    Write-SubHeading "6.1 Clinical Readiness Recommendation for Supervised Student Usability Pilot:"
    Write-BodyText "[  ]  RECOMMENDED (READY AS-IS): The application is pedagogically sound, cognitively accessible, and suitable for a supervised university student usability trial as demonstrated.`n[  ]  RECOMMENDED WITH MINOR ADJUSTMENTS: The product is suitable for pilot testing following minor adjustments noted in Section 5 above.`n[  ]  REQUIRES SUBSTANTIAL REVISION: Major clinical or usability modifications are required before safe testing with neurodivergent students.`n[  ]  NOT RECOMMENDED: The conceptual approach or user interface is not clinically suitable for the targeted student cohort." "" 6

    Write-SubHeading "6.2 Expert Attestation Declaration:"
    Write-BodyText '"I hereby confirm that I have personally evaluated the NeuroScript AI assistive learning application prototype (v0.3.0) and reviewed its design principles, cognitive user interfaces, pedagogical structures, and privacy safeguards. The ratings, qualitative remarks, and recommendations recorded in this document represent my independent professional judgment based upon the demonstration and clinical materials presented to me. I understand that this completed and signed document will be incorporated into the academic Final Year Project Part 1 (FYP-1) report submitted by the students to the Department of Computer Science, University of Engineering & Technology (UET) Taxila."' "" 6

    Write-SubHeading "6.3 Permission for Academic Reporting:"
    Write-BodyText "[  ] I grant permission for my name, qualifications, designation, and this completed form to be cited in the FYP-1 report.`n[  ] I prefer my feedback to be cited anonymously (clinical role and professional designation only)." "" 8

    # Signature & Seal Table
    $sigTable = $doc.Tables.Add($selection.Range, 3, 2)
    $sigTable.Borders.Enable = 1
    $sigTable.Borders.InsideColor = $BORDER_COLOR
    $sigTable.Borders.OutsideColor = $NAVY

    $sData = @(
        @("Psychologist's Full Name:`n`n__________________________________________________", "Professional Designation & Department:`n`n__________________________________________________"),
        @("Official Signature:`n`n`n__________________________________________________", "Date & Location:`n`nDate: ____________________  Place: _________________"),
        @("Official Clinical Stamp / Institutional Seal:`n`n`n`n`n", "Contact Phone / Email (Optional):`n`n__________________________________________________")
    )

    for ($r = 0; $r -lt 3; $r++) {
        $c1 = $sigTable.Cell($r + 1, 1)
        $c1.Range.Text = $sData[$r][0]
        $c1.Range.Font.Name = "Calibri"
        $c1.Range.Font.Size = 9.5
        $c1.Range.Font.Color = $NAVY
        if ($r -eq 2) {
            $c1.Shading.BackgroundPatternColor = 0x00FAF5F0
        } else {
            $c1.Shading.BackgroundPatternColor = 0x00FFFFFF
        }

        $c2 = $sigTable.Cell($r + 1, 2)
        $c2.Range.Text = $sData[$r][1]
        $c2.Range.Font.Name = "Calibri"
        $c2.Range.Font.Size = 9.5
        $c2.Range.Font.Color = $NAVY
        $c2.Shading.BackgroundPatternColor = 0x00FFFFFF
    }
    $sigTable.Columns.Item(1).Width = 252
    $sigTable.Columns.Item(2).Width = 252

    $selection.SetRange($sigTable.Range.End, $sigTable.Range.End)
    $selection.TypeParagraph()

    Write-BodyText "* Disclaimer: NeuroScript AI is an assistive study-support software developed for academic research purposes. It is designed to provide cognitive and sensory accommodations and does not claim to diagnose, treat, or clinically cure any learning or neurological condition." "" 4

    # Save as docx (Format 16 = wdFormatXMLDocument)
    $doc.SaveAs([ref]$outputDocx, [ref]16)
    Write-Host "Perfect Word Document generated at: $outputDocx"
}
finally {
    $doc.Close([ref]0)
    $word.Quit()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($word) | Out-Null
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
}
