CREATE TABLE epigraphs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    chapter TEXT NOT NULL,         -- 'ch01', 'ch08' など
    text_en TEXT NOT NULL,         -- 原文
    text_ja TEXT,                  -- 日本語訳（NULLなら原文のみマクロを呼ぶ）
    source TEXT NOT NULL,          -- 出典・著者
    genre TEXT,                    -- 'anime', 'cybernetics', 'math' など
    active INTEGER DEFAULT 0       -- 1ならコンパイル時に採用
);
