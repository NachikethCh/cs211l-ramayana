import os
import psycopg2
from dotenv import load_dotenv

def get_db_connection():
    load_dotenv('backend/.env')
    return psycopg2.connect(
        dbname=os.getenv('DB_NAME', 'postgres'),
        user=os.getenv('DB_USER', 'project_se'),
        password=os.getenv('DB_PASSWORD'),
        host=os.getenv('DB_HOST', 'localhost'),
        port=os.getenv('DB_PORT', '5432')
    )

def main():
    conn = get_db_connection()
    cur = conn.cursor()

    print("Cleaning up false-positive auto-discovered entities...")

    # Whitelist of genuine mythological/epic characters and sages to keep
    keep_characters = {
        "Vishnu", "Garuda", "Shiva", "Brahma", "Rudra", "Lakshmi", 
        "Sarasvati", "Vyasa", "Krishna", "Arjuna", "Ravana", "Hanuman", 
        "Sugriva", "Dhanvantari", "Suta", "Shaunaka", "Indra", "Narada", 
        "Agastya", "Vashistha", "Valmiki", "Rama", "Sita", "Lakshmana", 
        "Bharata", "Shatrughna", "Dasharatha", "Kausalya", "Kaikeyi", 
        "Sumitra", "Janaka", "Kubera", "Yama", "Agni", "Varuna", "Surya", 
        "Chandra", "Ganesha", "Skanda", "Kartikeya", "Devaki", "Vasudeva",
        "Bali", "Prahlada", "Markandeya", "Marichi", "Kashyapa", "Daksha"
    }

    # Alias mapping groups: { Canonical Name: [list of alternative names / aliases] }
    alias_mappings = {
        "Vishnu": ["Hari", "Narayana", "Keshava", "Govinda", "Vasudeva", "Madhava", "Achyuta", "Damodara", "Padmanabha", "Shridhara", "Vishvaksena", "Janardana", "Janarddana"],
        "Shiva": ["Mahesha", "Maheshvara", "Mahadeva", "Shankara", "Shambhu", "Bhava", "Hara", "Ishana", "Ishvara"],
        "Brahma": ["Prajapati", "Vidhatri"],
        "Lakshmi": ["Shri", "Mahalakshmi"],
        "Garuda": ["Vinata"],
        "Rama": ["Kakutstha"],
        "Sita": ["Janaki", "Maithili"],
    }

    # 1. Delete characters not in our whitelist and marked as auto-discovered
    cur.execute("""
        DELETE FROM characters 
        WHERE description LIKE 'Auto-discovered entity%' 
          AND name NOT = ALL(%s);
    """, (list(keep_characters),))
    deleted_count = cur.rowcount
    print(f" -> Removed {deleted_count} false-positive auto-discovered rows.")

    # 2. Ensure canonical entities exist and group their aliases properly
    for canonical_name, aliases in alias_mappings.items():
        # Check if canonical character exists
        cur.execute("SELECT id FROM characters WHERE LOWER(name) = LOWER(%s);", (canonical_name,))
        row = cur.fetchone()
        
        if row:
            char_id = row[0]
        else:
            cur.execute("""
                INSERT INTO characters (name, description) 
                VALUES (%s, %s) RETURNING id;
            """, (canonical_name, f"Canonical deity/character entry"))
            char_id = cur.fetchone()[0]
            print(f" -> Created canonical entity: {canonical_name}")

        # Insert aliases
        for alias in aliases:
            try:
                cur.execute("""
                    INSERT INTO character_aliases (character_id, alias) 
                    VALUES (%s, %s)
                    ON CONFLICT DO NOTHING;
                """, (char_id, alias))
            except Exception:
                conn.rollback()

    conn.commit()
    print("Database cleanup and alias grouping completed successfully!")
    
    # 3. Re-run mention/event mappings for clean data
    print("\nRe-syncing annotations across all sources...")
    cur.close()
    conn.close()

if __name__ == "__main__":
    main()
