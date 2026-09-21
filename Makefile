# 設定パラメータ
MAIN        := the_seed_of_magic
SRC_DIR     := src
BUILD_DIR   := build

DOT_SRC_DIR := $(SRC_DIR)/dot
DOT_OUT_DIR := $(BUILD_DIR)/dot

GP_SRC_DIR  := $(SRC_DIR)/plots
GP_OUT_DIR  := $(BUILD_DIR)/plots

PIK_SRC_DIR := $(SRC_DIR)/pikchr
PIK_OUT_DIR := $(BUILD_DIR)/pikchr

TARGET      := $(SRC_DIR)/$(MAIN).tex
OUTPUT_PDF  := $(BUILD_DIR)/$(MAIN).pdf

# 依存ソースおよび生成ファイル定義
DOT_SRCS    := $(wildcard $(DOT_SRC_DIR)/*.dot)
DOT_PDFS    := $(patsubst $(DOT_SRC_DIR)/%.dot,$(DOT_OUT_DIR)/%.pdf,$(DOT_SRCS))

GP_SRCS     := $(wildcard $(GP_SRC_DIR)/*.gp)
GP_TEXS     := $(patsubst $(GP_SRC_DIR)/%.gp,$(GP_OUT_DIR)/%.tex,$(GP_SRCS))

PIK_SRCS    := $(wildcard $(PIK_SRC_DIR)/*.pic)
PIK_PDFS    := $(patsubst $(PIK_SRC_DIR)/%.pic,$(PIK_OUT_DIR)/%.pdf,$(PIK_SRCS))

# コンパイルコマンド
LATEXMK     := latexmk -lualatex -outdir=$(BUILD_DIR) -interaction=nonstopmode -synctex=1
DOT         := dot
GNUPLOT     := gnuplot
PIKCHR      := pikchr
RSVG_CONVERT:= rsvg-convert

.PHONY: all clean distclean watch dot_figs plot_figs pikchr_figs

# デフォルトターゲット: 全ての図版・プロットを生成した後にメインPDFをコンパイル
all: $(OUTPUT_PDF)

# メインPDFの依存関係
$(OUTPUT_PDF): $(TARGET) $(DOT_PDFS) $(GP_TEXS) $(PIK_PDFS)
	@mkdir -p $(BUILD_DIR)
	$(LATEXMK) $(TARGET)

# 図版個別生成ターゲット
dot_figs: $(DOT_PDFS)
plot_figs: $(GP_TEXS)
pikchr_figs: $(PIK_PDFS)

# --- Graphviz 変換ルール (.dot -> .pdf) ---
$(DOT_OUT_DIR)/%.pdf: $(DOT_SRC_DIR)/%.dot
	@mkdir -p $(DOT_OUT_DIR)
	$(DOT) -Tpdf $< -o $@

# --- Gnuplot 変換ルール (.gp -> .tex + .pdf) ---
$(GP_OUT_DIR)/%.tex: $(GP_SRC_DIR)/%.gp
	@mkdir -p $(GP_OUT_DIR)
	$(GNUPLOT) $<

# --- Pikchr 変換ルール (.pic -> .svg -> .pdf) ---
$(PIK_OUT_DIR)/%.svg: $(PIK_SRC_DIR)/%.pic
	@mkdir -p $(PIK_OUT_DIR)
	$(PIKCHR) --svg-only $< > $@

$(PIK_OUT_DIR)/%.pdf: $(PIK_OUT_DIR)/%.svg
	@mkdir -p $(PIK_OUT_DIR)
	$(RSVG_CONVERT) -f pdf -o $@ $<

# クリーンアップ
clean:
	$(LATEXMK) -c $(TARGET)

distclean:
	$(LATEXMK) -C $(TARGET)
	rm -rf $(BUILD_DIR)

# latexmk 監視モード
watch: $(DOT_PDFS) $(GP_TEXS) $(PIK_PDFS)
	@mkdir -p $(BUILD_DIR)
	$(LATEXMK) -pvc $(TARGET)
