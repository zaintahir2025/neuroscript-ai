# ==============================================================================
# Script: generate_psychologist_form.ps1
# Generates a polished, professional Word document (.docx) for the Psychologist's
# Evaluation and Attestation for NeuroScript AI (FYP Part 1).
# ==============================================================================

$outputDocx = "c:\Users\Zain\StudioProjects\neuro_script\docs\NeuroScript_AI_Psychologist_Evaluation_Form.docx"

Write-Host "Initializing Microsoft Word COM Object..."
$word = New-Object -ComObject Word.Application
$word.Visible = $false
$word.DisplayAlerts = 0

try {
    $doc = $word.Documents.Add()

    # Set 0.7 inch margins for a clean professional layout
    $doc.PageSetup.TopMargin = 50.4    # ~0.7 in
    $doc.PageSetup.BottomMargin = 50.4
    $doc.PageSetup.LeftMargin = 50.4
    $doc.PageSetup.RightMargin = 50.4

    $selection = $word.Selection

    # Helper function for headings
    function Add-HeaderTitle($text) {
        $selection.Font.Name = "Calibri"
        $selection.Font.Size = 18
        $selection.Font.Bold = $true
        $selection.Font.Color = 0x005B540A # Deep Teal
        $selection.ParagraphFormat.Alignment = 1 # Center
        $selection.ParagraphFormat.SpaceAfter = 3
        $selection.TypeText($text)
        $selection.TypeParagraph()
    }

    function Add-SubHeader($text) {
        $selection.Font.Name = "Calibri"
        $selection.Font.Size = 11
        $selection.Font.Bold = $false
        $selection.Font.Italic = $true
        $selection.Font.Color = 0x00555555 # Slate Gray
        $selection.ParagraphFormat.Alignment = 1 # Center
        $selection.ParagraphFormat.SpaceAfter = 12
        $selection.TypeText($text)
        $selection.TypeParagraph()
    }

    function Add-SectionHeading($number, $title) {
        $selection.Font.Name = "Calibri"
        $selection.Font.Size = 13
        $selection.Font.Bold = $true
        $selection.Font.Italic = $false
        $selection.Font.Color = 0x00784B1F # Deep Blue/Teal
        $selection.ParagraphFormat.Alignment = 0 # Left
        $selection.ParagraphFormat.SpaceBefore = 10
        $selection.ParagraphFormat.SpaceAfter = 4
        $selection.TypeText("$number. $title")
        $selection.TypeParagraph()
    }

    function Add-Paragraph($text, $boldPrefix = "", $spaceAfter = 4) {
        $selection.ParagraphFormat.Alignment = 0
        $selection.ParagraphFormat.SpaceBefore = 0
        $selection.ParagraphFormat.SpaceAfter = $spaceAfter

        if ($boldPrefix -ne "") {
            $selection.Font.Name = "Calibri"
            $selection.Font.Size = 10
            $selection.Font.Bold = $true
            $selection.Font.Italic = $false
            $selection.Font.Color = 0x00000000
            $selection.TypeText($boldPrefix)
        }

        $selection.Font.Name = "Calibri"
        $selection.Font.Size = 10
        $selection.Font.Bold = $false
        $selection.Font.Italic = $false
        $selection.Font.Color = 0x00222222
        $selection.TypeText($text)
        $selection.TypeParagraph()
    }

    # -------------------------------------------------------------
    # Title & Subtitle
    # -------------------------------------------------------------
    Add-HeaderTitle "NEUROSCRIPT AI"
    Add-SubHeader "Psychologist's Professional Evaluation & Clinical Usability Attestation Form`nFinal Year Project (FYP-1) - Academic Session 2026-2027"

    # -------------------------------------------------------------
    # Section 1: Project Details
    # -------------------------------------------------------------
    Add-SectionHeading "1" "Project Details"
    
    $table1 = $doc.Tables.Add($selection.Range, 4, 2)
    $table1.Borders.Enable = 1
    $table1.Borders.InsideColor = 0x00D0D0D0
    $table1.Borders.OutsideColor = 0x00909090

    $projInfo = @(
        @("Project Title:", "NeuroScript AI - Privacy-Preserving Study Platform for Neurodivergent Learners"),
        @("Student Developers:", "Ujala Sahar (Reg. No: 23-CS-135) & Zain Tahir (Reg. No: 23-CS-115)"),
        @("Project Supervisor:", "Sir Awais (Mr. Awais Mehmood), Assistant Professor, Dept. of Computer Science"),
        @("Academic Institution:", "Department of Computer Science, University of Engineering & Technology (UET) Taxila")
    )

    for ($r = 0; $r -lt 4; $r++) {
        $cell1 = $table1.Cell($r + 1, 1)
        $cell1.Range.Text = $projInfo[$r][0]
        $cell1.Range.Font.Name = "Calibri"
        $cell1.Range.Font.Size = 9.5
        $cell1.Range.Font.Bold = $true
        $cell1.Shading.BackgroundPatternColor = 0x00F5F5F5

        $cell2 = $table1.Cell($r + 1, 2)
        $cell2.Range.Text = $projInfo[$r][1]
        $cell2.Range.Font.Name = "Calibri"
        $cell2.Range.Font.Size = 9.5
        $cell2.Range.Font.Bold = $false
    }
    $table1.Columns.Item(1).Width = 140
    $table1.Columns.Item(2).Width = 370

    $selection.SetRange($table1.Range.End, $table1.Range.End)
    $selection.TypeParagraph()

    # -------------------------------------------------------------
    # Section 2: About Project (Aims & Objectives)
    # -------------------------------------------------------------
    Add-SectionHeading "2" "About the Project (Aims & Objectives)"
    Add-Paragraph "NeuroScript AI is an intelligent, privacy-preserving mobile assistive learning platform designed specifically for university and college students with learning differences, specifically Dyslexia, Attention Deficit Hyperactivity Disorder (ADHD), and Autism Spectrum Disorder (ASD). In fast-paced university environments, messy, disorganized handwritten lecture notes create significant cognitive fatigue and executive dysfunction. NeuroScript AI transforms raw handwritten notes into structured, accessible study artifacts without compromising student privacy or risking AI hallucinations." "" 3

    Add-Paragraph "1. On-Device Handwritten OCR: " "• " 2
    $selection.TypeText("Extracts raw notes into editable, numbered lines directly on the device, allowing learners to verify text before generating study sets.")
    $selection.TypeParagraph()

    Add-Paragraph "2. Active Recall & Spaced Repetition: " "• " 2
    $selection.TypeText("Automatically creates chunked flashcards and concept maps scheduled via an SM-2 spaced repetition algorithm (1, 3, 7, 14, 30 days) to solidify long-term memory retention.")
    $selection.TypeParagraph()

    Add-Paragraph "3. Factual Grounding & Anti-Hallucination: " "• " 2
    $selection.TypeText("Features a patent-pending source grounding verification engine ('Where is this from?'). Every single card links back to its exact handwritten line numbers, preventing false academic facts.")
    $selection.TypeParagraph()

    Add-Paragraph "4. Tri-Modal Accessibility Engine: " "• " 2
    $selection.TypeText("Provides dedicated, evidence-backed UI profiles (Dyslexia: cream anti-glare, weighted font, wide line/letter spacing; ADHD: single-card focus, micro-sessions of 5 cards, minimal clutter; Autism: predictable layouts, literal wording, zero distracting animations).")
    $selection.TypeParagraph()

    Add-Paragraph "5. Privacy-First Edge Architecture: " "• " 4
    $selection.TypeText("All student notes, cards, and progress metrics are stored locally in an SQLCipher AES-256 encrypted database with zero mandatory account creation or cloud data profiling.")
    $selection.TypeParagraph()

    # -------------------------------------------------------------
    # Section 3: Psychologist Details
    # -------------------------------------------------------------
    Add-SectionHeading "3" "Evaluator's Professional Details"
    
    $table2 = $doc.Tables.Add($selection.Range, 4, 2)
    $table2.Borders.Enable = 1
    $table2.Borders.InsideColor = 0x00E0E0E0
    $table2.Borders.OutsideColor = 0x00909090

    $evalFields = @(
        @("Full Name:", "Designation / Role:"),
        @("Highest Qualification(s):", "Registration / License No. (if applicable):"),
        @("Clinic / Hospital / Institution:", "Years of Clinical / Educational Experience:"),
        @("Area(s) of Specialization:", "[ ] Dyslexia / SLD    [ ] ADHD    [ ] Autism / ASD    [ ] Student Counseling")
    )

    for ($r = 0; $r -lt 4; $r++) {
        $c1 = $table2.Cell($r + 1, 1)
        $c1.Range.Text = $evalFields[$r][0] + " "
        $c1.Range.Font.Name = "Calibri"
        $c1.Range.Font.Size = 9.5
        $c1.Range.Font.Bold = $true

        $c2 = $table2.Cell($r + 1, 2)
        $c2.Range.Text = $evalFields[$r][1] + " "
        $c2.Range.Font.Name = "Calibri"
        $c2.Range.Font.Size = 9.5
        if ($r -eq 3) { $c2.Range.Font.Bold = $false } else { $c2.Range.Font.Bold = $true }
    }
    $table2.Columns.Item(1).Width = 255
    $table2.Columns.Item(2).Width = 255

    $selection.SetRange($table2.Range.End, $table2.Range.End)
    $selection.TypeParagraph()

    # -------------------------------------------------------------
    # Section 4: Psychologist Questionnaire (Streamlined ~10-15 min)
    # -------------------------------------------------------------
    Add-SectionHeading "4" "Expert Usability & Clinical Questionnaire"
    Add-Paragraph "Instructions for Evaluator: Please evaluate the demonstrated prototype (v0.3.0) against clinical and educational best practices. This questionnaire is intentionally concise to respect your time (estimated 10-12 minutes). Please rate each statement from 1 to 5, or tick the relevant options." "" 6

    # 4.1 Rating Table
    Add-Paragraph "Part A: Core Cognitive & Pedagogical Principles" "" 3
    
    $table3 = $doc.Tables.Add($selection.Range, 8, 7)
    $table3.Borders.Enable = 1
    $table3.Borders.InsideColor = 0x00D0D0D0
    $table3.Borders.OutsideColor = 0x00606060

    # Header Row
    $headers = @("Evaluation Criteria", "1`nStrongly`nDisagree", "2`nDisagree", "3`nNeutral", "4`nAgree", "5`nStrongly`nAgree", "N/A`nUnable`nto Judge")
    for ($c = 0; $c -lt 7; $c++) {
        $cell = $table3.Cell(1, $c + 1)
        $cell.Range.Text = $headers[$c]
        $cell.Range.Font.Name = "Calibri"
        $cell.Range.Font.Size = 8.5
        $cell.Range.Font.Bold = $true
        $cell.Range.ParagraphFormat.Alignment = 1
        $cell.Shading.BackgroundPatternColor = 0x00EAEAEA
    }

    $statements = @(
        "1. Real Need: Difficulty taking and studying from handwritten notes is a significant academic hurdle for students with ADHD, Dyslexia, and Autism.",
        "2. Active Recall: Breaking lectures into bite-sized flashcards with 'Got it' / 'Not yet' active recall is cognitively suitable for these learners.",
        "3. Spaced Repetition: The evidence-based review schedule (1, 3, 7, 14, 30 days) is clinically sound for consolidating long-term memory.",
        "4. Factual Verification: Linking each card directly to source note lines ('Where is this from?') prevents AI misinformation and fosters trust.",
        "5. Dyslexia Mode: The warm cream background, increased line/letter spacing, and left-aligned text effectively mitigate visual crowding/glare.",
        "6. ADHD Mode: Restricting study bursts to 5 cards per session with single-card focus reduces overwhelm and supports executive function.",
        "7. Autism Mode: The calm palette, literal wording, structured concept maps, and absence of erratic animations promote sensory comfort."
    )

    for ($i = 0; $i -lt 7; $i++) {
        $row = $i + 2
        $cellText = $table3.Cell($row, 1)
        $cellText.Range.Text = $statements[$i]
        $cellText.Range.Font.Name = "Calibri"
        $cellText.Range.Font.Size = 9
        $cellText.Range.Font.Bold = $false
        $cellText.Range.ParagraphFormat.Alignment = 0

        for ($c = 2; $c -le 7; $c++) {
            $cellBox = $table3.Cell($row, $c)
            $cellBox.Range.Text = "[  ]"
            $cellBox.Range.Font.Name = "Calibri"
            $cellBox.Range.Font.Size = 9
            $cellBox.Range.ParagraphFormat.Alignment = 1
        }
    }

    $table3.Columns.Item(1).Width = 270
    for ($c = 2; $c -le 7; $c++) {
        $table3.Columns.Item($c).Width = 40
    }

    $selection.SetRange($table3.Range.End, $table3.Range.End)
    $selection.TypeParagraph()

    # Part B: Short Qualitative Clinical Observations
    Add-Paragraph "Part B: Professional Clinical Impressions" "" 4

    Add-Paragraph "1. Which demonstrated feature or interface aspect did you find most beneficial for neurodivergent learners?" "" 2
    Add-Paragraph "____________________________________________________________________________________________________" "" 1
    Add-Paragraph "____________________________________________________________________________________________________" "" 5

    Add-Paragraph "2. Did you identify any sensory, cognitive, or usability element that could cause friction, distraction, or fatigue?" "" 2
    Add-Paragraph "____________________________________________________________________________________________________" "" 1
    Add-Paragraph "____________________________________________________________________________________________________" "" 5

    Add-Paragraph "3. What single most critical enhancement would you advise the team to prioritize for the next phase?" "" 2
    Add-Paragraph "____________________________________________________________________________________________________" "" 1
    Add-Paragraph "____________________________________________________________________________________________________" "" 6

    # -------------------------------------------------------------
    # Section 5: Formal Attestation & Signatures (Report Appendix)
    # -------------------------------------------------------------
    Add-SectionHeading "5" "Professional Feedback, Attestation & Official Sign-Off"
    Add-Paragraph "This formal attestation will be permanently incorporated into the Final Year Project (FYP-1) examination report as certified evidence of expert consultation and clinical review." "" 4

    # Readiness Verdict Box
    Add-Paragraph "Clinical Readiness Recommendation for Supervised Student Usability Pilot:" "• " 3
    Add-Paragraph "[  ]  RECOMMENDED: Suitable for supervised university student usability trial as demonstrated." "" 2
    Add-Paragraph "[  ]  RECOMMENDED WITH MINOR CHANGES: Suitable for pilot testing after minor adjustments noted above." "" 2
    Add-Paragraph "[  ]  REQUIRES SUBSTANTIAL REVISION: Requires major modifications before testing with vulnerable learners." "" 2
    Add-Paragraph "[  ]  NOT RECOMMENDED: Concept or design direction is not suitable for the intended neurodivergent cohort." "" 6

    # Formal Attestation Statement
    Add-Paragraph "Declaration of Independent Professional Review:" "Attestation Statement: " 2
    Add-Paragraph '"I hereby confirm that I have evaluated the NeuroScript AI assistive learning application prototype (v0.3.0) and reviewed its design principles, cognitive user interfaces, and privacy safeguards. The ratings, observations, and recommendations recorded in this document represent my independent professional judgment based upon the demonstration and clinical materials presented. I understand this document serves as expert stakeholder evaluation for academic documentation in the students'' Final Year Project (FYP Part 1) at UET Taxila."' "" 6

    # Attribution Permission
    Add-Paragraph "Reporting Consent: [  ] I permit my name, credentials, and feedback to be cited in the academic FYP report." "" 2
    Add-Paragraph "                   [  ] I prefer my feedback to be cited anonymously (professional role/designation only)." "" 8

    # Signature Table
    $table4 = $doc.Tables.Add($selection.Range, 3, 2)
    $table4.Borders.Enable = 1
    $table4.Borders.InsideColor = 0x00E0E0E0
    $table4.Borders.OutsideColor = 0x00808080

    $sigFields = @(
        @("Psychologist's Full Name:`n________________________________________", "Professional Designation / Department:`n________________________________________"),
        @("Signature:`n`n________________________________________", "Date & Place:`n`n____________________, _______________"),
        @("Official Stamp / Clinical Seal:`n`n`n", "Contact Email / Phone (Optional):`n`n________________________________________")
    )

    for ($r = 0; $r -lt 3; $r++) {
        $c1 = $table4.Cell($r + 1, 1)
        $c1.Range.Text = $sigFields[$r][0]
        $c1.Range.Font.Name = "Calibri"
        $c1.Range.Font.Size = 9.5
        $c1.Range.Font.Bold = $false

        $c2 = $table4.Cell($r + 1, 2)
        $c2.Range.Text = $sigFields[$r][1]
        $c2.Range.Font.Name = "Calibri"
        $c2.Range.Font.Size = 9.5
        $c2.Range.Font.Bold = $false
    }
    $table4.Columns.Item(1).Width = 255
    $table4.Columns.Item(2).Width = 255

    # Save as docx (Format 16 = wdFormatXMLDocument)
    $doc.SaveAs([ref]$outputDocx, [ref]16)
    Write-Host "Document successfully generated at: $outputDocx"
}
finally {
    $doc.Close([ref]0)
    $word.Quit()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($word) | Out-Null
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
}
