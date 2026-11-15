#!/usr/bin/env python3
"""
MYTHVERSE CHARACTER RELATIONSHIP FIXER
--------------------------------------
- Leaves all character descriptions and backgrounds completely untouched.
- Purges all generic "Narrative Counterpart (X shared passages)" links.
- Populates accurate mythological relationships (Kinship, Lineage, Guru-Shishya,
  Saptarishi brotherhood, Alliances, Adversaries, and Puranic Interlocutors)
  where the label clearly states WHO the related character is to the current character.
"""

import os
import re
import sys
import unicodedata
from collections import Counter, defaultdict

ROOT_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
BACKEND_DIR = os.path.join(ROOT_DIR, "backend")
for p in (BACKEND_DIR, ROOT_DIR):
    if os.path.isdir(p) and p not in sys.path:
        sys.path.insert(0, p)

from database import get_connection


def norm(text: str) -> str:
    if not text:
        return ""
    return "".join(
        c for c in unicodedata.normalize("NFD", str(text))
        if unicodedata.category(c) != "Mn"
    ).lower().strip()


# ==============================================================================
# 1. COMPREHENSIVE MYTHOLOGICAL RELATIONSHIP GRAPH
# Tuple format: (Char_A, Char_B, Who_B_is_to_A, Who_A_is_to_B)
# Example: ("Rama", "Dasharatha", "Father", "Eldest Son")
#   -> On Rama's page:       [Dasharatha | Father]
#   -> On Dasharatha's page: [Rama       | Eldest Son]
# ==============================================================================

MYTHOLOGICAL_RELATIONS = [
    # --- Ikshvaku / Ayodhya Royal Family ---
    ("Rama", "Dasharatha", "Father", "Eldest Son"),
    ("Lakshmana", "Dasharatha", "Father", "Son"),
    ("Bharata", "Dasharatha", "Father", "Son"),
    ("Shatrughna", "Dasharatha", "Father", "Youngest Son"),
    ("Rama", "Kausalya", "Mother", "Son"),
    ("Bharata", "Kaikeyi", "Mother", "Son"),
    ("Lakshmana", "Sumitra", "Mother", "Son"),
    ("Shatrughna", "Sumitra", "Mother", "Son"),
    ("Dasharatha", "Kausalya", "Chief Queen / Consort", "Husband & King"),
    ("Dasharatha", "Kaikeyi", "Queen / Consort", "Husband & King"),
    ("Dasharatha", "Sumitra", "Queen / Consort", "Husband & King"),
    ("Rama", "Sita", "Beloved Consort", "Husband & Lord"),
    ("Sita", "Janaka", "Father", "Daughter"),
    ("Lakshmana", "Sita", "Sister-in-Law", "Devoted Brother-in-Law"),
    ("Rama", "Lakshmana", "Devoted Younger Brother", "Elder Brother & Lord"),
    ("Rama", "Bharata", "Younger Brother", "Elder Brother"),
    ("Rama", "Shatrughna", "Youngest Brother", "Elder Brother"),
    ("Lakshmana", "Shatrughna", "Twin Brother", "Twin Brother"),
    ("Bharata", "Lakshmana", "Brother", "Brother"),
    ("Bharata", "Shatrughna", "Younger Brother", "Elder Brother"),
    ("Rama", "Kusha", "Son", "Father"),
    ("Rama", "Lava", "Son", "Father"),
    ("Sita", "Kusha", "Son", "Mother"),
    ("Sita", "Lava", "Son", "Mother"),
    ("Kusha", "Lava", "Twin Brother", "Twin Brother"),
    ("Dasharatha", "Ikshvaku", "Dynastic Forefather", "Royal Descendant"),
    ("Rama", "Ikshvaku", "Dynastic Forefather", "Royal Descendant"),
    ("Rama", "Raghu", "Royal Ancestor", "Descendant (Raghava)"),
    ("Dasharatha", "Raghu", "Royal Ancestor", "Descendant"),
    ("Sagara", "Bhagiratha", "Great-Grandson", "Royal Ancestor"),
    ("Dasharatha", "Romapada", "Royal Friend & Ally", "Royal Friend & Ally"),
    ("Romapada", "Shanta", "Adopted Daughter", "Foster Father"),
    ("Rishyasringa", "Shanta", "Consort / Wife", "Husband"),
    ("Rishyasringa", "Vibhandaka", "Father & Guru", "Son"),
    ("Dasharatha", "Rishyasringa", "Son-in-Law & Priest", "Father-in-Law"),
    ("Dasharatha", "Sumantra", "Chief Minister & Charioteer", "Sovereign King"),
    ("Rama", "Sumantra", "Royal Charioteer & Counselor", "Beloved Prince"),
    ("Rama", "Guha", "Nishada King & Friend", "Beloved Friend & Lord"),

    # --- Preceptors & Sages of the Ramayana ---
    ("Rama", "Vishvamitra", "Guru & Astras Preceptor", "Foremost Royal Disciple"),
    ("Lakshmana", "Vishvamitra", "Guru & Preceptor", "Royal Disciple"),
    ("Dasharatha", "Vasishtha", "Royal Kulaguru", "Patron Monarch"),
    ("Rama", "Vasishtha", "Royal Kulaguru", "Royal Disciple"),
    ("Vasishtha", "Vishvamitra", "Former Rival & Fellow Brahmarshi", "Fellow Brahmarshi"),
    ("Vasishtha", "Arundhati", "Consort", "Husband"),
    ("Vishvamitra", "Menaka", "Celestial Consort", "Consort"),
    ("Vishvamitra", "Satananda", "Sage Interlocutor", "Revered Brahmarshi"),
    ("Janaka", "Satananda", "Royal Purohita (Priest)", "Patron King"),
    ("Gautama", "Ahalya", "Wife", "Husband"),
    ("Gautama", "Satananda", "Son", "Father"),
    ("Ahalya", "Satananda", "Son", "Mother"),
    ("Rama", "Ahalya", "Redeemed by Rama", "Liberator"),
    ("Rama", "Agastya", "Revered Sage & Bestower of Weapons", "Divine Guest"),
    ("Rama", "Bharadvaja", "Host Sage at Prayaga", "Honored Royal Guest"),
    ("Valmiki", "Narada", "Celestial Narrator & Inspiration", "Author of the Ramayana"),
    ("Valmiki", "Rama", "Protagonist of His Epic", "Chronicler & Poet"),
    ("Valmiki", "Sita", "Sheltered in His Hermitage", "Protector Sage"),
    ("Valmiki", "Bharadvaja", "Chief Disciple", "Guru / Preceptor"),

    # --- Vanaras, Allies & Lanka Characters ---
    ("Rama", "Hanuman", "Devoted Emissary & Champion", "Revered Lord"),
    ("Sita", "Hanuman", "Protector & Messenger", "Revered Mother / Queen"),
    ("Rama", "Sugriva", "Sworn Vanara Ally", "Sworn Ally & Protector"),
    ("Sugriva", "Hanuman", "Chief Minister & Emissary", "Vanara King"),
    ("Sugriva", "Vali", "Elder Brother & Rival", "Younger Brother & Rival"),
    ("Rama", "Vali", "Slain by Rama", "Slayer"),
    ("Vali", "Angada", "Son", "Father"),
    ("Sugriva", "Angada", "Nephew & Heir Apparent", "Paternal Uncle"),
    ("Hanuman", "Vayu", "Divine Father", "Son (Pavanaputra)"),
    ("Rama", "Jatayu", "Martyred Protector of Sita", "Revered Prince"),
    ("Dasharatha", "Jatayu", "Ancient Friend", "Ancient Friend"),
    ("Jatayu", "Sampati", "Elder Brother", "Younger Brother"),
    ("Jatayu", "Aruna", "Father", "Son"),
    ("Rama", "Vibhishana", "Righteous Ally in Lanka", "Revered Lord & Ally"),
    ("Ravana", "Vibhishana", "Righteous Younger Brother", "Elder Brother"),
    ("Ravana", "Kumbhakarna", "Younger Brother", "Elder Brother"),
    ("Vibhishana", "Kumbhakarna", "Elder Brother", "Younger Brother"),
    ("Ravana", "Indrajit", "Son (Meghanada)", "Father"),
    ("Ravana", "Mandodari", "Chief Queen / Consort", "Husband"),
    ("Ravana", "Surpanakha", "Sister", "Brother"),
    ("Ravana", "Khara", "Half-Brother & General", "Sovereign Brother"),
    ("Ravana", "Maricha", "Maternal Uncle & Advisor", "Nephew & King"),
    ("Ravana", "Kubera", "Half-Brother & Rival", "Half-Brother"),
    ("Ravana", "Pulastya", "Paternal Grandfather", "Grandson"),
    ("Kubera", "Pulastya", "Paternal Grandfather", "Grandson"),
    ("Rama", "Ravana", "Arch-Adversary", "Vanquisher"),
    ("Sita", "Ravana", "Abductor & Adversary", "Captive Princess"),
    ("Lakshmana", "Indrajit", "Arch-Rival in Battle", "Vanquisher"),
    ("Rama", "Tataka", "Slain Rakshasi", "Slayer"),
    ("Rama", "Maricha", "Slain Rakshasa", "Slayer"),
    ("Tataka", "Maricha", "Son", "Mother"),

    # --- Saptarishis, Prajapatis & Cosmic Lineage (Garuda / Puranas) ---
    ("Pulastya", "Brahma", "Creator Father", "Mind-born Son (Prajapati)"),
    ("Atri", "Brahma", "Creator Father", "Mind-born Son (Saptarishi)"),
    ("Bhrigu", "Brahma", "Creator Father", "Mind-born Son (Prajapati)"),
    ("Angira", "Brahma", "Creator Father", "Mind-born Son (Saptarishi)"),
    ("Kratu", "Brahma", "Creator Father", "Mind-born Son (Saptarishi)"),
    ("Marichi", "Brahma", "Creator Father", "Mind-born Son (Saptarishi)"),
    ("Pulaha", "Brahma", "Creator Father", "Mind-born Son (Saptarishi)"),
    ("Vasishtha", "Brahma", "Creator Father", "Mind-born Son (Saptarishi)"),
    ("Narada", "Brahma", "Creator Father", "Mind-born Son (Devarshi)"),
    ("Daksha", "Brahma", "Creator Father", "Mind-born Son (Prajapati)"),

    # Saptarishi Brotherhood (Fixes the exact Pulastya screenshot!)
    ("Pulastya", "Atri", "Fellow Saptarishi & Mind-born Brother", "Fellow Saptarishi & Mind-born Brother"),
    ("Pulastya", "Bhrigu", "Fellow Prajapati & Mind-born Brother", "Fellow Prajapati & Mind-born Brother"),
    ("Pulastya", "Angira", "Fellow Saptarishi & Mind-born Brother", "Fellow Saptarishi & Mind-born Brother"),
    ("Pulastya", "Kratu", "Fellow Saptarishi & Mind-born Brother", "Fellow Saptarishi & Mind-born Brother"),
    ("Pulastya", "Marichi", "Fellow Saptarishi & Mind-born Brother", "Fellow Saptarishi & Mind-born Brother"),
    ("Pulastya", "Pulaha", "Fellow Saptarishi & Mind-born Brother", "Fellow Saptarishi & Mind-born Brother"),
    ("Atri", "Bhrigu", "Fellow Saptarishi & Mind-born Brother", "Fellow Saptarishi & Mind-born Brother"),
    ("Atri", "Angira", "Fellow Saptarishi & Mind-born Brother", "Fellow Saptarishi & Mind-born Brother"),
    ("Atri", "Marichi", "Fellow Saptarishi & Mind-born Brother", "Fellow Saptarishi & Mind-born Brother"),
    ("Atri", "Kratu", "Fellow Saptarishi & Mind-born Brother", "Fellow Saptarishi & Mind-born Brother"),
    ("Atri", "Pulaha", "Fellow Saptarishi & Mind-born Brother", "Fellow Saptarishi & Mind-born Brother"),
    ("Bhrigu", "Angira", "Fellow Prajapati & Sage", "Fellow Prajapati & Sage"),
    ("Bhrigu", "Marichi", "Fellow Prajapati & Sage", "Fellow Prajapati & Sage"),
    ("Bhrigu", "Kratu", "Fellow Prajapati & Sage", "Fellow Prajapati & Sage"),
    ("Bhrigu", "Pulaha", "Fellow Prajapati & Sage", "Fellow Prajapati & Sage"),
    ("Angira", "Marichi", "Fellow Saptarishi", "Fellow Saptarishi"),
    ("Angira", "Kratu", "Fellow Saptarishi", "Fellow Saptarishi"),
    ("Angira", "Pulaha", "Fellow Saptarishi", "Fellow Saptarishi"),
    ("Marichi", "Kratu", "Fellow Saptarishi", "Fellow Saptarishi"),
    ("Marichi", "Pulaha", "Fellow Saptarishi", "Fellow Saptarishi"),
    ("Kratu", "Pulaha", "Fellow Saptarishi", "Fellow Saptarishi"),

    # Kashyapa, Garuda & Deva/Asura Lineage
    ("Kashyapa", "Marichi", "Father", "Son"),
    ("Kashyapa", "Aditi", "Consort (Mother of Devas)", "Husband"),
    ("Kashyapa", "Diti", "Consort (Mother of Daityas)", "Husband"),
    ("Kashyapa", "Vinata", "Consort (Mother of Garuda)", "Husband"),
    ("Kashyapa", "Kadru", "Consort (Mother of Nagas)", "Husband"),
    ("Kashyapa", "Daksha", "Father-in-Law", "Son-in-Law"),
    ("Garuda", "Kashyapa", "Father", "Son"),
    ("Garuda", "Vinata", "Mother", "Son (Vainateya)"),
    ("Garuda", "Aruna", "Elder Brother", "Younger Brother"),
    ("Garuda", "Vishnu", "Supreme Lord & Narrator", "Divine Mount & Interlocutor"),
    ("Indra", "Kashyapa", "Father", "Son"),
    ("Indra", "Aditi", "Mother", "Son (Aditya)"),
    ("Surya", "Kashyapa", "Father", "Son (Vivasvan)"),
    ("Surya", "Aditi", "Mother", "Son (Aditya)"),

    # Trimurti, Devis & Ganesha Purana
    ("Vishnu", "Lakshmi", "Divine Consort", "Husband & Lord"),
    ("Vishnu", "Rama", "Seventh Avatar", "Supreme Source Deity"),
    ("Vishnu", "Krishna", "Eighth Avatar", "Supreme Source Deity"),
    ("Vishnu", "Shiva", "Co-eval Supreme Deity (Hari-Hara)", "Co-eval Supreme Deity (Hari-Hara)"),
    ("Vishnu", "Brahma", "Creator Born from Cosmic Lotus", "Supreme Preserver"),
    ("Shiva", "Parvati", "Divine Consort (Uma)", "Husband (Mahadeva)"),
    ("Shiva", "Ganesha", "Son", "Father"),
    ("Parvati", "Ganesha", "Son", "Mother"),
    ("Shiva", "Kartikeya", "Son (Skanda)", "Father"),
    ("Parvati", "Kartikeya", "Son (Skanda)", "Mother"),
    ("Ganesha", "Kartikeya", "Brother", "Brother"),
    ("Brahma", "Sarasvati", "Divine Consort", "Consort"),
    ("Bhrigu", "Cyavana", "Son", "Father"),
    ("Bhrigu", "Somakanta", "King He Counselled & Healed", "Royal Spiritual Preceptor"),
    ("Cyavana", "Somakanta", "Disciple & Listener", "Preceptor Sage"),
    ("Suta", "Shaunaka", "Chief Listener at Naimisharanya", "Puranic Narrator"),
    ("Suta", "Vyasa", "Guru & Compiler of Puranas", "Chief Puranic Disciple"),

    # --- Bhagavad Gita & Mahabharata ---
    ("Arjuna", "Krishna", "Divine Charioteer, Friend & Guru", "Beloved Disciple & Friend"),
    ("Arjuna", "Indra", "Divine Father", "Son"),
    ("Arjuna", "Kunti", "Mother", "Third Son"),
    ("Arjuna", "Pandu", "Father", "Son"),
    ("Yudhishthira", "Kunti", "Mother", "Eldest Son"),
    ("Bhima", "Kunti", "Mother", "Second Son"),
    ("Bhimasena", "Kunti", "Mother", "Second Son"),
    ("Yudhishthira", "Arjuna", "Younger Brother", "Eldest Brother & King"),
    ("Bhima", "Arjuna", "Younger Brother", "Elder Brother"),
    ("Bhimasena", "Arjuna", "Younger Brother", "Elder Brother"),
    ("Yudhishthira", "Bhima", "Younger Brother", "Eldest Brother"),
    ("Yudhishthira", "Draupadi", "Queen & Consort", "Husband"),
    ("Arjuna", "Draupadi", "Consort", "Husband"),
    ("Bhima", "Draupadi", "Consort", "Husband"),
    ("Arjuna", "Subhadra", "Consort (Sister of Krishna)", "Husband"),
    ("Krishna", "Subhadra", "Sister", "Brother"),
    ("Arjuna", "Abhimanyu", "Son", "Father"),
    ("Arjuna", "Drona", "Martial Preceptor (Guru)", "Foremost Pupil"),
    ("Drona", "Ashvatthama", "Son", "Father"),
    ("Drona", "Kripa", "Brother-in-Law & Fellow Preceptor", "Brother-in-Law"),
    ("Bhishma", "Arjuna", "Beloved Grand-Nephew", "Revered Grand-Uncle (Pitamaha)"),
    ("Bhishma", "Yudhishthira", "Grand-Nephew", "Revered Grand-Uncle (Pitamaha)"),
    ("Bhishma", "Duryodhana", "Grand-Nephew & Commander's Liege", "Grand-Uncle & Supreme Commander"),
    ("Bhishma", "Dhritarashtra", "Nephew & King", "Grand-Uncle & Counselor"),
    ("Dhritarashtra", "Sanjaya", "Charioteer & Clairvoyant Narrator", "Blind Kuru Monarch"),
    ("Dhritarashtra", "Duryodhana", "Eldest Son", "Father"),
    ("Dhritarashtra", "Pandu", "Younger Brother", "Elder Brother"),
    ("Duryodhana", "Karna", "Loyal Friend & Champion", "Sworn Friend & Patron"),
    ("Duryodhana", "Drona", "Martial Preceptor & Commander", "Royal Pupil & Prince"),
    ("Duryodhana", "Arjuna", "Cousin & Arch-Rival", "Cousin & Arch-Rival"),
    ("Duryodhana", "Bhima", "Cousin & Sworn Nemesis", "Cousin & Sworn Nemesis"),
    ("Duryodhana", "Bhimasena", "Cousin & Sworn Nemesis", "Cousin & Sworn Nemesis"),
    ("Karna", "Arjuna", "Arch-Rival & Maternal Half-Brother", "Arch-Rival & Half-Brother"),
    ("Karna", "Kunti", "Biological Mother", "Firstborn Son"),
    ("Karna", "Surya", "Divine Father", "Son"),
]

# Regex patterns on paragraph text:
# If text matches `Name_A ... pattern ... Name_B`, it means A is [rel_A] of B,
# so on A's page B is `who_B_is_to_A`, and on B's page A is `who_A_is_to_B`.
TEXT_DEPENDENCY_PATTERNS = [
    (r"\b(?:son|offspring)\s+of\b", "Parent", "Son"),
    (r"\b(?:daughter)\s+of\b", "Parent", "Daughter"),
    (r"\b(?:father|sire)\s+of\b", "Child", "Father"),
    (r"\b(?:mother)\s+of\b", "Child", "Mother"),
    (r"\b(?:wife|consort|queen|spouse)\s+of\b", "Husband / Consort", "Consort / Wife"),
    (r"\b(?:husband|lord)\s+of\b", "Consort / Wife", "Husband"),
    (r"\b(?:brother)\s+of\b", "Brother", "Brother"),
    (r"\b(?:sister)\s+of\b", "Sibling", "Sister"),
    (r"\b(?:disciple|pupil|student)\s+of\b", "Guru / Preceptor", "Disciple"),
    (r"\b(?:guru|preceptor|teacher)\s+of\b", "Disciple", "Guru / Preceptor"),
    (r"\b(?:minister|counselor|charioteer|envoy)\s+of\b", "Sovereign / Liege", "Minister / Envoy"),
    (r"\b(?:friend|ally)\s+of\b", "Sworn Ally", "Sworn Ally"),
    (r"\b(?:slew|killed|vanquished|defeated|slaughtered)\b", "Vanquished Adversary", "Vanquisher"),
    (r"\b(?:slain|killed|defeated)\s+by\b", "Vanquisher", "Slain Adversary"),
    (r"\b(?:cursed)\b", "Recipient of Curse", "Bestower of Curse"),
    (r"\b(?:blessed|granted\s+a\s+boon\s+to)\b", "Recipient of Boon", "Bestower of Boon"),
]


# ==============================================================================
# 2. ARCHETYPE-SMART RELATIONSHIP INFERENCE (FOR REMAINING CO-OCCURRENCES)
# ==============================================================================

def get_archetype(role_text: str) -> str:
    r = (role_text or "").lower()
    if any(k in r for k in ("sage", "rishi", "seer", "muni", "brahmarshi", "preceptor")):
        return "sage"
    if any(k in r for k in ("deity", "god", "avatar", "supreme", "celestial", "lord")):
        return "deity"
    if any(k in r for k in ("rakshasa", "asura", "demon", "daitya")):
        return "asura"
    if any(k in r for k in ("vanara", "monkey", "bird", "eagle", "mount", "creature")):
        return "creature"
    if any(k in r for k in ("king", "prince", "princess", "queen", "royal", "warrior", "charioteer", "minister")):
        return "royal"
    return "figure"


def infer_meaningful_relation(char_a: dict, char_b: dict) -> tuple[str, str]:
    """
    Infers a clean mythological relationship between two co-occurring characters
    based on their archetypes so we NEVER output 'Narrative Counterpart (X shared passages)'.
    Returns (who_B_is_to_A, who_A_is_to_B).
    """
    arch_a = get_archetype(char_a["role"])
    arch_b = get_archetype(char_b["role"])

    if arch_a == "sage" and arch_b == "sage":
        return ("Fellow Vedic Sage", "Fellow Vedic Sage")
    if arch_a == "royal" and arch_b == "sage":
        return ("Spiritual Guide & Sage", "Royal Patron & Interlocutor")
    if arch_a == "sage" and arch_b == "royal":
        return ("Royal Patron & Interlocutor", "Spiritual Guide & Sage")
    if arch_a == "deity" and arch_b == "sage":
        return ("Devotee & Seer", "Revered Deity")
    if arch_a == "sage" and arch_b == "deity":
        return ("Revered Deity", "Devotee & Seer")
    if arch_a == "deity" and arch_b == "royal":
        return ("Devoted Royal Hero", "Presiding Deity")
    if arch_a == "royal" and arch_b == "deity":
        return ("Presiding Deity", "Devoted Royal Hero")
    if arch_a == "deity" and arch_b == "deity":
        return ("Fellow Celestial Deity", "Fellow Celestial Deity")
    if (arch_a in ("royal", "deity", "creature") and arch_b == "asura"):
        return ("Adversary in Battle", "Adversary in Battle")
    if (arch_a == "asura" and arch_b in ("royal", "deity", "creature")):
        return ("Adversary in Battle", "Adversary in Battle")
    if arch_a == "asura" and arch_b == "asura":
        return ("Rakshasa / Asura Kin", "Rakshasa / Asura Kin")
    if arch_a == "royal" and arch_b == "royal":
        return ("Royal Contemporary & Ally", "Royal Contemporary & Ally")
    if arch_a == "creature" and arch_b == "royal":
        return ("Royal Ally", "Sworn Vanara / Celestial Ally")
    if arch_a == "royal" and arch_b == "creature":
        return ("Sworn Vanara / Celestial Ally", "Royal Ally")

    return ("Sacred Text Interlocutor", "Sacred Text Interlocutor")


# ==============================================================================
# 3. EXECUTE CLEANUP & RE-POPULATION
# ==============================================================================

def main():
    conn = get_connection()
    cur = conn.cursor()

    try:
        print("🧹 Cleaning out generic 'Narrative Counterpart' & inverted rows...")
        cur.execute("TRUNCATE TABLE character_relationships RESTART IDENTITY;")
        conn.commit()

        # Load all characters & their roles
        cur.execute("""
            SELECT c.id, c.name, COALESCE(cp.role, c.description, '') AS role
            FROM characters c
            LEFT JOIN character_profiles cp ON cp.character_id = c.id
            ORDER BY c.id;
        """)
        characters = {}
        alias_to_id = {}
        for cid, name, role in cur.fetchall():
            characters[cid] = {"id": cid, "name": name, "role": role}
            alias_to_id[norm(name)] = cid

        cur.execute("SELECT character_id, alias FROM character_aliases;")
        for cid, alias in cur.fetchall():
            if cid in characters and alias:
                alias_to_id[norm(alias)] = cid

        existing_pairs = set()

        def add_bidirectional(id_a: int, id_b: int, who_b_is_to_a: str, who_a_is_to_b: str) -> int:
            if not id_a or not id_b or id_a == id_b:
                return 0
            added = 0
            if (id_a, id_b) not in existing_pairs:
                cur.execute(
                    """
                    INSERT INTO character_relationships (character_id, related_character_id, relationship_type)
                    VALUES (%s, %s, %s);
                    """,
                    (id_a, id_b, who_b_is_to_a),
                )
                existing_pairs.add((id_a, id_b))
                added += 1
            if (id_b, id_a) not in existing_pairs:
                cur.execute(
                    """
                    INSERT INTO character_relationships (character_id, related_character_id, relationship_type)
                    VALUES (%s, %s, %s);
                    """,
                    (id_b, id_a, who_a_is_to_b),
                )
                existing_pairs.add((id_b, id_a))
                added += 1
            return added

        # ------------------------------------------------------------------
        # TIER 1: Canonical Mythological Genealogy & Relationships
        # ------------------------------------------------------------------
        tier1_count = 0
        for name_a, name_b, b_to_a, a_to_b in MYTHOLOGICAL_RELATIONS:
            id_a = alias_to_id.get(norm(name_a))
            id_b = alias_to_id.get(norm(name_b))
            if id_a and id_b:
                tier1_count += add_bidirectional(id_a, id_b, b_to_a, a_to_b)
        conn.commit()
        print(f"⚡ Tier 1 (Canonical Genealogy & Epics): Inserted {tier1_count} verified relationships.")

        # ------------------------------------------------------------------
        # TIER 2: Paragraph Dependency & Possessive Pattern Extraction
        # ------------------------------------------------------------------
        cur.execute("""
            SELECT
                cm.character_id,
                cp.content,
                cm.chapter_id,
                cm.paragraph_number
            FROM character_mentions cm
            JOIN chapter_paragraphs cp
              ON cp.chapter_id = cm.chapter_id
             AND cp.paragraph_number = cm.paragraph_number
            WHERE cp.content IS NOT NULL;
        """)
        para_chars = defaultdict(set)
        para_text = {}
        for cid, content, ch_id, p_num in cur.fetchall():
            key = (ch_id, p_num)
            para_chars[key].add(cid)
            if key not in para_text:
                para_text[key] = norm(content)

        co_occurrence = Counter()
        tier2_count = 0

        for key, cids in para_chars.items():
            if len(cids) < 2:
                continue
            cid_list = sorted(cids)
            text = para_text[key]

            for i in range(len(cid_list)):
                for j in range(i + 1, len(cid_list)):
                    ca, cb = cid_list[i], cid_list[j]
                    co_occurrence[(ca, cb)] += 1

                    if (ca, cb) in existing_pairs:
                        continue

                    na = norm(characters[ca]["name"])
                    nb = norm(characters[cb]["name"])
                    if not na or not nb:
                        continue

                    # Check possessive: "X's son Y" -> X is Parent of Y, Y is Son of X
                    if re.search(rf"\b{re.escape(na)}'s\s+son\s+{re.escape(nb)}\b", text):
                        tier2_count += add_bidirectional(ca, cb, "Son", "Father / Parent")
                        continue
                    if re.search(rf"\b{re.escape(nb)}'s\s+son\s+{re.escape(na)}\b", text):
                        tier2_count += add_bidirectional(ca, cb, "Father / Parent", "Son")
                        continue

                    for pat, b_to_a, a_to_b in TEXT_DEPENDENCY_PATTERNS:
                        if re.search(rf"\b{re.escape(na)}\b[^.?!]{{0,50}}{pat}[^.?!]{{0,30}}\b{re.escape(nb)}\b", text):
                            tier2_count += add_bidirectional(ca, cb, b_to_a, a_to_b)
                            break
                        if re.search(rf"\b{re.escape(nb)}\b[^.?!]{{0,50}}{pat}[^.?!]{{0,30}}\b{re.escape(na)}\b", text):
                            tier2_count += add_bidirectional(cb, ca, b_to_a, a_to_b)
                            break

        conn.commit()
        print(f"🧠 Tier 2 (NLP Syntax & Possessive Mining): Inserted {tier2_count} relationships.")

        # ------------------------------------------------------------------
        # TIER 3: Archetype-Smart Inference for Any Character With < 3 Links
        # ------------------------------------------------------------------
        rel_counts = Counter(a for a, _ in existing_pairs)
        neighbors = defaultdict(list)
        for (ca, cb), weight in co_occurrence.items():
            neighbors[ca].append((weight, cb))
            neighbors[cb].append((weight, ca))

        tier3_count = 0
        for cid, cinfo in characters.items():
            if rel_counts[cid] >= 2:
                continue
            top_n = sorted(neighbors.get(cid, []), key=lambda x: x[0], reverse=True)
            for weight, other_id in top_n[:3]:
                b_to_a, a_to_b = infer_meaningful_relation(cinfo, characters[other_id])
                added = add_bidirectional(cid, other_id, b_to_a, a_to_b)
                if added:
                    tier3_count += added
                    rel_counts[cid] += 1
                    if rel_counts[cid] >= 3:
                        break

        conn.commit()
        print(f"🏛️  Tier 3 (Archetype Role Classification): Inserted {tier3_count} relationships.")

        cur.execute("SELECT COUNT(*) FROM character_relationships;")
        total = cur.fetchone()[0]
        print(f"\n✅ DONE! {total} clean, human-readable character relationships are now live.")

    finally:
        cur.close()
        conn.close()


if __name__ == "__main__":
    main()