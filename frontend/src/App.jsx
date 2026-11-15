import { useEffect, useMemo, useRef, useState } from 'react'
import './App.css'
import ForceGraph2D from 'react-force-graph-2d'

const API_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8000'

// ------------------------------------------------------------
// TEAMMATE'S 2D CONNECTION GRAPH HELPERS & ARCHETYPE REFINER
// ------------------------------------------------------------
const GROUP_META = {
  deity: { label: 'Deities', color: '#5bb8ff' },
  royal: { label: 'Royals', color: '#ffd166' },
  sage: { label: 'Sages', color: '#4ade9a' },
  warrior: { label: 'Warriors', color: '#ff7a59' },
  asura: { label: 'Asuras & Rakshasas', color: '#ff4d6d' },
  celestial: { label: 'Celestials', color: '#b794f6' },
  creature: { label: 'Creatures', color: '#f59e0b' },
  consort: { label: 'Queens & Consorts', color: '#f472b6' },
  other: { label: 'Others', color: '#d8b77c' },
}

const GROUP_KEYWORDS = [
  ['celestial', /apsara|gandharva|yaksha|kinnara|naga|vidyadhara|siddha|charana|rishi-?kanya|devata/i],
  ['asura', /asura|rakshasa|raksasa|daitya|danava|demon|ravana|kumbhakarna|indrajit|maricha|kamsa/i],
  ['creature', /vanara|monkey|bear|eagle|vulture|garuda|jatayu|sampati|elephant|horse|serpent|snake|cow|bird|lion|tiger|ox|bull|deer/i],
  ['consort', /queen|devi|sita|draupadi|kaikeyi|kausalya|sumitra|mandodari|tara|gandhari|kunti|madri|subhadra|uttara|rukmini|satyabhama/i],
  ['warrior', /warrior|archer|general|commander|senapati|bhima|arjuna|karna|drona|bhishma|abhimanyu|lakshmana|bharata|shatrughna|hanuman|angada|nala|nila/i],
]

const refineGroup = (node) => {
  const base = node?.group || 'other'
  if (base !== 'other') return GROUP_META[base] ? base : 'other'
  for (const [group, pattern] of GROUP_KEYWORDS) {
    if (pattern.test(node?.name || '')) return group
  }
  return 'other'
}

const DEFAULT_TOP_N = 40
const MAX_LABELLED_NODES = 14

const linkEndId = (end) => (end && typeof end === 'object' ? end.id : end)

const autoMinWeight = (nodes, links, topN = DEFAULT_TOP_N, maxLinks = 110) => {
  const top = new Set(
    [...nodes]
      .sort((a, b) => (b.mention_count || 0) - (a.mention_count || 0))
      .slice(0, topN)
      .map((n) => n.id)
  )
  const weights = links
    .filter((l) => top.has(linkEndId(l.source)) && top.has(linkEndId(l.target)))
    .map((l) => l.weight || 1)
    .sort((a, b) => b - a)
  return weights.length <= maxLinks ? 1 : weights[maxLinks - 1]
}

const chipStyle = (active, color = '#d8b77c') => ({
  display: 'inline-flex',
  alignItems: 'center',
  gap: '8px',
  padding: '8px 14px',
  borderRadius: '6px',
  cursor: 'pointer',
  fontSize: '10px',
  fontWeight: 700,
  letterSpacing: '0.18em',
  background: active ? 'rgba(216, 183, 124, 0.14)' : 'transparent',
  color: active ? '#f2eee7' : '#8c929e',
  border: `1px solid ${active ? color : 'rgba(218, 188, 133, 0.25)'}`,
  transition: '0.2s ease',
})

const hexToRgba = (hex, alpha = 1) => {
  if (!hex || typeof hex !== 'string') return `rgba(216, 183, 124, ${alpha})`
  let clean = hex.replace('#', '')
  if (clean.length === 3) {
    clean = clean
      .split('')
      .map((c) => c + c)
      .join('')
  }
  const num = parseInt(clean, 16)
  if (Number.isNaN(num)) return `rgba(216, 183, 124, ${alpha})`
  const r = (num >> 16) & 255
  const g = (num >> 8) & 255
  const b = num & 255
  return `rgba(${r}, ${g}, ${b}, ${alpha})`
}

const shadeHex = (hex, percent) => {
  if (!hex || typeof hex !== 'string' || !hex.startsWith('#')) return hex
  let clean = hex.replace('#', '')
  if (clean.length === 3) {
    clean = clean
      .split('')
      .map((c) => c + c)
      .join('')
  }
  const num = parseInt(clean, 16)
  if (Number.isNaN(num)) return hex
  const r = Math.min(255, Math.max(0, ((num >> 16) & 255) + Math.round(255 * (percent / 100))))
  const g = Math.min(255, Math.max(0, ((num >> 8) & 255) + Math.round(255 * (percent / 100))))
  const b = Math.min(255, Math.max(0, (num & 255) + Math.round(255 * (percent / 100))))
  return `rgb(${r}, ${g}, ${b})`
}

function App() {
  // Global Archive State
  const [sources, setSources] = useState([])
  const [allCharacters, setAllCharacters] = useState([])
  const [loadingArchive, setLoadingArchive] = useState(true)
  const [archiveError, setArchiveError] = useState(null)

  // Carousel & Search State (Home Page)
  const [activeSlideIndex, setActiveSlideIndex] = useState(0)
  const [archiveSearch, setArchiveSearch] = useState('')
  const [searchDropdownOpen, setSearchDropdownOpen] = useState(false)
  const trackRef = useRef(null)
  const ambientRef = useRef(null)
  const scrollTickingRef = useRef(false)

  // Selected Script Page State (Page 2: 3 Vertical Sections)
  const [selectedScript, setSelectedScript] = useState(null)
  const [scriptCharacters, setScriptCharacters] = useState([])
  const [scriptEvents, setScriptEvents] = useState([])
  const [scriptGraph, setScriptGraph] = useState({ nodes: [], links: [] })
  const [loadingScriptData, setLoadingScriptData] = useState(false)
  const [loadingEvents, setLoadingEvents] = useState(false)
  const [graphError, setGraphError] = useState(null)

  // Filters inside Selected Script Page
  const [eventFilter, setEventFilter] = useState('')
  const [chapterFilter, setChapterFilter] = useState('ALL')
  const [characterFilter, setCharacterFilter] = useState('')

  // Teammate's 2D Graph Interactive State
  const graphRef = useRef(null)
  const graphContainerRef = useRef(null)
  const fitDoneRef = useRef(false)
  const [graphWidth, setGraphWidth] = useState(920)
  const [graphTopN, setGraphTopN] = useState(DEFAULT_TOP_N)
  const [graphMinWeight, setGraphMinWeight] = useState(1)
  const [hiddenGroups, setHiddenGroups] = useState([])
  const [hoverNodeId, setHoverNodeId] = useState(null)
  const [selectedNodeId, setSelectedNodeId] = useState(null)
  const [hoverLink, setHoverLink] = useState(null)
  const [graphCurved, setGraphCurved] = useState(true)
  const [graphParticles, setGraphParticles] = useState(true)
  const [showLinkBadges, setShowLinkBadges] = useState(true)
  const [graphSearch, setGraphSearch] = useState('')
  const [graphSearchMiss, setGraphSearchMiss] = useState(false)

  // Character Dossier & Relations Modal State
  const [modalOpen, setModalOpen] = useState(false)
  const [selectedCharacter, setSelectedCharacter] = useState(null)
  const [characterStory, setCharacterStory] = useState(null)
  const [loadingStory, setLoadingStory] = useState(false)
  const [modalSourceId, setModalSourceId] = useState(null)
  const [previousModalSourceId, setPreviousModalSourceId] = useState(null)

  const padTwo = (n) => String(n ?? 0).padStart(2, '0')

  const normalizeText = (text) =>
    String(text || '')
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '')
      .toLowerCase()

  // ------------------------------------------------------------
  // 1. GPU-SCOPED COSMIC PARALLAX (SLEEPS WHEN MOUSE IS IDLE)
  // ------------------------------------------------------------
  useEffect(() => {
    let targetX = 0
    let targetY = 0
    let currentX = 0
    let currentY = 0
    let rafId = null
    let isRunning = false

    const animateCosmic = () => {
      const dx = targetX - currentX
      const dy = targetY - currentY

      currentX += dx * 0.06
      currentY += dy * 0.06

      if (ambientRef.current) {
        ambientRef.current.style.setProperty('--mouse-x', `${(currentX * 22).toFixed(1)}px`)
        ambientRef.current.style.setProperty('--mouse-y', `${(currentY * 22).toFixed(1)}px`)
      }

      if (Math.abs(dx) > 0.002 || Math.abs(dy) > 0.002) {
        rafId = requestAnimationFrame(animateCosmic)
      } else {
        isRunning = false
      }
    }

    const handleMouseMove = (e) => {
      targetX = (e.clientX / window.innerWidth - 0.5) * 2
      targetY = (e.clientY / window.innerHeight - 0.5) * 2
      if (!isRunning) {
        isRunning = true
        rafId = requestAnimationFrame(animateCosmic)
      }
    }

    window.addEventListener('mousemove', handleMouseMove, { passive: true })
    return () => {
      window.removeEventListener('mousemove', handleMouseMove)
      if (rafId) cancelAnimationFrame(rafId)
    }
  }, [])

  // ------------------------------------------------------------
  // 2. RESPONSIVE GRAPH CONTAINER SIZING
  // ------------------------------------------------------------
  useEffect(() => {
    const el = graphContainerRef.current
    if (!el) return undefined
    const update = () => setGraphWidth(Math.max(Math.floor(el.clientWidth), 280))
    update()
    const observer = new ResizeObserver(update)
    observer.observe(el)
    window.addEventListener('resize', update)
    return () => {
      observer.disconnect()
      window.removeEventListener('resize', update)
    }
  }, [selectedScript])

  // ------------------------------------------------------------
  // 3. INITIAL LOAD: SOURCES & GLOBAL CHARACTERS
  // ------------------------------------------------------------
  useEffect(() => {
    let mounted = true
    setLoadingArchive(true)
    setArchiveError(null)

    Promise.all([
      fetch(`${API_URL}/sources`).then((r) => {
        if (!r.ok) throw new Error('Failed to load sources')
        return r.json()
      }),
      fetch(`${API_URL}/characters`)
        .then((r) => (r.ok ? r.json() : []))
        .catch(() => []),
    ])
      .then(([sourcesData, charsData]) => {
        if (!mounted) return
        setSources(Array.isArray(sourcesData) ? sourcesData : [])
        setAllCharacters(Array.isArray(charsData) ? charsData : [])
        setLoadingArchive(false)
      })
      .catch((err) => {
        console.error('Archive load error:', err)
        if (!mounted) return
        setArchiveError(
          'Could not connect to the Mythverse FastAPI backend. Ensure uvicorn is running on port 8000.'
        )
        setLoadingArchive(false)
      })

    return () => {
      mounted = false
    }
  }, [])

  // ------------------------------------------------------------
  // 4. FILTERED SCRIPTS FOR THE HORIZONTAL CAROUSEL
  // ------------------------------------------------------------
  const filteredSources = useMemo(() => {
    const q = normalizeText(archiveSearch.trim())
    if (!q) return sources

    return sources.filter((s) => {
      const matchScript = [s.title, s.author, s.translator, s.year].some((val) =>
        normalizeText(val).includes(q)
      )
      if (matchScript) return true

      return allCharacters.some(
        (c) =>
          Array.isArray(c.source_ids) &&
          c.source_ids.includes(s.id) &&
          [c.name, ...(c.aliases || [])].some((n) => normalizeText(n).includes(q))
      )
    })
  }, [sources, allCharacters, archiveSearch])

  const matchingCharactersInSearch = useMemo(() => {
    const q = normalizeText(archiveSearch.trim())
    if (!q || q.length < 2) return []
    return allCharacters
      .filter((c) =>
        [c.name, ...(c.aliases || [])].some((n) => normalizeText(n).includes(q))
      )
      .slice(0, 6)
  }, [allCharacters, archiveSearch])

  const handleTrackScroll = () => {
    if (scrollTickingRef.current) return
    scrollTickingRef.current = true

    requestAnimationFrame(() => {
      scrollTickingRef.current = false
      const track = trackRef.current
      if (!track || filteredSources.length === 0) return
      const cards = track.querySelectorAll('.myth-slide-card')
      if (!cards.length) return

      const center = track.scrollLeft + track.clientWidth / 2
      let bestIdx = 0
      let minDistance = Infinity

      cards.forEach((card, i) => {
        const cardCenter = card.offsetLeft + card.offsetWidth / 2
        const dist = Math.abs(cardCenter - center)
        if (dist < minDistance) {
          minDistance = dist
          bestIdx = i
        }
      })

      setActiveSlideIndex((prev) => (prev === bestIdx ? prev : bestIdx))
    })
  }

  const scrollToSlide = (index) => {
    const track = trackRef.current
    if (!track || filteredSources.length === 0) return
    const clamped = Math.max(0, Math.min(index, filteredSources.length - 1))
    const cards = track.querySelectorAll('.myth-slide-card')
    if (cards[clamped]) {
      cards[clamped].scrollIntoView({ behavior: 'smooth', inline: 'center', block: 'nearest' })
    }
    setActiveSlideIndex(clamped)
  }

  // ------------------------------------------------------------
  // 5. OPEN A SCRIPT -> REDIRECT TO 3-SECTION VERTICAL PAGE
  // ------------------------------------------------------------
  const openScriptPage = async (source, initialCharacterToOpen = null) => {
    setSelectedScript(source)
    setEventFilter('')
    setChapterFilter('ALL')
    setCharacterFilter('')
    setScriptCharacters([])
    setScriptEvents([])
    setScriptGraph({ nodes: [], links: [] })
    setGraphError(null)
    setSelectedNodeId(null)
    setHoverNodeId(null)
    setHoverLink(null)
    setHiddenGroups([])
    setGraphTopN(DEFAULT_TOP_N)
    setGraphSearch('')
    setGraphSearchMiss(false)
    setLoadingScriptData(true)
    setLoadingEvents(true)
    setSearchDropdownOpen(false)

    window.scrollTo({ top: 0, behavior: 'smooth' })

    try {
      const [charsRes, graphRes] = await Promise.all([
        fetch(`${API_URL}/characters?source_id=${source.id}`).then((r) =>
          r.ok ? r.json() : []
        ),
        fetch(`${API_URL}/graph?source_id=${source.id}`)
          .then((r) => {
            if (!r.ok) throw new Error(`Graph request failed (${r.status})`)
            return r.json()
          })
          .catch((err) => {
            console.error('Failed to fetch graph data:', err)
            setGraphError('Could not load the connections graph.')
            return { nodes: [], links: [] }
          }),
      ])

      const validChars = Array.isArray(charsRes) ? charsRes : []
      setScriptCharacters(validChars)

      // Sanitize & refine graph data using teammate's logic
      const rawNodes = Array.isArray(graphRes?.nodes) ? graphRes.nodes : []
      const rawLinks = Array.isArray(graphRes?.links)
        ? graphRes.links
        : Array.isArray(graphRes?.edges)
          ? graphRes.edges
          : []
      const nodeIds = new Set(rawNodes.map((n) => n.id))
      const validLinks = rawLinks.filter(
        (l) => nodeIds.has(linkEndId(l.source)) && nodeIds.has(linkEndId(l.target))
      )
      const refinedNodes = rawNodes.map((n) => ({ ...n, group: refineGroup(n) }))

      setScriptGraph({ nodes: refinedNodes, links: validLinks })
      setGraphMinWeight(autoMinWeight(refinedNodes, validLinks))
      setLoadingScriptData(false)

      if (initialCharacterToOpen) {
        openCharacterModal(initialCharacterToOpen, source.id)
      }

      // Quick events seed
      const quickEventsMap = new Map()
      validChars.forEach((c) => {
        if (Array.isArray(c.event_titles)) {
          c.event_titles.forEach((title, idx) => {
            const summary = c.event_summaries?.[idx] || ''
            const key = `${normalizeText(title)}::${normalizeText(summary.slice(0, 60))}`
            if (title && !quickEventsMap.has(key)) {
              quickEventsMap.set(key, {
                id: `quick-${c.id}-${idx}`,
                title,
                summary,
                character_id: c.id,
                character_name: c.name,
                chapter: null,
                paragraph_start: null,
                paragraph_end: null,
                paragraphs: [],
              })
            }
          })
        }
      })

      if (quickEventsMap.size > 0) {
        setScriptEvents(Array.from(quickEventsMap.values()))
      }

      const topCharsToFetch = validChars.slice(0, 28)
      const storyResponses = await Promise.allSettled(
        topCharsToFetch.map((c) =>
          fetch(`${API_URL}/characters/${c.id}/story?source_id=${source.id}`)
            .then((r) => (r.ok ? r.json() : null))
            .then((storyData) => ({ char: c, storyData }))
        )
      )

      const richEventsMap = new Map()
      storyResponses.forEach((result) => {
        if (result.status === 'fulfilled' && result.value?.storyData?.events) {
          const { char, storyData } = result.value
          storyData.events.forEach((ev) => {
            const dedupKey = ev.id
              ? `id-${ev.id}`
              : `${normalizeText(ev.title)}-${ev.chapter?.number || 0}-${ev.paragraph_start || 0}`
            if (!richEventsMap.has(dedupKey)) {
              richEventsMap.set(dedupKey, {
                id: ev.id || dedupKey,
                title: ev.title,
                summary: ev.summary,
                chapter: ev.chapter || null,
                paragraph_start: ev.paragraph_start,
                paragraph_end: ev.paragraph_end,
                paragraphs: Array.isArray(ev.paragraphs) ? ev.paragraphs : [],
                character_id: char.id,
                character_name: char.name,
              })
            }
          })
        }
      })

      if (richEventsMap.size > 0) {
        const sortedEvents = Array.from(richEventsMap.values()).sort((a, b) => {
          const chA = Number(a.chapter?.number ?? 9999)
          const chB = Number(b.chapter?.number ?? 9999)
          if (chA !== chB) return chA - chB
          return Number(a.paragraph_start ?? 0) - Number(b.paragraph_start ?? 0)
        })
        setScriptEvents(sortedEvents)
      }
    } catch (err) {
      console.error('Error loading script page:', err)
    } finally {
      setLoadingScriptData(false)
      setLoadingEvents(false)
    }
  }

  const returnToArchive = () => {
    setSelectedScript(null)
    setModalOpen(false)
    window.scrollTo({ top: 0, behavior: 'smooth' })
  }

  // ------------------------------------------------------------
  // 6. OPEN CHARACTER DOSSIER & RELATIONS MODAL
  // ------------------------------------------------------------
  const openCharacterModal = async (characterObjOrId, explicitSourceId = null) => {
    const sourceId = explicitSourceId ?? selectedScript?.id ?? sources[0]?.id ?? null
    const charObj =
      typeof characterObjOrId === 'object'
        ? characterObjOrId
        : scriptCharacters.find((c) => c.id === Number(characterObjOrId)) ||
          allCharacters.find((c) => c.id === Number(characterObjOrId)) || {
            id: Number(characterObjOrId),
            name: 'Character Record',
          }

    setSelectedCharacter(charObj)
    setModalSourceId(sourceId)
    setPreviousModalSourceId(selectedScript?.id ?? sourceId)
    setCharacterStory(null)
    setLoadingStory(true)
    setModalOpen(true)

    try {
      const query = sourceId !== null ? `?source_id=${sourceId}` : ''
      const res = await fetch(`${API_URL}/characters/${charObj.id}/story${query}`)
      if (!res.ok) throw new Error('Failed to load character story')
      const data = await res.json()
      setCharacterStory(data)
    } catch (err) {
      console.error('Failed to load character story:', err)
    } finally {
      setLoadingStory(false)
    }
  }

  const handleModalSourceChange = async (newSourceIdRaw) => {
    const newSourceId = Number(newSourceIdRaw)
    if (!selectedCharacter || Number.isNaN(newSourceId)) return

    if (modalSourceId !== null && modalSourceId !== newSourceId) {
      setPreviousModalSourceId(modalSourceId)
    }
    setModalSourceId(newSourceId)

    try {
      const res = await fetch(
        `${API_URL}/characters/${selectedCharacter.id}/story?source_id=${newSourceId}`
      )
      if (!res.ok) throw new Error('Failed to load character story for selected script')
      const data = await res.json()
      setCharacterStory(data)
    } catch (err) {
      console.error('Failed to switch script in modal:', err)
    }
  }

  // ------------------------------------------------------------
  // 7. TEAMMATE'S 2D GRAPH COMPUTED DATA, FILTERS & CANVAS PAINTER
  // ------------------------------------------------------------
  const getNodeColor = (node) => (GROUP_META[node?.group] || GROUP_META.other).color

  const nodeRadius = (node) => Math.min(3 + Math.sqrt(node?.mention_count || 0) * 0.55, 13)

  const visibleGraph = useMemo(() => {
    const ranked = scriptGraph.nodes
      .filter((n) => !hiddenGroups.includes(n.group || 'other'))
      .sort((a, b) => (b.mention_count || 0) - (a.mention_count || 0))
    const kept = graphTopN > 0 ? ranked.slice(0, graphTopN) : ranked
    const ids = new Set(kept.map((n) => n.id))
    const links = scriptGraph.links
      .map((l) => ({
        source: linkEndId(l.source),
        target: linkEndId(l.target),
        weight: l.weight || 1,
      }))
      .filter((l) => l.weight >= graphMinWeight && ids.has(l.source) && ids.has(l.target))
    return { nodes: kept.map((n) => ({ ...n })), links }
  }, [scriptGraph, graphTopN, graphMinWeight, hiddenGroups])

  const neighborMap = useMemo(() => {
    const map = new Map()
    for (const l of visibleGraph.links) {
      const s = linkEndId(l.source)
      const t = linkEndId(l.target)
      if (!map.has(s)) map.set(s, new Set())
      if (!map.has(t)) map.set(t, new Set())
      map.get(s).add(t)
      map.get(t).add(s)
    }
    return map
  }, [visibleGraph])

  const labelIds = useMemo(
    () => new Set(visibleGraph.nodes.slice(0, MAX_LABELLED_NODES).map((n) => n.id)),
    [visibleGraph]
  )

  const groupCounts = useMemo(() => {
    const counts = {}
    for (const n of scriptGraph.nodes) {
      const key = n.group || 'other'
      counts[key] = (counts[key] || 0) + 1
    }
    return counts
  }, [scriptGraph])

  const maxLinkWeight = useMemo(
    () => scriptGraph.links.reduce((max, l) => Math.max(max, l.weight || 1), 2),
    [scriptGraph]
  )

  const activeNodeId = hoverNodeId ?? selectedNodeId

  const hubNodeIds = useMemo(() => {
    return new Set(visibleGraph.nodes.slice(0, 10).map((n) => n.id))
  }, [visibleGraph])

  const highlightIds = useMemo(() => {
    if (hoverLink) {
      return new Set([linkEndId(hoverLink.source), linkEndId(hoverLink.target)])
    }
    if (activeNodeId === null) return null
    return new Set([activeNodeId, ...(neighborMap.get(activeNodeId) || [])])
  }, [activeNodeId, hoverLink, neighborMap])

  const selectedNode = visibleGraph.nodes.find((n) => n.id === selectedNodeId) || null

  const selectedConnections = useMemo(() => {
    if (selectedNodeId === null) return []
    const byId = new Map(visibleGraph.nodes.map((n) => [n.id, n]))
    return visibleGraph.links
      .filter((l) => linkEndId(l.source) === selectedNodeId || linkEndId(l.target) === selectedNodeId)
      .map((l) => ({
        node: byId.get(
          linkEndId(l.source) === selectedNodeId ? linkEndId(l.target) : linkEndId(l.source)
        ),
        weight: l.weight,
      }))
      .filter((c) => c.node)
      .sort((a, b) => b.weight - a.weight)
      .slice(0, 6)
  }, [selectedNodeId, visibleGraph])

  useEffect(() => {
    fitDoneRef.current = false
    const fg = graphRef.current
    if (!fg || !visibleGraph.nodes.length) return
    fg.d3Force('charge')?.strength(-190)
    fg.d3Force('link')?.distance(65)
    fg.d3ReheatSimulation()
  }, [visibleGraph])

  const handleEngineStop = () => {
    if (fitDoneRef.current) return
    fitDoneRef.current = true
    graphRef.current?.zoomToFit(500, 70)
  }

  const focusNode = (idOrNode) => {
    const id = typeof idOrNode === 'object' ? idOrNode?.id : idOrNode
    if (id == null) return
    setSelectedNodeId(id)
    const node =
      (typeof idOrNode === 'object' && idOrNode?.x != null
        ? idOrNode
        : visibleGraph.nodes.find((n) => n.id === id)) || null
    if (node && node.x != null && graphRef.current) {
      graphRef.current.centerAt(node.x, node.y, 600)
      graphRef.current.zoom(3, 600)
    }
  }

  const handleGraphSearch = (event) => {
    event.preventDefault()
    const query = graphSearch.trim().toLowerCase()
    if (!query) return
    const match =
      scriptGraph.nodes.find((n) => n.name?.toLowerCase() === query) ||
      scriptGraph.nodes.find((n) => n.name?.toLowerCase().includes(query))
    if (!match) {
      setGraphSearchMiss(true)
      return
    }
    setGraphSearchMiss(false)
    if (!visibleGraph.nodes.some((n) => n.id === match.id)) {
      setGraphTopN(0)
      setHiddenGroups([])
    }
    focusNode(match.id)
  }

  const toggleGroup = (key) =>
    setHiddenGroups((current) =>
      current.includes(key) ? current.filter((k) => k !== key) : [...current, key]
    )

  // ------------------------------------------------------------
  // CANVAS BACKGROUND CONSTELLATION & RADAR COORDINATE GRID
  // ------------------------------------------------------------
  const paintBackgroundGrid = (ctx, globalScale) => {
    ctx.save()
    const radii = [130, 260, 420, 600]
    radii.forEach((rad, idx) => {
      ctx.beginPath()
      ctx.arc(0, 0, rad, 0, 2 * Math.PI)
      ctx.strokeStyle =
        idx % 2 === 0 ? 'rgba(216, 183, 124, 0.05)' : 'rgba(91, 184, 255, 0.04)'
      ctx.lineWidth = 0.8 / globalScale
      if (idx === 1 || idx === 3) {
        ctx.setLineDash([3 / globalScale, 7 / globalScale])
      } else {
        ctx.setLineDash([])
      }
      ctx.stroke()
    })

    ctx.beginPath()
    ctx.moveTo(-650, 0)
    ctx.lineTo(650, 0)
    ctx.moveTo(0, -650)
    ctx.lineTo(0, 650)
    ctx.strokeStyle = 'rgba(216, 183, 124, 0.035)'
    ctx.setLineDash([2 / globalScale, 6 / globalScale])
    ctx.lineWidth = 0.75 / globalScale
    ctx.stroke()
    ctx.restore()
  }

  // ------------------------------------------------------------
  // DYNAMIC GRADIENT LINK & LUMINOUS BLOOM PAINTER
  // ------------------------------------------------------------
  const isSameLink = (a, b) => {
    if (!a || !b) return false
    const as = linkEndId(a.source)
    const at = linkEndId(a.target)
    const bs = linkEndId(b.source)
    const bt = linkEndId(b.target)
    return (as === bs && at === bt) || (as === bt && at === bs)
  }

  const linkTouchesActive = (link) => {
    if (activeNodeId === null) return false
    const s = linkEndId(link.source)
    const t = linkEndId(link.target)
    return s === activeNodeId || t === activeNodeId
  }

  const paintLink = (link, ctx, globalScale) => {
    const start = link.source
    const end = link.target
    if (
      !start ||
      !end ||
      !Number.isFinite(start.x) ||
      !Number.isFinite(start.y) ||
      !Number.isFinite(end.x) ||
      !Number.isFinite(end.y)
    ) {
      return
    }

    const isHovered = isSameLink(hoverLink, link)
    const touchesActive = linkTouchesActive(link)
    const isHighlighted = isHovered || touchesActive
    const isDimmed = (activeNodeId !== null || hoverLink !== null) && !isHighlighted

    const sColor = getNodeColor(start)
    const tColor = getNodeColor(end)
    const weight = link.weight || 1

    const controlPoints = link.__controlPoints
    const hasCp = graphCurved && controlPoints && controlPoints.length === 2

    const tracePath = () => {
      ctx.beginPath()
      ctx.moveTo(start.x, start.y)
      if (hasCp) {
        ctx.quadraticCurveTo(controlPoints[0], controlPoints[1], end.x, end.y)
      } else {
        ctx.lineTo(end.x, end.y)
      }
    }

    if (isDimmed) {
      ctx.save()
      tracePath()
      ctx.strokeStyle = 'rgba(120, 140, 180, 0.035)'
      ctx.lineWidth = 0.5 / globalScale
      ctx.stroke()
      ctx.restore()
      return
    }

    if (isHighlighted) {
      // PASS 1: Soft luminous bloom
      ctx.save()
      tracePath()
      const bloomGrad = ctx.createLinearGradient(start.x, start.y, end.x, end.y)
      bloomGrad.addColorStop(0, hexToRgba(sColor, 0.42))
      bloomGrad.addColorStop(0.5, 'rgba(255, 255, 255, 0.5)')
      bloomGrad.addColorStop(1, hexToRgba(tColor, 0.42))
      ctx.strokeStyle = bloomGrad
      ctx.lineWidth =
        (Math.max(3, Math.min(7.5, 2.5 + Math.sqrt(weight) * 0.4)) + 5) / globalScale
      ctx.lineCap = 'round'
      ctx.stroke()
      ctx.restore()

      // PASS 2: High-contrast gradient core beam
      ctx.save()
      tracePath()
      const coreGrad = ctx.createLinearGradient(start.x, start.y, end.x, end.y)
      coreGrad.addColorStop(0, sColor)
      coreGrad.addColorStop(0.5, '#ffffff')
      coreGrad.addColorStop(1, tColor)
      ctx.strokeStyle = coreGrad
      ctx.lineWidth =
        Math.max(1.8, Math.min(4.8, 1.6 + Math.sqrt(weight) * 0.3)) / globalScale
      ctx.lineCap = 'round'
      ctx.stroke()
      ctx.restore()

      // PASS 3: Floating Midpoint Connection Badge
      if (showLinkBadges && globalScale > 0.65) {
        let midX = (start.x + end.x) / 2
        let midY = (start.y + end.y) / 2
        if (hasCp) {
          midX = 0.25 * start.x + 0.5 * controlPoints[0] + 0.25 * end.x
          midY = 0.25 * start.y + 0.5 * controlPoints[1] + 0.25 * end.y
        }

        ctx.save()
        const text = `${weight}`
        const fontSize = 8.5 / globalScale
        ctx.font = `700 ${fontSize}px Manrope, system-ui, sans-serif`
        const textWidth = ctx.measureText(text).width
        const padX = 5 / globalScale
        const padY = 2.5 / globalScale
        const dotR = 1.8 / globalScale
        const dotSpacing = 3.5 / globalScale
        const badgeW = padX * 2 + dotR * 2 + dotSpacing + textWidth
        const badgeH = fontSize + padY * 2
        const bx = midX - badgeW / 2
        const by = midY - badgeH / 2

        ctx.fillStyle = 'rgba(8, 12, 22, 0.94)'
        ctx.beginPath()
        if (typeof ctx.roundRect === 'function') {
          ctx.roundRect(bx, by, badgeW, badgeH, badgeH / 2)
        } else {
          ctx.rect(bx, by, badgeW, badgeH)
        }
        ctx.fill()

        ctx.lineWidth = 0.9 / globalScale
        ctx.strokeStyle = isHovered ? '#ffffff' : 'rgba(216, 183, 124, 0.75)'
        ctx.stroke()

        ctx.beginPath()
        ctx.arc(bx + padX + dotR, midY, dotR, 0, 2 * Math.PI)
        ctx.fillStyle = '#d8b77c'
        ctx.fill()

        ctx.textAlign = 'left'
        ctx.textBaseline = 'middle'
        ctx.fillStyle = '#f2eee7'
        ctx.fillText(text, bx + padX + dotR * 2 + dotSpacing, midY + 0.3 / globalScale)
        ctx.restore()
      }
    } else {
      ctx.save()
      tracePath()
      const grad = ctx.createLinearGradient(start.x, start.y, end.x, end.y)
      grad.addColorStop(0, hexToRgba(sColor, 0.32))
      grad.addColorStop(0.5, 'rgba(216, 183, 124, 0.24)')
      grad.addColorStop(1, hexToRgba(tColor, 0.32))
      ctx.strokeStyle = grad
      ctx.lineWidth =
        Math.max(0.65, Math.min(2.5, 0.5 + Math.sqrt(weight) * 0.18)) / globalScale
      ctx.stroke()
      ctx.restore()
    }
  }

  const paintLinkPointerArea = (link, color, ctx, globalScale = 1) => {
    const start = link.source
    const end = link.target
    if (!start || !end || !Number.isFinite(start.x) || !Number.isFinite(end.x)) return
    ctx.save()
    ctx.beginPath()
    ctx.moveTo(start.x, start.y)
    const controlPoints = link.__controlPoints
    if (graphCurved && controlPoints && controlPoints.length === 2) {
      ctx.quadraticCurveTo(controlPoints[0], controlPoints[1], end.x, end.y)
    } else {
      ctx.lineTo(end.x, end.y)
    }
    ctx.strokeStyle = color
    ctx.lineWidth = Math.max(2, 3 / globalScale)
    ctx.stroke()
    ctx.restore()
  }

  // ------------------------------------------------------------
  // FLOWING PHOTONS / ENERGY STREAMS ALONG CONNECTIONS
  // ------------------------------------------------------------
  const getLinkParticles = (link) => {
    if (!graphParticles) return 0
    if (linkTouchesActive(link) || isSameLink(hoverLink, link)) return 4
    if ((link.weight || 1) >= 4) return 1
    return 0
  }

  const getLinkParticleSpeed = (link) => {
    return linkTouchesActive(link) || isSameLink(hoverLink, link) ? 0.009 : 0.004
  }

  const paintParticle = (x, y, link, ctx, globalScale) => {
    if (!Number.isFinite(x) || !Number.isFinite(y)) return
    const isHighlighted = linkTouchesActive(link) || isSameLink(hoverLink, link)
    const baseR = (isHighlighted ? 3.0 : 1.8) / Math.sqrt(globalScale)
    const sColor = getNodeColor(link.source)
    const tColor = getNodeColor(link.target)

    const glowR = baseR * 3.4
    const glow = ctx.createRadialGradient(x, y, baseR * 0.2, x, y, glowR)
    glow.addColorStop(0, isHighlighted ? 'rgba(255, 255, 255, 0.95)' : hexToRgba(sColor, 0.8))
    glow.addColorStop(0.5, hexToRgba(tColor, 0.4))
    glow.addColorStop(1, 'rgba(0,0,0,0)')
    ctx.beginPath()
    ctx.arc(x, y, glowR, 0, 2 * Math.PI)
    ctx.fillStyle = glow
    ctx.fill()

    ctx.beginPath()
    ctx.arc(x, y, baseR, 0, 2 * Math.PI)
    ctx.fillStyle = isHighlighted ? '#ffffff' : '#ffd166'
    ctx.fill()
  }

  // Shared rule for when a node's label pill is drawn & clickable
  const isLabelVisible = (node, globalScale) => {
    const isActive = node.id === activeNodeId
    const dimmed = highlightIds !== null && !highlightIds.has(node.id)
    return (
      !dimmed &&
      (isActive ||
        highlightIds !== null ||
        labelIds.has(node.id) ||
        hubNodeIds.has(node.id) ||
        globalScale > 2.0)
    )
  }

  // ------------------------------------------------------------
  // MULTI-LAYER CELESTIAL NODE PAINTER (3D JEWEL CORE & GLASS PILL)
  // ------------------------------------------------------------
  const paintNode = (node, ctx, globalScale) => {
    if (!Number.isFinite(node.x) || !Number.isFinite(node.y)) return
    const r = nodeRadius(node)
    const color = getNodeColor(node)
    const isActive = node.id === activeNodeId
    const isHub = hubNodeIds.has(node.id)
    const dimmed = highlightIds !== null && !highlightIds.has(node.id)

    ctx.globalAlpha = dimmed ? 0.08 : 1

    // 1. Concentric radar orbit ring for top hubs
    if (isHub && !dimmed) {
      ctx.save()
      ctx.beginPath()
      ctx.arc(node.x, node.y, r * 2.1, 0, 2 * Math.PI)
      ctx.strokeStyle = hexToRgba(color, 0.28)
      ctx.setLineDash([2.5 / globalScale, 4.5 / globalScale])
      ctx.lineWidth = 0.85 / globalScale
      ctx.stroke()
      ctx.restore()
    }

    // 2. Soft atmospheric radial glow halo
    const glowR = r * (isActive ? 4.8 : 3.4)
    const glow = ctx.createRadialGradient(node.x, node.y, r * 0.3, node.x, node.y, glowR)
    glow.addColorStop(0, hexToRgba(color, isActive ? 0.6 : 0.3))
    glow.addColorStop(1, 'rgba(0,0,0,0)')
    ctx.beginPath()
    ctx.arc(node.x, node.y, glowR, 0, 2 * Math.PI)
    ctx.fillStyle = glow
    ctx.fill()

    // 3. Active expansion ring pulse
    if (isActive) {
      ctx.beginPath()
      ctx.arc(node.x, node.y, r + 4.5 / globalScale, 0, 2 * Math.PI)
      ctx.lineWidth = 1.8 / globalScale
      ctx.strokeStyle = '#ffffff'
      ctx.stroke()
    }

    // 4. Outer rim border ring
    ctx.beginPath()
    ctx.arc(node.x, node.y, r + 2.2 / globalScale, 0, 2 * Math.PI)
    ctx.lineWidth = (isActive ? 2.2 : 1.2) / globalScale
    ctx.strokeStyle = isActive ? '#ffffff' : hexToRgba(color, 0.8)
    ctx.stroke()

    // 5. 3D Spherical gradient core jewel
    const sphereGrad = ctx.createRadialGradient(
      node.x - r * 0.35,
      node.y - r * 0.35,
      r * 0.05,
      node.x,
      node.y,
      r
    )
    sphereGrad.addColorStop(0, '#ffffff')
    sphereGrad.addColorStop(0.35, color)
    sphereGrad.addColorStop(1, shadeHex(color, -50))
    ctx.beginPath()
    ctx.arc(node.x, node.y, r, 0, 2 * Math.PI)
    ctx.fillStyle = sphereGrad
    ctx.fill()

    // 6. Specular pinhead highlight
    ctx.beginPath()
    ctx.arc(node.x - r * 0.3, node.y - r * 0.3, Math.max(1, r * 0.22), 0, 2 * Math.PI)
    ctx.fillStyle = 'rgba(255, 255, 255, 0.88)'
    ctx.fill()

    // 7. Floating Frosted Glass Badge Pill Label
    if (isLabelVisible(node, globalScale)) {
      const fontSize = (isActive ? 12 : 11) / globalScale
      ctx.font = `${isActive ? '700 ' : '600 '}${fontSize}px Manrope, system-ui, sans-serif`
      const nameText = node.name || ''
      const nameWidth = ctx.measureText(nameText).width

      const countText = `${node.mention_count || 0}`
      const countFontSize = 9 / globalScale
      ctx.font = `500 ${countFontSize}px Manrope, system-ui, sans-serif`
      const countWidth = ctx.measureText(countText).width

      const padX = 7 / globalScale
      const padY = 3.5 / globalScale
      const dotR = 2.4 / globalScale
      const dotSpacing = 5.5 / globalScale
      const sepSpacing = 7 / globalScale

      const pillW = dotR * 2 + dotSpacing + nameWidth + sepSpacing + countWidth + padX * 2
      const pillH = fontSize + padY * 2
      const pillX = node.x - pillW / 2
      const pillY = node.y + r + 6 / globalScale

      ctx.fillStyle = isActive ? 'rgba(8, 12, 22, 0.96)' : 'rgba(10, 14, 24, 0.88)'
      ctx.beginPath()
      if (typeof ctx.roundRect === 'function') {
        ctx.roundRect(pillX, pillY, pillW, pillH, pillH / 2)
      } else {
        ctx.rect(pillX, pillY, pillW, pillH)
      }
      ctx.fill()

      ctx.lineWidth = (isActive ? 1.6 : 0.85) / globalScale
      ctx.strokeStyle = isActive ? '#ffffff' : hexToRgba(color, 0.65)
      ctx.stroke()

      const dotCenterX = pillX + padX + dotR
      const dotCenterY = pillY + pillH / 2
      ctx.beginPath()
      ctx.arc(dotCenterX, dotCenterY, dotR, 0, 2 * Math.PI)
      ctx.fillStyle = color
      ctx.fill()

      ctx.textAlign = 'left'
      ctx.textBaseline = 'middle'
      ctx.font = `${isActive ? '700 ' : '600 '}${fontSize}px Manrope, system-ui, sans-serif`
      ctx.fillStyle = isActive ? '#ffffff' : '#f2eee7'
      ctx.fillText(nameText, dotCenterX + dotR + dotSpacing, pillY + pillH / 2 + 0.3 / globalScale)

      ctx.font = `500 ${countFontSize}px Manrope, system-ui, sans-serif`
      ctx.fillStyle = isActive ? '#ffd166' : '#8c929e'
      const countX = dotCenterX + dotR + dotSpacing + nameWidth + sepSpacing
      ctx.fillText(countText, countX, pillY + pillH / 2 + 0.3 / globalScale)
    }

    ctx.globalAlpha = 1
  }

  // Tight pointer hitbox so every node is cleanly clickable without swallowing neighbours
  const paintNodePointerArea = (node, color, ctx, globalScale = 1) => {
    if (!Number.isFinite(node.x) || !Number.isFinite(node.y)) return
    const r = nodeRadius(node)
    const hitR = r + 4 / globalScale
    ctx.fillStyle = color
    ctx.beginPath()
    ctx.arc(node.x, node.y, hitR, 0, 2 * Math.PI)
    ctx.fill()

    if (!isLabelVisible(node, globalScale)) return
    const fontSize = 11.5 / globalScale
    ctx.font = `600 ${fontSize}px Manrope, system-ui, sans-serif`
    const nameWidth = ctx.measureText(node.name || '').width
    const pillW = nameWidth + 28 / globalScale
    const pillH = fontSize + 8 / globalScale
    const pillX = node.x - pillW / 2
    const pillY = node.y + r + 4 / globalScale
    ctx.beginPath()
    if (typeof ctx.roundRect === 'function') {
      ctx.roundRect(pillX, pillY, pillW, pillH, pillH / 2)
    } else {
      ctx.rect(pillX, pillY, pillW, pillH)
    }
    ctx.fill()
  }

  // Safety net: if a click lands on a link or background, still pick any node under the pointer
  const pickNodeAt = (event) => {
    const fg = graphRef.current
    const el = graphContainerRef.current
    if (!fg || !el || !event || event.clientX == null) return null
    const rect = el.getBoundingClientRect()
    const { x, y } = fg.screen2GraphCoords(event.clientX - rect.left, event.clientY - rect.top)
    const zoom = fg.zoom() || 1
    let best = null
    let bestDist = Infinity
    for (const n of visibleGraph.nodes) {
      if (!Number.isFinite(n.x) || !Number.isFinite(n.y)) continue
      const r = nodeRadius(n)
      const d = Math.hypot(n.x - x, n.y - y)
      if (d <= r + 6 / zoom && d < bestDist) {
        best = n
        bestDist = d
      }
    }
    return best
  }

  // ------------------------------------------------------------
  // 8. FILTERED EVENTS & CHARACTERS ON THE SCRIPT PAGE
  // ------------------------------------------------------------
  const availableChapters = useMemo(() => {
    const map = new Map()
    scriptEvents.forEach((ev) => {
      if (ev.chapter?.number != null) {
        const key = String(ev.chapter.number)
        if (!map.has(key)) {
          map.set(
            key,
            `Chapter ${ev.chapter.number}${ev.chapter.title ? ` · ${ev.chapter.title}` : ''}`
          )
        }
      }
    })
    return Array.from(map.entries())
  }, [scriptEvents])

  const filteredScriptEvents = useMemo(() => {
    const q = normalizeText(eventFilter.trim())
    return scriptEvents.filter((ev) => {
      if (chapterFilter !== 'ALL' && String(ev.chapter?.number) !== chapterFilter) {
        return false
      }
      if (!q) return true
      return [
        ev.title,
        ev.summary,
        ev.character_name,
        ev.chapter?.title,
        ev.chapter?.book,
      ].some((val) => normalizeText(val).includes(q))
    })
  }, [scriptEvents, eventFilter, chapterFilter])

  const filteredScriptCharacters = useMemo(() => {
    const q = normalizeText(characterFilter.trim())
    if (!q) return scriptCharacters
    return scriptCharacters.filter((c) =>
      [c.name, c.role, c.description, ...(c.aliases || [])].some((val) =>
        normalizeText(val).includes(q)
      )
    )
  }, [scriptCharacters, characterFilter])

  const getScriptVisualTheme = (title = '', index = 0) => {
    const t = title.toLowerCase()
    if (t.includes('ramayana') && !t.includes('griffith')) {
      return {
        badge: 'SANSKRIT ITIHĀSA · VĀLMĪKI TRADITION',
        accent: '#d8b77c',
        glow: 'rgba(216, 155, 76, 0.42)',
        bgGradient:
          'radial-gradient(ellipse at 78% 28%, rgba(212, 138, 58, 0.35), transparent 52%), linear-gradient(125deg, #1a120b 0%, #0d111a 55%, #2b1410 100%)',
        synopsis:
          'Trace Prince Rāma’s exile across Dandaka, the abduction of Sītā, the alliance with Sugrīva and Hanumān, and the cosmic siege of Lankā with full chapter-level provenance.',
      }
    }
    if (t.includes('griffith')) {
      return {
        badge: 'VERSE TRANSLATION · R.T.H. GRIFFITH ARCHIVE',
        accent: '#68b5c9',
        glow: 'rgba(54, 158, 184, 0.42)',
        bgGradient:
          'radial-gradient(ellipse at 78% 28%, rgba(38, 135, 156, 0.38), transparent 52%), linear-gradient(125deg, #0d1e29 0%, #0b101b 55%, #1d162b 100%)',
        synopsis:
          'Compare cross-translation entity resolution and poetic canto structures in Ralph T.H. Griffith’s classical English verse rendering of the Ramayana.',
      }
    }
    if (t.includes('bhagavad') || t.includes('gita')) {
      return {
        badge: 'UPANISHADIC DIALOGUE · KURUKSHETRA DISCOURSE',
        accent: '#7aa6f7',
        glow: 'rgba(78, 129, 228, 0.42)',
        bgGradient:
          'radial-gradient(ellipse at 78% 28%, rgba(66, 118, 212, 0.36), transparent 52%), linear-gradient(125deg, #0e182e 0%, #090d16 55%, #1f1730 100%)',
        synopsis:
          'Explore the 18 chapters of philosophical synthesis between Krishna and Arjuna on dharma, karma-yoga, and the Vishvarupa revelation.',
      }
    }
    if (t.includes('garuda')) {
      return {
        badge: 'VAISHNAVA MAHĀPURĀṆA · COSMOLOGY & SOTERIOLOGY',
        accent: '#68c999',
        glow: 'rgba(52, 168, 122, 0.38)',
        bgGradient:
          'radial-gradient(ellipse at 78% 28%, rgba(45, 150, 108, 0.34), transparent 52%), linear-gradient(125deg, #0c211d 0%, #0a0f18 55%, #241914 100%)',
        synopsis:
          'Navigate the dialogue between Lord Vishnu and Garuda spanning cosmic cycles, sacred genealogy, rituals, and the journey of the soul.',
      }
    }
    if (t.includes('ganesha')) {
      return {
        badge: 'UPAPURĀṆA CORPUS · UPĀSANĀ & KRĪḌĀ KHAṆḌAS',
        accent: '#e08256',
        glow: 'rgba(214, 96, 56, 0.42)',
        bgGradient:
          'radial-gradient(ellipse at 78% 28%, rgba(196, 84, 45, 0.38), transparent 52%), linear-gradient(125deg, #29130e 0%, #0d1018 55%, #1c1224 100%)',
        synopsis:
          'Uncover the mythological narratives of Somakanta, Sage Bhrigu, Cyavana, Suta, and the divine incarnations of Lord Ganesha.',
      }
    }
    return {
      badge: `CANONICAL SOURCE · ARCHIVE ${padTwo(index + 1)}`,
      accent: '#d8b77c',
      glow: index % 2 ? 'rgba(133, 73, 48, 0.45)' : 'rgba(38, 135, 156, 0.45)',
      bgGradient: 'linear-gradient(125deg, #132d3c, #12131d 52%, #331b20)',
      synopsis:
        'Explore canonical characters, automated SVO narrative events, chapter passages, and co-occurrence network graphs extracted from this scripture.',
    }
  }

  return (
    <div className="mythverse-root">
      {/* ============================================================
          PERSISTENT GPU-ACCELERATED COSMIC AMBIENT ANIMATION
      ============================================================ */}
      <div className="ambient" ref={ambientRef}>
        <div className="nebula n1" />
        <div className="nebula n2" />
        <div className="stars" />
      </div>

      {/* ============================================================
          TOPBAR NAVIGATION
      ============================================================ */}
      <header className="topbar">
        <a
          className="brand"
          href="#top"
          onClick={(e) => {
            e.preventDefault()
            returnToArchive()
          }}
        >
          <span className="brand-mark">✳</span> MYTHVERSE
        </a>

        {!selectedScript ? (
          <nav className="topbar-nav">
            <a href="#library">THE SCRIPT ARCHIVE</a>
            <a href="#architecture">HOW MYTHVERSE WORKS</a>
          </nav>
        ) : (
          <nav className="topbar-nav">
            <a href="#script-events">01 · MAIN EVENTS</a>
            <a href="#script-characters">02 · CHARACTERS</a>
            <a href="#script-network">03 · 2D CHARACTER MAP</a>
          </nav>
        )}

        <div className="topbar-actions">
          {selectedScript ? (
            <button className="back-pill-btn" onClick={returnToArchive}>
              ← ALL SCRIPTS
            </button>
          ) : (
            <button
              className="search-trigger"
              onClick={() => {
                document.getElementById('library')?.scrollIntoView({ behavior: 'smooth' })
                setTimeout(() => document.getElementById('archiveSearchInput')?.focus(), 400)
              }}
            >
              ⌕ <span>SEARCH ARCHIVE</span>
            </button>
          )}
        </div>
      </header>

      {/* ============================================================
          VIEW 1: HOME PAGE (HERO + SWIPEABLE SCRIPT CAROUSEL)
      ============================================================ */}
      {!selectedScript ? (
        <main id="homeView">
          {/* CINEMATIC HERO SECTION */}
          <section className="hero" id="top">
            <div className="hero-copy">
              <div className="eyebrow">
                <i /> COMPUTATIONAL MYTHOLOGY & KNOWLEDGE GRAPH PLATFORM
              </div>

              <h1>
                MYTH<span>VERSE</span>
              </h1>

              <p className="hero-sub">
                Where ancient epics become living, connected knowledge.
              </p>

              <p className="hero-desc">
                MYTHVERSE ingests classical Indian scriptures and translations into a
                unified relational graph — resolving character aliases across texts,
                extracting chapter-level turning points, and mapping every divine, royal,
                and sage interaction with verifiable textual provenance.
              </p>

              <div className="hero-cta-row">
                <a className="discover-primary" href="#library">
                  EXPLORE THE SCRIPTS <b>↓</b>
                </a>
                <div className="hero-metrics">
                  <span>
                    <b>{sources.length || '—'}</b> INGESTED SCRIPTS
                  </span>
                  <span>
                    <b>{allCharacters.length || '—'}</b> CANONICAL ENTITIES
                  </span>
                </div>
              </div>
            </div>

            <div className="hero-orbit orbit-one" />
            <div className="hero-orbit orbit-two" />
            <div className="hero-orbit orbit-three" />

            <div className="hero-caption">
              <span>01 / CANONICAL ENTITY & EVENT ENGINE</span>
              <span>SCROLL DOWN & SWIPE RIGHT THROUGH THE ARCHIVE ↓</span>
            </div>
          </section>

          {/* SCRIPT ARCHIVE & ONE-MYTHOLOGY-PER-SLIDE CAROUSEL */}
          <section className="library section-wrap" id="library">
            <div className="section-heading">
              <div>
                <div className="eyebrow">
                  <i /> THE SCRIPTURE COLLECTION
                </div>
                <h2>
                  Select a <em>Mythology.</em>
                </h2>
              </div>

              <div className="section-note">
                Swipe horizontally or use the arrows —<br />
                one sacred text per slide. Click any slide to open its 3-part world view{' '}
                <span>→</span>
              </div>
            </div>

            {/* SEARCH BAR FOR MYTHOLOGIES & CHARACTERS */}
            <div className="search-area">
              <div className="searchbox">
                <span>⌕</span>
                <input
                  id="archiveSearchInput"
                  type="text"
                  placeholder="Search for a mythology (e.g., Ramayana, Bhagavadgita, Ganesha Purana) or character..."
                  autoComplete="off"
                  value={archiveSearch}
                  onChange={(e) => {
                    setArchiveSearch(e.target.value)
                    setSearchDropdownOpen(Boolean(e.target.value.trim()))
                    setActiveSlideIndex(0)
                  }}
                  onFocus={() => {
                    if (archiveSearch.trim()) setSearchDropdownOpen(true)
                  }}
                  onKeyDown={(e) => {
                    if (e.key === 'Enter' && filteredSources.length > 0) {
                      openScriptPage(filteredSources[0])
                    }
                  }}
                />
                <kbd>ENTER</kbd>
                {archiveSearch && (
                  <button
                    type="button"
                    onClick={() => {
                      setArchiveSearch('')
                      setSearchDropdownOpen(false)
                    }}
                    aria-label="Clear search"
                  >
                    ×
                  </button>
                )}
              </div>

              {searchDropdownOpen && archiveSearch.trim() && (
                <div className="search-results">
                  {filteredSources.length > 0 && (
                    <>
                      <div className="result-label">
                        MATCHING MYTHOLOGIES ({filteredSources.length})
                      </div>
                      {filteredSources.map((s) => (
                        <button
                          key={s.id}
                          type="button"
                          className="result-row"
                          onClick={() => openScriptPage(s)}
                        >
                          <span>
                            <strong>{s.title}</strong>
                            {s.translator && s.translator !== '\\N'
                              ? ` · ${s.translator}`
                              : ''}
                          </span>
                          <small>ENTER WORLD ↗</small>
                        </button>
                      ))}
                    </>
                  )}

                  {matchingCharactersInSearch.length > 0 && (
                    <>
                      <div className="result-label">
                        CHARACTERS ACROSS SCRIPTS ({matchingCharactersInSearch.length})
                      </div>
                      {matchingCharactersInSearch.map((c) => {
                        const firstSource =
                          sources.find((s) => c.source_ids?.includes(s.id)) || sources[0]
                        return (
                          <button
                            key={c.id}
                            type="button"
                            className="result-row"
                            onClick={() => {
                              if (firstSource) openScriptPage(firstSource, c)
                            }}
                          >
                            <span>
                              <strong>{c.name}</strong> —{' '}
                              <em style={{ color: '#9aa3b2', fontStyle: 'normal' }}>
                                {c.role || c.description || 'Canonical Character'}
                              </em>
                            </span>
                            <small>
                              OPEN IN {firstSource?.title?.toUpperCase() || 'SCRIPT'} ↗
                            </small>
                          </button>
                        )
                      })}
                    </>
                  )}

                  {filteredSources.length === 0 &&
                    matchingCharactersInSearch.length === 0 && (
                      <div className="result-row">
                        No matching scripts or characters found in PostgreSQL.
                      </div>
                    )}
                </div>
              )}
            </div>

            {/* HORIZONTAL FULL-SLIDE CAROUSEL (1 MYTHOLOGY PER SWIPE) */}
            {loadingArchive ? (
              <div className="loading-card">
                Synchronizing scripts from PostgreSQL database…
              </div>
            ) : archiveError ? (
              <div className="loading-card error">{archiveError}</div>
            ) : filteredSources.length === 0 ? (
              <div className="loading-card">
                No mythological scripts match "{archiveSearch}".
              </div>
            ) : (
              <>
                <div className="carousel-shell">
                  <button
                    type="button"
                    className="arrow prev"
                    onClick={() => scrollToSlide(activeSlideIndex - 1)}
                    disabled={activeSlideIndex <= 0}
                    aria-label="Previous Mythology"
                  >
                    ←
                  </button>

                  <div
                    id="mythTrack"
                    ref={trackRef}
                    className="myth-track"
                    onScroll={handleTrackScroll}
                  >
                    {filteredSources.map((source, idx) => {
                      const theme = getScriptVisualTheme(source.title, idx)
                      const charCountForSource =
                        source.character_count ??
                        (allCharacters.filter(
                          (c) =>
                            Array.isArray(c.source_ids) && c.source_ids.includes(source.id)
                        ).length ||
                          allCharacters.length)

                      return (
                        <article
                          key={source.id}
                          className="myth-slide-card"
                          style={{
                            '--glow': theme.glow,
                            '--accent': theme.accent,
                            background: theme.bgGradient,
                          }}
                          onClick={() => openScriptPage(source)}
                        >
                          <div className="slide-ambient-orb" />

                          <div className="card-top-row">
                            <div className="card-number">
                              SLIDE {padTwo(idx + 1)} / {padTwo(filteredSources.length)}
                            </div>
                            <div className="card-index">{theme.badge}</div>
                          </div>

                          <div className="card-content">
                            <div className="script-kicker">
                              SOURCE ID #{padTwo(source.id)}
                              {source.language ? ` · ${source.language.toUpperCase()}` : ''}
                            </div>

                            <h3>{source.title}</h3>

                            <p className="script-credits">
                              {source.author ? `Composed by ${source.author}` : 'Classical Epic Tradition'}
                              {source.translator && source.translator !== '\\N'
                                ? ` · Translated by ${source.translator}`
                                : ''}
                              {source.year && source.year !== '\\N' ? ` (${source.year})` : ''}
                            </p>

                            <p className="script-synopsis">{theme.synopsis}</p>

                            <div className="card-bottom-bar">
                              <div className="card-meta">
                                <span>
                                  <b>{charCountForSource || '—'}</b> CANONICAL ENTITIES
                                </span>
                                <span>
                                  <b>3</b> VERTICAL LAYERS (EVENTS · CHARACTERS · 2D GRAPH)
                                </span>
                              </div>

                              <span className="card-enter-cta">
                                ENTER SCRIPT WORLD <b>↗</b>
                              </span>
                            </div>
                          </div>
                        </article>
                      )
                    })}
                  </div>

                  <button
                    type="button"
                    className="arrow next"
                    onClick={() => scrollToSlide(activeSlideIndex + 1)}
                    disabled={activeSlideIndex >= filteredSources.length - 1}
                    aria-label="Next Mythology"
                  >
                    →
                  </button>
                </div>

                <div className="carousel-footer">
                  <div className="progress">
                    <span
                      style={{
                        width: `${((activeSlideIndex + 1) / filteredSources.length) * 100}%`,
                      }}
                    />
                  </div>

                  <span className="slide-counter">
                    {padTwo(activeSlideIndex + 1)} / {padTwo(filteredSources.length)}
                  </span>

                  <div className="slide-dots">
                    {filteredSources.map((s, i) => (
                      <button
                        key={s.id}
                        type="button"
                        className={`slide-dot ${i === activeSlideIndex ? 'active' : ''}`}
                        onClick={() => scrollToSlide(i)}
                        title={s.title}
                      />
                    ))}
                  </div>

                  <span className="drag-hint">SWIPE RIGHT OR USE ARROWS FOR NEXT SCRIPT →</span>
                </div>
              </>
            )}
          </section>

          {/* PROJECT MANIFESTO / CAPTION SECTION */}
          <section className="manifesto section-wrap" id="architecture">
            <div className="manifesto-line" />
            <div className="eyebrow">
              <i /> THE MYTHVERSE ARCHITECTURE
            </div>
            <h2>
              Built for <em>textual fidelity,</em>
              <br />
              entity resolution, and narrative discovery.
            </h2>

            <div className="architecture-pillars">
              <div className="pillar-card">
                <span>01 / ENTITY & ALIAS CONSOLIDATION</span>
                <h3>Canonical Identities</h3>
                <p>
                  Resolves epithets and transliteration variants (such as Rāma, Raghava,
                  and Dasharathi) into unified canonical character records across
                  multiple Sanskrit and English translations.
                </p>
              </div>

              <div className="pillar-card">
                <span>02 / SVO NARRATIVE PIPELINE</span>
                <h3>Chapter Turning Points</h3>
                <p>
                  Extracts Subject–Verb–Object narrative events directly from source
                  chapters, linking every summary back to its exact book, chapter, and
                  translated paragraph numbers.
                </p>
              </div>

              <div className="pillar-card">
                <span>03 / CO-OCCURRENCE TOPOLOGY</span>
                <h3>Interactive 2D Force Graphs</h3>
                <p>
                  Maps character relationships and chapter co-occurrences into an
                  interactive 2D force-directed constellation where every node redirects
                  to its character dossier.
                </p>
              </div>
            </div>
          </section>

          <footer>
            <span>MYTHVERSE · EXTENSIBLE INDIAN EPIC KNOWLEDGE PLATFORM</span>
            <span>POSTGRESQL · FASTAPI · REACT FORCE GRAPH</span>
            <a href="#top">BACK TO TOP ↑</a>
          </footer>
        </main>
      ) : (
        /* ============================================================
           VIEW 2: SELECTED SCRIPT PAGE (3 VERTICAL SECTIONS)
           1st: Main Events | 2nd: Characters | 3rd: Teammate's 2D Graph
        ============================================================ */
        <main id="detailView">
          {/* SCRIPT WORLD HERO */}
          <section className="detail-hero">
            <div className="detail-hero-content">
              <button type="button" className="back-link" onClick={returnToArchive}>
                ← BACK TO THE SCRIPT ARCHIVE
              </button>

              <div className="eyebrow" style={{ marginTop: '24px' }}>
                <i /> SELECTED SCRIPT WORLD / SOURCE #{padTwo(selectedScript.id)}
              </div>

              <h1>{selectedScript.title}</h1>

              <p className="detail-meta-line">
                {[
                  selectedScript.author ? `Composed by ${selectedScript.author}` : null,
                  selectedScript.translator && selectedScript.translator !== '\\N'
                    ? `Translated by ${selectedScript.translator}`
                    : null,
                  selectedScript.year && selectedScript.year !== '\\N'
                    ? `Published ${selectedScript.year}`
                    : null,
                ]
                  .filter(Boolean)
                  .join('  ·  ')}
              </p>

              <div className="detail-stats">
                <a href="#script-events" className="stat-jump-box">
                  <b>{loadingEvents ? '…' : scriptEvents.length}</b>
                  <span>01 · MAIN EVENTS ↓</span>
                </a>
                <a href="#script-characters" className="stat-jump-box">
                  <b>{loadingScriptData ? '…' : scriptCharacters.length}</b>
                  <span>02 · CHARACTERS ↓</span>
                </a>
                <a href="#script-network" className="stat-jump-box">
                  <b>{loadingScriptData ? '…' : scriptGraph.nodes?.length || 0}</b>
                  <span>03 · 2D NETWORK NODES ↓</span>
                </a>
              </div>
            </div>
          </section>

          {/* ==========================================================
              VERTICAL SECTION 1: MAIN EVENTS IN THE SCRIPT
          ========================================================== */}
          <section className="vertical-section section-wrap" id="script-events">
            <div className="panel-heading">
              <div>
                <div className="eyebrow">
                  <i /> SECTION 01 OF 03 · NARRATIVE CHRONOLOGY
                </div>
                <h2>
                  Main <em>Events</em> in {selectedScript.title}
                </h2>
                <p className="panel-sub">
                  Scroll through the extracted chapter turning points below. Click any
                  character badge to inspect their relations and story, or expand the
                  original passage.
                </p>
              </div>

              <div className="panel-controls">
                {availableChapters.length > 0 && (
                  <select
                    className="mini-select"
                    value={chapterFilter}
                    onChange={(e) => setChapterFilter(e.target.value)}
                  >
                    <option value="ALL">All Chapters ({availableChapters.length})</option>
                    {availableChapters.map(([num, label]) => (
                      <option key={num} value={num}>
                        {label}
                      </option>
                    ))}
                  </select>
                )}

                <input
                  type="search"
                  className="mini-search"
                  placeholder="Filter events, chapters, or characters..."
                  value={eventFilter}
                  onChange={(e) => setEventFilter(e.target.value)}
                />
              </div>
            </div>

            {loadingEvents && scriptEvents.length === 0 ? (
              <div className="loading-card">
                Extracting chapter events and textual passages for {selectedScript.title}…
              </div>
            ) : filteredScriptEvents.length === 0 ? (
              <div className="loading-card">
                No narrative events match your filter in this script.
              </div>
            ) : (
              <div className="events-scroll-viewport">
                <div className="event-list">
                  {filteredScriptEvents.map((ev, i) => (
                    <article className="event-row" key={ev.id || i}>
                      <div className="event-index">{padTwo(i + 1)}</div>

                      <div className="event-body">
                        <div className="event-provenance">
                          {ev.chapter?.book || selectedScript.title}
                          {ev.chapter?.number != null
                            ? ` · CHAPTER ${ev.chapter.number}`
                            : ''}
                          {ev.chapter?.title ? ` (${ev.chapter.title})` : ''}
                          {ev.paragraph_start != null
                            ? ` · ¶ ${ev.paragraph_start}–${ev.paragraph_end || ev.paragraph_start}`
                            : ''}
                        </div>

                        <h3>{ev.title}</h3>
                        <p className="event-summary-text">{ev.summary}</p>

                        {ev.paragraphs?.length > 0 && (
                          <details className="passage-drawer">
                            <summary>READ ORIGINAL TRANSLATED PASSAGE ▾</summary>
                            <div className="passage-content">
                              {ev.paragraphs.map((p) => (
                                <div className="passage-line" key={p.number}>
                                  <span>¶ {p.number}</span>
                                  <p>{p.content}</p>
                                </div>
                              ))}
                            </div>
                          </details>
                        )}
                      </div>

                      <div className="event-actions">
                        {ev.character_id && (
                          <button
                            type="button"
                            className="char-jump-btn"
                            onClick={() => openCharacterModal(ev.character_id)}
                          >
                            {ev.character_name || 'CHARACTER'} ↗
                          </button>
                        )}
                      </div>
                    </article>
                  ))}
                </div>
              </div>
            )}
          </section>

          {/* ==========================================================
              VERTICAL SECTION 2: CHARACTERS IN THE SCRIPT
          ========================================================== */}
          <section className="vertical-section section-wrap" id="script-characters">
            <div className="panel-heading">
              <div>
                <div className="eyebrow">
                  <i /> SECTION 02 OF 03 · CANONICAL ENTITIES & RELATIONS
                </div>
                <h2>
                  Characters in <em>{selectedScript.title}</em>
                </h2>
                <p className="panel-sub">
                  Select any character below to inspect their canonical profile, aliases,
                  chapter turning points, and interactive relationship links to other
                  characters.
                </p>
              </div>

              <div className="panel-controls">
                <input
                  type="search"
                  className="mini-search"
                  placeholder={`Search ${scriptCharacters.length} characters in ${selectedScript.title}...`}
                  value={characterFilter}
                  onChange={(e) => setCharacterFilter(e.target.value)}
                />
              </div>
            </div>

            {loadingScriptData ? (
              <div className="loading-card">Loading characters from PostgreSQL…</div>
            ) : filteredScriptCharacters.length === 0 ? (
              <div className="loading-card">No characters match your search filter.</div>
            ) : (
              <div className="character-grid">
                {filteredScriptCharacters.map((char, idx) => (
                  <button
                    key={char.id}
                    type="button"
                    className="character-card"
                    onClick={() => openCharacterModal(char)}
                  >
                    <div className="char-card-top">
                      <small>ENTITY / {padTwo(idx + 1)}</small>
                      {char.aliases?.length > 0 && (
                        <span className="char-alias-badge">
                          +{char.aliases.length} ALIASES
                        </span>
                      )}
                    </div>

                    <strong>{char.name}</strong>

                    <p className="char-card-role">
                      {char.description ||
                        char.role ||
                        `Canonical figure in ${selectedScript.title}`}
                    </p>

                    <span className="char-card-cta">
                      VIEW STORY & RELATIONS ↗
                    </span>
                  </button>
                ))}
              </div>
            )}
          </section>

          {/* ==========================================================
              VERTICAL SECTION 3: TEAMMATE'S UPGRADED 2D CHARACTER MAP
          ========================================================== */}
          <section className="vertical-section section-wrap" id="script-network">
            <div className="panel-heading">
              <div>
                <div className="eyebrow">
                  <i /> SECTION 03 OF 03 · 2D CO-OCCURRENCE CONSTELLATION
                </div>
                <h2>
                  {selectedScript.title} <em>Network Map</em>
                </h2>
                <p className="panel-sub">
                  Filter by archetype, adjust connection strength, or search any node.
                  Hover to highlight neighbors, click a node to inspect its strongest
                  connections, and click <strong>Read Their Story</strong> to open their
                  full dossier.
                </p>
              </div>
            </div>

            <div className="network-layout">
              {/* ---------- Left Control Panel (Teammate's Sidebar) ---------- */}
              <aside className="graph-sidebar">
                <form
                  onSubmit={handleGraphSearch}
                  style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}
                >
                  <div className="graph-sidebar-label">SEARCH NODE</div>
                  <input
                    className="mini-search"
                    type="search"
                    list="graph-character-names"
                    placeholder="Find a character..."
                    value={graphSearch}
                    onChange={(event) => {
                      setGraphSearch(event.target.value)
                      setGraphSearchMiss(false)
                    }}
                    style={{ width: '100%', minWidth: 0 }}
                  />
                  <datalist id="graph-character-names">
                    {scriptGraph.nodes.map((n) => (
                      <option key={n.id} value={n.name} />
                    ))}
                  </datalist>
                  <button
                    type="submit"
                    style={{ ...chipStyle(true, '#d8b77c'), justifyContent: 'center' }}
                  >
                    FOCUS CHARACTER
                  </button>
                  {graphSearchMiss && (
                    <span style={{ color: '#ff9999', fontSize: '12px' }}>
                      Character not found in graph
                    </span>
                  )}
                </form>

                <div>
                  <div className="graph-sidebar-label" style={{ marginBottom: '8px' }}>
                    CATEGORIES
                  </div>
                  <div style={{ display: 'flex', flexDirection: 'column', gap: '6px' }}>
                    {Object.entries(GROUP_META)
                      .filter(([key]) => groupCounts[key])
                      .map(([key, meta]) => {
                        const hidden = hiddenGroups.includes(key)
                        return (
                          <button
                            key={key}
                            type="button"
                            onClick={() => toggleGroup(key)}
                            title={hidden ? `Show ${meta.label}` : `Hide ${meta.label}`}
                            style={{
                              display: 'flex',
                              alignItems: 'center',
                              gap: '10px',
                              padding: '7px 10px',
                              borderRadius: '8px',
                              cursor: 'pointer',
                              background: hidden ? 'transparent' : `${meta.color}1a`,
                              border: `1px solid ${
                                hidden ? 'rgba(218, 188, 133, 0.14)' : `${meta.color}66`
                              }`,
                              color: hidden ? '#6c7396' : '#eef1ff',
                              textAlign: 'left',
                              fontSize: '12px',
                            }}
                          >
                            <span
                              style={{
                                width: '10px',
                                height: '10px',
                                borderRadius: '50%',
                                background: meta.color,
                                boxShadow: hidden ? 'none' : `0 0 8px ${meta.color}`,
                                opacity: hidden ? 0.3 : 1,
                              }}
                            />
                            <span style={{ flex: 1 }}>{meta.label}</span>
                            <span style={{ color: '#8c929e', fontSize: '11px' }}>
                              {groupCounts[key]}
                            </span>
                          </button>
                        )
                      })}
                  </div>
                </div>

                <label style={{ display: 'flex', flexDirection: 'column', gap: '6px' }}>
                  <span className="graph-sidebar-label">SHOW</span>
                  <select
                    className="mini-select"
                    value={graphTopN}
                    onChange={(event) => setGraphTopN(Number(event.target.value))}
                    style={{ width: '100%', minWidth: 0 }}
                  >
                    <option value={25}>Top 25</option>
                    <option value={40}>Top 40</option>
                    <option value={75}>Top 75</option>
                    <option value={150}>Top 150</option>
                    <option value={0}>All characters</option>
                  </select>
                </label>

                <label style={{ display: 'flex', flexDirection: 'column', gap: '6px' }}>
                  <span className="graph-sidebar-label">
                    CONNECTION STRENGTH ·{' '}
                    <strong style={{ color: '#f2eee7' }}>{graphMinWeight}+</strong>
                  </span>
                  <input
                    type="range"
                    min={1}
                    max={Math.min(maxLinkWeight, 40)}
                    value={Math.min(graphMinWeight, Math.min(maxLinkWeight, 40))}
                    onChange={(event) => setGraphMinWeight(Number(event.target.value))}
                    style={{ accentColor: '#d8b77c' }}
                  />
                </label>

                <div style={{ display: 'flex', gap: '28px' }}>
                  <div>
                    <div
                      style={{
                        fontFamily: 'var(--serif)',
                        fontSize: '28px',
                        color: '#d8b77c',
                      }}
                    >
                      {visibleGraph.nodes.length}
                    </div>
                    <div className="graph-sidebar-label">NODES</div>
                  </div>
                  <div>
                    <div
                      style={{
                        fontFamily: 'var(--serif)',
                        fontSize: '28px',
                        color: '#d8b77c',
                      }}
                    >
                      {visibleGraph.links.length}
                    </div>
                    <div className="graph-sidebar-label">LINKS</div>
                  </div>
                </div>

                <button
                  type="button"
                  style={{ ...chipStyle(true, '#d8b77c'), justifyContent: 'center' }}
                  onClick={() => {
                    setSelectedNodeId(null)
                    setHoverLink(null)
                    graphRef.current?.zoomToFit(500, 70)
                  }}
                >
                  RESET VIEW ⊡
                </button>
              </aside>

              {/* ---------- Graph Canvas, HUD Bar & Floating Node Inspector ---------- */}
              <div className="graph-shell" ref={graphContainerRef}>
                {scriptGraph.nodes.length > 0 ? (
                  <>
                    {/* Floating Glassmorphic Graph HUD Bar */}
                    <div
                      className="graph-hud-bar"
                      style={{
                        position: 'absolute',
                        top: '14px',
                        left: '14px',
                        zIndex: 4,
                        display: 'flex',
                        alignItems: 'center',
                        gap: '8px',
                        padding: '6px 10px',
                        borderRadius: '10px',
                        background: 'rgba(10, 14, 24, 0.88)',
                        border: '1px solid rgba(218, 188, 133, 0.28)',
                        backdropFilter: 'blur(8px)',
                        flexWrap: 'wrap',
                      }}
                    >
                      <div style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
                        <button
                          type="button"
                          title="Zoom In"
                          style={chipStyle(false)}
                          onClick={() => {
                            const fg = graphRef.current
                            if (fg) fg.zoom(fg.zoom() * 1.35, 300)
                          }}
                        >
                          +
                        </button>
                        <button
                          type="button"
                          title="Zoom Out"
                          style={chipStyle(false)}
                          onClick={() => {
                            const fg = graphRef.current
                            if (fg) fg.zoom(fg.zoom() * 0.74, 300)
                          }}
                        >
                          −
                        </button>
                        <button
                          type="button"
                          title="Zoom to Fit Constellation"
                          style={chipStyle(false)}
                          onClick={() => {
                            setSelectedNodeId(null)
                            setHoverLink(null)
                            graphRef.current?.zoomToFit(500, 70)
                          }}
                        >
                          ⊡
                        </button>
                        <button
                          type="button"
                          title="Center at Origin"
                          style={chipStyle(false)}
                          onClick={() => {
                            graphRef.current?.centerAt(0, 0, 500)
                          }}
                        >
                          ◎
                        </button>
                      </div>

                      <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                        <button
                          type="button"
                          style={chipStyle(graphCurved)}
                          onClick={() => setGraphCurved((prev) => !prev)}
                          title="Toggle curved Bezier arcs vs straight lines"
                        >
                          {graphCurved ? '∿ Curved' : '— Straight'}
                        </button>

                        <button
                          type="button"
                          style={chipStyle(graphParticles)}
                          onClick={() => setGraphParticles((prev) => !prev)}
                          title="Toggle energetic particle flow along connections"
                        >
                          {graphParticles ? '⚡ Energy' : '⊘ Static'}
                        </button>

                        <button
                          type="button"
                          style={chipStyle(showLinkBadges)}
                          onClick={() => setShowLinkBadges((prev) => !prev)}
                          title="Toggle weight badges on connections"
                        >
                          {showLinkBadges ? '🏷 Badges: ON' : '🏷 Badges: OFF'}
                        </button>
                      </div>
                    </div>

                    {/* Live Link Hover Banner */}
                    {hoverLink && (
                      <div
                        className="graph-hover-banner"
                        style={{
                          position: 'absolute',
                          top: '62px',
                          left: '14px',
                          zIndex: 4,
                          display: 'inline-flex',
                          alignItems: 'center',
                          gap: '10px',
                          padding: '7px 14px',
                          borderRadius: '999px',
                          background: 'rgba(10, 14, 24, 0.92)',
                          border: '1px solid rgba(218, 188, 133, 0.4)',
                          color: '#f2eee7',
                          fontSize: '12px',
                          pointerEvents: 'none',
                        }}
                      >
                        <span
                          style={{
                            width: '8px',
                            height: '8px',
                            borderRadius: '50%',
                            background: getNodeColor(hoverLink.source),
                          }}
                        />
                        <strong>{hoverLink.source?.name || 'Entity'}</strong>
                        <span style={{ color: '#d8b77c' }}>⇄</span>
                        <span
                          style={{
                            width: '8px',
                            height: '8px',
                            borderRadius: '50%',
                            background: getNodeColor(hoverLink.target),
                          }}
                        />
                        <strong>{hoverLink.target?.name || 'Entity'}</strong>
                        <span style={{ color: '#9ba3b0', fontSize: '11px' }}>
                          · {hoverLink.weight || 1} co-occurrences
                        </span>
                      </div>
                    )}

                    <ForceGraph2D
                      ref={graphRef}
                      graphData={visibleGraph}
                      width={graphWidth}
                      height={640}
                      backgroundColor="rgba(0,0,0,0)"
                      autoPauseRedraw={false}
                      cooldownTicks={150}
                      d3VelocityDecay={0.3}
                      nodeLabel={(node) => `${node.name} · ${node.mention_count || 0} mentions`}
                      nodeCanvasObject={paintNode}
                      nodePointerAreaPaint={paintNodePointerArea}
                      linkCurvature={graphCurved ? 0.18 : 0}
                      linkCanvasObjectMode={() => 'replace'}
                      linkCanvasObject={paintLink}
                      linkPointerAreaPaint={paintLinkPointerArea}
                      linkDirectionalParticles={getLinkParticles}
                      linkDirectionalParticleSpeed={getLinkParticleSpeed}
                      linkDirectionalParticleWidth={2.4}
                      linkDirectionalParticleCanvasObject={paintParticle}
                      onRenderFramePre={paintBackgroundGrid}
                      onNodeHover={(node) => setHoverNodeId(node ? node.id : null)}
                      onNodeClick={(node) => focusNode(node)}
                      onLinkHover={(link) => setHoverLink(link || null)}
                      onLinkClick={(link, event) => {
                        const hit = pickNodeAt(event)
                        if (hit) focusNode(hit)
                      }}
                      onBackgroundClick={(event) => {
                        const hit = pickNodeAt(event)
                        if (hit) {
                          focusNode(hit)
                          return
                        }
                        setSelectedNodeId(null)
                        setHoverLink(null)
                      }}
                      onEngineStop={handleEngineStop}
                    />

                    {visibleGraph.nodes.length === 0 && (
                      <div
                        style={{
                          position: 'absolute',
                          inset: 0,
                          display: 'flex',
                          alignItems: 'center',
                          justifyContent: 'center',
                          color: '#9ba3b0',
                        }}
                      >
                        No characters match these filters.
                      </div>
                    )}

                    <div
                      style={{
                        position: 'absolute',
                        left: '16px',
                        bottom: '12px',
                        fontSize: '11px',
                        color: '#8c929e',
                        pointerEvents: 'none',
                      }}
                    >
                      Hover to highlight · Click any node for details · Scroll to zoom · Drag to pan
                    </div>

                    {/* Floating Selected Node Details Card */}
                    {selectedNode && (
                      <div className="graph-inspector-card">
                        <button
                          type="button"
                          aria-label="Close details"
                          onClick={() => setSelectedNodeId(null)}
                          style={{
                            position: 'absolute',
                            top: '8px',
                            right: '12px',
                            background: 'none',
                            border: 'none',
                            color: '#d8b77c',
                            fontSize: '22px',
                            cursor: 'pointer',
                          }}
                        >
                          ×
                        </button>

                        <div
                          style={{
                            fontSize: '10px',
                            fontWeight: 700,
                            letterSpacing: '0.18em',
                            color: getNodeColor(selectedNode),
                          }}
                        >
                          {(GROUP_META[selectedNode.group] || GROUP_META.other).label.toUpperCase()}
                        </div>

                        <h3
                          style={{
                            fontFamily: 'var(--serif)',
                            fontSize: '30px',
                            fontWeight: 500,
                            margin: '4px 0 6px',
                            color: '#ffffff',
                          }}
                        >
                          {selectedNode.name}
                        </h3>

                        <div style={{ fontSize: '12px', color: '#9ba3b0' }}>
                          {selectedNode.mention_count || 0} mentions ·{' '}
                          {neighborMap.get(selectedNode.id)?.size || 0} connections shown
                        </div>

                        {selectedConnections.length > 0 && (
                          <>
                            <div
                              style={{
                                margin: '14px 0 6px',
                                fontSize: '9px',
                                fontWeight: 700,
                                letterSpacing: '0.2em',
                                color: '#d8b77c',
                              }}
                            >
                              STRONGEST CONNECTIONS
                            </div>
                            <div
                              style={{
                                display: 'flex',
                                flexDirection: 'column',
                                gap: '6px',
                              }}
                            >
                              {selectedConnections.map(({ node, weight }) => {
                                const maxW = selectedConnections[0]?.weight || 1
                                const pct = Math.max(14, Math.min(100, Math.round((weight / maxW) * 100)))
                                const targetColor = getNodeColor(node)
                                return (
                                  <button
                                    key={node.id}
                                    type="button"
                                    onClick={() => focusNode(node)}
                                    style={{
                                      display: 'flex',
                                      flexDirection: 'column',
                                      gap: '5px',
                                      padding: '7px 10px',
                                      background: 'rgba(216, 183, 124, 0.08)',
                                      border: '1px solid rgba(218, 188, 133, 0.2)',
                                      borderRadius: '6px',
                                      color: '#f2eee7',
                                      fontSize: '12px',
                                      cursor: 'pointer',
                                      textAlign: 'left',
                                    }}
                                  >
                                    <div
                                      style={{
                                        display: 'flex',
                                        justifyContent: 'space-between',
                                        alignItems: 'center',
                                        width: '100%',
                                      }}
                                    >
                                      <span style={{ display: 'inline-flex', alignItems: 'center', gap: '7px' }}>
                                        <span
                                          style={{
                                            width: '7px',
                                            height: '7px',
                                            borderRadius: '50%',
                                            background: targetColor,
                                          }}
                                        />
                                        {node.name}
                                      </span>
                                      <span style={{ color: '#d8b77c', fontWeight: 700 }}>{weight}</span>
                                    </div>
                                    <div
                                      style={{
                                        width: '100%',
                                        height: '3px',
                                        borderRadius: '999px',
                                        background: 'rgba(255, 255, 255, 0.08)',
                                        overflow: 'hidden',
                                      }}
                                    >
                                      <div
                                        style={{
                                          width: `${pct}%`,
                                          height: '100%',
                                          background: `linear-gradient(90deg, ${getNodeColor(selectedNode)}, ${targetColor})`,
                                        }}
                                      />
                                    </div>
                                  </button>
                                )
                              })}
                            </div>
                          </>
                        )}

                        <button
                          type="button"
                          onClick={() => {
                            const match =
                              scriptCharacters.find((c) => c.id === selectedNode.id) ||
                              allCharacters.find((c) => c.id === selectedNode.id) ||
                              selectedNode
                            openCharacterModal(match)
                          }}
                          style={{
                            ...chipStyle(true, '#d8b77c'),
                            marginTop: '14px',
                            width: '100%',
                            justifyContent: 'center',
                          }}
                        >
                          READ THEIR STORY ↗
                        </button>
                      </div>
                    )}
                  </>
                ) : (
                  <div className="loading-card" style={{ border: 0 }}>
                    {loadingScriptData
                      ? 'Computing 2D character co-occurrence topology…'
                      : graphError || 'No co-occurrence links recorded for this script yet.'}
                  </div>
                )}
              </div>
            </div>
          </section>

          <footer>
            <span>MYTHVERSE · {selectedScript.title.toUpperCase()}</span>
            <button type="button" className="footer-link-btn" onClick={returnToArchive}>
              ← RETURN TO ALL SCRIPTS
            </button>
            <a
              href="#detailView"
              onClick={(e) => {
                e.preventDefault()
                window.scrollTo({ top: 0, behavior: 'smooth' })
              }}
            >
              TOP OF SCRIPT ↑
            </a>
          </footer>
        </main>
      )}

      {/* ============================================================
          CHARACTER DOSSIER, RELATIONS & TURNING POINTS MODAL
      ============================================================ */}
      {modalOpen && selectedCharacter && (
        <div className="modal">
          <div className="modal-backdrop" onClick={() => setModalOpen(false)} />

          <article className="character-sheet">
            <button
              type="button"
              className="modal-close"
              onClick={() => setModalOpen(false)}
              aria-label="Close character record"
            >
              ×
            </button>

            <div className="eyebrow">
              <i /> CANONICAL CHARACTER DOSSIER
              {selectedScript ? ` · ${selectedScript.title.toUpperCase()}` : ''}
            </div>

            <h2>{selectedCharacter.name}</h2>

            <p className="modal-role-subtitle">
              {characterStory?.profile?.role ||
                selectedCharacter.description ||
                selectedCharacter.role ||
                'Canonical Mythological Entity'}
            </p>

            {loadingStory ? (
              <div className="loading-card">
                Loading character relationships and turning points…
              </div>
            ) : (
              <>
                {characterStory?.profile?.background && (
                  <div className="modal-section">
                    <h3>CANONICAL BACKGROUND</h3>
                    <p className="modal-description">
                      {characterStory.profile.background}
                    </p>
                  </div>
                )}

                {characterStory?.aliases?.length > 0 && (
                  <div className="modal-section">
                    <h3>EPITHETS & ALIASES IN TEXT</h3>
                    <div className="relation-list">
                      {characterStory.aliases.map((alias) => (
                        <span key={alias} className="alias-tag">
                          {alias}
                        </span>
                      ))}
                    </div>
                  </div>
                )}
                {/* CROSS-SCRIPT DROPDOWN & DIFFERENCE INSPECTOR */}
                <div className="modal-section">
                  <h3>COMPARE CHARACTER ACROSS SCRIPTS</h3>
                  <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
                    <select
                      className="mini-select"
                      value={modalSourceId ?? ''}
                      onChange={(e) => handleModalSourceChange(e.target.value)}
                      style={{
                        width: '100%',
                        padding: '11px 14px',
                        fontSize: '13px',
                        borderRadius: '8px',
                        background: 'rgba(12, 16, 28, 0.92)',
                        border: '1px solid rgba(216, 183, 124, 0.45)',
                        color: '#f2eee7',
                        cursor: 'pointer',
                      }}
                    >
                      {sources.map((src) => {
                        const count =
                          characterStory?.source_mention_counts?.[String(src.id)] ?? 0
                        const labelSuffix =
                          count > 0
                            ? `(${count} ${count === 1 ? 'mention' : 'mentions'})`
                            : '(0 mentions of this character in this script)'
                        return (
                          <option key={src.id} value={src.id}>
                            {src.title} {labelSuffix}
                          </option>
                        )
                      })}
                    </select>

                    {(() => {
                      const breakdown = characterStory?.source_breakdown || {}
                      const curr = breakdown[String(modalSourceId)]
                      const fallbackPrevId =
                        previousModalSourceId && previousModalSourceId !== modalSourceId
                          ? previousModalSourceId
                          : sources.find((s) => s.id !== modalSourceId)?.id ?? modalSourceId
                      const prev = breakdown[String(fallbackPrevId)]

                      if (!curr) return null

                      const currAliases = curr.aliases_used || []
                      const prevAliases = prev?.aliases_used || []
                      const prevAliasSet = new Set(prevAliases.map((a) => a.toLowerCase()))
                      const currAliasSet = new Set(currAliases.map((a) => a.toLowerCase()))

                      const addedAliases = currAliases.filter(
                        (a) => !prevAliasSet.has(a.toLowerCase())
                      )
                      const missingAliases = prevAliases.filter(
                        (a) => !currAliasSet.has(a.toLowerCase())
                      )

                      const currCo = curr.co_characters || []
                      const prevCo = prev?.co_characters || []
                      const prevCoSet = new Set(prevCo.map((c) => c.toLowerCase()))
                      const uniqueCoChars = currCo.filter(
                        (c) => !prevCoSet.has(c.toLowerCase())
                      )

                      if (curr.mention_count === 0) {
                        return (
                          <div
                            style={{
                              padding: '14px 16px',
                              borderRadius: '8px',
                              background: 'rgba(255, 77, 109, 0.08)',
                              border: '1px solid rgba(255, 77, 109, 0.35)',
                              color: '#f2eee7',
                              fontSize: '13px',
                              lineHeight: 1.6,
                            }}
                          >
                            <strong style={{ color: '#ff8fa3' }}>
                              0 mentions of {selectedCharacter.name} in {curr.source_title}.
                            </strong>
                            {prev && prev.source_id !== curr.source_id && (
                              <div style={{ marginTop: '6px', color: '#b7c0d1' }}>
                                Compared to <strong>{prev.source_title}</strong>, where{' '}
                                {selectedCharacter.name} appears in{' '}
                                <strong>{prev.mention_count}</strong> passages
                                {prevAliases.length > 0
                                  ? ` under the epithets ${prevAliases.join(', ')}`
                                  : ''}
                                .
                              </div>
                            )}
                          </div>
                        )
                      }

                      return (
                        <div
                          style={{
                            padding: '14px 16px',
                            borderRadius: '8px',
                            background: 'rgba(216, 183, 124, 0.07)',
                            border: '1px solid rgba(216, 183, 124, 0.28)',
                            display: 'flex',
                            flexDirection: 'column',
                            gap: '10px',
                            fontSize: '12.5px',
                            color: '#d9dee8',
                          }}
                        >
                          <div
                            style={{
                              display: 'flex',
                              justifyContent: 'space-between',
                              flexWrap: 'wrap',
                              gap: '8px',
                              borderBottom: '1px solid rgba(216, 183, 124, 0.16)',
                              paddingBottom: '8px',
                            }}
                          >
                            <span>
                              <strong style={{ color: '#ffd166' }}>{curr.source_title}</strong>
                              {prev && prev.source_id !== curr.source_id
                                ? ` vs. ${prev.source_title}`
                                : ''}
                            </span>
                            <span style={{ color: '#d8b77c', fontWeight: 700 }}>
                              {curr.mention_count} mentions · {curr.event_count} events
                              {prev && prev.source_id !== curr.source_id
                                ? ` (was ${prev.mention_count} mentions · ${prev.event_count} events)`
                                : ''}
                            </span>
                          </div>

                          <div>
                            <strong style={{ color: '#f2eee7' }}>
                              Epithets matched in {curr.source_title}:
                            </strong>{' '}
                            {currAliases.length > 0 ? currAliases.join(', ') : 'None recorded'}
                          </div>

                          {prev && prev.source_id !== curr.source_id && (
                            <div style={{ display: 'flex', flexDirection: 'column', gap: '4px' }}>
                              <div>
                                <span style={{ color: '#4ade9a', fontWeight: 600 }}>
                                  + Unique / Added in {curr.source_title}:
                                </span>{' '}
                                {addedAliases.length > 0
                                  ? addedAliases.join(', ')
                                  : `Same epithets as ${prev.source_title}`}
                              </div>
                              {missingAliases.length > 0 && (
                                <div>
                                  <span style={{ color: '#ff9999', fontWeight: 600 }}>
                                    − Used in {prev.source_title} only:
                                  </span>{' '}
                                  {missingAliases.join(', ')}
                                </div>
                              )}
                            </div>
                          )}

                          {currCo.length > 0 && (
                            <div>
                              <strong style={{ color: '#f2eee7' }}>
                                Co-occurring characters in {curr.source_title}:
                              </strong>{' '}
                              {currCo.join(', ')}
                              {prev &&
                                prev.source_id !== curr.source_id &&
                                uniqueCoChars.length > 0 && (
                                  <span style={{ color: '#ffd166' }}>
                                    {' '}
                                    (New in this script: {uniqueCoChars.join(', ')})
                                  </span>
                                )}
                            </div>
                          )}

                          {curr.sample_passage?.content && (
                            <div
                              style={{
                                marginTop: '4px',
                                padding: '8px 10px',
                                borderRadius: '6px',
                                background: 'rgba(8, 11, 20, 0.75)',
                                borderLeft: '3px solid #d8b77c',
                                color: '#b9c2d0',
                                fontStyle: 'italic',
                              }}
                            >
                              <div
                                style={{
                                  fontStyle: 'normal',
                                  fontSize: '10px',
                                  letterSpacing: '0.14em',
                                  color: '#d8b77c',
                                  marginBottom: '4px',
                                }}
                              >
                                SAMPLE APPEARANCE IN {curr.source_title.toUpperCase()} · CH{' '}
                                {curr.sample_passage.chapter_number} ¶{' '}
                                {curr.sample_passage.paragraph_number}
                              </div>
                              "{curr.sample_passage.content.slice(0, 260)}
                              {curr.sample_passage.content.length > 260 ? '…' : ''}"
                            </div>
                          )}
                        </div>
                      )
                    })()}
                  </div>
                </div>

                <div className="modal-section">
                  <h3>
                    CHARACTER RELATIONS (CLICK ANY CHARACTER TO JUMP TO THEIR STORY)
                  </h3>
                  {characterStory?.related_characters?.length > 0 ? (
                    <div className="relation-list">
                      {characterStory.related_characters.map((rel) => (
                        <button
                          key={`${rel.id}-${rel.relationship}`}
                          type="button"
                          className="relation-pill"
                          onClick={() => openCharacterModal(rel)}
                        >
                          <strong>{rel.name}</strong>
                          <small>{rel.relationship || 'Connected'} ↗</small>
                        </button>
                      ))}
                    </div>
                  ) : (
                    <p className="modal-description">
                      No explicit family/alliance relation edges recorded for this entity.
                    </p>
                  )}
                </div>

                <div className="modal-section">
                  <h3>
                    MAIN TURN OF EVENTS ({characterStory?.events?.length || 0})
                  </h3>
                  {!characterStory?.events || characterStory.events.length === 0 ? (
                    <p className="modal-description">
                      No chapter-level events recorded for {selectedCharacter.name} in this
                      script.
                    </p>
                  ) : (
                    <div className="modal-events-stack">
                      {characterStory.events.map((ev, idx) => (
                        <div className="modal-event" key={ev.id || idx}>
                          <div className="modal-event-meta">
                            {ev.chapter?.book || selectedScript?.title || 'Script'}
                            {ev.chapter?.number != null
                              ? ` · Chapter ${ev.chapter.number}`
                              : ''}
                            {ev.chapter?.title ? ` · ${ev.chapter.title}` : ''}
                            {ev.paragraph_start != null
                              ? ` · ¶ ${ev.paragraph_start}–${ev.paragraph_end || ev.paragraph_start}`
                              : ''}
                          </div>
                          <strong>{ev.title}</strong>
                          <p>{ev.summary}</p>

                          {ev.paragraphs?.length > 0 && (
                            <details className="passage-drawer">
                              <summary>READ ORIGINAL PASSAGE ▾</summary>
                              <div className="passage-content">
                                {ev.paragraphs.map((p) => (
                                  <div className="passage-line" key={p.number}>
                                    <span>¶ {p.number}</span>
                                    <p>{p.content}</p>
                                  </div>
                                ))}
                              </div>
                            </details>
                          )}
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              </>
            )}
          </article>
        </div>
      )}
    </div>
  )
}

export default App