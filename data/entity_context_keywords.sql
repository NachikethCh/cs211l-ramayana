-- ============================================================
-- ENTITY CONTEXT KEYWORDS
-- ============================================================
--
-- Stores contextual evidence used for entity disambiguation.
--
-- entity_id:
--   Links to characters.id when the entity is a character.
--   NULL can be used for non-character entities such as rivers.
--
-- entity_name:
--   Human-readable name of the candidate entity.
--
-- entity_type:
--   CHARACTER, RIVER, EVENT, PLACE, TERM, etc.
--
-- keyword:
--   Word/phrase that provides contextual evidence.
--
-- weight:
--   Strength of the evidence.
--   3 = strong evidence
--   1 = weak evidence
-- ============================================================


CREATE TABLE IF NOT EXISTS entity_context_keywords (
    id SERIAL PRIMARY KEY,

    entity_id INTEGER NULL,

    entity_name TEXT NOT NULL,

    entity_type TEXT NOT NULL,

    keyword TEXT NOT NULL,

    weight INTEGER NOT NULL DEFAULT 1,

    CONSTRAINT entity_context_keywords_weight_check
        CHECK (weight > 0),

    CONSTRAINT entity_context_keywords_unique
        UNIQUE (
            entity_type,
            entity_name,
            keyword
        ),

    CONSTRAINT entity_context_keywords_character_fk
        FOREIGN KEY (entity_id)
        REFERENCES characters(id)
        ON DELETE CASCADE
);


-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX IF NOT EXISTS
idx_entity_context_keywords_entity
ON entity_context_keywords(entity_type, entity_name);

CREATE INDEX IF NOT EXISTS
idx_entity_context_keywords_keyword
ON entity_context_keywords(keyword);


INSERT INTO entity_context_keywords
    (entity_id, entity_name, entity_type, keyword, weight)

SELECT
    c.id,
    'Sita',
    'CHARACTER',
    data.keyword,
    data.weight

FROM characters c

CROSS JOIN (
    VALUES

        -- Strong evidence
        ('rama', 3),
        ('raghava', 3),
        ('kakutstha', 3),
        ('janaka', 3),
        ('ravana', 3),
        ('hanuman', 3),
        ('lakshmana', 3),

        ('wife', 3),
        ('husband', 3),
        ('daughter', 3),
        ('damsel', 3),
        ('girl', 3),
        ('maiden', 3),

        ('royal', 3),
        ('spouse', 3),
        ('spouses', 3),

        ('chaste', 3),
        ('beloved', 3),
        ('lord', 3),
        ('exalted', 3),
        ('famous', 3),

        ('marriage', 3),
        ('married', 3),
        ('recovery', 3),
        ('recovered', 3),

        ('found', 3),
        ('converse', 3),
        ('conversed', 3),
        ('ring', 3),
        ('bestowed', 3),
        ('confer', 3),
        ('received', 3),
        ('receive', 3),

        ('forest', 3),

        ('fire', 3),
        ('flaming', 3),

        ('ayodhya', 3),
        ('lanka', 3),
        ('asoka', 3),
        ('garden', 3),

        ('enemy', 3),
        ('king', 3),

        ('urmila', 3),
        ('hallowing', 3),
        ('field', 3),
        ('sacrifice', 3),
        ('name', 3),

        -- Weak evidence
        ('spoke', 1),
        ('said', 1),
        ('went', 1),
        ('met', 1),
        ('asked', 1),
        ('looked', 1),
        ('entered', 1),
        ('saw', 1),
        ('touching', 1),
        ('thought', 1),
        ('heart', 1),

        ('she', 1),
        ('her', 1),
        ('him', 1),
        ('his', 1),
        ('arose', 1),
        ('known', 1)

) AS data(keyword, weight)

WHERE c.name IN ('Sītā', 'Sita');



-- ============================================================
-- SĪTĀ — RIVER
-- ============================================================

INSERT INTO entity_context_keywords
    (entity_id, entity_name, entity_type, keyword, weight)

VALUES

    (NULL, 'Sita River', 'RIVER', 'river', 3),
    (NULL, 'Sita River', 'RIVER', 'rivers', 3),

    (NULL, 'Sita River', 'RIVER', 'stream', 3),
    (NULL, 'Sita River', 'RIVER', 'streams', 3),

    (NULL, 'Sita River', 'RIVER', 'sindhu', 3),
    (NULL, 'Sita River', 'RIVER', 'sucaksu', 3),

    (NULL, 'Sita River', 'RIVER', 'flow', 3),
    (NULL, 'Sita River', 'RIVER', 'flows', 3),
    (NULL, 'Sita River', 'RIVER', 'flowed', 3),
    (NULL, 'Sita River', 'RIVER', 'flowing', 3),

    (NULL, 'Sita River', 'RIVER', 'water', 1),
    (NULL, 'Sita River', 'RIVER', 'waters', 1),
    (NULL, 'Sita River', 'RIVER', 'banks', 1)

ON CONFLICT (
    entity_type,
    entity_name,
    keyword
)
DO NOTHING;


-- ============================================================
-- VERIFY
-- ============================================================

SELECT
    entity_type,
    entity_name,
    COUNT(*) AS keyword_count
FROM entity_context_keywords
GROUP BY
    entity_type,
    entity_name
ORDER BY
    entity_type,
    entity_name;
