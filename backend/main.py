from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from database import get_connection
from entity_resolution_service import resolve_text as resolve_text_service

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:5173",
        "http://127.0.0.1:5173",
        "http://localhost:5174",
        "http://127.0.0.1:5174",
        "http://localhost:5175",
        "http://127.0.0.1:5175",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def home():
    return {"message": "Ramayana Character API is running"}


@app.get("/test-db")
def test_database():
    connection = get_connection()
    cursor = connection.cursor()

    cursor.execute("SELECT current_database(), current_user;")
    result = cursor.fetchone()

    cursor.close()
    connection.close()

    return {
        "database": result[0],
        "user": result[1],
        "status": "connected",
    }


@app.get("/characters")
def get_characters():
    connection = get_connection()
    cursor = connection.cursor()

    # Return the main character fields plus the data needed by the
    # frontend search box. The event fields are aggregated so the
    # frontend can search event titles and summaries without making
    # a separate request for every character.
    cursor.execute("""
        SELECT
            c.id,
            c.name,
            c.description,
            COALESCE(
                (
                    SELECT ARRAY_AGG(ca.alias ORDER BY ca.alias)
                    FROM character_aliases ca
                    WHERE ca.character_id = c.id
                ),
                ARRAY[]::text[]
            ) AS aliases,
            COALESCE(cp.role, '') AS role,
            COALESCE(
                (
                    SELECT ARRAY_AGG(ce.event_title ORDER BY ce.id)
                    FROM character_events ce
                    WHERE ce.character_id = c.id
                ),
                ARRAY[]::text[]
            ) AS event_titles,
            COALESCE(
                (
                    SELECT ARRAY_AGG(ce.event_summary ORDER BY ce.id)
                    FROM character_events ce
                    WHERE ce.character_id = c.id
                ),
                ARRAY[]::text[]
            ) AS event_summaries
        FROM characters c
        LEFT JOIN character_profiles cp
            ON c.id = cp.character_id
        ORDER BY c.id;
    """)

    rows = cursor.fetchall()

    cursor.close()
    connection.close()

    characters = []

    for row in rows:
        characters.append({
            "id": row[0],
            "name": row[1],
            "description": row[2],
            "aliases": row[3],
            "role": row[4],
            "event_titles": row[5],
            "event_summaries": row[6],
        })

    return characters


@app.get("/characters/{character_id}")
def get_character(character_id: int):
    connection = get_connection()
    cursor = connection.cursor()

    cursor.execute("""
        SELECT
            c.id,
            c.name,
            c.description,
            cp.background,
            cp.role,
            cp.source_url,
            COALESCE(
                (
                    SELECT ARRAY_AGG(ca.alias ORDER BY ca.alias)
                    FROM character_aliases ca
                    WHERE ca.character_id = c.id
                ),
                ARRAY[]::text[]
            ) AS aliases
        FROM characters c
        LEFT JOIN character_profiles cp
            ON c.id = cp.character_id
        WHERE c.id = %s;
    """, (character_id,))

    row = cursor.fetchone()

    cursor.close()
    connection.close()

    if row is None:
        return {"error": "Character not found"}

    return {
        "id": row[0],
        "name": row[1],
        "description": row[2],
        "aliases": row[6],
        "profile": {
            "background": row[3],
            "role": row[4],
            "source_url": row[5],
        },
    }


@app.get("/characters/{character_id}/story")
def get_character_story(character_id: int):
    connection = get_connection()
    cursor = connection.cursor()

    # --------------------------------------------------
    # Get character + profile + aliases
    # --------------------------------------------------

    cursor.execute("""
        SELECT
            c.id,
            c.name,
            c.description,
            cp.background,
            cp.role,
            cp.source_url,
            COALESCE(
                (
                    SELECT ARRAY_AGG(ca.alias ORDER BY ca.alias)
                    FROM character_aliases ca
                    WHERE ca.character_id = c.id
                ),
                ARRAY[]::text[]
            ) AS aliases
        FROM characters c
        LEFT JOIN character_profiles cp
            ON c.id = cp.character_id
        WHERE c.id = %s;
    """, (character_id,))

    character = cursor.fetchone()

    if character is None:
        cursor.close()
        connection.close()
        return {"error": "Character not found"}

    # --------------------------------------------------
    # Get manually curated character relationships
    # --------------------------------------------------

    cursor.execute("""
        SELECT
            c.id,
            c.name,
            cr.relationship_type
        FROM character_relationships cr
        JOIN characters c
            ON c.id = cr.related_character_id
        WHERE cr.character_id = %s
        ORDER BY c.name;
    """, (character_id,))

    relationship_rows = cursor.fetchall()

    related_characters = []
    for row in relationship_rows:
        related_characters.append({
            "id": row[0],
            "name": row[1],
            "relationship": row[2],
        })

    # --------------------------------------------------
    # Get events + source information
    # --------------------------------------------------

    cursor.execute("""
        SELECT
            ce.id,
            ce.event_title,
            ce.event_summary,
            ch.chapter_number,
            ch.title,
            b.name,
            s.title,
            s.author,
            s.translator,
            s.year,
            s.language,
            s.url,
            ce.paragraph_start,
            ce.paragraph_end,
            ce.importance,
            ce.chapter_id
        FROM character_events ce
        JOIN chapters ch
            ON ce.chapter_id = ch.id
        LEFT JOIN books b
            ON ch.book_id = b.id
        LEFT JOIN sources s
            ON b.source_id = s.id
        WHERE ce.character_id = %s
        ORDER BY
            ch.chapter_number,
            ce.paragraph_start,
            ce.id;
    """, (character_id,))

    events = cursor.fetchall()
    story_events = []
    source_info = None

    for event in events:
        (
            event_id,
            event_title,
            event_summary,
            chapter_number,
            chapter_title,
            book_name,
            source_title,
            source_author,
            source_translator,
            source_year,
            source_language,
            source_url,
            paragraph_start,
            paragraph_end,
            importance,
            chapter_id,
        ) = event

        if source_info is None:
            source_info = {
                "title": source_title,
                "author": source_author,
                "translator": source_translator,
                "year": source_year,
                "language": source_language,
                "url": source_url,
            }

        cursor.execute("""
            SELECT
                paragraph_number,
                content
            FROM chapter_paragraphs
            WHERE chapter_id = %s
              AND paragraph_number BETWEEN %s AND %s
            ORDER BY paragraph_number;
        """, (chapter_id, paragraph_start, paragraph_end))

        paragraphs = cursor.fetchall()

        paragraph_data = []
        for paragraph in paragraphs:
            paragraph_data.append({
                "number": paragraph[0],
                "content": paragraph[1],
            })

        story_events.append({
            "id": event_id,
            "title": event_title,
            "summary": event_summary,
            "chapter": {
                "number": chapter_number,
                "title": chapter_title,
                "book": book_name,
            },
            "paragraph_start": paragraph_start,
            "paragraph_end": paragraph_end,
            "importance": importance,
            "paragraphs": paragraph_data,
        })

    cursor.close()
    connection.close()

    return {
        "character": {
            "id": character[0],
            "name": character[1],
            "description": character[2],
        },
        "aliases": character[6],
        "profile": {
            "background": character[3],
            "role": character[4],
            "source_url": character[5],
        },
        "source": source_info,
        "related_characters": related_characters,
        "events": story_events,
    }


class ResolveTextRequest(BaseModel):
    text: str = Field(..., min_length=1, max_length=50000)


@app.post("/resolve-text")
def resolve_text_endpoint(request: ResolveTextRequest):
    if not request.text.strip():
        raise HTTPException(
            status_code=422,
            detail="Text must not be blank.",
        )

    return resolve_text_service(request.text)
