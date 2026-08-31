import os
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


print("=" * 90)
print("CHARACTER EVENT CANDIDATE SUMMARY")
print("=" * 90)


# ============================================================
# SELECT SITA
# ============================================================

cur.execute("""
    SELECT id, name
    FROM characters
    WHERE name = 'Sītā';
""")

character = cur.fetchone()

if character is None:
    print("Sītā was not found.")
    cur.close()
    conn.close()
    exit()


character_id = character[0]
character_name = character[1]


# ============================================================
# GET MENTIONS
# ============================================================

cur.execute("""
    SELECT DISTINCT
        cm.chapter_id,
        ch.chapter_number,
        cm.paragraph_number
    FROM character_mentions cm

    JOIN chapters ch
        ON cm.chapter_id = ch.id

    WHERE cm.character_id = %s
      AND cm.paragraph_number IS NOT NULL

    ORDER BY
        ch.chapter_number,
        cm.paragraph_number;
""", (character_id,))

mentions = cur.fetchall()


# ============================================================
# GROUP NEARBY MENTIONS
# ============================================================

groups = []

current_group = []

previous_chapter = None
previous_paragraph = None


for chapter_id, chapter_number, paragraph_number in mentions:

    if not current_group:

        current_group = [
            (
                chapter_id,
                chapter_number,
                paragraph_number
            )
        ]

    else:

        same_chapter = (
            chapter_id == previous_chapter
        )

        close_paragraph = (
            paragraph_number - previous_paragraph <= 2
        )

        if same_chapter and close_paragraph:

            current_group.append(
                (
                    chapter_id,
                    chapter_number,
                    paragraph_number
                )
            )

        else:

            groups.append(current_group)

            current_group = [
                (
                    chapter_id,
                    chapter_number,
                    paragraph_number
                )
            ]

    previous_chapter = chapter_id
    previous_paragraph = paragraph_number


if current_group:
    groups.append(current_group)


# ============================================================
# PRINT COMPACT SUMMARY
# ============================================================

print(f"Character: {character_name}")
print(f"Total mentions: {len(mentions)}")
print(f"Candidate groups: {len(groups)}")
print()


print(
    f"{'ID':<5}"
    f"{'CHAPTER':<10}"
    f"{'START':<8}"
    f"{'END':<8}"
    f"{'MENTIONS'}"
)

print("-" * 70)


for i, group in enumerate(groups, start=1):

    chapter_number = group[0][1]

    first_mention = group[0][2]
    last_mention = group[-1][2]

    start_paragraph = max(
        1,
        first_mention - 2
    )

    end_paragraph = last_mention + 2

    mention_numbers = ", ".join(
        str(item[2])
        for item in group
    )

    print(
        f"{i:<5}"
        f"{chapter_number:<10}"
        f"{start_paragraph:<8}"
        f"{end_paragraph:<8}"
        f"{mention_numbers}"
    )


# ============================================================
# CLOSE
# ============================================================

cur.close()
conn.close()


print()
print("=" * 90)
print("SUMMARY COMPLETE")
print("=" * 90)
