# Ontology Data Layer (`db/`)

This directory serves as the persistent, local-first knowledge layer hosting the conceptual, mathematical, and historical ontology of *Scientific NLP*.

Rejecting opaque cloud subscriptions, heavyweight ORMs, and brittle runtime bindings, this project adopts a **deterministic, data-driven code generation architecture** adhering to the core tenets of the UNIX philosophy.

---

## 1. Epistemological Foundation: Data-Driven Code Generation

Intellectual sovereignty demands reproducible, zero-friction builds across diverse environments (local Arch Linux, macOS, GitHub Actions CI/CD).
This book is not written as a conventional monolithic manuscript—it is engineered as a **modular artifact generated deterministically from structured local knowledge**.

- **Normalization of Knowledge (`db/ontology.sqlite3`)**
  - Manages relational integrity across citations, mathematical terms, and master epigraph pools.
  - Epigraphs exist as a normalized, multi-purpose quotation pool decoupled from fixed chapter IDs, queryable via SQL.
- **Separation of Authoring and Compilation**
  - **Compilation (`make`)**: The typesetting engine (`lualatex`) executes completely isolated from external databases, runtime C-bindings (`.so`), or `-shell-escape` security overrides. It consumes only static, pre-rendered `.tex` components.
  - **Authoring (`make epigraph`)**: High-leverage generation tasks are executed offline on demand, transforming structured inventory into static LaTeX macros via a UNIX pipeline (`gawk` $\to$ `m4` $\to$ `sqlite3`).
- **Graph Causal Layer (KùzuDB)**
  - Tracks conceptual feedback loops, multi-loop cybernetic models, and absorbing barrier dependencies.

---

## 2. Directory Architecture

```text
db/
├── ontology.sqlite3         # SQLite3: Relational ontology database
├── ontology.kuzu/           # KùzuDB: Property graph storage directory
├── schema.sql               # SQLite DDL (table definitions & indexes)
├── generate_epigraph.sql.m4 # Parameterized m4 SQL template for LaTeX macro generation
├── seed.example.sql         # Public baseline seeds (epigraphs, references)
├── seed/                    # [Private / .gitignored] Local epistemic seed corpus
├── graph_schema.cypher      # KùzuDB schema definitions
└── README.md                # This specification

```

---

## 3. Data Models (`schema.sql`)

### A. Normalized Epigraph Pool (`epigraphs`)

Quotation assets are managed independently of specific chapter bindings:

```sql
CREATE TABLE IF NOT EXISTS epigraphs (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,
    quote               TEXT NOT NULL,            -- Original text
    translation         TEXT,                     -- Japanese translation
    attribution         TEXT NOT NULL,            -- Author / Originator
    source              TEXT,                     -- Work, Paper, or Speech
    context_note        TEXT,                     -- Cognitive rationale
    created_at          DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_epigraphs_attribution ON epigraphs(attribution);

```

### B. References and Observational Models (`references_db`)

Stores bibliography keys, conviction scores, domain categorizations, and formal academic attributions.

---

## 4. Pipeline Architecture (Data-Driven Code Generation)

The authoring pipeline separates dynamic query execution from PDF typesetting:

```text
[ src/epigraphs.tsv ]  (Manifest / Declarative Mapping)
        │
        ▼ (gawk parameterization)
[ db/generate_epigraph.sql.m4 ]
        │
        ▼ (m4 macro expansion)
[ SQLite3 (db/ontology.sqlite3) ]
        │
        ▼ (Offline batch generation via `make epigraph`)
[ src/epigraph/*.tex ] (Static LaTeX Macros)
        │
        ▼ (\input into manuscript chapters)
[ LuaLaTeX (`make`) ] ───► [ build/the_seed_of_magic.pdf ]

```

---

## 5. Epigraph Generation Protocol

### 1. Inventory Declaration (`src/epigraphs.tsv`)

Assignments of epigraphs to chapters are centrally registered in a TSV manifest:

```tsv
# target	word	author	limit
cha_prologue	cybernetic biochemical	Sugaya	1
cha_authoring_pipeline	Arch BTW	Unix Hacker	1
app_othello_filter	Body language	Sugaya	1
app_computational_duality	undocumented feature	Proverb	1
app_cybernetic_authoring	street finds	Gibson	1

```

* **`target`**: Destination basename (generates `src/epigraph/<target>.tex`).
* **`word`**: Substring filter matched against `quote` or `translation`.
* **`author`**: Substring filter matched against `attribution`.
* **`limit`**: Maximum records to render (default: 1).

### 2. Parameterized SQL Template (`db/generate_epigraph.sql.m4`)

The template handles parameter injection using `__WORD__`, `__AUTHOR__`, and `__LIMIT__`, while escaping SQL syntax through custom quote delimiters (`[[`, `]]`):

```sql
changequote(`[[', `]]')dnl
.mode list
.separator ""
.headers off

SELECT 
    CASE 
        WHEN translation IS NOT NULL AND trim(translation) != '' THEN
            '\ChapterEpigraphWithTranslation{' || 
            trim(quote) || '}{' || 
            trim(translation) || '}{' || 
            trim(attribution) || 
            CASE 
                WHEN source IS NOT NULL AND trim(source) != '' THEN ', \textit{' || trim(source) || '}'
                ELSE ''
            END || '}'
        ELSE
            '\ChapterEpigraph{' || 
            trim(quote) || '}{' || 
            trim(attribution) || 
            CASE 
                WHEN source IS NOT NULL AND trim(source) != '' THEN ', \textit{' || trim(source) || '}'
                ELSE ''
            END || '}'
    END
FROM epigraphs
WHERE 1=1
ifdef([[__WORD__]], [[  AND (quote LIKE '%__WORD__%' OR translation LIKE '%__WORD__%')]])
ifdef([[__AUTHOR__]], [[  AND attribution LIKE '%__AUTHOR__%']])
ORDER BY id ASC
LIMIT ifdef([[__LIMIT__]], [[__LIMIT__]], [[1]]);

```

### 3. Build Automation (`Makefile`)

Generation is executed as an isolated target:

```bash
make epigraph

```

The underlying `gawk` dispatch command processes the manifest:

```makefile
epigraph: $(EPIGRAPH_TSV) $(EPIGRAPH_M4) $(DB_FILE)
	@mkdir -p $(EPIGRAPH_DIR)
	@$(GAWK) -F'\t' ' \
		!/^#/ && NF >= 1 { \
			target = $$1; word = $$2; author = $$3; limit = ($$4 != "") ? $$4 : 1; \
			outfile = "$(EPIGRAPH_DIR)/" target ".tex"; \
			cmd = "m4"; \
			if (word != "")   cmd = cmd " -D__WORD__=\"" word "\""; \
			if (author != "") cmd = cmd " -D__AUTHOR__=\"" author "\""; \
			if (limit != "")  cmd = cmd " -D__LIMIT__=" limit; \
			cmd = cmd " $(EPIGRAPH_M4) | $(SQLITE3) $(DB_FILE) > " outfile; \
			system(cmd); \
		}' $(EPIGRAPH_TSV)

```

---

## 6. Manuscript Integration

Generated components are directly imported into chapter sources:

```latex
% src/chapters/authoring_pipeline.tex
\chapter{The Cybernetic Authoring Pipeline --- 認知摩擦ゼロの自己組織化環境}
\label{cha:authoring_pipeline}

\input{src/epigraph/cha_authoring_pipeline.tex}

```

### Supported LaTeX Macros (`src/preamble/macros.tex`)

```latex
% Bilingual epigraph format
\ChapterEpigraphWithTranslation{Original Quote}{日本語訳}{Attribution, \textit{Source}}

% Monolingual epigraph format
\ChapterEpigraph{Original Quote}{Attribution, \textit{Source}}

```

---

## 7. Hacker's Protocol: Operational Data Tooling

Interactive inspection, quick buffer tests, and batch insertions operate via standard POSIX pipelines.

### 1. Interactive Vim Inspection & Injection

Retrieve an epigraph snippet directly into your active editing buffer without leaving Vim:

```vim
:r !m4 -D__WORD__="Arch" db/generate_epigraph.sql.m4 | sqlite3 db/ontology.sqlite3

```

### 2. Surgical Range Injection via `sed`

Stream line-delimited records directly into the local database:

```bash
sed -n '12,30p' db/seed/epigraphs.sql | sqlite3 db/ontology.sqlite3

```

### 3. Deterministic Batch Rehydration

Reset and re-seed the entire database in sub-second order:

```bash
rm -f db/ontology.sqlite3
sqlite3 db/ontology.sqlite3 < db/schema.sql
cat db/seed/*.sql | sqlite3 db/ontology.sqlite3

```

---

```text
HACK THE PLANET!
    M. Sugaya

```
