
import os
import re
import sys
from collections import defaultdict

import psycopg2
from dotenv import load_dotenv

load_dotenv("backend/.env")

DB_NAME = os.getenv("DB_NAME", "postgres")
DB_USER = os.getenv("DB_USER", "project_se")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "5432")

SUMITRA_CHARACTER_ID = 11


def is_likely_non_character_mention(paragraph, alias, character_id, match):
    """Filter only the specific known false-positive patterns."""

    # Preserve the existing Sita/river filter for now.
    # This paragraph-level rule needs a more precise contextual model.
    if character_id == 2 and alias in ("Sītā", "Sita"):
        text = paragraph.lower()

        if (
            "sītā" in text
            and any(
                word in text
                for word in (
                    "river", "rivers", "stream", "streams",
                    "flowed", "flowing", "waters", "water"
                )
            )
        ):
            return True

    if character_id == SUMITRA_CHARACTER_ID:
        before = paragraph[:match.start()]
        after = paragraph[match.end():]

        # Examples: "Sumitra's noble son", "Sumitra's valiant son",
        # and "Sumitra's noble child".
        if re.match(
            r"(?i)^\s*['’]s\s+"
            r"(?:(?:noble|valiant|dear|beloved|lovely|"
            r"younger|elder|illustrious|famous|brave)\s+)*"
            r"(?:son|sons|child|children)\b",
            after,
        ):
            return True

        # Examples: "son of Queen Sumitra", "son of Sumitra",
        # and "child of Queen Sumitra".
        if re.search(
            r"(?i)\b(?:son|sons|child|children)\s+of\s+"
            r"(?:Queen\s+)?$",
            before,
        ):
            return True

        # Example: "of Sumitra born".
        if re.match(
            r"(?i)^\s+born\b",
            after,
        ) and re.search(
            r"(?i)\bof\s+$",
            before,
        ):
            return True

    return False


def main():
    conn = None
    cur = None

    inserted_by_source = defaultdict(int)
    processed_chapters_by_source = defaultdict(set)

    try:
        conn = psycopg2.connect(
            dbname=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD,
            host=DB_HOST,
            port=DB_PORT,
        )
        cur = conn.cursor()

        print("=" * 64)
        print("MULTI-SOURCE CHARACTER MENTION EXTRACTION")
        print("=" * 64)

        # Load all registered aliases.
        cur.execute("""
            SELECT id, character_id, alias
            FROM character_aliases
            WHERE alias IS NOT NULL
              AND BTRIM(alias) <> ''
            ORDER BY LENGTH(alias) DESC, id;
        """)
        aliases = cur.fetchall()

        print(f"Aliases loaded: {len(aliases)}")

        # Load paragraphs from every source in the database.
        cur.execute("""
            SELECT
                s.id AS source_id,
                s.title AS source_title,
                b.book_number,
                ch.id AS chapter_id,
                ch.chapter_number,
                cp.paragraph_number,
                cp.content
            FROM sources s
            JOIN books b ON b.source_id = s.id
            JOIN chapters ch ON ch.book_id = b.id
            JOIN chapter_paragraphs cp ON cp.chapter_id = ch.id
            ORDER BY
                s.id,
                b.book_number,
                ch.chapter_number,
                cp.paragraph_number;
        """)

        paragraph_rows = cur.fetchall()

        print(f"Paragraphs loaded: {len(paragraph_rows)}")

        # Load existing mention keys for these paragraphs.
        # This avoids issuing a SELECT for every alias occurrence.
        chapter_ids = list({
            row[3] for row in paragraph_rows
        })

        existing_keys = set()

        if chapter_ids:
            cur.execute("""
                SELECT
                    character_id,
                    alias_id,
                    chapter_id,
                    paragraph_number,
                    start_position,
                    end_position
                FROM character_mentions
                WHERE chapter_id = ANY(%s);
            """, (chapter_ids,))

            existing_keys = set(cur.fetchall())

        print(f"Existing mention records checked: {len(existing_keys)}")

        # Compile patterns once rather than for every paragraph.
        compiled_aliases = []

        for alias_id, character_id, alias in aliases:
            pattern = re.compile(
                r"(?<!\w)" + re.escape(alias) + r"(?!\w)"
            )
            compiled_aliases.append(
                (alias_id, character_id, alias, pattern)
            )

        # Extract missing occurrences.
        for (
            source_id,
            source_title,
            book_number,
            chapter_id,
            chapter_number,
            paragraph_number,
            paragraph,
        ) in paragraph_rows:

            processed_chapters_by_source[source_id].add(chapter_id)

            if not paragraph or not paragraph.strip():
                continue

            for alias_id, character_id, alias, pattern in compiled_aliases:
                for match in pattern.finditer(paragraph):

                    if is_likely_non_character_mention(
                        paragraph, alias, character_id, match
                    ):
                        continue

                    key = (
                        character_id,
                        alias_id,
                        chapter_id,
                        paragraph_number,
                        match.start(),
                        match.end(),
                    )

                    # Avoid duplicates already in the database and
                    # duplicate keys encountered during this run.
                    if key in existing_keys:
                        continue

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
                        match.group(),
                        match.start(),
                        match.end(),
                    ))

                    existing_keys.add(key)
                    inserted_by_source[source_id] += 1

        # One transaction for the complete extraction run.
        conn.commit()

        print()
        print("=" * 64)
        print("EXTRACTION COMPLETE")
        print("=" * 64)

        cur.execute("""
            SELECT id, title
            FROM sources
            ORDER BY id;
        """)
        source_titles = dict(cur.fetchall())

        for source_id in sorted(source_titles):
            print(f"Source {source_id}: {source_titles[source_id]}")
            print(
                "  Chapters processed: "
                f"{len(processed_chapters_by_source[source_id])}"
            )
            print(
                "  New mentions inserted: "
                f"{inserted_by_source[source_id]}"
            )

        print("=" * 64)
        print(f"Total new mentions: {sum(inserted_by_source.values())}")
        print("=" * 64)

    except Exception:
        if conn is not None:
            conn.rollback()

        print(
            "Extraction failed. Database transaction rolled back.",
            file=sys.stderr,
        )
        raise

    finally:
        if cur is not None:
            cur.close()

        if conn is not None:
            conn.close()


if __name__ == "__main__":
    main()
