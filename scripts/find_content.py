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

soup = BeautifulSoup(response.text, "html.parser")

# Find the heading "Chapter I"
heading = soup.find(
    lambda tag: tag.name in ["h1", "h2", "h3"]
    and "Chapter I" in tag.get_text()
)

if heading:
    print("FOUND HEADING:")
    print(heading)

    print("\nPARENT:")
    print(heading.parent.name)
    print(heading.parent.get("class"))
    print(heading.parent.get("id"))

else:
    print("Chapter heading not found")
