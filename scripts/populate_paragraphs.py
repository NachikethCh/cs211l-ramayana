import re
import psycopg2
import os
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

print("=" * 60)
print("POPULATING CHAPTER PARAGRAPHS")
print("=" * 60)


# ============================================================
# LOAD CHAPTERS
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

total_paragraphs = 0

for chapter_id, chapter_number, content in chapters:

    print(f"Processing Chapter {chapter_number}...")

    if not content:
        print("  WARNING: Chapter has no content.")
        continue

    # --------------------------------------------------------
    # Split chapter content into paragraphs
    # --------------------------------------------------------

    paragraphs = re.split(r"\n\s*\n", content)

    chapter_paragraphs = 0

    for paragraph_number, paragraph in enumerate(
        paragraphs,
        start=1
    ):

        paragraph = paragraph.strip()

        if not paragraph:
            continue

        # ----------------------------------------------------
        # Insert paragraph
        # ----------------------------------------------------

        cur.execute("""
            INSERT INTO chapter_paragraphs (
                chapter_id,
                paragraph_number,
                content
            )
            VALUES (%s, %s, %s)
            ON CONFLICT (
                chapter_id,
                paragraph_number
            )
            DO NOTHING;
        """, (
            chapter_id,
            paragraph_number,
            paragraph
        ))

        if cur.rowcount > 0:
            chapter_paragraphs += 1
            total_paragraphs += 1

    conn.commit()

    print(
        f"  ✓ Chapter {chapter_number}: "
        f"{chapter_paragraphs} paragraphs"
    )


# ============================================================
# FINISH
# ============================================================

cur.close()
conn.close()

print()
print("=" * 60)
print("PARAGRAPH IMPORT COMPLETE")
print("=" * 60)
print(f"Total paragraphs inserted: {total_paragraphs}")
print("=" * 60)
