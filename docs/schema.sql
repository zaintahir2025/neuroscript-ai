-- ============================================================================
-- NeuroScript AI: Relational Database Schema (SQLite / SQLCipher AES-256)
-- File: docs/schema.sql
--
-- Description:
--   Complete production DDL schema definition for NeuroScript AI on-device encrypted
--   persistence (Drift schema v2) adhering to Appendix A of the Project Proposal.
--   Enforces cascading referential integrity, zero data retention on deletion,
--   and cryptographic key verification.
-- ============================================================================

-- Activate foreign key constraints on every database connection
PRAGMA foreign_keys = ON;

-- ----------------------------------------------------------------------------
-- 1. USER_PROFILES
-- Stores learner accessibility preferences and active profile selection.
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS user_profiles (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  profile_type TEXT NOT NULL CHECK(profile_type IN ('ADHD', 'Dyslexia', 'Autism')),
  theme_settings TEXT NOT NULL DEFAULT '{}',
  created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
);

-- ----------------------------------------------------------------------------
-- 2. SOURCE_NOTES
-- Stores raw OCR text and cryptographic document digests from student notes.
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS source_notes (
  note_id TEXT NOT NULL PRIMARY KEY,
  raw_ocr_text TEXT NOT NULL,
  document_hash TEXT NOT NULL UNIQUE,
  created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
);

CREATE INDEX IF NOT EXISTS idx_source_notes_hash ON source_notes (document_hash);

-- ----------------------------------------------------------------------------
-- 3. LESSONS
-- Structured study units containing interactive concept graphs and metadata.
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS lessons (
  lesson_id TEXT NOT NULL PRIMARY KEY,
  note_id TEXT NOT NULL REFERENCES source_notes (note_id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  concept_map_json TEXT NOT NULL,
  prompt_version TEXT NOT NULL DEFAULT 'v1',
  source TEXT NOT NULL DEFAULT 'seed' CHECK(source IN ('seed', 'mock', 'cloud', 'device')),
  created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
  is_deleted INTEGER NOT NULL DEFAULT 0 CHECK(is_deleted IN (0, 1))
);

CREATE INDEX IF NOT EXISTS idx_lessons_note_id ON lessons (note_id);
CREATE INDEX IF NOT EXISTS idx_lessons_is_deleted ON lessons (is_deleted);

-- ----------------------------------------------------------------------------
-- 4. FLASHCARDS
-- Active recall flashcards grounded in source note lines with verification metrics.
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS flashcards (
  card_id TEXT NOT NULL PRIMARY KEY,
  lesson_id TEXT NOT NULL REFERENCES lessons (lesson_id) ON DELETE CASCADE,
  question TEXT NOT NULL,
  answer TEXT NOT NULL,
  source_line_reference TEXT NOT NULL,
  grounding_score REAL,
  verified INTEGER NOT NULL DEFAULT 0 CHECK(verified IN (0, 1))
);

CREATE INDEX IF NOT EXISTS idx_flashcards_lesson_id ON flashcards (lesson_id);
CREATE INDEX IF NOT EXISTS idx_flashcards_verified ON flashcards (verified);

-- ----------------------------------------------------------------------------
-- 5. REVIEW_PROGRESS
-- Tracks Leitner Spaced Repetition System (SRS) intervals and review scheduling.
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS review_progress (
  progress_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  card_id TEXT NOT NULL REFERENCES flashcards (card_id) ON DELETE CASCADE,
  box INTEGER NOT NULL DEFAULT 1 CHECK(box BETWEEN 1 AND 5),
  spaced_repetition_interval INTEGER NOT NULL DEFAULT 1 CHECK(spaced_repetition_interval IN (1, 3, 7, 14, 30)),
  next_review_date INTEGER NOT NULL,
  last_reviewed_at INTEGER,
  consecutive_correct INTEGER NOT NULL DEFAULT 0
);

CREATE INDEX IF NOT EXISTS idx_review_progress_card_id ON review_progress (card_id);
CREATE INDEX IF NOT EXISTS idx_review_progress_due ON review_progress (next_review_date);

-- ----------------------------------------------------------------------------
-- 6. PENDING_JOBS (Milestone 4C / FR-12: Offline Queue)
-- Enqueues background synthesis requests when offline or rate-limited.
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS pending_jobs (
  job_id TEXT NOT NULL PRIMARY KEY,
  note_hash TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK(status IN ('pending', 'in_flight', 'completed', 'failed')),
  attempts INTEGER NOT NULL DEFAULT 0,
  next_attempt_at INTEGER NOT NULL,
  created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
);

CREATE INDEX IF NOT EXISTS idx_pending_jobs_status_attempt ON pending_jobs (status, next_attempt_at);

-- ----------------------------------------------------------------------------
-- 7. REQUEST_LOG (Backend Proxy Ephemeral Audit Store - Figure 5.3)
-- Minimal telemetry table for rate limiting and latency metrics. Zero student data.
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS request_log (
  id TEXT NOT NULL PRIMARY KEY,
  install_hash TEXT NOT NULL,
  endpoint TEXT NOT NULL,
  status_code INTEGER NOT NULL,
  latency_ms INTEGER NOT NULL,
  provider TEXT NOT NULL CHECK(provider IN ('mock', 'gemini', 'fallback')),
  created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
);

CREATE INDEX IF NOT EXISTS idx_request_log_install_created ON request_log (install_hash, created_at);
