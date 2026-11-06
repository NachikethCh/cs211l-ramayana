import os
import psycopg2
from dotenv import load_dotenv

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

    # 1. Add missing canonical characters specific to the Gita/Mahabharata
    new_characters = ["Subhadra", "Drupada", "Virata", "Manu", "Vrishni", "Pandu"]
    for c in new_characters:
        cur.execute("""
            INSERT INTO characters (name, description) 
            SELECT %s, 'Epic Character' 
            WHERE NOT EXISTS (SELECT 1 FROM characters WHERE name = %s)
            RETURNING id;
        """, (c, c))
    
    # 2. Map the IAST (Sanskrit diacritic) names to the canonical English spellings
    alias_map = {
        "Krishna": ["Kṛṣṇa", "Vāsudeva", "Hṛṣīkeśa", "Keśava", "Kesava", "Madhu"],
        "Arjuna": ["Dhanañjaya", "Guḍākeśa"],
        "Kunti": ["Kuntī", "Pṛthā"],
        "Dhritarashtra": ["Dhṛtarāṣṭra"],
        "Bhishma": ["Bhīṣma"],
        "Bhima": ["Bhīma", "Bhimasena"],
        "Karna": ["Karṇa"],
        "Draupadi": ["Draupadī"],
        "Vyasa": ["Vyāsa"],
        "Subhadra": ["Subhadrā"],
        "Virata": ["Virāṭa"],
        "Vrishni": ["Vṛṣṇi"],
        "Pandu": ["Pāṇḍu"]
    }
    
    for canonical, aliases in alias_map.items():
        cur.execute("SELECT id FROM characters WHERE name = %s", (canonical,))
        res = cur.fetchone()
        if res:
            char_id = res[0]
            for alias in aliases:
                # Safely insert alias if it doesn't already exist
                cur.execute("""
                    INSERT INTO character_aliases (character_id, alias) 
                    SELECT %s, %s
                    WHERE NOT EXISTS (
                        SELECT 1 FROM character_aliases WHERE character_id = %s AND alias = %s
                    );
                """, (char_id, alias, char_id, alias))
    
    conn.commit()
    cur.close()
    conn.close()
    print("Bhagavad Gita characters and IAST aliases mapped successfully!")
    
    print("\nRe-running pipeline for Source 5 (Bhagavad Gita)...")
    os.system("python3 scripts/auto_inject_pipeline.py --source-id 5")

if __name__ == '__main__':
    main()
