# Design System and UI/UX Specifications

This directory contains user interface design tokens, accessibility specifications, screen wireframes, and design guidelines for NeuroScript AI.

---

## Directory Index

* **[design_tokens.json](design_tokens.json):** Machine-readable design tokens defining spacing scales, border radii, elevations, touch targets, and neuroinclusive profile color palettes.
* **[wireframes.md](wireframes.md):** Low-fidelity and high-fidelity screen wireframes, visual hierarchies, and interaction flows across the 11 core application views.

---

## Accessibility Guidelines and Design Tokens

The interface implements three distinct design systems developed according to WCAG 2.1 AA criteria (minimum contrast ratio of 4.5:1 for body text, interactive touch targets $\ge 48$ dp, and text scaling up to $2.0\times$ without layout clipping).

### 1. ADHD Profile (Executive Function & Focus Support)
* **Visual Hierarchy:** Minimalist, uncluttered cards with high-clarity section dividers.
* **Palette:** Deep Indigo primary (`#3F51B5`) paired with accessible amber-brown accents (`#B45309`) on a neutral background (`#F8F9FA`).
* **Session Chunking:** Study sessions are capped at 5-card micro-sessions with immediate visual completion rings to sustain dopamine feedback loops.

### 2. Dyslexia Profile (Visual Stress & Reading Comfort)
* **Anti-Glare Palette:** Warm off-white/cream background (`#FBF8EE`) paired with softened charcoal text (`#2B2D42`) to eliminate the optical glare of pure black on bright white.
* **Typography:** Relaxed line height ($\ge 1.6$) and increased letter spacing (tracking $+0.6$) to prevent visual crowding and line skipping.
* **Reading Aids:** Warm low-glare colors, relaxed line spacing, editable OCR text, and a line-level source sheet ("Where is this from?"). Read-aloud support is planned for a later milestone.

### 3. Autism Profile (Sensory Regulation & Predictability)
* **Low-Sensory Palette:** Calm, muted sage-teal primary (`#3D6B7A`) and ice-mist background (`#EEF3F4`) with low color saturation.
* **Predictable Structure:** Fixed navigation layouts with explicit step counters (e.g., "Card 2 of 5") and confirmation dialogues on destructive actions.
* **Motion & Audio:** Respects the operating system reduced-motion setting and includes an in-app reduced-motion toggle. Audio is not enabled yet.
* **Predictable Language:** Uses direct labels, visible session counts, and explicit confirmation before destructive actions. Text simplification is planned for a later milestone.
