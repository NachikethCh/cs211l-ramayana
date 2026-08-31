from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from database import get_connection

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
    return {
        "message": "Ramayana Character API is running"
    }


@app.get("/test-db")
def test_database():

    connection = get_connection()
    cursor = connection.cursor()

    cursor.execute(
        "SELECT current_database(), current_user;"
    )

    result = cursor.fetchone()

    cursor.close()
    connection.close()

    return {
        "database": result[0],
        "user": result[1],
        "status": "connected"
    }


@app.get("/characters")
def get_characters():

    connection = get_connection()
    cursor = connection.cursor()

    cursor.execute("""
        SELECT
            id,
            name,
            description
        FROM characters
        ORDER BY id;
    """)

    rows = cursor.fetchall()

    cursor.close()
    connection.close()

    characters = []

    for row in rows:
        characters.append({
            "id": row[0],
            "name": row[1],
            "description": row[2]
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
            cp.source_url
        FROM characters c
        LEFT JOIN character_profiles cp
            ON c.id = cp.character_id
        WHERE c.id = %s;
    """, (character_id,))

    row = cursor.fetchone()

    cursor.close()
    connection.close()

    if row is None:
        return {
            "error": "Character not found"
        }

    return {
        "id": row[0],
        "name": row[1],
        "description": row[2],
        "profile": {
            "background": row[3],
            "role": row[4],
            "source_url": row[5]
        }
    }
@app.get("/characters/{character_id}/story")
def get_character_story(character_id: int):

    connection = get_connection()
    cursor = connection.cursor()

    # --------------------------------------------------
    # Get character + profile
    # --------------------------------------------------

    cursor.execute("""
        SELECT
            c.id,
            c.name,
            c.description,
            cp.background,
            cp.role,
            cp.source_url
        FROM characters c
        LEFT JOIN character_profiles cp
            ON c.id = cp.character_id
        WHERE c.id = %s;
    """, (character_id,))

    character = cursor.fetchone()

    if character is None:
        cursor.close()
        connection.close()

        return {
            "error": "Character not found"
        }

    # --------------------------------------------------
    # Get events
    # --------------------------------------------------

    cursor.execute("""
        SELECT
            ce.id,
            ce.event_title,
            ce.event_summary,
            ch.chapter_number,
            ch.title,
            ce.paragraph_start,
            ce.paragraph_end,
            ce.importance
        FROM character_events ce
        JOIN chapters ch
            ON ce.chapter_id = ch.id
        WHERE ce.character_id = %s
        ORDER BY
            ch.chapter_number,
            ce.paragraph_start,
            ce.id;
    """, (character_id,))

    events = cursor.fetchall()

    story_events = []

    # --------------------------------------------------
    # Get paragraphs for each event
    # --------------------------------------------------

    for event in events:

        event_id = event[0]
        event_title = event[1]
        event_summary = event[2]
        chapter_number = event[3]
        chapter_title = event[4]
        paragraph_start = event[5]
        paragraph_end = event[6]
        importance = event[7]

        cursor.execute("""
            SELECT
                paragraph_number,
                content
            FROM chapter_paragraphs
            WHERE chapter_id = (
                SELECT chapter_id
                FROM character_events
                WHERE id = %s
            )
            AND paragraph_number BETWEEN (
                SELECT paragraph_start
                FROM character_events
                WHERE id = %s
            )
            AND (
                SELECT paragraph_end
                FROM character_events
                WHERE id = %s
            )
            ORDER BY paragraph_number;
        """, (event_id, event_id, event_id))
        paragraphs = cursor.fetchall()

        paragraph_data = []

        for paragraph in paragraphs:
            paragraph_data.append({
                "number": paragraph[0],
                "content": paragraph[1]
            })

        story_events.append({
            "id": event_id,
            "title": event_title,
            "summary": event_summary,
            "chapter": {
                "number": chapter_number,
                "title": chapter_title
            },
            "paragraph_start": paragraph_start,
            "paragraph_end": paragraph_end,
            "importance": importance,
            "paragraphs": paragraph_data
        })

    cursor.close()
    connection.close()

    # --------------------------------------------------
    # Return complete story
    # --------------------------------------------------

    return {
        "character": {
            "id": character[0],
            "name": character[1],
            "description": character[2]
        },
        "profile": {
            "background": character[3],
            "role": character[4],
            "source_url": character[5]
        },
        "events": story_events
    }
