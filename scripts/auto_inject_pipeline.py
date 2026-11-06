#!/usr/bin/env python3
"""
Unified Automated Database Injection Pipeline for MYTHVERSE.
"""

from __future__ import annotations

import argparse
import os
import re
import sys
from pathlib import Path

import psycopg2
from psycopg2.extras import Json
import requests
from dotenv import load_dotenv

SCRIPT_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = SCRIPT_DIR.parent
if str(SCRIPT_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPT_DIR))

load_dotenv(PROJECT_ROOT / "backend" / ".env")

from entity_resolver import (
    normalize,
    get_extended_context,
    get_local_context,
    resolve_entity,
    score_candidate,
)
from extract_character_mentions import is_likely_non_character_mention
from preview_wisdomlib_source import HEADERS, discover
from import_wisdomlib_generic import (
    get_source_title,
    build_payload,
    apply_import,
)


def get_db_connection():
    return psycopg2.connect(
        dbname=os.getenv("DB_NAME", "postgres"),
        user=os.getenv("DB_USER", "project_se"),
        password=os.getenv("DB_PASSWORD"),
        host=os.getenv("DB_HOST", "localhost"),
        port=os.getenv("DB_PORT", "5432"),
    )


def sync_entity_registry(cur):
    print("\n[Step 1/4] Syncing generic entity registry (`entities` & `entity_aliases`)...")
    cur.execute("""
        INSERT INTO entities (name, entity_type, description, character_id)
        SELECT c.name, 'CHARACTER', c.description, c.id
        FROM characters c
        ON CONFLICT DO NOTHING;
    """)
    entities_added = cur.rowcount

    cur.execute("""
        INSERT INTO entity_aliases (entity_id, alias)
        SELECT e.id, ca.alias
        FROM character_aliases ca
        JOIN entities e ON e.character_id = ca.character_id
        WHERE ca.alias IS NOT NULL AND BTRIM(ca.alias) <> ''
        ON CONFLICT DO NOTHING;
    """)
    aliases_added = cur.rowcount
    print(f"  -> Synced {entities_added} new entities and {aliases_added} new entity aliases.")


def run_resolution_and_mentions(cur, source_ids: list[int]):
    print(f"\n[Step 2/4] Running V11 Entity Resolution & Character Mention Injection for sources: {source_ids}...")

    cur.execute("""
        SELECT e.id, e.name, e.entity_type, e.character_id, ea.alias
        FROM entities e
        JOIN entity_aliases ea ON ea.entity_id = e.id
        ORDER BY LENGTH(ea.alias) DESC, e.id;
    """)
    entities = {}
    for entity_id, entity_name, entity_type, character_id, alias in cur.fetchall():
        if entity_id not in entities:
            entities[entity_id] = {
                "entity_id": entity_id,
                "entity_name": entity_name,
                "entity_type": entity_type,
                "character_id": character_id,
                "aliases": [],
                "keywords": [],
            }
        entities[entity_id]["aliases"].append(alias)

    cur.execute("""
        SELECT id, character_id, alias
        FROM character_aliases
        WHERE alias IS NOT NULL AND BTRIM(alias) <> '';
    """)
    char_alias_lookup = {}
    for alias_id, char_id, alias_text in cur.fetchall():
        char_alias_lookup[(char_id, normalize(alias_text))] = alias_id

    cur.execute("""
        SELECT entity_id, entity_name, entity_type, keyword, weight
        FROM entity_context_keywords
        ORDER BY entity_type, entity_name, id;
    """)
    keyword_rows = cur.fetchall()

    character_to_entity = {
        e["character_id"]: eid
        for eid, e in entities.items()
        if e["entity_type"] == "CHARACTER" and e["character_id"] is not None
    }

    for kw_entity_id, kw_name, kw_type, keyword, weight in keyword_rows:
        target_eid = None
        if kw_type == "CHARACTER" and kw_entity_id is not None:
            target_eid = character_to_entity.get(kw_entity_id)
        else:
            for eid, ent in entities.items():
                if ent["entity_type"] == kw_type and ent["entity_name"] == kw_name:
                    target_eid = eid
                    break
        if target_eid is not None and target_eid in entities:
            entities[target_eid]["keywords"].append({"keyword": keyword, "weight": weight})

    alias_records = [
        {
            "entity_id": eid,
            "entity_name": ent["entity_name"],
            "entity_type": ent["entity_type"],
            "alias": alias,
        }
        for eid, ent in entities.items()
        for alias in ent["aliases"]
    ]
    sorted_aliases = sorted(alias_records, key=lambda x: len(x["alias"]), reverse=True)
    if not sorted_aliases:
        print("  -> No aliases found. Skipping resolution.")
        return

    alias_pattern = "|".join(re.escape(item["alias"]) for item in sorted_aliases)
    mention_pattern = re.compile(r"(?<!\w)(" + alias_pattern + r")(?!\w)", flags=re.IGNORECASE)

    def find_candidates(mention_str):
        norm_m = normalize(mention_str)
        cand_map = {}
        for eid, ent in entities.items():
            for al in ent["aliases"]:
                if normalize(al) == norm_m:
                    cand_map[eid] = {
                        "entity_id": ent["entity_id"],
                        "entity_name": ent["entity_name"],
                        "entity_type": ent["entity_type"],
                        "character_id": ent["character_id"],
                        "keywords": ent["keywords"],
                    }
                    break
        return list(cand_map.values())

    for source_id in source_ids:
        cur.execute("""
            SELECT ch.id, ch.chapter_number, cp.paragraph_number, cp.content
            FROM chapter_paragraphs cp
            JOIN chapters ch ON ch.id = cp.chapter_id
            JOIN books b ON b.id = ch.book_id
            WHERE b.source_id = %s
            ORDER BY b.book_number, ch.chapter_number, cp.paragraph_number;
        """, (source_id,))
        paragraph_rows = cur.fetchall()

        if not paragraph_rows:
            print(f"  -> Source {source_id}: 0 paragraphs found.")
            continue

        chapter_ids = list({r[0] for r in paragraph_rows})
        cur.execute("""
            SELECT character_id, alias_id, chapter_id, paragraph_number, start_position, end_position
            FROM character_mentions
            WHERE chapter_id = ANY(%s);
        """, (chapter_ids,))
        existing_mention_keys = set(cur.fetchall())

        new_resolutions = []
        new_char_mentions = []

        for chapter_id, chapter_number, paragraph_number, paragraph in paragraph_rows:
            if not paragraph or not paragraph.strip():
                continue

            for match in mention_pattern.finditer(paragraph):
                mention = match.group()
                candidates = find_candidates(mention)
                candidates_with_context = [c for c in candidates if c["keywords"]]

                extended_context = get_extended_context(paragraph, match.start(), match.end())
                context = get_local_context(extended_context, mention, window=120)

                if normalize(mention) in {"sita", "sītā"} and len(candidates) > 1:
                    char_cands = [c for c in candidates if c["entity_type"] == "CHARACTER"]
                    river_cands = [c for c in candidates if c["entity_type"] == "RIVER"]
                    if char_cands and river_cands:
                        char_c = char_cands[0]
                        river_c = river_cands[0]
                        river_list_match = re.search(
                            r"\bsuchakshu\b.{0,100}\bsita\b.{0,100}\bsindhu\b|\bsucakṣu\b.{0,100}\bsītā\b.{0,100}\bsindhu\b",
                            paragraph,
                            flags=re.IGNORECASE | re.DOTALL,
                        )
                        if river_list_match is not None:
                            result = {
                                "mention": mention,
                                "entity": river_c["entity_name"],
                                "entity_type": "RIVER",
                                "entity_id": river_c["entity_id"],
                                "confidence": 0.95,
                                "matched_context": ["explicit_river_list", "suchakshu", "sindhu"],
                            }
                        else:
                            c_score, c_words = score_candidate(context, char_c)
                            r_score, r_words = score_candidate(context, river_c)
                            if any(w in {"sindhu", "sucaksu"} for w in r_words):
                                result = resolve_entity(mention, context, candidates_with_context)
                            else:
                                matched_ctx = (
                                    c_words + ["sita_river_generic_evidence_rejected"]
                                    if c_score > 0
                                    else ["sita_character_default"]
                                )
                                result = {
                                    "mention": mention,
                                    "entity": char_c["entity_name"],
                                    "entity_type": "CHARACTER",
                                    "entity_id": char_c["entity_id"],
                                    "confidence": 0.90,
                                    "matched_context": matched_ctx,
                                }
                    else:
                        result = resolve_entity(mention, context, candidates_with_context)

                elif len(candidates) == 1:
                    cand = candidates[0]
                    if cand["entity_type"] == "CHARACTER":
                        result = {
                            "mention": mention,
                            "entity": cand["entity_name"],
                            "entity_type": cand["entity_type"],
                            "entity_id": cand["entity_id"],
                            "confidence": 0.90,
                            "matched_context": ["unique_alias_match"],
                        }
                    elif candidates_with_context:
                        result = resolve_entity(mention, context, candidates_with_context)
                    else:
                        continue
                elif candidates_with_context:
                    result = resolve_entity(mention, context, candidates_with_context)
                else:
                    continue

                namesake_match = re.search(
                    r"\bhis\s+namesake\s+rama\s+met\s+and\s+fought\b",
                    paragraph,
                    flags=re.IGNORECASE,
                )
                if (
                    normalize(mention) == "rama"
                    and namesake_match is not None
                    and namesake_match.start() <= match.start() < namesake_match.end()
                ):
                    result = {
                        "mention": mention,
                        "entity": "AMBIGUOUS",
                        "entity_type": None,
                        "entity_id": None,
                        "confidence": 0.0,
                        "matched_context": ["namesake_ambiguity"],
                    }

                resolved_eid = result.get("entity_id")
                resolved_type = result.get("entity_type")
                if resolved_eid and resolved_type == "CHARACTER":
                    char_id = entities[resolved_eid]["character_id"]
                    if is_likely_non_character_mention(paragraph, mention, char_id, match):
                        continue

                if result["entity"] in ("AMBIGUOUS", "UNKNOWN"):
                    status = result["entity"]
                    resolved_eid = None
                    resolved_type = None
                else:
                    status = "RESOLVED"

                new_resolutions.append((
                    chapter_id,
                    paragraph_number,
                    mention,
                    match.start(),
                    match.end(),
                    context,
                    resolved_eid,
                    resolved_type,
                    result["confidence"],
                    Json(result["matched_context"]),
                    status,
                ))

                if status == "RESOLVED" and resolved_type == "CHARACTER" and resolved_eid:
                    char_id = entities[resolved_eid]["character_id"]
                    alias_id = char_alias_lookup.get((char_id, normalize(mention)))
                    if char_id is not None and alias_id is not None:
                        m_key = (
                            char_id,
                            alias_id,
                            chapter_id,
                            paragraph_number,
                            match.start(),
                            match.end(),
                        )
                        if m_key not in existing_mention_keys:
                            new_char_mentions.append((
                                char_id,
                                alias_id,
                                chapter_id,
                                paragraph_number,
                                mention,
                                match.start(),
                                match.end(),
                            ))
                            existing_mention_keys.add(m_key)

        cur.execute("""
            DELETE FROM entity_resolution_results er
            USING chapters ch, books b
            WHERE er.chapter_id = ch.id
              AND ch.book_id = b.id
              AND b.source_id = %s;
        """, (source_id,))

        if new_resolutions:
            cur.executemany("""
                INSERT INTO entity_resolution_results (
                    chapter_id, paragraph_number, mentioned_text,
                    start_position, end_position, context,
                    resolved_entity_id, resolved_entity_type,
                    confidence, matched_context, resolution_status
                )
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s);
            """, new_resolutions)

        if new_char_mentions:
            cur.executemany("""
                INSERT INTO character_mentions (
                    character_id, alias_id, chapter_id,
                    paragraph_number, mentioned_text,
                    start_position, end_position
                )
                VALUES (%s, %s, %s, %s, %s, %s, %s);
            """, new_char_mentions)

        print(
            f"  -> Source {source_id}: Stored {len(new_resolutions)} resolution results "
            f"and {len(new_char_mentions)} new character mentions."
        )


def summarize_event_window(character_name: str, chapter_title: str, anchor_text: str) -> tuple[str, str]:
    clean_text = " ".join(anchor_text.split())
    sentences = re.split(r"(?<=[.!?])\s+", clean_text)
    chosen_sentence = sentences[0] if sentences else clean_text
    for s in sentences:
        if normalize(character_name) in normalize(s) and len(s) > 25:
            chosen_sentence = s
            break
    words = chosen_sentence.split()
    snippet = " ".join(words[:8]).rstrip(".,;:!?'\"—–-")
    event_title = f"{character_name} in {chapter_title}: {snippet}..."
    summary = " ".join(sentences[:2]).strip()
    if len(summary) > 320:
        summary = summary[:317].rsplit(" ", 1)[0] + "..."
    return event_title, summary


def auto_inject_character_events(cur, source_ids: list[int], max_events_per_char_source: int = 25):
    print(f"\n[Step 3/4] Auto-generating & injecting `character_events` for sources: {source_ids}...")

    cur.execute("SELECT id, name FROM characters ORDER BY id;")
    characters = cur.fetchall()

    total_events_inserted = 0

    for source_id in source_ids:
        for char_id, char_name in characters:
            cur.execute("""
                SELECT COUNT(*)
                FROM character_events ce
                JOIN chapters ch ON ce.chapter_id = ch.id
                JOIN books b ON ch.book_id = b.id
                WHERE ce.character_id = %s AND b.source_id = %s;
            """, (char_id, source_id))
            if cur.fetchone()[0] > 0:
                continue

            cur.execute("""
                SELECT DISTINCT
                    cm.chapter_id,
                    ch.chapter_number,
                    COALESCE(ch.title, 'Chapter ' || ch.chapter_number),
                    cm.paragraph_number
                FROM character_mentions cm
                JOIN chapters ch ON cm.chapter_id = ch.id
                JOIN books b ON b.id = ch.book_id
                WHERE cm.character_id = %s
                  AND b.source_id = %s
                  AND cm.paragraph_number IS NOT NULL
                ORDER BY ch.chapter_number, cm.paragraph_number;
            """, (char_id, source_id))
            mentions = cur.fetchall()

            if not mentions:
                continue

            groups = []
            current_group = []
            prev_chapter = None
            prev_para = None

            for ch_id, ch_num, ch_title, para_num in mentions:
                if not current_group:
                    current_group = [(ch_id, ch_num, ch_title, para_num)]
                else:
                    if ch_id == prev_chapter and (para_num - prev_para <= 2):
                        current_group.append((ch_id, ch_num, ch_title, para_num))
                    else:
                        groups.append(current_group)
                        current_group = [(ch_id, ch_num, ch_title, para_num)]
                prev_chapter = ch_id
                prev_para = para_num

            if current_group:
                groups.append(current_group)

            ranked_groups = sorted(
                groups,
                key=lambda g: (len(g), -g[0][1], -g[0][3]),
                reverse=True,
            )[:max_events_per_char_source]

            ranked_groups.sort(key=lambda g: (g[0][1], g[0][3]))

            events_to_insert = []
            for group in ranked_groups:
                ch_id, ch_num, ch_title, first_para = group[0]
                last_para = group[-1][3]
                para_start = max(1, first_para - 2)
                para_end = last_para + 2
                importance = min(5, len(group))

                cur.execute("""
                    SELECT content, MAX(paragraph_number) OVER ()
                    FROM chapter_paragraphs
                    WHERE chapter_id = %s AND paragraph_number = %s;
                """, (ch_id, first_para))
                row = cur.fetchone()
                if not row:
                    continue

                anchor_text = row[0]
                event_title, event_summary = summarize_event_window(
                    char_name, ch_title, anchor_text
                )

                events_to_insert.append((
                    char_id,
                    ch_id,
                    event_title,
                    event_summary,
                    para_start,
                    para_end,
                    importance,
                ))

            if events_to_insert:
                cur.executemany("""
                    INSERT INTO character_events (
                        character_id,
                        chapter_id,
                        event_title,
                        event_summary,
                        paragraph_start,
                        paragraph_end,
                        importance
                    )
                    VALUES (%s, %s, %s, %s, %s, %s, %s);
                """, events_to_insert)
                total_events_inserted += len(events_to_insert)
                print(
                    f"  -> Source {source_id} | {char_name}: "
                    f"Injected {len(events_to_insert)} story events."
                )

    print(f"  -> Total new character_events injected: {total_events_inserted}")


def main():
    parser = argparse.ArgumentParser(
        description="End-to-End Automated Database Injection Pipeline for MYTHVERSE"
    )
    parser.add_argument("--url", help="Optional WisdomLib URL to scrape and import first")
    parser.add_argument("--author", help="Author name (when importing --url)")
    parser.add_argument("--translator", help="Translator name (when importing --url)")
    parser.add_argument("--year", type=int, help="Publication year (when importing --url)")
    parser.add_argument("--language", default="English", help="Language (default: English)")
    parser.add_argument("--source-id", type=int, help="Run downstream injection for a specific source_id")
    parser.add_argument("--all-sources", action="store_true", help="Run downstream injection for all sources in DB")
    args = parser.parse_args()

    conn = get_db_connection()

    try:
        target_source_ids = []

        if args.url:
            source_url = args.url.rstrip("/")
            session = requests.Session()
            session.headers.update(HEADERS)

            print("=" * 72)
            print(f"[Step 0/4] Scraping WisdomLib Source: {source_url}")
            print("=" * 72)

            source_title = get_source_title(session, source_url)
            sections = discover(session, source_url)
            payload = build_payload(session, source_url, sections)

            source_id, counts = apply_import(
                conn,
                source_url,
                source_title,
                args.author,
                args.translator,
                args.year,
                args.language,
                sections,
                payload,
            )
            print(f"  -> Imported Source ID {source_id}: {counts}")
            target_source_ids.append(source_id)

        with conn:
            with conn.cursor() as cur:
                if args.source_id:
                    target_source_ids.append(args.source_id)
                elif args.all_sources or not target_source_ids:
                    cur.execute("SELECT id FROM sources ORDER BY id;")
                    target_source_ids = [r[0] for r in cur.fetchall()]

                target_source_ids = sorted(set(target_source_ids))

                sync_entity_registry(cur)
                run_resolution_and_mentions(cur, target_source_ids)
                auto_inject_character_events(cur, target_source_ids)

                print("\n[Step 4/4] Verifying Database Table Counts...")
                for table in (
                    "sources",
                    "books",
                    "chapters",
                    "chapter_paragraphs",
                    "characters",
                    "character_aliases",
                    "entities",
                    "entity_aliases",
                    "entity_resolution_results",
                    "character_mentions",
                    "character_events",
                ):
                    cur.execute(f"SELECT COUNT(*) FROM {table};")
                    print(f"  - {table:<28}: {cur.fetchone()[0]} rows")

        print("\n=" * 72)
        print("AUTO-INJECTION PIPELINE COMPLETED SUCCESSFULLY!")
        print("=" * 72)

    finally:
        conn.close()


if __name__ == "__main__":
    main()
