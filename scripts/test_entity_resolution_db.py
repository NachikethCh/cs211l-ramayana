import os
import re
import psycopg2

from dotenv import load_dotenv

from entity_resolver import (
    resolve_entity,
    get_extended_context,
    get_local_context,
    normalize
)


# ============================================================
# LOAD ENVIRONMENT
# ============================================================

load_dotenv("backend/.env")


# ============================================================
# DATABASE CONFIGURATION
# ============================================================

DB_NAME = os.getenv(
    "DB_NAME",
    "postgres"
)

DB_USER = os.getenv(
    "DB_USER",
    "project_se"
)

DB_PASSWORD = os.getenv(
    "DB_PASSWORD"
)

DB_HOST = os.getenv(
    "DB_HOST",
    "localhost"
)

DB_PORT = os.getenv(
    "DB_PORT",
    "5432"
)


# ============================================================
# CONNECT TO DATABASE
# ============================================================

conn = psycopg2.connect(
    dbname=DB_NAME,
    user=DB_USER,
    password=DB_PASSWORD,
    host=DB_HOST,
    port=DB_PORT
)

cur = conn.cursor()


# ============================================================
# LOAD GENERIC ENTITIES
# ============================================================

cur.execute("""
    SELECT
        id,
        name,
        entity_type,
        character_id
    FROM entities
    ORDER BY id;
""")

entity_rows = cur.fetchall()


# ============================================================
# LOAD GENERIC ENTITY ALIASES
# ============================================================

cur.execute("""
    SELECT
        entity_id,
        alias
    FROM entity_aliases
    ORDER BY entity_id, id;
""")

alias_rows = cur.fetchall()


# ============================================================
# BUILD ALIAS MAP
# ============================================================

entity_aliases = {}


for entity_id, alias in alias_rows:

    if entity_id not in entity_aliases:

        entity_aliases[entity_id] = []

    entity_aliases[entity_id].append(
        alias
    )


# ============================================================
# LOAD CONTEXT KEYWORDS
# ============================================================
#
# IMPORTANT:
#
# entity_context_keywords currently still uses:
#
# CHARACTER:
#     entity_id = characters.id
#
# RIVER:
#     entity_id = NULL
#     entity_name = "Sita River"
#
# We bridge those records to the new generic
# entity registry here.
# ============================================================

cur.execute("""
    SELECT
        entity_id,
        entity_name,
        entity_type,
        keyword,
        weight
    FROM entity_context_keywords
    ORDER BY
        entity_type,
        entity_name,
        id;
""")

keyword_rows = cur.fetchall()


# ============================================================
# BUILD CHARACTER_ID → GENERIC_ENTITY_ID MAP
# ============================================================

character_to_entity = {}


for (
    entity_id,
    entity_name,
    entity_type,
    character_id
) in entity_rows:

    if (
        entity_type == "CHARACTER"
        and character_id is not None
    ):

        character_to_entity[
            character_id
        ] = entity_id


# ============================================================
# BUILD ENTITY LOOKUP
# ============================================================

entities = {}


for (
    entity_id,
    entity_name,
    entity_type,
    character_id
) in entity_rows:

    entities[entity_id] = {

        "entity_id": entity_id,

        "entity_name": entity_name,

        "entity_type": entity_type,

        "character_id": character_id,

        "aliases": entity_aliases.get(
            entity_id,
            []
        ),

        "keywords": []
    }


# ============================================================
# ATTACH CONTEXT KEYWORDS
# ============================================================

for (
    keyword_entity_id,
    keyword_entity_name,
    keyword_entity_type,
    keyword,
    weight
) in keyword_rows:

    target_entity_id = None


    # --------------------------------------------------------
    # Existing character context keywords
    # --------------------------------------------------------

    if (
        keyword_entity_type == "CHARACTER"
        and keyword_entity_id is not None
    ):

        target_entity_id = (
            character_to_entity.get(
                keyword_entity_id
            )
        )


    # --------------------------------------------------------
    # Non-character context keywords
    # --------------------------------------------------------

    else:

        for entity_id, entity in entities.items():

            if (
                entity["entity_type"]
                == keyword_entity_type
                and entity["entity_name"]
                == keyword_entity_name
            ):

                target_entity_id = entity_id

                break


    # --------------------------------------------------------
    # Attach keyword
    # --------------------------------------------------------

    if target_entity_id is not None:

        entities[
            target_entity_id
        ]["keywords"].append({

            "keyword": keyword,

            "weight": weight
        })


# ============================================================
# FIND CANDIDATES FOR A MENTION
# ============================================================

def find_candidates(mention):

    normalized_mention = normalize(
        mention
    )

    candidates = []


    for entity_id, entity in entities.items():

        alias_match = False


        # ----------------------------------------------------
        # Check every alias
        # ----------------------------------------------------

        for alias in entity["aliases"]:

            if normalize(alias) == normalized_mention:

                alias_match = True

                break


        if not alias_match:

            continue


        # ----------------------------------------------------
        # Create resolver candidate
        # ----------------------------------------------------

        candidates.append({

            "entity_id":
                entity["entity_id"],

            "entity_name":
                entity["entity_name"],

            "entity_type":
                entity["entity_type"],

            "keywords":
                entity["keywords"]
        })


    return candidates


# ============================================================
# START
# ============================================================

print(
    "=" * 70
)

print(
    "V6 GENERIC ENTITY RESOLUTION"
)

print(
    "=" * 70
)


# ============================================================
# SHOW ENTITY REGISTRY SIZE
# ============================================================

print(
    f"\nLoaded "
    f"{len(entities)} generic entities."
)

print(
    f"Loaded "
    f"{len(alias_rows)} generic aliases."
)


# ============================================================
# TEST CANDIDATE GENERATION
# ============================================================

print(
    "\nTesting candidates for Sītā..."
)


sita_candidates = find_candidates(
    "Sītā"
)


print(
    f"Found "
    f"{len(sita_candidates)} candidates:"
)


for candidate in sita_candidates:

    print(
        f"  "
        f"{candidate['entity_name']} "
        f"({candidate['entity_type']})"
    )


# ============================================================
# FIND REAL SĪTĀ OCCURRENCES
# ============================================================

cur.execute("""
    SELECT
        ch.id,
        ch.chapter_number,
        cp.paragraph_number,
        cp.content
    FROM chapter_paragraphs cp
    JOIN chapters ch
        ON cp.chapter_id = ch.id
    WHERE
        cp.content ILIKE '%Sītā%'
        OR cp.content ILIKE '%Sita%'
    ORDER BY
        ch.chapter_number,
        cp.paragraph_number;
""")

rows = cur.fetchall()


print(
    f"\nFound "
    f"{len(rows)} paragraphs containing "
    f"Sītā/Sita.\n"
)


# ============================================================
# RESULT COUNTS
# ============================================================

total = 0

result_counts = {

    "CHARACTER": 0,

    "RIVER": 0,

    "AMBIGUOUS": 0,

    "UNKNOWN": 0
}


# ============================================================
# PROCESS OCCURRENCES
# ============================================================

for (
    chapter_id,
    chapter_number,
    paragraph_number,
    paragraph
) in rows:


    # --------------------------------------------------------
    # Find each occurrence
    # --------------------------------------------------------

    pattern = (
        r"(?i)(?<!\w)"
        r"(Sītā|Sita)"
        r"(?!\w)"
    )


    matches = list(
        re.finditer(
            pattern,
            paragraph
        )
    )


    for match in matches:

        mention = match.group()


        # ----------------------------------------------------
        # Extended context
        # ----------------------------------------------------

        extended_context = (
            get_extended_context(
                paragraph,
                match.start(),
                match.end()
            )
        )


        # ----------------------------------------------------
        # Local context
        # ----------------------------------------------------

        context = (
            get_local_context(
                extended_context,
                mention,
                window=120
            )
        )


        # ----------------------------------------------------
        # Generic candidate generation
        # ----------------------------------------------------

        candidates = find_candidates(
            mention
        )


        # ----------------------------------------------------
        # Resolve
        # ----------------------------------------------------

        result = resolve_entity(
            mention,
            context,
            candidates
        )


        # ----------------------------------------------------
        # Count result
        # ----------------------------------------------------

        if (
            result["entity_type"]
            in result_counts
        ):

            result_counts[
                result["entity_type"]
            ] += 1

        elif result["entity"] == "AMBIGUOUS":

            result_counts[
                "AMBIGUOUS"
            ] += 1

        elif result["entity"] == "UNKNOWN":

            result_counts[
                "UNKNOWN"
            ] += 1


        total += 1


        # ----------------------------------------------------
        # Display
        # ----------------------------------------------------

        print(
            "\n"
            + "-" * 70
        )


        print(
            f"Chapter {chapter_number}, "
            f"Paragraph {paragraph_number}"
        )


        print(
            f"Mention: {mention}"
        )


        print(
            f"\nContext:\n{context}"
        )


        print(
            f"\nCandidate Count: "
            f"{len(candidates)}"
        )


        print(
            f"Resolved Entity: "
            f"{result['entity']}"
        )


        print(
            f"Entity Type: "
            f"{result['entity_type']}"
        )


        print(
            f"Entity ID: "
            f"{result['entity_id']}"
        )


        print(
            f"Confidence: "
            f"{result['confidence']}"
        )


        print(
            f"Matched Context: "
            f"{result['matched_context']}"
        )


        print(
            "\nCandidates:"
        )


        for candidate in result[
            "candidates"
        ]:

            print(
                f"  "
                f"{candidate['entity_name']} "
                f"({candidate['entity_type']}): "
                f"score="
                f"{candidate['score']}, "
                f"matches="
                f"{candidate['matched_words']}"
            )


# ============================================================
# SUMMARY
# ============================================================

print(
    "\n"
    + "=" * 70
)

print(
    "V6 RESOLUTION SUMMARY"
)

print(
    "=" * 70
)

print(
    f"Total occurrences tested: "
    f"{total}"
)

print(
    f"CHARACTER: "
    f"{result_counts['CHARACTER']}"
)

print(
    f"RIVER: "
    f"{result_counts['RIVER']}"
)

print(
    f"AMBIGUOUS: "
    f"{result_counts['AMBIGUOUS']}"
)

print(
    f"UNKNOWN: "
    f"{result_counts['UNKNOWN']}"
)

print(
    "=" * 70
)


# ============================================================
# CLOSE DATABASE
# ============================================================

cur.close()

conn.close()
