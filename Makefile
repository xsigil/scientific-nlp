# ==============================================================================
# Project: Scientific NLP - Multi-Language Build Pipeline
# ==============================================================================

# 設定パラメータ
MAIN         := the_seed_of_magic
SRC_DIR      := src
BUILD_DIR    := build

DOT_SRC_DIR  := $(SRC_DIR)/dot
DOT_OUT_DIR  := $(BUILD_DIR)/dot

GP_SRC_DIR   := $(SRC_DIR)/plots
GP_OUT_DIR   := $(BUILD_DIR)/plots

PIK_SRC_DIR  := $(SRC_DIR)/pikchr
PIK_OUT_DIR  := $(BUILD_DIR)/pikchr

EPIGRAPH_DIR := $(SRC_DIR)/epigraph
EPIGRAPH_TSV := $(SRC_DIR)/epigraphs.tsv
EPIGRAPH_M4  := db/generate_epigraph.sql.m4
DB_FILE      := db/ontology.sqlite3

TARGET       := $(SRC_DIR)/$(MAIN).tex

# 言語別出力アーティファクト定義
PDF_JA       := $(BUILD_DIR)/$(MAIN)_ja.pdf
PDF_EN       := $(BUILD_DIR)/$(MAIN)_en.pdf

# 依存ソースおよび生成ファイル定義
DOT_SRCS     := $(wildcard $(DOT_SRC_DIR)/*.dot)
DOT_M4S      := $(wildcard $(DOT_SRC_DIR)/*.m4)
DOT_PDFS     := $(patsubst $(DOT_SRC_DIR)/%.dot,$(DOT_OUT_DIR)/%.pdf,$(DOT_SRCS))

GP_SRCS      := $(wildcard $(GP_SRC_DIR)/*.gp)
GP_TEXS      := $(patsubst $(GP_SRC_DIR)/%.gp,$(GP_OUT_DIR)/%.tex,$(GP_SRCS))

PIK_SRCS     := $(wildcard $(PIK_SRC_DIR)/*.pic)
PIK_PDFS     := $(patsubst $(PIK_SRC_DIR)/%.pic,$(PIK_OUT_DIR)/%.pdf,$(PIK_SRCS))

ASSETS       := $(DOT_PDFS) $(GP_TEXS) $(PIK_PDFS)

# コンパイルコマンド
LATEXMK      := latexmk -lualatex -outdir=$(BUILD_DIR) -interaction=nonstopmode -synctex=1
M4           := m4 -I$(DOT_SRC_DIR)
DOT          := dot
GNUPLOT      := gnuplot
PIKCHR       := pikchr
RSVG_CONVERT := rsvg-convert
GAWK         := gawk
SQLITE3      := sqlite3

.PHONY: all ja en clean distclean watch watch-ja watch-en dot_figs plot_figs pikchr_figs epigraph
# デフォルトターゲット: 日英両方のPDFを生成
all: ja en

# 言語別ビルドターゲット
ja: $(PDF_JA)
en: $(PDF_EN)

# --- 日本語版コンパイル ---
$(PDF_JA): $(TARGET) $(ASSETS)
	@mkdir -p $(BUILD_DIR)
	$(LATEXMK) -jobname=$(MAIN)_ja -usepretex="\def\BOOKLANG{ja}" $(TARGET)

# --- 英語版コンパイル ---
$(PDF_EN): $(TARGET) $(ASSETS)
	@mkdir -p $(BUILD_DIR)
	$(LATEXMK) -jobname=$(MAIN)_en -usepretex="\def\BOOKLANG{en}" $(TARGET)

# 図版個別生成ターゲット
dot_figs: $(DOT_PDFS)
plot_figs: $(GP_TEXS)
pikchr_figs: $(PIK_PDFS)

# --- Graphviz 変換ルール (.dot + .m4 -> .pdf) ---
$(DOT_OUT_DIR)/%.pdf: $(DOT_SRC_DIR)/%.dot $(DOT_M4S)
	@mkdir -p $(DOT_OUT_DIR)
	$(M4) $< | $(DOT) -Tpdf -o $@

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

# --- Epigraph コード生成 (TSV -> gawk -> m4 -> sqlite3 -> src/epigraph/*.tex) ---
epigraph: $(EPIGRAPH_TSV) $(EPIGRAPH_M4) $(DB_FILE)
	@mkdir -p $(EPIGRAPH_DIR)
	@echo "==> Generating epigraph components into $(EPIGRAPH_DIR)..."
	@$(GAWK) -F'\t' ' \
		!/^#/ && NF >= 1 { \
			target = $$1; \
			word   = $$2; \
			author = $$3; \
			limit  = ($$4 != "") ? $$4 : 1; \
			outfile = "$(EPIGRAPH_DIR)/" target ".tex"; \
			\
			cmd = "m4"; \
			if (word != "")   cmd = cmd " -D__WORD__=\"" word "\""; \
			if (author != "") cmd = cmd " -D__AUTHOR__=\"" author "\""; \
			if (limit != "")  cmd = cmd " -D__LIMIT__=" limit; \
			cmd = cmd " $(EPIGRAPH_M4) | $(SQLITE3) $(DB_FILE) > " outfile; \
			\
			printf "  -> Generating %s (word: \"%s\", author: \"%s\")\n", outfile, word, author; \
			system(cmd); \
		}' $(EPIGRAPH_TSV)
	@echo "==> Done."

# クリーンアップ
clean:
	$(LATEXMK) -c -jobname=$(MAIN)_ja $(TARGET)
	$(LATEXMK) -c -jobname=$(MAIN)_en $(TARGET)

distclean:
	$(LATEXMK) -C -jobname=$(MAIN)_ja $(TARGET)
	$(LATEXMK) -C -jobname=$(MAIN)_en $(TARGET)
	rm -rf $(BUILD_DIR)

watch: watch-ja

# latexmk 継続的監視モード
watch-ja: $(ASSETS)
	@mkdir -p $(BUILD_DIR)
	$(LATEXMK) -pvc -jobname=$(MAIN)_ja -usepretex="\def\BOOKLANG{ja}" $(TARGET)

watch-en: $(ASSETS)
	@mkdir -p $(BUILD_DIR)
	$(LATEXMK) -pvc -jobname=$(MAIN)_en -usepretex="\def\BOOKLANG{en}" $(TARGET)
