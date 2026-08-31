import { useEffect, useState } from 'react'
import './App.css'

const API_URL = 'http://127.0.0.1:8000'

const kaandas = [
  {
    name: 'Bāla Kāṇḍa',
    description:
      "Rāma's early life, his education, Viśvāmitra's journey, and his marriage to Sītā.",
    events: [
      "Rāma's birth",
      "Viśvāmitra's journey",
      "Sītā's marriage",
    ],
  },
  {
    name: 'Ayodhyā Kāṇḍa',
    description:
      "The succession crisis transforms Rāma's life. Kaikeyī's demands lead to exile, while Bharata refuses the throne.",
    events: [
      'Coronation interrupted',
      'Fourteen-year exile',
      "Bharata's vow",
    ],
  },
  {
    name: 'Araṇya Kāṇḍa',
    description:
      "Life in the forest ends in abduction. The encounters there set the central conflict in motion.",
    events: [
      "Śūrpaṇakhā's encounter",
      'Golden deer',
      "Sītā's abduction",
    ],
  },
  {
    name: 'Kiṣkindhā Kāṇḍa',
    description:
      'Rāma meets Hanumān and Sugrīva. Their alliance brings the Vanara forces into the search for Sītā.',
    events: [
      'Hanumān meets Rāma',
      "Sugrīva's alliance",
      'Search begins',
    ],
  },
  {
    name: 'Sundara Kāṇḍa',
    description:
      'Hanumān crosses the ocean, finds Sītā in Laṅkā, delivers Rāma\'s message and returns with hope.',
    events: [
      'Ocean crossing',
      'Aśoka grove',
      'Laṅkā mission',
    ],
  },
  {
    name: 'Yuddha Kāṇḍa',
    description:
      "The search becomes war. The bridge to Laṅkā, the battles and Rāvaṇa's defeat bring the conflict to its decisive end.",
    events: [
      'Bridge to Laṅkā',
      'Great battle',
      'Rāvaṇa falls',
    ],
  },
  {
    name: 'Uttara Kāṇḍa',
    description:
      "The later chapter explores Rāma's reign, the burdens of kingship and the later story surrounding Sītā.",
    events: [
      "Rāma's reign",
      'Lava and Kuśa',
      "Sītā's later story",
    ],
  },
]

function App() {
  const [characters, setCharacters] = useState([])
  const [selectedCharacter, setSelectedCharacter] = useState(null)
  const [story, setStory] = useState(null)

  const [loadingCharacters, setLoadingCharacters] = useState(true)
  const [loadingStory, setLoadingStory] = useState(false)

  const [error, setError] = useState(null)
  const [search, setSearch] = useState('')

  const [modalOpen, setModalOpen] = useState(false)

  // ============================================================
  // LOAD CHARACTERS
  // ============================================================

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
        setError('Could not connect to the Ramayana API.')
        setLoadingCharacters(false)
      })
  }, [])

  // ============================================================
  // OPEN CHARACTER
  // ============================================================

  const openCharacter = async (character) => {
    setSelectedCharacter(character)
    setStory(null)
    setError(null)
    setLoadingStory(true)
    setModalOpen(true)

    try {
      const response = await fetch(
        `${API_URL}/characters/${character.id}/story`,
      )

      if (!response.ok) {
        throw new Error('Failed to fetch character story')
      }

      const data = await response.json()
      setStory(data)
    } catch (err) {
      console.error(err)
      setError('Could not load this character’s story.')
    } finally {
      setLoadingStory(false)
    }
  }

  // ============================================================
  // OPEN CHARACTER BY NAME
  // ============================================================

  const openCharacterByName = (name) => {
    const character = characters.find(
      (item) => item.name === name,
    )

    if (character) {
      openCharacter(character)
    }
  }

  // ============================================================
  // CLOSE MODAL
  // ============================================================

  const closeModal = () => {
    setModalOpen(false)
  }

const changeCharacter = (direction) => {
  if (!selectedCharacter || characters.length === 0) {
    return
  }

  const currentIndex = characters.findIndex(
    (character) => character.id === selectedCharacter.id,
  )

  if (currentIndex === -1) {
    return
  }

  const nextIndex =
    (currentIndex + direction + characters.length) %
    characters.length

  openCharacter(characters[nextIndex])
}

  // ============================================================
  // ESCAPE KEY
  // ============================================================

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

  // ============================================================
  // FILTER CHARACTERS
  // ============================================================

const normalizeText = (text) => {
  return text
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .replace(/sh/g, 's')
    .replace(/ph/g, 'f')
    .replace(/bh/g, 'b')
    .replace(/th/g, 't')
    .replace(/dh/g, 'd')
}

const filteredCharacters = characters.filter((character) => {
  const query = normalizeText(search.trim())

  if (!query) {
    return true
  }

  return normalizeText(character.name).includes(query)
})

  return (
    <div className="app">
      {/* ======================================================
          NAVIGATION
      ====================================================== */}

      <nav className="nav">
        <a className="brand" href="#home">
          THE RAMAYANA
        </a>

        <div className="navlinks">
          <a href="#story">STORY</a>
          <a href="#journey">KĀṆḌAS</a>
          <a href="#characters">CHARACTERS</a>
          <a href="#about">ABOUT</a>
        </div>

        <button className="menu-button" aria-label="Menu">
          ☰
        </button>
      </nav>

      {/* ======================================================
          HERO
      ====================================================== */}

      <header className="hero" id="home">
        <div className="mandala" />

        <div className="hero-content">
          <div className="kicker">
            AN INTERACTIVE CHRONICLE
          </div>

          <h1>RAMAYANA</h1>

          <p>
            A cinematic journey through duty, devotion,
            exile, war and the triumph of dharma.
          </p>

          <a className="cta" href="#story">
            ENTER THE EPIC <span>→</span>
          </a>
        </div>

        <div className="scroll-indicator">
          SCROLL TO BEGIN · ↓
        </div>
      </header>

      {/* ======================================================
          STORY INTRO
      ====================================================== */}

      <section className="section" id="story">
        <div className="container">
          <div className="section-title reveal">
            <div className="eyebrow">
              THE EPIC
            </div>

            <h2>
              A Story That Changed Everything
            </h2>

            <p>
              Follow the lives and choices that shape
              one of India's most enduring epics.
            </p>
          </div>

          <div className="story-intro reveal">
            <div className="story-copy">
              <p className="dropcap">
                The Ramayana follows{' '}
                <button
                  className="tag-button"
                  onClick={() => openCharacterByName('Rāma')}
                >
                  Rāma
                </button>
                , prince of Ayodhyā, whose commitment
                to truth and duty leads him from royal
                life into exile. With{' '}
                <button
                  className="tag-button"
                  onClick={() => openCharacterByName('Sītā')}
                >
                  Sītā
                </button>{' '}
                and{' '}
                <button
                  className="tag-button"
                  onClick={() =>
                    openCharacterByName('Lakṣmaṇa')
                  }
                >
                  Lakṣmaṇa
                </button>
                , he enters the forests, where a chain
                of encounters eventually brings him into
                conflict with the wider forces of Laṅkā.
              </p>

              <p>
                What begins as a family crisis becomes
                a vast journey involving kings, sages,
                warriors, allies and kingdoms. The story
                moves through separation, search, alliance
                and war before returning to the question
                at its heart: what does it mean to live
                by one's duty?
              </p>
            </div>

            <div className="ornament">
              <div className="quote">
                “Every choice becomes a path;
                every path changes the epic.”
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ======================================================
          KAANDAS
      ====================================================== */}

      <section className="section dark" id="journey">
        <div className="container">
          <div className="section-title reveal">
            <div className="eyebrow">
              THE JOURNEY
            </div>

            <h2>
              Seven Kāṇḍas
            </h2>

            <p>
              The major turning points, arranged as
              a navigable story timeline.
            </p>
          </div>

          <div className="timeline">
            {kaandas.map((kaanda, index) => (
              <div
                className={`kaanda reveal ${
                  index % 2 === 1 ? 'reverse' : ''
                }`}
                key={kaanda.name}
              >
                <div className="kcard">
                  <h3>{kaanda.name}</h3>

                  <p>{kaanda.description}</p>

                  <div className="events">
                    {kaanda.events.map((event) => (
                      <span
                        className="event-pill"
                        key={event}
                      >
                        {event}
                      </span>
                    ))}
                  </div>
                </div>

                <span className="knode" />
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ======================================================
          CHARACTERS
      ====================================================== */}

      <section className="section" id="characters">
        <div className="container">
          <div className="section-title reveal">
            <div className="eyebrow">
              THE PEOPLE
            </div>

            <h2>
              Characters of the Epic
            </h2>

            <p>
              Select any character to explore their
              background, major events and source passages.
            </p>
          </div>

          {/* SEARCH */}

          <div className="character-toolbar">
            <input
              className="character-search"
              type="search"
              placeholder="Search characters..."
              value={search}
              onChange={(event) =>
                setSearch(event.target.value)
              }
            />

            <span className="character-total">
              {filteredCharacters.length} of{' '}
              {characters.length}
            </span>
          </div>

          {loadingCharacters && (
            <div className="state-box">
              Loading characters...
            </div>
          )}

          {error && !loadingCharacters && (
            <div className="state-box error">
              {error}
            </div>
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
                    onClick={() =>
                      openCharacter(character)
                    }
                  >
                    <div className="portrait" >
			<div className="portrait" >
					{character.name.charAt(0)}
			</div>
		    </div>
                    <div className="character-info">
                      <div className="rank">
                        {String(index + 1).padStart(
                          2,
                          '0',
                        )}
                      </div>

                      <h3>{character.name}</h3>

                      <div className="role">
                        {character.description ||
                          'Character of the Ramayana'}
                      </div>

                      <span className="view">
                        VIEW CHARACTER →
                      </span>
                    </div>
                  </button>
                ))}
              </div>
            )}
        </div>
      </section>

      {/* ======================================================
          ABOUT
      ====================================================== */}

      <section className="section dark" id="about">
        <div className="container">
          <div className="section-title reveal">
            <div className="eyebrow">
              ABOUT THE EXPERIENCE
            </div>

            <h2>
              One Epic. Many Paths.
            </h2>

            <p>
              Explore the Ramayana through the
              perspectives of its characters, their
              turning points, and the passages that
              support each story.
            </p>
          </div>
        </div>
      </section>

      {/* ======================================================
          FOOTER
      ====================================================== */}

      <footer className="footer">
        <div className="brand">
          THE RAMAYANA
        </div>

        <p>
          An educational interactive prototype
        </p>
      </footer>

      {/* ======================================================
          CHARACTER MODAL
      ====================================================== */}

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
	    CHANGE CHARACTER
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
                <div className="eyebrow">
                  CHARACTER
                </div>

                <h2>
                  {selectedCharacter.name}
                </h2>

                <div className="modalrole">
                  {story?.profile?.role ||
                    selectedCharacter.description}
                </div>

                {loadingStory && (
                  <div className="state-box">
                    Loading character story...
                  </div>
                )}

                {error && (
                  <div className="state-box error">
                    {error}
                  </div>
                )}

                {story && !loadingStory && (
                  <>
                    {/* PROFILE */}

                    <div className="profile-section">
                      <h3>BACKGROUND</h3>

                      <p className="bio">
                        {story.profile?.background ||
                          'Background information is not available yet.'}
                      </p>
                    </div>

                    {/* EVENTS */}

                    <div className="major">
                      <div className="major-heading">
                        <h3>
                          MAJOR EVENTS
                        </h3>

                        <span>
                          {story.events.length} events
                        </span>
                      </div>

                      {story.events.length === 0 ? (
                        <div className="state-box">
                          No story events have been
                          added for this character yet.
                        </div>
                      ) : (
                        <div className="modal-events">
                          {story.events.map(
                            (event, index) => (
                              <article
                                className="modal-event"
                                key={event.id}
                              >
                                <div className="modal-event-number">
                                  {String(
                                    index + 1,
                                  ).padStart(2, '0')}
                                </div>

                                <div>
                                  <div className="event-meta">
                                    Chapter{' '}
                                    {
                                      event.chapter
                                        .number
                                    }
                                    {' · '}
                                    Paragraphs{' '}
                                    {
                                      event.paragraph_start
                                    }
                                    –
                                    {
                                      event.paragraph_end
                                    }
                                    {' · '}
                                    Importance{' '}
                                    {
                                      event.importance
                                    }
                                    /5
                                  </div>

                                  <h4>
                                    {event.title}
                                  </h4>

                                  <p className="event-summary">
                                    {event.summary}
                                  </p>

                                  <details>
                                    <summary>
                                      READ ORIGINAL PASSAGE
                                    </summary>

                                    <div className="source-text">
                                      {event.paragraphs.map(
                                        (paragraph) => (
                                          <div
                                            className="source-paragraph"
                                            key={
                                              paragraph.number
                                            }
                                          >
                                            <span>
                                              ¶{' '}
                                              {
                                                paragraph.number
                                              }
                                            </span>

                                            <p>
                                              {
                                                paragraph.content
                                              }
                                            </p>
                                          </div>
                                        ),
                                      )}
                                    </div>
                                  </details>
                                </div>
                              </article>
                            ),
                          )}
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
