import os
import re
import psycopg2

from dotenv import load_dotenv

from entity_resolver import normalize


# ============================================================
# LOAD ENVIRONMENT
# ============================================================

load_dotenv("backend/.env")


# ============================================================
# DATABASE CONFIGURATION
# ============================================================

DB_NAME = os.getenv("DB_NAME", "postgres")
DB_USER = os.getenv("DB_USER", "project_se")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "5432")


# ============================================================
# CONNECT
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
# LOAD ALL ENTITIES + ALIASES
# ============================================================

cur.execute("""
    SELECT
        e.id,
        e.name,
        e.entity_type,
        ea.alias
    FROM entities e
    JOIN entity_aliases ea
        ON ea.entity_id = e.id
    ORDER BY
        LENGTH(ea.alias) DESC,
        e.id;
""")

rows = cur.fetchall()


# ============================================================
# BUILD ALIAS RECORDS
# ============================================================

alias_records = []

for (
    entity_id,
    entity_name,
    entity_type,
    alias
) in rows:

    alias_records.append({
        "entity_id": entity_id,
        "entity_name": entity_name,
        "entity_type": entity_type,
        "alias": alias
    })


print("=" * 70)
print("V7 GENERIC ENTITY DETECTION")
print("=" * 70)

print(
    f"\nLoaded {len(alias_records)} entity aliases."
)


# ============================================================
# BUILD ONE REGEX
# ============================================================

# Longest aliases first prevents a shorter alias from
# matching before a longer alias.

sorted_aliases = sorted(
    alias_records,
    key=lambda item: len(item["alias"]),
    reverse=True
)


alias_pattern = "|".join(
    re.escape(item["alias"])
    for item in sorted_aliases
)


pattern = re.compile(
    r"(?<!\w)("
    + alias_pattern
    + r")(?!\w)",
    flags=re.IGNORECASE
)


# ============================================================
# TEST TEXTS
# ============================================================

test_texts = [

    "Rāma went into the forest with Sītā and Lakṣmaṇa.",

    "Rāghava spoke to Sītā before leaving Ayodhyā.",

    "Saumitra followed Rāma into the forest.",

    "The Sītā river flows toward the Sindhu.",

    "Janaka spoke about his daughter Sītā."
]


# ============================================================
# MATCH FUNCTION
# ============================================================

def find_mentions(text):

    mentions = []

    for match in pattern.finditer(text):

        mentioned_text = match.group()

        normalized_mention = normalize(
            mentioned_text
        )

        # Use a dictionary so each entity appears
        # only once even when multiple aliases of
        # the same entity normalize to the same form.
        candidate_map = {}

        for record in alias_records:

            if normalize(
                record["alias"]
            ) != normalized_mention:
                continue

            entity_id = record["entity_id"]

            candidate_map[entity_id] = {

                "entity_id": entity_id,

                "entity_name":
                    record["entity_name"],

                "entity_type":
                    record["entity_type"]
            }

        mentions.append({

            "text": mentioned_text,

            "start": match.start(),

            "end": match.end(),

            "candidates":
                list(candidate_map.values())
        })

    return mentions


# ============================================================
# RUN TESTS
# ============================================================

for text in test_texts:

    print("\n" + "-" * 70)

    print(
        "Text:",
        text
    )

    mentions = find_mentions(text)

    print(
        f"Detected mentions: "
        f"{len(mentions)}"
    )

    for mention in mentions:

        print(
            f"\n  Mention: "
            f"{mention['text']}"
        )

        print(
            f"  Position: "
            f"{mention['start']}-"
            f"{mention['end']}"
        )

        print(
            "  Candidates:"
        )

        for candidate in mention[
            "candidates"
        ]:

            print(
                f"    "
                f"{candidate['entity_name']} "
                f"({candidate['entity_type']}) "
                f"[ID {candidate['entity_id']}]"
            )


# ============================================================
# CLOSE
# ============================================================

cur.close()
conn.close()

print("\n" + "=" * 70)
print("V7 TEST COMPLETE")
print("=" * 70)
