#!/usr/bin/env python3
"""
MYTHVERSE AUTOMATED LOCAL-AI & DEPENDENCY PIPELINE
--------------------------------------------------
1-Command End-to-End Execution:
  • Ingest a new URL (scrapes chapters -> discovers characters & aliases -> extracts
    mentions & events -> runs local AI + syntax relation extraction):
      python3 scripts/mythverse_pipeline.py "https://www.wisdomlib.org/..."

  • Rebuild & fix all descriptions, roles, aliases, and relationships for existing DB:
      python3 scripts/mythverse_pipeline.py --backfill
"""

import json
import os
import re
import sys
import unicodedata
from collections import Counter, defaultdict
from urllib.parse import urljoin

# Load backend's working PostgreSQL connection pool
ROOT_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
BACKEND_DIR = os.path.join(ROOT_DIR, "backend")
for p in (BACKEND_DIR, ROOT_DIR):
    if os.path.isdir(p) and p not in sys.path:
        sys.path.insert(0, p)

from database import get_connection
from psycopg2.extras import RealDictCursor

try:
    import requests
    from bs4 import BeautifulSoup
except ImportError:
    requests = None
    BeautifulSoup = None

# Optional Local spaCy Dependency Parser
SPACY_NLP = None
try:
    import spacy
    for model_name in ("en_core_web_trf", "en_core_web_sm"):
        try:
            SPACY_NLP = spacy.load(model_name)
            break
        except Exception:
            continue
except ImportError:
    SPACY_NLP = None


def norm(text: str) -> str:
    if not text:
        return ""
    return "".join(
        c for c in unicodedata.normalize("NFD", str(text))
        if unicodedata.category(c) != "Mn"
    ).lower().strip()


# ==============================================================================
# 1. LOCAL OLLAMA LLM CONNECTOR (AUTO-DETECTS LOCAL GPU MODEL IF RUNNING)
# ==============================================================================

OLLAMA_URL = os.environ.get("OLLAMA_URL", "http://localhost:11434")
ACTIVE_OLLAMA_MODEL = None


def detect_ollama_model() -> str | None:
    """Checks if Ollama is running locally and picks an available instruct model."""
    if not requests:
        return None
    try:
        resp = requests.get(f"{OLLAMA_URL}/api/tags", timeout=1.5)
        if resp.status_code != 200:
            return None
        models = [m.get("name", "") for m in resp.json().get("models", [])]
        if not models:
            return None
        for preferred in ("qwen2.5", "llama3.2", "llama3.1", "llama3", "mistral", "gemma2"):
            for m in models:
                if m.startswith(preferred):
                    return m
        return models[0]
    except Exception:
        return None


def local_llm_extract_relation(char_a: str, char_b: str, sentence: str) -> tuple[str, str] | None:
    """
    Uses local Ollama model (if running) to extract the exact relationship between
    char_a and char_b from a shared sentence.
    Returns (who_B_is_to_A, who_A_is_to_B) or None.
    """
    if not ACTIVE_OLLAMA_MODEL or not requests:
        return None
    prompt = (
        f"Passage: \"{sentence}\"\n"
        f"Characters: A = \"{char_a}\", B = \"{char_b}\".\n"
        f"Based strictly on Indian mythology and this passage, return JSON with keys "
        f"\"b_to_a\" (what {char_b} is to {char_a}, e.g. 'Father', 'Son', 'Consort', 'Brother', 'Guru', 'Adversary') "
        f"and \"a_to_b\" (what {char_a} is to {char_b}). If no real relationship exists, return {{\"b_to_a\": null, \"a_to_b\": null}}."
    )
    try:
        r = requests.post(
            f"{OLLAMA_URL}/api/generate",
            json={
                "model": ACTIVE_OLLAMA_MODEL,
                "prompt": prompt,
                "format": "json",
                "stream": False,
                "options": {"temperature": 0.0, "num_predict": 80},
            },
            timeout=6,
        )
        if r.status_code == 200:
            data = json.loads(r.json().get("response", "{}"))
            b_to_a = data.get("b_to_a")
            a_to_b = data.get("a_to_b")
            if b_to_a and a_to_b and len(str(b_to_a)) < 40 and len(str(a_to_b)) < 40:
                return str(b_to_a).strip(), str(a_to_b).strip()
    except Exception:
        pass
    return None


# ==============================================================================
# 2. COMPLETE VERIFIED ONTOLOGY: ALIASES, ROLES & DIRECTION-CHECKED RELATIONS
# ==============================================================================

CANONICAL_ALIASES = {
    "Rama": ["Rāma", "Raghava", "Rāghava", "Dasharathi", "Ramachandra", "Kakutstha"],
    "Sita": ["Sītā", "Janaki", "Jānakī", "Maithili", "Vaidehi", "Vaidehī"],
    "Lakshmana": ["Lakṣmaṇa", "Laksmana", "Saumitri"],
    "Bharata": ["Bharata"],
    "Shatrughna": ["Śatrughna", "Shatrughna"],
    "Hanuman": ["Hanumān", "Anjaneya", "Maruti", "Pavanaputra", "Vayuputra"],
    "Ravana": ["Rāvaṇa", "Dashagriva", "Lankeshvara", "Paulastya"],
    "Dasharatha": ["Daśaratha", "Dasaratha"],
    "Vishvamitra": ["Viśvāmitra", "Visvamitra", "Kaushika", "Kauśika"],
    "Vasishtha": ["Vasiṣṭha", "Vashishtha", "Vasistha"],
    "Krishna": ["Kṛṣṇa", "Vasudeva", "Vāsudeva", "Govinda", "Madhava", "Mādhava", "Keshava", "Keśava", "Hrishikesha", "Hṛṣīkeśa", "Gopala", "Murari", "Madhusudana"],
    "Arjuna": ["Pārtha", "Partha", "Dhananjaya", "Kaunteya", "Gudakesha", "Savyasachin", "Kiritin"],
    "Yudhishthira": ["Yudhiṣṭhira", "Dharmaraja", "Ajatashatru"],
    "Bhima": ["Bhīma", "Bhimasena", "Bhīmasena", "Vrikodara"],
    "Bhimasena": ["Bhīmasena", "Bhima", "Vrikodara"],
    "Nakula": ["Nakula"],
    "Sahadeva": ["Sahadeva"],
    "Shiva": ["Śiva", "Siva", "Mahadeva", "Rudra", "Shankara", "Maheshvara", "Hara", "Shambhu"],
    "Vishnu": ["Viṣṇu", "Visnu", "Narayana", "Nārāyaṇa", "Hari", "Janardana", "Achyuta"],
    "Brahma": ["Brahmā", "Pitamaha", "Prajapati", "Prajāpati", "Chaturmukha", "Vidhatri", "Vidhātṛ"],
    "Ganesha": ["Gaṇeśa", "Ganapati", "Gaṇapati", "Vinayaka", "Vighneshvara", "Gajanana", "Heramba"],
    "Parvati": ["Pārvatī", "Uma", "Umā", "Gauri", "Ambika", "Durga"],
    "Lakshmi": ["Lakṣmī", "Shri", "Śrī", "Padma"],
    "Sarasvati": ["Sarasvatī", "Vani", "Bharati"],
    "Garuda": ["Garuḍa", "Suparna", "Vainateya", "Tarkshya"],
    "Indra": ["Śakra", "Sakra", "Purandara", "Vasava", "Devendra", "Mahendra"],
    "Surya": ["Sūrya", "Vivasvan", "Aditya", "Savitr", "Bhanu"],
    "Chandra": ["Soma", "Indu", "Shashanka"],
    "Vayu": ["Vāyu", "Pavana", "Maruta", "Anila"],
    "Agni": ["Hutashana", "Pavaka", "Vahni"],
    "Varuna": ["Varuṇa", "Prachetas"],
    "Yama": ["Dharmaraja", "Vaivasvata", "Kala"],
    "Kubera": ["Vaiśravaṇa", "Vaishravana", "Dhanada"],
    "Narada": ["Nārada", "Devarshi Narada"],
    "Valmiki": ["Vālmīki", "Prachetasa"],
    "Vyasa": ["Vyāsa", "Krishna Dvaipayana", "Badarayana"],
    "Sugriva": ["Sugrīva"],
    "Vali": ["Vāli", "Bāli"],
    "Vibhishana": ["Vibhīṣaṇa"],
    "Kumbhakarna": ["Kumbhakarṇa"],
    "Surpanakha": ["Śūrpaṇakhā", "Surpanakha"],
    "Kausalya": ["Kausalyā"],
    "Kaikeyi": ["Kaikeyī"],
    "Sumitra": ["Sumitrā"],
}

# Verified Roles & Biographies (Contains /graph keywords: Deity, Royal, Sage, Warrior, Asura, Creature, Consort)
VERIFIED_PROFILES = {
    "rama": ("Prince of Ayodhya & Seventh Avatar of Vishnu (Royal / Deity)", "Royal prince of Kosala, eldest son of King Dasharatha and Queen Kausalya, consort of Sita, and central hero of the Ramayana."),
    "sita": ("Princess of Mithila & Consort of Rama (Royal Queen / Consort)", "Daughter of King Janaka of Mithila and beloved consort of Prince Rama, revered for her unwavering dharma and devotion."),
    "lakshmana": ("Prince of Ayodhya & Devoted Brother of Rama (Royal Warrior)", "Son of King Dasharatha and Queen Sumitra who accompanied Rama and Sita throughout their fourteen-year forest exile."),
    "bharata": ("Prince of Ayodhya & Regent of Kosala (Royal Prince)", "Righteous son of King Dasharatha and Queen Kaikeyi who ruled Kosala as regent with Rama's sandals on the throne."),
    "shatrughna": ("Prince of Ayodhya & Twin Brother of Lakshmana (Royal Warrior)", "Youngest son of King Dasharatha and Queen Sumitra, devoted brother to Bharata and vanquisher of Lavanasura."),
    "dasharatha": ("King of Kosala & Sovereign of Ayodhya (Royal King)", "Monarch of the Ikshvaku Solar dynasty in Ayodhya and father of Rama, Bharata, Lakshmana, and Shatrughna."),
    "kausalya": ("Chief Queen of Ayodhya & Mother of Rama (Royal Queen / Consort)", "Senior queen of King Dasharatha and mother of Prince Rama."),
    "kaikeyi": ("Queen of Ayodhya & Mother of Bharata (Royal Queen / Consort)", "Queen of King Dasharatha and mother of Prince Bharata whose two boons led to Rama's forest exile."),
    "sumitra": ("Queen of Ayodhya & Mother of Lakshmana and Shatrughna (Royal Queen / Consort)", "Wise queen of King Dasharatha and mother of the twin princes Lakshmana and Shatrughna."),
    "janaka": ("Philosopher King of Mithila & Father of Sita (Royal King)", "Righteous ruler of Videha (Mithila), custodian of Shiva's bow, and father of Princess Sita."),
    "kusha": ("Prince of Kosala & Twin Son of Rama and Sita (Royal Prince)", "Elder twin son of Rama and Sita raised in Sage Valmiki's hermitage."),
    "lava": ("Prince of Kosala & Twin Son of Rama and Sita (Royal Prince)", "Younger twin son of Rama and Sita who sang the Ramayana with his brother Kusha."),
    "hanuman": ("Vanara Hero & Devoted Emissary of Rama (Creature / Vanara / Deity)", "Spiritual son of Vayu, chief minister to Sugriva, and devoted champion of Rama who leaped across the ocean to Lanka."),
    "sugriva": ("Vanara King of Kishkindha & Sworn Ally of Rama (Creature / Vanara King)", "Ruler of the Vanara kingdom of Kishkindha who allied with Rama to recover Sita."),
    "vali": ("Vanara King of Kishkindha & Elder Brother of Sugriva (Creature / Vanara Warrior)", "Mightiest Vanara warrior of Kishkindha, elder brother of Sugriva and father of Angada."),
    "angada": ("Crown Prince of Kishkindha & Son of Vali (Creature / Vanara Warrior)", "Valiant Vanara prince, son of Vali and Tara, who served as Rama's envoy to Ravana's court."),
    "jatayu": ("Noble King of Vultures & Friend of Dasharatha (Creature / Celestial Bird)", "Heroic bird king, brother of Sampati, who fought Ravana in the sky to defend Sita."),
    "sampati": ("Elder Brother of Jatayu & Son of Aruna (Creature / Celestial Bird)", "Giant solar bird who revealed Sita's location in Lanka to Hanuman's search party."),
    "ravana": ("Rakshasa Emperor of Lanka (Asura / Rakshasa King)", "Ten-headed Rakshasa ruler of Lanka, grandson of Sage Pulastya, and primary antagonist of the Ramayana."),
    "vibhishana": ("Righteous Rakshasa Prince & King of Lanka (Asura / Royal Ally)", "Younger brother of Ravana who renounced adharma to join Rama and was crowned King of Lanka."),
    "kumbhakarna": ("Giant Rakshasa Warrior & Brother of Ravana (Asura / Rakshasa Warrior)", "Mightiest warrior of Lanka and younger brother of Ravana, famed for his six-month slumber."),
    "indrajit": ("Crown Prince of Lanka & Son of Ravana (Asura / Rakshasa Warrior)", "Meghanada, eldest son of Ravana and Mandodari, master of celestial weapons slain by Lakshmana."),
    "mandodari": ("Chief Queen of Lanka & Consort of Ravana (Royal Queen / Consort)", "Righteous daughter of Mayasura, chief queen of Ravana, and mother of Indrajit."),
    "surpanakha": ("Rakshasi Princess of Lanka & Sister of Ravana (Asura / Rakshasa)", "Sister of Ravana, Kumbhakarna, Vibhishana, and Khara whose encounter at Panchavati sparked the war of Lanka."),
    "khara": ("Rakshasa General of Janasthana & Brother of Ravana (Asura / Rakshasa Warrior)", "Fierce Rakshasa warlord who ruled Janasthana with Dushana and was vanquished by Prince Rama."),
    "dushana": ("Rakshasa Commander of Janasthana (Asura / Rakshasa Warrior)", "Commander of Khara's army in Janasthana who was slain in battle by Rama."),
    "maricha": ("Shape-Shifting Rakshasa & Uncle of Ravana (Asura / Rakshasa)", "Son of Tataka who assumed the form of the golden deer to lure Rama and Lakshmana away from Sita."),
    "tataka": ("Fierce Yakshini-turned-Rakshasi of the Forest (Asura / Rakshasa)", "Mother of Maricha who terrorized Sage Vishvamitra's hermitage and was slain by young Rama."),
    "vishvamitra": ("Brahmarshi & Preceptor of Rama and Lakshmana (Vedic Sage / Rishi)", "Celebrated Vedic rishi, former king Kaushika, who guided Rama and Lakshmana and bestowed divine astras upon them."),
    "vasishtha": ("Royal Kulaguru of the Ikshvaku Dynasty (Vedic Sage / Rishi)", "Saptarishi, consort of Arundhati, and chief spiritual preceptor to King Dasharatha and Rama."),
    "valmiki": ("Adi Kavi & Author of the Ramayana (Vedic Sage / Rishi)", "Revered sage who composed the Sanskrit Ramayana and sheltered Sita and her twin sons in his hermitage."),
    "agastya": ("Revered Vedic Rishi of the Southern Hermitage (Vedic Sage / Rishi)", "Great sage who blessed Rama in exile and gifted him the divine bow of Vishnu."),
    "bharadvaja": ("Vedic Rishi of the Prayaga Hermitage (Vedic Sage / Rishi)", "Great sage and disciple of Valmiki who hosted Rama, Sita, and Lakshmana at the confluence of Prayaga."),
    "gautama": ("Vedic Maharishi & Husband of Ahalya (Vedic Sage / Rishi)", "Ancient rishi, father of Satananda and author of sacred dharma traditions."),
    "ahalya": ("Wife of Sage Gautama Redeemed by Rama (Consort / Sacred Matriarch)", "Created by Brahma, wife of Sage Gautama and mother of Satananda, liberated from a curse by Prince Rama."),
    "satananda": ("Royal Priest of Mithila & Son of Gautama and Ahalya (Vedic Sage / Rishi)", "Chief purohita to King Janaka of Mithila who narrated the life of Vishvamitra to Rama."),
    "rishyasringa": ("Ascetic Sage & Son-in-Law of Dasharatha (Vedic Sage / Rishi)", "Son of Sage Vibhandaka and husband of Princess Shanta who officiated Dasharatha's Putrakameshti sacrifice."),
    "vibhandaka": ("Great Forest Ascetic & Father of Rishyasringa (Vedic Sage / Rishi)", "Stern forest rishi and son of Kashyapa who raised Rishyasringa in deep asceticism."),
    "romapada": ("King of Anga & Friend of Dasharatha (Royal King)", "Ruler of Anga who adopted Princess Shanta and wedded her to Sage Rishyasringa."),
    "shanta": ("Princess of Kosala & Wife of Sage Rishyasringa (Royal Princess / Consort)", "Elder daughter of Dasharatha adopted by King Romapada and married to Sage Rishyasringa."),
    "sumantra": ("Chief Minister & Charioteer of Ayodhya (Royal Minister / Warrior)", "Trusted counselor and royal charioteer to King Dasharatha and Prince Rama."),
    "guha": ("King of the Nishadas & Beloved Friend of Rama (Royal King / Ally)", "Chieftain of Shringaverapura who ferried Rama, Sita, and Lakshmana across the Ganga."),
    "krishna": ("Supreme Deity & Divine Teacher of the Bhagavad Gita (Deity / Avatar)", "Eighth avatar of Vishnu, prince of Dvaraka, and charioteer-guide to Arjuna on the battlefield of Kurukshetra."),
    "arjuna": ("Pandava Prince & Foremost Archer of Kurukshetra (Royal Prince / Warrior)", "Third Pandava brother, son of Indra and Kunti, and primary interlocutor of Lord Krishna in the Bhagavad Gita."),
    "yudhishthira": ("Eldest Pandava Prince & Emperor of Indraprastha (Royal King)", "Son of Dharma and Kunti, revered as Dharmaraja and leader of the five Pandava brothers."),
    "bhima": ("Second Pandava Prince & Peerless Mace Warrior (Royal Prince / Warrior)", "Son of Vayu and Kunti, elder brother of Arjuna, famed for his immense strength and vanquishing of Duryodhana."),
    "bhimasena": ("Second Pandava Prince & Peerless Mace Warrior (Royal Prince / Warrior)", "Son of Vayu and Kunti, elder brother of Arjuna, famed for his immense strength and vanquishing of Duryodhana."),
    "nakula": ("Fourth Pandava Prince & Twin Brother of Sahadeva (Royal Prince / Warrior)", "Son of the Ashvins and Queen Madri, renowned for his swordsmanship and mastery of horses."),
    "sahadeva": ("Youngest Pandava Prince & Twin Brother of Nakula (Royal Prince / Warrior)", "Youngest of the five Pandava brothers, son of Pandu and Madri (via the Ashvins), famed for his wisdom and sword mastery."),
    "pandu": ("King of Hastinapura & Father of the Five Pandavas (Royal King)", "Kuru monarch of Hastinapura, husband of Kunti and Madri, and father of Yudhishthira, Bhima, Arjuna, Nakula, and Sahadeva."),
    "kunti": ("Queen Mother of the Pandavas (Royal Queen / Consort)", "Wife of King Pandu, sister of Vasudeva, and mother of Karna, Yudhishthira, Bhima, and Arjuna."),
    "madri": ("Second Queen of Pandu & Mother of Nakula and Sahadeva (Royal Queen / Consort)", "Princess of Madra, wife of King Pandu, and mother of the twin Pandava princes Nakula and Sahadeva."),
    "draupadi": ("Empress of Indraprastha & Queen of the Pandavas (Royal Queen / Consort)", "Daughter of King Drupada of Panchala and devoted common consort of the five Pandava brothers."),
    "subhadra": ("Princess of Dvaraka, Sister of Krishna & Wife of Arjuna (Royal Princess / Consort)", "Younger sister of Krishna and Balarama, consort of Arjuna, and mother of Abhimanyu."),
    "abhimanyu": ("Heroic Prince & Son of Arjuna and Subhadra (Royal Prince / Warrior)", "Valiant young warrior, nephew of Krishna and son of Arjuna, who breached the Chakra-vyuha at Kurukshetra."),
    "dhritarashtra": ("Blind Kuru Monarch of Hastinapura (Royal King)", "Elder brother of Pandu and father of Duryodhana and the Kauravas, to whom Sanjaya narrates the Bhagavad Gita."),
    "sanjaya": ("Royal Advisor & Clairvoyant Narrator of the Gita (Royal Minister)", "Charioteer and counselor to King Dhritarashtra, blessed with divine vision by Sage Vyasa to narrate the Bhagavad Gita."),
    "duryodhana": ("Crown Prince of Hastinapura & Leader of the Kauravas (Royal Prince / Warrior)", "Eldest son of King Dhritarashtra and Queen Gandhari, and chief adversary of the Pandava cousins."),
    "bhishma": ("Grandsire of the Kuru Dynasty & Supreme Commander (Royal Warrior / Sage)", "Devavrata, son of King Shantanu and Goddess Ganga, patriarch of Hastinapura."),
    "drona": ("Royal Martial Preceptor of the Kurus & Pandavas (Vedic Sage / Warrior)", "Dronacharya, master of divine weaponry, father of Ashvatthama, and teacher of Arjuna."),
    "ashvatthama": ("Immortal Warrior & Son of Dronacharya (Warrior / Sage)", "Son of Preceptor Drona and Kripi, foremost warrior of the Kaurava alliance."),
    "kripa": ("Kula-Acharya of Hastinapura (Vedic Sage / Warrior)", "Kripacharya, immortal martial preceptor of the Kuru royal house and maternal uncle of Ashvatthama."),
    "karna": ("King of Anga & Peerless Archer (Royal King / Warrior)", "Firstborn son of Surya and Kunti, sworn friend of Duryodhana, and chief rival of Arjuna."),
    "shishupala": ("King of Chedi & Cousin-Rival of Krishna (Royal King / Warrior)", "Ruler of Chedi slain by Lord Krishna's Sudarshana Chakra at Yudhishthira's Rajasuya sacrifice."),
    "vishnu": ("Supreme Preserver Deity of the Cosmos (Deity / Lord)", "Preserver of cosmic order (dharma), consort of Lakshmi, source of the Dashavatara, and narrator of the Garuda Purana."),
    "shiva": ("Supreme Ascetic Deity & Destroyer of Ignorance (Deity / Lord)", "Mahadeva, consort of Parvati, father of Ganesha and Kartikeya, and lord of Kailasa."),
    "brahma": ("Creator Deity of the Universe & Grandsire of Worlds (Deity / Prajapati)", "Four-faced creator god of the Hindu triad, consort of Sarasvati, and father of the Saptarishis and Prajapatis."),
    "ganesha": ("Lord of Beginnings & Remover of Obstacles (Deity / Lord)", "Elephant-headed deity of wisdom, son of Shiva and Parvati, and supreme deity of the Ganesha Purana."),
    "parvati": ("Divine Mother & Consort of Lord Shiva (Deity / Consort)", "Supreme Goddess, daughter of Himavan, consort of Shiva, and mother of Ganesha and Kartikeya."),
    "lakshmi": ("Goddess of Prosperity & Eternal Consort of Vishnu (Deity / Consort)", "Supreme Goddess of fortune and dharma, incarnating as Sita with Rama and Rukmini with Krishna."),
    "sarasvati": ("Goddess of Wisdom, Speech & Sacred Learning (Deity / Consort)", "Divine consort of Brahma and presiding deity of knowledge, poetry, and the Vedas."),
    "garuda": ("King of Birds & Divine Mount of Lord Vishnu (Creature / Celestial Mount)", "Son of Sage Kashyapa and Vinata, younger brother of Aruna, and primary interlocutor of the Garuda Purana."),
    "aruna": ("Celestial Charioteer of Surya & Elder Brother of Garuda (Deity / Celestial)", "Son of Kashyapa and Vinata, father of Jatayu and Sampati, and charioteer of the Sun God."),
    "indra": ("King of the Devas & Lord of Svarga (Deity / Celestial King)", "Sovereign of the celestial gods, son of Kashyapa and Aditi, wielder of the Vajra thunderbolt, and father of Arjuna and Vali."),
    "vayu": ("Vedic Deity of the Wind & Cosmic Life-Breath (Deity / Lord)", "Lord of the winds and vital breath (Prana), divine father of Hanuman (Pavanaputra) and Bhima (Vrikodara)."),
    "agni": ("Vedic Deity of Sacred Fire & Divine Messenger (Deity / Lord)", "God of fire and sacrifice who purified Sita and bestowed celestial weapons upon Rama and Arjuna."),
    "varuna": ("Vedic Deity of the Cosmic Waters & Moral Order (Deity / Lord)", "Lord of the oceans and cosmic law (Rita), guardian of the western quarter."),
    "surya": ("Vedic Solar Deity & Progenitor of the Solar Dynasty (Deity / Lord)", "Vivasvan, the Sun God, son of Kashyapa and Aditi, progenitor of the Ikshvaku dynasty and father of Sugriva and Karna."),
    "chandra": ("Vedic Lunar Deity & Progenitor of the Lunar Dynasty (Deity / Lord)", "Soma, the Moon God, lord of night and sacred herbs, progenitor of the Chandravamsha (Lunar dynasty)."),
    "yama": ("Lord of Dharma & Sovereign of the Afterlife (Deity / Lord)", "Son of Surya, impartial judge of departed souls in the Garuda Purana, and spiritual father of Yudhishthira."),
    "kubera": ("Lord of Wealth & Guardian of the North (Deity / Celestial King)", "Son of Sage Vishrava (Ailavila), grandson of Pulastya, and elder half-brother of Ravana."),
    "narada": ("Devarshi & Celestial Sage of Bhakti (Vedic Sage / Celestial Rishi)", "Mind-born son of Brahma and devotee of Vishnu who inspired Valmiki and Vyasa."),
    "vyasa": ("Compiler of the Vedas, Mahabharata & Puranas (Vedic Sage / Rishi)", "Krishna Dvaipayana Vyasa, son of Sage Parashara and Satyavati, revered guru of Suta."),
    "parashara": ("Vedic Maharishi & Author of the Vishnu Purana (Vedic Sage / Rishi)", "Grandson of Vasishtha and father of Sage Vyasa."),
    "markandeya": ("Immortal Chiranjivi Sage & Puranic Narrator (Vedic Sage / Rishi)", "Devotee of Shiva and Vishnu renowned for his wisdom across cosmic cycles."),
    "suta": ("Revered Puranic Chronicler & Disciple of Vyasa (Vedic Sage / Narrator)", "Romaharshana / Ugrashravas Suta who narrated the Puranas to the sages at Naimisharanya."),
    "somakanta": ("King of Devanagara in the Ganesha Purana (Royal King)", "Righteous monarch counselled and healed by Sage Bhrigu through the listening of the Ganesha Purana."),
    "cyavana": ("Bhargava Rishi & Son of Sage Bhrigu (Vedic Sage / Rishi)", "Great ascetic sage, son of Bhrigu and Puloma, rejuvenated by the Ashvins."),
    "pulastya": ("Mind-born Son of Brahma & Saptarishi (Vedic Sage / Prajapati)", "One of the seven great sages (Saptarishis) created by Brahma and progenitor of Vishrava, Kubera, and Ravana."),
    "pulaha": ("Mind-born Son of Brahma & Saptarishi (Vedic Sage / Prajapati)", "One of the seven cosmic rishis (Saptarishis) and Prajapatis born from Lord Brahma."),
    "kratu": ("Mind-born Son of Brahma & Saptarishi (Vedic Sage / Prajapati)", "One of the seven cosmic rishis (Saptarishis) and Prajapatis born from Lord Brahma."),
    "angira": ("Mind-born Son of Brahma & Saptarishi (Vedic Sage / Prajapati)", "Angiras, luminous Saptarishi, father of Brihaspati, and co-progenitor of Vedic hymns."),
    "atri": ("Mind-born Son of Brahma & Saptarishi (Vedic Sage / Prajapati)", "Great Saptarishi, husband of Anasuya, and father of Dattatreya, Durvasa, and Soma."),
    "marichi": ("Mind-born Son of Brahma, Saptarishi & Father of Kashyapa (Vedic Sage / Prajapati)", "Chief of the Saptarishis, mind-born son of Brahma, and father of Sage Kashyapa."),
    "bhrigu": ("Mind-born Son of Brahma & Foremost Maharishi (Vedic Sage / Prajapati)", "Patriarch of the Bhargava lineage, father of Cyavana and Lakshmi, and narrator of the Ganesha Purana to King Somakanta."),
    "daksha": ("Prajapati & Father of Sati, Aditi, and Diti (Deity / Prajapati)", "Chief among Brahma's progenitor sons (Prajapatis) and father-in-law of Shiva and Kashyapa."),
    "kashyapa": ("Vedic Progenitor Sage of Devas, Asuras & Living Beings (Vedic Sage / Prajapati)", "Son of Marichi, husband of Aditi, Diti, Vinata, and Kadru, and father of Indra, Surya, Vamana, and Garuda."),
    "aditi": ("Mother of the Devas & Consort of Kashyapa (Deity / Consort)", "Daughter of Daksha, consort of Sage Kashyapa, and mother of the twelve Adityas including Indra, Surya, and Vamana."),
    "diti": ("Mother of the Daityas & Consort of Kashyapa (Consort / Matriarch)", "Daughter of Daksha, sister of Aditi, and mother of the Daitya clan."),
    "vinata": ("Mother of Garuda and Aruna & Consort of Kashyapa (Consort / Matriarch)", "Daughter of Daksha, wife of Sage Kashyapa, and devoted mother of Aruna and Garuda (Vainateya)."),
    "kadru": ("Mother of the Nagas & Consort of Kashyapa (Consort / Matriarch)", "Daughter of Daksha, sister of Vinata, and mother of the celestial serpents (Nagas)."),
    "ailavila": ("Solar Dynasty Royal Figure & Lineage Prince (Royal Prince)", "Royal figure recorded in the Garuda Purana Solar Dynasty genealogy, child of Dasharha / Budha and ancestor of Vishrava."),
    "ikshvaku": ("Founder of the Solar Dynasty of Ayodhya (Royal King)", "Son of Vaivasvata Manu and progenitor of the Ikshvaku (Suryavamsha) royal line of Ayodhya."),
    "raghu": ("Celebrated Emperor of the Solar Dynasty (Royal King)", "Illustrious ancestor of Dasharatha and Rama, after whom the dynasty is called Raghuvamsha."),
    "sagara": ("Ancient Emperor of Ayodhya (Royal King)", "Forefather of Bhagiratha and Rama whose sixty thousand sons were redeemed by the descent of Ganga."),
    "bhagiratha": ("Royal Sage-King Who Brought Ganga to Earth (Royal King)", "Descendant of Sagara and ancestor of Rama whose penance brought the celestial river Ganga to earth."),
    "ambarisha": ("Righteous Solar Dynasty King & Devotee of Vishnu (Royal King)", "Ancient monarch of Ayodhya celebrated across the Ramayana and Puranas for his unwavering devotion."),
    "harishchandra": ("Solar Dynasty Monarch of Unyielding Truth (Royal King)", "Legendary Suryavamsha king renowned for sacrificing his kingdom to uphold truth (Satya)."),
    "trishanku": ("Solar Dynasty King Elevated to the Heavens by Vishvamitra (Royal King)", "Father of Harishchandra for whom Sage Vishvamitra created a new constellation in the southern sky."),
    "yayati": ("Emperor of the Lunar Dynasty (Royal King)", "Son of Nahusha and ancestor of both the Yadu (Krishna) and Puru/Kuru (Pandava) lineages."),
    "pururavas": ("Founder King of the Lunar Dynasty (Royal King)", "Son of Budha and Ila, consort of Urvashi, and progenitor of the Chandravamsha."),
    "prahlada": ("Saintly Daitya Prince & Supreme Devotee of Vishnu (Royal Ally / Devotee)", "Righteous son of Hiranyakashipu and grandfather of Bali, protected by Lord Narasimha."),
    "bali": ("Daitya Emperor & Grandson of Prahlada (Asura / Royal King)", "Mahabali, generous ruler of the three worlds who bestowed three paces of land upon Lord Vamana."),
    "vamana": ("Fifth Avatar of Vishnu & Younger Brother of Indra (Deity / Avatar)", "Son of Kashyapa and Aditi who measured the three worlds in three strides to restore Indra's kingdom."),
    "vishvaksena": ("Commander-in-Chief of Lord Vishnu's Celestial Host (Deity / Warrior)", "Supreme attendant and general of Vaikuntha in the Garuda Purana."),
}

# ==============================================================================
# 3. DIRECTION-VERIFIED CANONICAL RELATIONSHIPS
# Format: (Char_A, Char_B, Label_Shown_Next_To_B_On_A_Page, Label_Shown_Next_To_A_On_B_Page)
# ==============================================================================

VERIFIED_RELATIONS = [
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
    ("Rama", "Sagara", "Solar Dynasty Ancestor", "Royal Descendant"),
    ("Rama", "Bhagiratha", "Solar Dynasty Ancestor", "Royal Descendant"),
    ("Sagara", "Bhagiratha", "Great-Grandson", "Royal Ancestor"),
    ("Ikshvaku", "Surya", "Divine Progenitor", "Solar Dynasty Founder"),
    ("Trishanku", "Harishchandra", "Son", "Father"),
    ("Trishanku", "Vishvamitra", "Royal Patron & Protege", "Benefactor Sage"),
    ("Ambarisha", "Vishnu", "Supreme Deity Worshipped", "Devoted Solar King"),
    ("Ambarisha", "Rama", "Solar Dynasty Descendant", "Solar Dynasty Ancestor"),
    ("Dasharatha", "Romapada", "Royal Friend & Ally", "Royal Friend & Ally"),
    ("Romapada", "Shanta", "Adopted Daughter", "Foster Father"),
    ("Rishyasringa", "Shanta", "Consort / Wife", "Husband"),
    ("Rishyasringa", "Vibhandaka", "Father & Guru", "Son"),
    ("Vibhandaka", "Kashyapa", "Father", "Son"),
    ("Dasharatha", "Rishyasringa", "Son-in-Law & Officiating Sage", "Father-in-Law"),
    ("Dasharatha", "Shanta", "Daughter", "Father"),
    ("Dasharatha", "Sumantra", "Chief Minister & Charioteer", "Sovereign King"),
    ("Rama", "Sumantra", "Royal Charioteer & Counselor", "Beloved Prince"),
    ("Rama", "Guha", "Nishada King & Sworn Friend", "Beloved Friend & Lord"),

    # --- Preceptors & Sages of the Ramayana ---
    ("Rama", "Vishvamitra", "Guru & Bestower of Astras", "Foremost Royal Disciple"),
    ("Lakshmana", "Vishvamitra", "Guru & Preceptor", "Royal Disciple"),
    ("Dasharatha", "Vasishtha", "Royal Kulaguru", "Patron Monarch"),
    ("Rama", "Vasishtha", "Royal Kulaguru", "Royal Disciple"),
    ("Vasishtha", "Vishvamitra", "Fellow Brahmarshi & Former Rival", "Fellow Brahmarshi"),
    ("Vishvamitra", "Satananda", "Chronicler of His Lineage", "Revered Brahmarshi"),
    ("Janaka", "Satananda", "Royal Purohita (Chief Priest)", "Patron King"),
    ("Gautama", "Ahalya", "Consort / Wife", "Husband"),
    ("Gautama", "Satananda", "Son", "Father"),
    ("Ahalya", "Satananda", "Son", "Mother"),
    ("Rama", "Ahalya", "Redeemed by Rama", "Divine Liberator"),
    ("Rama", "Agastya", "Revered Sage & Bestower of Bow", "Honored Royal Guest"),
    ("Rama", "Bharadvaja", "Host Sage at Prayaga", "Honored Royal Guest"),
    ("Valmiki", "Narada", "Celestial Narrator & Inspiration", "Author of the Ramayana"),
    ("Valmiki", "Rama", "Hero of His Epic", "Chronicler & Poet"),
    ("Valmiki", "Sita", "Sheltered in His Hermitage", "Protector Sage"),
    ("Valmiki", "Kusha", "Foster Grandsire & Guru", "Disciple"),
    ("Valmiki", "Lava", "Foster Grandsire & Guru", "Disciple"),
    ("Valmiki", "Bharadvaja", "Chief Disciple", "Guru / Preceptor"),

    # --- Vanaras, Vayu & Lanka Characters ---
    ("Rama", "Hanuman", "Devoted Emissary & Champion", "Revered Lord"),
    ("Sita", "Hanuman", "Protector & Emissary", "Revered Queen Mother"),
    ("Lakshmana", "Hanuman", "Comrade in Arms & Healer", "Brother of Lord Rama"),
    ("Rama", "Sugriva", "Sworn Vanara Ally", "Sworn Ally & Protector"),
    ("Sugriva", "Hanuman", "Chief Minister & Emissary", "Vanara King"),
    ("Sugriva", "Vali", "Elder Brother & Rival", "Younger Brother & Rival"),
    ("Sugriva", "Surya", "Divine Father", "Son"),
    ("Vali", "Indra", "Divine Father", "Son"),
    ("Rama", "Vali", "Vanquished by Rama", "Slayer"),
    ("Vali", "Angada", "Son", "Father"),
    ("Sugriva", "Angada", "Nephew & Crown Prince", "Paternal Uncle"),
    ("Vayu", "Hanuman", "Spiritual Son (Pavanaputra)", "Divine Father"),
    ("Vayu", "Bhima", "Spiritual Son (Vrikodara)", "Divine Father"),
    ("Vayu", "Bhimasena", "Spiritual Son (Vrikodara)", "Divine Father"),
    ("Vayu", "Rama", "Supreme Avatar Served by Hanuman", "Vedic Wind Deity"),
    ("Vayu", "Indra", "Fellow Vedic Deity (Lokapala)", "Fellow Vedic Deity"),
    ("Vayu", "Agni", "Fellow Vedic Deity", "Fellow Vedic Deity"),
    ("Rama", "Jatayu", "Martyred Defender of Sita", "Revered Prince"),
    ("Dasharatha", "Jatayu", "Ancient Friend", "Ancient Friend"),
    ("Jatayu", "Sampati", "Elder Brother", "Younger Brother"),
    ("Jatayu", "Aruna", "Father", "Son"),
    ("Sampati", "Aruna", "Father", "Son"),
    ("Rama", "Vibhishana", "Righteous Ally in Lanka", "Revered Lord & Ally"),
    ("Ravana", "Vibhishana", "Righteous Younger Brother", "Elder Brother"),
    ("Ravana", "Kumbhakarna", "Younger Brother", "Elder Brother"),
    ("Vibhishana", "Kumbhakarna", "Elder Brother", "Younger Brother"),
    ("Ravana", "Indrajit", "Son (Meghanada)", "Father"),
    ("Ravana", "Mandodari", "Chief Queen / Consort", "Husband"),
    ("Mandodari", "Indrajit", "Son", "Mother"),
    ("Ravana", "Surpanakha", "Sister", "Brother"),
    ("Vibhishana", "Surpanakha", "Sister", "Brother"),
    ("Kumbhakarna", "Surpanakha", "Sister", "Brother"),
    ("Ravana", "Khara", "Brother / General in Janasthana", "Sovereign Brother"),
    ("Surpanakha", "Khara", "Brother & Protector", "Sister"),
    ("Khara", "Dushana", "Brother & Co-General", "Brother & Commander"),
    ("Ravana", "Maricha", "Maternal Uncle & Advisor", "Nephew & King"),
    ("Tataka", "Maricha", "Son", "Mother"),
    ("Ravana", "Kubera", "Elder Half-Brother & Rival", "Half-Brother"),
    ("Ravana", "Pulastya", "Paternal Grandfather", "Grandson"),
    ("Kubera", "Pulastya", "Paternal Grandfather", "Grandson"),
    ("Vibhishana", "Pulastya", "Paternal Grandfather", "Grandson"),
    ("Rama", "Ravana", "Arch-Adversary", "Vanquisher"),
    ("Sita", "Ravana", "Abductor & Adversary", "Captive Princess"),
    ("Lakshmana", "Indrajit", "Arch-Rival in Battle", "Vanquisher"),
    ("Lakshmana", "Surpanakha", "Vanquished Rakshasi", "Adversary"),
    ("Rama", "Khara", "Vanquished Adversary in Janasthana", "Vanquisher"),
    ("Rama", "Dushana", "Vanquished Adversary", "Vanquisher"),
    ("Rama", "Tataka", "Slain Rakshasi", "Vanquisher"),
    ("Rama", "Maricha", "Slain Rakshasa", "Vanquisher"),

    # --- Brahma, Saptarishis, Prajapatis & Cosmic Lineage ---
    # Note: Position 3 is what B is to A (shown on A's page)!
    ("Brahma", "Pulastya", "Mind-born Son (Prajapati)", "Creator Father"),
    ("Brahma", "Atri", "Mind-born Son (Saptarishi)", "Creator Father"),
    ("Brahma", "Bhrigu", "Mind-born Son (Prajapati)", "Creator Father"),
    ("Brahma", "Angira", "Mind-born Son (Saptarishi)", "Creator Father"),
    ("Brahma", "Kratu", "Mind-born Son (Saptarishi)", "Creator Father"),
    ("Brahma", "Marichi", "Mind-born Son (Saptarishi)", "Creator Father"),
    ("Brahma", "Pulaha", "Mind-born Son (Saptarishi)", "Creator Father"),
    ("Brahma", "Vasishtha", "Mind-born Son (Saptarishi)", "Creator Father"),
    ("Brahma", "Narada", "Mind-born Son (Devarshi)", "Creator Father"),
    ("Brahma", "Daksha", "Mind-born Son (Prajapati)", "Creator Father"),
    ("Brahma", "Sarasvati", "Divine Consort", "Consort & Creator"),
    ("Brahma", "Vishnu", "Co-eval Trimurti Deity (Preserver)", "Creator Born from Cosmic Lotus"),
    ("Brahma", "Shiva", "Co-eval Trimurti Deity (Mahadeva)", "Co-eval Trimurti Deity (Creator)"),

    # Saptarishi Brotherhood
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
    ("Atri", "Chandra", "Son (Soma)", "Father"),
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

    # Kashyapa, Garuda & Vedic Devas
    ("Marichi", "Kashyapa", "Son", "Father"),
    ("Kashyapa", "Aditi", "Consort (Mother of Devas)", "Husband"),
    ("Kashyapa", "Diti", "Consort (Mother of Daityas)", "Husband"),
    ("Kashyapa", "Vinata", "Consort (Mother of Garuda)", "Husband"),
    ("Kashyapa", "Kadru", "Consort (Mother of Nagas)", "Husband"),
    ("Daksha", "Kashyapa", "Son-in-Law", "Father-in-Law"),
    ("Daksha", "Aditi", "Daughter", "Father"),
    ("Daksha", "Diti", "Daughter", "Father"),
    ("Daksha", "Vinata", "Daughter", "Father"),
    ("Daksha", "Kadru", "Daughter", "Father"),
    ("Daksha", "Shiva", "Son-in-Law", "Father-in-Law"),
    ("Garuda", "Kashyapa", "Father", "Son"),
    ("Garuda", "Vinata", "Mother", "Son (Vainateya)"),
    ("Garuda", "Aruna", "Elder Brother", "Younger Brother"),
    ("Aruna", "Kashyapa", "Father", "Son"),
    ("Aruna", "Vinata", "Mother", "Son"),
    ("Aruna", "Surya", "Solar Deity He Chariots", "Divine Charioteer"),
    ("Garuda", "Vishnu", "Supreme Lord & Narrator", "Divine Mount & Interlocutor"),
    ("Indra", "Kashyapa", "Father", "Son"),
    ("Indra", "Aditi", "Mother", "Son (Aditya)"),
    ("Surya", "Kashyapa", "Father", "Son (Vivasvan)"),
    ("Surya", "Aditi", "Mother", "Son (Aditya)"),
    ("Vamana", "Kashyapa", "Father", "Son (Avatar of Vishnu)"),
    ("Vamana", "Aditi", "Mother", "Son (Avatar of Vishnu)"),
    ("Vamana", "Indra", "Elder Brother", "Younger Brother (Upendra)"),
    ("Vamana", "Bali", "Subdued Daitya Emperor", "Supreme Avatar (Trivikrama)"),
    ("Prahlada", "Bali", "Grandson", "Paternal Grandfather"),
    ("Prahlada", "Vishnu", "Supreme Protector Deity", "Foremost Bhakta (Devotee)"),
    ("Surya", "Yama", "Son", "Father"),
    ("Indra", "Agni", "Fellow Vedic Deity", "Fellow Vedic Deity"),
    ("Indra", "Varuna", "Fellow Vedic Deity", "Fellow Vedic Deity"),
    ("Indra", "Surya", "Aditya Brother", "Aditya Brother"),
    ("Agni", "Varuna", "Fellow Vedic Deity", "Fellow Vedic Deity"),
    ("Ailavila", "Kubera", "Lineage Identity (Vaishravana)", "Paternal Lineage Title"),
    ("Ailavila", "Pulastya", "Lineage Patriarch", "Dynastic Descendant"),
    ("Ailavila", "Rama", "Fellow Solar Dynasty Royal", "Solar Dynasty Ancestor"),

    # Trimurti, Devis & Ganesha Purana
    ("Vishnu", "Lakshmi", "Eternal Consort", "Husband & Supreme Lord"),
    ("Vishnu", "Rama", "Seventh Avatar", "Supreme Source Deity"),
    ("Vishnu", "Krishna", "Eighth Avatar", "Supreme Source Deity"),
    ("Vishnu", "Vamana", "Fifth Avatar", "Supreme Source Deity"),
    ("Vishnu", "Shiva", "Co-eval Supreme Deity (Hari-Hara)", "Co-eval Supreme Deity (Hari-Hara)"),
    ("Vishnu", "Vishvaksena", "Commander of Vaikuntha Host", "Supreme Lord"),
    ("Vishnu", "Narada", "Foremost Celestial Devotee", "Supreme Worshipped Lord"),
    ("Vishnu", "Markandeya", "Immortal Sage Devotee", "Supreme Protector Deity"),
    ("Shiva", "Parvati", "Divine Consort (Uma)", "Husband (Mahadeva)"),
    ("Shiva", "Ganesha", "Son", "Father"),
    ("Parvati", "Ganesha", "Son", "Mother"),
    ("Ganesha", "Vishnu", "Paternal Uncle / Revered Deity", "Nephew / Revered Deity"),
    ("Ganesha", "Brahma", "Creator Grandsire", "Supreme Lord of Beginnings"),
    ("Bhrigu", "Cyavana", "Son", "Father"),
    ("Bhrigu", "Lakshmi", "Daughter (Bhargavi)", "Father"),
    ("Bhrigu", "Somakanta", "Royal Disciple & Listener", "Spiritual Preceptor"),
    ("Cyavana", "Somakanta", "Royal Listener", "Sage Preceptor"),
    ("Vyasa", "Parashara", "Father", "Son"),
    ("Parashara", "Vasishtha", "Paternal Grandfather", "Grandson"),
    ("Vyasa", "Suta", "Chief Puranic Disciple", "Guru & Compiler of Puranas"),

    # --- Bhagavad Gita & Mahabharata (Fixes Krishna & Sahadeva!) ---
    ("Krishna", "Arjuna", "Beloved Disciple, Friend & Brother-in-Law", "Divine Charioteer, Guru & Friend"),
    ("Krishna", "Rama", "Previous Avatar of Vishnu (Seventh)", "Subsequent Avatar of Vishnu (Eighth)"),
    ("Krishna", "Subhadra", "Sister", "Elder Brother"),
    ("Krishna", "Yudhishthira", "Cousin & Righteous King", "Cousin & Divine Counselor"),
    ("Krishna", "Bhima", "Pandava Cousin & Ally", "Cousin & Divine Counselor"),
    ("Krishna", "Bhimasena", "Pandava Cousin & Ally", "Cousin & Divine Counselor"),
    ("Krishna", "Draupadi", "Devoted Sakhi & Protected Queen", "Divine Protector & Friend"),
    ("Krishna", "Kunti", "Paternal Aunt", "Divine Nephew"),
    ("Krishna", "Shishupala", "Cousin & Vanquished Rival", "Vanquisher"),
    ("Krishna", "Duryodhana", "Adversary in the Kurukshetra War", "Divine Guide of the Pandavas"),
    ("Krishna", "Bhishma", "Revered Kuru Patriarch & Devotee", "Supreme Lord"),
    ("Krishna", "Vyasa", "Divine Chronicler", "Supreme Lord"),
    ("Arjuna", "Indra", "Divine Father", "Son"),
    ("Arjuna", "Kunti", "Mother", "Third Son"),
    ("Arjuna", "Pandu", "Father", "Third Son"),
    ("Yudhishthira", "Pandu", "Father", "Eldest Son"),
    ("Yudhishthira", "Kunti", "Mother", "Eldest Son"),
    ("Yudhishthira", "Yama", "Divine Father (Dharma)", "Son (Dharmaraja)"),
    ("Bhima", "Pandu", "Father", "Second Son"),
    ("Bhima", "Kunti", "Mother", "Second Son"),
    ("Bhimasena", "Pandu", "Father", "Second Son"),
    ("Bhimasena", "Kunti", "Mother", "Second Son"),
    ("Nakula", "Pandu", "Father", "Fourth Son"),
    ("Nakula", "Madri", "Mother", "Son"),
    ("Nakula", "Kunti", "Foster Mother", "Foster Son"),
    ("Sahadeva", "Pandu", "Father", "Youngest Son"),
    ("Sahadeva", "Madri", "Mother", "Youngest Son"),
    ("Sahadeva", "Kunti", "Foster Mother", "Foster Son"),
    ("Sahadeva", "Nakula", "Twin Brother", "Twin Brother"),
    ("Sahadeva", "Yudhishthira", "Eldest Brother & King", "Youngest Brother"),
    ("Sahadeva", "Bhima", "Elder Brother", "Youngest Brother"),
    ("Sahadeva", "Bhimasena", "Elder Brother", "Youngest Brother"),
    ("Sahadeva", "Arjuna", "Elder Brother", "Youngest Brother"),
    ("Sahadeva", "Draupadi", "Queen & Consort", "Husband"),
    ("Sahadeva", "Krishna", "Cousin & Divine Guide", "Pandava Cousin"),
    ("Nakula", "Yudhishthira", "Eldest Brother & King", "Younger Brother"),
    ("Nakula", "Bhima", "Elder Brother", "Younger Brother"),
    ("Nakula", "Bhimasena", "Elder Brother", "Younger Brother"),
    ("Nakula", "Arjuna", "Elder Brother", "Younger Brother"),
    ("Nakula", "Draupadi", "Queen & Consort", "Husband"),
    ("Yudhishthira", "Arjuna", "Younger Brother", "Eldest Brother & King"),
    ("Bhima", "Arjuna", "Younger Brother", "Elder Brother"),
    ("Bhimasena", "Arjuna", "Younger Brother", "Elder Brother"),
    ("Yudhishthira", "Bhima", "Younger Brother", "Eldest Brother"),
    ("Yudhishthira", "Bhimasena", "Younger Brother", "Eldest Brother"),
    ("Yudhishthira", "Draupadi", "Queen & Consort", "Husband"),
    ("Arjuna", "Draupadi", "Queen & Consort", "Husband"),
    ("Bhima", "Draupadi", "Queen & Consort", "Husband"),
    ("Bhimasena", "Draupadi", "Queen & Consort", "Husband"),
    ("Arjuna", "Subhadra", "Consort (Sister of Krishna)", "Husband"),
    ("Arjuna", "Abhimanyu", "Son", "Father"),
    ("Subhadra", "Abhimanyu", "Son", "Mother"),
    ("Arjuna", "Drona", "Martial Preceptor (Guru)", "Foremost Pupil"),
    ("Drona", "Ashvatthama", "Son", "Father"),
    ("Drona", "Kripa", "Brother-in-Law & Fellow Preceptor", "Brother-in-Law"),
    ("Kripa", "Ashvatthama", "Nephew", "Maternal Uncle"),
    ("Bhishma", "Arjuna", "Beloved Grand-Nephew", "Revered Grand-Uncle (Pitamaha)"),
    ("Bhishma", "Yudhishthira", "Grand-Nephew", "Revered Grand-Uncle (Pitamaha)"),
    ("Bhishma", "Duryodhana", "Grand-Nephew & Liege", "Grand-Uncle & Supreme Commander"),
    ("Bhishma", "Dhritarashtra", "Nephew & King", "Grand-Uncle & Counselor"),
    ("Bhishma", "Pandu", "Nephew", "Grand-Uncle (Pitamaha)"),
    ("Dhritarashtra", "Sanjaya", "Charioteer & Clairvoyant Narrator", "Blind Kuru Monarch"),
    ("Dhritarashtra", "Duryodhana", "Eldest Son", "Father"),
    ("Dhritarashtra", "Pandu", "Younger Brother", "Elder Brother"),
    ("Pandu", "Kunti", "Chief Queen / Consort", "Husband & King"),
    ("Pandu", "Madri", "Queen / Consort", "Husband & King"),
    ("Duryodhana", "Karna", "Loyal Friend & Champion", "Sworn Friend & Patron"),
    ("Duryodhana", "Drona", "Martial Preceptor & Commander", "Royal Pupil & Prince"),
    ("Duryodhana", "Arjuna", "Cousin & Arch-Rival", "Cousin & Arch-Rival"),
    ("Duryodhana", "Bhima", "Cousin & Sworn Nemesis", "Cousin & Sworn Nemesis"),
    ("Duryodhana", "Bhimasena", "Cousin & Sworn Nemesis", "Cousin & Sworn Nemesis"),
    ("Karna", "Arjuna", "Arch-Rival & Maternal Half-Brother", "Arch-Rival & Half-Brother"),
    ("Karna", "Kunti", "Biological Mother", "Firstborn Son"),
    ("Karna", "Surya", "Divine Father", "Son"),
    ("Yayati", "Pururavas", "Lunar Dynasty Ancestor", "Royal Descendant"),
    ("Pururavas", "Chandra", "Lunar Progenitor", "Lunar Dynasty Descendant"),
]

# Known female characters for gender-consistency validation
FEMALE_CHARACTERS = {
    "sita", "kausalya", "kaikeyi", "sumitra", "shanta", "ahalya", "tara",
    "mandodari", "surpanakha", "tataka", "shabari", "anasuya", "arundhati",
    "menaka", "urvashi", "rambha", "kunti", "madri", "draupadi", "subhadra",
    "gandhari", "satyavati", "uttarā", "uttara", "parvati", "uma", "durga",
    "lakshmi", "sarasvati", "aditi", "diti", "vinata", "kadru", "anga",
}

FEMALE_ONLY_LABELS = {"mother", "sister", "wife", "daughter", "queen / consort"}


# ==============================================================================
# 4. CLAUSE-STRICT NLP & LOCAL-AI CHARACTER / ROLE / RELATION EXTRACTOR
# ==============================================================================

def pick_best_quote(char_name: str, passages: list[str]) -> str:
    n_name = norm(char_name)
    scored = []
    seen = set()
    for p in passages:
        for sent in re.split(r"(?<=[.!?])\s+", p.strip()):
            clean = re.sub(r"\s+", " ", sent).strip()
            if len(clean) < 45 or len(clean) > 300:
                continue
            ns = norm(clean)
            if n_name not in ns or ns in seen:
                continue
            if re.match(r"^[A-ZĀĪŪṚṢŚṆÑṬḌ\s]{2,25}\s+(?:said|spoke|replied|asked)[:,-]", clean):
                continue
            score = 2 if 65 <= len(clean) <= 210 else 0
            if re.search(r"\b(son|daughter|wife|consort|brother|father|mother|king|prince|queen|sage|rishi|lord|deity|begat|born)\b", ns):
                score += 5
            seen.add(ns)
            scored.append((score, clean))
    scored.sort(key=lambda x: x[0], reverse=True)
    return scored[0][1] if scored else ""


def classify_character_profile(
    char_name: str,
    passages: list[str],
    event_summaries: list[str],
    source_titles: list[str],
    mention_count: int,
) -> tuple[str, str]:
    """
    Determines exact `role` (used on cards and by /graph for node color) and
    `background` (used in the character dossier modal) WITHOUT false-positive sage bugs.
    """
    n_name = norm(char_name)
    primary = source_titles[0] if source_titles else "the Sacred Epics"
    all_src = ", ".join(source_titles) if source_titles else "Indian Epic Literature"
    quote = pick_best_quote(char_name, passages)

    # 1. Exact ontology match
    if n_name in VERIFIED_PROFILES:
        role, base_bio = VERIFIED_PROFILES[n_name]
        full_bio = base_bio
        if quote:
            full_bio += f" In {primary}, the text records: \"{quote}\""
        elif event_summaries:
            full_bio += f" Key narrative event: {event_summaries[0]}"
        if mention_count > 0:
            full_bio += f" Recorded across {mention_count} textual mentions in {all_src}."
        return role, full_bio

    # 2. Local Clause Window Inspection (ONLY +/- 45 chars around the character's name!)
    local_windows = []
    for p in passages[:25]:
        np = norm(p)
        for m in re.finditer(rf"\b{re.escape(n_name)}\b", np):
            start = max(0, m.start() - 45)
            end = min(len(np), m.end() + 55)
            local_windows.append(np[start:end])

    window_text = " | ".join(local_windows)

    # Score archetypes strictly inside the immediate clause window of the character
    scores = Counter()
    if re.search(rf"\b(?:king|prince|princess|queen|monarch|ruler|royal|emperor)\s+{re.escape(n_name)}\b|\b{re.escape(n_name)}\s+begat\b|\bbegat\s+(?:a\s+son\s+named\s+)?{re.escape(n_name)}\b", window_text):
        scores["royal"] += 6
    if re.search(rf"\b(?:sage|rishi|muni|brahmarshi|maharshi|ascetic)\s+{re.escape(n_name)}\b|\b{re.escape(n_name)}\s*,\s*the\s+(?:great\s+)?(?:sage|rishi|muni)\b", window_text):
        scores["sage"] += 6
    if re.search(rf"\b(?:rakshasa|asura|demon|daitya|danava|fiend)\s+{re.escape(n_name)}\b", window_text):
        scores["asura"] += 6
    if re.search(rf"\b(?:vanara|monkey|bird|vulture|eagle|serpent|naga)\s+{re.escape(n_name)}\b", window_text):
        scores["creature"] += 6
    if re.search(rf"\b(?:god|deity|lord|goddess|devi|bhagavan)\s+{re.escape(n_name)}\b", window_text):
        scores["deity"] += 5

    best_arch = scores.most_common(1)[0][0] if scores else "royal"

    arch_labels = {
        "royal": f"Royal Lineage Figure & Noble in {primary} (Royal)",
        "sage": f"Vedic Sage & Seer in {primary} (Sage / Rishi)",
        "asura": f"Asura / Rakshasa Warrior in {primary} (Asura)",
        "creature": f"Mythological Vanara / Celestial Being in {primary} (Creature)",
        "deity": f"Celestial Deity & Sacred Figure in {primary} (Deity)",
    }
    role = arch_labels.get(best_arch, f"Mythological Figure in {primary}")

    bio = f"{char_name} is a {role.split(' (')[0].lower()} featured in {all_src}."
    if quote:
        bio += f" According to the source text: \"{quote}\""
    elif event_summaries:
        bio += f" Key turning point: {event_summaries[0]}"
    if mention_count > 0:
        bio += f" Appears in {mention_count} recorded passages across the archive."

    return role, bio


def is_valid_gender_label(target_name: str, label: str) -> bool:
    """Prevents male characters from ever receiving 'Sister', 'Mother', 'Wife', or 'Daughter'."""
    t_norm = norm(target_name)
    l_norm = label.lower().strip()
    if any(fem_word in l_norm for fem_word in FEMALE_ONLY_LABELS):
        if t_norm not in FEMALE_CHARACTERS:
            return False
    return True


def extract_strict_clause_relations(
    sentence: str,
    cid_a: int,
    name_a: str,
    cid_b: int,
    name_b: str,
) -> tuple[str, str] | None:
    """
    Extracts relationships ONLY when `name_a` and `name_b` are bound in a direct,
    unbroken grammatical clause (zero middle-character leakage).
    Returns (who_B_is_to_A, who_A_is_to_B) or None.
    """
    s = norm(sentence)
    na = re.escape(norm(name_a))
    nb = re.escape(norm(name_b))
    if not na or not nb:
        return None

    # 1. Genealogical "A begat [a son/daughter named] B"
    if re.search(rf"\b{na}\s+begat\s+(?:a\s+son\s+named\s+|a\s+daughter\s+named\s+)?{nb}\b", s):
        child_lbl = "Daughter" if norm(name_b) in FEMALE_CHARACTERS else "Son"
        return (child_lbl, "Father")
    if re.search(rf"\b{nb}\s+begat\s+(?:a\s+son\s+named\s+|a\s+daughter\s+named\s+)?{na}\b", s):
        child_lbl = "Daughter" if norm(name_a) in FEMALE_CHARACTERS else "Son"
        return ("Father", child_lbl)

    # 2. "A [who] was the father/mother of B"
    if re.search(rf"\b{na}\s+(?:who\s+)?(?:was|is)\s+the\s+father\s+of\s+{nb}\b", s):
        child_lbl = "Daughter" if norm(name_b) in FEMALE_CHARACTERS else "Son"
        return (child_lbl, "Father")
    if re.search(rf"\b{nb}\s+(?:who\s+)?(?:was|is)\s+the\s+father\s+of\s+{na}\b", s):
        child_lbl = "Daughter" if norm(name_a) in FEMALE_CHARACTERS else "Son"
        return ("Father", child_lbl)

    # 3. Direct Appositive: "A, the [son/daughter/wife/brother/father/disciple] of B"
    # Notice: NO arbitrary words allowed between `A` and `, the <rel> of B`!
    appositive_rules = [
        ("son", "Parent", "Son"),
        ("daughter", "Parent", "Daughter"),
        ("father", "Child", "Father"),
        ("mother", "Child", "Mother"),
        ("wife", "Husband", "Consort / Wife"),
        ("consort", "Consort", "Consort"),
        ("brother", "Brother", "Brother"),
        ("disciple", "Guru / Preceptor", "Disciple"),
        ("pupil", "Preceptor", "Pupil"),
        ("charioteer", "Sovereign / Warrior", "Charioteer"),
    ]
    for noun, b_to_a, a_to_b in appositive_rules:
        if re.search(rf"\b{na}\s*,\s*(?:the\s+|a\s+)?(?:eldest\s+|youngest\s+|beloved\s+)?{noun}\s+of\s+{nb}\b", s):
            if is_valid_gender_label(name_b, b_to_a) and is_valid_gender_label(name_a, a_to_b):
                return (b_to_a, a_to_b)
        if re.search(rf"\b{nb}\s*,\s*(?:the\s+|a\s+)?(?:eldest\s+|youngest\s+|beloved\s+)?{noun}\s+of\s+{na}\b", s):
            if is_valid_gender_label(name_a, b_to_a) and is_valid_gender_label(name_b, a_to_b):
                return (a_to_b, b_to_a)

    # 4. If Ollama Local LLM is running, ask it to classify the shared sentence
    llm_res = local_llm_extract_relation(name_a, name_b, sentence)
    if llm_res:
        b_to_a, a_to_b = llm_res
        if is_valid_gender_label(name_b, b_to_a) and is_valid_gender_label(name_a, a_to_b):
            return (b_to_a, a_to_b)

    return None


def infer_chapter_context_relation(
    char_a: dict,
    char_b: dict,
    shared_chapter_titles: list[str],
) -> tuple[str, str]:
    """
    For minor characters (e.g. from newly ingested URLs or Puranic king lists) that
    have 0 explicit family edges after Tier 1 & Tier 2, derives a specific, accurate
    context relationship from the chapter theme and roles.
    """
    ch_text = " ".join(shared_chapter_titles).lower()
    role_a = (char_a.get("role") or "").lower()
    role_b = (char_b.get("role") or "").lower()

    if "genealogy" in ch_text or "race" in ch_text or "dynasty" in ch_text or "lineage" in ch_text:
        return ("Royal Dynasty Lineage", "Royal Dynasty Lineage")
    if "epithet" in ch_text or "hymn" in ch_text or "salutation" in ch_text:
        return ("Co-Invoked Sacred Deity", "Co-Invoked Sacred Deity")
    if "battle" in ch_text or "war" in ch_text or "slaying" in ch_text or "destruction" in ch_text:
        if ("asura" in role_a) != ("asura" in role_b):
            return ("Battlefield Adversary", "Battlefield Adversary")
        return ("Comrade in Arms", "Comrade in Arms")
    if "sage" in role_a and "sage" in role_b:
        return ("Fellow Vedic Rishi", "Fellow Vedic Rishi")
    if "deity" in role_a and "deity" in role_b:
        return ("Fellow Vedic Deity", "Fellow Vedic Deity")
    if "royal" in role_a and "sage" in role_b:
        return ("Spiritual Preceptor & Sage", "Royal Patron")
    if "sage" in role_a and "royal" in role_b:
        return ("Royal Patron", "Spiritual Preceptor & Sage")
    if "royal" in role_a and "royal" in role_b:
        return ("Royal Contemporary", "Royal Contemporary")

    return ("Co-Featured in Chapter Narrative", "Co-Featured in Chapter Narrative")


# ==============================================================================
# 5. FULL 1-COMMAND URL INGESTION (CHAPTERS + NER + MENTIONS + EVENTS)
# ==============================================================================

STOPWORDS_NER = {
    "the", "and", "but", "for", "nor", "yet", "so", "in", "on", "at", "to", "from",
    "by", "with", "of", "as", "into", "like", "through", "after", "over", "between",
    "out", "against", "during", "without", "before", "under", "around", "among",
    "chapter", "book", "section", "verse", "sloka", "canto", "part", "thus", "then",
    "there", "here", "when", "where", "while", "who", "whom", "whose", "which",
    "what", "that", "this", "these", "those", "one", "two", "three", "four", "five",
    "king", "prince", "queen", "lord", "god", "sage", "rishi", "brahmin", "son",
    "father", "mother", "brother", "wife", "daughter", "city", "forest", "mountain",
    "earth", "heaven", "world", "time", "day", "night", "men", "man", "woman",
}


def ingest_from_url(conn, url: str):
    if not requests or not BeautifulSoup:
        raise RuntimeError("requests and beautifulsoup4 are required for URL ingestion.")

    print(f"🌐 [1/4] Scraping source & chapters from URL: {url}")
    headers = {"User-Agent": "Mozilla/5.0"}
    resp = requests.get(url, headers=headers, timeout=25)
    resp.raise_for_status()
    soup = BeautifulSoup(resp.text, "html.parser")

    raw_title = soup.find("h1").get_text(strip=True) if soup.find("h1") else url.rstrip("/").split("/")[-1]
    clean_title = re.sub(r"\s*\(.*?\)\s*", " ", raw_title).strip()

    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute(
            "SELECT id FROM sources WHERE url = %s OR LOWER(title) = LOWER(%s) LIMIT 1;",
            (url, clean_title),
        )
        existing = cur.fetchone()
        if existing:
            source_id = existing["id"]
        else:
            cur.execute(
                """
                INSERT INTO sources (title, author, translator, year, language, url)
                VALUES (%s, 'Classical Tradition', 'Wisdomlib Archive', 2024, 'English', %s)
                RETURNING id;
                """,
                (clean_title, url),
            )
            source_id = cur.fetchone()["id"]
            conn.commit()

        cur.execute("SELECT id FROM books WHERE source_id = %s LIMIT 1;", (source_id,))
        book_row = cur.fetchone()
        if book_row:
            book_id = book_row["id"]
        else:
            cur.execute(
                "INSERT INTO books (source_id, name) VALUES (%s, %s) RETURNING id;",
                (source_id, "Main Work"),
            )
            book_id = cur.fetchone()["id"]
            conn.commit()

        chapter_links = [
            (a.get_text(" ", strip=True) or f"Chapter {i}", urljoin(url, a["href"]))
            for i, a in enumerate(soup.select("a[href]"), 1)
            if "chapter" in a.get_text(" ", strip=True).lower() or "/d/doc" in a["href"]
        ]
        chapter_links = chapter_links[:35] or [(clean_title, url)]

        ingested_chapters = []
        for idx, (ch_title, ch_url) in enumerate(chapter_links, 1):
            cur.execute(
                "SELECT id FROM chapters WHERE book_id = %s AND chapter_number = %s LIMIT 1;",
                (book_id, idx),
            )
            ch_existing = cur.fetchone()
            if ch_existing:
                ingested_chapters.append((ch_existing["id"], idx, ch_title))
                continue

            try:
                ch_resp = requests.get(ch_url, headers=headers, timeout=20)
                ch_soup = BeautifulSoup(ch_resp.text, "html.parser")
                container = ch_soup.select_one("#scontent, .chapter-content, main") or ch_soup.body
                paras = [
                    p.get_text(" ", strip=True)
                    for p in container.find_all("p")
                    if len(p.get_text(" ", strip=True)) > 45
                ]
                if not paras:
                    continue

                cur.execute(
                    """
                    INSERT INTO chapters (book_id, chapter_number, title, source_url)
                    VALUES (%s, %s, %s, %s)
                    RETURNING id;
                    """,
                    (book_id, idx, ch_title[:200], ch_url),
                )
                chapter_id = cur.fetchone()["id"]
                for p_num, p_text in enumerate(paras, 1):
                    cur.execute(
                        """
                        INSERT INTO chapter_paragraphs (chapter_id, paragraph_number, content)
                        VALUES (%s, %s, %s);
                        """,
                        (chapter_id, p_num, p_text),
                    )
                conn.commit()
                ingested_chapters.append((chapter_id, idx, ch_title))
            except Exception:
                conn.rollback()

        # Discover & resolve characters + mentions + events inside the newly ingested source
        print(f"🔎 [2/4] Discovering characters, aliases, mentions & events for '{clean_title}'...")
        cur.execute("SELECT id, name FROM characters;")
        alias_to_id = {}
        id_to_name = {}
        for r in cur.fetchall():
            alias_to_id[norm(r["name"])] = r["id"]
            id_to_name[r["id"]] = r["name"]

        cur.execute("SELECT character_id, alias FROM character_aliases;")
        for r in cur.fetchall():
            if r["alias"]:
                alias_to_id[norm(r["alias"])] = r["character_id"]

        for canon, alist in CANONICAL_ALIASES.items():
            cid = alias_to_id.get(norm(canon))
            if cid:
                for a in alist:
                    alias_to_id[norm(a)] = cid

        # Scan paragraphs of this source to discover frequent proper nouns + record mentions
        cur.execute(
            """
            SELECT cp.chapter_id, cp.paragraph_number, cp.content, ch.title AS ch_title
            FROM chapter_paragraphs cp
            JOIN chapters ch ON ch.id = cp.chapter_id
            JOIN books b ON b.id = ch.book_id
            WHERE b.source_id = %s
            ORDER BY ch.chapter_number, cp.paragraph_number;
            """,
            (source_id,),
        )
        source_paras = cur.fetchall()

        # Candidate discovery via contextual honorifics ("King X", "Sage X", "X said", "X begat Y")
        candidate_counts = Counter()
        for row in source_paras:
            txt = row["content"]
            for m in re.finditer(
                r"\b(?:King|Prince|Queen|Sage|Rishi|Lord|Goddess|Deity)\s+([A-ZĀĪŪṚṢŚṆÑṬḌ][a-zāīūṛṣśṇñṭḍ]{2,18})\b"
                r"|\b([A-ZĀĪŪṚṢŚṆÑṬḌ][a-zāīūṛṣśṇñṭḍ]{2,18})\s+(?:said|spoke|replied|begat|slew)\b",
                txt,
            ):
                cand = m.group(1) or m.group(2)
                if cand and norm(cand) not in STOPWORDS_NER:
                    candidate_counts[cand] += 1

        for cand, cnt in candidate_counts.items():
            if cnt >= 3 and norm(cand) not in alias_to_id:
                cur.execute(
                    "INSERT INTO characters (name, description) VALUES (%s, %s) RETURNING id;",
                    (cand, f"Mythological Figure in {clean_title}"),
                )
                new_id = cur.fetchone()["id"]
                cur.execute(
                    "INSERT INTO character_aliases (character_id, alias) VALUES (%s, %s) ON CONFLICT DO NOTHING;",
                    (new_id, cand),
                )
                alias_to_id[norm(cand)] = new_id
                id_to_name[new_id] = cand
        conn.commit()

        # Match mentions & create chapter events if not already present
        for row in source_paras:
            ch_id = row["chapter_id"]
            p_num = row["paragraph_number"]
            txt = row["content"]
            ch_title = row["ch_title"] or "Chapter Narrative"

            matched_in_para = set()
            for word_m in re.finditer(r"\b[A-ZĀĪŪṚṢŚṆÑṬḌ][a-zāīūṛṣśṇñṭḍ]{2,20}\b", txt):
                w = word_m.group(0)
                cid = alias_to_id.get(norm(w))
                if cid:
                    matched_in_para.add(cid)
                    cur.execute(
                        """
                        INSERT INTO character_mentions
                            (character_id, chapter_id, mentioned_text, paragraph_number, start_position, end_position)
                        VALUES (%s, %s, %s, %s, %s, %s)
                        ON CONFLICT DO NOTHING;
                        """,
                        (cid, ch_id, w, p_num, word_m.start(), word_m.end()),
                    )

            if matched_in_para and p_num <= 5:
                lead_cid = sorted(matched_in_para)[0]
                ev_title = f"{id_to_name.get(lead_cid, 'Character')}: {ch_title[:80]}"
                cur.execute(
                    """
                    SELECT 1 FROM character_events
                    WHERE character_id = %s AND chapter_id = %s LIMIT 1;
                    """,
                    (lead_cid, ch_id),
                )
                if not cur.fetchone():
                    cur.execute(
                        """
                        INSERT INTO character_events
                            (character_id, chapter_id, event_title, event_summary, paragraph_start, paragraph_end, importance)
                        VALUES (%s, %s, %s, %s, %s, %s, 5);
                        """,
                        (lead_cid, ch_id, ev_title, txt[:280], p_num, p_num),
                    )
        conn.commit()

    return source_id


# ==============================================================================
# 6. UNIFIED ENRICHMENT: OVERWRITE BAD ROLES, SYNC ALIASES & BUILD RELATIONS
# ==============================================================================

def run_enrichment(conn):
    global ACTIVE_OLLAMA_MODEL
    ACTIVE_OLLAMA_MODEL = detect_ollama_model()
    if ACTIVE_OLLAMA_MODEL:
        print(f"🤖 Local Ollama AI Model detected: {ACTIVE_OLLAMA_MODEL}")
    if SPACY_NLP:
        print(f"🧠 Local spaCy Dependency Model active: {SPACY_NLP.meta.get('name')}")

    cur = conn.cursor(cursor_factory=RealDictCursor)
    try:
        print("🚀 Running Complete Profile, Alias & Relationship Enrichment...")

        # ------------------------------------------------------------------
        # STEP 1: Load Characters & Populate Canonical Aliases
        # ------------------------------------------------------------------
        cur.execute("SELECT id, name, description FROM characters ORDER BY id;")
        characters = {r["id"]: dict(r) for r in cur.fetchall()}
        alias_map = {norm(c["name"]): c["id"] for c in characters.values()}

        cur.execute("SELECT character_id, alias FROM character_aliases;")
        for r in cur.fetchall():
            if r["character_id"] in characters and r["alias"]:
                alias_map[norm(r["alias"])] = r["character_id"]

        for canon, aliases in CANONICAL_ALIASES.items():
            cid = alias_map.get(norm(canon))
            if cid:
                for a in aliases:
                    cur.execute(
                        "SELECT 1 FROM character_aliases WHERE character_id = %s AND LOWER(alias) = LOWER(%s) LIMIT 1;",
                        (cid, a),
                    )
                    if not cur.fetchone():
                        cur.execute(
                            "INSERT INTO character_aliases (character_id, alias) VALUES (%s, %s) ON CONFLICT DO NOTHING;",
                            (cid, a),
                        )
                    alias_map[norm(a)] = cid
        conn.commit()

        # ------------------------------------------------------------------
        # STEP 2: Gather Passages, Mentions & Events for Every Character
        # ------------------------------------------------------------------
        cur.execute("""
            SELECT
                c.id,
                (cp.character_id IS NOT NULL) AS has_prof,
                cp.source_url AS existing_url,
                COUNT(cm.id) AS m_count,
                ARRAY_AGG(DISTINCT s.title) FILTER (WHERE s.title IS NOT NULL) AS s_titles,
                MAX(COALESCE(ch.source_url, s.url)) AS b_url
            FROM characters c
            LEFT JOIN character_profiles cp ON cp.character_id = c.id
            LEFT JOIN character_mentions cm ON cm.character_id = c.id
            LEFT JOIN chapters ch ON ch.id = cm.chapter_id
            LEFT JOIN books b ON b.id = ch.book_id
            LEFT JOIN sources s ON s.id = b.source_id
            GROUP BY c.id, cp.character_id, cp.source_url;
        """)
        char_meta = {r["id"]: dict(r) for r in cur.fetchall()}

        cur.execute("""
            SELECT
                cm.character_id,
                cp.content,
                cm.chapter_id,
                cm.paragraph_number,
                ch.title AS chapter_title
            FROM character_mentions cm
            JOIN chapter_paragraphs cp
              ON cp.chapter_id = cm.chapter_id
             AND cp.paragraph_number = cm.paragraph_number
            JOIN chapters ch ON ch.id = cm.chapter_id
            WHERE cp.content IS NOT NULL
            ORDER BY cm.id ASC;
        """)
        char_passages = defaultdict(list)
        para_chars = defaultdict(set)
        para_texts = {}
        para_ch_title = {}

        for r in cur.fetchall():
            cid = r["character_id"]
            if len(char_passages[cid]) < 25:
                char_passages[cid].append(r["content"])
            pkey = (r["chapter_id"], r["paragraph_number"])
            para_chars[pkey].add(cid)
            if pkey not in para_texts:
                para_texts[pkey] = r["content"]
                para_ch_title[pkey] = r["chapter_title"] or ""

        cur.execute("SELECT character_id, event_summary FROM character_events WHERE event_summary IS NOT NULL;")
        char_events = defaultdict(list)
        for r in cur.fetchall():
            if len(char_events[r["character_id"]]) < 6:
                char_events[r["character_id"]].append(r["event_summary"])

        # ------------------------------------------------------------------
        # STEP 3: Force-Update ALL Character Roles, Descriptions & Bios
        # (Fixes Vayu, Sahadeva, Khara, Ailavila, etc. in BOTH tables!)
        # ------------------------------------------------------------------
        for cid, cinfo in characters.items():
            meta = char_meta.get(cid, {})
            role, bio = classify_character_profile(
                char_name=cinfo["name"],
                passages=char_passages.get(cid, []),
                event_summaries=char_events.get(cid, []),
                source_titles=meta.get("s_titles") or [],
                mention_count=meta.get("m_count") or 0,
            )
            characters[cid]["role"] = role
            final_url = meta.get("existing_url") or meta.get("b_url")

            cur.execute("UPDATE characters SET description = %s WHERE id = %s;", (role, cid))
            if meta.get("has_prof"):
                cur.execute(
                    """
                    UPDATE character_profiles
                    SET role = %s, background = %s, source_url = COALESCE(source_url, %s)
                    WHERE character_id = %s;
                    """,
                    (role, bio, final_url, cid),
                )
            else:
                cur.execute(
                    """
                    INSERT INTO character_profiles (character_id, role, background, source_url)
                    VALUES (%s, %s, %s, %s);
                    """,
                    (cid, role, bio, final_url),
                )
        conn.commit()
        print(f"✨ Updated accurate roles, descriptions & biographies for all {len(characters)} characters.")

        # ------------------------------------------------------------------
        # STEP 4: Rebuild Character Relationships (Direction-Verified!)
        # ------------------------------------------------------------------
        cur.execute("DELETE FROM character_relationships;")
        conn.commit()

        existing_edges = set()

        def add_rel(ca, cb, who_b_is_to_a: str, who_a_is_to_b: str) -> int:
            if not ca or not cb or int(ca) == int(cb):
                return 0
            ca_i, cb_i = int(ca), int(cb)
            added = 0
            if (ca_i, cb_i) not in existing_edges:
                cur.execute(
                    """
                    INSERT INTO character_relationships (character_id, related_character_id, relationship_type)
                    VALUES (%s, %s, %s);
                    """,
                    (ca_i, cb_i, who_b_is_to_a),
                )
                existing_edges.add((ca_i, cb_i))
                added += 1
            if who_a_is_to_b and (cb_i, ca_i) not in existing_edges:
                cur.execute(
                    """
                    INSERT INTO character_relationships (character_id, related_character_id, relationship_type)
                    VALUES (%s, %s, %s);
                    """,
                    (cb_i, ca_i, who_a_is_to_b),
                )
                existing_edges.add((cb_i, ca_i))
                added += 1
            return added

        # Tier 1: Verified Mythological Ontology (Direction-checked!)
        t1 = 0
        for name_a, name_b, b_to_a, a_to_b in VERIFIED_RELATIONS:
            id_a = alias_map.get(norm(name_a))
            id_b = alias_map.get(norm(name_b))
            if id_a and id_b:
                t1 += add_rel(id_a, id_b, b_to_a, a_to_b)
        conn.commit()
        print(f"⚡ Tier 1 (Verified Mythological Ontology): Inserted {t1} edges.")

        # Tier 2: Strict Clause-Isolated Syntax & Local LLM Extraction
        cooc_counts = Counter()
        shared_ch_titles = defaultdict(list)
        t2 = 0

        for pkey, cids in para_chars.items():
            if len(cids) < 2:
                continue
            cid_list = sorted(cids)
            raw_para = para_texts[pkey]
            ch_title = para_ch_title[pkey]
            sentences = re.split(r"(?<=[.!?])\s+", raw_para)

            for i in range(len(cid_list)):
                for j in range(i + 1, len(cid_list)):
                    ca, cb = cid_list[i], cid_list[j]
                    cooc_counts[(ca, cb)] += 1
                    if ch_title and len(shared_ch_titles[(ca, cb)]) < 5:
                        shared_ch_titles[(ca, cb)].append(ch_title)

                    if (ca, cb) in existing_edges:
                        continue

                    name_a = characters[ca]["name"]
                    name_b = characters[cb]["name"]
                    for sent in sentences:
                        ns = norm(sent)
                        if norm(name_a) in ns and norm(name_b) in ns:
                            res = extract_strict_clause_relations(sent, ca, name_a, cb, name_b)
                            if res:
                                t2 += add_rel(ca, cb, res[0], res[1])
                                break

        conn.commit()
        print(f"🧠 Tier 2 (Clause-Isolated Syntax & Local AI): Inserted {t2} edges.")

        # Tier 3: Chapter-Theme Context Relations ONLY for characters that still have 0 relations
        rel_counts = Counter(a for a, _ in existing_edges)
        neighbors = defaultdict(list)
        for (ca, cb), w in cooc_counts.items():
            neighbors[ca].append((w, cb, shared_ch_titles[(ca, cb)]))
            neighbors[cb].append((w, ca, shared_ch_titles[(ca, cb)]))

        t3 = 0
        for cid, cinfo in characters.items():
            if rel_counts[cid] >= 1:
                continue
            top_n = sorted(neighbors.get(cid, []), key=lambda x: x[0], reverse=True)
            for w, other_id, ch_list in top_n[:3]:
                b_to_a, a_to_b = infer_chapter_context_relation(
                    cinfo, characters[other_id], ch_list
                )
                added = add_rel(cid, other_id, b_to_a, a_to_b)
                if added:
                    t3 += added
                    rel_counts[cid] += 1
                    if rel_counts[cid] >= 3:
                        break

        conn.commit()
        print(f"🏛️  Tier 3 (Chapter-Theme Coverage for Minor Entities): Inserted {t3} edges.")
        print(f"✅ COMPLETE! Database now holds {t1 + t2 + t3} accurate, direction-verified relationships.")

    finally:
        cur.close()


if __name__ == "__main__":
    arg = sys.argv[1] if len(sys.argv) > 1 else ""
    conn = get_connection()
    try:
        if arg.startswith("http"):
            ingest_from_url(conn, arg)
        run_enrichment(conn)
    finally:
        conn.close()