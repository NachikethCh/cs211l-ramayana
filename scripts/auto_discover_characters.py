import os
import argparse
import unicodedata
from collections import Counter
import psycopg2
import spacy
from dotenv import load_dotenv
from consolidate_aliases import CANONICAL_SYNONYMS, strip_diacritics

def build_alias_lookup():
    """Maps normalized alias/epithet -> canonical character name."""
    lookup = {}
    for canonical, aliases in CANONICAL_SYNONYMS.items():
        lookup[strip_diacritics(canonical)] = canonical
        for a in aliases:
            lookup[strip_diacritics(a)] = canonical
    return lookup

def main():
    parser = argparse.ArgumentParser(description="Auto-discover characters with canonical alias resolution.")
    parser.add_argument("--source-id", type=int, required=True, help="Source ID to scan")
    parser.add_argument("--min-mentions", type=int, default=3, help="Minimum mentions required")
    args = parser.parse_args()

    load_dotenv("backend/.env")
    conn = psycopg2.connect(
        dbname=os.getenv("DB_NAME", "postgres"),
        user=os.getenv("DB_USER", "project_se"),
        password=os.getenv("DB_PASSWORD"),
        host=os.getenv("DB_HOST", "localhost"),
        port=os.getenv("DB_PORT", "5432"),
    )
    cur = conn.cursor()

    print("Loading NLP model...")
    nlp = spacy.load("en_core_web_sm")

    print(f"Fetching text for source ID {args.source_id}...")
    cur.execute("""
        SELECT cp.text 
        FROM chapter_paragraphs cp
        JOIN chapters c ON cp.chapter_id = c.id
        JOIN books b ON c.book_id = b.id
        WHERE b.source_id = %s;
    """, (args.source_id,))
    paragraphs = [r[0] for r in cur.fetchall() if r[0]]

    print(f"Scanning {len(paragraphs)} paragraphs with AI for characters & aliases...")
    counts = Counter()
    for doc in nlp.pipe(paragraphs, batch_size=50):
        for ent in doc.ents:
            if ent.label_ in ("PERSON", "ORG", "GPE", "NORP"):
                clean = ent.text.strip()
                if len(clean) >= 3 and clean[0].isupper() and " " not in clean:
                    counts[clean] += 1

    alias_lookup = build_alias_lookup()

    # Load existing characters and aliases from DB
    cur.execute("SELECT id, name FROM characters;")
    db_chars = {strip_diacritics(name): (cid, name) for cid, name in cur.fetchall()}

    cur.execute("SELECT alias, character_id FROM character_aliases;")
    db_aliases = {strip_diacritics(alias): cid for alias, cid in cur.fetchall()}

    new_chars = 0
    new_aliases = 0

    for candidate, count in counts.most_common():
        if count < args.min_mentions:
            continue

        norm = strip_diacritics(candidate)

        # 1. Already a known alias in DB? Skip creating a new character, just ensure exact spelling is stored
        if norm in db_aliases:
            char_id = db_aliases[norm]
            cur.execute("""
                INSERT INTO character_aliases (character_id, alias)
                SELECT %s, %s WHERE NOT EXISTS (
                    SELECT 1 FROM character_aliases WHERE character_id = %s AND LOWER(alias) = LOWER(%s)
                );
            """, (char_id, candidate, char_id, candidate))
            continue

        # 2. Matches our Canonical Knowledge Graph? Link as alias to canonical character
        if norm in alias_lookup:
            canonical_name = alias_lookup[norm]
            canon_norm = strip_diacritics(canonical_name)

            if canon_norm in db_chars:
                char_id, _ = db_chars[canon_norm]
            else:
                cur.execute(
                    "INSERT INTO characters (name, description) VALUES (%s, %s) RETURNING id;",
                    (canonical_name, f"Auto-discovered canonical character from source {args.source_id}")
                )
                char_id = cur.fetchone()[0]
                db_chars[canon_norm] = (char_id, canonical_name)
                new_chars += 1

            cur.execute("""
                INSERT INTO character_aliases (character_id, alias)
                SELECT %s, %s WHERE NOT EXISTS (
                    SELECT 1 FROM character_aliases WHERE character_id = %s AND LOWER(alias) = LOWER(%s)
                );
            """, (char_id, candidate, char_id, candidate))
            db_aliases[norm] = char_id
            new_aliases += 1
            print(f"  -> Linked alias '{candidate}' ({count} mentions) to canonical character '{canonical_name}'")
            continue

        # 3. Matches an existing DB character via diacritic stripping? Add as alias
        if norm in db_chars:
            char_id, canon_name = db_chars[norm]
            cur.execute("""
                INSERT INTO character_aliases (character_id, alias)
                SELECT %s, %s WHERE NOT EXISTS (
                    SELECT 1 FROM character_aliases WHERE character_id = %s AND LOWER(alias) = LOWER(%s)
                );
            """, (char_id, candidate, char_id, candidate))
            db_aliases[norm] = char_id
            new_aliases += 1
            print(f"  -> Linked diacritic variant '{candidate}' to '{canon_name}'")
            continue

        # 4. Brand-new standalone character candidate
        cur.execute(
            "INSERT INTO characters (name, description) VALUES (%s, %s) RETURNING id;",
            (candidate, f"Auto-discovered entity from source {args.source_id}")
        )
        char_id = cur.fetchone()[0]
        cur.execute("INSERT INTO character_aliases (character_id, alias) VALUES (%s, %s);", (char_id, candidate))
        db_chars[norm] = (char_id, candidate)
        db_aliases[norm] = char_id
        new_chars += 1
        print(f"  -> Added new character: {candidate} ({count} mentions)")

    conn.commit()
    cur.close()
    conn.close()
    print(f"\nDiscovery complete: {new_chars} new characters, {new_aliases} new aliases linked.")

if __name__ == "__main__":
    main()
