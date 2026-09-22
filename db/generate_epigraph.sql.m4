changequote(`[[', `]]')dnl
.mode list
.separator ""
.headers off

SELECT 
    CASE 
        -- 訳文が存在する場合: \ChapterEpigraphWithTranslation{原文}{訳文}{出典}
        WHEN translation IS NOT NULL AND trim(translation) != '' THEN
            '\ChapterEpigraphWithTranslation{' || 
            trim(quote) || '}{' || 
            trim(translation) || '}{' || 
            trim(attribution) || 
            CASE 
                WHEN source IS NOT NULL AND trim(source) != '' THEN ', \textit{' || trim(source) || '}'
                ELSE ''
            END || '}'

        -- 原文のみの場合: \ChapterEpigraph{原文}{出典}
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
