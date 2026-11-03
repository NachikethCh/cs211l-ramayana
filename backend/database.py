import os
from pathlib import Path

import psycopg2
from dotenv import load_dotenv

# Load the backend/.env file regardless of the current working directory.
ENV_FILE = Path(__file__).resolve().parent / ".env"
load_dotenv(ENV_FILE)


def get_connection():
    return psycopg2.connect(
        host=os.getenv("DB_HOST"),
        port=os.getenv("DB_PORT"),
        database=os.getenv("DB_NAME"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
    )
