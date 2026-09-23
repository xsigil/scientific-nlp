# LaTeX Macro Coding Standard: Namespace & Prefix Conventions

This standard defines a macro naming scheme designed for large-scale academic books and mathematical monographs (Book class)[cite: 1]. It prevents identifier collisions in the global TeX scope while maximizing discoverability and efficiency via Vim completion (`<C-n>` / `<C-p>`), `ctags`, and `ripgrep` (`rg`)[cite: 1].

---

## 1. Core Principles

1. **Global Namespace Pollution Prevention**  
   Since standard TeX macro names consist exclusively of alphabetical characters (`[A-Za-z]`), explicit semantic camelCase prefixes are mandatory to eliminate naming collisions with package-level commands[cite: 1].
2. **Keystroke & Completion Optimization**  
   Typing a short prefix (3–4 characters) followed by the editor's auto-completion trigger immediately narrows the candidate list to the designated semantic scope[cite: 1].
3. **Symmetry Between Math & Natural Language**  
   For any single conceptual entity, bind its mathematical symbol, English textual form, Japanese translation, abbreviated acronym, and expanded formal name to a unified base identifier[cite: 1].

---

## 2. Prefix Hierarchy

| Prefix | Classification / Role | Semantics & Purpose | Examples | Rendered Output (Target) |
| :--- | :--- | :--- | :--- | :--- |
| `\mth...` | **Mathematical Glyph / Operator** | Mathematical models, operators, symbols (math-mode context) | `\mthWholeSelf`<br>`\mthWheel` | $\WholeSelf$<br>$\mathcal{T}_{\text{wheel}}$ |
| `\txt...` | **Standard Concept Text** | Standard English concept names and proper nouns in prose | `\txtSNLP`<br>`\txtWholeSelf` | Scientific NLP™<br>WholeSelf |
| `\ja...` | **Japanese Terminology** | Japanese canonical terminology, glossaries, translations | `\jaWholeSelf`<br>`\jaWheel` | 全体自己<br>六道車輪 |
| `\abbr...` | **Abbreviation / Acronym** | Acronyms and shorthand tokens (tables, inline abbreviations) | `\abbrNLP`<br>`\abbrDAG` | NLP<br>DAG |
| `\full...` | **Expanded / Formal Text** | Fully expanded formal names (definitions, title pages) | `\fullSNLP`<br>`\fullNLP` | Scientific Neuro-Linguistic Programming<br>Neuro-Linguistic Programming |

---

## 3. Macro Definition Patterns (`macros.tex`)

Define orthogonal macros for the same conceptual entity (e.g., `WholeSelf`) using distinct prefixes[cite: 1]:

```latex
% ====================================================================
% Concept: WholeSelf
% ====================================================================
% 1. Mathematical Symbol
%    Encapsulates \mathord, \vcenter, and \raisebox for inline math placement.
\newcommand{\mthWholeSelf}{%
  \mathord{%
    \raisebox{-0.15ex}{%
      \vcenter{\hbox{%
        \includegraphics[height=2.0ex, keepaspectratio]{src/images/Ouroboros.pdf}%
      }}%
    }%
  }%
}

% 2. Standard Concept Text
\newcommand{\txtWholeSelf}{WholeSelf\xspace}

% 3. Japanese Terminology
\newcommand{\jaWholeSelf}{全体自己\xspace}


% ====================================================================
% Concept: Scientific NLP
% ====================================================================
% 1. Standard Text (eliminates typographical inconsistency)
\newcommand{\txtSNLP}{Scientific NLP\texttrademark\xspace}

% 2. Abbreviation
\newcommand{\abbrSNLP}{S-NLP\xspace}

% 3. Fully Expanded Formal Name
\newcommand{\fullSNLP}{Scientific Neuro-Linguistic Programming\xspace}

```

> **Note:** Always append `\xspace` from the `xspace` package to prose-oriented macros (`\txt...`, `\ja...`, `\abbr...`, `\full...`) to prevent TeX from silently swallowing trailing whitespace.
> 
> 

---

## 4. Usage in Chapter Sources (`chapters/*.tex`)

```latex
\chapter{Foundations of \txtWholeSelf}

The concept of \fullSNLP (\abbrSNLP) formalizes the observer loop.
In Japanese philosophy, this corresponds to \jaWholeSelf.

Within the probabilistic state space, we define the deterministic prior:
\begin{equation}
  P(\mthWholeSelf \mid \mathcal{D}) = \frac{P(\mathcal{D} \mid \mthWholeSelf) P(\mthWholeSelf)}{P(\mathcal{D})}
\end{equation}

```

---

## 5. Editor & CLI Toolchain Integration

### (1) Vim / Neovim Keystroke Flow

* **Math Mode:** Type `\mth` followed by `<C-n>` $\to$ displays only registered math glyphs.


* **Terminology Check:** Type `\ja` followed by `<C-n>` $\to$ displays only Japanese vocabulary equivalents.



### (2) Symbol Navigation with `ripgrep`

```bash
# Locate exact occurrences of WholeSelf used as a math symbol
rg '\\mthWholeSelf\b' src/chapters/

# Locate textual occurrences of WholeSelf in body prose
rg '\\txtWholeSelf\b' src/chapters/

```

### (3) Regex Configuration for Universal Ctags (`~/.ctags.d/latex.ctags`)

Tag extraction pattern for prefixed macros:

```text
--langdef=latex
--map-latex=+.tex
--kinddef-latex=m,macro,macros
--regex-latex=/\\(?:newcommand|def)\{\\([A-Za-z]+)\}/\1/m,macro/

```
