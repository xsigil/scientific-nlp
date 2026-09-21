divert(-1)
# ==========================================================================
# CRT（Current Reality Tree）構文用 カラーパレット
# ==========================================================================
define(`COLOR_BG_TRANSPARENT', `"transparent"')
define(`COLOR_CLUSTER_BORDER', `"#BDC3C7"')

define(`COLOR_ROOT_BG',        `"#D5F5E3"')  # 根本原因 / Root Cause (淡緑)
define(`COLOR_ROOT_BORDER',    `"#2ECC71"')
define(`COLOR_INT_BG',         `"#FCF3CF"')  # 中間エンティティ (淡黄)
define(`COLOR_INT_BORDER',     `"#F1C40F"')
define(`COLOR_UDE_BG',         `"#FADBD8"')  # 望ましくない結果 / UDE (淡赤)
define(`COLOR_UDE_BORDER',     `"#E74C3C"')

define(`COLOR_AND_BG',         `"#EAEDED"')  # AND結合ノード (淡灰)
define(`COLOR_AND_BORDER',     `"#7F8C8D"')

# ==========================================================================
# ノード生成マクロ
# ==========================================================================
# CRT_NODE_ROOT(id, "ラベル")
define(`CRT_NODE_ROOT',
    `$1 [label=$2, fillcolor=COLOR_ROOT_BG, color=COLOR_ROOT_BORDER]')

# CRT_NODE_INTERMEDIATE(id, "ラベル")
define(`CRT_NODE_INTERMEDIATE',
    `$1 [label=$2, fillcolor=COLOR_INT_BG, color=COLOR_INT_BORDER]')

# CRT_NODE_UDE(id, "ラベル")
define(`CRT_NODE_UDE',
    `$1 [label=$2, fillcolor=COLOR_UDE_BG, color=COLOR_UDE_BORDER]')

# CRT_NODE_AND(id)
define(`CRT_NODE_AND',
    `$1 [shape=ellipse, label="AND", width=0.4, height=0.2, fontsize=7, style="filled", fillcolor=COLOR_AND_BG, color=COLOR_AND_BORDER]')

# クラスタ枠スタイル
define(`CRT_CLUSTER_STYLE',
    `style = dotted;
    color = COLOR_CLUSTER_BORDER;')

divert(0)dnl
