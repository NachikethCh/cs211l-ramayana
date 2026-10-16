"""Read-only entity resolution service for the FastAPI backend."""

import re
import sys
from pathlib import Path

# Reuse the V1-V9 resolver without copying its scoring logic.
PROJECT_ROOT = Path(__file__).resolve().parent.parent
SCRIPTS_DIR = PROJECT_ROOT / "scripts"

if str(SCRIPTS_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPTS_DIR))

from database import get_connection
from entity_resolver import (
    get_extended_context,
    get_local_context,
    normalize,
    resolve_entity,
)


def _load_registry(cursor):
    """Load generic entities, aliases, and their contextual keywords."""

    cursor.execute("""
        SELECT
            e.id,
            e.name,
            e.entity_type,
            e.character_id,
            ea.alias
        FROM entities e
        JOIN entity_aliases ea
            ON ea.entity_id = e.id
        ORDER BY LENGTH(ea.alias) DESC, e.id;
    """)

    entities = {}

    for entity_id, name, entity_type, character_id, alias in cursor.fetchall():
        if entity_id not in entities:
            entities[entity_id] = {
                "entity_id": entity_id,
                "entity_name": name,
                "entity_type": entity_type,
                "character_id": character_id,
                "aliases": [],
                "keywords": [],
            }

        entities[entity_id]["aliases"].append(alias)

    # The keyword table's entity_id refers to characters.id for
    # character keywords, not to entities.id. Map those IDs explicitly.
    character_to_entity = {
        entity["character_id"]: entity_id
        for entity_id, entity in entities.items()
        if (
            entity["entity_type"] == "CHARACTER"
            and entity["character_id"] is not None
        )
    }

    entity_by_type_name = {
        (entity["entity_type"], entity["entity_name"]): entity_id
        for entity_id, entity in entities.items()
    }

    cursor.execute("""
        SELECT entity_id, entity_name, entity_type, keyword, weight
        FROM entity_context_keywords
        ORDER BY entity_type, entity_name, id;
    """)

    for keyword_entity_id, keyword_entity_name, keyword_entity_type, keyword, weight in cursor.fetchall():
        if keyword_entity_type == "CHARACTER" and keyword_entity_id is not None:
            target_entity_id = character_to_entity.get(keyword_entity_id)
        else:
            target_entity_id = entity_by_type_name.get(
                (keyword_entity_type, keyword_entity_name)
            )

        if target_entity_id is not None:
            entities[target_entity_id]["keywords"].append({
                "keyword": keyword,
                "weight": weight,
            })

    # Allow aliases that differ only by diacritics to share candidates.
    normalized_alias_to_ids = {}

    all_aliases = set()

    for entity_id, entity in entities.items():
        for alias in entity["aliases"]:
            all_aliases.add(alias)
            normalized_alias_to_ids.setdefault(
                normalize(alias), set()
            ).add(entity_id)

    # Prefer longer aliases, e.g. "Sita River", over shorter
    # aliases when both could match the same part of the text.
    sorted_aliases = sorted(
        all_aliases,
        key=len,
        reverse=True,
    )

    mention_pattern = None

    if sorted_aliases:
        alias_pattern = "|".join(
            re.escape(alias) for alias in sorted_aliases
        )
        mention_pattern = re.compile(
            r"(?<!\w)(" + alias_pattern + r")(?!\w)",
            flags=re.IGNORECASE,
        )

    return entities, normalized_alias_to_ids, mention_pattern


def _find_candidates(mention, entities, normalized_alias_to_ids):
    """Return every generic entity matching the detected alias."""

    entity_ids = normalized_alias_to_ids.get(normalize(mention), set())

    candidates = []

    for entity_id in sorted(entity_ids):
        entity = entities[entity_id]

        candidates.append({
            "entity_id": entity["entity_id"],
            "entity_name": entity["entity_name"],
            "entity_type": entity["entity_type"],
            "keywords": entity["keywords"],
        })

    return candidates


def resolve_text(text: str) -> dict:
    """
    Detect known aliases in arbitrary text and resolve them using
    the existing rule-based contextual resolver.

    This function does not insert, update, or delete database rows.
    """

    connection = get_connection()

    try:
        with connection.cursor() as cursor:
            entities, alias_index, mention_pattern = _load_registry(cursor)

            if mention_pattern is None:
                return {
                    "method": "rule_based_contextual_keywords",
                    "input_text": text,
                    "mention_count": 0,
                    "results": [],
                    "message": "No entity aliases are configured in the database.",
                }

            results = []

            for match in mention_pattern.finditer(text):
                mention = match.group()
                candidates = _find_candidates(
                    mention,
                    entities,
                    alias_index,
                )

                extended_context = get_extended_context(
                    text,
                    match.start(),
                    match.end(),
                )

                context = get_local_context(
                    extended_context,
                    mention,
                    window=120,
                )

                # A unique alias needs no contextual disambiguation.
                if len(candidates) == 1:
                    candidate = candidates[0]

                    resolution = {
                        "mention": mention,
                        "entity": candidate["entity_name"],
                        "entity_type": candidate["entity_type"],
                        "entity_id": candidate["entity_id"],
                        "confidence": 1.0,
                        "matched_context": [],
                        "candidates": [{
                            "entity_id": candidate["entity_id"],
                            "entity_name": candidate["entity_name"],
                            "entity_type": candidate["entity_type"],
                            "score": 0,
                            "matched_words": [],
                        }],
                    }
                    resolution_basis = "UNIQUE_ALIAS"

                else:
                    # Shared aliases need contextual disambiguation.
                    resolution = resolve_entity(
                        mention,
                        context,
                        candidates,
                    )
                    resolution_basis = "CONTEXTUAL_KEYWORDS"

                if resolution["entity"] == "AMBIGUOUS":
                    status = "AMBIGUOUS"
                    resolved_entity = None

                elif resolution["entity"] == "UNKNOWN":
                    status = "UNKNOWN"
                    resolved_entity = None

                else:
                    status = "RESOLVED"
                    resolved_entity = {
                        "id": resolution["entity_id"],
                        "name": resolution["entity"],
                        "type": resolution["entity_type"],
                    }

                results.append({
                    "mention": mention,
                    "start_position": match.start(),
                    "end_position": match.end(),
                    "context": context,
                    "resolution_status": status,
                    "resolution_basis": resolution_basis,
                    "resolved_entity": resolved_entity,
                    "confidence": resolution["confidence"],
                    "matched_context": resolution["matched_context"],
                    "candidates": [
                        {
                            "entity_id": candidate["entity_id"],
                            "name": candidate["entity_name"],
                            "type": candidate["entity_type"],
                            "score": candidate["score"],
                            "matched_context": candidate["matched_words"],
                        }
                        for candidate in resolution["candidates"]
                    ],
                })

            return {
                "method": "rule_based_contextual_keywords",
                "input_text": text,
                "mention_count": len(results),
                "results": results,
                "message": (
                    "Resolution completed."
                    if results
                    else "No known entity aliases were found in the input text."
                ),
            }

    finally:
        connection.close()
