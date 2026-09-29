#!/usr/bin/env bash
set -euo pipefail

# GNU sed の検出 (macOS で gsed が入っている場合は優先)
if command -v gsed >/dev/null 2>&1; then
    SED_CMD="gsed"
else
    SED_CMD="sed"
fi

echo "=== Target TeX Files Scanning ==="
# 置換対象ファイルのリスト（必要に応じてパスを調整）
TARGET_FILES=$(find . -type f \( -name "*.tex" -o -name "*.sty" \) ! -path "*/.git/*" ! -path "*/build/*")

# 置換テーブル: "旧マクロ名:新マクロ名"
# ※ 誤爆を防ぐため、文字数の長い順（降順）に厳密に並べています。
MAPPINGS=(
    # --- 複合・長大マクロ (最優先) ---
    "jpIntellectualZeroPersonalityKana:jaIntellectualZeroPersonalityKana"
    "exIntellectualZeroPersonality:fullIntellectualZeroPersonality"
    "jpIntellectualZeroPersonality:jaIntellectualZeroPersonality"
    "jpIntellectualZeroStateKana:jaIntellectualZeroStateKana"
    "exIntellectualZeroState:fullIntellectualZeroState"
    "jpIntellectualZeroState:jaIntellectualZeroState"

    "NeuralQuasiBayesianUpdateConviction:mthNeuralQuasiBayesianUpdateConviction"
    "NeuralQuasiBayesianExploration:mthNeuralQuasiBayesianExploration"
    "MathBayesianUpdateCollapse:mthBayesianUpdateCollapse"
    "PredictThreatVirtualConviction:mthPredictThreatVirtualConviction"
    "PredictProfitVirtualConviction:mthPredictProfitVirtualConviction"
    "exTextConditionalProbability:fullTextConditionalProbability"
    "jpTextConditionalProbability:jaTextConditionalProbability"

    "exVCausalityEgoConviction:fullVCausalityEgoConviction"
    "jpVCausalityEgoConviction:jaVCausalityEgoConviction"
    "exVCauseEgoConviction:fullVCauseEgoConviction"
    "jpVCauseEgoConviction:jaVCauseEgoConviction"
    "exVEffectEgoConviction:fullVEffectEgoConviction"
    "jpVEffectEgoConviction:jaVEffectEgoConviction"

    "nonTMexAttentiveObserver:fullAttentiveObserver"
    "nonTMjpAttentiveObserver:jaAttentiveObserver"
    "exAttentiveObserver:fullAttentiveObserver"
    "jpAttentiveObserver:jaAttentiveObserver"
    "aAttentiveObserver:abbrAttentiveObserver"

    "exFlipperOthello:fullFlipperOthello"
    "jpFlipperOthello:jaFlipperOthello"
    "aFlipperOthello:abbrFlipperOthello"
    "FlipperZero:txtFlipperZero"

    "exZeroPersonality:fullZeroPersonality"
    "jpZeroPersonality:jaZeroPersonality"
    "exZeroState:fullZeroState"
    "jpZeroState:jaZeroState"

    "exNQPosteriorSpace:fullNQPosteriorSpace"
    "jpNQPosteriorSpace:jaNQPosteriorSpace"
    "aNQPosteriorSpace:abbrNQPosteriorSpace"

    "exNQPriorSpace:fullNQPriorSpace"
    "jpNQPriorSpace:jaNQPriorSpace"
    "aNQPriorSpace:abbrNQPriorSpace"

    "exTextBayesTheorem:fullTextBayesTheorem"
    "jpTextBayesTheorem:jaTextBayesTheorem"

    "ConditionalProbability:mthConditionalProbability"
    "MathHypothesisGroup:mthHypothesisGroup"
    "VirtualConvictionGroup:mthVirtualConvictionGroup"
    "InvoluntaryMovement:mthInvoluntaryMovement"
    "LangTranslationOp:mthLangTranslationOp"
    "MathNumHypotheses:mthNumHypotheses"
    "NeuralQuasiEvidence:mthNeuralQuasiEvidence"
    "VoluntaryMovement:mthVoluntaryMovement"
    "LangTranslation:mthLangTranslation"
    "MathHypoSpace:mthHypoSpace"
    "MathHypothesis:mthHypothesis"

    # --- 略称・プロトコル・技法系 ---
    "exRBSFOPI:fullRBSFOPI"
    "jpRBSFOPI:jaRBSFOPI"
    "aRBSFOPI:abbrRBSFOPI"

    "exFTHBFT:fullFTHBFT"
    "jpFTHBFT:jaFTHBFT"
    "aFTHBFT:abbrFTHBFT"

    "exRCSMIT:fullRCSMIT"
    "jpRCSMIT:jaRCSMIT"
    "aRCSMIT:abbrRCSMIT"

    "exCNQBIS:fullCNQBIS"
    "jpCNQBIS:jaCNQBIS"
    "aCNQBIS:abbrCNQBIS"

    "exDrBandler:fullDrBandler"
    "jpDrBandler:jaDrBandler"
    "jpaDrBandler:jaBandlerDr"

    "exUUSTT:fullUUSTT"
    "jpUUSTT:jaUUSTT"
    "aUUSTT:abbrUUSTT"

    "exTRPSH:fullTRPSH"
    "jpTRPSH:jaTRPSH"
    "aTRPSH:abbrTRPSH"

    "exBHPPP:fullBHPPP"
    "jpBHPPP:jaBHPPP"
    "aBHPPP:abbrBHPPP"

    "exTFVEC:fullTFVEC"
    "jpTFVEC:jaTFVEC"
    "aTFVEC:abbrTFVEC"

    "exBOODA:fullBOODA"
    "jpBOODA:jaBOODA"
    "aBOODA:abbrBOODA"

    "exADBC:fullADBC"
    "jpADBC:jaADBC"
    "aADBC:abbrADBC"

    "exKIMA:fullKIMA"
    "jpKIMA:jaKIMA"
    "aKIMA:abbrKIMA"

    "exMBCR:fullMBCR"
    "jpMBCR:jaMBCR"
    "aMBCR:abbrMBCR"

    "exSBFT:fullSBFT"
    "jpSBFT:jaSBFT"
    "aSBFT:abbrSBFT"

    "exNQBIE:fullNQBIE"
    "jpNQBIE:jaNQBIE"
    "aNQBIE:abbrNQBIE"

    "exMBIE:fullMBIE"
    "jpMBIE:jaMBIE"
    "aMBIE:abbrMBIE"

    "exNQBU:fullNQBU"
    "jpNQBU:jaNQBU"
    "aNQBU:abbrNQBU"

    "exNQSpace:fullNQSpace"
    "jpNQSpace:jaNQSpace"
    "aNQSpace:abbrNQSpace"

    "exUUST:fullUUST"
    "jpUUST:jaUUST"
    "aUUST:abbrUUST"

    "exBDLL:fullBDLL"
    "jpBDLL:jaBDLL"
    "aBDLL:abbrBDLL"

    "nonTMexVNC:fullVNC"
    "nonTMjpVNC:jaVNC"
    "exVNC:fullVNC"
    "jpVNC:jaVNC"
    "aVNC:abbrVNC"

    "exBSF:fullBSF"
    "jpBSF:jaBSF"
    "aBSF:abbrBSF"

    "exKOP:fullKOP"
    "jpKOP:jaKOP"
    "aKOP:abbrKOP"

    "exOIP:fullOIP"
    "jpOIP:jaOIP"
    "aOIP:abbrOIP"

    "exBTP:fullBTP"
    "jpBTP:jaBTP"
    "aBTP:abbrBTP"

    "exRIP:fullRIP"
    "jpRIP:jaRIP"
    "aRIP:abbrRIP"

    "exAAB:fullAAB"
    "jpAAB:jaAAB"
    "aAAB:abbrAAB"

    "exADR:fullADR"
    "jpADR:jaADR"
    "aADR:abbrADR"

    "exCBO:fullCBO"
    "jpCBO:jaCBO"
    "aCBO:abbrCBO"

    "exSNLP:fullSNLP"
    "jpSNLP:jaSNLP"
    "aSNLP:abbrSNLP"

    "exCNLP:fullCNLP"
    "jpCNLP:jaCNLP"
    "aCNLP:abbrCNLP"
    "rawCNLP:txtCNLP"

    "exBandler:fullBandler"
    "jpBandler:jaBandler"
    "jpaBandler:jaBandlerShort"
    "Bandler:txtBandler"

    "exOthelloFilter:fullOthelloFilter"
    "jpOthelloFilter:jaOthelloFilter"

    "exDMN:fullDMN"
    "jpDMN:jaDMN"
    "aDMN:abbrDMN"

    "exCEN:fullCEN"
    "jpCEN:jaCEN"
    "aCEN:abbrCEN"

    "exSN:fullSN"
    "jpSN:jaSN"
    "aSN:abbrSN"

    "exBV:fullBV"
    "jpBV:jaBV"
    "aBV:abbrBV"

    "exOP:fullOP"
    "jpOP:jaOP"
    "aOP:abbrOP"

    "exAR:fullAR"
    "jpAR:jaAR"
    "aAR:abbrAR"

    # --- 数理・記号系 ---
    "DiscreteStep:mthDiscreteStep"
    "CoupledState:mthCoupledState"
    "ConflictLoop:mthConflictLoop"
    "VirtualConviction:mthVirtualConviction"
    "MathEvidence:mthEvidence"
    "AlteredState:mthAlteredState"
    "SixthSense:mthSixthSense"
    "Probability:mthProbability"
    "scientificVd:mthScientificVd"
    "scientificAd:mthScientificAd"
    "scientificV:mthScientificV"
    "scientificA:mthScientificA"
    "scientificK:mthScientificK"
    "scientificO:mthScientificO"
    "scientificG:mthScientificG"
    "classicVd:mthClassicVd"
    "classicAd:mthClassicAd"
    "classicV:mthClassicV"
    "classicA:mthClassicA"
    "classicK:mthClassicK"
    "classicO:mthClassicO"
    "classicG:mthClassicG"
    "DMNState:mthDMNState"
    "CENState:mthCENState"
    "WholeSelf:mthWholeSelf"
    "Ouroboros:mthOuroboros"
    "EnvNoise:mthEnvNoise"
    "VdNoise:mthVdNoise"
    "ANoise:mthANoise"
    "KNoise:mthKNoise"
    "ONoise:mthONoise"
    "GNoise:mthGNoise"
    "VNoise:mthVNoise"
    "Deciban:mthDeciban"
    "NQSpace:mthNQSpace"
    "State:mthState"
    "eventA:mthEventA"
    "eventB:mthEventB"
    "eventC:mthEventC"
    "eventD:mthEventD"
    "eventM:mthEventM"
    "EventStyle:mthEventStyle"
    "CBO:mthCBO"
    "UU:mthUU"
    "NLP:abbrNLP"
    "TOTE:abbrTOTE"
)

echo "Starting replacement across $(echo "$TARGET_FILES" | wc -l) files..."

for item in "${MAPPINGS[@]}"; do
    OLD="${item%%:*}"
    NEW="${item##*:}"
    
    # \\OLD\\b で TeX コマンドの単語境界を完全捕捉
    # 置換パターン: \OLD -> \NEW
    echo "Replacing: \\${OLD} -> \\${NEW}"
    
    for file in $TARGET_FILES; do
        $SED_CMD -i -E "s/\\\\${OLD}\b/\\\\${NEW}/g" "$file"
    done
done

echo "=== All Replacements Completed ==="
