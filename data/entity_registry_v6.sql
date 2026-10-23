-- ============================================================
-- V6: GENERIC ENTITY REGISTRY
-- ============================================================
--
-- Purpose:
-- Create a generic entity layer above the existing
-- character-specific tables.
--
-- Existing tables are NOT removed or modified.
--
-- Current supported entity types:
--   CHARACTER
--   RIVER
--
-- Future types:
--   EVENT
--   PLACE
--   OBJECT
--   TERM
--   CONCEPT
-- ============================================================


-- ============================================================
-- ENTITIES
-- ============================================================

CREATE TABLE IF NOT EXISTS entities (

    id SERIAL PRIMARY KEY,

    name TEXT NOT NULL,

    entity_type TEXT NOT NULL,

    description TEXT,

    source_id INTEGER NULL,

    -- Links a generic entity to the existing character
    -- record when this entity represents a character.
    character_id INTEGER NULL UNIQUE,

    CONSTRAINT entities_name_type_unique
        UNIQUE (name, entity_type),

    CONSTRAINT entities_character_fk
        FOREIGN KEY (character_id)
        REFERENCES characters(id)
        ON DELETE CASCADE,

    CONSTRAINT entities_source_fk
        FOREIGN KEY (source_id)
        REFERENCES sources(id)
        ON DELETE SET NULL
);


-- ============================================================
-- INDEXES FOR ENTITIES
-- ============================================================

CREATE INDEX IF NOT EXISTS
idx_entities_type
ON entities(entity_type);

CREATE INDEX IF NOT EXISTS
idx_entities_name
ON entities(name);


-- ============================================================
-- ENTITY ALIASES
-- ============================================================

CREATE TABLE IF NOT EXISTS entity_aliases (

    id SERIAL PRIMARY KEY,

    entity_id INTEGER NOT NULL,

    alias TEXT NOT NULL,

    CONSTRAINT entity_aliases_entity_fk
        FOREIGN KEY (entity_id)
        REFERENCES entities(id)
        ON DELETE CASCADE,

    CONSTRAINT entity_aliases_unique
        UNIQUE (entity_id, alias)
);


-- ============================================================
-- INDEXES FOR ENTITY ALIASES
-- ============================================================

CREATE INDEX IF NOT EXISTS
idx_entity_aliases_entity
ON entity_aliases(entity_id);

CREATE INDEX IF NOT EXISTS
idx_entity_aliases_alias
ON entity_aliases(LOWER(alias));


-- ============================================================
-- IMPORT EXISTING CHARACTERS
-- ============================================================

INSERT INTO entities (
    name,
    entity_type,
    description,
    character_id
)

SELECT
    c.name,
    'CHARACTER',
    c.description,
    c.id

FROM characters c

ON CONFLICT DO NOTHING;


-- ============================================================
-- IMPORT EXISTING CHARACTER ALIASES
-- ============================================================

INSERT INTO entity_aliases (
    entity_id,
    alias
)

SELECT
    e.id,
    ca.alias

FROM character_aliases ca

JOIN entities e
    ON e.character_id = ca.character_id

ON CONFLICT DO NOTHING;


-- ============================================================
-- ADD SĪTĀ RIVER AS A GENERIC ENTITY
-- ============================================================
--
-- This demonstrates that the same alias can belong to
-- more than one entity.
--
-- Example:
--
-- Sītā → CHARACTER
-- Sītā → RIVER
-- ============================================================

INSERT INTO entities (
    name,
    entity_type,
    description
)

VALUES (
    'Sita River',
    'RIVER',
    'A river referred to as Sītā in the Ramayana corpus.'
)

ON CONFLICT (
    name,
    entity_type
)

DO NOTHING;


-- ============================================================
-- ADD SĪTĀ RIVER ALIASES
-- ============================================================

INSERT INTO entity_aliases (
    entity_id,
    alias
)

SELECT
    e.id,
    alias_data.alias

FROM entities e

CROSS JOIN (
    VALUES
        ('Sītā'),
        ('Sita')
) AS alias_data(alias)

WHERE e.name = 'Sita River'
  AND e.entity_type = 'RIVER'

ON CONFLICT DO NOTHING;


-- ============================================================
-- VERIFICATION 1
-- ============================================================

SELECT
    entity_type,
    COUNT(*) AS entity_count

FROM entities

GROUP BY entity_type

ORDER BY entity_type;


-- ============================================================
-- VERIFICATION 2
-- ============================================================

SELECT
    e.id,
    e.name,
    e.entity_type,
    e.character_id,
    ea.alias

FROM entities e

LEFT JOIN entity_aliases ea
    ON ea.entity_id = e.id

WHERE
    LOWER(e.name) = 'sita'
    OR LOWER(e.name) = 'sita river'

ORDER BY
    e.entity_type,
    ea.alias;


-- ============================================================
-- VERIFICATION 3
-- ============================================================

SELECT
    e.name,
    e.entity_type,
    COUNT(ea.id) AS alias_count

FROM entities e

LEFT JOIN entity_aliases ea
    ON ea.entity_id = e.id

GROUP BY
    e.id,
    e.name,
    e.entity_type

ORDER BY
    e.entity_type,
    e.name;
