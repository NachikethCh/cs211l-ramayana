# MYTHVERSE — Exploring Characters Across Indian Epics

**A computational mythology & knowledge graph platform for exploring canonical character identities, aliases, relationships, and story events across Indian epics.**

[![React](https://img.shields.io/badge/Frontend-React_19-61DAFB?logo=react&logoColor=black)](https://react.dev/)
[![FastAPI](https://img.shields.io/badge/Backend-FastAPI-009688?logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com/)
[![PostgreSQL](https://img.shields.io/badge/Database-PostgreSQL-4169E1?logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![ForceGraph2D](https://img.shields.io/badge/Graph-D3_Force_2D-F59E0B)](https://github.com/vasturiano/react-force-graph)
[![Vite](https://img.shields.io/badge/Build-Vite-646CFF?logo=vite&logoColor=white)](https://vite.dev/)
[![Vercel](https://img.shields.io/badge/Live_Demo-Vercel-000000?logo=vercel&logoColor=white)](https://cs211l-mythverse.vercel.app)

## 🔗 Live Production Links

- **Primary Web Application:** [cs211l-mythverse.vercel.app](https://cs211l-mythverse.vercel.app)
- **Legacy Domain (Redirects):** `https://cs211l-ramayana.vercel.app`

---

## Table of Contents

- [Overview](#overview)
- [Team and Contributions](#team-and-contributions)
- [Problem Statement](#problem-statement)
- [Proposed Solution](#proposed-solution)
- [Features](#features)
- [Models and Algorithms Used (100% Open-Source)](#models-and-algorithms-used-100-open-source)
- [How It Works](#how-it-works)
- [Technology Stack](#technology-stack)
- [Project Architecture](#project-architecture)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Installation and Setup](#installation-and-setup)
- [Database Configuration](#database-configuration)
- [Running the Application](#running-the-application)
- [Data Ingestion and Entity Resolution Scripts](#data-ingestion-and-entity-resolution-scripts)
- [API Overview](#api-overview)
- [Development and Testing](#development-and-testing)
- [Configuration and Security](#configuration-and-security)
- [Troubleshooting](#troubleshooting)
- [Current Scope and Future Enhancements](#current-scope-and-future-enhancements)
- [Contributing](#contributing)
- [License](#license)

---

## Overview

**MYTHVERSE** (`cs211l-ramayana`) is a full-stack computational mythology and knowledge graph platform developed as part of the Software Engineering course (**CS211L**). It makes classical Indian scriptures easier to explore by consolidating characters across their diverse Sanskrit and English epithets, synthesizing source-verified biographies, mapping direction-verified family and narrative relationships, and rendering interactive 2D co-occurrence networks.

Originally centered on the *Valmiki Ramayana*, its relational PostgreSQL schema and automated 1-command ingestion pipeline (`mythverse_pipeline.py`) now support a multi-scripture corpus—including the *Ramayana of Valmiki*, *R.T.H. Griffith's Verse Ramayana*, the *Bhagavad Gita*, the *Garuda Purana*, and the *Ganesha Purana*.

---













## Team and Contributions

| Team Member | Roll Number | Domain | Key Contributions |
|---|---|---|---|
| **Nachiketh Ch** | `CS25B011` | Database & Data Processing | Designed the PostgreSQL database, created automated Python pipelines to extract and store scriptural data, and developed character identification and relationship inference systems. |
| **Rujuthao** | `CS25B046` | Backend & Graph Development | Developed the FastAPI backend, implemented APIs for character relationships and story aggregation, and built the interactive 2D character relationship graph. |
| **Chandra Shekar** | `CS25B009` | Frontend & Character Extraction | Developed character name and alias extraction systems and implemented the character exploration interface, search functionality, and relationship navigation. |
| **Jayanth** | `CS25B037` | Narrative Analysis & Frontend | Developed narrative event extraction, chapter-wise story summaries, chronology visualization, and cross-script character comparison features. |
| **Meghana** | `CS25B047` | UI/UX & Visual Design | Designed the website's visual identity, scripture-based themes, animations, interactive layouts, and responsive user interface. |

---

## Problem Statement

A single figure in Indian epics is often referenced by dozens of distinct names, patronymics, epithets, and transliteration variants across translations and Puranic texts (for example, *Rāma / Raghava / Dasharathi*, *Kṛṣṇa / Govinda / Vāsudeva*, or *Garuḍa / Vainateya / Suparna*). Furthermore, homonyms such as *Sītā* can refer to either the princess of Mithila or a sacred river depending on narrative context. Standard keyword searches fail to unify aliases, disambiguate homonyms, or reveal the underlying web of genealogical and narrative relationships.

## Proposed Solution

MYTHVERSE pairs a normalized PostgreSQL knowledge graph with two complementary Python NLP pipelines and an interactive React + D3-Force frontend:

1. **Automated 1-Command Ingestion & Relationship Pipeline (`scripts/mythverse_pipeline.py`):** Scrapes scripture URLs into books, chapters, and paragraphs, discovers characters and aliases, synthesizes quote-backed biographies, and populates bidirectional relationships using a 3-tier extraction engine.
2. **Contextual Entity Resolution Engine (`scripts/entity_resolver.py` & `POST /resolve-text`):** Uses Unicode NFKD normalization and weighted sliding-window context scoring to disambiguate shared aliases and homonyms in real time.
3. **3-Part Interactive Scripture World (`frontend/src/App.jsx`):** Lets users swipe through sacred texts in a full-screen carousel and dive into any scripture's **Main Events**, **Canonical Characters**, and **2D Force-Directed Constellation Map**.

---

## Features

- **Full-Slide Scripture Archive Carousel:** Swipe horizontally through ingested scriptures with custom visual themes and live global search across texts, authors, and character aliases.
- **3-Layer Vertical Scripture World:**
  1. **01 · Main Events:** Chronological chapter turning points with expandable drawers displaying the exact translated source paragraphs (`¶ start–end`).
  2. **02 · Canonical Characters:** Filterable character cards displaying archetype roles, alias counts, and one-click access to full character dossiers.
  3. **03 · 2D Co-Occurrence Constellation (`ForceGraph2D`):** Interactive HTML5 Canvas network map with 3D jewel-core nodes, archetype category toggles (`Deities`, `Royals`, `Sages`, `Warriors`, `Asuras`, `Creatures`, `Consorts`), connection-strength sliders, flowing photon particles, and a floating node inspector card.
- **Direction-Verified Character Dossier Modal:** Displays canonical backgrounds with textual quotes, epithet tags, clickable relationship pills (allowing instant jumps between related characters), and source-filtered turning points.
- **1-Command URL Ingestion & Backfill:** Add a new Wisdomlib scripture URL or re-enrich the entire database with a single terminal command.
- **Live Contextual Disambiguation API (`POST /resolve-text`):** Resolves raw text passages into canonical entities with confidence scores and matched context evidence.

---

## Models and Algorithms Used (100% Open-Source)

MYTHVERSE uses **zero commercial or paid APIs**. Every NLP, extraction, and graph-layout model runs locally using open-source software:

| Model / Engine | License | Role in MYTHVERSE |
|---|---|---|
| **Ollama Local LLM** (`qwen2.5`, `llama3.2`, `mistral`, `gemma2` on `:11434`) | Open-Weights / MIT | Auto-detected by `mythverse_pipeline.py` to extract structured bidirectional character relationships (`b_to_a`, `a_to_b`) in JSON from shared sentences. |
| **spaCy** (`en_core_web_trf` / `en_core_web_sm`) | Open-Source (MIT) | Local NLP pipeline integrated for grammatical tokenization and dependency analysis. |
| **V11 Weighted Contextual-Keyword Resolver** (`entity_resolver.py`) | Custom Open-Source (Python) | Applies Unicode NFKD diacritic stripping, extracts a 3-sentence / $\pm 120$-character sliding window, scores candidates against `entity_context_keywords`, and computes heuristic confidence $\frac{S_1}{S_1 + S_2}$ (disambiguating cases like *Sītā* the character vs. *Sītā* the river). |
| **3-Tier Ontology & Clause-Isolated Kinship Extractor** (`mythverse_pipeline.py`) | Custom Open-Source (Python) | Combines Tier 1 (direction-verified canonical genealogy), Tier 2 (clause-isolated regex syntax such as `begat` and appositives with gender-consistency guardrails), and Tier 3 (chapter-theme context inference). |
| **D3-Force 2D Physics Engine** (`react-force-graph-2d`) | Open-Source (MIT) | Runs velocity-Verlet force simulation (`charge` repulsion + `link` springs) on HTML5 Canvas to cluster character nodes and animate directional link particles. |

---

## How It Works

1. **Archive Selection:** The user opens MYTHVERSE, searches or swipes through the horizontal scripture carousel, and selects a text (e.g., *The Ramayana*, *Bhagavadgita*, *Garuda Purana*, or *Ganesha Purana*).
2. **Parallel Data Fetch:** The React frontend queries `GET /characters?source_id=X`, `GET /graph?source_id=X`, and `GET /characters/{id}/story?source_id=X` on the FastAPI backend.
3. **Graph & Event Synthesis:** PostgreSQL computes mention-scaled node weights and overlapping event paragraph co-occurrences, returning nodes and weighted edges to the 2D Canvas force simulation.
4. **Interactive Exploration:** Clicking any character badge, relationship pill, or 2D graph node opens the Character Dossier Modal or focuses the camera on that character's constellation neighborhood.

---

## Technology Stack

| Component | Technology | Purpose |
|---|---|---|
| **Frontend** | React 19, Vite 8 | Component state, views, and fast HMR bundling |
| **2D Network Graph** | `react-force-graph-2d` | HTML5 Canvas force-directed graph & custom node/link shaders |
| **Styling & UI** | Custom CSS (`App.css`) | Cosmic nebula parallax, glassmorphism, and responsive layout |
| **Backend** | Python 3, FastAPI, Uvicorn | Asynchronous REST API and endpoint routing |
| **Database** | PostgreSQL, `psycopg2-binary` | Relational storage and SQL co-occurrence graph queries |
| **NLP & Scraping** | `spacy`, `requests`, `beautifulsoup4`, Local Ollama | Automated URL scraping, entity discovery, and relation mining |
| **Validation** | Pydantic v2 | Request/response schema validation |
| **Deployment** | Vercel, Git, GitHub | Production hosting and version control |

---

## Project Architecture

```text
                       USER BROWSER
                            |
                            v
       React 19 + ForceGraph2D Frontend (Port 5173 / Vercel)
        [Script Carousel | Events | Characters | 2D Map]
                            |
                       HTTP / JSON
                            |
                            v
                 FastAPI Backend (Port 8000)
      [/sources | /characters | /story | /mentions | /graph | /resolve-text]
                            |
                      psycopg2 Pool
                            |
                            v
                   PostgreSQL Database
    [sources, books, chapters, chapter_paragraphs, characters,
     character_aliases, character_profiles, character_mentions,
     character_events, character_relationships, entities]
                            ^
                            |
          Automated Python Pipelines (scripts/)
     [mythverse_pipeline.py  <-->  Local Ollama LLM / spaCy]
     [run_entity_resolution_pipeline.py  <-->  entity_resolver.py]
```

---

## Project Structure

```text
cs211l-ramayana/
├── backend/
│   ├── main.py                        # FastAPI endpoints (/sources, /characters, /graph, /resolve-text)
│   ├── database.py                    # Shared PostgreSQL connection handler
│   ├── entity_resolution_service.py   # Read-only contextual resolution service for FastAPI
│   └── requirements.txt               # Python backend & NLP dependencies
│
├── frontend/
│   ├── public/
│   ├── src/
│   │   ├── App.jsx                    # Main application & 2D Force-Graph constellation
│   │   ├── App.css                    # Cosmic theme, carousel, modal, and graph styling
│   │   ├── index.css
│   │   └── main.jsx
│   ├── index.html
│   ├── package.json
│   └── vite.config.js
│
├── data/
│   ├── entity_context_keywords.sql
│   ├── entity_registry_v6.sql
│   ├── entity_resolution_v9.sql
│   └── ramayana2.0.sql
│
├── scripts/
│   ├── mythverse_pipeline.py              # Unified 1-command URL ingestion, bio & 3-tier relation pipeline
│   ├── entity_resolver.py                 # Core Unicode NFKD & weighted context-window disambiguator
│   ├── run_entity_resolution_pipeline.py  # Batch V11 contextual entity resolution pipeline
│   ├── check_db.py                        # Database table & row-count verification utility
│   ├── preview_wisdomlib_source.py        # Source structure inspector
│   └── test_entity_resolution_db.py       # Resolution verification tests
│
├── COMMANDS.md                        # Quick CLI & viva command reference
├── .gitignore
└── README.md
```

---

## Prerequisites

Ensure the following are installed on your system:

- **Git**
- **Python 3.10+**
- **Node.js 18+** and **npm**
- **PostgreSQL 14+**
- *(Optional)* **Ollama** running locally on `http://localhost:11434` (`ollama pull llama3.2` or `qwen2.5`) for LLM-assisted Tier-2 relationship extraction.

---

## Installation and Setup

### 1. Clone the repository

```bash
git clone https://github.com/NachikethCh/cs211l-ramayana.git
cd cs211l-ramayana
```

### 2. Set up the Python virtual environment

```bash
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r backend/requirements.txt
pip install requests beautifulsoup4
```

### 3. Install frontend dependencies

```bash
cd frontend
npm install
cd ..
```

---

## Database Configuration

### 1. Create the PostgreSQL database

```bash
sudo -u postgres psql
```

```sql
CREATE DATABASE mythverse;
CREATE USER mythverse_user WITH PASSWORD 'replace_with_a_strong_password';
GRANT ALL PRIVILEGES ON DATABASE mythverse TO mythverse_user;
\q
```

### 2. Configure `backend/.env`

Create `backend/.env` with the credentials used by `backend/database.py`:

```dotenv
DB_HOST=localhost
DB_PORT=5432
DB_NAME=mythverse
DB_USER=mythverse_user
DB_PASSWORD=replace_with_a_strong_password
DATABASE_URL=postgresql://mythverse_user:replace_with_a_strong_password@localhost:5432/mythverse
```

### 3. Restore or initialize schema

Restore the base SQL dump or schema files into `mythverse`:

```bash
psql -h localhost -U mythverse_user -d mythverse -f data/ramayana2.0.sql
```

Then run the unified backfill command to enrich all character descriptions, roles, aliases, and direction-verified relationships:

```bash
python3 scripts/mythverse_pipeline.py --backfill
```

---

## Running the Application

Run the backend and frontend in two separate terminals:

### Terminal 1 — FastAPI Backend

```bash
cd ~/Documents/Codes/cs211l-ramayana/backend
source ../venv/bin/activate
uvicorn main:app --reload --port 8000
```

- **API Base URL:** `http://localhost:8000`
- **Swagger UI Docs:** `http://localhost:8000/docs`

### Terminal 2 — React + Vite Frontend

```bash
cd ~/Documents/Codes/cs211l-ramayana/frontend
npm run dev
```

- **Frontend Local URL:** `http://localhost:5173`

---

## Data Ingestion and Entity Resolution Scripts

### 1. Unified 1-Command URL Ingestion (`scripts/mythverse_pipeline.py`)

Pass any supported Wisdomlib scripture URL to automatically scrape chapters and paragraphs, discover characters and aliases, extract mentions and events, synthesize biographies, and build the 3-tier relationship graph:

```bash
python3 scripts/mythverse_pipeline.py "https://www.wisdomlib.org/hinduism/book/the-ramayana-of-valmiki"
```

### 2. Database Backfill & Relationship Rebuild (`--backfill`)

Re-run profile classification, quote extraction, and direction-verified relationship generation across all existing database characters without scraping:

```bash
python3 scripts/mythverse_pipeline.py --backfill
```

### 3. Contextual Entity Resolution Pipeline (`scripts/run_entity_resolution_pipeline.py`)

Run the V11 weighted contextual-keyword disambiguator on a specific `source_id` (or preview with `--dry-run`):

```bash
python3 scripts/run_entity_resolution_pipeline.py --source-id 3
python3 scripts/run_entity_resolution_pipeline.py --source-id 3 --dry-run
```

---

## API Overview

| Method & Endpoint | Purpose |
|---|---|
| `GET /` | Health check confirming the API is running |
| `GET /test-db` | Verify active PostgreSQL database and user connection |
| `GET /sources` | Retrieve all ingested scriptures and metadata |
| `GET /characters` | Retrieve canonical characters, aliases, roles, and events (supports `?source_id=`) |
| `GET /characters/{character_id}` | Retrieve a single character's canonical profile and aliases |
| `GET /characters/{character_id}/story` | Retrieve biography, `related_characters`, source mention counts, and chronological events with paragraphs (supports `?source_id=`) |
| `GET /characters/{character_id}/mentions` | Retrieve paginated paragraph-level character mentions (`?source_id=&limit=&offset=`) |
| `GET /graph` | Compute 2D network nodes (mention-scaled radii & archetype groups) and co-occurrence links (`?source_id=`) |
| `POST /resolve-text` | Disambiguate entity aliases in arbitrary input text with confidence scores |

Example `curl` commands:

```bash
curl http://localhost:8000/sources
curl "http://localhost:8000/characters?source_id=1"
curl "http://localhost:8000/characters/1/story?source_id=1"
curl "http://localhost:8000/graph?source_id=1"
curl -X POST http://localhost:8000/resolve-text \
  -H "Content-Type: application/json" \
  -d '{"text": "Raghava and Saumitri crossed the sacred stream with Sita."}'
```

---

## Development and Testing

### Verify database row counts

```bash
python3 scripts/check_db.py
```

### Compile-check Python files

```bash
python3 -m py_compile backend/main.py backend/database.py backend/entity_resolution_service.py scripts/mythverse_pipeline.py
```

### Build and lint the frontend

```bash
cd frontend
npm run build
npm run lint
```

---

## Configuration and Security

- Never commit `.env` files, database passwords, or local virtual environments (`venv/`).
- `mythverse_pipeline.py` uses `DELETE FROM character_relationships` instead of `TRUNCATE ... RESTART IDENTITY` so standard application database users do not require sequence-ownership privileges.
- Always test custom entity resolution changes with `--dry-run` before writing to production tables.

---

## Troubleshooting

### `psycopg2.OperationalError: password authentication failed`
- Ensure your script imports `get_connection` from `backend/database.py` (already configured in `scripts/mythverse_pipeline.py`) and that `backend/.env` contains your valid local PostgreSQL credentials.

### `InsufficientPrivilege: must be owner of sequence`
- Resolved in `scripts/mythverse_pipeline.py` by using `DELETE FROM character_relationships;` rather than `TRUNCATE`.

### Frontend cannot reach backend
- Verify `uvicorn main:app --reload --port 8000` is running and check `VITE_API_BASE_URL` (defaults to `http://localhost:8000`).

---

## Current Scope and Future Enhancements

**Current Scope:**
- Multi-scripture ingestion and exploration (*Ramayana*, *Griffith Ramayana*, *Bhagavad Gita*, *Garuda Purana*, *Ganesha Purana*).
- Automated 1-command URL ingestion, alias consolidation, quote-backed biographies, and 3-tier direction-verified relationships.
- Interactive 2D D3-Force constellation map with full node hit-testing and HUD controls.

**Future Enhancements:**
- Cross-cultural mythology expansion (e.g., Greek and Norse ontologies via modular archetype dictionaries).
- Side-by-side translation comparison view for parallel chapter passages.
- Administrative web UI for triggering URL ingestion jobs directly from the browser.

---

## Contributing

1. Fork the repository.
2. Create a feature branch (`git checkout -b feature/your-feature`).
3. Commit your changes and verify both backend and frontend builds.
4. Open a pull request.

## License

Developed for academic and research purposes in **CS211L (Software Engineering)**. Ensure all third-party translations and source texts comply with their respective archive licenses before redistribution.

---

**Repository:** [NachikethCh/cs211l-ramayana](https://github.com/NachikethCh/cs211l-ramayana)  
**Live Deployment:** [cs211l-mythverse.vercel.app](https://cs211l-mythverse.vercel.app)  
**Project:** MYTHVERSE — Exploring Characters Across Indian Epics
