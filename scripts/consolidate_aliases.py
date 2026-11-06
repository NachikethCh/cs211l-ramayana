import os
import unicodedata
import psycopg2
from dotenv import load_dotenv

# Master Knowledge Base of Canonical Characters -> Known Epithets & Spelling Variants
CANONICAL_SYNONYMS = {
    "Shiva": [
        "Shankara", "Śaṅkara", "Mahadeva", "Mahādeva", "Maheshvara", "Maheśvara", 
        "Mahesha", "Shambhu", "Śambhu", "Bhava", "Hara", "Ishana", "Īśāna", 
        "Ishvara", "Īśvara", "Rudra", "Neelakantha", "Trilochana", "Pashupati"
    ],
    "Vishnu": [
        "Viṣṇu", "Hari", "Narayana", "Nārāyaṇa", "Achyuta", "Damodara", "Dāmodara",
        "Padmanabha", "Padmanābha", "Shridhara", "Śrīdhara", "Janardana", "Janarddana", 
        "Janārdana", "Madhusudana", "Chakrapani", "Purushottama"
    ],
    "Krishna": [
        "Kṛṣṇa", "Keshava", "Keśava", "Kesava", "Govinda", "Madhava", "Mādhava", 
        "Vasudeva", "Vāsudeva", "Hrishikesha", "Hṛṣīkeśa", "Madhu", "Gopala", "Murari"
    ],
    "Brahma": [
        "Brahmā", "Prajapati", "Prajāpati", "Vidhatri", "Vidhātṛ", "Pitamaha", "Chaturmukha"
    ],
    "Lakshmi": [
        "Lakṣmī", "Shri", "Śrī", "Mahalakshmi", "Mahālakṣmī", "Padma", "Kamala"
    ],
    "Parvati": [
        "Pārvatī", "Uma", "Umā", "Gauri", "Gaurī", "Durga", "Durgā", "Kali", "Kālī", "Ambika", "Shakti"
    ],
    "Ganesha": [
        "Gaṇeśa", "Vinayaka", "Vināyaka", "Ganapati", "Vighneshvara"
    ],
    "Kartikeya": [
        "Kārtikeya", "Skanda", "Subrahmanya", "Guha", "Shanmukha"
    ],
    "Rāma": [
        "Rama", "Rāghava", "Raghava", "Kākutstha", "Kakutstha", "Dasharathi", "Ramachandra"
    ],
    "Sītā": [
        "Sita", "Vaidehī", "Vaidehi", "Janakātmajā", "Maithili", "Janaki", "Jānakī"
    ],
    "Lakṣmaṇa": [
        "Lakshmana", "Lakshman", "Saumitri", "Saumitra", "Ramanuja"
    ],
    "Śatrughna": [
        "Shatrughna", "Satrughna", "Ripudamana"
    ],
    "Daśaratha": [
        "Dasharatha", "Dasaratha"
    ],
    "Hanuman": [
        "Hanumān", "Anjaneya", "Āñjaneya", "Maruti", "Pavanaputra", "Mahavira"
    ],
    "Arjuna": [
        "Dhanañjaya", "Dhananjaya", "Guḍākeśa", "Gudakesha", "Partha", "Pārtha", "Savyasachi", "Kiriti"
    ],
    "Bhimasena": [
        "Bhima", "Bhīma", "Bhīmasena", "Vrikodara"
    ],
    "Kunti": [
        "Kuntī", "Pṛthā", "Pritha"
    ],
    "Vyasa": [
        "Vyāsa", "Veda Vyasa", "Krishna Dvaipayana", "Badarayana"
    ],
    "Nārada": [
        "Narada", "Narad", "Devarshi"
    ],
    "Vālmīki": [
        "Valmiki", "Prachetasa"
    ],
    "Viśvāmitra": [
        "Viswamitra", "Vishvamitra", "Kaushika"
    ],
    "Kaśyapa": [
        "Kashyapa", "Kashyap"
    ],
    "Ravana": [
        "Rāvaṇa", "Dashanana", "Lankeshvara", "Dashagriva"
    ]
}

def strip_diacritics(text):
    return ''.join(
        c for c in unicodedata.normalize('NFD', text)
        if unicodedata.category(c) != 'Mn'
    ).lower().strip()

def main():
    load_dotenv('backend/.env')
    conn = psycopg2.connect(
        dbname=os.getenv('DB_NAME', 'postgres'),
        user=os.getenv('DB_USER', 'project_se'),
        password=os.getenv('DB_PASSWORD'),
        host=os.getenv('DB_HOST', 'localhost'),
        port=os.getenv('DB_PORT', '5432')
    )
    cur = conn.cursor()

    print("=== Consolidating Duplicate Epithets & Aliases ===")
    merged_count = 0

    for canonical_name, aliases in CANONICAL_SYNONYMS.items():
        # 1. Ensure the canonical character exists
        cur.execute("SELECT id FROM characters WHERE LOWER(name) = LOWER(%s) LIMIT 1;", (canonical_name,))
        row = cur.fetchone()
        if not row:
            cur.execute(
                "INSERT INTO characters (name, description) VALUES (%s, %s) RETURNING id;",
                (canonical_name, f"Canonical Epic Deity/Hero ({canonical_name})")
            )
            canonical_id = cur.fetchone()[0]
        else:
            canonical_id = row[0]

        # Ensure canonical name itself is in character_aliases
        cur.execute("""
            INSERT INTO character_aliases (character_id, alias)
            SELECT %s, %s WHERE NOT EXISTS (
                SELECT 1 FROM character_aliases WHERE character_id = %s AND LOWER(alias) = LOWER(%s)
            );
        """, (canonical_id, canonical_name, canonical_id, canonical_name))

        # 2. Check each alias: register in character_aliases AND merge if a separate character row exists
        for alias in aliases:
            alias_clean = alias.strip()
            # Insert into character_aliases for the canonical character
            cur.execute("""
                INSERT INTO character_aliases (character_id, alias)
                SELECT %s, %s WHERE NOT EXISTS (
                    SELECT 1 FROM character_aliases WHERE character_id = %s AND LOWER(alias) = LOWER(%s)
                );
            """, (canonical_id, alias_clean, canonical_id, alias_clean))

            # Check if this alias accidentally exists as a separate standalone row in `characters`
            cur.execute(
                "SELECT id, name FROM characters WHERE id != %s AND (LOWER(name) = LOWER(%s) OR LOWER(name) = LOWER(%s));",
                (canonical_id, alias_clean, strip_diacritics(alias_clean))
            )
            dup_rows = cur.fetchall()

            for dup_id, dup_name in dup_rows:
                print(f" -> Merging standalone character '{dup_name}' (ID {dup_id}) into '{canonical_name}' (ID {canonical_id})")
                
                # Move existing aliases from duplicate to canonical
                cur.execute("""
                    UPDATE character_aliases SET character_id = %s 
                    WHERE character_id = %s AND LOWER(alias) NOT IN (
                        SELECT LOWER(alias) FROM character_aliases WHERE character_id = %s
                    );
                """, (canonical_id, dup_id, canonical_id))
                cur.execute("DELETE FROM character_aliases WHERE character_id = %s;", (dup_id,))

                # Reassign mentions, events, and relationships
                cur.execute("UPDATE character_mentions SET character_id = %s WHERE character_id = %s;", (canonical_id, dup_id))
                cur.execute("UPDATE character_events SET character_id = %s WHERE character_id = %s;", (canonical_id, dup_id))
                
                # Safely reassign relationships avoiding self-loops
                cur.execute("UPDATE character_relationships SET character_id = %s WHERE character_id = %s AND related_character_id != %s;", (canonical_id, dup_id, canonical_id))
                cur.execute("UPDATE character_relationships SET related_character_id = %s WHERE related_character_id = %s AND character_id != %s;", (canonical_id, dup_id, canonical_id))
                cur.execute("DELETE FROM character_relationships WHERE character_id = %s OR related_character_id = %s;", (dup_id, dup_id))

                # Also clean up duplicate entities table entry if present (using column 'name')
                cur.execute("DELETE FROM entity_resolution_results WHERE resolved_entity_id IN (SELECT id FROM entities WHERE LOWER(name) = LOWER(%s));", (dup_name,))
                cur.execute("DELETE FROM entity_aliases WHERE entity_id IN (SELECT id FROM entities WHERE LOWER(name) = LOWER(%s));", (dup_name,))
                cur.execute("DELETE FROM entities WHERE LOWER(name) = LOWER(%s) AND LOWER(name) != LOWER(%s);", (dup_name, canonical_name))

                # Finally delete the duplicate character row
                cur.execute("DELETE FROM characters WHERE id = %s;", (dup_id,))
                merged_count += 1

    # 3. Also auto-merge any remaining characters whose stripped-diacritic name matches another character
    cur.execute("SELECT id, name FROM characters ORDER BY id;")
    all_chars = cur.fetchall()
    seen_normalized = {}
    for cid, cname in all_chars:
        norm = strip_diacritics(cname)
        if norm in seen_normalized:
            target_id, target_name = seen_normalized[norm]
            print(f" -> Auto-merging diacritic variant '{cname}' (ID {cid}) into '{target_name}' (ID {target_id})")
            cur.execute("""
                INSERT INTO character_aliases (character_id, alias)
                SELECT %s, %s WHERE NOT EXISTS (
                    SELECT 1 FROM character_aliases WHERE character_id = %s AND LOWER(alias) = LOWER(%s)
                );
            """, (target_id, cname, target_id, cname))
            cur.execute("DELETE FROM character_aliases WHERE character_id = %s;", (cid,))
            cur.execute("UPDATE character_mentions SET character_id = %s WHERE character_id = %s;", (target_id, cid))
            cur.execute("UPDATE character_events SET character_id = %s WHERE character_id = %s;", (target_id, cid))
            cur.execute("DELETE FROM characters WHERE id = %s;", (cid,))
            merged_count += 1
        else:
            seen_normalized[norm] = (cid, cname)

    conn.commit()
    cur.close()
    conn.close()
    print(f"\nSuccessfully merged {merged_count} duplicate/alias character entries!")
    print("Re-running auto_inject_pipeline.py to synchronize all events and mentions...")
    os.system("python3 scripts/auto_inject_pipeline.py --all-sources")

if __name__ == "__main__":
    main()
