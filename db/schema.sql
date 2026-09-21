-- =============================================================================
-- Scientific NLP: Ontology Relational Layer Schema
-- Target: db/ontology.sqlite3
-- Paradigm: Deterministic, Zero-Dependency POSIX Ingestion
-- =============================================================================

PRAGMA foreign_keys = ON;

-- -----------------------------------------------------------------------------
-- 1. epigraphs: Cognitive anchors introducing each chapter
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS epigraphs (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,
    chapter_id          TEXT NOT NULL,            -- e.g., 'prologue', 'ch08', 'epilogue'
    quote               TEXT NOT NULL,            -- The epigraph text (original language)
    translation         TEXT,                     -- Japanese translation for \ChapterEpigraphWithTranslation
    attribution         TEXT NOT NULL,            -- Author / Character / Theoretical Origin
    source              TEXT,                     -- Title, Work, Anime, or Academic Paper
    context_note        TEXT,                     -- Rationale for cognitive anchoring
    created_at          DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_epigraphs_chapter_id ON epigraphs(chapter_id);

-- -----------------------------------------------------------------------------
-- 2. references_db: External observational models and bibliography metadata
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS references_db (
    cite_key            TEXT PRIMARY KEY,         -- e.g., 'bandler1975structure', 'ashby1956cybernetics'
    title               TEXT NOT NULL,
    authors             TEXT NOT NULL,
    year                INTEGER,
    domain              TEXT NOT NULL,            -- 'cybernetics', 'neuroscience', 'nlp', 'psychiatry', etc.
    tags                TEXT,                     -- Comma-separated tags: 'ergodicity,prior,hypnosis'
    conviction_level    REAL DEFAULT 1.0          -- Subjective/empirical conviction score [0.0 - 1.0]
        CHECK (conviction_level >= 0.0 AND conviction_level <= 1.0),
    annotation          TEXT,                     -- Observational critical note from the author
    created_at          DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_references_domain ON references_db(domain);

-- -----------------------------------------------------------------------------
-- 3. terms: Canonical mathematical definitions of redefined concepts
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS terms (
    symbol              TEXT PRIMARY KEY,         -- Identifier/LaTeX command key (e.g., 'CBO', 'BDLL')
    canonical_name      TEXT NOT NULL,            -- e.g., 'Cybernetic Biochemical Operator'
    latex_def           TEXT NOT NULL,            -- Formal math notation in LaTeX
    plain_summary       TEXT NOT NULL,            -- Operational definition
    absorbing_barrier   INTEGER DEFAULT 0         -- Boolean flag (0 or 1): Is it bound to an absorbing barrier?
        CHECK (absorbing_barrier IN (0, 1)),
    created_at          DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------------------------------
-- 4. epistemic_notes: Internal design axioms, hacker protocols, debug room
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS epistemic_notes (
    key                 TEXT PRIMARY KEY,         -- Semantic slug (e.g., 'posix-pipeline-hydration')
    topic               TEXT NOT NULL,            -- 'architecture', 'security', 'cybernetics', 'raw_observation'
    title               TEXT NOT NULL,
    thesis              TEXT NOT NULL,            -- Single-sentence core axiom
    body                TEXT NOT NULL,            -- Uncurated log, raw mathematical proof, or protocol details
    created_at          DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_epistemic_notes_topic ON epistemic_notes(topic);
