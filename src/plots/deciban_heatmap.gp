# ==============================================================================
# Deciban Weight of Evidence 2D Heatmap & Contour Plot
# W = 10 * log10( P(D | H) / P(D | \neg H) )
# ==============================================================================

set terminal cairolatex pdf size 11cm, 8.5cm font ",9.5"
set output "build/plots/deciban_heatmap.tex"

# マップ視点（完全な2次元真上視点）
set view map
set size square

# サンプリング密度（等高線とグラデーションを滑らかに描画）
set isosamples 100, 100

# 軸範囲（ゼロ割りと対数発散防止のため微小値 eps から 1.0）
eps = 0.02
set xrange [eps:1.0]
set yrange [eps:1.0]

# 軸ラベル（LaTeX記法）
set xlabel "$P(D \\mid H)$" offset 0,-0.5
set ylabel "$P(D \\mid \\neg H)$" offset -0.5,0

# カラーパレット（負: 青 = 反証 / 0: 白 = 中立 / 正: 赤 = 確証）
# 彩度を抑えた印刷向きのカラーグラデーション
set palette defined ( \
  -30 "#2b83ba", \
  -10 "#abd9e9", \
    0 "#ffffbf", \
   10 "#fdae61", \
   30 "#d7191c"  \
)
set cbrange [-30:30]
set cblabel "証拠の重み $W$ [db]" offset 1,0

# 等高線（Contour）の設定
set contour base
set cntrparam bspline
set cntrparam levels discrete -20, -10, -3, 0, 3, 10, 20
set cntrlabel onecolor format "%.0f db" font ",7.5"
unset clabel                 # 等高線の凡例を別枠で出さずマップ上に直接保持

# 関数定義
W(x, y) = 10.0 * (log10(x) - log10(y))

# プロット実行
# 1段目: ヒートマップ面（pm3d map）
# 2段目: 対角線（W = 0 db の中立線・情報量ゼロ）
set pm3d at b explicit
splot W(x, y) with pm3d notitle, \
      x with lines lc rgb "#333333" dt 2 lw 1 title "中立線 ($W=0\\,\\mathrm{db}$)"
