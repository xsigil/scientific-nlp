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
OUTPUT_PDF   := $(BUILD_DIR)/$(MAIN).pdf

# 依存ソースおよび生成ファイル定義
DOT_SRCS     := $(wildcard $(DOT_SRC_DIR)/*.dot)
DOT_M4S      := $(wildcard $(DOT_SRC_DIR)/*.m4)
DOT_PDFS     := $(patsubst $(DOT_SRC_DIR)/%.dot,$(DOT_OUT_DIR)/%.pdf,$(DOT_SRCS))

GP_SRCS      := $(wildcard $(GP_SRC_DIR)/*.gp)
GP_TEXS      := $(patsubst $(GP_SRC_DIR)/%.gp,$(GP_OUT_DIR)/%.tex,$(GP_SRCS))

PIK_SRCS     := $(wildcard $(PIK_SRC_DIR)/*.pic)
PIK_PDFS     := $(patsubst $(PIK_SRC_DIR)/%.pic,$(PIK_OUT_DIR)/%.pdf,$(PIK_SRCS))

# コンパイルコマンド
LATEXMK      := latexmk -lualatex -outdir=$(BUILD_DIR) -interaction=nonstopmode -synctex=1
M4           := m4 -I$(DOT_SRC_DIR)
DOT          := dot
GNUPLOT      := gnuplot
PIKCHR       := pikchr
RSVG_CONVERT := rsvg-convert
GAWK         := gawk
SQLITE3      := sqlite3

.PHONY: all clean distclean watch dot_figs plot_figs pikchr_figs epigraph

# デフォルトターゲット: 全ての図版・プロットを生成した後にメインPDFをコンパイル
all: $(OUTPUT_PDF)

# メインPDFの依存関係（エピグラフ生成には依存させず高速・決定論的に保つ）
$(OUTPUT_PDF): $(TARGET) $(DOT_PDFS) $(GP_TEXS) $(PIK_PDFS)
	@mkdir -p $(BUILD_DIR)
	$(LATEXMK) $(TARGET)

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
	$(LATEXMK) -c $(TARGET)

distclean:
	$(LATEXMK) -C $(TARGET)
	rm -rf $(BUILD_DIR)

# latexmk 監視モード
watch: $(DOT_PDFS) $(GP_TEXS) $(PIK_PDFS)
	@mkdir -p $(BUILD_DIR)
	$(LATEXMK) -pvc $(TARGET)
