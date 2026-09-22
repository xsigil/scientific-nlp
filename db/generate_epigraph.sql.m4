changequote(`[[', `]]')dnl
.mode list
.separator ""
.headers off

SELECT 
    CASE 
        -- 訳文が存在する場合: \ifja で分岐を出力
        WHEN translation IS NOT NULL AND trim(translation) != '' THEN
            '\ifja' || char(10) ||
            '  \ChapterEpigraphWithTranslation{' || 
            trim(quote) || '}{' || 
            trim(translation) || '}{' || 
            trim(attribution) || 
            CASE 
                WHEN source IS NOT NULL AND trim(source) != '' THEN ', \textit{' || trim(source) || '}'
                ELSE ''
            END || '}' || char(10) ||
            '\else' || char(10) ||
            '  \ChapterEpigraph{' || 
            trim(quote) || '}{' || 
            trim(attribution) || 
            CASE 
                WHEN source IS NOT NULL AND trim(source) != '' THEN ', \textit{' || trim(source) || '}'
                ELSE ''
            END || '}' || char(10) ||
            '\fi'

        -- 訳文が存在しない（原文のみ）場合: 分岐不要で \ChapterEpigraph を出力
        ELSE
            '\ChapterEpigraph{' || 
            trim(quote) || '}{' || 
            trim(attribution) || 
            CASE 
                WHEN source IS NOT NULL AND trim(source) != '' THEN ', \textit{' || trim(source) || '}'
                ELSE ''
            END || '}'
    END
FROM epigraphs
WHERE 1=1
ifdef([[__WORD__]], [[  AND (quote LIKE '%__WORD__%' OR translation LIKE '%__WORD%')]])
ifdef([[__AUTHOR__]], [[  AND attribution LIKE '%__AUTHOR__%']])
ORDER BY id ASC
LIMIT ifdef([[__LIMIT__]], [[__LIMIT__]], [[1]]);
