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

print("Status:", response.status_code)

soup = BeautifulSoup(response.text, "html.parser")

print("Page title:")
print(soup.title.get_text(strip=True) if soup.title else "No title")

print("\nHeadings found:")
for heading in soup.find_all(["h1", "h2", "h3"]):
    text = heading.get_text(" ", strip=True)

    if text:
        print(text)

print("\nFirst 3000 characters of visible text:\n")

text = soup.get_text(
    "\n",
    strip=True
)

print(text[:3000])
