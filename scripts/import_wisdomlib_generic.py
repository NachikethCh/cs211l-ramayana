#!/usr/bin/env python3

import argparse
import getpass
import os
import re
import time
from html.parser import HTMLParser
from urllib.parse import urljoin, urlparse

import requests


DEFAULT_URL = (
    "https://www.wisdomlib.org/hinduism/book/"
    "ramayana-of-valmiki-griffith"
)

HEADERS = {
    "User-Agent": "Mozilla/5.0 (compatible; MythverseImporter/1.0)"
}

ROMAN = r"[IVXLCDM]+"

BOOK_RE = re.compile(rf"^Book\s+({ROMAN})\b", re.I)

CHAPTER_RE = re.compile(
    rf"^Chapter\s+({ROMAN})\b\s*(?:-\s*)?:?\s*(.*)$",
    re.I,
)


def roman_to_int(value):
    values = {
        "I": 1,
        "V": 5,
        "X": 10,
        "L": 50,
        "C": 100,
        "D": 500,
        "M": 1000,
    }

    value = value.upper()
    total = 0
    previous = 0

    for char in reversed(value):
        number = values[char]
        total += -number if number < previous else number
        previous = number

    return total


def slugify(value):
    value = value.lower()
    value = re.sub(r"[^a-z0-9]+", "-", value)
    return value.strip("-")


class LinkParser(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.links = []
        self.href = None
        self.parts = []

    def handle_starttag(self, tag, attrs):
        if tag == "a":
            self.href = dict(attrs).get("href")
            self.parts = []

    def handle_data(self, data):
        if self.href is not None:
            self.parts.append(data)

    def handle_endtag(self, tag):
        if tag == "a" and self.href is not None:
            label = " ".join(" ".join(self.parts).split())

            if label:
                self.links.append((label, self.href))

            self.href = None
            self.parts = []


class TitleParser(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.in_title = False
        self.parts = []

    def handle_starttag(self, tag, attrs):
        if tag == "title":
            self.in_title = True

    def handle_data(self, data):
        if self.in_title:
            self.parts.append(data)

    def handle_endtag(self, tag):
        if tag == "title":
            self.in_title = False

    @property
    def title(self):
        return " ".join(" ".join(self.parts).split())


class ParagraphParser(HTMLParser):
    """Extract paragraphs while excluding inline footnote markers."""

    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.in_p = False
        self.skip_footnote_depth = 0
        self.current = []
        self.paragraphs = []

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)

        if self.skip_footnote_depth:
            if tag == "sup":
                self.skip_footnote_depth += 1
            return

        if tag == "sup" and "ftnt" in attrs.get("class", "").split():
            self.skip_footnote_depth = 1
            return

        if tag == "p":
            self.in_p = True
            self.current = []

        elif tag == "br" and self.in_p:
            self.current.append("\n")

    def handle_startendtag(self, tag, attrs):
        self.handle_starttag(tag, attrs)

        if tag == "br" and self.in_p and not self.skip_footnote_depth:
            return

        self.handle_endtag(tag)

    def handle_data(self, data):
        if self.in_p and not self.skip_footnote_depth:
            self.current.append(data)

    def handle_endtag(self, tag):
        if self.skip_footnote_depth:
            if tag == "sup":
                self.skip_footnote_depth -= 1
            return

        if tag == "p" and self.in_p:
            text = "".join(self.current).replace("\xa0", " ")

            lines = [
                line.strip()
                for line in text.splitlines()
                if line.strip()
            ]

            text = "\n".join(lines).strip()

            if text and text != "\xa0":
                self.paragraphs.append(text)

            self.in_p = False
            self.current = []


def fetch(session, url):
    response = session.get(url, timeout=30)
    response.raise_for_status()
    return response.text


def same_source(url, source_url):
    candidate = urlparse(url)
    base = urlparse(source_url)

    return (
        candidate.scheme in ("http", "https")
        and candidate.netloc == base.netloc
        and candidate.path.startswith(base.path.rstrip("/") + "/")
    )


def get_page_title(html):
    parser = TitleParser()
    parser.feed(html)
    return parser.title


def discover_books(session, source_url):
    html = fetch(session, source_url)
    page_title = get_page_title(html)

    parser = LinkParser()
    parser.feed(html)

    books = []
    seen_urls = set()

    for label, href in parser.links:
        match = BOOK_RE.match(label)

        if not match or not href:
            continue

        url = urljoin(source_url, href).split("#", 1)[0]

        if not same_source(url, source_url) or url in seen_urls:
            continue

        seen_urls.add(url)
        number = roman_to_int(match.group(1))

        books.append(
            {
                "number": number,
                "name": f"Book {match.group(1).upper()}",
                "slug": f"book-{number}",
                "url": url,
            }
        )

    books.sort(key=lambda item: item["number"])

    if not books:
        raise RuntimeError(
            "No book pages discovered. Refusing to continue."
        )

    return page_title, books


def discover_chapters(session, source_url, book):
    html = fetch(session, book["url"])

    parser = LinkParser()
    parser.feed(html)

    chapters = []
    seen_urls = set()

    for label, href in parser.links:
        match = CHAPTER_RE.match(label)

        if not match or not href:
            continue

        url = urljoin(book["url"], href).split("#", 1)[0]

        if not same_source(url, source_url) or url in seen_urls:
            continue

        seen_urls.add(url)
        title = (match.group(2) or "").strip()

        chapters.append(
            {
                "number": roman_to_int(match.group(1)),
                "label": label,
                "title": title or label,
                "url": url,
            }
        )

    # Chapter numbers can repeat or have gaps. Do not deduplicate by number.
    chapters.sort(key=lambda item: item["url"])

    if not chapters:
        raise RuntimeError(
            f"No chapter links found on {book['url']}"
        )

    return chapters


class NarrativeContainerParser(HTMLParser):
    """Extract narrative paragraphs only from the #scontent container."""

    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.active = False
        self.div_depth = 0
        self.in_p = False
        self.skip_ftnt = 0
        self.current = []
        self.paragraphs = []

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)

        if not self.active:
            if tag == "div" and attrs.get("id") == "scontent":
                self.active = True
                self.div_depth = 1
            return

        # Stop before the explanatory footnotes section, if present.
        if tag == "section" and "footnotes" in (
            attrs.get("class") or ""
        ).split():
            self.active = False
            self.in_p = False
            self.current = []
            return

        if tag == "div":
            self.div_depth += 1

        if self.skip_ftnt:
            if tag == "sup":
                self.skip_ftnt += 1
            return

        if tag == "sup" and "ftnt" in (
            attrs.get("class") or ""
        ).split():
            self.skip_ftnt = 1
            return

        if tag == "p":
            self.in_p = True
            self.current = []

        elif tag == "br" and self.in_p:
            self.current.append("\n")

    def handle_startendtag(self, tag, attrs):
        self.handle_starttag(tag, attrs)

        if tag not in {
            "br",
            "img",
            "hr",
            "meta",
            "link",
            "input",
        }:
            self.handle_endtag(tag)

    def handle_data(self, data):
        if self.active and self.in_p and not self.skip_ftnt:
            self.current.append(data)

    def handle_endtag(self, tag):
        if not self.active:
            return

        if self.skip_ftnt:
            if tag == "sup":
                self.skip_ftnt -= 1
            return

        if tag == "p" and self.in_p:
            value = "".join(self.current).replace("\xa0", " ")

            lines = [
                line.strip()
                for line in value.splitlines()
                if line.strip()
            ]

            value = "\n".join(lines).strip()

            # Ignore formatting-only separators such as "* * * * *".
            if value and any(ch.isalnum() for ch in value):
                self.paragraphs.append(value)

            self.in_p = False
            self.current = []

        if tag == "div":
            self.div_depth -= 1

            if self.div_depth == 0:
                self.active = False


def extract_narrative(html):
    parser = NarrativeContainerParser()
    parser.feed(html)
    parser.close()

    if not parser.active and not parser.paragraphs:
        raise RuntimeError(
            "No narrative paragraphs extracted from #scontent."
        )

    if not parser.paragraphs:
        raise RuntimeError("No narrative paragraphs extracted.")

    return parser.paragraphs


def preview(session, source_url):
    title, books = discover_books(session, source_url)

    print(f"\nSource title: {title or source_url}")
    print(f"Source URL:   {source_url}")
    print(f"Books found:  {len(books)}")

    total = 0
    first_chapter = None

    for book in books:
        chapters = discover_chapters(session, source_url, book)
        total += len(chapters)

        print(f"\n{book['name']}: {len(chapters)} chapters")
        print(f"  URL: {book['url']}")

        for chapter in chapters[:2]:
            print(
                f"  Chapter {chapter['number']}: "
                f"{chapter['title']} -> {chapter['url']}"
            )

        if first_chapter is None:
            first_chapter = (book, chapters[0])

    print(f"\nTotal chapter links: {total}")

    if first_chapter:
        book, chapter = first_chapter
        html = fetch(session, chapter["url"])
        paragraphs = extract_narrative(html)

        print(f"\nSample chapter: {chapter['label']}")
        print(f"Extracted narrative paragraphs: {len(paragraphs)}")

        print("\nFirst 2 paragraphs:")
        for paragraph in paragraphs[:2]:
            print(" -", paragraph[:180])

        print("\nLast paragraph preview:")
        print(paragraphs[-1][:250])

    print("\nPREVIEW ONLY: no database writes.")

    return title, books


EXPECTED_CHAPTERS_PER_BOOK = {
    1: 75,
    2: 119,
    3: 76,
    4: 67,
    5: 55,
    6: 102,
}


def validate_all(session, source_url, books):
    """Download and validate all chapters without accessing the database."""

    if len(books) != 6:
        raise RuntimeError(
            f"Expected 6 books, discovered {len(books)}."
        )

    actual_book_numbers = sorted(book["number"] for book in books)

    if actual_book_numbers != [1, 2, 3, 4, 5, 6]:
        raise RuntimeError(
            f"Unexpected book numbers: {actual_book_numbers}"
        )

    payload = []
    all_urls = set()

    print("\nVALIDATION ONLY: downloading all chapter pages.")
    print("No database connection will be opened.\n")

    for book in books:
        chapters = discover_chapters(session, source_url, book)
        expected = EXPECTED_CHAPTERS_PER_BOOK[book["number"]]

        if len(chapters) != expected:
            raise RuntimeError(
                f"{book['name']}: expected {expected} chapters, "
                f"discovered {len(chapters)}."
            )

        print(
            f"{book['name']}: {len(chapters)} chapter links verified."
        )

        for chapter in chapters:
            url = chapter["url"]

            if url in all_urls:
                raise RuntimeError(f"Duplicate chapter URL: {url}")

            all_urls.add(url)

            last_error = None
            paragraphs = None

            # Retry transient fetch or parsing failures up to 3 times.
            for attempt in range(1, 4):
                try:
                    html = fetch(session, url)
                    paragraphs = extract_narrative(html)
                    last_error = None
                    break

                except Exception as exc:
                    last_error = exc

                    if attempt < 3:
                        print(
                            f"\nRetry {attempt + 1}/3 for {url} "
                            f"after: {exc}",
                            flush=True,
                        )
                        time.sleep(1.0 * attempt)

            if last_error is not None or not paragraphs:
                raise RuntimeError(
                    f"Failed to validate chapter {url} after 3 attempts: "
                    f"{last_error or 'no narrative paragraphs extracted'}"
                ) from last_error

            if not paragraphs or any(
                not isinstance(p, str) or not p.strip()
                for p in paragraphs
            ):
                raise RuntimeError(
                    f"Empty or invalid paragraphs in chapter: {url}"
                )

            payload.append((chapter, paragraphs))

            print(
                f"\rValidated {len(payload)}/494 chapters...",
                end="",
                flush=True,
            )

            time.sleep(0.12)

    print()

    if len(payload) != 494:
        raise RuntimeError(
            f"Expected 494 chapters, validated {len(payload)}."
        )

    print("\nFULL VALIDATION PASSED")
    print("Books: 6")
    print(f"Chapters: {len(payload)}")
    print(f"Unique chapter URLs: {len(all_urls)}")
    print(f"Chapters with non-empty narrative: {len(payload)}")
    print("Database: not connected; no writes performed.")


def connect_database():
    import psycopg2

    password = (
        os.environ.get("DB_PASSWORD")
        or os.environ.get("PGPASSWORD")
    )

    if not password:
        password = getpass.getpass(
            "PostgreSQL password for project_se: "
        )

    return psycopg2.connect(
        host=os.environ.get("DB_HOST", "localhost"),
        port=os.environ.get("DB_PORT", "5432"),
        dbname=os.environ.get("DB_NAME", "postgres"),
        user=os.environ.get("DB_USER", "project_se"),
        password=password,
    )


def import_source(connection, session, source_url, title, books):
    # Download and parse everything before opening the database transaction.
    print("\nDownloading and parsing all chapter pages...")
    payload = []

    for book in books:
        chapters = discover_chapters(session, source_url, book)

        for chapter in chapters:
            try:
                html = fetch(session, chapter["url"])
                paragraphs = extract_narrative(html)

            except Exception:
                print(f"\nFAILED chapter URL: {chapter.get('url')}")
                print(f"Chapter metadata: {chapter!r}")
                print(f"Book metadata: {book!r}")
                raise

            payload.append(
                {
                    "book": book,
                    "chapter": chapter,
                    "paragraphs": paragraphs,
                }
            )

            print(
                f"\rParsed {len(payload)} chapters...",
                end="",
                flush=True,
            )

            time.sleep(0.12)

    print(f"\nParsed {len(payload)} chapters successfully.")

    # Validate the complete payload before issuing any database writes.
    if len(books) != 6:
        raise RuntimeError(
            f"Expected 6 books, discovered {len(books)}. "
            "Refusing database writes."
        )

    if len(payload) != 494:
        raise RuntimeError(
            f"Expected 494 chapters, extracted {len(payload)}. "
            "Refusing database writes."
        )

    chapter_urls = [
        item["chapter"]["url"]
        for item in payload
    ]

    if len(chapter_urls) != len(set(chapter_urls)):
        raise RuntimeError(
            "Duplicate chapter URLs found in extracted payload. "
            "Refusing database writes."
        )

    for item in payload:
        paragraphs = item["paragraphs"]
        chapter_url = item["chapter"]["url"]

        if not paragraphs or any(
            not isinstance(paragraph, str) or not paragraph.strip()
            for paragraph in paragraphs
        ):
            raise RuntimeError(
                f"Empty or invalid paragraph in {chapter_url}. "
                "Refusing database writes."
            )

    print(
        "Validation passed: 6 books, 494 chapters, unique chapter URLs, "
        "and non-empty paragraphs."
    )

    with connection.cursor() as cursor:
        # Prevent simultaneous runs for this exact source URL.
        cursor.execute(
            "SELECT pg_advisory_xact_lock(hashtext(%s))",
            (source_url,),
        )

        cursor.execute(
            "SELECT id FROM sources WHERE url = %s ORDER BY id",
            (source_url,),
        )

        source_rows = cursor.fetchall()

        if len(source_rows) > 1:
            raise RuntimeError(
                "Multiple source rows use this URL. Resolve duplicates first."
            )

        if source_rows:
            source_id = source_rows[0][0]

        else:
            cursor.execute(
                """
                INSERT INTO sources
                    (title, author, translator, year, language, url)
                VALUES (%s, %s, %s, %s, %s, %s)
                RETURNING id
                """,
                (
                    title or "Ramayana of Valmiki (Griffith)",
                    "Valmiki",
                    "Griffith",
                    None,
                    "English",
                    source_url,
                ),
            )

            source_id = cursor.fetchone()[0]

        book_ids = {}

        for book in books:
            cursor.execute(
                """
                SELECT id
                FROM books
                WHERE source_id = %s AND book_number = %s
                ORDER BY id
                """,
                (source_id, book["number"]),
            )

            rows = cursor.fetchall()

            if len(rows) > 1:
                raise RuntimeError(
                    f"Duplicate book number {book['number']} "
                    "exists for this source."
                )

            if rows:
                book_id = rows[0][0]

            else:
                cursor.execute(
                    """
                    INSERT INTO books
                        (source_id, book_number, name, slug)
                    VALUES (%s, %s, %s, %s)
                    RETURNING id
                    """,
                    (
                        source_id,
                        book["number"],
                        book["name"],
                        book["slug"],
                    ),
                )

                book_id = cursor.fetchone()[0]

            book_ids[book["number"]] = book_id

        new_chapters = 0
        preserved_chapters = 0
        new_paragraphs = 0
        preserved_paragraph_sets = 0

        for item in payload:
            book = item["book"]
            chapter = item["chapter"]
            paragraphs = item["paragraphs"]

            book_id = book_ids[book["number"]]
            content = "\n\n".join(paragraphs)

            cursor.execute(
                """
                SELECT id, book_id, content
                FROM chapters
                WHERE source_url = %s
                ORDER BY id
                """,
                (chapter["url"],),
            )

            rows = cursor.fetchall()

            if len(rows) > 1:
                raise RuntimeError(
                    f"Duplicate chapter URL in database: {chapter['url']}"
                )

            if rows:
                chapter_id, existing_book_id, existing_content = rows[0]

                if existing_book_id != book_id:
                    raise RuntimeError(
                        "Chapter URL already belongs to another book: "
                        + chapter["url"]
                    )

                preserved_chapters += 1

                # Never overwrite non-empty chapter content.
                if not existing_content or not existing_content.strip():
                    cursor.execute(
                        "UPDATE chapters SET content = %s WHERE id = %s",
                        (content, chapter_id),
                    )

            else:
                cursor.execute(
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

                chapter_id = cursor.fetchone()[0]
                new_chapters += 1

            cursor.execute(
                """
                SELECT COUNT(*)
                FROM chapter_paragraphs
                WHERE chapter_id = %s
                """,
                (chapter_id,),
            )

            existing_count = cursor.fetchone()[0]

            if existing_count:
                # Preserve existing paragraph rows; never silently replace them.
                preserved_paragraph_sets += 1
                continue

            for paragraph_number, paragraph in enumerate(paragraphs, 1):
                cursor.execute(
                    """
                    INSERT INTO chapter_paragraphs
                        (chapter_id, paragraph_number, content)
                    VALUES (%s, %s, %s)
                    ON CONFLICT (chapter_id, paragraph_number) DO NOTHING
                    """,
                    (chapter_id, paragraph_number, paragraph),
                )

                new_paragraphs += cursor.rowcount

    connection.commit()

    print("\nImport completed.")
    print("Source ID:", source_id)
    print("New chapters:", new_chapters)
    print("Existing chapters preserved:", preserved_chapters)
    print("New paragraph rows:", new_paragraphs)
    print(
        "Chapters with existing paragraphs preserved:",
        preserved_paragraph_sets,
    )


def main():
    parser = argparse.ArgumentParser(
        description="Generic WisdomLib source importer"
    )

    parser.add_argument(
        "--url",
        default=DEFAULT_URL,
        help="WisdomLib book/source index URL",
    )

    parser.add_argument(
        "--apply",
        action="store_true",
        help="Write imported content to PostgreSQL",
    )

    parser.add_argument(
        "--validate-all",
        action="store_true",
        help="Download and validate every chapter without database access",
    )

    args = parser.parse_args()

    source_url = args.url.rstrip("/")
    session = requests.Session()
    session.headers.update(HEADERS)

    title, books = preview(session, source_url)

    if args.validate_all:
        validate_all(session, source_url, books)
        return

    if not args.apply:
        return

    print("\n--apply enabled: database writes are enabled.")
    print("The importer will preserve existing non-empty content.")

    connection = connect_database()

    try:
        import_source(connection, session, source_url, title, books)

    except Exception:
        connection.rollback()
        raise

    finally:
        connection.close()


if __name__ == "__main__":
    main()