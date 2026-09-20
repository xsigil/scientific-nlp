# -------------------------------------------------------------
# Gnuplot Script: BH3P™ Temporal Decay & Consolidation Dynamics
# -------------------------------------------------------------
set terminal cairolatex pdf size 12cm, 7.5cm font ",10"
set output "build/plots/bh3p_temporal_decay.tex"

# スタイル・グリッド設定
set grid lc rgb "#d0d0d0" lt 1 lw 0.8
set samples 1000
set xrange [0:14]      # 時間軸（日数）
set yrange [0:1.1]

# 軸ラベル・目盛り（LaTeX 記法）
set xlabel "経過時間 $t$ (日) [Time Elapsed / Days]" offset 0, -0.5
set ylabel "正規化ポテンシャル [Normalized Potential]" offset -0.5, 0
set xtics 1
set ytics 0.2

# -------------------------------------------------------------
# 関数定義
# -------------------------------------------------------------
# 1. エピソード記憶・警戒電位 T(t): 半減期 τ_defense ≈ 1.5日
tau_T = 1.5
T(x) = exp(-x / tau_T)

# 2. スヌープ・オセロ知見の無意識コンソリデーション C(t):
#    一旦潜在化し、内発的信念として定着するロジスティック結合
C(x) = (1.0 / (1.0 + exp(-(x - 2.5) / 1.0))) * 0.85

# 3. 防衛起動閾値 θ_defense (安全境界線)
theta = 0.20

# -------------------------------------------------------------
# 領域・境界線の描画
# -------------------------------------------------------------
# 安全介入ウィンドウ (Day 4.0 〜 Day 10.0) の網掛け
set object 1 rect from 4.0, 0 to 10.0, 1.05 \
    fc rgb "#e6e6e6" fillstyle solid 0.5 noborder behind

# 閾値ライン
set arrow 1 from 0, theta to 14, theta nohead lc rgb "#707070" dt 2 lw 1.5

# ラベル配置（LaTeX 記法）
set label 1 '\shortstack[l]{Danger Zone\\(Direct Observation Alert: $T \gg \theta$)}' at 1.2, 0.75 font ",8.5" tc rgb "#333333"
set label 2 '\shortstack[c]{Safe Intervention Window\\(BH3P Active Execution Phase)}' at 7.0, 0.95 center font ",8.5" tc rgb "#111111"
set label 3 'Defense Threshold ($\theta_{\mathrm{defense}}$)' at 10.2, theta + 0.04 font ",8.5" tc rgb "#555555"

# -------------------------------------------------------------
# プロット実行
# -------------------------------------------------------------
set key top right spacing 1.3 box lc rgb "#aaaaaa"

plot \
    T(x) title '警戒電位 / エピソード記憶 $T(t) = \mathrm{e}^{-t/\tau}$' w lines lc rgb "#000000" lw 2.2, \
    C(x) title '無意識コンソリデーション $C(t)$ (内発的信念化)' w lines lc rgb "#555555" dt 4 lw 2.0
