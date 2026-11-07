# MYTHVERSE — Exploring Characters Across Indian Epics

**A web platform for exploring character identities, aliases, and story events across different sources of Indian epics.**

[![React](https://img.shields.io/badge/Frontend-React-61DAFB?logo=react&logoColor=black)](https://react.dev/)
[![FastAPI](https://img.shields.io/badge/Backend-FastAPI-009688?logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com/)
[![PostgreSQL](https://img.shields.io/badge/Database-PostgreSQL-4169E1?logo=postgresql&logoColor=white)](https://www.postgresql.org/)
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

**MYTHVERSE** (`cs211l-ramayana`) is a web-based project developed as part of the Software Engineering course (**CS211L**). It aims to make Indian epics easier to explore by connecting characters with their different names (epithets and aliases) and presenting their information, relationships, and story events across multiple sacred texts and sources.

Originally centered on the *Valmiki Ramayana*, its database schema and automated ingestion pipelines have been expanded to support multi-text corpora—including the *Garuda Purana*—allowing users to trace characters and story events across diverse traditions and translations.

---

## Team and Contributions

| Team Member | Roll Number | Role & Key Contributions |
|---|---|---|
| **Nachiketh Ch** | `CS25B011` | **Database Architecture & Entity Resolution:** Designed and maintained the PostgreSQL schema, built the contextual entity resolution registries (`entity_registry`, `entity_resolution`), and developed the automated multi-source ingestion and alias consolidation pipelines (`auto_inject_pipeline.py`, Wisdomlib importers). |
| **Jayanth** | `CS25B037` | **Frontend Engineering:** Built interactive React components, implemented client-side routing, state management, and integrated frontend views with the FastAPI backend endpoints. |
| **Chandra** | `CS25B009` | **Frontend Engineering:** Developed character exploration views, source filtering interfaces, story event displays, and responsive frontend workflows. |
| **Rujuthao** | `CS25B046` | **Backend Development:** Architected the FastAPI REST server, implemented endpoints for characters, sources, stories, and mentions, and managed database query execution and Pydantic data validation. |
| **Meghana** | `CS25B047` | **UI & Visual Design:** Crafted the visual identity, theme aesthetics, typography, layout structure, and custom CSS styling directly in code. |

---

## Problem Statement

The same character in Indian epics can be known by dozens of different names, epithets, and transliterations across books, scripts, translations, and Puranic sources (for example, *Rama / Raghava / Dasharathi* or *Garuda / Vainateya / Suparna*). This makes it difficult for readers and researchers to identify canonical characters and understand how they are represented across different versions and texts.

## Proposed Solution

MYTHVERSE provides a unified platform where users can select a character, choose a textual source, and explore canonical character profiles alongside source-specific story events and mentions.

Under the hood, the project pairs a relational PostgreSQL schema with Python data-engineering pipelines for automated text ingestion, contextual keyword matching, alias consolidation, and canonical entity resolution.

## Features

- **Character Exploration ("Meet the Legends"):** Browse and select canonical characters available in the database.
- **Multi-Source Selection:** Choose from available textual sources and translations (such as the *Ramayana* and *Garuda Purana*).
- **Source-Specific Story Events:** Retrieve chronological and thematic story events associated with the selected character and source.
- **Character Information & Mentions:** Display detailed character profiles, known aliases, and paginated paragraph-level text mentions.
- **Source References:** Open the original source URL directly when available.
- **Automated Entity Resolution & Ingestion:** SQL schemas and Python scripts (`auto_inject_pipeline.py`, `run_entity_resolution_pipeline.py`) support contextual entity identification, duplicate merging, and multi-source text parsing.
- **Database-Backed Architecture:** Store and retrieve character, source, chapter, paragraph, alias, and event information using PostgreSQL.
- **Responsive Custom UI:** A React-based interface styled with custom CSS designed directly for an immersive mythological aesthetic.

*Note: Feature availability depends on the data populated in the database. Not every character necessarily has information or events for every source.*

## How It Works

1. The user opens the MYTHVERSE web interface (`Explore`, `Sources`, `Characters`, `Connections`, `About`).
2. The frontend requests available character and source information from the FastAPI backend.
3. The user selects a character and a textual source.
4. The frontend sends requests to the FastAPI backend with the selected identifiers.
5. The backend queries PostgreSQL for the canonical profile, resolved aliases, mentions, and story events.
6. The results are rendered in the frontend, complete with source links where available.

## Technology Stack

| Component | Technology | Purpose |
|---|---|---|
| **Frontend** | React | User interface and interactive components |
| **Frontend Tooling** | Vite | Development server and production build |
| **Styling & UI** | Custom CSS | Layout, visual theme, typography, and responsive styling |
| **Backend** | Python, FastAPI | REST API and application logic |
| **Database** | PostgreSQL | Persistent relational storage for texts, entities, and events |
| **Database Driver** | `psycopg2-binary` | Python-to-PostgreSQL connectivity |
| **Validation** | Pydantic | Request/response data validation used by the backend |
| **Server** | Uvicorn | ASGI server running the FastAPI application |
| **Entity Resolution & ETL** | Python & SQL | Contextual entity processing, text ingestion, and alias merging |
| **Deployment & Version Control** | Vercel, Git, GitHub | Frontend hosting, source control, and team collaboration |

## Project Architecture

MYTHVERSE follows a three-tier frontend–backend–database architecture:

```text
                 USER
                   |
                   v
          React + Vite Frontend
       (Local: 5173 / Vercel Live)
                   |
              HTTP / JSON
                   |
                   v
            FastAPI Backend
             (Port 8000)
                   |
             psycopg2 driver
                   |
                   v
            PostgreSQL Database
                   |
       Characters, Sources, Chapters,
        Paragraphs, Events, Aliases
```

The frontend handles user interaction and presentation. The backend exposes RESTful API endpoints and executes parameterized SQL queries. PostgreSQL stores the canonical character registry, textual hierarchy, and resolved entity mentions.

## Project Structure

```text
cs211l-ramayana/
├── backend/
│   ├── main.py
│   ├── database.py
│   ├── entity_resolution_service.py
│   └── requirements.txt
│
├── frontend/
│   ├── public/
│   ├── src/
│   │   ├── App.jsx
│   │   ├── App.css
│   │   ├── index.css
│   │   └── main.jsx
│   ├── index.html
│   ├── package.json
│   ├── package-lock.json
│   └── vite.config.js
│
├── data/
│   ├── entity_context_keywords.sql
│   ├── entity_registry_v6.sql
│   ├── entity_resolution_v9.sql
│   └── ramayana2.0.sql
│
├── scripts/
│   ├── auto_inject_pipeline.py
│   ├── extract_character_mentions.py
│   ├── import_wisdomlib_generic.py
│   ├── preview_wisdomlib_source.py
│   ├── run_entity_resolution_pipeline.py
│   ├── test_entity_resolution_db.py
│   └── test_generic_entity_detection.py
│
├── .gitignore
└── README.md
```

*Note: The tree above highlights the main project files. Database schema scripts and utility scripts in `data/` and `scripts/` should be reviewed before execution because some depend on existing tables or previously populated data.*

## Prerequisites

Install the following on a new machine:

- **Git**
- **Python 3.10+** (compatible with installed dependencies)
- **Node.js** and **npm**
- **PostgreSQL** (with a configured database and user with required permissions)

Check the installed versions:

```bash
git --version
python3 --version
node --version
npm --version
psql --version
```

## Installation and Setup

### 1. Clone the repository

```bash
git clone https://github.com/NachikethCh/cs211l-ramayana.git
cd cs211l-ramayana
```

### 2. Set up the backend environment

Create a Python virtual environment:

```bash
python3 -m venv backend/venv
```

Activate it on Linux or macOS:

```bash
source backend/venv/bin/activate
```

On Windows PowerShell:

```powershell
py -m venv backend\venv
.\backend\venv\Scripts\Activate.ps1
```

Install the Python dependencies:

```bash
python -m pip install --upgrade pip
pip install -r backend/requirements.txt
```

### 3. Install frontend dependencies

Open a terminal in the project directory:

```bash
cd frontend
npm ci
```

Return to the project root:

```bash
cd ..
```

`npm ci` uses the committed `package-lock.json` to install exact frontend dependencies.

## Database Configuration

MYTHVERSE requires PostgreSQL to be installed and running. The database must contain the tables and data expected by the backend.

### 1. Create a database and user

Open PostgreSQL using an administrator account:

```bash
sudo -u postgres psql
```

Create a database and a dedicated user (replace the example names and password with your own):

```sql
CREATE DATABASE mythverse;
CREATE USER mythverse_user WITH PASSWORD 'replace_with_a_strong_password';
GRANT ALL PRIVILEGES ON DATABASE mythverse TO mythverse_user;
```

Exit the PostgreSQL shell:

```sql
\q
```

**Important:** The commands above create an empty database and user. They do not create the MYTHVERSE tables or import its data.

### 2. Configure environment variables

The backend uses environment variables for database credentials read in `backend/database.py`.

Create a local configuration file:

```bash
nano backend/.env
```

Configure the database variables expected by `backend/database.py`:

```dotenv
DB_HOST=localhost
DB_PORT=5432
DB_NAME=mythverse
DB_USER=mythverse_user
DB_PASSWORD=replace_with_a_strong_password
```

Verify the exact variable names in `backend/database.py` before using this example. Keep `backend/.env` private—it is excluded from Git and must never be committed.

### 3. Initialize or restore the database

The backend expects an existing schema and populated data. The repository contains SQL files for entity resolution, contextual keywords, and character relationships (`data/ramayana2.0.sql`, `data/entity_registry_v6.sql`, `data/entity_resolution_v9.sql`, `data/entity_context_keywords.sql`), which should be applied in the proper dependency order or restored from an approved PostgreSQL dump.

For a compatible plain-text PostgreSQL dump:

```bash
psql -h localhost -U mythverse_user -d mythverse -f /path/to/database_dump.sql
```

*(PostgreSQL custom-format dumps require `pg_restore` instead.)*

After initialization, verify that the database contains the tables and data expected by the backend, including the character, source, chapter, paragraph, alias, and event tables.

## Running the Application

Run the backend and frontend in separate terminals.

### Terminal 1 — Start the backend

From the project root:

```bash
cd cs211l-ramayana
source backend/venv/bin/activate
uvicorn main:app --app-dir backend --reload
```

- **API Base URL:** `http://127.0.0.1:8000`
- **Interactive Swagger UI Docs:** `http://127.0.0.1:8000/docs`

### Terminal 2 — Start the frontend

From the project root:

```bash
cd cs211l-ramayana/frontend
npm run dev
```

- **Frontend Local URL:** `http://localhost:5173`

### Build the frontend for production

From the `frontend/` directory:

```bash
npm run build
```

Vite generates production assets in `frontend/dist/`.

## Data Ingestion and Entity Resolution Scripts

The `scripts/` directory contains Python utilities for importing new sacred texts (such as Wisdomlib sources and the *Garuda Purana*), extracting character mentions, resolving canonical entities, and injecting events into PostgreSQL:

- `import_wisdomlib_generic.py` & `preview_wisdomlib_source.py` — Preview and import structured chapters and paragraphs from textual sources.
- `auto_inject_pipeline.py` — Automated pipeline to process configured sources, extract character events, and inject records into the database.
- `extract_character_mentions.py` — Scan imported source paragraphs to index character occurrences.
- `run_entity_resolution_pipeline.py` — Execute contextual keyword matching and alias consolidation across registered entities.
- `test_entity_resolution_db.py` & `test_generic_entity_detection.py` — Validation scripts to verify entity resolution accuracy against the database.

*Always review script arguments or run with dry-run/preview flags before executing write operations against a live database.*

## API Overview

The FastAPI backend provides endpoints for retrieving project information:

| Endpoint | Purpose |
|---|---|
| `GET /sources` | Retrieve all available textual sources |
| `GET /characters` | Retrieve available canonical characters |
| `GET /characters/{character_id}` | Retrieve detailed character profile information |
| `GET /characters/{character_id}/story` | Retrieve character story events, with optional `source_id` filtering |
| `GET /characters/{character_id}/mentions` | Retrieve textual mentions, with optional source filtering and pagination |

Example `curl` requests:

```bash
curl http://127.0.0.1:8000/sources
curl http://127.0.0.1:8000/characters
curl "http://127.0.0.1:8000/characters/1/story?source_id=2"
```

## Development and Testing

### Check backend Python syntax

From the project root:

```bash
backend/venv/bin/python -m py_compile backend/main.py backend/database.py
```

### Build and lint the frontend

```bash
cd frontend
npm run build
npm run lint
```

### Version control

Check repository status, stage, and push changes:

```bash
git status
git add .
git commit -m "Describe your changes"
git push origin main
```

*Before using `git add .`, verify that `.env` secrets, database dumps, virtual environments, and generated build files are excluded.*

## Configuration and Security

- Never commit `.env` files, database passwords, API keys, or access tokens.
- Use a dedicated PostgreSQL user with only the required permissions.
- Keep large local database dumps outside public repositories unless reviewed and approved.
- Review SQL and Python ingestion scripts before executing them against an existing database.
- Configure the frontend's API URL and backend CORS settings appropriately for production deployments.

## Troubleshooting

### Database connection failure
- Confirm PostgreSQL is running.
- Verify the host, port, database name, username, and password in `backend/.env`.
- Verify that the required database tables and data have been initialized.

### Frontend cannot retrieve data
- Ensure the FastAPI backend is running on port `8000`.
- Verify the API URL used by the frontend.
- Check browser developer tools (Network/Console tabs) and the backend terminal for CORS or connection errors.

### `npm ci` fails
- Check that Node.js and npm are installed.
- Run the command from the `frontend/` directory and ensure `package.json` and `package-lock.json` are consistent.

### No story events appear for a source
- The application displays events that exist in the database and match the selected `character_id` and `source_id`. Verify that the ingestion and entity resolution scripts have been run for the newly imported source.

## Current Scope and Future Enhancements

The current implementation supports multi-source selection (*Ramayana*, *Garuda Purana*, etc.), character profile exploration, source-specific story events, textual mention lookups, and automated entity-resolution pipelines.

Potential future enhancements include:

- Expanding the corpus with additional Indian epics, Puranas, and regional translations.
- Enhancing character alias matching across scripts and phonetic transliterations.
- Supporting interactive side-by-side comparisons between different versions of an epic event.
- Adding automated API and integration test suites.
- Providing an administrative dashboard for managing sources and curating entity aliases.

## Contributing

Contributions and suggestions are welcome:

1. Fork the repository.
2. Create a feature branch for your change.
3. Make and test your changes locally.
4. Submit a pull request with a clear description.

## License

No license is specified in this README. Before redistributing or reusing the project, add a license approved by the project team and ensure that the source texts, translations, datasets, and other included materials may legally be redistributed.

---

**Repository:** [NachikethCh/cs211l-ramayana](https://github.com/NachikethCh/cs211l-ramayana)  
**Live Deployment:** [cs211l-ramayana.vercel.app](https://cs211l-ramayana.vercel.app)  
**Project:** MYTHVERSE — Exploring Characters Across Indian Epics