-- src/lua/ontology_bridge.lua
local luasql = require('luasql.sqlite3')
local env = luasql.sqlite3()
local db_path = "db/ontology.sqlite3"

local function get_db()
    return env:connect(db_path)
end

-- エピグラフを整形して tex.print するヘルパー
local function render_epigraph(row)
    local cite = row.attribution
    if row.source and row.source:match("%S") then
        cite = cite .. ", \\textit{" .. row.source .. "}"
    end

    if row.translation and row.translation:match("%S") then
        tex.print(string.format("\\ChapterEpigraphWithTranslation{%s}{%s}{%s}", 
            row.quote, row.translation, cite))
    else
        tex.print(string.format("\\ChapterEpigraph{%s}{%s}", 
            row.quote, cite))
    end
end

-- =============================================================================
-- Epigraph 柔軟検索エンジン
-- opt = {
--     word = "street",           -- quote または translation の部分一致
--     author = "Gibson",         -- attribution の部分一致
--     allow_multiple = true      -- 複数ヒット時に全件展開するか（falseなら警告）
-- }
-- =============================================================================
function QueryEpigraph(opt)
    opt = opt or {}
    local con = get_db()

    local where_clauses = {}
    
    -- 単語検索 (quote または translation に LIKE)
    if opt.word and opt.word:match("%S") then
        local w = con:escape(opt.word)
        table.insert(where_clauses, string.format("(quote LIKE '%%%s%%' OR translation LIKE '%%%s%%')", w, w))
    end

    -- 作者検索 (attribution に LIKE)
    if opt.author and opt.author:match("%S") then
        local a = con:escape(opt.author)
        table.insert(where_clauses, string.format("attribution LIKE '%%%s%%'", a))
    end

    -- 条件なし防止（全件誤爆を防ぐ）
    if #where_clauses == 0 then
        tex.print("\\textbf{[Epigraph Error: No search criteria specified.]}")
        con:close()
        return
    end

    local sql = string.format([[
        SELECT id, quote, translation, attribution, source 
        FROM epigraphs 
        WHERE %s
        ORDER BY id ASC;
    ]], table.concat(where_clauses, " AND "))

    local cur = con:execute(sql)
    local rows = {}
    local row = cur:fetch({}, "a")
    while row do
        table.insert(rows, row)
        row = cur:fetch({}, "a")
    end
    cur:close()
    con:close()

    local count = #rows

    -- -------------------------------------------------------------------------
    -- パターン A: ヒット件数ゼロ（エラーハンドリング）
    -- -------------------------------------------------------------------------
    if count == 0 then
        local desc = string.format("word='%s', author='%s'", opt.word or "", opt.author or "")
        -- コンソールログに警告
        texio.write_nl(string.format("--> [DB Warning] Epigraph not found: %s", desc))
        -- 紙面にもビルドエラーが視覚的に分かるアラートを出力
        tex.print(string.format("\\textbf{\\color{red}[Epigraph Not Found: %s]}", desc))
        return
    end

    -- -------------------------------------------------------------------------
    -- パターン B: 複数件ヒットした場合の分岐
    -- -------------------------------------------------------------------------
    local allow_multi = (opt.allow_multiple == nil) or (opt.allow_multiple == true)

    if count > 1 and not allow_multi then
        -- 複数ヒットを意図せず許容しない場合（1件に絞り込みたい時など）
        local warn_msg = string.format("Multiple epigraphs (%d) matched query. Set allow_multiple=true to render all.", count)
        texio.write_nl("--> [DB Ambiguity Warning] " .. warn_msg)
        tex.print(string.format("\\textbf{\\color{orange}[Epigraph Query Ambiguous: %s]}", warn_msg))
        return
    end

    -- -------------------------------------------------------------------------
    -- パターン C: レンダリング（1件、または複数件を順次展開）
    -- -------------------------------------------------------------------------
    for _, r in ipairs(rows) do
        render_epigraph(r)
    end
end
