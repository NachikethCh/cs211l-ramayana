import os
import re
import psycopg2
from psycopg2.extras import Json
from dotenv import load_dotenv

from entity_resolver import (
    normalize,
    get_extended_context,
    get_local_context,
    resolve_entity,
    score_candidate,
)


# ============================================================
# LOAD ENVIRONMENT AND CONNECT
# ============================================================

load_dotenv("backend/.env")

DB_NAME = os.getenv("DB_NAME", "postgres")
DB_USER = os.getenv("DB_USER", "project_se")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "5432")

SOURCE_ID = 3  # Griffith

conn = psycopg2.connect(
    dbname=DB_NAME,
    user=DB_USER,
    password=DB_PASSWORD,
    host=DB_HOST,
    port=DB_PORT,
)

cur = conn.cursor()

try:
    # ========================================================
    # LOAD ENTITIES AND ALIASES
    # ========================================================

    cur.execute("""
        SELECT e.id, e.name, e.entity_type, ea.alias
        FROM entities e
        JOIN entity_aliases ea ON ea.entity_id = e.id
        ORDER BY LENGTH(ea.alias) DESC, e.id;
    """)

    entity_alias_rows = cur.fetchall()
    entities = {}

    for entity_id, entity_name, entity_type, alias in entity_alias_rows:
        if entity_id not in entities:
            entities[entity_id] = {
                "entity_id": entity_id,
                "entity_name": entity_name,
                "entity_type": entity_type,
                "aliases": [],
                "keywords": [],
            }

        entities[entity_id]["aliases"].append(alias)

    # ========================================================
    # LOAD CONTEXT KEYWORDS
    # ========================================================

    cur.execute("""
        SELECT entity_id, entity_name, entity_type, keyword, weight
        FROM entity_context_keywords
        ORDER BY entity_type, entity_name, id;
    """)

    keyword_rows = cur.fetchall()

    cur.execute("""
        SELECT id, character_id
        FROM entities
        WHERE entity_type = 'CHARACTER'
          AND character_id IS NOT NULL;
    """)

    character_to_entity = {
        character_id: entity_id
        for entity_id, character_id in cur.fetchall()
    }

    for (
        keyword_entity_id,
        keyword_entity_name,
        keyword_entity_type,
        keyword,
        weight,
    ) in keyword_rows:
        target_entity_id = None

        if (
            keyword_entity_type == "CHARACTER"
            and keyword_entity_id is not None
        ):
            target_entity_id = character_to_entity.get(
                keyword_entity_id
            )
        else:
            for entity_id, entity in entities.items():
                if (
                    entity["entity_type"] == keyword_entity_type
                    and entity["entity_name"] == keyword_entity_name
                ):
                    target_entity_id = entity_id
                    break

        if target_entity_id is not None:
            entities[target_entity_id]["keywords"].append({
                "keyword": keyword,
                "weight": weight,
            })

    # ========================================================
    # BUILD ALIAS DETECTOR
    # ========================================================

    alias_records = []

    for entity_id, entity in entities.items():
        for alias in entity["aliases"]:
            alias_records.append({
                "entity_id": entity_id,
                "entity_name": entity["entity_name"],
                "entity_type": entity["entity_type"],
                "alias": alias,
            })

    sorted_aliases = sorted(
        alias_records,
        key=lambda item: len(item["alias"]),
        reverse=True,
    )

    alias_pattern = "|".join(
        re.escape(item["alias"])
        for item in sorted_aliases
    )

    mention_pattern = re.compile(
        r"(?<!\w)(" + alias_pattern + r")(?!\w)",
        flags=re.IGNORECASE,
    )

    def find_candidates(mention):
        normalized_mention = normalize(mention)
        candidate_map = {}

        for entity_id, entity in entities.items():
            for alias in entity["aliases"]:
                if normalize(alias) == normalized_mention:
                    candidate_map[entity_id] = {
                        "entity_id": entity["entity_id"],
                        "entity_name": entity["entity_name"],
                        "entity_type": entity["entity_type"],
                        "keywords": entity["keywords"],
                    }
                    break

        return list(candidate_map.values())

    # ========================================================
    # LOAD GRIFFITH PARAGRAPHS
    # ========================================================

    cur.execute("""
        SELECT ch.id, ch.chapter_number, cp.paragraph_number, cp.content
        FROM chapter_paragraphs cp
        JOIN chapters ch ON ch.id = cp.chapter_id
        JOIN books b ON b.id = ch.book_id
        WHERE b.source_id = %s
        ORDER BY b.book_number, ch.chapter_number, cp.paragraph_number;
    """, (SOURCE_ID,))

    paragraph_rows = cur.fetchall()

    print("=" * 70)
    print("V11 END-TO-END ENTITY RESOLUTION PIPELINE")
    print("=" * 70)
    print(f"\nLoaded entities: {len(entities)}")
    print(f"Loaded aliases: {len(alias_records)}")
    print(f"Loaded paragraphs: {len(paragraph_rows)}")

    total_mentions = 0
    resolved_mentions = 0
    without_context_model = 0
    new_results = []

    result_counts = {
        "CHARACTER": 0,
        "RIVER": 0,
        "AMBIGUOUS": 0,
        "UNKNOWN": 0,
    }

    # ========================================================
    # PROCESS GRIFFITH
    # ========================================================

    for (
        chapter_id,
        chapter_number,
        paragraph_number,
        paragraph,
    ) in paragraph_rows:

        matches = list(mention_pattern.finditer(paragraph))

        for match in matches:
            mention = match.group()
            total_mentions += 1

            candidates = find_candidates(mention)

            candidates_with_context = [
                candidate
                for candidate in candidates
                if candidate["keywords"]
            ]

            extended_context = get_extended_context(
                paragraph,
                match.start(),
                match.end(),
            )

            context = get_local_context(
                extended_context,
                mention,
                window=120,
            )

            # ------------------------------------------------
            # SITA: CHARACTER VS RIVER
            # ------------------------------------------------

            if (
                normalize(mention) in {"sita", "sītā"}
                and len(candidates) > 1
            ):
                character_candidates = [
                    candidate
                    for candidate in candidates
                    if (
                        candidate["entity_type"] == "CHARACTER"
                        and normalize(candidate["entity_name"]) == "sita"
                    )
                ]

                river_candidates = [
                    candidate
                    for candidate in candidates
                    if (
                        candidate["entity_type"] == "RIVER"
                        and normalize(candidate["entity_name"]) == "sita river"
                    )
                ]

                if character_candidates and river_candidates:
                    character_candidate = character_candidates[0]
                    river_candidate = river_candidates[0]

                    # Highest-priority rule: the known geographical
                    # list explicitly names Sita alongside other rivers.
                    river_list_match = re.search(
                        r"\bsuchakshu\b.{0,100}\bsita\b.{0,100}\bsindhu\b",
                        paragraph,
                        flags=re.IGNORECASE | re.DOTALL,
                    )

                    if river_list_match is not None:
                        result = {
                            "mention": mention,
                            "entity": river_candidate["entity_name"],
                            "entity_type": "RIVER",
                            "entity_id": river_candidate["entity_id"],
                            "confidence": 0.95,
                            "matched_context": [
                                "explicit_river_list",
                                "suchakshu",
                                "sindhu",
                            ],
                            "candidates": [],
                        }

                    else:
                        character_score, character_words = score_candidate(
                            context,
                            character_candidate,
                        )

                        river_score, river_words = score_candidate(
                            context,
                            river_candidate,
                        )

                        river_specific_words = {
                            "sindhu",
                            "sucaksu",
                        }

                        river_has_specific_evidence = any(
                            word in river_specific_words
                            for word in river_words
                        )

                        if river_has_specific_evidence:
                            # If river-specific evidence exists outside
                            # the exact list rule, use contextual scoring.
                            result = resolve_entity(
                                mention,
                                context,
                                candidates_with_context,
                            )

                        else:
                            # Generic words such as "stream", "river",
                            # or "waters" alone do not identify Sita River.
                            #
                            # The explicit geographical-list rule above
                            # handles the known river reference. For other
                            # mentions, prefer the character when there is
                            # no specific evidence identifying the river.

                            matched_context = [
                                "sita_character_default"
                            ]

                            if character_score > 0:
                                matched_context = (
                                    character_words
                                    + [
                                        "sita_river_generic_evidence_rejected"
                                    ]
                                )

                            elif river_score > 0:
                                matched_context = [
                                    "sita_river_generic_evidence_rejected"
                                ]

                            result = {
                                "mention": mention,
                                "entity": character_candidate["entity_name"],
                                "entity_type": "CHARACTER",
                                "entity_id": character_candidate["entity_id"],
                                "confidence": 0.90,
                                "matched_context": matched_context,
                                "candidates": [],
                            }

                else:
                    result = resolve_entity(
                        mention,
                        context,
                        candidates_with_context,
                    )

            # ------------------------------------------------
            # GENERAL ENTITY RESOLUTION
            # ------------------------------------------------

            elif len(candidates) == 1:
                candidate = candidates[0]

                if candidate["entity_type"] == "CHARACTER":
                    result = {
                        "mention": mention,
                        "entity": candidate["entity_name"],
                        "entity_type": candidate["entity_type"],
                        "entity_id": candidate["entity_id"],
                        "confidence": 0.90,
                        "matched_context": ["unique_alias_match"],
                        "candidates": [],
                    }

                elif candidates_with_context:
                    result = resolve_entity(
                        mention,
                        context,
                        candidates_with_context,
                    )

                else:
                    without_context_model += 1
                    continue

            elif candidates_with_context:
                result = resolve_entity(
                    mention,
                    context,
                    candidates_with_context,
                )

            else:
                without_context_model += 1
                continue

            # ------------------------------------------------
            # RAMA NAMESAKE EXCEPTION
            # ------------------------------------------------

            namesake_match = re.search(
                r"\bhis\s+namesake\s+rama\s+met\s+and\s+fought\b",
                paragraph,
                flags=re.IGNORECASE,
            )

            if (
                mention.lower() == "rama"
                and namesake_match is not None
                and namesake_match.start()
                <= match.start()
                < namesake_match.end()
            ):
                result = {
                    "mention": mention,
                    "entity": "AMBIGUOUS",
                    "entity_type": None,
                    "entity_id": None,
                    "confidence": 0.0,
                    "matched_context": ["namesake_ambiguity"],
                    "candidates": [],
                }

            # ------------------------------------------------
            # STATUS AND BUFFER
            # ------------------------------------------------

            if result["entity"] == "AMBIGUOUS":
                resolution_status = "AMBIGUOUS"
                result_counts["AMBIGUOUS"] += 1
                resolved_entity_id = None
                resolved_entity_type = None

            elif result["entity"] == "UNKNOWN":
                resolution_status = "UNKNOWN"
                result_counts["UNKNOWN"] += 1
                resolved_entity_id = None
                resolved_entity_type = None

            else:
                resolution_status = "RESOLVED"
                resolved_entity_id = result["entity_id"]
                resolved_entity_type = result["entity_type"]

                if resolved_entity_type in result_counts:
                    result_counts[resolved_entity_type] += 1

            new_results.append((
                chapter_id,
                paragraph_number,
                mention,
                match.start(),
                match.end(),
                context,
                resolved_entity_id,
                resolved_entity_type,
                result["confidence"],
                Json(result["matched_context"]),
                resolution_status,
            ))

            resolved_mentions += 1

    # ========================================================
    # REPLACE GRIFFITH RESULTS ATOMICALLY
    # ========================================================

    try:
        cur.execute("""
            DELETE FROM entity_resolution_results er
            USING chapters ch, books b
            WHERE er.chapter_id = ch.id
              AND ch.book_id = b.id
              AND b.source_id = %s;
        """, (SOURCE_ID,))

        cur.executemany("""
            INSERT INTO entity_resolution_results (
                chapter_id,
                paragraph_number,
                mentioned_text,
                start_position,
                end_position,
                context,
                resolved_entity_id,
                resolved_entity_type,
                confidence,
                matched_context,
                resolution_status
            )
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s);
        """, new_results)

        conn.commit()

    except Exception:
        conn.rollback()
        raise

    print(f"New Griffith results inserted: {len(new_results)}")
    print("\n" + "=" * 70)
    print("V11 PIPELINE SUMMARY")
    print("=" * 70)
    print(f"Total entity mentions detected: {total_mentions}")
    print(f"Mentions with contextual models: {resolved_mentions}")
    print(
        "Mentions waiting for contextual models: "
        f"{without_context_model}"
    )
    print("\nResolution results:")

    for entity_type, count in result_counts.items():
        print(f"{entity_type}: {count}")

    cur.execute("""
        SELECT COUNT(*)
        FROM entity_resolution_results;
    """)

    stored_count = cur.fetchone()[0]
    print(f"\nResults stored in PostgreSQL: {stored_count}")
    print("=" * 70)

finally:
    cur.close()
    conn.close()
