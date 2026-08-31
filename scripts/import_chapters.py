import time
import requests
import psycopg2
import os
from dotenv import load_dotenv

load_dotenv()

from bs4 import BeautifulSoup

DB_CONFIG = {
    "host": os.getenv("DB_HOST", "localhost"),
    "dbname": os.getenv("DB_NAME", "postgres"),
    "user": os.getenv("DB_USER", "project_se"),
    "password": os.getenv("DB_PASSWORD"),
    "port": os.getenv("DB_PORT", "5432"),
}
HEADERS = {
    "User-Agent": "Mozilla/5.0"
}


def get_chapter_text(url):
    response = requests.get(
        url,
        headers=HEADERS,
        timeout=30
    )

    response.raise_for_status()

    soup = BeautifulSoup(response.text, "html.parser")

    # WisdomLib's chapter content
    content = soup.select_one("#scontent")

    if content is None:
        raise Exception("Could not find #scontent")

    paragraphs = []

    for p in content.find_all("p"):
        text = p.get_text(" ", strip=True)

        if text:
            paragraphs.append(text)

    return "\n\n".join(paragraphs)


def main():

    conn = psycopg2.connect(**DB_CONFIG)
    cursor = conn.cursor()

    cursor.execute("""
        SELECT id, chapter_number, source_url
        FROM chapters
        ORDER BY chapter_number;
    """)

    chapters = cursor.fetchall()

    print(f"Found {len(chapters)} chapters.")

    successful = 0
    failed = 0

    for chapter_id, chapter_number, url in chapters:

        print(f"\nDownloading Chapter {chapter_number}...")

        try:
            text = get_chapter_text(url)

            cursor.execute("""
                UPDATE chapters
                SET content = %s
                WHERE id = %s;
            """, (text, chapter_id))

            conn.commit()

            print(
                f"✓ Chapter {chapter_number} imported "
                f"({len(text)} characters)"
            )

            successful += 1

            # Small delay between requests
            time.sleep(1)

        except Exception as e:

            conn.rollback()

            print(
                f"✗ Chapter {chapter_number} FAILED: {e}"
            )

            failed += 1

    cursor.close()
    conn.close()

    print("\n" + "=" * 50)
    print("IMPORT COMPLETE")
    print("=" * 50)
    print(f"Successful: {successful}")
    print(f"Failed:     {failed}")


if __name__ == "__main__":
    main()
