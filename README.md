# MYTHVERSE — Exploring Characters Across Indian Epics

**A web platform for exploring character identities, aliases, and story events across different sources of Indian epics.**

[![React](https://img.shields.io/badge/Frontend-React-61DAFB?logo=react&logoColor=black)](https://react.dev/)
[![FastAPI](https://img.shields.io/badge/Backend-FastAPI-009688?logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com/)
[![PostgreSQL](https://img.shields.io/badge/Database-PostgreSQL-4169E1?logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Vite](https://img.shields.io/badge/Build-Vite-646CFF?logo=vite&logoColor=white)](https://vite.dev/)

## Table of Contents

- [Overview](#overview)
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
- [API Overview](#api-overview)
- [Development and Testing](#development-and-testing)
- [Configuration and Security](#configuration-and-security)
- [Troubleshooting](#troubleshooting)
- [Current Scope and Future Enhancements](#current-scope-and-future-enhancements)
- [Contributing](#contributing)
- [License](#license)

## Overview

MYTHVERSE is a web-based project developed as part of a Software Engineering course. It aims to make Indian epics easier to explore by connecting characters with their different names and presenting their information and story events across multiple sources.

The project currently focuses on character exploration using sources related to the Ramayana. Its architecture and data model are intended to support expansion to other Indian epics, sources, and translations.

## Problem Statement

The same character in Indian epics can be known by different names across books, scripts, translations, and sources. This makes it difficult for readers to identify these characters and understand how they are represented in different versions of a story.

## Proposed Solution

MYTHVERSE provides a unified platform where users can select a character, choose a source, and explore the available character information and important story events associated with that source.

The project also includes database structures and scripts for entity resolution, contextual keywords, and character-related data. These components support the broader goal of connecting different names and references to the same character.

## Features

- **Character exploration:** Browse and select characters available in the database.
- **Source selection:** Choose from available textual sources and translations.
- **Source-specific story events:** Retrieve story events associated with the selected character and source.
- **Character information:** Display available character profiles and details.
- **Source references:** Open the source URL when one is available.
- **Entity resolution support:** SQL schemas and Python scripts support contextual entity identification and resolution.
- **Database-backed architecture:** Store and retrieve character, source, chapter, paragraph, and event information using PostgreSQL.
- **Responsive frontend:** A React-based interface styled with CSS.
- **Extensible design:** Additional sources and future epic collections can be incorporated as the database and application are expanded.

*Feature availability depends on the data populated in the database. Not every character necessarily has information or events for every source.*

## How It Works

1. The user opens the MYTHVERSE web interface.
2. The frontend requests available character and source information from the backend.
3. The user selects a character and a source.
4. The frontend sends requests to the FastAPI backend with the selected identifiers.
5. The backend queries PostgreSQL for the relevant profile and story events.
6. The results are displayed in the frontend, with a source link where available.

## Technology Stack

| Component | Technology | Purpose |
|---|---|---|
| Frontend | React | User interface and interactive components |
| Frontend tooling | Vite | Development server and production build |
| Styling | CSS | Layout, appearance, and responsive styling |
| Backend | Python, FastAPI | REST API and application logic |
| Database | PostgreSQL | Persistent project data |
| Database driver | psycopg2-binary | Python-to-PostgreSQL connectivity |
| Validation | Pydantic | Data validation used by the backend |
| Server | Uvicorn | Runs the FastAPI application |
| Entity resolution utilities | Python and SQL | Contextual entity processing and database support |
| Version control | Git and GitHub | Source control and collaboration |

## Project Architecture

MYTHVERSE follows a frontend–backend–database architecture.

```text
                 USER
                   |
                   v
          React + Vite Frontend
             (Port 5173)
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

The frontend handles user interaction and presentation. The backend exposes API endpoints and executes database queries. PostgreSQL stores the information required to explore characters and their story events.

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

The tree above highlights the main project files. Additional files may exist in the repository. Database schema scripts and utility scripts should be reviewed before execution because some depend on existing tables or previously populated data.

## Prerequisites

Install the following on a new machine:

- Git
- Python 3.10 or later, with a version compatible with the installed dependencies
- Node.js and npm
- PostgreSQL
- A PostgreSQL database and user with the required permissions

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

`npm ci` uses the committed `package-lock.json` to install the frontend dependencies.

## Database Configuration

MYTHVERSE requires PostgreSQL to be installed and running. The database must contain the tables and data expected by the backend.

### 1. Create a database and user

Open PostgreSQL using an administrator account:

```bash
sudo -u postgres psql
```

Create a database and a dedicated user. Replace the example names and password with your own:

```sql
CREATE DATABASE mythverse;
CREATE USER mythverse_user WITH PASSWORD 'replace_with_a_strong_password';
GRANT ALL PRIVILEGES ON DATABASE mythverse TO mythverse_user;
```

Exit the PostgreSQL shell:

```sql
\q
```

**Important:** The commands above create an example database and user. They do not create the MYTHVERSE tables or import its data.

### 2. Configure environment variables

The backend uses environment variables for database credentials. The code reads `DB_PASSWORD` in `backend/database.py`.

Create a local configuration file:

```bash
nano backend/.env
```

Configure the database variables expected by `backend/database.py`. For example, if the code reads these variable names:

```dotenv
DB_HOST=localhost
DB_PORT=5432
DB_NAME=mythverse
DB_USER=mythverse_user
DB_PASSWORD=replace_with_a_strong_password
```

Verify the exact variable names in `backend/database.py` before using this example. The database name and user must also match the database you create.

Keep `backend/.env` private. It is excluded from Git and must not be committed.

### 3. Initialize or restore the database

The backend expects an existing schema and populated data. The repository contains SQL files for entity resolution, contextual keywords, and character relationships, but these files should not be assumed to constitute a complete database initialization sequence.

To run the application on a new machine, obtain an approved PostgreSQL backup or the complete database setup scripts from the project maintainer. Restore or initialize the database using the procedure appropriate to that backup and schema version.

For example, for a compatible plain-text PostgreSQL dump:

```bash
psql -h localhost -U mythverse_user -d mythverse -f /path/to/database_dump.sql
```

Use this command only with a compatible dump and an appropriately prepared target database. PostgreSQL custom-format dumps require `pg_restore` instead.

After initialization, verify that the database contains the tables and data expected by the backend, including the character, source, chapter, paragraph, and event data.

**Database note:** The local database dumps used during development are not included in the public repository. Do not assume that cloning the repository alone creates a fully populated database.

## Running the Application

Run the backend and frontend in separate terminals.

### Terminal 1 — Start the backend

From the project root:

```bash
cd cs211l-ramayana
source backend/venv/bin/activate
uvicorn main:app --app-dir backend --reload
```

The API should be available at:

```text
http://127.0.0.1:8000
```

Interactive API documentation is normally available at:

```text
http://127.0.0.1:8000/docs
```

The backend requires a working PostgreSQL connection and a correctly initialized database.

### Terminal 2 — Start the frontend

From the project root:

```bash
cd cs211l-ramayana/frontend
npm run dev
```

Vite normally serves the frontend at:

```text
http://localhost:5173
```

Open that address in your browser.

If the frontend cannot reach the backend, verify the API URL configured in the frontend code and ensure the backend is running on the expected port.

### Build the frontend for production

From the frontend directory:

```bash
npm run build
```

Vite generates production assets in `frontend/dist/`. This folder is generated output and is excluded from Git.

## API Overview

The FastAPI backend provides endpoints for retrieving project information. The following endpoints are implemented or used by the frontend:

| Endpoint | Purpose |
|---|---|
| `GET /sources` | Retrieve available sources |
| `GET /characters` | Retrieve available characters |
| `GET /characters/{character_id}` | Retrieve character information |
| `GET /characters/{character_id}/story` | Retrieve story information, with optional `source_id` filtering |
| `GET /characters/{character_id}/mentions` | Retrieve character mentions, with optional source filtering and pagination |

Example requests:

```bash
curl http://127.0.0.1:8000/sources
```

```bash
curl http://127.0.0.1:8000/characters
```

```bash
curl "http://127.0.0.1:8000/characters/1/story?source_id=2"
```

The returned results depend on the database contents and the identifiers available in the current database. Refer to `/docs` for the running backend's interactive API documentation.

## Development and Testing

### Check backend Python syntax

From the project root:

```bash
backend/venv/bin/python -m py_compile backend/main.py backend/database.py
```

### Build the frontend

```bash
cd frontend
npm run build
```

### Run the frontend linter

```bash
npm run lint
```

### Run project utility scripts

The `scripts/` directory contains utilities for character mention extraction, source import, entity resolution, and database testing. Review each script's purpose, configuration requirements, and database effects before running it. Some scripts may modify the database or depend on previously created tables.

### Version control

Check repository status:

```bash
git status
```

Commit and push changes:

```bash
git add .
git commit -m "Describe your changes"
git push origin main
```

Before using `git add .`, verify that secrets, database dumps, virtual environments, and generated files are excluded.

## Configuration and Security

- Never commit `.env` files, database passwords, API keys, or access tokens.
- Use a dedicated PostgreSQL user with only the required permissions.
- Keep database backups outside public repositories unless they have been reviewed and approved for publication.
- Review SQL scripts before executing them against an existing database.
- Do not run untrusted scripts against production databases.
- Use HTTPS and appropriate access controls when deploying the application publicly.
- Configure the frontend's API URL and backend CORS settings appropriately for deployment.

## Troubleshooting

### Database connection failure

- Confirm PostgreSQL is running.
- Verify the host, port, database name, username, and password.
- Confirm that `backend/.env` contains the variables expected by `backend/database.py`.
- Verify that the required database tables and data have been initialized.

### Frontend cannot retrieve data

- Ensure the FastAPI backend is running.
- Verify the API URL used by the frontend.
- Check browser developer tools and the backend terminal for errors.
- Confirm the requested character and source identifiers exist in the database.

### `npm ci` fails

- Check that Node.js and npm are installed.
- Run the command from the `frontend/` directory.
- Ensure `package.json` and `package-lock.json` are present and consistent.

### Python dependencies fail to install

- Activate the correct virtual environment.
- Check your Python version.
- Install the dependencies using `pip install -r backend/requirements.txt`.

### No story events appear for a source

The application can only display events that exist in the database and match the selected character and source. Verify the relevant records and source identifiers before assuming the API is broken.

## Current Scope and Future Enhancements

The current implementation focuses on source selection, character information, source-specific story events, and supporting entity-resolution data.

Potential future improvements include:

- Adding more Indian epics, translations, and textual sources.
- Improving character alias matching across scripts and transliterations.
- Supporting richer comparisons between different versions of a story.
- Expanding source-specific character profiles.
- Improving database initialization and migration documentation.
- Adding automated API and integration tests.
- Deploying the frontend and backend for public access.
- Providing a controlled interface for administrators to add sources and manage content.

These are possible extensions rather than claims that every feature is already implemented.

## Contributing

Contributions and suggestions are welcome.

1. Fork the repository.
2. Create a branch for your change.
3. Make and test your changes.
4. Submit a pull request with a clear description.

When contributing, avoid committing secrets, local database dumps, generated build output, or virtual environments.

## License

No license is specified in this README. Before redistributing or reusing the project, add a license approved by the project owner and ensure that the source texts, translations, datasets, and other included materials may legally be redistributed.

---

**Repository:** [NachikethCh/cs211l-ramayana](https://github.com/NachikethCh/cs211l-ramayana)

**Project:** MYTHVERSE — Exploring Characters Across Indian Epics
