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

from consolidate_aliases import CANONICAL_SYNONYMS, strip_diacritics
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


# Strict exclusion list of non-character capitalized tokens (places, scriptures, castes, concepts, months, etc.)
NON_CHARACTER_TERMS = {
    # English / Structural words
    "the", "they", "them", "their", "he", "him", "his", "she", "her", "it", "its", "we", "us", "our", "you", "your", "sages", "gods", "demigods", "ministers", "kings", "brahmanas", "rishis", "munis", "men", "women", "people", "others", "gosvami", "swami", "maharaja", "bhagavan", "chapter", "section", "book", "canto", "sarga", "part", "verse", "sloka", "shloka", "stanza",
    "thus", "there", "then", "when", "where", "while", "after", "before", "having", "being", "hearing",
    "beholding", "seeing", "knowing", "speaking", "saying", "therefore", "however", "moreover", "furthermore",
    "first", "second", "third", "fourth", "fifth", "sixth", "seventh", "eighth", "ninth", "tenth",
    "north", "south", "east", "west", "heaven", "earth", "hell", "world", "worlds", "universe",
    "king", "queen", "prince", "princess", "monarch", "lord", "lady", "sage", "saint", "hermit", "ascetic",
    "minister", "priest", "brahman", "brahmana", "brahmanas", "brahmin", "brahmins", "kshatriya", "kshatriyas",
    "vaishya", "vaishyas", "shudra", "shudras", "muni", "munis", "rishi", "rishis", "deva", "devas",
    "asura", "asuras", "rakshasa", "rakshasas", "danava", "danavas", "daitya", "daityas", "yaksha", "yakshas",
    "gandharva", "gandharvas", "apsara", "apsaras", "naga", "nagas", "siddha", "siddhas", "pitri", "pitris",
    # Philosophical, Ritual & Scripture terms
    "veda", "vedas", "rigveda", "samaveda", "yajurveda", "atharvaveda", "purana", "puranas", "puranam",
    "upasana", "khanda", "krida", "upanishad", "upanishads", "shastra", "shastras", "smriti", "smritis",
    "itihasa", "mahabharata", "ramayana", "gita", "bhagavadgita", "mantra", "mantras", "tantra", "vidya",
    "yajna", "homa", "puja", "vrata", "tapas", "dharma", "adharma", "karma", "moksha", "mukti", "bhakti",
    "jnana", "yoga", "sankhya", "vedanta", "maya", "prakriti", "purusha", "atman", "brahman", "om", "svaha",
    "svadha", "vashat", "namah", "sattva", "rajas", "tamas", "guna", "gunas", "prana", "manas", "buddhi",
    "ahamkara", "chitta", "kalpa", "yuga", "krita", "treta", "dvapara", "kali", "manvantara",
    # Famous Cities, Regions, Mountains, Rivers, Forests (Places != Characters)
    "ayodhya", "mithila", "lanka", "kishkindha", "panchavati", "chitrakuta", "dandaka", "naimisha",
    "naimisharanya", "kurukshetra", "hastinapura", "indraprastha", "mathura", "dvaraka", "dwarka",
    "kashi", "varanasi", "prayaga", "gaya", "pushkara", "avantika", "ujjayini", "kanchi", "devapura",
    "surashtra", "saurashtra", "bharata", "jambudvipa", "plaksha", "kusha", "krauncha", "shaka", "pushkara",
    "meru", "sumeru", "kailasa", "mandara", "vindhya", "himavat", "himalaya", "malaya", "sahya", "riksha",
    "ganga", "ganges", "yamuna", "sarasvati", "godavari", "narmada", "sindhu", "kaveri", "sarayu", "tamasa",
    "pampa", "ashoka", "svarga", "patala", "naraka", "vaikuntha", "goloka", "satyaloka", "brahmaloka",
    # Common English words that appear capitalized at sentence start
    "some", "many", "all", "both", "each", "every", "other", "others", "another", "such", "what", "which",
    "who", "whom", "whose", "this", "that", "these", "those", "here", "there", "now", "once", "again",
    "great", "holy", "divine", "sacred", "royal", "noble", "wise", "mighty", "blessed", "glorious",
    "listen", "hear", "behold", "speak", "tell", "know", "come", "go", "may", "let", "shall", "will",
}


def auto_discover_characters_for_sources(
    cur,
    source_ids: list[int],
    min_mentions: int = 3,
    interactive: bool = False,
):
    """
    Automatically discovers genuine characters & aliases from chapter_paragraphs.content
    using linguistic role/agency verification (speech verbs, titles, kinship appositives)
    and links aliases to canonical characters without human hardcoding.
    """
    print(f"\n[Step 1A/4] Auto-Discovering Characters & Aliases for sources: {source_ids}...")

    # Build canonical alias lookup from consolidate_aliases.CANONICAL_SYNONYMS
    alias_lookup = {}
    for canonical, aliases in CANONICAL_SYNONYMS.items():
        alias_lookup[strip_diacritics(canonical).lower()] = canonical
        for a in aliases:
            alias_lookup[strip_diacritics(a).lower()] = canonical

    # Load existing DB characters & aliases
    cur.execute("SELECT id, name FROM characters;")
    db_chars = {strip_diacritics(name).lower(): (cid, name) for cid, name in cur.fetchall()}

    cur.execute("SELECT alias, character_id FROM character_aliases;")
    db_aliases = {strip_diacritics(alias).lower(): cid for alias, cid in cur.fetchall()}

    # Regex patterns proving a proper noun is an animate PERSON/DEITY character
    title_before_re = re.compile(
        r"\b(?:king|queen|prince|princess|monarch|sovereign|sage|muni|rishi|maharshi|saint|ascetic|hermit|"
        r"lord|god|goddess|deity|minister|charioteer|bard|suta|preceptor|guru|demon|daitya|danava|rakshasa|"
        r"brother|sister|mother|father|son|daughter|wife|husband|consort|disciple|friend)\s+"
        r"(?:named\s+|called\s+)?([A-ZĀĪŪṚŚṢṬḌṆ][a-zA-Zāīūṛṝḷṃḥṅñṭḍṇśṣ]{2,18})\b"
    )
    appositive_after_re = re.compile(
        r"\b([A-ZĀĪŪṚŚṢṬḌṆ][a-zA-Zāīūṛṝḷṃḥṅñṭḍṇśṣ]{2,18})\s*,?\s+"
        r"(?:the\s+)?(?:king|queen|prince|princess|monarch|sage|muni|rishi|lord|god|goddess|minister|"
        r"son\s+of|daughter\s+of|wife\s+of|consort\s+of|husband\s+of|father\s+of|mother\s+of|brother\s+of)\b"
    )
    agency_verb_re = re.compile(
        r"\b([A-ZĀĪŪṚŚṢṬḌṆ][a-zA-Zāīūṛṝḷṃḥṅñṭḍṇśṣ]{2,18})\s+"
        r"(?:said|spoke|replied|answered|asked|inquired|questioned|addressed|exclaimed|cried|wept|smiled|"
        r"laughed|bowed|saluted|worshipped|prayed|meditated|went|came|departed|entered|arrived|returned|"
        r"fought|slew|killed|struck|protected|rescued|gave|bestowed|granted|cursed|blessed|vowed|heard|beheld|saw)\b"
    )
    vocative_re = re.compile(
        r"\bO\s+([A-ZĀĪŪṚŚṢṬḌṆ][a-zA-Zāīūṛṝḷṃḥṅñṭḍṇśṣ]{2,18})\s*[,!]"
    )
    # Place context detector to reject cities/countries/rivers/mountains
    place_context_re = re.compile(
        r"\b(?:city|town|village|country|kingdom|province|region|land|island|continent|mountain|hill|peak|"
        r"river|stream|lake|ocean|sea|forest|grove|wood|hermitage|palace|temple|shrine)\s+(?:of\s+|called\s+|named\s+)?"
        r"([A-ZĀĪŪṚŚṢṬḌṆ][a-zA-Zāīūṛṝḷṃḥṅñṭḍṇśṣ]{2,18})\b"
        r"|\b(?:in|at|to|from|into|near|towards)\s+([A-ZĀĪŪṚŚṢṬḌṆ][a-zA-Zāīūṛṝḷṃḥṅñṭḍṇśṣ]{2,18})\b"
    )
    proper_token_re = re.compile(r"\b([A-ZĀĪŪṚŚṢṬḌṆ][a-zA-Zāīūṛṝḷṃḥṅñṭḍṇśṣ]{2,18})\b")

    total_new_chars = 0
    total_new_aliases = 0

    for source_id in source_ids:
        cur.execute(
            """
            SELECT cp.content
            FROM chapter_paragraphs cp
            JOIN chapters ch ON cp.chapter_id = ch.id
            JOIN books b ON ch.book_id = b.id
            WHERE b.source_id = %s AND cp.content IS NOT NULL;
            """,
            (source_id,),
        )
        paragraphs = [r[0] for r in cur.fetchall() if r and r[0]]
        if not paragraphs:
            continue

        mention_counts = {}
        person_evidence = {}
        place_hits = {}

        for p in paragraphs:
            # Count general capitalized occurrences
            for m in proper_token_re.finditer(p):
                word = m.group(1)
                norm = strip_diacritics(word).lower()
                if norm in NON_CHARACTER_TERMS or len(norm) < 3:
                    continue
                mention_counts[word] = mention_counts.get(word, 0) + 1

            # Collect strong personhood evidence (titles, appositives, speech/action verbs, vocatives)
            for regex, label in (
                (title_before_re, "title"),
                (appositive_after_re, "role"),
                (agency_verb_re, "action/speech"),
                (vocative_re, "vocative"),
            ):
                for m in regex.finditer(p):
                    word = m.group(1)
                    norm = strip_diacritics(word).lower()
                    if norm in NON_CHARACTER_TERMS:
                        continue
                    if norm not in person_evidence:
                        person_evidence[norm] = {"surface": word, "score": 0, "reasons": set()}
                    person_evidence[norm]["score"] += 2
                    person_evidence[norm]["reasons"].add(label)

            # Track place prepositions ("city of Devapura", "in Surashtra")
            for m in place_context_re.finditer(p):
                w = m.group(1) or m.group(2)
                if w:
                    n = strip_diacritics(w).lower()
                    place_hits[n] = place_hits.get(n, 0) + 1

        # Aggregate mention counts by normalized stem while preserving the most frequent surface form
        norm_totals = {}
        best_surface = {}
        for surface, cnt in mention_counts.items():
            norm = strip_diacritics(surface).lower()
            norm_totals[norm] = norm_totals.get(norm, 0) + cnt
            if norm not in best_surface or cnt > mention_counts.get(best_surface[norm], 0):
                best_surface[norm] = surface

        new_candidates_to_confirm = []

        for norm, total_cnt in sorted(norm_totals.items(), key=lambda x: x[1], reverse=True):
            if total_cnt < min_mentions:
                continue
            if norm in NON_CHARACTER_TERMS:
                continue

            surface = best_surface[norm]

            # 1. Already in DB aliases? Ensure exact spelling is stored
            if norm in db_aliases:
                char_id = db_aliases[norm]
                cur.execute(
                    """
                    INSERT INTO character_aliases (character_id, alias)
                    SELECT %s, %s WHERE NOT EXISTS (
                        SELECT 1 FROM character_aliases WHERE character_id = %s AND LOWER(alias) = LOWER(%s)
                    );
                    """,
                    (char_id, surface, char_id, surface),
                )
                if cur.rowcount > 0:
                    total_new_aliases += 1
                continue

            # 2. Matches an existing DB character name (diacritic-insensitive)? Link as alias
            if norm in db_chars:
                char_id, canon_name = db_chars[norm]
                cur.execute(
                    """
                    INSERT INTO character_aliases (character_id, alias)
                    SELECT %s, %s WHERE NOT EXISTS (
                        SELECT 1 FROM character_aliases WHERE character_id = %s AND LOWER(alias) = LOWER(%s)
                    );
                    """,
                    (char_id, surface, char_id, surface),
                )
                db_aliases[norm] = char_id
                if cur.rowcount > 0:
                    total_new_aliases += 1
                    print(f"  -> [Alias Linked] '{surface}' ({total_cnt} mentions) -> '{canon_name}'")
                continue

            # 3. Matches Canonical Knowledge Graph (CANONICAL_SYNONYMS)? Create/link canonical character
            if norm in alias_lookup:
                canonical_name = alias_lookup[norm]
                canon_norm = strip_diacritics(canonical_name).lower()
                if canon_norm in db_chars:
                    char_id, _ = db_chars[canon_norm]
                else:
                    cur.execute(
                        "INSERT INTO characters (name, description) VALUES (%s, %s) RETURNING id;",
                        (canonical_name, f"Canonical character discovered in source {source_id}."),
                    )
                    char_id = cur.fetchone()[0]
                    db_chars[canon_norm] = (char_id, canonical_name)
                    total_new_chars += 1
                    print(f"  -> [Canonical Character Added] '{canonical_name}' (from '{surface}', {total_cnt} mentions)")

                for al in {canonical_name, surface}:
                    cur.execute(
                        """
                        INSERT INTO character_aliases (character_id, alias)
                        SELECT %s, %s WHERE NOT EXISTS (
                            SELECT 1 FROM character_aliases WHERE character_id = %s AND LOWER(alias) = LOWER(%s)
                        );
                        """,
                        (char_id, al, char_id, al),
                    )
                db_aliases[norm] = char_id
                db_aliases[canon_norm] = char_id
                total_new_aliases += 1
                continue

            # 4. Brand-new standalone character candidate: verify personhood evidence vs place evidence!
            if norm in FORBIDDEN_PRONOUNS or norm in SMALL_TITLE_WORDS or norm.endswith("s"):
                continue
            ev = person_evidence.get(norm)
            # Require at least 2 distinct evidence types (e.g. 'title' + 'action/speech' or 'vocative' + 'action/speech')
            if not ev or ev["score"] < 4 or len(ev["reasons"]) < 2:
                continue
            # Reject if used predominantly as a geographic location ("city of X", "in X") without speech/vocative evidence
            p_hits = place_hits.get(norm, 0)
            if p_hits >= ev["score"] and "action/speech" not in ev["reasons"] and "vocative" not in ev["reasons"]:
                continue

            new_candidates_to_confirm.append({
                "surface": surface,
                "norm": norm,
                "mentions": total_cnt,
                "score": ev["score"],
                "reasons": ", ".join(sorted(ev["reasons"])),
            })

        if new_candidates_to_confirm:
            print(f"\n  -> Source {source_id}: Discovered {len(new_candidates_to_confirm)} new verified characters:")
            for c in new_candidates_to_confirm:
                if interactive:
                    ans = input(
                        f"     Add character '{c['surface']}' ({c['mentions']} mentions | evidence: {c['reasons']})? [Y/n]: "
                    ).strip().lower()
                    if ans in ("n", "no"):
                        continue

                cur.execute(
                    "INSERT INTO characters (name, description) VALUES (%s, %s) RETURNING id;",
                    (c["surface"], f"Character discovered in source {source_id} ({c['reasons']})."),
                )
                char_id = cur.fetchone()[0]
                cur.execute(
                    "INSERT INTO character_aliases (character_id, alias) VALUES (%s, %s);",
                    (char_id, c["surface"]),
                )
                db_chars[c["norm"]] = (char_id, c["surface"])
                db_aliases[c["norm"]] = char_id
                total_new_chars += 1
                total_new_aliases += 1
                print(f"  -> [New Character Added] '{c['surface']}' ({c['mentions']} mentions | {c['reasons']})")

    print(f"  -> Character discovery summary: {total_new_chars} new characters, {total_new_aliases} new aliases linked.")


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


# ============================================================================
# AI + SEMANTIC SVO EVENT HEADING & EXTRACTION ENGINE (ZERO DANGLING PRONOUNS)
# ============================================================================

FORBIDDEN_PRONOUNS = {
    "he", "him", "his", "himself",
    "she", "her", "hers", "herself",
    "they", "them", "their", "theirs",
    "it", "its", "this", "that", "these", "those",
    "who", "whom", "whose", "which", "one", "ones",
    "thou", "thee", "thy", "thine", "ye", "you", "your",
    "i", "me", "my", "mine", "we", "us", "our"
}

SMALL_TITLE_WORDS = {
    "a", "an", "the", "and", "or", "of", "in", "on", "at",
    "to", "for", "with", "by", "from", "into", "upon", "over", "after", "before"
}

_LLM_BACKEND_CACHE = {"checked": False, "type": None, "model": None, "url": None, "key": None}


def _detect_llm_backend() -> dict:
    """Auto-detects Gemini API, OpenAI/Groq API, or local Ollama (used by Open WebUI)."""
    if _LLM_BACKEND_CACHE["checked"]:
        return _LLM_BACKEND_CACHE

    _LLM_BACKEND_CACHE["checked"] = True

    gemini_key = os.getenv("GEMINI_API_KEY")
    if gemini_key:
        _LLM_BACKEND_CACHE.update({"type": "gemini", "key": gemini_key, "model": "gemini-2.5-flash"})
        print("  [AI Engine] Using Gemini API (gemini-2.5-flash) for event heading generation.")
        return _LLM_BACKEND_CACHE

    openai_key = os.getenv("GROQ_API_KEY") or os.getenv("OPENAI_API_KEY")
    if openai_key:
        is_groq = bool(os.getenv("GROQ_API_KEY"))
        _LLM_BACKEND_CACHE.update({
            "type": "openai",
            "key": openai_key,
            "url": "https://api.groq.com/openai/v1/chat/completions" if is_groq else "https://api.openai.com/v1/chat/completions",
            "model": "llama-3.1-8b-instant" if is_groq else "gpt-4o-mini",
        })
        print(f"  [AI Engine] Using {'Groq' if is_groq else 'OpenAI'} API for event heading generation.")
        return _LLM_BACKEND_CACHE

    # Check local Ollama (port 11434 - powers Open WebUI)
    try:
        r = requests.get("http://localhost:11434/api/tags", timeout=1.2)
        if r.status_code == 200:
            models = [m.get("name") for m in r.json().get("models", []) if m.get("name")]
            if models:
                # Prefer fast instruct models if multiple exist
                chosen = models[0]
                for m in models:
                    if any(k in m.lower() for k in ("llama3", "qwen", "mistral", "gemma", "phi")):
                        chosen = m
                        break
                _LLM_BACKEND_CACHE.update({
                    "type": "ollama",
                    "url": "http://localhost:11434/api/generate",
                    "model": chosen,
                })
                print(f"  [AI Engine] Connected to local Ollama model '{chosen}' for event heading generation.")
                return _LLM_BACKEND_CACHE
    except Exception:
        pass

    print("  [AI Engine] Using built-in Semantic SVO + Coreference Engine for event headings.")
    return _LLM_BACKEND_CACHE


def _title_case(text: str) -> str:
    words = text.split()
    out = []
    for i, w in enumerate(words):
        low = w.lower()
        if 0 < i < len(words) - 1 and low in SMALL_TITLE_WORDS:
            out.append(low)
        else:
            out.append(w[:1].upper() + w[1:])
    return " ".join(out)


def _has_dangling_pronoun(heading: str) -> bool:
    tokens = re.findall(r"[a-zA-Zāīūṛṝḷṃḥṅñṭḍṇśṣ]+", heading.lower())
    return any(t in FORBIDDEN_PRONOUNS for t in tokens)


def _call_llm_for_heading(
    character_name: str,
    co_characters: list[str],
    summary: str,
) -> str | None:
    backend = _detect_llm_backend()
    if not backend["type"]:
        return None

    co_str = ", ".join(co_characters) if co_characters else "None"
    prompt = (
        f"Write a concise, self-contained 4 to 7 word Title Case event heading summarizing what happens in this epic passage.\n"
        f"Main Character: {character_name}\n"
        f"Other Characters Present: {co_str}\n"
        f"Passage: {summary}\n\n"
        f"STRICT RULES:\n"
        f"1. Use explicit character names ({character_name}, {co_str}).\n"
        f"2. NEVER use pronouns (he, him, his, she, her, they, them, that one, who, whom).\n"
        f"3. NEVER include chapter numbers or 'Chapter X'.\n"
        f"4. Output ONLY the 4-7 word heading, nothing else."
    )

    try:
        if backend["type"] == "ollama":
            resp = requests.post(
                backend["url"],
                json={"model": backend["model"], "prompt": prompt, "stream": False, "options": {"temperature": 0.1, "num_predict": 25}},
                timeout=6.0,
            )
            if resp.status_code == 200:
                raw = resp.json().get("response", "").strip()
            else:
                return None
        elif backend["type"] == "gemini":
            url = f"https://generativelanguage.googleapis.com/v1beta/models/{backend['model']}:generateContent?key={backend['key']}"
            resp = requests.post(
                url,
                json={"contents": [{"parts": [{"text": prompt}]}], "generationConfig": {"temperature": 0.1, "maxOutputTokens": 25}},
                timeout=6.0,
            )
            if resp.status_code == 200:
                raw = resp.json()["candidates"][0]["content"]["parts"][0]["text"].strip()
            else:
                return None
        elif backend["type"] == "openai":
            resp = requests.post(
                backend["url"],
                headers={"Authorization": f"Bearer {backend['key']}", "Content-Type": "application/json"},
                json={"model": backend["model"], "messages": [{"role": "user", "content": prompt}], "temperature": 0.1, "max_tokens": 25},
                timeout=6.0,
            )
            if resp.status_code == 200:
                raw = resp.json()["choices"][0]["message"]["content"].strip()
            else:
                return None
        else:
            return None

        heading = raw.splitlines()[0].strip(" \"'`.,;:!?—–-*#")
        heading = re.sub(r"^(heading|title|event)\s*:\s*", "", heading, flags=re.I).strip(" \"'`")
        words = heading.split()
        if 3 <= len(words) <= 9 and not _has_dangling_pronoun(heading):
            return _title_case(heading)[:68]
    except Exception:
        return None
    return None


# Semantic Event Templates (Subject + Action + Object/Partner with explicit character names, ZERO pronouns)
SEMANTIC_SCENE_CLASSIFIERS = [
    # (Regex pattern on passage, Template using {char} and {partner})
    (r"\b(enter\w*\s+(?:flaming\s+)?fire|flaming\s+fire|agni\s*pariksha|ordeal\s+by\s+fire)\b", "{char}'s Trial by Fire before {partner}"),
    (r"\b(seen\s+s[iī]t[aā]|sight\s+there\s+of\s+s[iī]t[aā]|present\w*\s+of\s+the\s+ring|a[sś]oka\s+(?:forest|grove))\b", "{partner} Brings News of Sītā in Laṅkā"),
    (r"\b(burnt\s+the\s+vulture|ja[tṭ][aā]yu|kabandha|searching\s+for\s+s[iī]t[aā])\b", "Search for Sītā and Encounter with {partner}"),
    (r"\b(bend\s+the\s+bow|broke\s+the\s+bow|bow\s+of\s+[sś]iva|confer\s+s[iī]t[aā])\b", "Betrothal of {char} and {partner} After the Bow Trial"),
    (r"\b(given\s+away\s+his\s+daughter|water\s+and\s+mantras|united\s+with\s+her\s+lord|marri\w*|wed\w*|nuptial\w*|bride)\b", "Sacred Marriage of {char} and {partner}"),
    (r"\b(passed\s+many\s+a\s+season\s+in\s+delight|heart\s+dedicated\s+to\s+her|enhancing\s+his\s+joy)\b", "Joyful Union of {char} and {partner} in Ayodhyā"),
    (r"\b(two\s+boons|kaikey[iī].*exile|exile\s+of\s+r[aā]ma.*consecration)\b", "Kaikeyī's Two Boons and the Exile Decree"),
    (r"\b(abduct\w*|carried\s+away|seized|r[aā]va[nṇ]a.*place|captiv\w*)\b", "Abduction and Captivity of {char} in Laṅkā"),
    (r"\b(golden\s+deer|m[aā]r[iī]ca)\b", "{char} and the Deception of the Golden Deer"),
    (r"\b(leap\w*\s+across|crossed\s+the\s+ocean|bridge\s+over|setu)\b", "{char} and the Crossing of the Ocean to Laṅkā"),
    (r"\b(slain|slew|killed|fought|battled|arrows?|combat|defeated|vanquished|war)\b", "Fierce Battle Involving {char} and {partner}"),
    (r"\b(exile\w*|banish\w*|forest|wilderness|dandaka|hermitage|citrak[uū][tṭ]a)\b", "Forest Sojourn of {char} and {partner}"),
    (r"\b(coronation|crowned|consecrat\w*|installed\s+on\s+the\s+throne|royal\s+installation)\b", "Royal Consecration of {char} and {partner}"),
    (r"\b(sacrific\w*|yajna|horse[-\s]sacrifice|a[sś]vamedha|altar|oblations?)\b", "{char} and {partner} at the Sacred Sacrifice"),
    (r"\b(boon\w*|penance|tapas|austerit\w*|blessing)\b", "Sacred Penance and Boon of {char}"),
    (r"\b(curs\w*|wrath|anger|doomed)\b", "Fateful Curse and Wrath Involving {char}"),
    (r"\b(vow\w*|oath|promise\w*|pledg\w*)\b", "Sacred Vow of {char} and {partner}"),
    (r"\b(alliance|friendship|sugr[iī]va|ki[sṣ]kindh[aā]|messenger)\b", "Sacred Alliance of {char} and {partner}"),
    (r"\b(counsel\w*|advis\w*|discours\w*|instruct\w*|addressed|converse\w*|reply)\b", "Sacred Counsel of {char} and {partner}"),
]

SOLO_FALLBACK_BY_KEYWORD = [
    (r"\b(flaming\s+fire|agni\s*pariksha|ordeal\s+by\s+fire)\b", "{char}'s Trial by Fire"),
    (r"\b(marri\w*|wed\w*|bride|mantras)\b", "Royal Wedding Ceremony of {char}"),
    (r"\b(bow)\b", "{char} and the Trial of the Sacred Bow"),
    (r"\b(slain|slew|fought|battle|war|arrows?|combat)\b", "{char} in Fierce Battle"),
    (r"\b(exile\w*|banish\w*|forest|hermitage)\b", "{char}'s Journey into Forest Exile"),
    (r"\b(abduct\w*|captiv\w*|a[sś]oka)\b", "{char}'s Captivity in the Aśoka Grove"),
    (r"\b(coronation|crowned|consecrat\w*|throne)\b", "Royal Coronation of {char}"),
    (r"\b(sacrific\w*|yajna|ritual|offering)\b", "{char} Performs the Sacred Ritual"),
    (r"\b(boon\w*|penance|austerit\w*)\b", "Ascetic Penance and Boon of {char}"),
    (r"\b(vow\w*|oath|promise\w*)\b", "Fulfilment of {char}'s Sacred Vow"),
    (r"\b(delight|joy|beloved)\b", "{char}'s Devotion and Royal Joy"),
]


def is_false_positive_char_context(text: str, character_name: str) -> bool:
    """
    Filters out:
    1. Chapter colophons ('Thus ends the sixth chapter of Upasana Khanda...')
    2. Patronymics ('descendant of Bharata', 'son of X')
    3. Similes & metaphors ('like Sita behind Rama', 'like Shiva and Durga', 'like Indra', 'equal to that of Indra', 'I am Rama among...')
    4. Scripture lists ('eighteen minor Puranas such as the Ganesha, Narada...')
    """
    norm_text = normalize(text)
    norm_char = normalize(character_name)
    if not norm_char or norm_char not in norm_text:
        return True

    # Reject chapter colophon footers
    if re.search(r"\bthus\s+ends\s+the\b.*\bchapter\b", norm_text):
        return True

    scrubbed = norm_text
    # Strip patronymics
    scrubbed = re.sub(
        rf"\b(descendants?|sons?|daughters?|race|line|family|house|lineage|seed)\s+of\s+{re.escape(norm_char)}\b",
        " ",
        scrubbed,
    )
    # Strip similes ("like X", "as X", "equal to that of X", "behind X" in simile clauses)
    scrubbed = re.sub(
        rf"\b(i\s+am|like|as|equal\s+to(?:\s+that\s+of)?|resembling)\s+[^.;!?]{{0,45}}\b{re.escape(norm_char)}\b",
        " ",
        scrubbed,
    )
    # Strip Purana title references ("ganesha purana", "minor puranas such as the ganesha")
    scrubbed = re.sub(
        rf"\b{re.escape(norm_char)}\s+purana\b|\bpuranas?\s+such\s+as\s+(?:the\s+)?{re.escape(norm_char)}\b",
        " ",
        scrubbed,
    )
    return re.search(rf"\b{re.escape(norm_char)}\b", scrubbed) is None


def score_narrative_action(text: str) -> int:
    text_low = text.lower()
    if re.search(r"\bthus\s+ends\s+the\b.*\bchapter\b", text_low):
        return 0
    score = 0
    for pattern, _ in SEMANTIC_SCENE_CLASSIFIERS:
        if re.search(pattern, text_low):
            score += 3
    # Boost for clear narrative agency verbs
    agency_hits = len(re.findall(
        r"\b(narrated|recited|told|questioned|asked|worshipped|bowed|went|departed|renounced|crowned|installed|cursed|blessed|healed|instructed|commanded|bound|protected|abandoned)\b",
        text_low,
    ))
    return score + (agency_hits * 2)


ACTION_VERB_HEADINGS = [
    (r"\b(narrated|recited|recounted|related|told)\b.*\b(purana|story|history|tale)\b", "{char} Narrates the Sacred Purāṇa to {partner}", "{char} Narrates the Sacred Purāṇa"),
    (r"\b(listen\w*|heard)\b.*\b(purana|discourse|story)\b", "{char} Listens to the Sacred Discourse of {partner}", "{char} Listens to the Sacred Purāṇa"),
    (r"\b(question\w*|inquir\w*|ask\w*)\b", "{char} Questions {partner} on Sacred Lore", "{char} Seeks Sacred Knowledge"),
    (r"\b(worship\w*|ador\w*|obeisance|supplication|bow\w*|salut\w*)\b", "{char} Offers Sacred Worship with {partner}", "Sacred Worship and Devotion to {char}"),
    (r"\b(renounc\w*|left\s+his\s+kingdom|depart\w*\s+for\s+the\s+forest)\b", "{char} Renounces the Kingdom with {partner}", "{char} Renounces the Royal Kingdom"),
    (r"\b(abandon\w*|cast\s+off|forsak\w*)\b", "Abandonment of {char} in the Forest", "{char} Abandoned in the Wilderness"),
    (r"\b(command\w*|directs\s+the\s+wind|causes\s+the\s+waters|burns\s+in\s+the\s+three\s+worlds|subject\s+to\s+his\s+command)\b", "{char} Executes the Cosmic Command", "Cosmic Authority and Command over {char}"),
    (r"\b(removes\s+obstacles|creates\s+obstacles|ocean\s+of\s+misery)\b", "Grace and Obstacle-Removal of {char}", "Divine Grace of {char}"),
    (r"\b(messengers\s+bound|whipped|punish\w*)\b", "Judgment and Punishment by {char}'s Messengers", "Judgment in the Realm of {char}"),
    (r"\b(incarnation|avatara|divided\s+his\s+divine\s+self)\b", "Divine Incarnation of {char} and {partner}", "Divine Manifestation of {char}"),
    (r"\b(hermitage|ashrama|walked\s+in\s+front)\b", "{char} and {partner} Arrive at the Sacred Hermitage", "{char}'s Arrival at the Hermitage"),
    (r"\b(leprosy|disease|afflict\w*|sins?|healed|cured)\b", "Affliction and Spiritual Healing of {char}", "Redemption and Healing of {char}"),
    (r"\b(minister\w*|counsel\w*|polity|govern\w*)\b", "Royal Counsel of {char} and {partner}", "Royal Governance and Counsel of {char}"),
]


def build_clean_semantic_heading(
    character_name: str,
    summary: str,
    co_characters: list[str] | None = None,
    chapter_title: str = "",
) -> str:
    """
    Generates a descriptive 4-to-8 word event heading strictly from the event content.
    NEVER uses `chapter_title` (like 'The Description of Somakanta' or 'Chapter X').
    """
    co_list = [c for c in (co_characters or []) if normalize(c) != normalize(character_name)]
    partners_in_summary = [c for c in co_list if normalize(c) in normalize(summary)]
    partner = partners_in_summary[0] if partners_in_summary else (co_list[0] if co_list else None)

    # 1. Try LLM first if running
    ai_heading = _call_llm_for_heading(character_name, co_list[:3], summary)
    if ai_heading:
        return ai_heading

    # 2. Check specific narrative & Purana action patterns first
    for pattern, partner_tpl, solo_tpl in ACTION_VERB_HEADINGS:
        if re.search(pattern, summary, flags=re.I):
            if partner:
                return _title_case(partner_tpl.format(char=character_name, partner=partner))[:68]
            return _title_case(solo_tpl.format(char=character_name))[:68]

    # 3. Check Epic Semantic Scene Classifiers
    if partner:
        for pattern, template in SEMANTIC_SCENE_CLASSIFIERS:
            if re.search(pattern, summary, flags=re.I):
                heading = template.format(char=character_name, partner=partner)
                if "News of Sītā" in heading and normalize(character_name) == "sita":
                    heading = f"{partner} Brings Rāma's Ring to Sītā"
                return _title_case(heading)[:68]

    for pattern, solo_tpl in SOLO_FALLBACK_BY_KEYWORD:
        if re.search(pattern, summary, flags=re.I):
            if partner:
                return _title_case(f"{solo_tpl.format(char=character_name)} with {partner}")[:68]
            return _title_case(solo_tpl.format(char=character_name))[:68]

    # 4. Fallback: explicit character interaction heading (never chapter_title!)
    if len(co_list) >= 2:
        return f"Sacred Discourse of {character_name}, {co_list[0]}, and {co_list[1]}"[:68]
    if partner:
        return f"Sacred Dialogue of {character_name} and {partner}"[:68]
    return f"Sacred Narrative of {character_name}"[:68]


def summarize_event_window(
    character_name: str,
    chapter_title: str,
    anchor_text: str,
    co_characters: list[str] | None = None,
    chapter_number: int | None = None,
) -> tuple[str, str]:
    clean_text = " ".join(anchor_text.split())
    sentences = [s.strip() for s in re.split(r"(?<=[.!?])\s+", clean_text) if s.strip()]

    valid_char_sentences = [
        s for s in sentences
        if normalize(character_name) in normalize(s)
        and not is_false_positive_char_context(s, character_name)
        and 25 <= len(s) <= 300
    ]
    if not valid_char_sentences:
        valid_char_sentences = [
            s for s in sentences
            if normalize(character_name) in normalize(s) and 25 <= len(s) <= 300
        ]
    summary_sentences = valid_char_sentences[:2] if valid_char_sentences else sentences[:2]
    summary = " ".join(summary_sentences).strip()
    if len(summary) > 320:
        summary = summary[:317].rsplit(" ", 1)[0] + "..."

    event_title = build_clean_semantic_heading(
        character_name=character_name,
        summary=summary,
        co_characters=co_characters,
        chapter_title=chapter_title,
    )
    return event_title, summary


def auto_inject_character_events(
    cur,
    source_ids: list[int],
    max_events_per_char_source: int = 8,
    interactive: bool = False,
    replace_existing: bool = True,
    character_filter: str | None = None,
):
    mode_label = "INTERACTIVE CONFIRM" if interactive else "FULL AUTO-REBUILD"
    print(f"\n[Step 3/4] Rebuilding High-Importance `character_events` from scratch ({mode_label}) for sources: {source_ids}...")

    if character_filter:
        cur.execute(
            "SELECT id, name FROM characters WHERE LOWER(name) LIKE LOWER(%s) ORDER BY id;",
            (f"%{character_filter}%",),
        )
    else:
        cur.execute("SELECT id, name FROM characters ORDER BY id;")
    characters = cur.fetchall()

    total_events_inserted = 0

    for source_id in source_ids:
        if replace_existing:
            if character_filter and characters:
                char_ids = [c[0] for c in characters]
                cur.execute(
                    """
                    DELETE FROM character_events ce
                    USING chapters ch, books b
                    WHERE ce.chapter_id = ch.id
                      AND ch.book_id = b.id
                      AND b.source_id = %s
                      AND ce.character_id = ANY(%s);
                    """,
                    (source_id, char_ids),
                )
            else:
                cur.execute(
                    """
                    DELETE FROM character_events ce
                    USING chapters ch, books b
                    WHERE ce.chapter_id = ch.id
                      AND ch.book_id = b.id
                      AND b.source_id = %s;
                    """,
                    (source_id,),
                )
            print(f"  -> Cleared old character_events for source_id={source_id} (clean slate, 0 duplicates).")

        source_candidates = []

        for char_id, char_name in characters:
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

            # If a character has mentions in actual narrative chapters (Ch > 4 in Source 2),
            # skip Bala Kanda Chapters 1-4 which are just the Table-of-Contents index summary!
            if source_id == 2:
                non_toc_mentions = [m for m in mentions if m[1] > 4]
                if len(non_toc_mentions) >= 3:
                    mentions = non_toc_mentions

            groups = []
            current_group = []
            prev_chapter = None
            prev_para = None

            for ch_id, ch_num, ch_title, para_num in mentions:
                if not current_group:
                    current_group = [(ch_id, ch_num, ch_title, para_num)]
                else:
                    if ch_id == prev_chapter and (para_num - prev_para <= 3):
                        current_group.append((ch_id, ch_num, ch_title, para_num))
                    else:
                        groups.append(current_group)
                        current_group = [(ch_id, ch_num, ch_title, para_num)]
                prev_chapter = ch_id
                prev_para = para_num

            if current_group:
                groups.append(current_group)

            scored_char_events = []
            seen_titles_for_char = set()
            seen_summaries_for_char = set()

            for group in groups:
                mention_density = len(group)
                ch_id, ch_num, ch_title, first_para = group[0]
                last_para = group[-1][3]
                para_start = max(1, first_para - 1)
                para_end = last_para + 1

                cur.execute("""
                    SELECT content
                    FROM chapter_paragraphs
                    WHERE chapter_id = %s
                      AND paragraph_number BETWEEN %s AND %s
                    ORDER BY paragraph_number;
                """, (ch_id, first_para, last_para))
                anchor_rows = [r[0] for r in cur.fetchall() if r and r[0]]
                if not anchor_rows:
                    continue
                anchor_text = " ".join(anchor_rows)

                if is_false_positive_char_context(anchor_text, char_name):
                    continue

                cur.execute("""
                    SELECT c.name, COUNT(*) AS cnt
                    FROM character_mentions cm
                    JOIN characters c ON cm.character_id = c.id
                    WHERE cm.chapter_id = %s
                      AND cm.paragraph_number BETWEEN %s AND %s
                      AND cm.character_id != %s
                    GROUP BY c.id, c.name
                    ORDER BY cnt DESC, c.name ASC
                    LIMIT 3;
                """, (ch_id, first_para, last_para, char_id))
                co_chars = [r[0] for r in cur.fetchall()]

                action_score = score_narrative_action(anchor_text)

                if action_score < 3 and mention_density < 2:
                    continue
                if mention_density < 2 and len(co_chars) == 0:
                    continue

                relevance_score = (mention_density * 2.5) + (len(co_chars) * 2.5) + min(action_score * 1.5, 9.0)
                if relevance_score < 6.0:
                    continue

                importance = min(5, max(2, int(round(relevance_score / 3.5))))
                event_title, event_summary = summarize_event_window(
                    char_name,
                    ch_title,
                    anchor_text,
                    co_characters=co_chars,
                    chapter_number=ch_num,
                )

                norm_title = normalize(event_title)
                norm_sum = normalize(event_summary[:120])
                if norm_title in seen_titles_for_char or norm_sum in seen_summaries_for_char:
                    continue
                seen_titles_for_char.add(norm_title)
                seen_summaries_for_char.add(norm_sum)

                scored_char_events.append({
                    "char_id": char_id,
                    "char_name": char_name,
                    "ch_id": ch_id,
                    "ch_num": ch_num,
                    "ch_title": ch_title,
                    "event_title": event_title,
                    "event_summary": event_summary,
                    "para_start": para_start,
                    "para_end": para_end,
                    "importance": importance,
                    "mention_density": mention_density,
                    "co_chars": co_chars,
                    "relevance_score": relevance_score,
                })

            top_char_events = sorted(
                scored_char_events,
                key=lambda e: (e["relevance_score"], e["mention_density"], -e["ch_num"]),
                reverse=True,
            )[:max_events_per_char_source]

            top_char_events.sort(key=lambda e: (e["ch_num"], e["para_start"]))
            source_candidates.extend(top_char_events)

        if not source_candidates:
            print(f"  -> Source {source_id}: No high-importance narrative events found.")
            continue

        print(f"\n  -> Source {source_id}: Extracted {len(source_candidates)} unique high-importance events:")
        print("  " + "-" * 96)
        print(f"  {'#':<4} {'CHARACTER':<16} {'CH:PARA':<12} {'IMP':<5} {'EVENT HEADING'}")
        print("  " + "-" * 96)
        for idx, ev in enumerate(source_candidates[:25], start=1):
            loc = f"Ch.{ev['ch_num']}:{ev['para_start']}-{ev['para_end']}"
            print(f"  {idx:<4} {ev['char_name'][:15]:<16} {loc:<12} {ev['importance']}/5   {ev['event_title']}")
            print(f"       Summary: {ev['event_summary'][:110]}...")
        if len(source_candidates) > 25:
            print(f"  ... and {len(source_candidates) - 25} more unique events across remaining characters.")
        print("  " + "-" * 96)

        approved = True
        if interactive:
            ans = input(f"\n  Commit these {len(source_candidates)} events for Source {source_id}? [Y/n]: ").strip().lower()
            if ans in ("n", "no", "q", "quit"):
                approved = False
                print("  -> Skipped.")

        if approved:
            events_to_insert = [
                (
                    ev["char_id"],
                    ev["ch_id"],
                    ev["event_title"],
                    ev["event_summary"],
                    ev["para_start"],
                    ev["para_end"],
                    ev["importance"],
                )
                for ev in source_candidates
            ]
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
            print(f"  -> Source {source_id}: Committed {len(events_to_insert)} unique character_events!")

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
    parser.add_argument("--auto-events", action="store_true", help="Auto-insert high-importance events without interactive [y/n] prompt")
    parser.add_argument("--replace-events", action="store_true", help="Delete existing character_events for target source(s) and regenerate clean ones")
    parser.add_argument("--max-events", type=int, default=8, help="Max top events per character per source (default: 8)")
    parser.add_argument("--character", type=str, default=None, help="Optional character name filter for event extraction")
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

                auto_discover_characters_for_sources(cur, target_source_ids, interactive=not args.auto_events)
                sync_entity_registry(cur)
                run_resolution_and_mentions(cur, target_source_ids)
                auto_inject_character_events(
                    cur,
                    target_source_ids,
                    max_events_per_char_source=args.max_events,
                    interactive=False if args.auto_events else True,
                    replace_existing=True,
                    character_filter=args.character,
                )

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

        print("\n" + "=" * 72)
        print("AUTO-INJECTION PIPELINE COMPLETED SUCCESSFULLY!")
        print("=" * 72)

    finally:
        conn.close()


if __name__ == "__main__":
    main()
