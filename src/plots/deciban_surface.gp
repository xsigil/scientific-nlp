# ==============================================================================
# Deciban Weight of Evidence 3D Surface Plot
# z = 10 * log10( P(D | H) / P(D | \neg H) )
# ==============================================================================

# LuaLaTeX連携用 terminal 設定
set terminal cairolatex pdf size 12cm, 9cm font ",10"
set output "build/plots/deciban_surface.tex"

# スタイル・視点設定
set title "チューリングの証拠の重み（デシバン $W$）の3次元曲面"
set view 60, 125, 1, 1       # 視点の仰角・方位角
set isosamples 40, 40        # メッシュの細かさ
set hidden3d                 # 陰線消去（裏側の線を隠す）

# 軸範囲（0の対数発散・ゼロ割りを防ぐため微小値 epsilon から 1.0 まで）
eps = 0.01
set xrange [eps:1.0]
set yrange [eps:1.0]
set zrange [-30:30]          # 表示するデシバン範囲 [-30db, +30db]

# 軸ラベル（LaTeX記法）
set xlabel "$P(D \\mid H)$" rotate parallel offset 0,-1
set ylabel "$P(D \\mid \\neg H)$" rotate parallel offset 0,-1
set zlabel "デシバン $W$ [db]" rotate parallel offset -1,0

# カラーパレット設定（寒色=反証/負, 暖色=確証/正）
set pm3d at s                # サーフェス上にカラーマップを投影
set palette defined (-30 "#2b83ba", 0 "#ffffbf", 30 "#d7191c")
set colorbox
set cbrange [-30:30]
set cblabel "$W$ [db]"

# 関数定義
W(x, y) = 10.0 * (log10(x) - log10(y))

# プロット実行
splot W(x, y) with pm3d notitle
