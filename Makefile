# 設定パラメータ
MAIN        := the_seed_of_magic
SRC_DIR     := src
BUILD_DIR   := build

DOT_SRC_DIR := $(SRC_DIR)/dot
DOT_OUT_DIR := $(BUILD_DIR)/dot

GP_SRC_DIR  := $(SRC_DIR)/plots
GP_OUT_DIR  := $(BUILD_DIR)/plots

TARGET      := $(SRC_DIR)/$(MAIN).tex
OUTPUT_PDF  := $(BUILD_DIR)/$(MAIN).pdf

# 依存ソースおよび生成ファイル定義
DOT_SRCS    := $(wildcard $(DOT_SRC_DIR)/*.dot)
DOT_PDFS    := $(patsubst $(DOT_SRC_DIR)/%.dot,$(DOT_OUT_DIR)/%.pdf,$(DOT_SRCS))

GP_SRCS     := $(wildcard $(GP_SRC_DIR)/*.gp)
GP_TEXS     := $(patsubst $(GP_SRC_DIR)/%.gp,$(GP_OUT_DIR)/%.tex,$(GP_SRCS))

# コンパイルコマンド
LATEXMK     := latexmk -lualatex -outdir=$(BUILD_DIR) -interaction=nonstopmode -synctex=1
DOT         := dot
GNUPLOT     := gnuplot

.PHONY: all clean distclean watch dot_figs plot_figs

# デフォルトターゲット: DOT図版とGnuplot出力を生成した後にメインPDFをコンパイル
all: $(OUTPUT_PDF)

# メインPDFの依存関係
$(OUTPUT_PDF): $(TARGET) $(DOT_PDFS) $(GP_TEXS)
	@mkdir -p $(BUILD_DIR)
	$(LATEXMK) $(TARGET)

# 図版個別生成ターゲット
dot_figs: $(DOT_PDFS)
plot_figs: $(GP_TEXS)

# --- Graphviz 変換ルール (.dot -> .pdf) ---
$(DOT_OUT_DIR)/%.pdf: $(DOT_SRC_DIR)/%.dot
	@mkdir -p $(DOT_OUT_DIR)
	$(DOT) -Tpdf $< -o $@

# --- Gnuplot 変換ルール (.gp -> .tex + .pdf) ---
$(GP_OUT_DIR)/%.tex: $(GP_SRC_DIR)/%.gp
	@mkdir -p $(GP_OUT_DIR)
	$(GNUPLOT) $<

# クリーンアップ
clean:
	$(LATEXMK) -c $(TARGET)

distclean:
	$(LATEXMK) -C $(TARGET)
	rm -rf $(BUILD_DIR)

# latexmk 監視モード
watch: $(DOT_PDFS) $(GP_TEXS)
	@mkdir -p $(BUILD_DIR)
	$(LATEXMK) -pvc $(TARGET)
