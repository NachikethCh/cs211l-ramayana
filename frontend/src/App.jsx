import { useEffect, useMemo, useState } from 'react'
import './App.css'
import ForceGraph2D from 'react-force-graph-2d'

const API_URL = import.meta.env.VITE_API_BASE_URL || 'https://mythverse-backend-254f.onrender.com'

function App() {
  const [characters, setCharacters] = useState([])
  const [sources, setSources] = useState([])
  const [selectedSourceId, setSelectedSourceId] = useState(null)
  const [activeSourceFilter, setActiveSourceFilter] = useState(null)
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
  const [graphData, setGraphData] = useState({ nodes: [], links: [] })

  // ------------------------------------------------------------
  // GRAPH DATA (SUPPORTS SOURCE FILTERING)
  // ------------------------------------------------------------

  useEffect(() => {
    const graphQuery = activeSourceFilter ? `?source_id=${activeSourceFilter}` : ''
    fetch(`${API_URL}/graph${graphQuery}`)
      .then((res) => {
        if (!res.ok) throw new Error('Failed to fetch graph data')
        return res.json()
      })
      .then((data) => setGraphData(data))
      .catch((err) => console.error('Failed to fetch graph data:', err))
  }, [activeSourceFilter])

  // ------------------------------------------------------------
  // LOAD SOURCES
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

  // ------------------------------------------------------------
  // LOAD CHARACTERS
  // ------------------------------------------------------------

  useEffect(() => {
    setLoadingCharacters(true)
    setError(null)
    const sourceQuery = activeSourceFilter ? `?source_id=${activeSourceFilter}` : ''

    fetch(`${API_URL}/characters${sourceQuery}`)
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
  }, [activeSourceFilter])

  // ------------------------------------------------------------
  // OPEN CHARACTER
  // ------------------------------------------------------------

  const openCharacter = async (
    character,
    requestedSourceId = selectedSourceId,
    isExplicitSourceChange = false,
  ) => {
    let sourceId = requestedSourceId ?? activeSourceFilter ?? sources[0]?.id ?? null

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

    try {
      const sourceQuery = sourceId !== null ? `?source_id=${sourceId}` : ''
      const response = await fetch(
        `${API_URL}/characters/${character.id}/story${sourceQuery}`,
      )

      if (!response.ok) {
        throw new Error('Failed to fetch character story')
      }

      let data = await response.json()

      // Auto-switch to first available source if character has 0 mentions here
      const counts = data.source_mention_counts || {}
      if (
        !isExplicitSourceChange &&
        sourceId !== null &&
        (counts[String(sourceId)] || 0) === 0 &&
        Object.keys(counts).length > 0
      ) {
        const bestSource = sources.find((s) => (counts[String(s.id)] || 0) > 0)
        if (bestSource) {
          sourceId = bestSource.id
          setSelectedSourceId(Number(sourceId))
          const retryRes = await fetch(
            `${API_URL}/characters/${character.id}/story?source_id=${sourceId}`,
          )
          if (retryRes.ok) {
            data = await retryRes.json()
          }
        }
      }

      setStory(data)
      loadCharacterMentions(character.id, 0, sourceId)
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
    const sourceId = requestedSourceId ?? activeSourceFilter ?? sources[0]?.id ?? null
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
    if (selectedCharacter) openCharacter(selectedCharacter, sourceId, true)
  }

  const closeModal = () => {
    setModalOpen(false)
  }

  const changeCharacter = (direction) => {
    if (!selectedCharacter || filteredCharacters.length === 0) return

    const currentIndex = filteredCharacters.findIndex(
      (character) => character.id === selectedCharacter.id,
    )

    if (currentIndex === -1) {
      openCharacter(filteredCharacters[0])
      return
    }

    const nextIndex =
      (currentIndex + direction + filteredCharacters.length) % filteredCharacters.length

    openCharacter(filteredCharacters[nextIndex])
  }

  // ------------------------------------------------------------
  // AVATAR GENERATION
  // ------------------------------------------------------------

  const getGradient = (name) => {
    let hash = 0
    for (let i = 0; i < name.length; i++) {
      hash = name.charCodeAt(i) + ((hash << 5) - hash)
    }
    const h1 = Math.abs(hash) % 360
    const h2 = (h1 + 40) % 360
    return `linear-gradient(135deg, hsl(${h1}, 60%, 25%), hsl(${h2}, 70%, 10%))`
  }

  // ------------------------------------------------------------
  // SEARCH & CLIENT-SIDE FILTERING FALLBACK
  // ------------------------------------------------------------

  const normalizeText = (text) =>
    String(text || '')
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '')
      .toLowerCase()

  const filteredCharacters = useMemo(() => {
    const query = normalizeText(search.trim())

    return characters.filter((character) => {
      // If character object has source_ids array, respect activeSourceFilter client-side as well
      if (
        activeSourceFilter !== null &&
        Array.isArray(character.source_ids) &&
        !character.source_ids.includes(activeSourceFilter)
      ) {
        return false
      }

      if (!query) return true

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
  }, [characters, search, activeSourceFilter])

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

  const currentSourceMentions =
    story?.source_mention_counts && selectedSourceId !== null
      ? story.source_mention_counts[String(selectedSourceId)] || 0
      : mentionsTotal

  const totalMentionsAllSources =
    story?.total_mentions_all_sources ?? mentionsTotal

  const activeSourceObj = sources.find((s) => s.id === activeSourceFilter)

  return (
    <div className="app">
      {/* ========================================================
          NAVIGATION
      ======================================================== */}

      <nav className="nav">
        <a className="brand" href="#home" style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
          <img
            src="/logo.png"
            alt="Mythverse Emblem"
            style={{
              width: '32px',
              height: '32px',
              borderRadius: '50%',
              objectFit: 'cover',
              border: '1px solid rgba(197, 160, 89, 0.6)',
              boxShadow: '0 0 8px rgba(197, 160, 89, 0.4)',
            }}
          />
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

          <h1 style={{ textShadow: '0 0 40px rgba(197, 160, 89, 0.6), 0 0 15px rgba(197, 160, 89, 0.3)' }}>
            MYTHVERSE
          </h1>

          <p>
            Ancient stories. Legendary characters. Hidden connections.
            Explore Indian mythology through the texts that carry its stories.
          </p>

          <div
            className="hero-actions"
            style={{ display: 'flex', gap: '1.5rem', justifyContent: 'center', marginTop: '2rem' }}
          >
            <a
              className="cta"
              href="#explore"
              style={{
                padding: '1rem 2rem',
                background: 'linear-gradient(135deg, #e6c875 0%, #c5a059 100%)',
                color: '#1a0d00',
                textDecoration: 'none',
                borderRadius: '6px',
                fontWeight: 'bold',
                letterSpacing: '1px',
                boxShadow: '0 4px 20px rgba(197, 160, 89, 0.5)',
              }}
            >
              EXPLORE THE MYTHVERSE <span style={{ marginLeft: '8px' }}>→</span>
            </a>

            <a
              className="secondary-cta"
              href="#characters"
              style={{
                padding: '1rem 2rem',
                background: 'rgba(20, 10, 5, 0.85)',
                color: '#e6c875',
                border: '1px solid rgba(197, 160, 89, 0.6)',
                textDecoration: 'none',
                borderRadius: '6px',
                fontWeight: 'bold',
                letterSpacing: '1px',
                backdropFilter: 'blur(8px)',
                boxShadow: '0 4px 20px rgba(0, 0, 0, 0.4)',
              }}
            >
              MEET THE LEGENDS
            </a>
          </div>
        </div>

        <div className="scroll-indicator">DISCOVER BELOW · ↓</div>
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

          <div
            className="explore-grid"
            style={{
              display: 'grid',
              gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))',
              gap: '1.5rem',
              marginTop: '3rem',
            }}
          >
            <article
              className="explore-card"
              style={{
                background:
                  'linear-gradient(180deg, rgba(40,20,10,0.6) 0%, rgba(20,10,5,0.8) 100%)',
                padding: '2.5rem 1.5rem',
                borderRadius: '12px',
                border: '1px solid rgba(197, 160, 89, 0.15)',
                textAlign: 'center',
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center',
                gap: '1rem',
              }}
            >
              <div
                style={{
                  width: '50px',
                  height: '50px',
                  borderRadius: '50%',
                  background: 'rgba(197, 160, 89, 0.1)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  color: '#c5a059',
                  fontSize: '1.5rem',
                }}
              >
                📖
              </div>
              <h3 style={{ margin: 0, color: '#c5a059', letterSpacing: '2px' }}>READ</h3>
              <p style={{ margin: 0, color: '#a09070', lineHeight: '1.6', fontSize: '0.95rem' }}>
                Explore chapters and original translated passages directly from the ancient source texts.
              </p>
            </article>

            <article
              className="explore-card"
              style={{
                background:
                  'linear-gradient(180deg, rgba(40,20,10,0.6) 0%, rgba(20,10,5,0.8) 100%)',
                padding: '2.5rem 1.5rem',
                borderRadius: '12px',
                border: '1px solid rgba(197, 160, 89, 0.15)',
                textAlign: 'center',
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center',
                gap: '1rem',
              }}
            >
              <div
                style={{
                  width: '50px',
                  height: '50px',
                  borderRadius: '50%',
                  background: 'rgba(197, 160, 89, 0.1)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  color: '#c5a059',
                  fontSize: '1.5rem',
                }}
              >
                ✨
              </div>
              <h3 style={{ margin: 0, color: '#c5a059', letterSpacing: '2px' }}>DISCOVER</h3>
              <p style={{ margin: 0, color: '#a09070', lineHeight: '1.6', fontSize: '0.95rem' }}>
                Find characters, uncover their hidden aliases, and pinpoint important moments inside the stories.
              </p>
            </article>

            <article
              className="explore-card"
              style={{
                background:
                  'linear-gradient(180deg, rgba(40,20,10,0.6) 0%, rgba(20,10,5,0.8) 100%)',
                padding: '2.5rem 1.5rem',
                borderRadius: '12px',
                border: '1px solid rgba(197, 160, 89, 0.15)',
                textAlign: 'center',
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center',
                gap: '1rem',
              }}
            >
              <div
                style={{
                  width: '50px',
                  height: '50px',
                  borderRadius: '50%',
                  background: 'rgba(197, 160, 89, 0.1)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  color: '#c5a059',
                  fontSize: '1.5rem',
                }}
              >
                🔗
              </div>
              <h3 style={{ margin: 0, color: '#c5a059', letterSpacing: '2px' }}>CONNECT</h3>
              <p style={{ margin: 0, color: '#a09070', lineHeight: '1.6', fontSize: '0.95rem' }}>
                Follow dynamic character networks, relationships, and major events across the mythology.
              </p>
            </article>

            <article
              className="explore-card"
              style={{
                background:
                  'linear-gradient(180deg, rgba(40,20,10,0.6) 0%, rgba(20,10,5,0.8) 100%)',
                padding: '2.5rem 1.5rem',
                borderRadius: '12px',
                border: '1px solid rgba(197, 160, 89, 0.15)',
                textAlign: 'center',
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center',
                gap: '1rem',
              }}
            >
              <div
                style={{
                  width: '50px',
                  height: '50px',
                  borderRadius: '50%',
                  background: 'rgba(197, 160, 89, 0.1)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  color: '#c5a059',
                  fontSize: '1.5rem',
                }}
              >
                🧭
              </div>
              <h3 style={{ margin: 0, color: '#c5a059', letterSpacing: '2px' }}>EXPLORE</h3>
              <p style={{ margin: 0, color: '#a09070', lineHeight: '1.6', fontSize: '0.95rem' }}>
                Jump from one epic to another and discover how the pieces of the Mythverse fit together.
              </p>
            </article>
          </div>
        </div>
      </section>

      {/* ========================================================
          SOURCES
      ======================================================== */}

      <section className="section dark" id="sources">
        <div className="container">
          <div className="section-title reveal">
            <div className="eyebrow">THE LIBRARY</div>

            <h2>Explore the Sources</h2>

            <p>
              MYTHVERSE is designed to grow. Select any text below to enter its world,
              filter characters, and view its narrative graph.
            </p>
          </div>

          <div className="source-grid">
            {sources.map((source, index) => {
              const isSelected = activeSourceFilter === source.id
              return (
                <article
                  key={source.id}
                  className={`source-card-large active-source ${isSelected ? 'selected-source-card' : ''}`}
                  style={{
                    backgroundColor: isSelected
                      ? 'rgba(60, 40, 15, 0.7)'
                      : index % 2 === 0
                        ? 'rgba(40, 20, 10, 0.4)'
                        : 'rgba(20, 30, 20, 0.4)',
                    border: isSelected
                      ? '1px solid #c5a059'
                      : '1px solid rgba(197, 160, 89, 0.2)',
                    boxShadow: isSelected
                      ? '0 0 25px rgba(197, 160, 89, 0.35)'
                      : 'none',
                    transition: 'all 0.3s ease',
                  }}
                >
                  <div className="source-art">
                    <span className="source-symbol">{index % 2 === 0 ? '◈' : '✧'}</span>
                  </div>

                  <div className="source-content">
                    <div className="source-label">
                      {isSelected ? 'CURRENTLY VIEWING' : 'AVAILABLE SOURCE'}
                    </div>
                    <h3>{source.title}</h3>
                    <p>
                      {source.author ? `By ${source.author}. ` : ''}
                      {source.translator ? `Translated by ${source.translator}. ` : ''}
                      Explore characters, chapters, and events from this dataset.
                    </p>

                    <div style={{ display: 'flex', gap: '1rem', marginTop: '1rem', flexWrap: 'wrap' }}>
                      <button
                        onClick={() => {
                          setActiveSourceFilter(source.id)
                          setSelectedSourceId(source.id)
                          document.getElementById('characters').scrollIntoView({ behavior: 'smooth' })
                        }}
                        className="source-link"
                        style={{
                          background: isSelected ? '#c5a059' : 'none',
                          color: isSelected ? '#1a0d00' : '#c5a059',
                          fontWeight: 'bold',
                          border: isSelected ? 'none' : '1px solid rgba(197, 160, 89, 0.4)',
                          borderRadius: '4px',
                          cursor: 'pointer',
                          padding: '6px 14px',
                          transition: 'all 0.2s ease',
                        }}
                      >
                        {isSelected ? '✓ VIEWING CHARACTERS' : 'EXPLORE CHARACTERS →'}
                      </button>

                      <button
                        onClick={() => {
                          setActiveSourceFilter(source.id)
                          setSelectedSourceId(source.id)
                          document.getElementById('connections').scrollIntoView({ behavior: 'smooth' })
                        }}
                        className="source-link"
                        style={{
                          background: 'none',
                          color: '#a09070',
                          border: '1px solid rgba(160, 144, 112, 0.3)',
                          borderRadius: '4px',
                          cursor: 'pointer',
                          padding: '6px 14px',
                          fontSize: '0.85rem',
                        }}
                      >
                        VIEW GRAPH ↗
                      </button>
                    </div>
                  </div>
                </article>
              )
            })}
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

            <h2>
              {activeSourceObj
                ? `Characters in ${activeSourceObj.title}`
                : 'Meet the Characters'}
            </h2>

            <p>
              {activeSourceObj
                ? `Viewing characters who appear in ${activeSourceObj.title}. Mentions and relationships are scoped to this text.`
                : 'These characters are loaded from your PostgreSQL database through the existing FastAPI backend.'}
            </p>
          </div>

          {/* Active Source Scope Filter Chip */}
          {activeSourceObj && (
            <div
              style={{
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
                padding: '0.85rem 1.25rem',
                marginBottom: '1.5rem',
                backgroundColor: 'rgba(197, 160, 89, 0.1)',
                border: '1px solid rgba(197, 160, 89, 0.35)',
                borderRadius: '8px',
                flexWrap: 'wrap',
                gap: '10px',
              }}
            >
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                <span style={{ color: '#c5a059', fontSize: '1.1rem' }}>◈</span>
                <span style={{ color: '#f3e5ab', fontSize: '0.95rem' }}>
                  Filtered by source: <strong>{activeSourceObj.title}</strong>
                </span>
              </div>
              <button
                onClick={() => setActiveSourceFilter(null)}
                style={{
                  background: 'rgba(255, 100, 100, 0.15)',
                  color: '#ff9999',
                  border: '1px solid rgba(255, 100, 100, 0.3)',
                  padding: '5px 12px',
                  borderRadius: '4px',
                  cursor: 'pointer',
                  fontSize: '0.85rem',
                  letterSpacing: '0.5px',
                  transition: 'background 0.2s ease',
                }}
              >
                ✕ Clear Source Filter (Show All)
              </button>
            </div>
          )}

          <div className="character-toolbar">
            <input
              className="character-search"
              type="search"
              placeholder={
                activeSourceObj
                  ? `Search characters within ${activeSourceObj.title}...`
                  : 'Search characters, aliases or stories...'
              }
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
                {activeSourceObj
                  ? `No characters found for this search in ${activeSourceObj.title}.`
                  : 'No characters match your search.'}
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
                    <div
                      className="portrait"
                      style={{ background: getGradient(character.name || '') }}
                    >
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

            <h2>
              {activeSourceObj
                ? `${activeSourceObj.title} Network`
                : 'Every story is connected.'}
            </h2>

            <p>
              {activeSourceObj
                ? `Showing co-occurrence graph of characters who interact inside ${activeSourceObj.title}.`
                : 'A character can have many names. A character can appear in many chapters. Events connect people, places and stories.'}
            </p>
          </div>

          <div
            className="connection-map"
            style={{
              height: '600px',
              width: '100%',
              backgroundColor: 'rgba(0,0,0,0.4)',
              borderRadius: '12px',
              border: '1px solid rgba(255, 215, 0, 0.1)',
              overflow: 'hidden',
              display: 'flex',
              justifyContent: 'center',
              cursor: 'grab',
            }}
          >
            {graphData.nodes.length > 0 ? (
              <ForceGraph2D
                graphData={graphData}
                nodeLabel="name"
                nodeColor={() => '#c5a059'}
                nodeRelSize={6}
                linkColor={() => 'rgba(197, 160, 89, 0.2)'}
                width={1000}
                height={600}
                onNodeClick={(node) => {
                  const match = characters.find(
                    (c) => c.name.toLowerCase() === node.name?.toLowerCase(),
                  )
                  if (match) openCharacter(match)
                }}
              />
            ) : (
              <div style={{ padding: '2rem', color: '#c5a059' }}>
                Loading Mythverse connections...
              </div>
            )}
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
        <div
          className="brand"
          style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            gap: '10px',
          }}
        >
          <img
            src="/logo.png"
            alt="Mythverse Emblem"
            style={{
              width: '24px',
              height: '24px',
              borderRadius: '50%',
              objectFit: 'cover',
              border: '1px solid rgba(197, 160, 89, 0.5)',
            }}
          />
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
                      <div
                        style={{
                          display: 'flex',
                          alignItems: 'center',
                          gap: '12px',
                          flexWrap: 'wrap',
                        }}
                      >
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
                          {sources.map((source) => {
                            const count = story.source_mention_counts
                              ? story.source_mention_counts[String(source.id)] || 0
                              : null
                            return (
                              <option key={source.id} value={source.id}>
                                {source.title}
                                {source.translator ? ` — ${source.translator}` : ''}
                                {source.year ? ` (${source.year})` : ''}
                                {count !== null
                                  ? count === 0
                                    ? ' · No mentions'
                                    : ` · ${count} mentions`
                                  : ''}
                              </option>
                            )
                          })}
                        </select>

                        {!loadingMentions && totalMentionsAllSources === 0 && (
                          <span
                            className="alias-pill"
                            style={{ opacity: 0.8, cursor: 'default' }}
                          >
                            No mentions in any script
                          </span>
                        )}

                        {!loadingMentions &&
                          totalMentionsAllSources > 0 &&
                          currentSourceMentions === 0 && (
                            <span
                              className="alias-pill"
                              style={{ opacity: 0.8, cursor: 'default' }}
                            >
                              No mentions in this script
                            </span>
                          )}
                      </div>

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
                          {story.source.year ? ` · ${story.source.year}` : ''}
                          {story.source.language ? ` · ${story.source.language}` : ''}
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

                    {/* MAJOR EVENTS */}
                    <div className="major">
                      <div className="major-heading">
                        <h3>MAJOR EVENTS</h3>
                        <span>{story.events?.length || 0} events</span>
                      </div>

                      {!story.events || story.events.length === 0 ? (
                        <div className="state-box">
                          No story events have been added for this character in
                          this source yet.
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
                                  <summary>READ ORIGINAL PASSAGE</summary>

                                  <div className="source-text">
                                    {event.paragraphs?.map((paragraph) => (
                                      <div
                                        className="source-paragraph"
                                        key={paragraph.number}
                                      >
                                        <span>¶ {paragraph.number}</span>
                                        <p>{paragraph.content}</p>
                                      </div>
                                    ))}
                                  </div>
                                </details>
                              </div>
                            </article>
                          ))}
                        </div>
                      )}
                    </div>

                    {/* MENTIONS SECTION */}
                    <section className="mentions-section">
                      <div className="major-heading mentions-heading">
                        <h3>MENTIONS IN THIS SOURCE</h3>
                        <span>
                          {mentions.length} of {mentionsTotal} mentions
                        </span>
                      </div>

                      <p className="mentions-intro">
                        Explore this character's recorded appearances in the
                        selected text, with passages and source locations
                        preserved.
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
                            No recorded mentions were found for this character
                            in this source.
                          </div>
                        )}

                      {Object.entries(mentionsBySource).map(
                        ([sourceId, group]) => (
                          <section className="mention-source-group" key={sourceId}>
                            <div className="mention-source-heading">
                              <h4>{group.source.title || 'Unknown source'}</h4>
                              <p>
                                {group.source.translator ||
                                  group.source.author ||
                                  'Translator not specified'}
                                {group.source.year ? ` · ${group.source.year}` : ''}
                                {group.source.language ? ` · ${group.source.language}` : ''}
                              </p>
                              {group.source.url && (
                                <a
                                  href={group.source.url}
                                  target="_blank"
                                  rel="noreferrer"
                                >
                                  VIEW SOURCE ↗
                                </a>
                              )}
                            </div>

                            <div className="mention-list">
                              {group.paragraphs.map((paragraph) => {
                                const mention = paragraph.mention
                                const matchedNames = [
                                  ...new Set(
                                    paragraph.mentions
                                      .map((item) => item.mentioned_text)
                                      .filter(Boolean),
                                  ),
                                ]

                                return (
                                  <article
                                    className="mention-card"
                                    key={paragraph.key}
                                  >
                                    <div className="mention-meta">
                                      {mention.book?.name
                                        ? `${mention.book.name} · `
                                        : ''}
                                      {mention.chapter?.number != null
                                        ? `Chapter ${mention.chapter.number}`
                                        : 'Chapter'}
                                      {mention.chapter?.title
                                        ? ` · ${mention.chapter.title}`
                                        : ''}
                                      {mention.paragraph_number != null
                                        ? ` · Paragraph ${mention.paragraph_number}`
                                        : ''}
                                    </div>

                                    <div className="mention-matched-name">
                                      Matched name
                                      {matchedNames.length === 1 ? '' : 's'}:{' '}
                                      <strong>
                                        {matchedNames.join(', ') ||
                                          'Name unavailable'}
                                      </strong>
                                      <span className="mention-occurrence-count">
                                        {' '}
                                        · {paragraph.mentions.length} occurrence
                                        {paragraph.mentions.length === 1 ? '' : 's'}
                                      </span>
                                    </div>

                                    <p className="mention-passage">
                                      {mention.passage ||
                                        'Original passage unavailable.'}
                                    </p>

                                    {mention.chapter?.url && (
                                      <a
                                        className="mention-chapter-link"
                                        href={mention.chapter.url}
                                        target="_blank"
                                        rel="noreferrer"
                                      >
                                        OPEN CHAPTER ↗
                                      </a>
                                    )}
                                  </article>
                                )
                              })}
                            </div>
                          </section>
                        ),
                      )}

                      {loadingMentions && mentions.length > 0 && (
                        <div className="state-box">Loading more mentions...</div>
                      )}

                      {mentionsError && mentions.length > 0 && (
                        <button
                          className="mentions-load-more"
                          type="button"
                          onClick={() =>
                            loadCharacterMentions(
                              selectedCharacter.id,
                              mentionsOffset,
                              selectedSourceId,
                            )
                          }
                          disabled={loadingMentions}
                        >
                          RETRY LOADING MENTIONS
                        </button>
                      )}

                      {!mentionsError && mentionsOffset < mentionsTotal && (
                        <button
                          className="mentions-load-more"
                          type="button"
                          onClick={() =>
                            loadCharacterMentions(
                              selectedCharacter.id,
                              mentionsOffset,
                              selectedSourceId,
                            )
                          }
                          disabled={loadingMentions}
                        >
                          {loadingMentions
                            ? 'LOADING...'
                            : `LOAD MORE MENTIONS (${mentionsTotal - mentionsOffset} remaining)`}
                        </button>
                      )}
                    </section>
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
