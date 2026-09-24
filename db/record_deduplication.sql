SELECT id, quote, attribution, source
FROM (
    SELECT id, quote, attribution, source,
           ROW_NUMBER() OVER (
               PARTITION BY quote, attribution, source, context_note, created_at, translation
               ORDER BY id ASC
           ) AS rn
    FROM epigraphs
)
WHERE rn > 1;
