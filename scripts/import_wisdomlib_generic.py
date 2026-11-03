#!/usr/bin/env python3

from __future__ import annotations

import argparse
import os
import re
import sys
import time
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import urlparse

import psycopg2
import requests
from dotenv import load_dotenv

def normalize_title(title):
    title = (title or "").strip()
    title = re.sub(r"[\s:;,.–—-]+$", "", title)
    return title

from preview_wisdomlib_source import (
    HEADERS,
    TIMEOUT,
    discover,
    fetch,
)

PROJECT_ROOT = Path(__file__).resolve().parent.parent
load_dotenv(PROJECT_ROOT / "backend" / ".env")

MAX_CHAPTER_SIZE = 5_000_000
REQUEST_DELAY = 0.12


class PageTitleParser(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.active = False
        self.parts = []

    def handle_starttag(self, tag, attrs):
        if tag == "title":
            self.active = True

    def handle_data(self, data):
        if self.active:
            self.parts.append(data)

    def handle_endtag(self, tag):
        if tag == "title":
            self.active = False

    @property
    def title(self):
        return " ".join(" ".join(self.parts).split())


class NarrativeParser(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.active = False
        self.div_depth = 0
        self.in_paragraph = False
        self.skip_footnote = 0
        self.current = []
        self.paragraphs = []

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)

        if not self.active:
            if tag == "div" and attrs.get("id") == "scontent":
                self.active = True
                self.div_depth = 1
            return

        if tag == "section" and "footnotes" in (
            attrs.get("class") or ""
        ).split():
            self.active = False
            self.in_paragraph = False
            self.current = []
            return

        if tag == "div":
            self.div_depth += 1

        if self.skip_footnote:
            if tag == "sup":
                self.skip_footnote += 1
            return

        if tag == "sup" and "ftnt" in (
            attrs.get("class") or ""
        ).split():
            self.skip_footnote = 1
            return

        if tag == "p":
            self.in_paragraph = True
            self.current = []

        elif tag == "br" and self.in_paragraph:
            self.current.append("\n")

    def handle_startendtag(self, tag, attrs):
        self.handle_starttag(tag, attrs)

        if tag not in {
            "br", "img", "hr", "meta", "link", "input"
        }:
            self.handle_endtag(tag)

    def handle_data(self, data):
        if self.active and self.in_paragraph and not self.skip_footnote:
            self.current.append(data)

    def handle_endtag(self, tag):
        if not self.active:
            return

        if self.skip_footnote:
            if tag == "sup":
                self.skip_footnote -= 1
            return

        if tag == "p" and self.in_paragraph:
            value = "".join(self.current).replace("\xa0", " ")
            lines = [
                line.strip()
                for line in value.splitlines()
                if line.strip()
            ]
            value = "\n".join(lines).strip()

            if value and any(ch.isalnum() for ch in value):
                self.paragraphs.append(value)

            self.in_paragraph = False
            self.current = []

        if tag == "div":
            self.div_depth -= 1
            if self.div_depth <= 0:
                self.active = False


def extract_narrative(html):
    parser = NarrativeParser()
    parser.feed(html)
    parser.close()

    if not parser.paragraphs:
        raise RuntimeError(
            "No narrative paragraphs found in #scontent."
        )

    return parser.paragraphs


def get_source_title(session, url):
    html = fetch(session, url)
    parser = PageTitleParser()
    parser.feed(html)

    title = parser.title.strip()
    title = re.sub(
        r"\s*[-|]\s*Wisdom\s*Library\s*$",
        "",
        title,
        flags=re.I,
    ).strip()

    return title or url


def connect_database():
    required = ["DB_NAME", "DB_USER", "DB_PASSWORD"]
    missing = [
        key for key in required
        if not os.getenv(key)
    ]

    if missing:
        raise RuntimeError(
            "Missing database settings in backend/.env: "
            + ", ".join(missing)
        )

    return psycopg2.connect(
        dbname=os.getenv("DB_NAME"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
        host=os.getenv("DB_HOST", "localhost"),
        port=os.getenv("DB_PORT", "5432"),
        connect_timeout=10,
    )


def build_payload(session, source_url, sections):
    payload = []
    seen_urls = set()

    total = sum(len(chapters) for _, chapters in sections)
    print(f"\nDownloading {total} chapter pages...")

    for section, chapters in sections:
        for chapter in chapters:
            url = chapter["url"]

            if url in seen_urls:
                raise RuntimeError(
                    f"Duplicate chapter URL discovered: {url}"
                )

            seen_urls.add(url)

            last_error = None
            paragraphs = None

            for attempt in range(1, 4):
                try:
                    html = fetch(session, url)

                    if len(html) > MAX_CHAPTER_SIZE:
                        raise RuntimeError(
                            f"Page exceeds size limit: {url}"
                        )

                    paragraphs = extract_narrative(html)
                    last_error = None
                    break

                except Exception as exc:
                    last_error = exc
                    if attempt < 3:
                        time.sleep(attempt)

            if last_error is not None:
                raise RuntimeError(
                    f"Could not extract {url}: {last_error}"
                ) from last_error

            if not paragraphs:
                raise RuntimeError(
                    f"No paragraphs extracted from {url}"
                )

            content = "\n\n".join(paragraphs)

            payload.append({
                "section": section,
                "chapter": chapter,
                "paragraphs": paragraphs,
                "content": content,
            })

            print(
                f"\rValidated {len(payload)}/{total} pages",
                end="",
                flush=True,
            )

            time.sleep(REQUEST_DELAY)

    print()

    if not payload:
        raise RuntimeError("Discovery produced no chapter pages.")

    if len(seen_urls) != len(payload):
        raise RuntimeError("Chapter URL validation failed.")

    return payload


def inspect_database(connection, source_url, payload):
    report = {
        "source_id": None,
        "source_exists": False,
        "new_books": 0,
        "existing_books": 0,
        "new_chapters": 0,
        "updated_chapters": 0,
        "unchanged_chapters": 0,
        "new_paragraphs": 0,
        "updated_paragraphs": 0,
        "unchanged_paragraphs": 0,
        "stale_chapters": 0,
    }

    with connection.cursor() as cur:
        cur.execute(
            "SELECT id FROM sources WHERE url = %s ORDER BY id",
            (source_url,),
        )
        source_rows = cur.fetchall()

        if len(source_rows) > 1:
            raise RuntimeError(
                "Multiple sources already use this URL. "
                "Resolve duplicates before importing."
            )

        source_id = source_rows[0][0] if source_rows else None
        report["source_id"] = source_id
        report["source_exists"] = source_id is not None

        if source_id is None:
            chapter_urls = [
                item["chapter"]["url"] for item in payload
            ]

            cur.execute(
                """
                SELECT
                    c.source_url,
                    c.id,
                    c.title,
                    s.id,
                    s.title
                FROM chapters c
                JOIN books b ON b.id = c.book_id
                JOIN sources s ON s.id = b.source_id
                WHERE c.source_url = ANY(%s)
                ORDER BY c.source_url
                """,
                (chapter_urls,),
            )

            collisions = cur.fetchall()

            if collisions:
                details = "\n".join(
                    f"  {row[0]} | chapter_id={row[1]} "
                    f"| {row[2]} | source_id={row[3]} "
                    f"| {row[4]}"
                    for row in collisions
                )

                raise RuntimeError(
                    "New source contains chapter URLs already "
                    "registered in another source:\n" + details
                )

            report["new_books"] = len({
                item["section"]["number"] for item in payload
            })
            report["new_chapters"] = len(payload)
            report["new_paragraphs"] = sum(
                len(item["paragraphs"]) for item in payload
            )
            return report

        cur.execute(
            """
            SELECT id, book_number, name
            FROM books
            WHERE source_id = %s
            """,
            (source_id,),
        )

        existing_books = {
            row[1]: {"id": row[0], "name": row[2]}
            for row in cur.fetchall()
        }

        discovered_book_numbers = set()

        for item in payload:
            section = item["section"]
            chapter = item["chapter"]
            paragraphs = item["paragraphs"]

            book_number = section["number"]
            discovered_book_numbers.add(book_number)

            existing_book = existing_books.get(book_number)

            if existing_book is None:
                report["new_books"] += 1
                report["new_chapters"] += 1
                report["new_paragraphs"] += len(paragraphs)
                continue

            cur.execute(
                """
                SELECT id, book_id, chapter_number, title, content
                FROM chapters
                WHERE source_url = %s
                ORDER BY id
                """,
                (chapter["url"],),
            )
            rows = cur.fetchall()

            if len(rows) > 1:
                raise RuntimeError(
                    f"Duplicate chapter URL in database: {chapter['url']}"
                )

            if not rows:
                report["new_chapters"] += 1
                report["new_paragraphs"] += len(paragraphs)
                continue

            chapter_id, old_book_id, old_number, old_title, old_content = rows[0]

            if old_book_id != existing_book["id"]:
                raise RuntimeError(
                    "Chapter URL is already assigned to a different book: "
                    + chapter["url"]
                )

            changed = (
                old_number != chapter["number"]
                or normalize_title(old_title) != normalize_title(chapter["title"])
                or old_content != item["content"]
            )

            if changed:
                report["updated_chapters"] += 1
            else:
                report["unchanged_chapters"] += 1

            cur.execute(
                """
                SELECT COUNT(*)
                FROM chapter_paragraphs
                WHERE chapter_id = %s
                """,
                (chapter_id,),
            )
            existing_count = cur.fetchone()[0]

            if changed:
                report["updated_paragraphs"] += len(paragraphs)
            elif existing_count == 0:
                report["new_paragraphs"] += len(paragraphs)
            else:
                report["unchanged_paragraphs"] += existing_count

        report["existing_books"] = len(existing_books)
        report["stale_chapters"] = 0

    return report


def apply_import(
    connection,
    source_url,
    source_title,
    author,
    translator,
    year,
    language,
    sections,
    payload,
):
    counts = {
        "new_books": 0,
        "new_chapters": 0,
        "updated_chapters": 0,
        "unchanged_chapters": 0,
        "paragraphs_written": 0,
    }

    with connection:
        with connection.cursor() as cur:
            cur.execute(
                "SELECT pg_advisory_xact_lock(hashtext(%s))",
                (source_url,),
            )

            cur.execute(
                "SELECT id FROM sources WHERE url = %s ORDER BY id",
                (source_url,),
            )
            source_rows = cur.fetchall()

            if len(source_rows) > 1:
                raise RuntimeError(
                    "Duplicate source URLs exist in the database."
                )

            if source_rows:
                source_id = source_rows[0][0]

                cur.execute(
                    """
                    UPDATE sources
                    SET title = %s,
                        author = COALESCE(%s, author),
                        translator = COALESCE(%s, translator),
                        year = COALESCE(%s, year),
                        language = COALESCE(%s, language)
                    WHERE id = %s
                    """,
                    (
                        source_title,
                        author,
                        translator,
                        year,
                        language,
                        source_id,
                    ),
                )
            else:
                cur.execute(
                    """
                    INSERT INTO sources
                        (title, author, translator, year, language, url)
                    VALUES (%s, %s, %s, %s, %s, %s)
                    RETURNING id
                    """,
                    (
                        source_title,
                        author,
                        translator,
                        year,
                        language,
                        source_url,
                    ),
                )
                source_id = cur.fetchone()[0]

            book_ids = {}

            for section, _ in sections:
                number = section["number"]

                if number in book_ids:
                    continue

                name = section["label"]
                slug = re.sub(
                    r"[^a-z0-9]+",
                    "-",
                    name.lower(),
                ).strip("-") or f"section-{number}"

                cur.execute(
                    """
                    SELECT id
                    FROM books
                    WHERE source_id = %s AND book_number = %s
                    ORDER BY id
                    """,
                    (source_id, number),
                )
                rows = cur.fetchall()

                if len(rows) > 1:
                    raise RuntimeError(
                        f"Duplicate book number {number} for source {source_id}"
                    )

                if rows:
                    book_id = rows[0][0]
                    cur.execute(
                        """
                        UPDATE books
                        SET name = %s, slug = %s
                        WHERE id = %s
                        """,
                        (name, slug, book_id),
                    )
                else:
                    cur.execute(
                        """
                        INSERT INTO books
                            (source_id, book_number, name, slug)
                        VALUES (%s, %s, %s, %s)
                        RETURNING id
                        """,
                        (source_id, number, name, slug),
                    )
                    book_id = cur.fetchone()[0]
                    counts["new_books"] += 1

                book_ids[number] = book_id

            for item in payload:
                section = item["section"]
                chapter = item["chapter"]
                paragraphs = item["paragraphs"]
                content = item["content"]

                book_id = book_ids[section["number"]]

                cur.execute(
                    """
                    SELECT id, book_id, chapter_number, title, content
                    FROM chapters
                    WHERE source_url = %s
                    ORDER BY id
                    """,
                    (chapter["url"],),
                )
                rows = cur.fetchall()

                if len(rows) > 1:
                    raise RuntimeError(
                        f"Duplicate chapter URL: {chapter['url']}"
                    )

                if rows:
                    chapter_id, old_book_id, old_number, old_title, old_content = rows[0]

                    if old_book_id != book_id:
                        raise RuntimeError(
                            "Chapter URL belongs to another book: "
                            + chapter["url"]
                        )

                    metadata_changed = (
                        old_number != chapter["number"]
                        or normalize_title(old_title)
                        != normalize_title(chapter["title"])
                    )
                    content_changed = old_content != content

                    if metadata_changed or content_changed:
                        cur.execute(
                            """
                            UPDATE chapters
                            SET chapter_number = %s,
                                title = %s,
                                content = %s
                            WHERE id = %s
                            """,
                            (
                                chapter["number"],
                                chapter["title"],
                                content,
                                chapter_id,
                            ),
                        )
                        counts["updated_chapters"] += 1
                    else:
                        counts["unchanged_chapters"] += 1

                    cur.execute(
                        """
                        SELECT paragraph_number, content
                        FROM chapter_paragraphs
                        WHERE chapter_id = %s
                        ORDER BY paragraph_number
                        """,
                        (chapter_id,),
                    )
                    old_paragraphs = cur.fetchall()

                    expected_paragraphs = list(enumerate(paragraphs, 1))
                    paragraph_rows_match = (
                        old_paragraphs == expected_paragraphs
                    )

                    # Preserve existing paragraph rows whenever their content
                    # already matches. Metadata-only chapter changes must not
                    # invalidate paragraph IDs or downstream annotations.
                    if paragraph_rows_match:
                        continue

                    # Replacing paragraphs can make paragraph-number and text
                    # offsets stored by downstream annotations incorrect.
                    # Abort the whole transaction if annotations already exist.
                    cur.execute(
                        """
                        SELECT
                            (SELECT COUNT(*) FROM character_mentions
                             WHERE chapter_id = %s),
                            (SELECT COUNT(*) FROM character_events
                             WHERE chapter_id = %s),
                            (SELECT COUNT(*) FROM entity_resolution_results
                             WHERE chapter_id = %s)
                        """,
                        (chapter_id, chapter_id, chapter_id),
                    )
                    mention_count, event_count, resolution_count = cur.fetchone()

                    if mention_count or event_count or resolution_count:
                        raise RuntimeError(
                            f"Refusing to replace paragraphs for chapter {chapter_id}: "
                            f"{mention_count} mentions, {event_count} events, "
                            f"{resolution_count} resolution results exist. "
                            "Reprocess annotations explicitly before updating."
                        )

                    # No downstream annotations depend on these paragraphs, so
                    # replacement is safe within this transaction.
                    if old_paragraphs:
                        cur.execute(
                            """
                            DELETE FROM chapter_paragraphs
                            WHERE chapter_id = %s
                            """,
                            (chapter_id,),
                        )

                    cur.executemany(
                        """
                        INSERT INTO chapter_paragraphs
                            (chapter_id, paragraph_number, content)
                        VALUES (%s, %s, %s)
                        """,
                        [
                            (chapter_id, number, paragraph)
                            for number, paragraph in enumerate(paragraphs, 1)
                        ],
                    )
                    counts["paragraphs_written"] += len(paragraphs)
                    continue

                else:
                    cur.execute(
                        """
                        INSERT INTO chapters
                            (book_id, chapter_number, title, source_url, content)
                        VALUES (%s, %s, %s, %s, %s)
                        RETURNING id
                        """,
                        (
                            book_id,
                            chapter["number"],
                            chapter["title"],
                            chapter["url"],
                            content,
                        ),
                    )
                    chapter_id = cur.fetchone()[0]
                    counts["new_chapters"] += 1

                cur.executemany(
                    """
                    INSERT INTO chapter_paragraphs
                        (chapter_id, paragraph_number, content)
                    VALUES (%s, %s, %s)
                    """,
                    [
                        (chapter_id, number, paragraph)
                        for number, paragraph in enumerate(paragraphs, 1)
                    ],
                )
                counts["paragraphs_written"] += len(paragraphs)

    return source_id, counts


def main():
    parser = argparse.ArgumentParser(
        description="Generic WisdomLib source importer"
    )
    parser.add_argument("--url", required=True)
    parser.add_argument("--apply", action="store_true")
    parser.add_argument("--author")
    parser.add_argument("--translator")
    parser.add_argument("--year", type=int)
    parser.add_argument("--language", default="English")
    args = parser.parse_args()

    source_url = args.url.rstrip("/")
    parsed = urlparse(source_url)

    if (
        parsed.scheme not in ("http", "https")
        or not parsed.netloc
        or parsed.netloc.lower() != "www.wisdomlib.org"
    ):
        parser.error("--url must be a valid WisdomLib URL.")

    session = requests.Session()
    session.headers.update(HEADERS)

    try:
        print("=" * 68)
        print("GENERIC WISDOMLIB IMPORTER")
        print("=" * 68)
        print("Source:", source_url)

        source_title = get_source_title(session, source_url)
        sections = discover(session, source_url)

        print("\nDiscovered sections:", len(sections))
        for section, chapters in sections:
            print(
                f"  {section['label']}: "
                f"{len(chapters)} chapter/page links"
            )

        payload = build_payload(session, source_url, sections)

        print("\nSource title:", source_title)
        print("Total validated chapter pages:", len(payload))
        print(
            "Total narrative paragraphs:",
            sum(len(item["paragraphs"]) for item in payload),
        )

        connection = connect_database()

        try:
            report = inspect_database(
                connection,
                source_url,
                payload,
            )

            print("\nDATABASE COMPARISON")
            print("-" * 48)
            print("Existing source:", report["source_exists"])
            print("Source ID:", report["source_id"])
            print("New books:", report["new_books"])
            print("Existing books:", report["existing_books"])
            print("New chapters:", report["new_chapters"])
            print("Updated chapters:", report["updated_chapters"])
            print("Unchanged chapters:", report["unchanged_chapters"])
            print("New paragraph rows:", report["new_paragraphs"])
            print("Updated paragraph rows:", report["updated_paragraphs"])
            print("Unchanged paragraph rows:", report["unchanged_paragraphs"])
            print("Stale chapters: not deleted")

            if not args.apply:
                print("\nDRY RUN COMPLETE.")
                print("No database writes were performed.")
                print("Review the counts before using --apply.")
                return

            print("\n--apply enabled. Starting database transaction.")

            source_id, counts = apply_import(
                connection,
                source_url,
                source_title,
                args.author,
                args.translator,
                args.year,
                args.language,
                sections,
                payload,
            )

            print("\nIMPORT COMMITTED")
            print("Source ID:", source_id)
            for key, value in counts.items():
                print(f"{key}: {value}")

        finally:
            connection.close()

    except Exception as exc:
        print(f"\nIMPORT FAILED: {exc}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
