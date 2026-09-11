# 設定パラメータ
MAIN       := the_seed_of_magic
SRC_DIR    := src
BUILD_DIR  := build
TARGET     := $(SRC_DIR)/$(MAIN).tex
OUTPUT_PDF := $(BUILD_DIR)/$(MAIN).pdf

# コンパイルコマンド（LuaLaTeX指定・出力先build指定・停止せずエラー報告）
LATEXMK    := latexmk -lualatex -outdir=$(BUILD_DIR) -interaction=nonstopmode -synctex=1

.PHONY: all clean distclean watch

# デフォルトターゲット: PDFをビルド
all: $(OUTPUT_PDF)

$(OUTPUT_PDF): $(TARGET)
	@mkdir -p $(BUILD_DIR)
	$(LATEXMK) $(TARGET)

# 中間生成物のみ削除（PDFは保持）
clean:
	$(LATEXMK) -c $(TARGET)

# PDFを含むビルド成果物を全削除
distclean:
	$(LATEXMK) -C $(TARGET)
	rm -rf $(BUILD_DIR)

# latexmk 組み込みの監視モード（inotify/ポーリングベース）
watch:
	@mkdir -p $(BUILD_DIR)
	$(LATEXMK) -pvc $(TARGET)
