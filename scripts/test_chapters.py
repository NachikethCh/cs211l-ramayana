import requests
from bs4 import BeautifulSoup
from urllib.parse import urljoin

URL = "https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365868.html"

headers = {
    "User-Agent": "Mozilla/5.0"
}

response = requests.get(URL, headers=headers)

print("Status:", response.status_code)

soup = BeautifulSoup(response.text, "html.parser")

chapters = []

for link in soup.find_all("a"):
    text = link.get_text(" ", strip=True)

    if text.startswith("Chapter"):
        href = link.get("href")

        if href:
            full_url = urljoin(URL, href)

            chapters.append((text, full_url))


print("\nChapters found:", len(chapters))

for number, (title, url) in enumerate(chapters, start=1):
    print(f"{number}. {title}")
    print(f"   {url}")
