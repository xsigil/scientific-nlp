# Ontology Data Layer (`db/`)

This directory serves as the persistent data storage layer hosting the conceptual and mathematical ontology of *Scientific NLP*.

Rejecting the bloated, opaque, and extortionate "cloud enterprise ontologies" peddled by legacy consultancies, this project adopts a **fully embedded, deterministic architecture executed locally within a POSIX environment on a single machine**.

---

## 1. Epistemological Foundation: Why SQLite3 and KùzuDB?

Intellectual sovereignty must never be ceded to proprietary cloud platforms or subscription SaaS.
This book is not written as a conventional "manuscript"—it is designed as **software deterministically compiled in milliseconds from structured local knowledge**.

- **Deterministic Relational Metadata (SQLite3)**
  - Manages static relational integrity across typography, attributions, epigraphs, trademarks, and chapter hierarchies inside `ontology.db`.
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
├── ontology.sqlite3       # SQLite3: Relational ontology database
├── ontology.kuzu/         # KùzuDB: Property graph storage directory
├── schema.sql             # SQLite DDL (table schemas)
├── seed.example.sql       # Public baseline seeds (epigraphs, bibliography)
├── seed/                  # [Private / .gitignored] Surgical epistemic seed corpus
├── graph_schema.cypher    # KùzuDB schema definitions
└── README.md              # This specification
```

---

## 3. Data Models

### A. Relational Layer (`ontology.db`)

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

HACK THE PLANET!
    M. Sugaya
