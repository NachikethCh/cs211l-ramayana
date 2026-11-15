#!/usr/bin/env python3
"""
MYTHVERSE AUTOMATED CHARACTER DESCRIPTION & RELATIONSHIP POPULATOR
------------------------------------------------------------------
Matches the exact schema in backend/main.py:
  - characters (id, name, description)
  - character_profiles (character_id, background, role, source_url)
  - character_aliases (character_id, alias)
  - character_relationships (character_id, related_character_id, relationship_type)
  - character_mentions (id, character_id, chapter_id, mentioned_text, paragraph_number)
  - chapter_paragraphs (chapter_id, paragraph_number, content)
  - character_events (id, character_id, chapter_id, event_title, event_summary, paragraph_start, paragraph_end)

Usage:
  python3 scripts/enrich_characters.py            # Enrich missing/generic descriptions & all relationships
  python3 scripts/enrich_characters.py --force    # Re-generate descriptions/backgrounds for ALL characters
"""

import os
import re
import sys
import unicodedata
from collections import Counter, defaultdict

# Add backend/ and project root to sys.path so `from database import get_connection` works anywhere
ROOT_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
BACKEND_DIR = os.path.join(ROOT_DIR, "backend")
for p in (BACKEND_DIR, ROOT_DIR):
    if os.path.isdir(p) and p not in sys.path:
        sys.path.insert(0, p)

from database import get_connection


def strip_diacritics(text: str) -> str:
    if not text:
        return ""
    return "".join(
        c for c in unicodedata.normalize("NFD", str(text))
        if unicodedata.category(c) != "Mn"
    ).lower().strip()


# ==============================================================================
# 1. ARCHETYPE & ROLE CLASSIFIER RULES (Aligned with main.py /graph groups)
# ==============================================================================

KNOWN_CHARACTER_ROLES = {
    "rama": ("Prince of Ayodhya & Seventh Avatar of Vishnu (Royal / Deity)", "Royal prince of Kosala, eldest son of King Dasharatha and Queen Kausalya, and the central hero of the Ramayana."),
    "sita": ("Princess of Mithila & Consort of Rama (Royal Queen)", "Daughter of King Janaka of Mithila and beloved consort of Prince Rama, revered for her unwavering dharma and devotion."),
    "lakshmana": ("Prince of Ayodhya & Devoted Brother of Rama (Royal Warrior)", "Son of King Dasharatha and Queen Sumitra who accompanied Rama and Sita throughout their fourteen-year forest exile."),
    "hanuman": ("Vanara Chief & Devoted Emissary of Rama (Vanara / Deity)", "Son of Vayu and Anjana, foremost minister to Sugriva, and heroic devotee of Rama who leaped across the ocean to Lanka."),
    "ravana": ("Rakshasa Emperor of Lanka (Asura / Rakshasa King)", "Ten-headed Rakshasa ruler of Lanka, son of Vishrava and Kaikashi, and primary antagonist of the Ramayana."),
    "dasharatha": ("King of Kosala & Ruler of Ayodhya (Royal King)", "Sovereign of the Ikshvaku dynasty in Ayodhya and father of Rama, Bharata, Lakshmana, and Shatrughna."),
    "bharata": ("Prince of Ayodhya & Son of Kaikeyi (Royal Prince)", "Righteous son of Dasharatha and Kaikeyi who ruled Kosala as regent by placing Rama's sandals upon the throne at Nandigrama."),
    "shatrughna": ("Prince of Ayodhya & Twin Brother of Lakshmana (Royal Prince)", "Youngest son of King Dasharatha and Queen Sumitra, devoted brother to Bharata and slayer of Lavanasura."),
    "vishvamitra": ("Brahmarshi & Royal Preceptor (Vedic Sage / Rishi)", "Celebrated Vedic rishi, former king Kaushika, who guided young Rama and Lakshmana and bestowed celestial astras upon them."),
    "vasishtha": ("Chief Royal Sage of the Ikshvaku Court (Vedic Sage / Rishi)", "Brahmarshi and spiritual preceptor to King Dasharatha and the royal house of Ayodhya."),
    "sugriva": ("Vanara King of Kishkindha (Vanara / RoyalMount)", "Ruler of the Vanara kingdom of Kishkindha and sworn ally of Prince Rama in the quest to recover Sita."),
    "vali": ("Vanara King of Kishkindha & Brother of Sugriva (Vanara Chief)", "Mightiest warrior of Kishkindha, elder brother of Sugriva and father of Angada."),
    "vibhishana": ("Righteous Rakshasa Prince & Ally of Rama (Asura / Royal)", "Younger brother of Ravana who renounced adharma to join Rama and was crowned King of Lanka."),
    "krishna": ("Supreme Deity & Charioteer of Arjuna (Deity / Avatar)", "Eighth avatar of Vishnu, prince of Dvaraka, and divine teacher of the Bhagavad Gita on the battlefield of Kurukshetra."),
    "arjuna": ("Pandava Prince & Foremost Archer (Royal Prince / Warrior)", "Third of the Pandava brothers, son of Indra and Kunti, and interlocutor of Lord Krishna in the Bhagavad Gita."),
    "sanjaya": ("Royal Charioteer & Clairvoyant Narrator (Royal Minister)", "Advisor and charioteer to King Dhritarashtra, blessed with divine sight by Sage Vyasa to narrate the Bhagavad Gita."),
    "dhritarashtra": ("Blind King of Hastinapura (Royal King)", "Kuru monarch of Hastinapura, father of Duryodhana and the Kauravas, to whom Sanjaya narrates the Bhagavad Gita."),
    "duryodhana": ("Crown Prince of Hastinapura & Kaurava Leader (Royal Prince)", "Eldest son of King Dhritarashtra and Queen Gandhari, and chief rival of the Pandava princes."),
    "bhishma": ("Grand Sire of the Kuru Dynasty (Royal Warrior / Sage)", "Patriarch of Hastinapura, son of Shantanu and Ganga, and supreme commander of the Kaurava forces."),
    "drona": ("Royal Martial Preceptor of the Kurus & Pandavas (Sage / Warrior)", "Master of military arts and teacher to both the Pandava and Kaurava princes."),
    "karna": ("King of Anga & Son of Surya (Royal Warrior)", "Peerless archer, son of Surya and Kunti, and loyal ally to Duryodhana."),
    "yudhishthira": ("Eldest Pandava Prince & King of Indraprastha (Royal King)", "Son of Dharma and Kunti, embodiment of righteousness among the five Pandava brothers."),
    "bhima": ("Pandava Prince of Immense Strength (Royal Warrior)", "Second Pandava brother, son of Vayu and Kunti, renowned for his mace mastery."),
    "garuda": ("Celestial Eagle & Divine Mount of Vishnu (Celestial Bird / Mount)", "King of birds, son of Sage Kashyapa and Vinata, and the primary interlocutor with Lord Vishnu in the Garuda Purana."),
    "vishnu": ("Supreme Preserver Deity of the Cosmos (Deity / Lord)", "Preserver of cosmic order (dharma), consort of Lakshmi, and supreme narrator of the Garuda Purana."),
    "shiva": ("Supreme Ascetic Deity & Destroyer of Evil (Deity / Lord)", "Mahadeva, consort of Parvati and father of Ganesha and Kartikeya, revered across the Puranas and Itihasas."),
    "brahma": ("Creator Deity of the Universe (Deity / Prajapati)", "Four-faced creator god of the Hindu triad and grandsire (Pitamaha) of the worlds."),
    "indra": ("King of the Devas & Lord of Svarga (Deity / Celestial King)", "Ruler of the celestial gods, wielder of the Vajra thunderbolt, and lord of rain and heaven."),
    "ganesha": ("Lord of Beginnings & Remover of Obstacles (Deity / Lord)", "Elephant-headed deity of wisdom, son of Shiva and Parvati, and supreme subject of the Ganesha Purana."),
    "parvati": ("Divine Mother & Consort of Lord Shiva (Deity / Queen)", "Daughter of Himavan, supreme goddess (Shakti), consort of Shiva, and mother of Ganesha and Kartikeya."),
    "narada": ("Celestial Sage & Divine Messenger (Devarshi / Sage)", "Travelling Vedic rishi and devotee of Vishnu who imparts sacred narratives across the three worlds."),
    "valmiki": ("Adi Kavi & Author of the Ramayana (Vedic Sage / Rishi)", "Revered sage who composed the Sanskrit epic Ramayana and sheltered Sita in his hermitage."),
    "vyasa": ("Compiler of the Vedas & Mahabharata (Vedic Sage / Rishi)", "Krishna Dvaipayana Vyasa, immortal sage and narrator of the Mahabharata and the eighteen Mahapuranas."),
}

# Context regexes that map a character's surrounding text to a role & `/graph` group keyword
CONTEXT_ARCHETYPE_PATTERNS = [
    (r"\b(?:sage|rishi|muni|ascetic|hermit|seer|brahmarshi|maharshi|brahmin|preceptor)\b", "Vedic Sage & Seer"),
    (r"\b(?:god|deity|lord|divine|celestial|supreme|avatar|visnu|vishnu|siva|shiva|brahma|devi|goddess)\b", "Deity & Celestial Figure"),
    (r"\b(?:king|monarch|sovereign|emperor|ruler|maharaja|prince|princess|queen|royal|dynasty|throne)\b", "Royal Figure & Noble"),
    (r"\b(?:rakshasa|asura|demon|fiend|daitya|danava|night-?ranger)\b", "Asura / Rakshasa Figure"),
    (r"\b(?:vanara|monkey|bear|eagle|bird|vulture|serpent|naga|steed|mount|elephant)\b", "Mythological Creature / Vanara"),
    (r"\b(?:warrior|charioteer|general|commander|archer|hero|minister|counselor)\b", "Epic Warrior & Court Figure"),
]


# ==============================================================================
# 2. CANONICAL & NLP RELATIONSHIP RULES
# ==============================================================================

CANONICAL_RELATIONS = [
    ("Rama", "Sita", "Husband of", "Wife of"),
    ("Rama", "Lakshmana", "Elder Brother of", "Younger Brother of"),
    ("Rama", "Bharata", "Elder Brother of", "Younger Brother of"),
    ("Rama", "Shatrughna", "Elder Brother of", "Younger Brother of"),
    ("Dasharatha", "Rama", "Father of", "Son of"),
    ("Dasharatha", "Lakshmana", "Father of", "Son of"),
    ("Dasharatha", "Bharata", "Father of", "Son of"),
    ("Dasharatha", "Shatrughna", "Father of", "Son of"),
    ("Kausalya", "Rama", "Mother of", "Son of"),
    ("Kaikeyi", "Bharata", "Mother of", "Son of"),
    ("Sumitra", "Lakshmana", "Mother of", "Son of"),
    ("Sumitra", "Shatrughna", "Mother of", "Son of"),
    ("Janaka", "Sita", "Father of", "Daughter of"),
    ("Hanuman", "Rama", "Devoted Emissary of", "Revered Lord of"),
    ("Sugriva", "Rama", "Sworn Ally of", "Protector of"),
    ("Sugriva", "Hanuman", "King served by", "Chief Minister of"),
    ("Sugriva", "Vali", "Brother & Rival of", "Brother & Rival of"),
    ("Rama", "Ravana", "Vanquisher of", "Slain by"),
    ("Vibhishana", "Ravana", "Younger Brother of", "Elder Brother of"),
    ("Vibhishana", "Rama", "Righteous Ally of", "Ally of"),
    ("Kumbhakarna", "Ravana", "Brother of", "Brother of"),
    ("Indrajit", "Ravana", "Son of", "Father of"),
    ("Vishvamitra", "Rama", "Spiritual Preceptor of", "Disciple of"),
    ("Vasishtha", "Dasharatha", "Royal Preceptor of", "Patron King of"),
    ("Valmiki", "Narada", "Inspired by", "Narrator to"),
    ("Krishna", "Arjuna", "Divine Charioteer & Guide of", "Disciple & Friend of"),
    ("Sanjaya", "Dhritarashtra", "Charioteer & Narrator to", "Sovereign of"),
    ("Dhritarashtra", "Duryodhana", "Father of", "Eldest Son of"),
    ("Pandu", "Kunti", "Husband of", "Wife of"),
    ("Kunti", "Yudhishthira", "Mother of", "Son of"),
    ("Kunti", "Bhima", "Mother of", "Son of"),
    ("Kunti", "Arjuna", "Mother of", "Son of"),
    ("Yudhishthira", "Arjuna", "Elder Brother of", "Younger Brother of"),
    ("Bhima", "Arjuna", "Elder Brother of", "Younger Brother of"),
    ("Drona", "Arjuna", "Martial Preceptor of", "Foremost Pupil of"),
    ("Bhishma", "Dhritarashtra", "Grand-uncle & Advisor to", "Nephew of"),
    ("Shiva", "Parvati", "Consort of", "Consort of"),
    ("Shiva", "Ganesha", "Father of", "Son of"),
    ("Parvati", "Ganesha", "Mother of", "Son of"),
    ("Vishnu", "Lakshmi", "Consort of", "Consort of"),
    ("Vishnu", "Garuda", "Lord borne by", "Divine Mount & Interlocutor of"),
    ("Kashyapa", "Garuda", "Father of", "Son of"),
    ("Vinata", "Garuda", "Mother of", "Son of"),
    ("Brahma", "Sarasvati", "Consort of", "Consort of"),
    ("Brahma", "Narada", "Father of", "Mind-born Son of"),
    ("Brahma", "Marichi", "Creator Father of", "Mind-born Son of"),
    ("Brahma", "Atri", "Creator Father of", "Mind-born Son of"),
    ("Brahma", "Pulastya", "Creator Father of", "Mind-born Son of"),
    ("Brahma", "Bhrigu", "Creator Father of", "Mind-born Son of"),
    ("Vibhandaka", "Rishyasringa", "Father of", "Son of"),
    ("Romapada", "Shanta", "Foster Father of", "Daughter of"),
    ("Rishyasringa", "Shanta", "Husband of", "Wife of"),
]

# Textual regex patterns between two character names in the same passage
RELATION_PATTERNS = [
    (r"\b(?:son|offspring|child)\s+of\b", "Son of", "Parent of"),
    (r"\b(?:daughter)\s+of\b", "Daughter of", "Parent of"),
    (r"\b(?:father|sire)\s+of\b", "Father of", "Child of"),
    (r"\b(?:mother)\s+of\b", "Mother of", "Child of"),
    (r"\b(?:wife|consort|spouse|queen)\s+of\b", "Consort of", "Spouse of"),
    (r"\b(?:husband|lord)\s+of\b", "Husband of", "Consort of"),
    (r"\b(?:brother)\s+of\b", "Brother of", "Sibling of"),
    (r"\b(?:sister)\s+of\b", "Sister of", "Sibling of"),
    (r"\b(?:disciple|pupil|student)\s+of\b", "Disciple of", "Preceptor of"),
    (r"\b(?:guru|preceptor|teacher)\s+of\b", "Preceptor of", "Disciple of"),
    (r"\b(?:friend|ally|companion)\s+of\b", "Ally of", "Ally of"),
    (r"\b(?:charioteer)\s+of\b", "Charioteer of", "Guided by"),
    (r"\b(?:devotee|worshipper|servant)\s+of\b", "Devotee of", "Revered by"),
    (r"\b(?:minister|counselor|envoy|messenger)\s+of\b", "Minister / Envoy of", "Sovereign of"),
    (r"\b(?:slew|killed|slaughtered|vanquished|defeated)\b", "Vanquished", "Slain / Defeated by"),
    (r"\b(?:slain|killed|defeated)\s+by\b", "Slain / Defeated by", "Vanquished"),
    (r"\b(?:cursed)\b", "Cursed", "Cursed by"),
    (r"\b(?:blessed|granted\s+a\s+boon\s+to)\b", "Blessed", "Blessed by"),
    (r"\b(?:married|wedded)\b", "Spouse of", "Spouse of"),
]


# ==============================================================================
# 3. HELPER: CLEAN SENTENCE EXTRACTION FOR BIOGRAPHIES
# ==============================================================================

def is_placeholder_text(text: str) -> bool:
    if not text or not text.strip():
        return True
    low = text.strip().lower()
    placeholders = (
        "auto-discovered",
        "canonical figure",
        "explore this character",
        "background information is not available",
        "character record",
        "unknown",
    )
    return any(p in low for p in placeholders)


def pick_best_bio_sentences(char_name: str, passages: list[str], max_sentences: int = 2) -> str:
    """Finds the most informative narrative sentences mentioning `char_name`."""
    norm_name = strip_diacritics(char_name)
    scored_sentences = []
    seen_norms = set()

    for passage in passages:
        # Split into sentences
        raw_sents = re.split(r"(?<=[.!?])\s+", passage.strip())
        for sent in raw_sents:
            clean = re.sub(r"\s+", " ", sent).strip()
            if len(clean) < 45 or len(clean) > 320:
                continue

            norm_sent = strip_diacritics(clean)
            if norm_name not in norm_sent:
                continue
            if norm_sent in seen_norms:
                continue

            # Skip pure dialogue prompts like "Rama said:" or footnote numbers
            if re.match(r"^[A-ZĀĪŪṚṢŚṆÑṬḌ\s]{2,25}\s+(?:said|spoke|replied|asked)[:,-]", clean):
                continue

            score = 0
            # Boost sentences with biographical appositives & lineage keywords
            if re.search(r"\b(son|daughter|wife|husband|brother|father|mother|king|prince|queen|sage|rishi|lord|deity|demon|rakshasa|born|chief|disciple|preceptor)\b", norm_sent):
                score += 5
            if re.search(rf"\b{re.escape(norm_name)}\s*,\s*(?:the|a|who)\b", norm_sent):
                score += 4
            if 70 <= len(clean) <= 220:
                score += 2

            seen_norms.add(norm_sent)
            scored_sentences.append((score, clean))

    scored_sentences.sort(key=lambda x: x[0], reverse=True)
    chosen = [s for _, s in scored_sentences[:max_sentences]]
    return " ".join(chosen)


def infer_character_role_and_bio(
    char_name: str,
    passages: list[str],
    event_summaries: list[str],
    source_titles: list[str],
    mention_count: int,
):
    """Generates both a concise `role`/`description` and a rich `background` paragraph."""
    norm_name = strip_diacritics(char_name)
    primary_source = source_titles[0] if source_titles else "the Sacred Epics"
    all_sources_str = ", ".join(source_titles) if source_titles else "Indian Epic Literature"

    # 1. Check curated canonical dictionary first
    if norm_name in KNOWN_CHARACTER_ROLES:
        curated_role, curated_bio = KNOWN_CHARACTER_ROLES[norm_name]
        best_Quotes = pick_best_bio_sentences(char_name, passages, max_sentences=1)
        full_bio = curated_bio
        if best_Quotes:
            full_bio += f" In {primary_source}, the text records: \"{best_Quotes}\""
        elif event_summaries:
            full_bio += f" Key narrative moment: {event_summaries[0]}"
        if mention_count > 0:
            full_bio += f" Recorded across {mention_count} textual mentions in {all_sources_str}."
        return curated_role, full_bio

    # 2. Otherwise, infer archetype from surrounding passages + event summaries
    combined_context = " ".join(passages[:15]) + " " + " ".join(event_summaries[:5])
    norm_context = strip_diacritics(combined_context)

    # Look for explicit "King X", "Sage X", "X, the son of Y"
    kinship_match = re.search(
        rf"\b{re.escape(norm_name)}\b\s*,?\s*(?:the\s+|a\s+)?((?:eldest\s+|youngest\s+|beloved\s+|mighty\s+|royal\s+|great\s+)?(?:son|daughter|wife|consort|husband|brother|sister|father|mother|disciple|pupil|minister|charioteer|king|prince|princess|queen|sage|rishi)\s+of\s+[a-z]+)",
        norm_context,
    )

    detected_archetype = None
    for pattern, archetype_label in CONTEXT_ARCHETYPE_PATTERNS:
        if re.search(pattern, norm_context):
            detected_archetype = archetype_label
            break

    if not detected_archetype:
        detected_archetype = "Mythological Figure"

    if kinship_match:
        rel_phrase = kinship_match.group(1).title()
        concise_role = f"{detected_archetype} ({rel_phrase}) in {primary_source}"
    else:
        concise_role = f"{detected_archetype} in {primary_source}"

    # Build rich background paragraph
    extracted_sentences = pick_best_bio_sentences(char_name, passages, max_sentences=2)
    bio_parts = []

    if extracted_sentences:
        bio_parts.append(
            f"{char_name} is a {detected_archetype.lower()} featured in {all_sources_str}. "
            f"According to the source text: \"{extracted_sentences}\""
        )
    elif event_summaries:
        bio_parts.append(
            f"{char_name} is a {detected_archetype.lower()} in {all_sources_str}. "
            f"Key turning point: {event_summaries[0]}"
        )
    else:
        bio_parts.append(
            f"{char_name} is a canonical {detected_archetype.lower()} recorded in {all_sources_str}."
        )

    if mention_count > 0:
        bio_parts.append(
            f"Appears in {mention_count} recorded passage{'s' if mention_count != 1 else ''} across the archive."
        )

    return concise_role, " ".join(bio_parts)


# ==============================================================================
# 4. MAIN PIPELINE EXECUTION
# ==============================================================================

def run_enrichment(force_update: bool = False):
    conn = get_connection()
    cur = conn.cursor()

    try:
        print("🚀 Starting Mythverse Automated Description & Relationship Enrichment...")

        # ----------------------------------------------------------------------
        # STEP A: Load all characters, existing profiles, aliases, and sources
        # ----------------------------------------------------------------------
        cur.execute("""
            SELECT
                c.id,
                c.name,
                c.description,
                cp.role,
                cp.background,
                cp.source_url,
                (cp.character_id IS NOT NULL) AS has_profile
            FROM characters c
            LEFT JOIN character_profiles cp ON cp.character_id = c.id
            ORDER BY c.id;
        """)
        char_rows = cur.fetchall()

        characters = {}
        alias_to_id = {}
        for row in char_rows:
            cid, name, desc, role, bg, src_url, has_prof = row
            characters[cid] = {
                "id": cid,
                "name": name,
                "description": desc,
                "role": role,
                "background": bg,
                "source_url": src_url,
                "has_profile": has_prof,
            }
            alias_to_id[strip_diacritics(name)] = cid

        cur.execute("SELECT character_id, alias FROM character_aliases;")
        for cid, alias in cur.fetchall():
            if cid in characters and alias:
                alias_to_id[strip_diacritics(alias)] = cid

        print(f"📚 Loaded {len(characters)} characters and {len(alias_to_id)} name/alias keys.")

        # ----------------------------------------------------------------------
        # STEP B: Fetch mention counts, sample passages & source titles per char
        # ----------------------------------------------------------------------
        print("🔍 Gathering contextual passages from chapter_paragraphs & character_mentions...")
        cur.execute("""
            SELECT
                cm.character_id,
                COUNT(cm.id) AS mention_count,
                ARRAY_AGG(DISTINCT s.title) AS source_titles,
                MAX(COALESCE(ch.source_url, s.url)) AS best_url
            FROM character_mentions cm
            JOIN chapters ch ON ch.id = cm.chapter_id
            JOIN books b ON b.id = ch.book_id
            JOIN sources s ON s.id = b.source_id
            GROUP BY cm.character_id;
        """)
        char_stats = {}
        for cid, mcount, stitles, burl in cur.fetchall():
            char_stats[cid] = {
                "mention_count": mcount or 0,
                "source_titles": [t for t in (stitles or []) if t],
                "best_url": burl,
            }

        # Fetch up to 20 sample passages per character for biography/role synthesis
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
            WHERE cp.content IS NOT NULL
            ORDER BY cm.id ASC;
        """)
        char_passages = defaultdict(list)
        para_to_chars = defaultdict(set)
        para_to_text = {}

        for cid, content, ch_id, p_num in cur.fetchall():
            if len(char_passages[cid]) < 20:
                char_passages[cid].append(content)
            para_key = (ch_id, p_num)
            para_to_chars[para_key].add(cid)
            if para_key not in para_to_text:
                para_to_text[para_key] = content

        # Fetch event summaries per character
        cur.execute("""
            SELECT character_id, event_summary
            FROM character_events
            WHERE event_summary IS NOT NULL
            ORDER BY id ASC;
        """)
        char_events = defaultdict(list)
        for cid, ev_sum in cur.fetchall():
            if len(char_events[cid]) < 8:
                char_events[cid].append(ev_sum)

        # ----------------------------------------------------------------------
        # STEP C: Populate Automated Descriptions, Roles & Backgrounds
        # ----------------------------------------------------------------------
        updated_descriptions = 0
        for cid, cinfo in characters.items():
            needs_desc = force_update or is_placeholder_text(cinfo["description"])
            needs_role = force_update or is_placeholder_text(cinfo["role"])
            needs_bg = force_update or is_placeholder_text(cinfo["background"])

            if not (needs_desc or needs_role or needs_bg):
                continue

            stats = char_stats.get(cid, {"mention_count": 0, "source_titles": [], "best_url": None})
            inferred_role, inferred_bio = infer_character_role_and_bio(
                char_name=cinfo["name"],
                passages=char_passages.get(cid, []),
                event_summaries=char_events.get(cid, []),
                source_titles=stats["source_titles"],
                mention_count=stats["mention_count"],
            )

            final_desc = inferred_role if needs_desc else cinfo["description"]
            final_role = inferred_role if needs_role else cinfo["role"]
            final_bg = inferred_bio if needs_bg else cinfo["background"]
            final_url = cinfo["source_url"] or stats["best_url"]

            # Update characters.description
            cur.execute(
                "UPDATE characters SET description = %s WHERE id = %s;",
                (final_desc, cid),
            )

            # Update or Insert character_profiles
            if cinfo["has_profile"]:
                cur.execute(
                    """
                    UPDATE character_profiles
                    SET role = %s,
                        background = %s,
                        source_url = COALESCE(source_url, %s)
                    WHERE character_id = %s;
                    """,
                    (final_role, final_bg, final_url, cid),
                )
            else:
                cur.execute(
                    """
                    INSERT INTO character_profiles (character_id, role, background, source_url)
                    VALUES (%s, %s, %s, %s);
                    """,
                    (cid, final_role, final_bg, final_url),
                )

            updated_descriptions += 1

        conn.commit()
        print(f"✨ Enriched descriptions, roles, and backgrounds for {updated_descriptions} characters.")

        # ----------------------------------------------------------------------
        # STEP D: Populate Automated Character Relationships (3-Layer Engine)
        # ----------------------------------------------------------------------
        cur.execute("SELECT character_id, related_character_id FROM character_relationships;")
        existing_pairs = {(r[0], r[1]) for r in cur.fetchall()}

        def add_relation(id_a: int, id_b: int, rel_ab: str, rel_ba: str | None = None) -> int:
            if not id_a or not id_b or id_a == id_b:
                return 0
            added = 0
            if (id_a, id_b) not in existing_pairs:
                cur.execute(
                    """
                    INSERT INTO character_relationships (character_id, related_character_id, relationship_type)
                    VALUES (%s, %s, %s);
                    """,
                    (id_a, id_b, rel_ab),
                )
                existing_pairs.add((id_a, id_b))
                added += 1
            if rel_ba and (id_b, id_a) not in existing_pairs:
                cur.execute(
                    """
                    INSERT INTO character_relationships (character_id, related_character_id, relationship_type)
                    VALUES (%s, %s, %s);
                    """,
                    (id_b, id_a, rel_ba),
                )
                existing_pairs.add((id_b, id_a))
                added += 1
            return added

        # Layer 1: Canonical Relationships
        canon_added = 0
        for name_a, name_b, rel_ab, rel_ba in CANONICAL_RELATIONS:
            id_a = alias_to_id.get(strip_diacritics(name_a))
            id_b = alias_to_id.get(strip_diacritics(name_b))
            if id_a and id_b:
                canon_added += add_relation(id_a, id_b, rel_ab, rel_ba)
        conn.commit()
        print(f"⚡ Layer 1 (Canonical Knowledge Base): Added {canon_added} relationship edges.")

        # Layer 2: Paragraph NLP Pattern Mining
        nlp_added = 0
        co_occurrence_weights = Counter()

        for para_key, cid_set in para_to_chars.items():
            if len(cid_set) < 2:
                continue
            cid_list = sorted(cid_set)
            norm_para = strip_diacritics(para_to_text.get(para_key, ""))

            for i in range(len(cid_list)):
                for j in range(i + 1, len(cid_list)):
                    ca, cb = cid_list[i], cid_list[j]
                    co_occurrence_weights[(ca, cb)] += 1

                    if (ca, cb) in existing_pairs and (cb, ca) in existing_pairs:
                        continue

                    name_a = strip_diacritics(characters[ca]["name"])
                    name_b = strip_diacritics(characters[cb]["name"])
                    if not name_a or not name_b:
                        continue

                    for pat, rel_ab, rel_ba in RELATION_PATTERNS:
                        # Forward: Name A ... [son of] ... Name B
                        rx_ab = rf"\b{re.escape(name_a)}\b[^.?!]{{0,55}}{pat}[^.?!]{{0,35}}\b{re.escape(name_b)}\b"
                        if re.search(rx_ab, norm_para):
                            nlp_added += add_relation(ca, cb, rel_ab, rel_ba)
                            break

                        # Reverse: Name B ... [son of] ... Name A
                        rx_ba = rf"\b{re.escape(name_b)}\b[^.?!]{{0,55}}{pat}[^.?!]{{0,35}}\b{re.escape(name_a)}\b"
                        if re.search(rx_ba, norm_para):
                            nlp_added += add_relation(cb, ca, rel_ab, rel_ba)
                            break

        conn.commit()
        print(f"🧠 Layer 2 (Paragraph NLP Syntax Mining): Added {nlp_added} semantic relationship edges.")

        # Also include event-level co-occurrences (same logic as main.py /graph)
        cur.execute("""
            SELECT
                ce1.character_id,
                ce2.character_id,
                COUNT(*) AS weight
            FROM character_events ce1
            JOIN character_events ce2
              ON ce1.chapter_id = ce2.chapter_id
             AND ce1.paragraph_start <= ce2.paragraph_end
             AND ce1.paragraph_end >= ce2.paragraph_start
             AND ce1.character_id < ce2.character_id
            GROUP BY ce1.character_id, ce2.character_id;
        """)
        for ca, cb, w in cur.fetchall():
            co_occurrence_weights[(ca, cb)] += int(w)

        # Layer 3: Co-Occurrence Fallback so every character has clickable relations
        char_rel_counts = Counter(a for a, _ in existing_pairs)
        neighbors_by_char = defaultdict(list)
        for (ca, cb), weight in co_occurrence_weights.items():
            neighbors_by_char[ca].append((weight, cb))
            neighbors_by_char[cb].append((weight, ca))

        fallback_added = 0
        for cid in characters:
            if char_rel_counts[cid] >= 3:
                continue
            top_neighbors = sorted(neighbors_by_char.get(cid, []), key=lambda x: x[0], reverse=True)
            for weight, other_id in top_neighbors[:5]:
                label = (
                    f"Narrative Counterpart ({weight} shared passages)"
                    if weight > 1
                    else "Shared Chapter Appearance"
                )
                added = add_relation(cid, other_id, label, label)
                if added:
                    fallback_added += added
                    char_rel_counts[cid] += 1
                    if char_rel_counts[cid] >= 4:
                        break

        conn.commit()
        print(f"🕸️  Layer 3 (Co-Occurrence Fallback): Added {fallback_added} relationship links.")

        # Final Summary
        cur.execute("SELECT COUNT(*) FROM character_relationships;")
        total_rels = cur.fetchone()[0]
        print(f"\n✅ COMPLETE! Database now holds {total_rels} total character relationship edges.")

    finally:
        cur.close()
        conn.close()


if __name__ == "__main__":
    force = "--force" in sys.argv
    run_enrichment(force_update=force)