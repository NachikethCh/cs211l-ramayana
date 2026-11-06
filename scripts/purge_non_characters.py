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

    # Absolute strict whitelist of genuine characters, deities, kings, sages, and demons across Sanskrit epics/Puranas
    absolute_whitelist = [
        "Rāma", "Rama", "Sītā", "Sita", "Lakṣmaṇa", "Lakshmana", "Bharata", "Śatrughna", "Shatrughna",
        "Daśaratha", "Dasharatha", "Kausalyā", "Kaushalya", "Kaikeyī", "Kaikeyi", "Sumitrā", "Sumitra",
        "Hanuman", "Sugriva", "Vali", "Angada", "Jatayu", "Sampati", "Ravana", "Kumbhakarna", "Indrajita",
        "Vibhishana", "Surpanakha", "Maricha", "Tadaka", "Subahu", "Khara", "Dushana", "Mandodari",
        "Vishnu", "Viṣṇu", "Hari", "Narayana", "Keshava", "Govinda", "Madhava", "Achyuta", "Damodara",
        "Padmanabha", "Shridhara", "Vishvaksena", "Janardana", "Janarddana", "Vasudeva", "Krishna",
        "Shiva", "Mahesha", "Maheshvara", "Mahadeva", "Shankara", "Shambhu", "Bhava", "Hara", "Ishana",
        "Ishvara", "Brahma", "Prajapati", "Vidhatri", "Lakshmi", "Shri", "Mahalakshmi", "Sarasvati",
        "Garuda", "Vinata", "Indra", "Agni", "Yama", "Varuna", "Surya", "Chandra", "Kubera", "Vayu",
        "Narada", "Nārada", "Agastya", "Vashistha", "Valmiki", "Vālmīki", "Vyasa", "Veda Vyasa", "Parashara",
        "Viswamitra", "Viśvāmitra", "Marichi", "Kashyapa", "Kaśyapa", "Daksha", "Atri", "Bhrigu", "Angira",
        "Pulastya", "Pulaha", "Kratu", "Gautama", "Mandavya", "Chyavana", "Jamadagni", "Markandeya",
        "Devaki", "Rohini", "Yudhishthira", "Bhimasena", "Arjuna", "Sahadeva", "Draupadi", "Pandu",
        "Kunti", "Bhishma", "Drona", "Karna", "Duryodhana", "Dhritarashtra", "Shakuni", "Shishupala",
        "Jarasandha", "Kamsa", "Bali", "Prahlada", "Hiranyakashipu", "Hiranyaksha", "Skanda", "Kartikeya",
        "Ganesha", "Vinayaka", "Durga", "Kali", "Uma", "Gauri", "Anasuya", "Ahalya", "Tara",
        "Janaka", "Ailavila", "Trinavindu", "Vishala", "Satyavrata", "Trishhanku", "Harish Chandra",
        "Sagara", "Bhagiratha", "Dilipa", "Raghu", "Aja", "Kusha", "Lava", "Romapāda", "Śāntā", "Shanta",
        "Rṣyaśṛṅga", "Rsyasringa", "Vibhāṇḍaka", "Vibhandaka"
    ]

    print("Purging non-character entries from database...")
    
    # Delete characters not in the strict whitelist using NOT = ANY
    cur.execute("""
        DELETE FROM characters 
        WHERE name <> ALL(%s);
    """, (absolute_whitelist,))
    
    deleted = cur.rowcount
    conn.commit()
    print(f" -> Purged {deleted} non-character entries. Keeping only true epic legends.")

    cur.close()
    conn.close()
    
    print("Running auto-injection pipeline for clean entities...")
    os.system("python3 scripts/auto_inject_pipeline.py --all-sources")
    print("Database cleanup and synchronization complete!")

if __name__ == "__main__":
    main()
