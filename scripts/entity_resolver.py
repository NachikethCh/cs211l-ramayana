import re
import unicodedata


# ============================================================
# TEXT NORMALIZATION
# ============================================================

def normalize(text):
    """
    Normalize Unicode text.

    Examples:
        Rāma   -> rama
        Rama   -> rama
        Sītā   -> sita
        Sita   -> sita
        Ayodhyā -> ayodhya
    """

    text = unicodedata.normalize(
        "NFKD",
        text
    )

    text = "".join(
        char
        for char in text
        if not unicodedata.combining(char)
    )

    return text.lower()


# ============================================================
# WHOLE-WORD MATCHING
# ============================================================

def contains_word(text, word):
    """
    Check whether a complete word/term occurs in the text.
    """

    normalized_text = normalize(text)
    normalized_word = normalize(word)

    pattern = (
        r"(?<!\w)"
        + re.escape(normalized_word)
        + r"(?!\w)"
    )

    return re.search(
        pattern,
        normalized_text
    ) is not None


# ============================================================
# EXTENDED CONTEXT
# ============================================================

def get_extended_context(
    text,
    mention_start,
    mention_end
):
    """
    Get the sentence containing the mention plus
    one previous and one next sentence.
    """

    sentences = re.split(
        r"(?<=[.!?])\s+",
        text
    )

    current_position = 0
    target_index = None

    for index, sentence in enumerate(sentences):

        sentence_start = current_position

        sentence_end = (
            current_position
            + len(sentence)
        )

        if (
            sentence_start <= mention_start
            and mention_end <= sentence_end
        ):
            target_index = index
            break

        current_position = sentence_end + 1

    if target_index is None:
        return text

    start_index = max(
        0,
        target_index - 1
    )

    end_index = min(
        len(sentences),
        target_index + 2
    )

    return " ".join(
        sentences[start_index:end_index]
    )


# ============================================================
# LOCAL CONTEXT
# ============================================================

def get_local_context(
    text,
    mention,
    window=120
):
    """
    Keep only text near the detected mention.
    """

    normalized_text = normalize(text)

    normalized_mention = normalize(
        mention
    )

    position = normalized_text.find(
        normalized_mention
    )

    if position == -1:
        return normalized_text

    start = max(
        0,
        position - window
    )

    end = min(
        len(normalized_text),
        position
        + len(normalized_mention)
        + window
    )

    return normalized_text[start:end]


# ============================================================
# SCORE CANDIDATE
# ============================================================

def score_candidate(
    context,
    candidate
):
    """
    Score an entity candidate using keyword evidence.

    Candidate format:

    {
        "entity_id": 2,
        "entity_name": "Sita",
        "entity_type": "CHARACTER",
        "keywords": [
            {
                "keyword": "rama",
                "weight": 3
            },
            ...
        ]
    }
    """

    score = 0
    matched_words = []

    seen_keywords = set()

    for item in candidate.get(
        "keywords",
        []
    ):

        keyword = item["keyword"]
        weight = item["weight"]

        normalized_keyword = normalize(
            keyword
        )

        # Prevent duplicate evidence
        if normalized_keyword in seen_keywords:
            continue

        seen_keywords.add(
            normalized_keyword
        )

        if contains_word(
            context,
            normalized_keyword
        ):

            score += weight

            matched_words.append(
                normalized_keyword
            )

    return score, matched_words


# ============================================================
# RESOLVE ENTITY
# ============================================================

def resolve_entity(
    mention,
    context,
    candidates
):
    """
    Generic context-aware entity resolver.

    The resolver does not know anything specifically
    about Sītā, Rāma, rivers, etc.

    All candidate information is supplied externally.
    """

    if not candidates:

        return {
            "mention": mention,
            "entity": "UNKNOWN",
            "entity_type": None,
            "entity_id": None,
            "confidence": 0.0,
            "matched_context": [],
            "candidates": []
        }

    scored_candidates = []

    for candidate in candidates:

        score, matched_words = score_candidate(
            context,
            candidate
        )

        scored_candidates.append({

            "entity_id": candidate.get(
                "entity_id"
            ),

            "entity_name": candidate.get(
                "entity_name"
            ),

            "entity_type": candidate.get(
                "entity_type"
            ),

            "score": score,

            "matched_words": matched_words
        })


    # Highest score first
    scored_candidates.sort(
        key=lambda item: item["score"],
        reverse=True
    )


    best = scored_candidates[0]

    best_score = best["score"]


    # ========================================================
    # NO EVIDENCE
    # ========================================================

    if best_score == 0:

        return {
            "mention": mention,
            "entity": "UNKNOWN",
            "entity_type": None,
            "entity_id": None,
            "confidence": 0.0,
            "matched_context": [],
            "candidates": scored_candidates
        }


    # ========================================================
    # SECOND BEST
    # ========================================================

    second_score = 0

    if len(scored_candidates) > 1:

        second_score = (
            scored_candidates[1]["score"]
        )


    # ========================================================
    # AMBIGUOUS
    # ========================================================

    if best_score == second_score:

        return {
            "mention": mention,
            "entity": "AMBIGUOUS",
            "entity_type": None,
            "entity_id": None,
            "confidence": 0.5,
            "matched_context": best[
                "matched_words"
            ],
            "candidates": scored_candidates
        }


    # ========================================================
    # HEURISTIC CONFIDENCE
    # ========================================================

    confidence = best_score / (
        best_score + second_score
    )


    return {
        "mention": mention,

        "entity": best[
            "entity_name"
        ],

        "entity_type": best[
            "entity_type"
        ],

        "entity_id": best[
            "entity_id"
        ],

        "confidence": round(
            confidence,
            2
        ),

        "matched_context": best[
            "matched_words"
        ],

        "candidates": scored_candidates
    }
