import os
import re
import psycopg2
from dotenv import load_dotenv

load_dotenv()

# ============================================================
# DATABASE CONFIGURATION
# ============================================================

DB_NAME = os.getenv("DB_NAME", "postgres")
DB_USER = os.getenv("DB_USER", "project_se")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "5432")
# ============================================================
# CONNECT TO POSTGRESQL
# ============================================================

conn = psycopg2.connect(
    dbname=DB_NAME,
    user=DB_USER,
    password=DB_PASSWORD,
    host=DB_HOST,
    port=DB_PORT
)

cur = conn.cursor()

print("=" * 60)
print("CHARACTER MENTION EXTRACTION")
print("=" * 60)

def is_likely_non_character_mention(paragraph, alias, character_id):
    """
    Returns True when an alias occurrence is clearly being
    used for something other than the character.
    """

    # Sītā can refer to both the character and a river.
    if character_id == 2 and alias in ("Sītā", "Sita"):

        # Clear linguistic indicators that Sītā is a river.
        river_context = [
            "river",
            "rivers",
            "streams",
            "stream",
            "flowed",
            "flowing",
            "waters",
            "water",
            "Gaṅgā",
            "Sindhu",
            "Sucakṣu"
        ]

        paragraph_lower = paragraph.lower()

        for word in river_context:
            if word.lower() in paragraph_lower:
                # Only reject if the paragraph actually describes
                # Sītā in a geographical/water context.
                if (
                    "sītā" in paragraph_lower
                    and (
                        "river" in paragraph_lower
                        or "streams" in paragraph_lower
                        or "stream" in paragraph_lower
                        or "flowed" in paragraph_lower
                        or "flowing" in paragraph_lower
                        or "waters" in paragraph_lower
                    )
                ):
                    return True

    return False

# ============================================================
# LOAD CHARACTERS + ALIASES
# ============================================================

cur.execute("""
    SELECT
        ca.id,
        ca.character_id,
        ca.alias
    FROM character_aliases ca
    ORDER BY LENGTH(ca.alias) DESC;
""")

aliases = cur.fetchall()

print(f"Loaded {len(aliases)} aliases.")


# ============================================================
# LOAD ALL CHAPTERS
# ============================================================

cur.execute("""
    SELECT
        id,
        chapter_number,
        content
    FROM chapters
    ORDER BY chapter_number;
""")

chapters = cur.fetchall()

print(f"Loaded {len(chapters)} chapters.")
print()


# ============================================================
# PROCESS EACH CHAPTER
# ============================================================

total_mentions = 0

for chapter_id, chapter_number, content in chapters:

    print(f"Processing Chapter {chapter_number}...")

    chapter_mentions = 0

    # --------------------------------------------------------
    # Split chapter into paragraphs
    # --------------------------------------------------------

    paragraphs = re.split(r"\n\s*\n", content)

    for paragraph_number, paragraph in enumerate(paragraphs, start=1):

        if not paragraph.strip():
            continue

        # ----------------------------------------------------
        # Search every alias
        # ----------------------------------------------------

        for alias_id, character_id, alias in aliases:

            # Escape the alias so characters such as
            # parentheses or periods are treated literally.
            escaped_alias = re.escape(alias)

            # Unicode-aware word boundary.
            #
            # (?<!\w) = character before alias isn't a word char
            # (?!\w)  = character after alias isn't a word char
            #
            # This prevents matching:
            #
            # Rama
            # inside
            # Ramasomething
            #
            pattern = r"(?<!\w)" + escaped_alias + r"(?!\w)"
            if is_likely_non_character_mention(
                paragraph,
                alias,
                character_id
            ):
                continue
            for match in re.finditer(pattern, paragraph):

                start_position = match.start()
                end_position = match.end()

                mentioned_text = match.group()

                # ------------------------------------------------
                # Prevent duplicate insertion
                # ------------------------------------------------

                cur.execute("""
                    SELECT 1
                    FROM character_mentions
                    WHERE character_id = %s
                      AND alias_id = %s
                      AND chapter_id = %s
                      AND paragraph_number = %s
                      AND start_position = %s
                      AND end_position = %s
                    LIMIT 1;
                """, (
                    character_id,
                    alias_id,
                    chapter_id,
                    paragraph_number,
                    start_position,
                    end_position
                ))

                already_exists = cur.fetchone()

                if already_exists:
                    continue

                # ------------------------------------------------
                # Insert mention
                # ------------------------------------------------

                cur.execute("""
                    INSERT INTO character_mentions (
                        character_id,
                        alias_id,
                        chapter_id,
                        paragraph_number,
                        mentioned_text,
                        start_position,
                        end_position
                    )
                    VALUES (%s, %s, %s, %s, %s, %s, %s);
                """, (
                    character_id,
                    alias_id,
                    chapter_id,
                    paragraph_number,
                    mentioned_text,
                    start_position,
                    end_position
                ))

                chapter_mentions += 1
                total_mentions += 1

    conn.commit()

    print(
        f"  ✓ Chapter {chapter_number}: "
        f"{chapter_mentions} mentions"
    )


# ============================================================
# FINISH
# ============================================================

cur.close()
conn.close()

print()
print("=" * 60)
print("EXTRACTION COMPLETE")
print("=" * 60)
print(f"Total new character mentions: {total_mentions}")
print("=" * 60)
