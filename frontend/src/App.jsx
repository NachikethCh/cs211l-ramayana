import { useEffect, useMemo, useState } from 'react'
import './App.css'

const API_URL = 'http://127.0.0.1:8000'

function App() {
  const [characters, setCharacters] = useState([])
  const [sources, setSources] = useState([])
  const [selectedSourceId, setSelectedSourceId] = useState(null)
  const [selectedCharacter, setSelectedCharacter] = useState(null)
  const [story, setStory] = useState(null)

  const [loadingCharacters, setLoadingCharacters] = useState(true)
  const [loadingStory, setLoadingStory] = useState(false)
  const [mentions, setMentions] = useState([])
  const [mentionsTotal, setMentionsTotal] = useState(0)
  const [mentionsOffset, setMentionsOffset] = useState(0)
  const [loadingMentions, setLoadingMentions] = useState(false)
  const [mentionsError, setMentionsError] = useState(null)
  const [error, setError] = useState(null)
  const [search, setSearch] = useState('')
  const [modalOpen, setModalOpen] = useState(false)

  // ------------------------------------------------------------
  // LOAD CHARACTERS FROM YOUR EXISTING FASTAPI BACKEND
  // ------------------------------------------------------------

  useEffect(() => {
    fetch(`${API_URL}/sources`)
      .then((response) => {
        if (!response.ok) throw new Error('Failed to fetch sources')
        return response.json()
      })
      .then((data) => {
        setSources(data)
        setSelectedSourceId((current) => current ?? data[0]?.id ?? null)
      })
      .catch((err) => {
        console.error('Could not load sources:', err)
      })
  }, [])

  useEffect(() => {
    fetch(`${API_URL}/characters`)
      .then((response) => {
        if (!response.ok) {
          throw new Error('Failed to fetch characters')
        }
        return response.json()
      })
      .then((data) => {
        setCharacters(data)
        setLoadingCharacters(false)
      })
      .catch((err) => {
        console.error(err)
        setError('Could not connect to the MYTHVERSE API.')
        setLoadingCharacters(false)
      })
  }, [])

  // ------------------------------------------------------------
  // OPEN CHARACTER
  // ------------------------------------------------------------

  const openCharacter = async (character, requestedSourceId = selectedSourceId) => {
    const sourceId = requestedSourceId ?? sources[0]?.id ?? null

    setSelectedCharacter(character)
    if (sourceId !== null) setSelectedSourceId(Number(sourceId))
    setStory(null)

    // Reset mentions for the newly selected character.
    setMentions([])
    setMentionsTotal(0)
    setMentionsOffset(0)
    setMentionsError(null)

    setError(null)
    setLoadingStory(true)
    setModalOpen(true)

    // Load story and mentions for the same selected source.
    loadCharacterMentions(character.id, 0, sourceId)

    try {
      const sourceQuery = sourceId !== null ? `?source_id=${sourceId}` : ''
      const response = await fetch(
        `${API_URL}/characters/${character.id}/story${sourceQuery}`,
      )

      if (!response.ok) {
        throw new Error('Failed to fetch character story')
      }

      const data = await response.json()
      setStory(data)
    } catch (err) {
      console.error(err)
      setError('Could not load this character.')
    } finally {
      setLoadingStory(false)
    }
  }

  const loadCharacterMentions = async (
    characterId,
    offset = 0,
    requestedSourceId = selectedSourceId,
  ) => {
    const sourceId = requestedSourceId ?? sources[0]?.id ?? null
    setLoadingMentions(true)
    setMentionsError(null)

    try {
      const sourceQuery = sourceId !== null ? `&source_id=${sourceId}` : ''
      const response = await fetch(
        `${API_URL}/characters/${characterId}/mentions?limit=50&offset=${offset}${sourceQuery}`,
      )

      if (!response.ok) {
        throw new Error('Failed to fetch character mentions')
      }

      const data = await response.json()

      setMentions((previous) =>
        offset === 0 ? data.mentions : [...previous, ...data.mentions],
      )
      setMentionsTotal(data.total)
      setMentionsOffset(offset + data.mentions.length)
    } catch (err) {
      console.error(err)
      setMentionsError('Could not load mentions for this source.')
    } finally {
      setLoadingMentions(false)
    }
  }

  const changeSource = (value) => {
    const sourceId = Number(value)
    if (!Number.isFinite(sourceId)) return
    setSelectedSourceId(sourceId)
    if (selectedCharacter) openCharacter(selectedCharacter, sourceId)
  }

  const openCharacterByName = (name) => {
    const character = characters.find((item) => item.name === name)

    if (character) {
      openCharacter(character)
    }
  }

  const closeModal = () => {
    setModalOpen(false)
  }

  const changeCharacter = (direction) => {
    if (!selectedCharacter || characters.length === 0) return

    const currentIndex = characters.findIndex(
      (character) => character.id === selectedCharacter.id,
    )

    if (currentIndex === -1) return

    const nextIndex =
      (currentIndex + direction + characters.length) % characters.length

    openCharacter(characters[nextIndex])
  }

  // ------------------------------------------------------------
  // SEARCH
  // ------------------------------------------------------------

  const normalizeText = (text) =>
    String(text || '')
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '')
      .toLowerCase()

  const filteredCharacters = useMemo(() => {
    const query = normalizeText(search.trim())

    if (!query) return characters

    return characters.filter((character) => {
      const searchableText = [
        character.name,
        character.description,
        character.role,
        ...(character.aliases || []),
        ...(character.event_titles || []),
        ...(character.event_summaries || []),
      ]

      return searchableText.some((value) =>
        normalizeText(value).includes(query),
      )
    })
  }, [characters, search])

  // Group occurrences by source and paragraph so the same passage is shown once.
  // Individual mention rows (including start/end positions) remain available in
  // paragraph.mentions for future highlighting and search features.
  const mentionsBySource = useMemo(() => {
    const groups = {}

    for (const mention of mentions) {
      const sourceId = mention.source?.id ?? 'unknown'

      if (!groups[sourceId]) {
        groups[sourceId] = {
          source: mention.source || {},
          paragraphs: {},
        }
      }

      const paragraphKey = [
        mention.book?.id ?? mention.book?.name ?? 'unknown-book',
        mention.chapter?.id ?? mention.chapter?.number ?? 'unknown-chapter',
        mention.paragraph_number ?? 'unknown-paragraph',
      ].join(':')

      if (!groups[sourceId].paragraphs[paragraphKey]) {
        groups[sourceId].paragraphs[paragraphKey] = {
          key: paragraphKey,
          mention,
          mentions: [],
        }
      }

      groups[sourceId].paragraphs[paragraphKey].mentions.push(mention)
    }

    return Object.fromEntries(
      Object.entries(groups).map(([sourceId, group]) => [
        sourceId,
        {
          source: group.source,
          paragraphs: Object.values(group.paragraphs),
        },
      ]),
    )
  }, [mentions])

  // ------------------------------------------------------------
  // ESCAPE KEY
  // ------------------------------------------------------------

  useEffect(() => {
    const handleKeyDown = (event) => {
      if (event.key === 'Escape') {
        closeModal()
      }
    }

    window.addEventListener('keydown', handleKeyDown)

    return () => {
      window.removeEventListener('keydown', handleKeyDown)
    }
  }, [])

  return (
    <div className="app">
      {/* ========================================================
          NAVIGATION
      ======================================================== */}

      <nav className="nav">
        <a className="brand" href="#home">
          <span className="brand-mark">✦</span>
          MYTHVERSE
        </a>

        <div className="navlinks">
          <a href="#explore">EXPLORE</a>
          <a href="#sources">SOURCES</a>
          <a href="#characters">CHARACTERS</a>
          <a href="#connections">CONNECTIONS</a>
          <a href="#about">ABOUT</a>
        </div>

        <button className="menu-button" aria-label="Menu">
          ☰
        </button>
      </nav>

      {/* ========================================================
          HERO
      ======================================================== */}

      <header className="hero" id="home">
        <div className="hero-pattern" />
        <div className="hero-orbit hero-orbit-one" />
        <div className="hero-orbit hero-orbit-two" />

        <div className="hero-content">
          <div className="kicker">AN INTERACTIVE MYTHOLOGY UNIVERSE</div>

          <h1>MYTHVERSE</h1>

          <p>
            Ancient stories. Legendary characters. Hidden connections.
            Explore Indian mythology through the texts that carry its stories.
          </p>

          <div className="hero-actions">
            <a className="cta" href="#explore">
              EXPLORE THE MYTHVERSE <span>→</span>
            </a>

            <a className="secondary-cta" href="#characters">
              MEET THE LEGENDS
            </a>
          </div>
        </div>

        <div className="scroll-indicator">
          DISCOVER BELOW · ↓
        </div>
      </header>

      {/* ========================================================
          INTRO
      ======================================================== */}

      <section className="section" id="explore">
        <div className="container">
          <div className="section-title reveal">
            <div className="eyebrow">THE IDEA</div>

            <h2>Where stories become connections.</h2>

            <p>
              MYTHVERSE is built to explore mythology through its original
              texts, characters, events and relationships — with every new
              source adding another part to the larger story.
            </p>
          </div>

          <div className="explore-grid">
            <article className="explore-card">
              <span className="explore-number">01</span>
              <h3>READ</h3>
              <p>
                Explore chapters and passages from the sources inside
                MYTHVERSE.
              </p>
            </article>

            <article className="explore-card">
              <span className="explore-number">02</span>
              <h3>DISCOVER</h3>
              <p>
                Find characters, aliases and important moments directly
                inside the stories.
              </p>
            </article>

            <article className="explore-card">
              <span className="explore-number">03</span>
              <h3>CONNECT</h3>
              <p>
                Follow characters, relationships and events across the
                mythology.
              </p>
            </article>

            <article className="explore-card">
              <span className="explore-number">04</span>
              <h3>EXPLORE</h3>
              <p>
                Jump from one story to another and discover how the pieces
                fit together.
              </p>
            </article>
          </div>
        </div>
      </section>

      {/* ========================================================
          SOURCES
          Ramayana is currently the populated source.
          The UI is intentionally source-agnostic.
      ======================================================== */}

      <section className="section dark" id="sources">
        <div className="container">
          <div className="section-title reveal">
            <div className="eyebrow">THE LIBRARY</div>

            <h2>Explore the Sources</h2>

            <p>
              MYTHVERSE is designed to grow. The Ramayana is the first source;
              administrators can add new texts, traditions, languages and
              scripts over time.
            </p>
          </div>

          <div className="source-grid">
            <article className="source-card-large active-source">
              <div className="source-art">
                <span className="source-symbol">◈</span>
              </div>

              <div className="source-content">
                <div className="source-label">CURRENTLY AVAILABLE</div>
                <h3>Valmiki Ramayana</h3>
                <p>
                  Explore characters, chapters, events and source passages
                  from the current MYTHVERSE dataset.
                </p>

                <a href="#characters" className="source-link">
                  EXPLORE SOURCE →
                </a>
              </div>
            </article>

            <article className="source-card-large future-source">
              <div className="source-art">
                <span className="source-symbol">✧</span>
              </div>

              <div className="source-content">
                <div className="source-label">DESIGNED TO EXPAND</div>
                <h3>More Worlds</h3>
                <p>
                  Mahabharata, Puranic literature, regional traditions and
                  other texts can become part of the MYTHVERSE.
                </p>

                <span className="source-link muted">
                  ADD THROUGH ADMIN →
                </span>
              </div>
            </article>
          </div>
        </div>
      </section>

      {/* ========================================================
          CHARACTERS
      ======================================================== */}

      <section className="section" id="characters">
        <div className="container">
          <div className="section-title reveal">
            <div className="eyebrow">THE LEGENDS</div>

            <h2>Meet the Characters</h2>

            <p>
              These characters are loaded from your PostgreSQL database
              through the existing FastAPI backend.
            </p>
          </div>

          <div className="character-toolbar">
            <input
              className="character-search"
              type="search"
              placeholder="Search characters, aliases or stories..."
              value={search}
              onChange={(event) => setSearch(event.target.value)}
            />

            <span className="character-total">
              {filteredCharacters.length} of {characters.length}
            </span>
          </div>

          {loadingCharacters && (
            <div className="state-box">Loading characters...</div>
          )}

          {error && !loadingCharacters && (
            <div className="state-box error">{error}</div>
          )}

          {!loadingCharacters &&
            !error &&
            filteredCharacters.length === 0 && (
              <div className="state-box">
                No characters match your search.
              </div>
            )}

          {!loadingCharacters &&
            !error &&
            filteredCharacters.length > 0 && (
              <div className="characters">
                {filteredCharacters.map((character, index) => (
                  <button
                    className="character"
                    key={character.id}
                    onClick={() => openCharacter(character)}
                  >
                    <div className="portrait">
                      {character.name?.charAt(0)}
                    </div>

                    <div className="character-info">
                      <div className="rank">
                        {String(index + 1).padStart(2, '0')}
                      </div>

                      <h3>{character.name}</h3>

                      <div className="role">
                        {character.description ||
                          character.role ||
                          'Explore this character'}
                      </div>

                      <span className="view">EXPLORE CHARACTER →</span>
                    </div>
                  </button>
                ))}
              </div>
            )}
        </div>
      </section>

      {/* ========================================================
          CONNECTIONS
      ======================================================== */}

      <section className="section dark" id="connections">
        <div className="container">
          <div className="section-title reveal">
            <div className="eyebrow">THE MYTHVERSE</div>

            <h2>Every story is connected.</h2>

            <p>
              A character can have many names. A character can appear in many
              chapters. Events connect people, places and stories. MYTHVERSE
              brings those connections together.
            </p>
          </div>

          <div className="connection-map">
            <div className="connection-node main">CHARACTER</div>
            <div className="connection-line line-one" />
            <div className="connection-node node-one">ALIASES</div>
            <div className="connection-line line-two" />
            <div className="connection-node node-two">EVENTS</div>
            <div className="connection-line line-three" />
            <div className="connection-node node-three">SOURCES</div>
            <div className="connection-line line-four" />
            <div className="connection-node node-four">RELATIONSHIPS</div>
          </div>
        </div>
      </section>

      {/* ========================================================
          ABOUT
      ======================================================== */}

      <section className="section" id="about">
        <div className="container">
          <div className="about-grid">
            <div>
              <div className="eyebrow">ABOUT MYTHVERSE</div>
              <h2>Ancient stories. Modern exploration.</h2>
            </div>

            <div>
              <p>
                MYTHVERSE is an extensible mythology platform. Its goal is
                not to represent a single epic, but to create a connected
                space where different texts and traditions can be explored
                together.
              </p>

              <p>
                Administrators can add new sources, while readers discover
                characters and their connections through the texts.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* ========================================================
          FOOTER
      ======================================================== */}

      <footer className="footer">
        <div className="brand">
          <span className="brand-mark">✦</span>
          MYTHVERSE
        </div>

        <p>Ancient stories. Modern exploration. Connected knowledge.</p>
      </footer>

      {/* ========================================================
          CHARACTER MODAL
      ======================================================== */}

      {modalOpen && (
        <div
          className="modal open"
          onClick={(event) => {
            if (event.target === event.currentTarget) {
              closeModal()
            }
          }}
        >
          <div className="modalbox">
            <button
              className="close"
              onClick={closeModal}
              aria-label="Close"
            >
              ×
            </button>

            <div className="character-navigation">
              <button
                className="change-character"
                onClick={() => changeCharacter(-1)}
              >
                ← PREVIOUS
              </button>

              <button
                className="change-character"
                onClick={closeModal}
              >
                CLOSE
              </button>

              <button
                className="change-character"
                onClick={() => changeCharacter(1)}
              >
                NEXT →
              </button>
            </div>

            {selectedCharacter && (
              <>
                <div className="eyebrow">CHARACTER</div>

                <h2>{selectedCharacter.name}</h2>

                <div className="modalrole">
                  {story?.profile?.role ||
                    selectedCharacter.description ||
                    selectedCharacter.role}
                </div>

                {story?.aliases?.length > 0 && (
                  <div className="aliases-section">
                    <h3>ALSO KNOWN AS</h3>

                    <div className="alias-list">
                      {story.aliases.map((alias) => (
                        <button
                          className="alias-pill"
                          type="button"
                          key={alias}
                          onClick={() => setSearch(alias)}
                        >
                          {alias}
                        </button>
                      ))}
                    </div>
                  </div>
                )}

                {story?.related_characters?.length > 0 && (
                  <div className="related-section">
                    <div className="related-heading">
                      <h3>RELATED CHARACTERS</h3>
                      <span>
                        {story.related_characters.length} connections
                      </span>
                    </div>

                    <div className="related-list">
                      {story.related_characters.map((related) => (
                        <button
                          className="related-card"
                          type="button"
                          key={`${related.id}-${related.relationship}`}
                          onClick={() => openCharacter(related)}
                        >
                          <span className="related-name">
                            {related.name}
                          </span>

                          <span className="related-type">
                            {related.relationship}
                          </span>
                        </button>
                      ))}
                    </div>
                  </div>
                )}

                {loadingStory && (
                  <div className="state-box">
                    Loading character story...
                  </div>
                )}

                {error && (
                  <div className="state-box error">{error}</div>
                )}

                {story && !loadingStory && (
                  <>
                    <div className="profile-section source-selector-section">
                      <label htmlFor="character-source-select">
                        EXPLORE THIS CHARACTER IN
                      </label>
                      <select
                        id="character-source-select"
                        className="character-search"
                        value={selectedSourceId ?? ''}
                        onChange={(event) => changeSource(event.target.value)}
                        disabled={sources.length === 0 || loadingStory}
                      >
                        {sources.map((source) => (
                          <option key={source.id} value={source.id}>
                            {source.title}
                            {source.translator ? ` — ${source.translator}` : ''}
                            {source.year ? ` (${source.year})` : ''}
                          </option>
                        ))}
                      </select>
                      <p className="mentions-intro">
                        Events and mentions below are filtered to this source.
                      </p>
                    </div>

                    {story.source && (
                      <div className="source-card">
                        <div className="source-card-title">SOURCE</div>

                        <div className="source-card-main">
                          {story.source.title || 'Source text'}
                        </div>

                        <div className="source-card-meta">
                          {story.source.translator ||
                            story.source.author ||
                            'Source text'}
                          {story.source.year
                            ? ` · ${story.source.year}`
                            : ''}
                          {story.source.language
                            ? ` · ${story.source.language}`
                            : ''}
                        </div>

                        {story.source.url && (
                          <a
                            className="source-link"
                            href={story.source.url}
                            target="_blank"
                            rel="noreferrer"
                          >
                            VIEW SOURCE →
                          </a>
                        )}
                      </div>
                    )}

                    <div className="profile-section">
                      <h3>BACKGROUND</h3>

                      <p className="bio">
                        {story.profile?.background ||
                          'Background information is not available yet.'}
                      </p>
                    </div>

                    <section className="mentions-section">
                      <div className="major-heading mentions-heading">
                        <h3>MENTIONS IN THIS SOURCE</h3>
                        <span>
                          {mentions.length} of {mentionsTotal} mentions
                        </span>
                      </div>

                      <p className="mentions-intro">
                        Explore this character's recorded appearances in the selected text,
                        with passages and source locations preserved.
                      </p>

                      {mentionsError && (
                        <div className="state-box error">{mentionsError}</div>
                      )}

                      {loadingMentions && mentions.length === 0 && (
                        <div className="state-box">
                          Loading mentions for this source...
                        </div>
                      )}

                      {!loadingMentions &&
                        !mentionsError &&
                        mentions.length === 0 && (
                          <div className="state-box">
                            No recorded mentions were found for this character.
                          </div>
                        )}

                      {Object.entries(mentionsBySource).map(([sourceId, group]) => (
                        <section className="mention-source-group" key={sourceId}>
                          <div className="mention-source-heading">
                            <h4>{group.source.title || 'Unknown source'}</h4>
                            <p>
                              {group.source.translator || group.source.author || 'Translator not specified'}
                              {group.source.year ? ` · ${group.source.year}` : ''}
                              {group.source.language ? ` · ${group.source.language}` : ''}
                            </p>
                            {group.source.url && (
                              <a href={group.source.url} target="_blank" rel="noreferrer">
                                VIEW SOURCE ↗
                              </a>
                            )}
                          </div>

                          <div className="mention-list">
                            {group.paragraphs.map((paragraph) => {
                              const mention = paragraph.mention
                              const matchedNames = [
                                ...new Set(paragraph.mentions.map((item) => item.mentioned_text).filter(Boolean)),
                              ]

                              return (
                                <article className="mention-card" key={paragraph.key}>
                                  <div className="mention-meta">
                                    {mention.book?.name ? `${mention.book.name} · ` : ''}
                                    {mention.chapter?.number != null ? `Chapter ${mention.chapter.number}` : 'Chapter'}
                                    {mention.chapter?.title ? ` · ${mention.chapter.title}` : ''}
                                    {mention.paragraph_number != null ? ` · Paragraph ${mention.paragraph_number}` : ''}
                                  </div>

                                  <div className="mention-matched-name">
                                    Matched name{matchedNames.length === 1 ? '' : 's'}:{' '}
                                    <strong>{matchedNames.join(', ') || 'Name unavailable'}</strong>
                                    <span className="mention-occurrence-count">
                                      {' '}· {paragraph.mentions.length} occurrence{paragraph.mentions.length === 1 ? '' : 's'}
                                    </span>
                                  </div>

                                  <p className="mention-passage">
                                    {mention.passage || 'Original passage unavailable.'}
                                  </p>

                                  {mention.chapter?.url && (
                                    <a className="mention-chapter-link" href={mention.chapter.url} target="_blank" rel="noreferrer">
                                      OPEN CHAPTER ↗
                                    </a>
                                  )}
                                </article>
                              )
                            })}
                          </div>
                        </section>
                      ))}

                      {loadingMentions && mentions.length > 0 && (
                        <div className="state-box">Loading more mentions...</div>
                      )}

                      {mentionsError && mentions.length > 0 && (
                        <button
                          className="mentions-load-more"
                          type="button"
                          onClick={() => loadCharacterMentions(selectedCharacter.id, mentionsOffset, selectedSourceId)}
                          disabled={loadingMentions}
                        >
                          RETRY LOADING MENTIONS
                        </button>
                      )}

                      {!mentionsError && mentionsOffset < mentionsTotal && (
                        <button
                          className="mentions-load-more"
                          type="button"
                          onClick={() => loadCharacterMentions(selectedCharacter.id, mentionsOffset, selectedSourceId)}
                          disabled={loadingMentions}
                        >
                          {loadingMentions ? 'LOADING...' : `LOAD MORE MENTIONS (${mentionsTotal - mentionsOffset} remaining)`}
                        </button>
                      )}
                    </section>

                    <div className="major">
                      <div className="major-heading">
                        <h3>MAJOR EVENTS</h3>
                        <span>{story.events?.length || 0} events</span>
                      </div>

                      {!story.events || story.events.length === 0 ? (
                        <div className="state-box">
                          No story events have been added for this
                          character yet.
                        </div>
                      ) : (
                        <div className="modal-events timeline-events">
                          {story.events.map((event, index) => (
                            <article
                              className="modal-event"
                              key={event.id}
                            >
                              <div className="modal-event-number">
                                {String(index + 1).padStart(2, '0')}
                              </div>

                              <div>
                                <div className="event-meta">
                                  {event.chapter?.book ||
                                    story.source?.title ||
                                    'Source'}
                                  {' · '}
                                  Chapter {event.chapter?.number}
                                  {event.chapter?.title
                                    ? ` · ${event.chapter.title}`
                                    : ''}
                                  {' · '}
                                  Paragraphs {event.paragraph_start}–
                                  {event.paragraph_end}
                                </div>

                                <h4>{event.title}</h4>

                                <p className="event-summary">
                                  {event.summary}
                                </p>

                                <details>
                                  <summary>
                                    READ ORIGINAL PASSAGE
                                  </summary>

                                  <div className="source-text">
                                    {event.paragraphs?.map(
                                      (paragraph) => (
                                        <div
                                          className="source-paragraph"
                                          key={paragraph.number}
                                        >
                                          <span>
                                            ¶ {paragraph.number}
                                          </span>

                                          <p>{paragraph.content}</p>
                                        </div>
                                      ),
                                    )}
                                  </div>
                                </details>
                              </div>
                            </article>
                          ))}
                        </div>
                      )}
                    </div>
                  </>
                )}
              </>
            )}
          </div>
        </div>
      )}
    </div>
  )
}

export default App
