# Ramayana Character Explorer

An interactive, database-backed web application for exploring characters and important events from the Ramayana.

The application allows users to browse characters, search for characters, view detailed character profiles, explore important events, and read the original source paragraphs associated with those events.

---

## Project Overview

The Ramayana is a large and interconnected narrative containing many characters, events, relationships, and alternative names.

This project provides a **character-centric exploration system** instead of requiring users to search through the entire text linearly.

The user can:

1. Browse characters.
2. Search for a character.
3. Open a character profile.
4. View important events associated with that character.
5. See the chapter and paragraph range of each event.
6. Read the original source passage supporting the event.

---

# Technology Stack

## Frontend

- React
- JavaScript / JSX
- CSS
- Vite
- npm

## Backend

- Python
- FastAPI
- Uvicorn
- psycopg2
- python-dotenv

## Database

- PostgreSQL

## Data Processing

- Python
- Regular Expressions
- SQL

---

# System Architecture

```text
                 RAMAYANA SOURCE TEXT
                          |
                          v
                 Python Data Scripts
                          |
            +-------------+-------------+
            |                           |
            v                           v
     Character Aliases          Chapter Paragraphs
            |                           |
            +-------------+-------------+
                          |
                          v
                     PostgreSQL
                          |
        +-----------------+-----------------+
        |                 |                 |
        v                 v                 v
   Characters         Mentions           Events
        |                 |                 |
        +-----------------+-----------------+
                          |
                          v
                       FastAPI
                          |
                       JSON API
                          |
                          v
                    React + Vite
                          |
                          v
                Interactive Web UI
