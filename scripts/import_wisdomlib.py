import re
import requests
import psycopg2
import os
from bs4 import BeautifulSoup
from urllib.parse import urljoin
from dotenv import load_dotenv

load_dotenv()

# --------------------------------------------------
# WISDOMLIB
# --------------------------------------------------

BOOK_URL = "https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365868.html"


# --------------------------------------------------
# POSTGRESQL
# --------------------------------------------------

DB_HOST = "localhost"
DB_NAME = os.getenv("DB_NAME", "postgres")
DB_USER = os.getenv("DB_USER", "project_se")
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "5432")

# --------------------------------------------------
# ROMAN NUMERAL → INTEGER
# --------------------------------------------------

def roman_to_int(roman):

    values = {
        "I": 1,
        "V": 5,
        "X": 10,
        "L": 50,
        "C": 100,
        "D": 500,
        "M": 1000
    }

    total = 0
    previous = 0

    for char in reversed(roman.upper()):

        value = values[char]

        if value < previous:
            total -= value
        else:
            total += value

        previous = value

    return total


# --------------------------------------------------
# DOWNLOAD BOOK PAGE
# --------------------------------------------------

def get_book_page():

    headers = {
        "User-Agent": "Mozilla/5.0"
    }

    response = requests.get(
        BOOK_URL,
        headers=headers,
        timeout=30
    )

    response.raise_for_status()

    return response.text


# --------------------------------------------------
# EXTRACT CHAPTER LINKS
# --------------------------------------------------

def extract_chapters(html):

    soup = BeautifulSoup(html, "html.parser")

    chapters = []

    for link in soup.find_all("a"):

        text = link.get_text(" ", strip=True)

        match = re.fullmatch(
            r"Chapter\s+([IVXLCDM]+)",
            text,
            re.IGNORECASE
        )

        if not match:
            continue

        roman = match.group(1)

        chapter_number = roman_to_int(roman)

        href = link.get("href")

        if not href:
            continue

        url = urljoin(
            BOOK_URL,
            href
        )

        chapters.append({
            "chapter_number": chapter_number,
            "title": text,
            "url": url
        })

    # Remove duplicates
    unique = {}

    for chapter in chapters:

        unique[chapter["chapter_number"]] = chapter

    chapters = list(unique.values())

    chapters.sort(
        key=lambda x: x["chapter_number"]
    )

    return chapters


# --------------------------------------------------
# DATABASE CONNECTION
# --------------------------------------------------

def connect_database():

    return psycopg2.connect(
        host=DB_HOST,
        port=DB_PORT,
        database=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD
    )


# --------------------------------------------------
# INSERT SOURCE
# --------------------------------------------------

def insert_source(cursor):

    cursor.execute(
        """
        SELECT id
        FROM sources
        WHERE title = %s
        AND translator = %s
        AND year = %s
        """,
        (
            "The Ramayana",
            "Manmatha Nath Dutt",
            1891
        )
    )

    result = cursor.fetchone()

    if result:

        return result[0]

    cursor.execute(
        """
        INSERT INTO sources
        (
            title,
            author,
            translator,
            year,
            language,
            url
        )
        VALUES
        (%s, %s, %s, %s, %s, %s)
        RETURNING id
        """,
        (
            "The Ramayana",
            "Valmiki",
            "Manmatha Nath Dutt",
            1891,
            "English",
            BOOK_URL
        )
    )

    return cursor.fetchone()[0]


# --------------------------------------------------
# INSERT BOOK
# --------------------------------------------------

def insert_book(cursor, source_id):

    cursor.execute(
        """
        SELECT id
        FROM books
        WHERE source_id = %s
        AND book_number = %s
        """,
        (
            source_id,
            1
        )
    )

    result = cursor.fetchone()

    if result:

        return result[0]

    cursor.execute(
        """
        INSERT INTO books
        (
            source_id,
            book_number,
            name,
            slug
        )
        VALUES
        (%s, %s, %s, %s)
        RETURNING id
        """,
        (
            source_id,
            1,
            "Bāla-kāṇḍa",
            "bala-kanda"
        )
    )

    return cursor.fetchone()[0]


# --------------------------------------------------
# INSERT CHAPTERS
# --------------------------------------------------

def insert_chapters(cursor, book_id, chapters):

    inserted = 0
    skipped = 0

    for chapter in chapters:

        cursor.execute(
            """
            SELECT id
            FROM chapters
            WHERE book_id = %s
            AND chapter_number = %s
            """,
            (
                book_id,
                chapter["chapter_number"]
            )
        )

        existing = cursor.fetchone()

        if existing:

            skipped += 1

            continue

        cursor.execute(
            """
            INSERT INTO chapters
            (
                book_id,
                chapter_number,
                title,
                source_url
            )
            VALUES
            (%s, %s, %s, %s)
            """,
            (
                book_id,
                chapter["chapter_number"],
                chapter["title"],
                chapter["url"]
            )
        )

        inserted += 1

        print(
            f"Inserted Chapter "
            f"{chapter['chapter_number']}: "
            f"{chapter['title']}"
        )

    print()
    print(f"Inserted: {inserted}")
    print(f"Skipped:  {skipped}")


# --------------------------------------------------
# MAIN
# --------------------------------------------------

def main():

    print("\nStarting Ramayana importer...\n")

    # Download
    html = get_book_page()

    # Extract
    chapters = extract_chapters(html)

    print(
        f"Found {len(chapters)} chapters."
    )

    if len(chapters) != 77:

        raise Exception(
            f"Expected 77 chapters, "
            f"but found {len(chapters)}."
        )

    # Connect
    connection = connect_database()

    try:

        cursor = connection.cursor()

        # Source
        source_id = insert_source(cursor)

        print(
            f"Source ID: {source_id}"
        )

        # Book
        book_id = insert_book(
            cursor,
            source_id
        )

        print(
            f"Book ID: {book_id}"
        )

        # Chapters
        insert_chapters(
            cursor,
            book_id,
            chapters
        )

        connection.commit()

        print("\nSUCCESS!")
        print(
            "Book 1 and its 77 chapters "
            "are now in PostgreSQL."
        )

    except Exception as error:

        connection.rollback()

        print("\nERROR:")
        print(error)

    finally:

        cursor.close()
        connection.close()


if __name__ == "__main__":
    main()
