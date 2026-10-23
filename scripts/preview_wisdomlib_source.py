import re
import requests
from html.parser import HTMLParser
from urllib.parse import urljoin, urlparse

SOURCE_URL = (
    "https://www.wisdomlib.org/hinduism/book/"
    "ramayana-of-valmiki-griffith"
)

HEADERS = {"User-Agent": "Mozilla/5.0"}
ROMAN = r"[IVXLCDM]+"
BOOK_RE = re.compile(rf"^Book\s+{ROMAN}\b", re.I)
CHAPTER_RE = re.compile(rf"^Chapter\s+{ROMAN}\b", re.I)


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


def get_links(url):
    response = requests.get(url, headers=HEADERS, timeout=30)
    response.raise_for_status()
    parser = LinkParser()
    parser.feed(response.text)
    return parser.links


def same_source(url):
    return urlparse(url).netloc == urlparse(SOURCE_URL).netloc and (
        urlparse(url).path.startswith(urlparse(SOURCE_URL).path + "/")
    )


root_links = get_links(SOURCE_URL)

books = []
seen = set()

for label, href in root_links:
    absolute = urljoin(SOURCE_URL, href)
    if BOOK_RE.match(label) and same_source(absolute):
        if absolute not in seen:
            books.append((label, absolute))
            seen.add(absolute)

print("Source:", SOURCE_URL)
print("Book pages discovered:", len(books))

total_chapters = 0

for book_name, book_url in books:
    try:
        links = get_links(book_url)
        chapters = []
        chapter_urls = set()

        for label, href in links:
            absolute = urljoin(book_url, href)
            if CHAPTER_RE.match(label) and same_source(absolute):
                if absolute not in chapter_urls:
                    chapters.append((label, absolute))
                    chapter_urls.add(absolute)

        total_chapters += len(chapters)
        print(f"\n{book_name}: {len(chapters)} chapter links")
        print("  Book URL:", book_url)

        for label, url in chapters[:3]:
            print(f"  First: {label} -> {url}")

        if len(chapters) > 3:
            label, url = chapters[-1]
            print(f"  Last:  {label} -> {url}")

    except requests.RequestException as exc:
        print(f"\nERROR reading {book_name}: {exc}")

print("\nTotal chapter links discovered:", total_chapters)
print("Preview only: no database writes.")
