# Ontology Data Layer (`db/`)

This directory serves as the persistent data storage layer hosting the conceptual and mathematical ontology of *Scientific NLP*.

Rejecting the bloated, opaque, and extortionate "cloud enterprise ontologies" peddled by legacy consultancies, this project adopts a **fully embedded, deterministic architecture executed locally within a POSIX environment on a single machine**.

---

## 1. Epistemological Foundation: Why SQLite3 and KùzuDB?

Intellectual sovereignty must never be ceded to proprietary cloud platforms or subscription SaaS.
This book is not written as a conventional "manuscript"—it is designed as **software deterministically compiled in milliseconds from structured local knowledge**.

- **Deterministic Relational Metadata (SQLite3)**
  - Manages static relational integrity across typography, attributions, epigraphs, trademarks, and chapter hierarchies inside `ontology.sqlite3`.
  - Delivers ACID transactional guarantees, sub-millisecond query latency, and zero-configuration portability.
- **Topological Causal Graphs and Multi-Loop Feedback (KùzuDB)**
  - Dynamic feedback mechanisms, Bayesian Double-Loop Learning (BDLL), and non-ergodic absorbing barriers cannot be expressed cleanly in flat relational tables. They are modeled as a property graph in KùzuDB.
  - Serverless and embedded with a DuckDB-like columnar storage engine, enabling local Cypher queries for causal traversal and consistency verification with minimal footprint.
- **Direct Runtime Injection into Typesetting Engine (LuaLaTeX)**
  - Eliminates intermediate files, manual conversions, and fragile copy-pasting. During compilation, the internal Lua runtime directly queries these embedded databases and injects the resulting records straight into the TeX token stream.

---

## 2. Directory Architecture

```text
db/
├── ontology.sqlite3        # SQLite3: Relational ontology database
├── ontology.kuzu/          # KùzuDB: Property graph storage directory
├── schema.sql              # SQLite DDL (table schemas)
├── seed.example.sql        # Public baseline seeds (epigraphs, bibliography)
├── seed/                   # [Private / .gitignored] Surgical epistemic seed corpus
├── graph_schema.cypher     # KùzuDB schema definitions
└── README.md               # This specification

```

---

## 3. Data Models

### A. Relational Layer (`ontology.sqlite3`)

* **`epigraphs`**: Cognitive anchors introducing each chapter (storing academic literature and subversive anime quotes on an equal footing).
* **`references_db`**: External observational models and bibliography metadata, tracking domains, tags, and empirical conviction levels.
* **`terms`**: Canonical mathematical definitions of terms redefined throughout the book (CBO, BDLL, Bayesian Vision, etc.).
* **`epistemic_notes`**: Internal design axioms, hacker protocols, and uncurated empirical observations of the observer.

### B. Graph Causal Layer (`graph/` — KùzuDB)

Maintains directed acyclic and cyclic dependency graphs linking chapters, mathematical algorithms, biochemical operators, and absorbing barriers.

```cypher
// Example: Conceptual topology definition
(:Chapter {id: "ch08"})
  -[:IMPLEMENTS]-> (:Algorithm {name: "BDLL"})
  -[:MODULATES]-> (:Operator {name: "CBO"})
  -[:AVOIDS]-> (:Barrier {type: "Absorbing", property: "Ruin"});

```

---

## 4. Build Pipeline (Data -> Engine -> PDF)

```text
[ SQLite3 (ontology.sqlite3) ] \
                                ==> [ src/lua/ontology_bridge.lua ] ==> [ LuaLaTeX ] ==> [ PDF ]
[ KùzuDB (ontology.kuzu/)    ] /         (In-process Query)           (Typesetting)

```

---

## 5. Hacker's Protocol: Surgical Data Operations via POSIX & Vim

This knowledge layer rejects bloated GUI clients, heavyweight ORM migrators, and sluggish language runtimes.
By treating the database CLI as a standard stream filter, you can manipulate knowledge with zero dependencies and millisecond latency.

### 1. Direct Buffer Execution from Vim

You do not need to leave your editor or even save the file to update the ontology.
Within Vim, inspect your line numbers (`:set number`) and pipe arbitrary ranges directly into the SQLite binary:

```vim
" Write lines 4 to 5 directly into the SQLite stdin
:4,5w ! sqlite3 ontology.sqlite3

" Or visually select a block (V) and pipe the selection:
:'<,'>w ! sqlite3 ontology.sqlite3

```

### 2. Surgical Injection via `sed` Pipeline

To inject specific records from partial seed files without evaluating the entire corpus:

```bash
# Extract exactly lines 20 to 35 and stream them directly into the engine
sed -n '20,35p' db/seed/epistemic_notes.sql | sqlite3 db/ontology.sqlite3

```

### 3. Radar-and-Scalpel: Search and Apply with `grep`

Find the exact coordinates and surrounding context of an axiom, then surgically apply it:

```bash
# Step 1 (Radar): Locate target term with context, filename, and line numbers
grep -r -n -H -A 4 -B 4 "bio-cybernetics" db/seed/

# Step 2 (Scalpel): Target the identified lines and inject
sed -n '12,30p' db/seed/99_observables.sql | sqlite3 db/ontology.sqlite3

```

### 4. Deterministic Batch Hydration

To re-initialize the entire local state, rely on standard shell globbing rather than complex orchestration scripts:

```bash
cat db/seed/*.sql | sqlite3 db/ontology.sqlite3

```

> **Pedagogical Axiom:**
> The computer is not a collection of fragmented apps designed to restrict your agency.
> Every process is an input/output filter connected by pipelines. Master the stream, and you master the machine.

---

## 6. In-Process Ontology Hydration Protocol (`src/lua/ontology_bridge.lua`)

This architecture completely eliminates external processes (such as spawning subshells or generating intermediate files). Instead, it queries `ontology.sqlite3` in-process directly from the Lua runtime embedded within LuaLaTeX, hydrating the TeX token stream in real time.

Rather than relying on static bindings tied to fixed chapter identifiers (`chapter_id`), this protocol supports fuzzy matching (`LIKE`) across quotations and translations, as well as author-scoped filtering tailored to the conceptual context.

### 1. LuaLaTeX Interface Specification (`src/lua/ontology_bridge.lua`)

```lua
-- src/lua/ontology_bridge.lua
local luasql = require('luasql.sqlite3')
local env = luasql.sqlite3()
local db_path = "db/ontology.sqlite3"

local function get_db()
    return env:connect(db_path)
end

-- Helper: Format and emit an epigraph via tex.print
local function render_epigraph(row)
    local cite = row.attribution
    if row.source and row.source:match("%S") then
        cite = cite .. ", \\textit{" .. row.source .. "}"
    end

    if row.translation and row.translation:match("%S") then
        tex.print(string.format("\\ChapterEpigraphWithTranslation{%s}{%s}{%s}", 
            row.quote, row.translation, cite))
    else
        tex.print(string.format("\\ChapterEpigraph{%s}{%s}", 
            row.quote, cite))
    end
end

-- =============================================================================
-- Epigraph Flexible Query Engine
-- opt = {
--     word = "street",           -- Substring match against quote or translation
--     author = "Gibson",         -- Substring match against attribution
--     allow_multiple = true      -- Whether to render all matches (false raises a warning)
-- }
-- =============================================================================
function QueryEpigraph(opt)
    opt = opt or {}
    local con = get_db()
    local where_clauses = {}
    
    -- Substring search (matches either quote or translation)
    if opt.word and opt.word:match("%S") then
        local w = con:escape(opt.word)
        table.insert(where_clauses, string.format("(quote LIKE '%%%s%%' OR translation LIKE '%%%s%%')", w, w))
    end

    -- Author-scoped search (matches attribution)
    if opt.author and opt.author:match("%S") then
        local a = con:escape(opt.author)
        table.insert(where_clauses, string.format("attribution LIKE '%%%s%%'", a))
    end

    -- Guard: Prevent unbounded full-table scans
    if #where_clauses == 0 then
        tex.print("\\textbf{[Epigraph Error: No search criteria specified.]}")
        con:close()
        return
    end

    local sql = string.format([[
        SELECT id, quote, translation, attribution, source 
        FROM epigraphs 
        WHERE %s
        ORDER BY id ASC;
    ]], table.concat(where_clauses, " AND "))

    local cur = con:execute(sql)
    local rows = {}
    local row = cur:fetch({}, "a")
    while row do
        table.insert(rows, row)
        row = cur:fetch({}, "a")
    end
    cur:close()
    con:close()

    local count = #rows

    -- Case 1: Zero hits (fail-safe notification)
    if count == 0 then
        local desc = string.format("word='%s', author='%s'", opt.word or "", opt.author or "")
        texio.write_nl(string.format("--> [DB Warning] Epigraph not found: %s", desc))
        tex.print(string.format("\\textbf{\\color{red}[Epigraph Not Found: %s]}", desc))
        return
    end

    -- Case 2: Multiple hits (strict mode verification)
    local allow_multi = (opt.allow_multiple == nil) or (opt.allow_multiple == true)
    if count > 1 and not allow_multi then
        local warn_msg = string.format("Multiple epigraphs (%d) matched query. Set allow_multiple=true to render all.", count)
        texio.write_nl("--> [DB Ambiguity Warning] " .. warn_msg)
        tex.print(string.format("\\textbf{\\color{orange}[Epigraph Query Ambiguous: %s]}", warn_msg))
        return
    end

    -- Case 3: Token stream injection
    for _, r in ipairs(rows) do
        render_epigraph(r)
    end
end

```

---

### 2. LaTeX Macro Definitions (`src/preamble/macros.tex`)

Wrapper macros designed for near-zero-latency invocation from manuscripts:

```latex
% \QueryEpigraph[author]{word}
% Expands all matched records sequentially
\newcommand{\QueryEpigraph}[2][]{%
  \directlua{QueryEpigraph({word = "#2", author = "#1", allow_multiple = true})}%
}

% Single-match enforcement (warns on terminal logs and output pages if ambiguous)
\newcommand{\QueryStrictEpigraph}[2][]{%
  \directlua{QueryEpigraph({word = "#2", author = "#1", allow_multiple = false})}%
}

```

---

### 3. Operational Patterns in Manuscript

#### A. Flexible Keyword Lookup (Full Sequence Expansion)

```latex
\chapter*{Prologue}
% Hydrates all records containing "street" in quote or translation
\QueryEpigraph{street}

```

#### B. Precision Author-Targeted Lookup

```latex
\chapter{The Illusion of Free Will and Reality}
% Targets only Bandler's statements containing "freedom"
\QueryEpigraph[Bandler]{Freedom}

```

#### C. Fault Tolerance & Visual Error Feedback

* **Zero matches**: Does not break the compilation process (crash-safe). Prints an explicit red marker `[Epigraph Not Found: ...]` on the rendered page and logs `--> [DB Warning]` into `build/*.log`.
* **Ambiguous matches (Strict mode)**: Prints an orange warning when multiple entries collide, preventing accidental layout distortion.

---

```text
HACK THE PLANET!
    M. Sugaya
```
