import os
import psycopg2
from dotenv import load_dotenv

load_dotenv('backend/.env')
conn = psycopg2.connect(
    dbname=os.getenv('DB_NAME', 'postgres'),
    user=os.getenv('DB_USER', 'project_se'),
    password=os.getenv('DB_PASSWORD'),
    host=os.getenv('DB_HOST', 'localhost'),
    port=os.getenv('DB_PORT', '5432')
)
cur = conn.cursor()

query = """
SELECT 
    c.name AS character_name,
    ca.alias AS matched_alias,
    COUNT(cm.id) AS mention_count
FROM characters c
JOIN character_aliases ca ON ca.character_id = c.id
JOIN character_mentions cm ON cm.alias_id = ca.id
JOIN chapters ch ON ch.id = cm.chapter_id
JOIN books b ON b.id = ch.book_id
WHERE b.source_id = 6
GROUP BY c.name, ca.alias
ORDER BY c.name, mention_count DESC;
"""

cur.execute(query)
rows = cur.fetchall()

print("=" * 60)
print(f"{'CHARACTER':<20} | {'ALIAS MATCHED':<20} | {'COUNT'}")
print("-" * 60)
for row in rows:
    print(f"{row[0]:<20} | {row[1]:<20} | {row[2]}")
print("=" * 60)

conn.close()
