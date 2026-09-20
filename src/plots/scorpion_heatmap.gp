# -------------------------------------------------------------
# Gnuplot Script: USS Scorpion Search Prior Heatmap
# -------------------------------------------------------------
set terminal cairolatex pdf size 12cm, 7.5cm font ",10"
set output "build/plots/scorpion_prior_heatmap.tex"

# --- 軸・マージン・レイアウト設定 ---
set title "USS Scorpion Search: Prior Distribution (Figure 2)" font ",11"
set xlabel "East-West Grid" offset 0,-0.3
set ylabel "North-South Grid" offset -0.5,0

# 列 (A〜Q = 1〜17)
set xrange [0.5:17.5]
set xtics ("A" 1, "B" 2, "C" 3, "D" 4, "E" 5, "F" 6, "G" 7, "H" 8, "I" 9, "J" 10, "K" 11, "L" 12, "M" 13, "N" 14, "O" 15, "P" 16, "Q" 17) nomirror out scale 0.5

# 行 (1〜14, 上側を行1にするため reverse)
set yrange [0.5:14.5] reverse
set ytics 1,1,14 nomirror out scale 0.5

# --- カラーパレット設定 ---
set palette defined ( \
  0.0 "#ffffff", \
  0.5 "#e0ecf4", \
  2.0 "#9ebcda", \
  5.0 "#8856a7", \
  12.5 "#810f7c" \
)

set cbrange [0:13]
set cblabel "Prior Probability (\\%)" offset 1,0
set cbtics 0,2,12 scale 0.5

# グリッド線の明示
set grid front linetype 1 linecolor rgb "#dddddd" linewidth 0.5

# スコーピオンの実際の発見位置 (セル F6: X=6, Y=6)
set label 1 "\\Large $\\star$" at 6, 6 center front textcolor rgb "#d95f02"

# --- プロット実行 ---
# 1. with image で全格子を描画
# 2. 確率 1.0% 以上の主要セルのみ数値を中央に印字
plot "src/plots/scorpion_points.dat" using 1:2:4 with image notitle, \
     "src/plots/scorpion_points.dat" using 1:2:($4 >= 1.0 ? sprintf("%.1f", $4) : "") with labels center font ",6.5" textcolor rgb "#111111" notitle