#!/usr/bin/env python3
"""Safely orchestrate WisdomLib import and source-scoped annotations.

Default mode is a dry run. Use --apply to write. Existing entity-resolution
results are not refreshed unless --refresh-annotations is also supplied.
"""

from __future__ import annotations

import argparse
import os
import subprocess
import sys
from datetime import datetime
from pathlib import Path
from urllib.parse import urlparse

from dotenv import dotenv_values

PROJECT_ROOT = Path(__file__).resolve().parent.parent

# Ensure project packages such as backend can be imported reliably.
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

SCRIPTS_DIR = PROJECT_ROOT / "scripts"
IMPORTER = SCRIPTS_DIR / "import_wisdomlib_generic.py"
EXTRACTOR = SCRIPTS_DIR / "extract_character_mentions.py"
RESOLVER = SCRIPTS_DIR / "run_entity_resolution_pipeline.py"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Run the complete source-scoped WisdomLib population workflow."
    )

    parser.add_argument(
        "--url",
        required=True,
        help="WisdomLib source landing-page URL.",
    )

    mode = parser.add_mutually_exclusive_group()

    mode.add_argument(
        "--dry-run",
        action="store_true",
        help="Preview import and annotation work without database writes (default).",
    )

    mode.add_argument(
        "--apply",
        action="store_true",
        help="Import content, extract mentions, and resolve entities.",
    )

    parser.add_argument(
        "--refresh-annotations",
        action="store_true",
        help="Permit rebuilding existing entity-resolution results for this source.",
    )

    args = parser.parse_args()

    parsed = urlparse(args.url.rstrip("/"))

    if (
        parsed.scheme not in ("http", "https")
        or parsed.netloc.lower() != "www.wisdomlib.org"
    ):
        parser.error("--url must be an HTTP(S) URL on www.wisdomlib.org.")

    if args.refresh_annotations and not args.apply:
        parser.error("--refresh-annotations requires --apply.")

    args.url = args.url.rstrip("/")

    return args


def run_step(label: str, command: list[str]) -> None:
    print(
        f"\n{'=' * 72}\n{label}\n{'=' * 72}",
        flush=True,
    )

    subprocess.run(
        command,
        cwd=PROJECT_ROOT,
        check=True,
    )


def get_connection():
    # Import inside the function so --help does not require a live DB.
    from backend.database import get_connection as connect

    return connect()


def get_source_id(source_url: str) -> int | None:
    conn = get_connection()

    try:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT id FROM sources WHERE url = %s ORDER BY id",
                (source_url,),
            )

            rows = cur.fetchall()

        if len(rows) > 1:
            raise RuntimeError(
                f"Multiple source rows use URL {source_url}; "
                "resolve duplicates first."
            )

        return rows[0][0] if rows else None

    finally:
        conn.close()


def source_counts(source_id: int) -> dict[str, int]:
    conn = get_connection()

    try:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT
                    (SELECT COUNT(*)
                     FROM character_mentions m
                     JOIN chapters ch ON ch.id = m.chapter_id
                     JOIN books b ON b.id = ch.book_id
                     WHERE b.source_id = %s),

                    (SELECT COUNT(*)
                     FROM character_events ev
                     JOIN chapters ch ON ch.id = ev.chapter_id
                     JOIN books b ON b.id = ch.book_id
                     WHERE b.source_id = %s),

                    (SELECT COUNT(*)
                     FROM entity_resolution_results er
                     JOIN chapters ch ON ch.id = er.chapter_id
                     JOIN books b ON b.id = ch.book_id
                     WHERE b.source_id = %s)
                """,
                (source_id, source_id, source_id),
            )

            mentions, events, resolutions = cur.fetchone()

            return {
                "mentions": mentions,
                "events": events,
                "resolutions": resolutions,
            }

    finally:
        conn.close()


def snapshot_other_sources(
    excluded_source_id: int | None,
) -> dict[int, tuple[int, int, int]]:

    conn = get_connection()

    try:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT s.id,

                    (SELECT COUNT(*)
                     FROM character_mentions m
                     JOIN chapters ch ON ch.id = m.chapter_id
                     JOIN books b ON b.id = ch.book_id
                     WHERE b.source_id = s.id),

                    (SELECT COUNT(*)
                     FROM character_events ev
                     JOIN chapters ch ON ch.id = ev.chapter_id
                     JOIN books b ON b.id = ch.book_id
                     WHERE b.source_id = s.id),

                    (SELECT COUNT(*)
                     FROM entity_resolution_results er
                     JOIN chapters ch ON ch.id = er.chapter_id
                     JOIN books b ON b.id = ch.book_id
                     WHERE b.source_id = s.id)

                FROM sources s
                WHERE (%s::INTEGER IS NULL OR s.id <> %s)
                ORDER BY s.id
                """,
                (excluded_source_id, excluded_source_id),
            )

            return {
                row[0]: (row[1], row[2], row[3])
                for row in cur.fetchall()
            }

    finally:
        conn.close()


def create_backup() -> Path:
    env = dotenv_values(PROJECT_ROOT / "backend" / ".env")

    required = [
        "DB_HOST",
        "DB_PORT",
        "DB_NAME",
        "DB_USER",
        "DB_PASSWORD",
    ]

    missing = [
        key for key in required
        if not env.get(key)
    ]

    if missing:
        raise RuntimeError(
            "Cannot create a safety backup; missing database settings: "
            + ", ".join(missing)
        )

    backup_dir = PROJECT_ROOT / "backups"
    backup_dir.mkdir(parents=True, exist_ok=True)

    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")

    backup_path = (
        backup_dir / f"automated-population-{timestamp}.dump"
    )

    child_env = os.environ.copy()
    child_env["PGPASSWORD"] = env["DB_PASSWORD"]

    command = [
        "pg_dump",
        "-h", env["DB_HOST"],
        "-p", str(env["DB_PORT"]),
        "-U", env["DB_USER"],
        "-d", env["DB_NAME"],
        "-Fc",
        "-f", str(backup_path),
    ]

    subprocess.run(
        command,
        cwd=PROJECT_ROOT,
        env=child_env,
        check=True,
    )

    if (
        not backup_path.exists()
        or backup_path.stat().st_size == 0
    ):
        raise RuntimeError(
            "pg_dump returned without producing a valid non-empty backup."
        )

    print(
        f"Safety backup created: "
        f"{backup_path.relative_to(PROJECT_ROOT)} "
        f"({backup_path.stat().st_size} bytes)",
        flush=True,
    )

    return backup_path


def verify_results(
    source_id: int,
    baseline_other_sources: dict[int, tuple[int, int, int]],
) -> None:

    conn = get_connection()

    try:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT s.title,

                    (SELECT COUNT(*)
                     FROM books b
                     WHERE b.source_id = s.id),

                    (SELECT COUNT(*)
                     FROM chapters ch
                     JOIN books b ON b.id = ch.book_id
                     WHERE b.source_id = s.id),

                    (SELECT COUNT(*)
                     FROM chapter_paragraphs cp
                     JOIN chapters ch ON ch.id = cp.chapter_id
                     JOIN books b ON b.id = ch.book_id
                     WHERE b.source_id = s.id),

                    (SELECT COUNT(*)
                     FROM character_mentions m
                     JOIN chapters ch ON ch.id = m.chapter_id
                     JOIN books b ON b.id = ch.book_id
                     WHERE b.source_id = s.id),

                    (SELECT COUNT(*)
                     FROM character_events ev
                     JOIN chapters ch ON ch.id = ev.chapter_id
                     JOIN books b ON b.id = ch.book_id
                     WHERE b.source_id = s.id),

                    (SELECT COUNT(*)
                     FROM entity_resolution_results er
                     JOIN chapters ch ON ch.id = er.chapter_id
                     JOIN books b ON b.id = ch.book_id
                     WHERE b.source_id = s.id)

                FROM sources s
                WHERE s.id = %s
                """,
                (source_id,),
            )

            row = cur.fetchone()

            if row is None:
                raise RuntimeError(
                    f"Source {source_id} disappeared after processing."
                )

            cur.execute(
                """
                SELECT COUNT(*)
                FROM character_mentions m
                JOIN chapters ch ON ch.id = m.chapter_id
                JOIN books b ON b.id = ch.book_id

                WHERE b.source_id = %s

                  AND NOT EXISTS (
                      SELECT 1
                      FROM entity_resolution_results er
                      WHERE er.chapter_id = m.chapter_id
                        AND er.paragraph_number = m.paragraph_number
                        AND er.start_position = m.start_position
                        AND er.end_position = m.end_position
                        AND er.mentioned_text = m.mentioned_text
                  )
                """,
                (source_id,),
            )

            mentions_without_resolution = cur.fetchone()[0]

            cur.execute(
                """
                SELECT COUNT(*)
                FROM entity_resolution_results er
                JOIN chapters ch ON ch.id = er.chapter_id
                JOIN books b ON b.id = ch.book_id

                WHERE b.source_id = %s

                  AND NOT EXISTS (
                      SELECT 1
                      FROM character_mentions m
                      WHERE m.chapter_id = er.chapter_id
                        AND m.paragraph_number = er.paragraph_number
                        AND m.start_position = er.start_position
                        AND m.end_position = er.end_position
                        AND m.mentioned_text = er.mentioned_text
                  )
                """,
                (source_id,),
            )

            resolutions_without_mention = cur.fetchone()[0]

            cur.execute(
                """
                SELECT s.id,

                    (SELECT COUNT(*)
                     FROM character_mentions m
                     JOIN chapters ch ON ch.id = m.chapter_id
                     JOIN books b ON b.id = ch.book_id
                     WHERE b.source_id = s.id),

                    (SELECT COUNT(*)
                     FROM character_events ev
                     JOIN chapters ch ON ch.id = ev.chapter_id
                     JOIN books b ON b.id = ch.book_id
                     WHERE b.source_id = s.id),

                    (SELECT COUNT(*)
                     FROM entity_resolution_results er
                     JOIN chapters ch ON ch.id = er.chapter_id
                     JOIN books b ON b.id = ch.book_id
                     WHERE b.source_id = s.id)

                FROM sources s
                WHERE s.id <> %s
                ORDER BY s.id
                """,
                (source_id,),
            )

            after_other_sources = {
                r[0]: (r[1], r[2], r[3])
                for r in cur.fetchall()
            }

        if after_other_sources != baseline_other_sources:
            raise RuntimeError(
                "Integrity check failed: annotation counts for another "
                "source changed. "
                f"Before={baseline_other_sources}; "
                f"after={after_other_sources}"
            )

        print("\n========== FINAL SOURCE REPORT ==========")

        print("Source ID:", source_id)
        print("Source:", row[0])
        print("Books:", row[1])
        print("Chapters:", row[2])
        print("Paragraphs:", row[3])
        print("Character mentions:", row[4])
        print("Character events:", row[5])
        print("Entity-resolution results:", row[6])

        print(
            "Mentions without resolution:",
            mentions_without_resolution,
        )

        print(
            "Resolutions without mentions:",
            resolutions_without_mention,
        )

        print("Other-source annotation counts: unchanged")

    finally:
        conn.close()


def main() -> int:
    args = parse_args()
    interpreter = sys.executable

    existing_source_id = get_source_id(args.url)

    print("=" * 72)
    print("AUTOMATED WISDOMLIB POPULATION")
    print("Mode:", "APPLY" if args.apply else "DRY RUN")
    print("URL:", args.url)
    print("=" * 72)

    if args.apply and existing_source_id is not None:
        counts = source_counts(existing_source_id)

        if (
            counts["resolutions"] > 0
            and not args.refresh_annotations
        ):
            raise RuntimeError(
                f"Source {existing_source_id} already has "
                f"{counts['resolutions']} entity-resolution results. "
                "Refusing to rebuild them implicitly. Re-run with "
                "--refresh-annotations only after reviewing the "
                "source-scoped replacement."
            )

    importer_command = [
        interpreter,
        str(IMPORTER),
        "--url",
        args.url,
    ]

    if not args.apply:

        run_step(
            "1/3 — IMPORTER DRY RUN",
            importer_command,
        )

        if existing_source_id is None:
            print(
                "\nThis source is not yet in the database. "
                "The importer preview is complete; annotation stages "
                "will run after an explicit --apply."
            )
            return 0

        run_step(
            "2/3 — CHARACTER EXTRACTION DRY RUN",
            [
                interpreter,
                str(EXTRACTOR),
                "--source-id",
                str(existing_source_id),
                "--dry-run",
            ],
        )

        run_step(
            "3/3 — ENTITY RESOLUTION DRY RUN",
            [
                interpreter,
                str(RESOLVER),
                "--source-id",
                str(existing_source_id),
                "--dry-run",
            ],
        )

        print(
            "\nWORKFLOW DRY RUN COMPLETE. "
            "No database writes were performed."
        )

        return 0

    baseline_other_sources = snapshot_other_sources(
        existing_source_id
    )

    create_backup()

    run_step(
        "1/3 — IMPORT CONTENT",
        importer_command + ["--apply"],
    )

    source_id = get_source_id(args.url)

    if source_id is None:
        raise RuntimeError(
            "Importer completed but no source row exists for the "
            "requested URL. Inspect the importer output before continuing."
        )

    run_step(
        "2/3 — EXTRACT CHARACTER MENTIONS",
        [
            interpreter,
            str(EXTRACTOR),
            "--source-id",
            str(source_id),
        ],
    )

    run_step(
        "3/3 — RESOLVE ENTITIES",
        [
            interpreter,
            str(RESOLVER),
            "--source-id",
            str(source_id),
            "--apply",
        ],
    )

    verify_results(
        source_id,
        baseline_other_sources,
    )

    print("\nAUTOMATED POPULATION COMPLETED SUCCESSFULLY.")
    print("Backup is available under backups/")

    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())

    except subprocess.CalledProcessError as exc:
        print(
            f"\nFAILED: command exited with status {exc.returncode}. "
            "Earlier committed stages, if any, remain committed; "
            "use the reported backup for recovery if required.",
            file=sys.stderr,
        )

        raise SystemExit(exc.returncode)

    except Exception as exc:
        print(
            f"\nFAILED: {exc}",
            file=sys.stderr,
        )

        raise SystemExit(1)
