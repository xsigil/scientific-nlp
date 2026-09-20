#ifndef TOC_NODES_H
#define TOC_NODES_H

/* 色・スタイルのパレット定義 */
#define COLOR_FOUNDATION   "#e2e8f0"  /* 00: 基盤・物理層（スレートグレー） */
#define COLOR_BOUNDING     "#fef3c7"  /* 01: 事前拘束（アンバー） */
#define COLOR_PASSIVE      "#e0f2fe"  /* 02: 受動観測（シアン） */
#define COLOR_ACTIVE       "#fee2e2"  /* 03: 能動介入（ローズ） */
#define COLOR_CORE         "#f3e8ff"  /* 04: BTPコア（パープル） */

/* ノード描画マクロ */
#define DEFINE_CHAPTER(id, num, name, col) \
    id [shape=box, style="filled,rounded", fillcolor=col, penwidth=1.5, \
        label=<<B>Chapter num</B><BR/><FONT POINT-SIZE="10">name</FONT>>]

/* 共通ノードIDと名称の完全マッピング（TOC同期） */
#define NODE_CH01(id) DEFINE_CHAPTER(id, "01", "Paradigm Shift to L1", COLOR_FOUNDATION)
#define NODE_CH02(id) DEFINE_CHAPTER(id, "02", "Boundary Conditions & Integrity", COLOR_FOUNDATION)
#define NODE_CH03(id) DEFINE_CHAPTER(id, "03", "Pre-Profiling (Fermi)", COLOR_BOUNDING)
#define NODE_CH04(id) DEFINE_CHAPTER(id, "04", "Bayesian Vision™ Engine", COLOR_PASSIVE)
#define NODE_CH05(id) DEFINE_CHAPTER(id, "05", "Deciban Mental Arithmetic", COLOR_PASSIVE)
#define NODE_CH06(id) DEFINE_CHAPTER(id, "06", "Orthogonal Probing™", COLOR_ACTIVE)
#define NODE_CH07(id) DEFINE_CHAPTER(id, "07", "BTP Double-Loop State Machine", COLOR_CORE)

#endif
