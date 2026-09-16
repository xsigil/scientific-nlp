# 設定パラメータ
MAIN        := the_seed_of_magic
SRC_DIR     := src
BUILD_DIR   := build
DOT_SRC_DIR := $(SRC_DIR)/dot
DOT_OUT_DIR := $(BUILD_DIR)/dot

TARGET      := $(SRC_DIR)/$(MAIN).tex
OUTPUT_PDF  := $(BUILD_DIR)/$(MAIN).pdf

# Graphviz ソースおよび変換先PDFの定義
DOT_SRCS    := $(wildcard $(DOT_SRC_DIR)/*.dot)
DOT_PDFS    := $(patsubst $(DOT_SRC_DIR)/%.dot,$(DOT_OUT_DIR)/%.pdf,$(DOT_SRCS))

# コンパイルコマンド（LuaLaTeX指定・出力先build指定・停止せずエラー報告）
LATEXMK     := latexmk -lualatex -outdir=$(BUILD_DIR) -interaction=nonstopmode -synctex=1
DOT         := dot

.PHONY: all clean distclean watch dot_figs

# デフォルトターゲット: DOT図版の生成後にメインPDFをビルド
all: $(OUTPUT_PDF)

# メインPDFはターゲットTeXファイルおよび生成されたすべてのDOT PDFに依存
$(OUTPUT_PDF): $(TARGET) $(DOT_PDFS)
	@mkdir -p $(BUILD_DIR)
	$(LATEXMK) $(TARGET)

# 明示的に図版のみを生成したい場合のターゲット
dot_figs: $(DOT_PDFS)

# .dot から .pdf への変換パターンルール（ベクター形式で直接出力）
$(DOT_OUT_DIR)/%.pdf: $(DOT_SRC_DIR)/%.dot
	@mkdir -p $(DOT_OUT_DIR)
	$(DOT) -Tpdf $< -o $@

# 中間生成物のみ削除（PDFは保持）
clean:
	$(LATEXMK) -c $(TARGET)

# PDFを含むビルド成果物を全削除（生成した図版PDFディレクトリも削除）
distclean:
	$(LATEXMK) -C $(TARGET)
	rm -rf $(BUILD_DIR)

# latexmk 組み込みの監視モード（事前に関連図版をすべて生成してから監視開始）
watch: $(DOT_PDFS)
	@mkdir -p $(BUILD_DIR)
	$(LATEXMK) -pvc $(TARGET)
