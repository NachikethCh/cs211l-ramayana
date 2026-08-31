import requests
from bs4 import BeautifulSoup

URL = "https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365869.html"

headers = {
    "User-Agent": "Mozilla/5.0"
}

response = requests.get(
    URL,
    headers=headers,
    timeout=30
)

response.raise_for_status()

soup = BeautifulSoup(response.text, "html.parser")

# Exact WisdomLib chapter-content container
content = soup.select_one("#scontent")

if content is None:
    raise Exception("Chapter content not found!")

# Extract paragraphs separately
paragraphs = []

for p in content.find_all("p"):
    text = p.get_text(" ", strip=True)

    if text:
        paragraphs.append(text)

print("Paragraphs found:", len(paragraphs))

print("\n" + "=" * 80)
print("CHAPTER TEXT")
print("=" * 80)

for i, paragraph in enumerate(paragraphs, start=1):
    print(f"\n[{i}] {paragraph}")
