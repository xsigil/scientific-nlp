#ifndef TOC_NODES_H
#define TOC_NODES_H

/* ==========================================================================
 * CRT（Current Reality Tree）構文用 カラーパレット
 * ========================================================================== */
#define COLOR_BG_TRANSPARENT "transparent"
#define COLOR_CLUSTER_BORDER "#BDC3C7"

/* ノード背景色・境界色 */
#define COLOR_ROOT_BG        "#D5F5E3"  /* 根本原因 / Root Cause (淡緑) */
#define COLOR_ROOT_BORDER    "#2ECC71"
#define COLOR_INT_BG         "#FCF3CF"  /* 中間エンティティ / Intermediate (淡黄) */
#define COLOR_INT_BORDER     "#F1C40F"
#define COLOR_UDE_BG         "#FADBD8"  /* 望ましくない結果 / UDE (淡赤) */
#define COLOR_UDE_BORDER     "#E74C3C"

#define COLOR_AND_BG         "#EAEDED"  /* AND結合ノード (淡灰) */
#define COLOR_AND_BORDER     "#7F8C8D"

/* ==========================================================================
 * ノード生成マクロ
 * ========================================================================== */
/* 根本原因 / Root Cause / 十分原因 (緑) */
#define CRT_NODE_ROOT(id, txt) \
    id [label=txt, fillcolor=COLOR_ROOT_BG, color=COLOR_ROOT_BORDER]

/* 中間エンティティ / 状態遷移 / 結果 (黄) */
#define CRT_NODE_INTERMEDIATE(id, txt) \
    id [label=txt, fillcolor=COLOR_INT_BG, color=COLOR_INT_BORDER]

/* 望ましくない結果 / UDE (赤) */
#define CRT_NODE_UDE(id, txt) \
    id [label=txt, fillcolor=COLOR_UDE_BG, color=COLOR_UDE_BORDER]

/* AND論理結合楕円ノード */
#define CRT_NODE_AND(id) \
    id [shape=ellipse, label="AND", width=0.4, height=0.2, fontsize=7, \
        style="filled", fillcolor=COLOR_AND_BG, color=COLOR_AND_BORDER]

/* クラスタ（サブグラフ枠）スタイル */
#define CRT_CLUSTER_STYLE \
    style = dotted; \
    color = COLOR_CLUSTER_BORDER

#endif /* TOC_NODES_H */
