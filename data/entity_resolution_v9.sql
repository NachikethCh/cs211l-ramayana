CREATE TABLE IF NOT EXISTS entity_resolution_results (

    id SERIAL PRIMARY KEY,

    chapter_id INTEGER NOT NULL,

    paragraph_number INTEGER NOT NULL,

    mentioned_text TEXT NOT NULL,

    start_position INTEGER,

    end_position INTEGER,

    context TEXT,

    resolved_entity_id INTEGER,

    resolved_entity_type TEXT,

    confidence NUMERIC(5,4),

    matched_context JSONB,

    resolution_status TEXT NOT NULL DEFAULT 'RESOLVED',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT entity_resolution_results_chapter_fk
        FOREIGN KEY (chapter_id)
        REFERENCES chapters(id)
        ON DELETE CASCADE,

    CONSTRAINT entity_resolution_results_entity_fk
        FOREIGN KEY (resolved_entity_id)
        REFERENCES entities(id)
        ON DELETE SET NULL,

    CONSTRAINT entity_resolution_results_confidence_check
        CHECK (
            confidence IS NULL
            OR (
                confidence >= 0
                AND confidence <= 1
            )
        )
);


CREATE INDEX IF NOT EXISTS
idx_resolution_results_chapter
ON entity_resolution_results(chapter_id);


CREATE INDEX IF NOT EXISTS
idx_resolution_results_entity
ON entity_resolution_results(resolved_entity_id);


CREATE INDEX IF NOT EXISTS
idx_resolution_results_status
ON entity_resolution_results(resolution_status);


CREATE INDEX IF NOT EXISTS
idx_resolution_results_mention
ON entity_resolution_results(mentioned_text);
