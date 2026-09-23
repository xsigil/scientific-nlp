# LaTeX Macro Coding Standard: Namespace & Prefix Convention

本規約は、長編の学術書・数理モノグラフ（Bookクラス）においてグローバルスコープによる識別子の衝突を防ぎ、Vim補完（`<C-n>` / `<C-p>`）、`ctags`、および `ripgrep`（`rg`）による検索性を最大化するためのマクロ命名体系である。

---

## 1. コア原則

1. **グローバル汚染の防止**
TeX のマクロ名は原則として英字のみ（`[A-Za-z]`）で構成されるため、キャメルケースのセマンティック・プレフィックスを必須とし、パッケージ標準コマンドとの衝突をゼロにする。
2. **打鍵補完の最適化**
プレフィックス（3〜4文字）を入力した直後にエディタの補完トリガーを叩くことで、候補をスコープ別に即座に絞り込む。
3. **数理と自然言語の対称性**
1つの概念（Concept）に対し、数式表現・英語表記・日本語対訳・略称・正式名称を同一のキー名でバインド可能にする。

---

## 2. プレフィックス体系一覧

| プレフィックス | 分類 / 役割 | 用途・セマンティクス | 記述例 | 展開結果のイメージ |
| --- | --- | --- | --- | --- |
| `\mth...` | **Mathematical Glyph / Operator** | 数理モデル・演算子・記号（数式モード前提） | `\mthWholeSelf`<br>

<br>`\mthWheel` | $\WholeSelf$<br>

<br>$\mathcal{T}_{\text{wheel}}$ |
| `\txt...` | **Standard Concept Text** | 本文中の標準的な概念名・英字固有名詞 | `\txtSNLP`<br>

<br>`\txtWholeSelf` | Scientific NLP™<br>

<br>WholeSelf |
| `\ja...` | **Japanese Terminology** | 日本語の定型表現・術語・対訳 | `\jaWholeSelf`<br>

<br>`\jaWheel` | 全体自己<br>

<br>六道車輪 |
| `\abbr...` | **Abbreviation / Acronym** | 略称・頭字語（本文・表での省略表記用） | `\abbrNLP`<br>

<br>`\abbrDAG` | NLP<br>

<br>DAG |
| `\full...` | **Expanded / Formal Text** | 初出時の正式名称・完全表記（定義・扉絵用） | `\fullSNLP`<br>

<br>`\fullNLP` | Scientific Neuro-Linguistic Programming<br>

<br>Neuro-Linguistic Programming |

---

## 3. マクロ定義の実装パターン (`macros.tex`)

同一概念（例: `WholeSelf`）に対して、各プレフィックスを用いて直交するように定義する。

```latex
% ====================================================================
% Concept: WholeSelf
% ====================================================================
% 1. 数式記号 (Mathematical Symbol)
%    ※ 内部で \mathord や \vcenter, \raisebox を隠蔽し、数式内で直接展開可能にする
\newcommand{\mthWholeSelf}{%
  \mathord{%
    \raisebox{-0.15ex}{%
      \vcenter{\hbox{%
        \includegraphics[height=2.0ex, keepaspectratio]{src/images/Ouroboros.pdf}%
      }}%
    }%
  }%
}

% 2. 英語表記 (Standard Concept Text)
\newcommand{\txtWholeSelf}{WholeSelf\xspace}

% 3. 日本語対訳 (Japanese Terminology)
\newcommand{\jaWholeSelf}{全体自己\xspace}


% ====================================================================
% Concept: Scientific NLP
% ====================================================================
% 1. 標準テキスト (表記揺れ防止)
\newcommand{\txtSNLP}{Scientific NLP\texttrademark\xspace}

% 2. 略称
\newcommand{\abbrSNLP}{S-NLP\xspace}

% 3. 正式名称 (展開表記)
\newcommand{\fullSNLP}{Scientific Neuro-Linguistic Programming\xspace}

```

> **Note:** テキスト系マクロ（`\txt...`, `\ja...`, `\abbr...`, `\full...`）の末尾には `xspace` パッケージの `\xspace` を付与し、マクロ直後のスペースが TeX の仕様で消失するのを防ぐ。

---

## 4. 本文中での使用例 (`chapters/*.tex`)

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

## 5. エディタ・CLI統合

### (1) Vim / Neovim 打鍵パターン

* **数式入力時:** `\mth` と入力して `<C-n>` $\to$ 登録済み数式マクロのみが候補表示。
* **対訳確認時:** `\ja` と入力して `<C-n>` $\to$ 術語一覧が候補表示。

### (2) `ripgrep` によるシンボル探索

```bash
# 数式記号としての WholeSelf の出現箇所のみを完全一致で探索
rg '\\mthWholeSelf\b' src/chapters/

# テキストとしての WholeSelf の出現箇所を探索
rg '\\txtWholeSelf\b' src/chapters/

```

### (3) `~/.ctags.d/latex.ctags` の正規表現対応

プレフィックス付きマクロを ctags に拾わせるためのルール：

```text
--langdef=latex
--map-latex=+.tex
--kinddef-latex=m,macro,macros
--regex-latex=/\\(?:newcommand|def)\{\\([A-Za-z]+)\}/\1/m,macro/

```
