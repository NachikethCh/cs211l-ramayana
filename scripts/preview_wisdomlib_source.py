#!/usr/bin/env python3
"""
Generic WisdomLib structure previewer.

This script is deliberately read-only. It accepts a source/index URL and
discovers book/section pages and chapter/page links without assuming a
particular work, author, source ID, or fixed chapter count.

Examples:
  python3 scripts/preview_wisdomlib_source.py --url "https://www.wisdomlib.org/..."
  python3 scripts/preview_wisdomlib_source.py --url "https://www.wisdomlib.org/..." --verbose

The supported structure is currently HTML pages whose links are labelled
with recognizable section/chapter terms. Unknown structures are reported
rather than silently treated as complete.
"""

from __future__ import annotations

import argparse
import re
import sys
from html.parser import HTMLParser
from urllib.parse import urldefrag, urljoin, urlparse

import requests


HEADERS = {
    "User-Agent": "Mozilla/5.0 (compatible; MythverseWisdomLibPreview/2.0)"
}
TIMEOUT = 30
RETRIES = 3

SECTION_TERMS = (
    "book", "part", "volume", "vol", "kanda", "kāṇḍa", "kanda",
    "canto", "section", "skandha", "chapter-group", "parva",
)
CHAPTER_TERMS = (
    "chapter", "chatper", "chaper", "chap",
    "sarga", "adhyaya", "adhyāya", "section",
    "discourse", "hymn", "lesson", "story", "text", "verse",
)

NUM = r"(?:\d+|[IVXLCDM]+)"
SECTION_RE = re.compile(
    rf"^\s*(?P<kind>{'|'.join(map(re.escape, SECTION_TERMS))})"
    rf"\s+(?P<number>{NUM})\b\s*[:.\-–—]?\s*(?P<title>.*)$",
    re.I,
)
CHAPTER_RE = re.compile(
    rf"^\s*(?P<kind>{'|'.join(map(re.escape, CHAPTER_TERMS))})"
    rf"\s+(?P<number>{NUM})\b\s*[:.\-–—]?\s*(?P<title>.*)$",
    re.I,
)


class LinkParser(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.links = []
        self._href = None
        self._parts = []

    def handle_starttag(self, tag, attrs):
        if tag == "a":
            self._href = dict(attrs).get("href")
            self._parts = []

    def handle_data(self, data):
        if self._href is not None:
            self._parts.append(data)

    def handle_endtag(self, tag):
        if tag == "a" and self._href is not None:
            label = " ".join(" ".join(self._parts).split())
            if label:
                self.links.append((label, self._href))
            self._href = None
            self._parts = []


def roman_to_int(value: str) -> int | None:
    values = {"I": 1, "V": 5, "X": 10, "L": 50, "C": 100, "D": 500, "M": 1000}
    value = value.upper()
    if not value or any(ch not in values for ch in value):
        return None
    total = previous = 0
    for ch in reversed(value):
        n = values[ch]
        total += -n if n < previous else n
        previous = n
    return total


def parse_number(value: str) -> int | None:
    return int(value) if value.isdigit() else roman_to_int(value)


def fetch(session: requests.Session, url: str) -> str:
    last_error = None
    for attempt in range(1, RETRIES + 1):
        try:
            response = session.get(url, timeout=TIMEOUT)
            response.raise_for_status()
            return response.text
        except requests.RequestException as exc:
            last_error = exc
            if attempt < RETRIES:
                import time
                time.sleep(attempt)
    raise RuntimeError(f"Could not fetch {url}: {last_error}")


def get_links(session, url):
    parser = LinkParser()
    parser.feed(fetch(session, url))
    return parser.links


def canonical_url(base: str, href: str) -> str:
    return urldefrag(urljoin(base, href))[0]


def belongs_to_source(candidate: str, source: str) -> bool:
    c = urlparse(candidate)
    s = urlparse(source)
    if c.scheme not in ("http", "https") or c.netloc.lower() != s.netloc.lower():
        return False
    source_path = s.path.rstrip("/")
    candidate_path = c.path.rstrip("/")
    return candidate_path == source_path or candidate_path.startswith(source_path + "/")


def classify_links(links, base_url, source_url, pattern):
    found, seen = [], set()

    for label, href in links:
        match = pattern.match(label)

        if not match or not href:
            continue

        url = canonical_url(base_url, href)

        if not belongs_to_source(url, source_url) or url in seen:
            continue

        number = parse_number(match.group("number"))

        if number is None:
            continue

        seen.add(url)

        title = match.groupdict().get("title") or ""
        title = re.sub(r"^[\s:;,.–—-]+", "", title)
        title = re.sub(r"[\s:;,.–—-]+$", "", title)
        title = " ".join(title.split())

        if not title:
            title = f"{match.group('kind').capitalize()} {match.group('number').upper()}"

        found.append({
            "label": label,
            "url": url,
            "kind": match.group("kind"),
            "number": number,
            "title": title,
        })

    found.sort(key=lambda item: (item["number"], item["url"]))
    return found


def discover(session, source_url):
    root_links = get_links(session, source_url)
    sections = classify_links(root_links, source_url, source_url, SECTION_RE)

    # A source without separate section pages may list chapters directly.
    if not sections:
        sections = [{
            "label": "Main work",
            "url": source_url,
            "kind": "work",
            "number": 1,
            "title": "Main work",
        }]

    results = []
    all_chapter_urls = set()
    for section in sections:
        section_links = root_links if section["url"] == source_url else get_links(session, section["url"])
        chapters = classify_links(section_links, section["url"], source_url, CHAPTER_RE)
        if not chapters:
            raise RuntimeError(
                f"No recognizable chapter links found under {section['label']} "
                f"({section['url']}). This WisdomLib page may use a different "
                "link-label convention; discovery cannot be certified."
            )
        for chapter in chapters:
            if chapter["url"] in all_chapter_urls:
                raise RuntimeError(f"Duplicate chapter URL discovered: {chapter['url']}")
            all_chapter_urls.add(chapter["url"])
        results.append((section, chapters))
    return results


def main():
    parser = argparse.ArgumentParser(description="Read-only WisdomLib book/chapter discovery")
    parser.add_argument("--url", required=True, help="WisdomLib source/index URL")
    parser.add_argument("--verbose", action="store_true", help="Print every discovered chapter")
    args = parser.parse_args()

    parsed = urlparse(args.url)
    if parsed.scheme not in ("http", "https") or not parsed.netloc:
        parser.error("--url must be a valid http(s) URL")

    source_url = args.url.rstrip("/")
    session = requests.Session()
    session.headers.update(HEADERS)

    try:
        print(f"Source URL: {source_url}")
        print("Discovery mode: generic WisdomLib HTML link discovery")
        sections = discover(session, source_url)

        total = 0
        for section, chapters in sections:
            total += len(chapters)
            print(f"\n{section['label']}: {len(chapters)} chapter/page links")
            print(f"  Section URL: {section['url']}")
            if args.verbose:
                for chapter in chapters:
                    suffix = f" — {chapter['title']}" if chapter["title"] else ""
                    print(f"  [{chapter['number']}] {chapter['label']}{suffix}")
                    print(f"      {chapter['url']}")
            else:
                for chapter in chapters[:3]:
                    print(f"  First: {chapter['label']} -> {chapter['url']}")
                if len(chapters) > 3:
                    chapter = chapters[-1]
                    print(f"  Last:  {chapter['label']} -> {chapter['url']}")

        print(f"\nSections discovered: {len(sections)}")
        print(f"Total chapter/page links discovered: {total}")
        print("Preview only: no database connection and no database writes.")
    except Exception as exc:
        print(f"\nDISCOVERY FAILED: {exc}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
