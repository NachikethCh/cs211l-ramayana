--
-- PostgreSQL database dump
--

\restrict s2fUyASr3p6B0xNf1nMtuX8FC2GlaDGmkbIw2t7OxXmMOylNiUcmJGU4kAW2BlF

-- Dumped from database version 16.15 (Ubuntu 16.15-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.15 (Ubuntu 16.15-0ubuntu0.24.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: books; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.books (
    id integer NOT NULL,
    source_id integer,
    book_number integer,
    name text,
    slug text
);


--
-- Name: books_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.books_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: books_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.books_id_seq OWNED BY public.books.id;


--
-- Name: chapter_paragraphs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.chapter_paragraphs (
    id integer NOT NULL,
    chapter_id integer NOT NULL,
    paragraph_number integer NOT NULL,
    content text NOT NULL
);


--
-- Name: chapter_paragraphs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.chapter_paragraphs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: chapter_paragraphs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.chapter_paragraphs_id_seq OWNED BY public.chapter_paragraphs.id;


--
-- Name: chapters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.chapters (
    id integer NOT NULL,
    book_id integer,
    chapter_number integer,
    title text,
    source_url text,
    content text
);


--
-- Name: chapters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.chapters_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: chapters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.chapters_id_seq OWNED BY public.chapters.id;


--
-- Name: character_aliases; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.character_aliases (
    id integer NOT NULL,
    character_id integer NOT NULL,
    alias text NOT NULL
);


--
-- Name: character_aliases_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.character_aliases_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: character_aliases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.character_aliases_id_seq OWNED BY public.character_aliases.id;


--
-- Name: character_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.character_events (
    id integer NOT NULL,
    character_id integer NOT NULL,
    chapter_id integer NOT NULL,
    event_title text NOT NULL,
    event_summary text NOT NULL,
    paragraph_start integer,
    paragraph_end integer,
    importance integer DEFAULT 1
);


--
-- Name: character_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.character_events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: character_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.character_events_id_seq OWNED BY public.character_events.id;


--
-- Name: character_mentions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.character_mentions (
    id integer NOT NULL,
    character_id integer NOT NULL,
    alias_id integer,
    chapter_id integer NOT NULL,
    paragraph_number integer,
    mentioned_text text NOT NULL,
    start_position integer,
    end_position integer
);


--
-- Name: character_mentions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.character_mentions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: character_mentions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.character_mentions_id_seq OWNED BY public.character_mentions.id;


--
-- Name: character_profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.character_profiles (
    id integer NOT NULL,
    character_id integer NOT NULL,
    description text,
    background text,
    role text,
    source_url text
);


--
-- Name: character_profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.character_profiles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: character_profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.character_profiles_id_seq OWNED BY public.character_profiles.id;


--
-- Name: characters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.characters (
    id integer NOT NULL,
    name text NOT NULL,
    description text
);


--
-- Name: characters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.characters_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: characters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.characters_id_seq OWNED BY public.characters.id;


--
-- Name: sources; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sources (
    id integer NOT NULL,
    title text NOT NULL,
    author text,
    translator text,
    year integer,
    language text,
    url text
);


--
-- Name: sources_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sources_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sources_id_seq OWNED BY public.sources.id;


--
-- Name: books id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.books ALTER COLUMN id SET DEFAULT nextval('public.books_id_seq'::regclass);


--
-- Name: chapter_paragraphs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chapter_paragraphs ALTER COLUMN id SET DEFAULT nextval('public.chapter_paragraphs_id_seq'::regclass);


--
-- Name: chapters id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chapters ALTER COLUMN id SET DEFAULT nextval('public.chapters_id_seq'::regclass);


--
-- Name: character_aliases id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_aliases ALTER COLUMN id SET DEFAULT nextval('public.character_aliases_id_seq'::regclass);


--
-- Name: character_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_events ALTER COLUMN id SET DEFAULT nextval('public.character_events_id_seq'::regclass);


--
-- Name: character_mentions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_mentions ALTER COLUMN id SET DEFAULT nextval('public.character_mentions_id_seq'::regclass);


--
-- Name: character_profiles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_profiles ALTER COLUMN id SET DEFAULT nextval('public.character_profiles_id_seq'::regclass);


--
-- Name: characters id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.characters ALTER COLUMN id SET DEFAULT nextval('public.characters_id_seq'::regclass);


--
-- Name: sources id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sources ALTER COLUMN id SET DEFAULT nextval('public.sources_id_seq'::regclass);


--
-- Data for Name: books; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.books (id, source_id, book_number, name, slug) FROM stdin;
1	2	1	Bāla-kāṇḍa	bala-kanda
\.


--
-- Data for Name: chapter_paragraphs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.chapter_paragraphs (id, chapter_id, paragraph_number, content) FROM stdin;
1	1	1	The ascetic Vālmīki asked Nārada , the best of sages and foremost of those conversant with words, ever engaged in austerities and Vedic studies.
2	1	2	Who at present in this world is like crowned with qualities, and with prowess, knowing duty, and grateful, and truthful, and firm in vow.
3	1	3	Who is qualified by virtue of his character, and who is engaged in the welfare of all creatures? Who is learned and capable. Who alone is ever lovely to behold?
4	1	4	Who has subdued his heart, and controlled his anger, is endowed with splendour, and devoid of malice; and whom enraged in battle, do even the gods, fear?
5	1	5	I have great curiosity to hear of such a person. You can, O Maharṣi , [1] know about a man of this description.
6	1	6	Hearing Vālmīki’s words, Nārada, cognizant of the three worlds, said with alacrity, “listen to me”!
7	1	7	Rare as are the qualities mentioned by you, I wifi, O sage, having duly considered, describe to you a person endued with them.
8	1	8	There is one sprung from the line of Ikṣvāku , known by the name of Rāma . He is of subdued soul; and is exceedingly powerful; effulgent; endowed with patience; having senses under control.
9	1	9	He is intelligent; learned in morality; eloquent; crowned with grace; the slayer of foes: broad-shouldered; possessed of mighty arms, a conch-shaped neck, fleshy jaws.
10	1	10	And a broad chest; a powerful bowman; the repressor of foes; having plump shoulder-blades; of arms reaching down to his knees; with a beautiful head, and a graceful forehead; and endowed with excellent might.
11	1	11	And having symmetrical limbs; and of a cool hue; and possessed of prowess; and having a well-developed chest; with expansive eyes; crowned with auspiciousness and favourable marks.
12	1	12	Knowing duty; firm in promise; always engaged in the good of his subjects; of accomplished renown; furnished with knowledge; pure in body and spirit; obedient towards superiors; versed in self-knowledge.
13	1	13	Nāraḍa says—Like Prajāpati himself; blessed with prosperity; protecting all; the destroyer of enemies, and protector of all living beings.
14	1	14	Practising all the duties of his class; and preserving those cleaving to him; versed in the profundities of the Vedas and the Vedāṅgas ; accomplished in archery.
15	1	15	Well versed in the dicta of all the sciences; brilliant; gifted with a good memory; the darling of all; unreproved; of unvanquished spirit; proficient in every branch of learning.
16	1	16	Ever resorted to by the good persons even as the ocean is by the rivers; worthy of being honoured; having an equal regard for all; and capable of filling the heart with ever new sensations.
17	1	17	Crowned with all sort of qualities, he enhances the joys of Kausalyā ; being like that of the sea in gravity, and that of the Himavat in patience.
18	1	18	In prowess, he is like as Viṣṇu , and boasts of the personal attractions of the Moon. In anger he resembles the fire raging at the time of dissolution; and in forgiveness, he is like that of the Earth.
19	1	19	In giving away, he is like the Bestower of riches Kubera , and in truth, he is like another Dharma . Desirous of doing that which would be acceptable to his subjects, king Daśaratha , from fullness of affection, wished to install as his associate in the kingdom his beloved and meritorious eldest son.
20	1	20	Rāma who of infallible prowess, and endued with sterling virtues, and ever intent on the welfare of the people. The king Daśaratha with great pleasure wished to install as the hair-apparent of the kingdom.
21	1	21	Beholding the provisions of the installation, that lady the king’s consort, Kaikeyī , who had previously been promised two boons, even asked him for those viz ., the exile of Rāma, and the installation of Bharata .
22	1	22	Bound by the ties of duty in consequence of his promise, king Daśaratha banished his favourite son Rāma.
23	1	23	In pursuance of his father’s promise, and with the view of compassing the pleasure of Kaikeyī, that heroic one, commanded by his sire, repaired to the forest.
24	1	24	On the eve of his departure for the forest, that enhancer of Sumitrā ’s joy and favourite of his brother (Rāma), his dear brother Lakṣmaṇa , endowed with humility, displaying brotherliness, followed him out of affection.
25	1	25	As Rohiṇī followed with the moon, Rāma’s beloved spouse, sprung in Janaka ’s line—like as an embodiment of Divine power—sear (Rāma) as life itself, and engaged in acts of good, and furnished with every auspicious mark, and the best of wives, followed Rāma. Having been followed far by his father Daśaratha along with the citizens.
26	1	26	Rāma met with the virtuous and beloved king of the Niṣādas ; and then in company with Guha , Lakṣmaṇa, and Sītā , Rāma dismissed his charioteer on the banks of the Ganges at Śṛṅgaverapura .
27	1	27	Then wending from one forest to another, and having crossed many broad rivers, they, in accordance with Bharadvāja ’s directions, arrived at the Citrakūṭa ; and constructing a romantic abode, the three began to live there.
28	1	28	They spent their days in delight, in the company of gods and Gandharvas . And when Rāma had reached the Citrakūṭa, king Daśaratha, distressed on account of his son, went to heaven, bewailing the latter.
29	1	29	When king Daśaratha had passed away heaven, the mighty Bharata, although pressed by the Brāhmaṇas headed by Vasiṣṭha , to rule the kingdom, did not wish for dominion. And that hero went the forest, with the view of propitiating Rāma.
30	1	30	Having come to the high-souled Rāma, with truth for his prowess, he besought his brother, with every mark of respect.
31	1	31	Bharata said, You are only the king conversant with Dharma. And the exceedingly generous, illustrious and mighty Rāma of a cheerful countenance did not wish for the kingdom, in consonance with his father’s injunction. And having made over to Bharata, as his substitute on the throne, his own sandals, Bharata’s elder brother repeatedly forbade him.
32	1	32	And then Bharata, finding his desire not fulfilled, touched Rāma’s feet, and began to rule at Nandigrāma , expecting the return of Rāma.
33	1	33	And when the auspicious Bharata, firm in his promise and of subdued sense, had gone away, Rāma again perceiving there the influx of citizens and others, eagerly entered Daṇḍaka .
34	1	34	Having entered that mighty vast, the lotus-eyed Rāma slew the Rākṣasa Virādha , and saw Śarabhaṅga , Sutīkṣna, Agastya and Agastya’s brother.
35	1	35	He then, advised by Agastya, gladly possessed himself of Indra ’s bow, the inexhaustible arrows, the scimitar, and the quiver.
36	1	36	While Rāma was dwelling there with the rangers of forests, the sages came to him in a body, for the destruction of the Asuras and Rākṣasas .
37	1	37	Thereupon in the presence of those ascetics like the flaming fire, inhabiting the Daṇḍaka forest, he promised to slay those Rākṣasas in battle.
38	1	38	It was while he was living there that, that dweller of Janasthāna , the Rākṣasī Śūrpaṇakhā , capable of assuming any form at will, was disfigured.
39	1	39	It was while living there in the society of the inhabitants of Janasthāna, that Rāma slew in battle the Rākṣasas Khara and Triśiras and Dūṣaṇa , together with their followers, who all had been stirred up by the words of Śūrpaṇakhā. And fourteen thousand Rākṣasas were slain in that battle.
40	1	40	Having leart of the destruction of his relatives, Rāvaṇa wrought into frenzy by anger, sought the help of a Rākṣasa named Mārīca .
41	1	41	And although strongly dissuaded by Mārīca, saying. You ought not to enter into hostilities with that powerful one. Do you, therefore, O Rāvaṇa, excuse me! yet, disregarding those words of his, Rāvaṇa, urged on by Fate, went into that asylum in company with Mārīca.
42	1	42	That one (Mārīca) commanding illusions, having drawn far the king’s sons (Rāma and Lakṣmaṇa), he (Rāvaṇa) carried away Rāma’s wife, slaying the vulture Jaṭāyu .
43	1	43	And beholding the vulture slain and learning of the kidnapping of Mithilā ’s daughter, the descendant of Raghu , deprived of sense, bewailed in grief.
44	1	44	Having with unassuaged sorrow burnt the vulture Jaṭāyu, as he was searching for Sītā in that forest, he fell in with a Rākṣasa, Kabandha by name, of a dreadful and deformed shape. Having slain him, the mighty-armed one burnt his body,—and thereupon he went to heaven.
45	1	45	And the Rākṣasa addressed Rāma saying, O descendant of Raghu, Do you repair to the ascetic, Śabarī , conversant with all systems of morality.
46	1	46	Repairing to Śabarī, that destroyer of foes, gifted with exceeding energy, Rāma, the son of Daśaratha, highly honoured by Śabarī.
47	1	47	Than he met with Hanumān on the banks of the Pampā . Then, agreeably to Hanumān’s advice, the exceedingly powerful Rāma saw Sugrīva . And detailed to him all specially touching Sītā.
48	1	48	Then the monkey Sugrīva, having heard all from Rāma was well pleased with Rāma, and in the presence of fire, made friends with him.
49	1	49	Then the king of monkeys, out of friendship, mournfully related to him all about his hostilities with Vālī .
50	1	50	Then Rāma vowed that he would slay Vālī. Thereupon the monkey described to Rāghava the prowess of Vālī, and he feared lest Rāma should not prove a match for Vālī.
51	1	51	And with the view of convincing Rāghava (as to Vālī’s might), Sugrīva showed to him the huge corpse of Dundubhi , resembling a hill.
52	1	52	And looking at the skeleton, Rāma endued with exceeding prowess, smiling the while, with his toe cast it off at the distance of full ninety miles.
53	1	53	With a single mighty shaft he pierced seven palmyra palms, a hill, and the sixth nether worlds, carrying conviction to Sugrīva.
54	1	54	Thus convinced, the mighty monkey well pleased went with Rāma towards the cave called Kiṣkindhā .
55	1	55	And having arrived there, that best of monkeys, Sugrīva of a tawny and golden hue, set up loud roars. And at those mighty sounds, out came the lord of monkeys; and having obtained Tārā ’s consent came before Sugrīva for battle. Then Rāghava killed Vālī on the spot with a single shaft.
56	1	56	And, in compliance with Sugrīva’s request, having slain Vālī in battle, Rāghava conferred the kingdom on Sugrīva.
57	1	57	Then that best of monkeys having summoned all the various monkeys, sent them in various directions in search of Janaka’s daughter.
58	1	58	Then at the suggestion of the vulture Sampāti , the mighty Hanumān crossed the salt sea extending for a hundred Yojanas (900 miles).
59	1	59	Thereby arriving at the city of Laṅkā , ruled by Rāvaṇa, he found Sītā in the midst of an Aśoka garden, absorbed in thought.
60	1	60	Then having shown her the sign, he related to her all about the friendship between Rāma and Sugrīva, and having convinced Videha ’s daughter, he smashed the gate of the place.
61	1	61	Then having slain five generals, and seven counsellors’ sons, and crushed the heroic Akṣa , he was bound fast (by the armsof Indrajit .)
62	1	62	Then knowing that in virtue of the grand-sire’s boon, he was free, he forgave those Rākṣasas that were leading him (to Rāvaṇa.)
63	1	63	Then having burnt down the city of Laṅkā, with the exception of the place occupied by Mithilā’s daughter, the mighty one returned, with the intention of delivering the glad tidings to Rāma.
64	1	64	That one of immeasurable soul having come before the high-souled Rāma, and circled him addressed him, saying,—I have truly seen Sītā.
65	1	65	Thereafter accompanied by Sugrīva, Rāma repaired to the shore of the mighty ocean, and with shafts resembling the sun, vexed the deep.
66	1	66	Then that lord of rivers, the Ocean, showed himself. And agreeably to the advice of the Ocean, Nala constructed a bridge (over the water.)
67	1	67	By that bridge Rāma went to the city of Laṅkā, and slew Rāvaṇa in battle. And, having recovered Sītā, Rāma experienced high shame (in consequence of Sītā’s having lived so long in Rāvaṇa’s place.)
68	1	68	Language towards Sītā in the presence of all. Incapable of bearing it, the chaste Sītā entered flaming fire.
69	1	69	Thereupon assured by Agni as to the sinlessness of Sītā, Rāma became exceedingly pleased, and was honoured by all the deities. And at that great act of Rāma’s the three worlds with all that was mobile and immobile in them, along with the sages and gods, were well pleased with the mighty-souled Rāghava.
70	1	70	Then installing that foremost of Rākṣasas, Vibhīṣaṇa , on the throne of Laṅkā, Rāma was perfectly easy, and rejoiced exceedingly.
71	1	71	Then Rāma, obtaining a boon from the celestials, revived the monkeys fallen in battle, and surrounded by friends, set out for Ayodhyā on the Puṣpaka .
72	1	72	And repairing to Bharadvāja’s hermitage, Rāma, having truth for his prowess, despatched Hanumān to Bharata.
73	1	73	Then talking over past affairs, accompanied with Sugrīva, Rāma, mounted on the Puṣpaka, and departed for Nandigrāma.
74	1	74	Having arrived at Nandigrāma, the sinless Rāma sheared himself of his matted locks along with his brothers, and having regained Sītā, got back his kingdom
75	1	75	(During his reign) his subjects will enjoy happiness, and contentment, and become hale, and grow in righteousness, and be devoid of mental disquietude and disease, and free from the fear of famine.
76	1	76	Where a no person is to witness his son’s death, and women will be ever chaste, and never bear widow-hood.
77	1	77	And no fear of conflagration (will exercise people), nor creatures be drowned in water. And no danger will come from hunger, or from thieves. And all will live happily as at the Kṛta age.
78	1	78	Having performed with countless gold an hundred horse-sacrifices, and bestowed with due rites ayutas and koṭis [2] of kine on learned persons, and countless wealth on famous Brāhmaṇas, Rāghava will establish an hundred royal families, and will employ each of the four castes in its own duties.
79	1	79	And having reigned for ten thousand and as many hundred years. Rāma will depart for the regions of Brahmā .
80	1	80	He that reads this sacred, sin-destroying, merit-bestowing history of Rāma like that of the Veda itself, becomes cleansed from all sin.
81	1	81	And the man that reads this Rāmāyaṇa conferring length of days, after death, is honoured in heaven, along with his sons, and grandsons, and relations.
82	1	82	If a Brāhmaṇa reads it, he attains excellence in speech; if a Kṣatriya , he will acquire lordship over landed possessions; if a Vaiśya , abundance of wealth in trade; and if a Śūdra , greatness.
83	1	83	[back to top]
84	1	84	[1] :
85	1	85	A great saint. The word, however, signifies one belonging to a particular order of saints.
86	1	86	[2] :
87	1	87	Ayuta is ten thousand; and koṭi is ten millions.
88	2	1	Hearing those words of Nārada , that one of virtuous soul, skilled in speech, together with his disciples, worshipped that great sage.
89	2	2	Having received due honours, that Devarṣi Nārada taking leave of him went to his ethereal regions.
90	2	3	And when Nārada had left for the celestial regions, that holy person went to the banks of the Tamasā not very far from Jāhnavī .
91	2	4	And having arrived at the banks of that river, the pious one, observing a holy spot devoid of mud, spoke to his disciple standing by.
92	2	5	Saying—O Bharadvāja , behold this holy spot devoid of mud. And it is beautiful, and contains pleasant waters, even like the minds of good men.
93	2	6	O child, do you, put down your pitcher, and give me my bark. I will bathe even in this Tamasā, the best of holy spots.
94	2	7	Thus accosted by the high-souled Vālmīki , Bharadvāja ever intent upon serving his spiritual guide, presented the sage his bark.
95	2	8	That one of subdued senses, having received his bark from his disciple, began to range around, surveying that extensive forest.
96	2	9	In the vicinity of the forest, that worshipful one espied a pair of Krauñcas , emitting melodious notes, and ranging around never parting from one another.
97	2	10	At this juncturere, a wicked-minded fowler, singling out the male , without any cause of hostility, slew him in the very presence of the holy man.
98	2	11	Observing him struggling on the earth, bathed in blood, his female companion began to bewail in piteous accents.
99	2	12	At the prospect of her separation from her copper-crested oviparous husband, engaged in sport with extended plumage.
100	2	13	Finding the bird in that condition thus brought down by the fowler, the pity of that pious and righteous-souled Ṛṣi was excited exceedingly.
101	2	14	Then considering it to be an unrighteous deed, with a heart moved with pity, that twice-born one, beholding the weeping Krauñci, spoke these words.
102	2	15	O fowler, since you have slain one of a pair of Krauñcas, you shall never attain prosperity (respect)!
103	2	16	Having uttered this, he got worried within himself What is this that I have said, afflicted with grief for the bird?
104	2	17	Resolving thus in his mind, that highly-wise one and best of sages addressed his disciple, saying.
105	2	18	This speech that I have uttered is of equal bound with metre and accents; it has rhythm and is capable of being chanted according to measure to stringed accompaniment. Let it therefore go forth as a śloka !
106	2	19	When the sage had spoken thus, his disciple, well pleased, assented to his excellent speech; and thereat that pious person was gratified.
107	2	20	Then having duly performed his ablutions at that holy spot, the reverend sage retraced his steps, pondering over the incidents touching the śloka .
108	2	21	His disciple also, accomplished in learning, and of meek demeanour, followed Vālmīki, carrying on his back a pitcher filled with water.
109	2	22	Having entered the hermitage along with his disciple, conversant with righteousness engaged in diverse kinds of talk, revolved in his mind the circumstances connected with the verses.
110	2	23	It came to pass that desirous of seeing the best of sages, there arrived, that lord and creator of all, the effulgent Brahmā , furnished with four countenances.
111	2	24	Beholding him Vālmīki rose up suddenly and, wondering greatly, humbly and silently stood before him with clasped hands.
112	2	25	And duly bending low in reverence, Vālmīki offered that deity water to wash his feet, and other things for reception.
113	2	26	Having sat-down on a highly-honoured seat, that worshipful one enquired after the welfare of that sage Vālmīki knowing no deterioration; and then asked him to be seated.
114	2	27	Having been seated in the presence of the Grand-sire of all, Vālmīki, his mind running upon the self-same subject, became plunged in thought. What a sin has been committed by the wicked-minded one, incited by hostile feeling, that he without cause slew that sweetly-singing Krauñca !
115	2	28	And thereupon, again lamenting that female Krauñca, he, in grief of heart, mentally recited those verses.
116	2	29	Then smiling, Brahmā spoke to the excellent sage,—Those verses of your which you have composed a śloka shall attain celebrity: no doubt need be entertained on this head. It is because I had intended so, that those verses had come out of your lips.
151	3	24	Sītā’s handing a gem to Hanumān; and the breaking down of trees; and the fight of the Rākaṣasis, and the slaughter of the salves.
117	2	30	Do you now, O best of saints, compose the entire history of Rāma . Do you relate to the world the history of the righteous-souled and intelligent Rāma crowned with qualities. And do you, as you have heard it from Nārada.
118	2	31	Relate all what is known, and all what is unknown to the world, O wise one, concerning Rāma, and Lakṣmaṇa , and Videha ’s daughter, and all the Rākṣasas . And even what is not knowm to Nārada, shall be unfolded to you.
119	2	32	No words of yours in this poem shall contain an untruth sacred. Therefore, now compose into verses. This delightful story of Rāma.
120	2	33	As long as the mountains and the seas exist on earth, the history of Rāmāyaṇa will remain prevalent among men.
121	2	34	As long as this story of Rāmāyaṇa shall retain its currency, you shall reside both in this world and in mine.
122	2	35	Having said this, the Lord Brahmā disappeared there. And thereat the sage and his disciples marvelled greatly.
123	2	36	His disciples sang those verses again and again; and, momentarily experiencing pleasure, recited it with exceeding wonder.
124	2	37	Those verses, composed of equal accents, and furnished with four parts, have been sung by the great saint, have, in virtue of frequent repetition, been associated with a world of pathos and have attained the eminence of a śloka .
125	2	38	Now it is the intention of that illustrious and self-centred sage to compose the entire Rāmāyaṇa in this metre.
126	2	39	The great ascetic Vālmīki of gracious appearance and unparalleled renown composed a poetry consisting of hundreds of verses in melodious measure, couching the significance of the history of Rāma.
127	2	40	Listen to the annals of the foremost of Raghu ’s race, and the destruction of the Ten-headed one composed by the ascetic, with Samāsas , Sandhis , Prakṛtis , and Pratayas ; and lucid with sweet and equally-accented words.
128	3	1	Having heard the entire prevalent history of the intelligent Rāma , capable of conferring religious merit and the two other cognate objects, as well as emancipation, Vālmīki again sought to get insight into it
129	3	2	And, sitting himself facing the east on a cushion of kuśa grass, and sipping water according to the ordinance, he addressed himself to the contemplation of the subject through Yoga .
130	3	3	And by virtue of his Yoga powers, he clearly observed before him Rāma, and Lakṣmaṇa , and Sītā , and Daśaratha together with his wives in his kingdom, laughing, and talking, and acting, and bearing themselves as in real life.
131	3	4	He also saw all that was endured by Rāma firm in promise, with his wife as the third accompanist roaming in the forest
132	3	5	And like an embolic myrobalan on his palm, that righteous-souled sage by virtue of his yoga, perceived all that had happened as well as all that would happen in the past.
133	3	6	Having truly seen everything by virtue of his contemplation, that magnanimous one set about recording the charming Rāma’s history.
134	3	7	And agreeably to what had been related by the mighty-souled Nāraḍa, that worshipful saint composed the history of Raghu ’s line, conferring profit and pleasure, and impregnated with qualities fraught with them, and like to the ocean, abounding in riches, and captivating ear and mind.
135	3	8	Rāma’s birth, his mighty prowess, and kindness to all, and popularity, and forbearance, and goodness, and truthfulness.
136	3	9	And the wonderful converse he had with Visvāmitra ; wedding of Janaka ’s daughter; and breaking the bow; the hostilities of Rāma with Rāma ( Paraśurāma ); and the noble qualities of Daśaratha’s son: and Rāma’s installation; and the enmity of Kaikeyī ; and the obstacle in the way of the installation; and the exile of Rāma; and the kings grief, lamentations, and departure for the other regions; and the grief of the subjects, and their dismissal (by Rāma to Ayodhyā ); and the tidings of the lord of Niṣādas ; and the charioteer’s return.
137	3	10	And the swimming of the Gaṅgā and Rāma sinter view with Bharadvāja ; and his arrival at Citrakūṭa in consonance with Bharadvāja’s injunction.
138	3	11	And Rāma’s building a mansion there and sojourn; and Bharata ’s arrival, and his propitiation of Rāma; and Rāma’s offering oblations to the manes of his father.
139	3	12	And the installation of the sandals; and Bharata’s dwelling at Nandigrāma : and Rāma’s removal to Daṇḍaka and killing of Virādha .
140	3	13	And Rāma’s interview with Śarabhaṅga and meeting with Sutīkṣna; and Sītā’s companionship with Anasūyā , and the latter’s painting the former.
141	3	14	And Rāma’s interview with Agastya , and his obtaining the bow from him; and the dialogue of Śūrpaṇakhā and her disfigurement.
142	3	15	And the slaughter of Khara and Triśiras ; and the exertions of Rāvaṇa ; the killing of Mārīca , and the carrying away of Vaidehī .
143	3	16	Rāghava ’s lamentations, and the death of the king of vultures; Rāma’s encounter with Kabandha , and his view of Pampā .
144	3	17	Rāma’s interview with Śabarī , and his subsistence there on fruits and roots; Rāma’s lamentations at Pampā, and meeting with Hanumān .
145	3	18	The former’s sojourn to the Rṣyamūka, and meeting with Sugrīva ; Rāma’s raising the confidence of Sugrīva and his friendship with the latter; and the encounter between Vālī and Sugrīva.
146	3	19	The destruction of Vālī, and the installation of Sugrīva and Tārā ’s lamentations; the understanding between Rāma and Sugrīva as to the time for commencing the march. Rāma’s stay at the wet night; and the ire of Rāma the lion of Raghu’s race; the levying of forces; and the despatch of envoys in deferent directions; and the assignment by Sugrīva of different quarters to the monkeys.
147	3	20	The making over of his ring by Rāma to Hanumān; Ṛkṣa ’s discovery of the cave. The abstemious abode of the monkeys on the shore of the ocean; Hanumān’s interview with Sampāti .
148	3	21	Hanumān’s ascension of the mountain, and his bounding over the main; and his sight of the Maināka at the injunction of Ocean; the roaring of Rākṣasis; Hanumān’s meeting with the Rākṣasa Chāyāgrāha. Hanumān’s destruction of Siṃhikāyā; and Hanumān's sight of Laṅkā .
149	3	22	His entrance by night into Laṅkā; his ascertaining of conduct in times of helplessness; his journey to the Āpāna ground; and his sight of his car Puṣpaka ; his walk to the Aśoka forest, and sight there of Sītā.
150	3	23	His presentation of the ring to Sītā and converse with her; and the roaring of the Rākṣasis; and the dreaming of the dream by Trijaṭā .
152	3	25	The wind-god’s son being taken captive; and his terrible roars while burning down Laṅkā; and his bounding back over the ocean; and the forcible possession of honey.
153	3	26	Hanumān's consoling Rāghava, and handing him the gem; Rāma’s interview with ocean; and Nala ’s constructing the bridge.
154	3	27	The army’s crossing of the ocean; and the nightly siege of Laṅkā; and Rāma, interview with Bibhishana ; the communication as to the means of destruction.
155	3	28	And the killing of Kumbhakarṇa and Meghanāda ; and the destruction of Rāvaṇa, and the recovery of Sītā in the enemy’s city.
156	3	29	And the coronation of Vibhīṣaṇa , and the sight of Puṣpaka; Rāma’s return towards Ayodhyā, and meeting with Bharadvāja.
157	3	30	Despatch of Hanumān; and Rāma’s meeting with Bharata; and the installation of Rāma; and the dismissal of all the forces.
158	3	31	Rāma’s pleasing his subjects and renunciation of Sītā,—alleles besides concerning Rāma on earth, that has not yet taken place,—have been dealt with by the worshipful sage in the following poem.
159	4	1	When Rāma had obtained his kingdom that worshipful sage, Vālmīki , composed the entire history (of that hero in) excellent metre and fraught with high meaning.
160	4	2	The saint recited twenty-four thousand ślokas ; and it consists of five hundred sections, and is divided into six Kāṇḍas with the Uttara .
161	4	3	And having composed it, including as well future incidents to happen afterwards, that lord relected [reflected?] as to who should publish the same before assemblies.
162	4	4	And as that great sage of purified soul was thus pounding, in came Kuśi and Lava , in the guise of the sons of ascetics, and touched his feet.
163	4	5	And he found those illustrious princes the brothers Kuśi and lava, knowing morality, and living in a hermitage, and endowed with rythmic voice, well versed in the Vedas . And finding them of a retentive endowment, and initiated into Vedic studies, that lord thought them how to interpret the Vedas, and that vow-observing one taught them the great Rāmāyaṇa in full, treating of Sītā ’s great life, and the destruction of Paulastya ( Rāvaṇa ).
164	4	6	Those sweet-voiced brothers, resembling Gandharvas in grace, accomplished in music and dancing, and cognizant of Sthāna and Mūrchanā , began to time to the accompaniment of stringed instruments, and fraught with the sentiments of love, pathos, risibility, the irascible, the terrible, and the heroic. And knowing the characteristics that go to make up the Drama , and gifted with mellifluous voices, those blameless princes, coming from Rāma’s body, and resembling him (like two images of one body, they were two images of made of Rāma’s body).
165	4	7	Even as the reflection of the solar or the lunar disc resembles that disc; got by heart that excellent and moral story in its entirety; and those princes versed in the Fine arts, with a concentrated mind chanted it as they had learnt it, in the assemblies of ascetics and Brāhmaṇas and good men.
166	4	8	Once upon a time, those high-souled and pious ones, furnished with every auspicious mark, chanted this poem in an assembly of ascetics of purified souls. Having heard this music, all the ascetics were seized with surprise, and with eyes flooded with tears, exclaimed, Well done! Well done! And well pleased, those saints cherishing Duty.
167	4	9	Praised the praiseworthy Kuśi and Lava as they sang, saying,—Ah! what charming music! What sweetness of the verses!
168	4	10	All this happened long ago, yet it seems as if we saw it before us. And unified with the theme, both of them singing together sweetly, and at a high pitch, by means of ṣaḍja and the other notes, they entranced the audience.
169	4	11	They two thus went on sweetly singing at a high pitch, praised by those mighty sages priding in their asceticism.
170	4	12	Some one in the assembly pleased with them presented them with a water-pitcher; and some one of high fame, being delighted, made them a present of a bark garment; and some one gave them a dark deer skin and some holy thread.
171	4	13	Some gave a kamaṇḍalu (An earthen or wooden water pot used by an ascetic) and some great saint conferred on them a muñja (grass) made girdle; and some person granted them a bṛsī (The seat of an ascetic), and some a kaupina (a small piece of cloth worn by ascetics.)
172	4	14	Then some ascetic, well-pleased, gave them an axe; and some a saffron, another a casual clothings.
173	4	15	And some, a thread for tying up their matted locks; and some gladly gave a twine for binding faggots with, and some ascetic presented them with a sacrificial pot; and some, a quantity of fire-wood; and some, a seat made of udumbara (The glamorous fig tree). And some exclaimed, ‘ Svasti ’; and some joyfully cried, “May you be long-lived!” And all those ascetics of truthful speech conferred on them blessings.
174	4	16	The sages said—Wonderful is the story! And, O you accomplished in all kinds of music! beautifully have you chanted and finished this poem, charming ear and heart, and conferring long life and prosperity, which will afford themes to poets.
175	4	17	And admired everywhere, on one occasion those singers were seen by Bharata ’s elder brother, in a street of Ayodhyā , sparsely scattered with stalls. And having had the brothers Kuśi and Lava brought under his roof, that destroyer of enemies, Rāma, accorded those ones worthy of honour, a respectful reception. And having seated himself on a throne of excellent gold, in the midst of his brothers and counsellors, that lord, Rāma, beholding both the brothers, handsome and of modest demeanour, spoke to Lakṣmaṇa , Bharata and Śatrughna , saying, Do you listen to the story, fraught with excellent sense and composed in excellent measure, as sung by these ones endowed with the divine afflatus. And then he ordered the singers to begin.
176	4	18	Thereupon causing the down of the audience to stand on end, and ravishing their minds and hearts, they began to sing melodiously and distinctly and in as high a pitch as they could command, and in strains rivalling the notes of a Vīṇā . And that song of their enchanted the ear of that assembly.
177	4	19	Rāma said, Although these Kuśa and Lava, of rigid penances, look like ascetics, yet they bear on their persons the signs of royalty. And, besides, the story conduces to my fame. Do you, therefore, listen to that history fraught with great worth!
178	4	20	And then commanded by Rāma, they began to chant according to the Mārga mode, and Rāma seated in the midst of his court, was drawn to the music, anxious for the perpetuation of his history.
179	5	1	This great story of Rāmāyaṇa treats of those victorious kings commencing with Prajāpati , and having Ikṣvāku for their founder, who ruled the entire earth as no other kings had done so before them, and in whose line Sagara was born—Sagara who dug the ocean, and whom, while out in progress, his sixty-thousand sons followed.
180	5	2	We shall now chant the entire history of that dynasty from the beginning. Do you, with minds free from ill will, listen to that story conferring merit, profit and pleasure.
181	5	3	There is on the banks of the Sarayū a great and flourishing country called Kośala abounding in com and wealth, in which the inhabitants passed their days pleasantly.
182	5	4	The capital of that country was Ayodhyā famed among men, which was founded by Manu himself that foremost of men.
183	5	5	That beautiful and mighty city was twelve Yojanas in length and Three in breadth; and was intersected outside with spacious roads laid out orderly.
184	5	6	And scattered with blown blossoms, and regularly sprinkled with water; the well-arranged broad high-ways looked beautiful.
185	5	7	That one bringing prosperity into great kingdoms, King Daśaratha , lived in that city, like that of the lord of the deities inhabiting the celestial regions.
186	5	8	And the city was furnished with doors and gates, and well-arranged rows of shops. And it contained all kinds of instruments and arms, and was inhabited by all classes of artizans.
187	5	9	And that graceful and matchlessly brilliant city abounded in eulogists and genealogists. And it was crowned with stately edifices with flags, and guarded by hundreds of Śatāghnīs . (A weapon commonly described as a stone set round with iron spiles).
188	5	10	And the mighty city contained theatres for females, and gardens, and mango-groves; and was enclosed by a wall of sāla trees.
189	5	11	And encircled by a deep moat, the city was not accessible for enemies. And it abounded with elephants and horses, and kine and camels and asses.
190	5	12	It was thronged with neighbouring kings come to pay tribute, and inhabited by merchants from various countries.
191	5	13	And adorned with mountain like palaces glittering with gems, and filled with sporting-places for females, and like to Indra ’s Amarāvatī .
192	5	14	The city was wonderful to behold, gleaming with gold-bumished ornaments, and inhabited by troops of courtezans, and abounding in all kinds of gems, and graced with royal palaces.
193	5	15	And it abounded in paddy and rice, and its water was sweet as the juice of the sugar-cane.
194	5	16	And it resounded with the sounds of Dundubhis and Mṛdaṅgas and Vīṇās and Paṇavas .
195	5	17	And that foremost spot of all the earth was like an aerial car obtained in heaven by the Siddhas , through force of ascetic austerities, and thronged with the best specimens of humanity.
196	5	18	That city was filled by king Daśaratha with thousands of such Mahārathas [1] light-handed and accomplished in fight, as could by force of arms or sharpened shafts slaughter infuriated lions and tigers and boars roaming in the forest; yet as would not pierce with arrows persons lorn or abandoned or hiding or fugitive.
197	5	19	A warrior fighting ten thousand Mahārathas .
198	5	20	It abounded mostly in excellent Brāhmaṇas , lighting the sacrificial fire, and crowned with qualities, and versed in the Vedas and the Vedāṅgas , and giving away thousands, and ever abiding by truth, and high-souled, and resembling might ascetics.
199	5	21	[back to top]
200	5	22	[1] :
201	5	23	A warrior coping with ten thousand persons, and protecting both his charioteer and steeds.
202	6	1	In that city of Ayodhyā resided king Daśaratha , versed in the Vedas , commanding all resources, far-sighted, of mighty prowess, dear to the inhabitants both rural and urban.
203	6	2	He was an Athiratha in the Ikṣvāku line, performing sacrifices, engaged in the performance of duties, self-controlled like a Maharṣi , a royal saint famed in the three worlds.
204	6	3	He possessed of strength, the destroyer of foes, having friends, of subdued senses, comparable to Śakra and Vaiśravaṇa by virtue of accumulated riches and other possessions.
205	6	4	As the highly-powerful Manu protected the people, Daśaratha did the same.
206	6	5	As Indra rules Amarāvatī , that one firm in promise, and following duty, profit, and pleasure, ruled that best of cities.
207	6	6	In that excellent city, the men were happy and righteous-souled, and widely-read, and each contented with his possessions, and devoid of covetousness, and speaking the truth.
208	6	7	In that prime of cities, there was none who had not at his command a plenteous supply of the good things, and there was no householder who was not well off in horses and kine, and com and wealth.
209	6	8	And one could see nowhere in Ayodhyā persons given up to lust, or unsightly, or crooked-minded, or unlettered, or atheistical.
210	6	9	And all the men and all the women were of excellent character, and subdued senses, and a happy frame of mind, and both on respect of occupation and conduct spotless like to the Maharṣis .
211	6	10	And all wore ear-rings and tiaras and garlands, and abundantly enjoyed the good things of life. And all were clean, daubing their limbs, and perfuming their persons.
212	6	11	And feeding on pure food, and giving away, and wearing Aṅgadas (A bracelet worn upon the upper arm) and Niṣkas (An ornament for the breast or neck.) and hand-omaments, and repressing passions.
213	6	12	There were not on Ayodhyā persons not lighting the sacrificial fire, or not performing sacrifices, or mean-minded, or thieving, or engaged in improper occupations, or of impure descent.
214	6	13	The Brāhmaṇas of subdued senses were always engaged in the performance of their own duties, giving away in charity, and studying, and receiving gifts with discrimination.
215	6	14	None of them was atheistical or untruthful or be reft of hearing scriptures or detracting or incompetent or illiterate.
216	6	15	There was no Brāhmaṇa who was not versed in the Vedas and Vedāṅgas , or poor-spiriṭ or of insane miad, or afflicted.
217	6	16	And no man and no woman was seen devoid of grace or beauty, or lacking in reverence for their monarch.
218	6	17	The four orders with Brāhmaṇas at their head contained persons serving gods and guests, and endowed with gratitude, and munificent, and heroic, and possessing prowess.
219	6	18	And the men were long-lived; and ever abode by duty and truth; and lived in that best of cities, always surrounded by sons and grandsons and wives.
220	6	19	The Kṣatriyas were obedient to the Brāhmaṇas, and the Vaiśyas followed the Kṣatriyas, and the Śūdras , occupied with their proper vocations, ministered to the three other orders.
289	10	9	Since his birth he had never before seen men and women, or any other creatures living in cities and towns.
221	6	20	That city was ably governed by Daśaratha that lord of Ikṣvāku’s line, even as that foremost of men, the intelligent Manu, had governed it before him.
222	6	21	And as a mountain-cavern abounds with lions, it Was filled with warriors resembling flaming fire, of straight ways, unforbearing, and of accomplished learning.
223	6	22	And the city abounded with excellent horses sprung in Kāmboja , and Vāhlika , and Vanāyu , and the banks of the Sindhu , and like to that best of horses, Hari ’s charger.
224	6	23	With fierce elephants spruhg on the Vindhya mountain, and the Himavat , filled with juice, and of exceeding strength, and resembling hills.
225	6	24	And with Bhadra , Mandra , and Mṛga [1] elephants; and those sprung from the mixture of the three, and from the mixture of Bhadra and Mandra, and from Bhadra and Mṛga, and from Mṛga and Mandra, superior like to Airāvata , and coming from Mahāpadma , Añjanā , and Vāmana breeds; fierce, and looking like hills. And that city was over two Yojanas ; and truly it was called Ayodhyā. (incapable of being conquered.)
226	6	25	Repressing enemies, that city was governed by the great and the exceedingly. And that lord of earth resembling Śakra governed that city of Ayodhya bearing a true name furnished with strong gates and bolts, and auspicious, and graced with excellent edifices, and teeming with thousands.
227	6	26	[back to top]
228	6	27	[1] :
229	6	28	(Those elephants whose limbs are contracted are bhadras ; those whose bodies are fat, slack, and contracted are Mandras : and those whose bodies are lean and large are Mṛgas .)
230	7	1	That high-souled one of Ikṣvāku ’s line had competent counsellors, capable of administering business, of diving into the motives of others, and ever intent upon the good of the monarch. And that heroic king had eight famous counsellors, pure and devoted to the royal service.
231	7	2	They were, Dhṛṣṭi , Jayanta , and Vijaya , and Surāṣṭra , and Rāṣṭravardhana , and Akopa and Dharmapāla , and Sumantra the eight, conversant with profit.
232	7	3	And he had two family priests beloved to him; viz. those foremost of saints. Vasiṣṭha and Vāmadeva .
233	7	4	And he had other counsellors besides, viz; Suyajña , and Jāvālī, and Kāśyapa , and Gautama , and the long-lived Markaṇḍeya, and the regenerate Kātyāyana .
234	7	5	Fver associated in counsel with these Brahmarṣis , his priests and counsellors serving the dynasty from father to son, were learned yet modest, and bashful, and conversant with policy, and of subdued-sense, and auspicious, and high-souled, and accomplished in the art of arms, and of high renown, and cautious, and acting according to their word, and possessing energy, forgiveness and fame and ever precluding their speech with a smile, and never committing themselves to a lie either from anger or interest or desire.
235	7	6	And they were not unknown to what was done or sought to be done in the midst of their own or a hostile party. And they were adept in intercourse with people, and well-tried in friendship by the monarch.
236	7	7	And they were ever busy in replenishing the exchequer and in levying troops. And they did not cherish ill will even towards enemies, when innocent.
237	7	8	And they were heroic, and ever high-spirited, following policy, and protecting those citizens that were pure.
238	7	9	And not bearing ill will towards Brāhmaṇas and Kṣatriyas , and filling the treasury, by inflicting punishments according to the offences of the persons guilty.
239	7	10	And during the time when those pure ones of one mind presided over the justice of the kingdom, there was neither in the city nor the provinces any that was a liar, or wicked, or going after others’ wives. And peace reigned all around the city and the provinces.
240	7	11	And the ministers wore excellent raiment, aṇd ornaments, and were engaged in observing pure vows, and ever kept their eye of policy open in the interest of the monarch.
241	7	12	And the king considered them as crowned with virtues; and they were famed on account of their prowess, concluding unerringly in consequence of their intelligence of other countries. And in all climes and times they could manifest their noble qualities.
242	7	13	They inculcated noble qualities in all aspects and were not devoid of virtues. And they were cognizant of war and peace, and possessed of goodness, passion and ignorance.
243	7	14	And they could keep their counsel and judge of things finely, and were well-versed in the art of policy, and ever fair-spoken.
244	7	15	Surrounded by such counsellors endowed with various qualities, the faultless king Daśaratha ruled the earth.
245	7	16	And gathering intelligence by means of spies, and righteously protecting the subjects, and preserving the people, and not sacrificing his duties.
246	7	17	Famed over the three worlds , and munificent, and firm in promise in battle, the tiger among men ruled over this earth.
247	7	18	Nor did he ever meet with a foe that was either his equal or superior. And possessed of friends, and having obedient commanders, and extricating his thorns by his might, that king ruled the earth, even as the lord of celestials rules heaven.
248	7	19	And surrounded by those counsellors studious of his welfare, and bearing affection towards him, and clever, and competent, that king, by virtue of his prowess in subduing others, resembled the sun surrounded by his rays.
249	8	1	And although engaged in austerities with the view of having sons born to him, the powerful and high-souled king, had no son capable of perpetuating his race.
250	8	2	Mentally turning the matter over, the high-souled one thought, Why do I not celebrate a horse-sacrifice with the intention of obtaining a son?
251	8	3	That highly-energetic, pious and intelligent monarch, in consultation with all his counsellors of sedate minds, having made up his mind to celebrate the sacrifice, said to that best of counsellors, Sumantra ,—Do you speedily summon my spiritual guides, along with the family priests.
252	8	4	Thereupon, going out speeding, Sumantra of swift movements called together all the spiritual guides, as well as others versed in the Vedic ritual .
253	8	5	They were Suyajña , and Vāmadeva , and Jābāli , and Kaśyapa , and Vasiṣṭha , and other principal twice-born ones. And having paid homage to them, the virtuous king Daśaratha then spoke to them these sweet words.
254	8	6	Consistent with duty and interest,—Ever pining on account of a son, I know no happiness,—therefore it is my intention that I should celebrate a horse sacrifice.
255	8	7	I intend to celebrate it according to the ordinance. Do you, therefore, consider how I may attain my object.
256	8	8	Thereat, the Brāhmaṇas with Vasiṣṭha at their head, exclaiming well! Well I approved the words that had fallen from the lips of the monarch.
257	8	9	And exceedingly pleased, they asked Daśaratha,—“Do you order the necessary articles, loose the horse, and prepare the sacrificial ground on the north bank of the Sarayū ." And, O king, since with the intention of obtaining offspring your purpose so piously, you will surely obtain sons after your heart.
258	8	10	And hearing these words of the regenerate ones, the king was highly gratified. And with eyes expanded in delight, he asked his ministers, Do to procure the necessary sacrificial articles, according to the injunction of my spiritual preceptors; and loose a horse protected by a competent person, and followed by one of the chief family priests; and prepare the sacrificial ground on the north bank of the Sarayū; and in due order and according to the ordinance perform the śānti rites required to secure an uninterrupted completion to the ceremony. This ceremony is incapable of being celebrated by every king. Particular care should be taken that the sacrifice is not defective on account of any serious omission; inasmuch as with learned Brahma-Rākṣasas ever on the look-out to spy shortcomings in the ceremony.
259	8	11	The performer thereof speedily perishes, should anything take place not consonant to the ordinance. And do you possessed of ability so arrange, that this sacrifice may be completed in harmony with the ritual.
260	8	12	Thus addressed With due respect, the counsellors listened to the word of the monarch, and said, So be it.
261	8	13	Then hearing those words of that best king again, as heard before, conversant with their duty, having blessed the monarch, taking permission of the king, they returned to their respective quarters.
262	8	14	Dismissing those Brāhmaṇas, the king spoke to his ministers, saying, Do you, even as the family priests have ordered, arrange for the sacrifice!
263	8	15	Having said this, that mighty-minded tiger among men dismissed his ministers, and himself entered into the inner apartment.
264	8	16	And coming there, that lord of men said to his favourite wives, Do you know it for certain that in order to obtain a son I am going to perform a sacrifice.
265	8	17	And hearing those sweet words, the countenances of those shining dames looked resplendent, like lotuses after the cold season is over.
266	9	1	Hearing all about it, the king’s charioteer addressed the monarch in private, saying, Do you listen to what is related in the Purāṇas , and to what I have heard myself!
267	9	2	This horse-sacrifice is enjoined by the family priests; and I have myself heard the following story celebrated in ancient chronicle. And what the worshipful Sanatkumāra had said formerly in the presence of the saints, applies, O king, to the case of your having a son.
268	9	3	Kaśyapa has a son known by the name of Vibhāṇḍaka. He will get a son called Ṛṣyaśṛṅga . And he will grow up and pass his days in the forests.
269	9	4	And that foremost of Brāhmaṇas will not know anything else save following his father. And, O king, it is rumoured abroad, and also always said by the Vipras , that the high-souled one will practise (Those that assume the staff and the kamaṇḍalu are reckoned the first order; while those that continue to live with their wives are considered as next in worth.) the two modes of Brahmacarya life.
270	9	5	And he spent some time in serving the sacrificial fire and his famous sire. At this time, the powerful Romapāda of exceeding strength will be famed as king of the Aṅgas . And in consequence of some default on his part, there will occur in his kingdom a terrible and dreadful drought, capable of striking terror in the all.
271	9	6	And filled with grief on account of this drought, the king will call about him Veda -accomplished Brāhmaṇas, and speak to them, saying, You are conversant with the Vedic ritual and the social duties. Do therefore, tell me how to expiate for this evil
272	9	7	Thus accosted by the king, those excellent Brāhmaṇas versed in the Vedas , will say to the ruler of earth.
273	9	8	Do you, O monarch, by all means, bring Vibhāṇḍaka’s son. And having, O king, brought that Brāhmaṇa versed in the Vedas, Vibhāṇḍaka’s son Ṛṣyaśṛṅga, and duly honoured him, do you, O monarch, with a concentrated mind, perform the betrothal of your daughter Śāntā , with him according to the ordinance.
274	9	9	And hearing those words of theirs, the king will began to think as to how he can bring over that one endowed with energy.
275	9	10	Then in consultation with his counsellors, the prudent king having come to a conclusion will, honouring them duly, desire his priest and his courtiers to set out in quest of Ṛṣyaśṛṅga.
276	9	11	Thereupon hearing the king’s words, with aggrieved hearts, and wiṃ heads hanging down, they will beseech the monarch, saying, Afraid of the saint, Vibhāṇḍaka, we shall not be able to repair thither.
277	9	12	Anon hitting upon the appropriate means, they say, ‘We will search for the Vipra , and no blame shall accrue to us.’
278	9	13	Thus by help of courtesans, the saint’s son was brought by the lord of the Aṅgas. And then the god ( Indra ) poured down showers; and the king conferred on him Śāntā.
279	9	14	And now your son-in-law Ṛṣyaśṛṅga will help you in obtaining a son. Now I have related to you what Sanatkumāra had communicated.
280	9	15	Thereupon king Daśaratha , well pleased, asked Sumantra , Do you now tell me by what means Ṛṣyaśṛṅga was brought over (by the lord of the Aṅgas).
281	10	1	Thus asked by the king, Sumantra said these words—I will relate to you how the counsellors brought Ṛṣyaśṛṅga . Do you listen with your counsellors!
282	10	2	The priest together with the counsellors spoke to Romapāda , saying,
283	10	3	“The means that we have hit upon can never fail of effect.’
284	10	4	Ṛṣyaśṛṅga has been brought up in woods; and is engaged in austerities and the study of the Vedas . He is ignorant of the pleasure that ensues from contact with women.
285	10	5	By help of things agreeably ministering to the sense, and ravishing the soul, we shall bring him to the city. Do you, therefore, arrange for them!
286	10	6	Let courtezans of comely presence, clad in ornaments, repair thither. And if well treated, they will by various means bring him here.“
287	10	7	Hearing this, the king said to the priest, “So be it!” Then the priest and courtiers acted accordingly.
288	10	8	In accordance with the instructions, the courtezans entered that great forest; and remaining at some distance from the hermitage, endeavoured to meet with the sober son of the saint ever dwelling in the woods. And satisfied with serving his sire, he never strayed from the hermitage.
290	10	10	It came to pass that on one occasion, walking about at will, Vibhāṇḍaka’s son came to that spot and beheld the courtezans.
291	10	11	Colourfully attired, and singing sweet songs, the women came to the saint’s son and said,
292	10	12	“Who are you? And where are you going, O Brahman ? We wish to learn all this. And why is it that you range alone this far-off forest?
293	10	13	Beholding these beautiful damsels never seen before, he from delight, hastened to inform them of his lineage.
294	10	14	My father is Vibhāṇḍaka; and I am his son. My name is Ṛṣyaśṛṅga and my occupation is known the world over.
295	10	15	This auspicious hermitage hard by belongs to us; and there I shall receive you all in due form O' lovely ones!.”
296	10	16	Hearing the words of the saint’s son, they all consented, and the women went to behold that asylum.
297	10	17	When they had come there, the saint’s son received them hospitably, saying, “Here is Arghya ,” “Here is water for washing the feet,” “Here are fruits and roots.”
298	10	18	And thereupon they readily received his hospitality. And actuated by the fear of the saint, Vibhāṇḍaka, they bent their minds upon departing soon.
299	10	19	They said, Do you also, O twice-born one, receive from us these excellent fruits! O Vipra ! good betide you, eat them without delay.
300	10	20	Thereupon, embracing him joyfully, they gave him sweetmeats and various kinds of savoury viands.
301	10	21	And tasting those things, the glorious one took them for fruits, never tasted before by the dwellers of the forest.
302	10	22	Then, having accosted him the women, feigning the observance of some vow, went away, inspired with the fear of his father.
303	10	23	And when they had gone, that twice-born one, Kaśyapa ’s son, became sad, and suffered from grief of heart and became restless due to sadness.
304	10	24	And the next day his mind momentarily running upon it, the graceful son of Vibhāṇḍaka, endowed with prowess, came to that spot where he had encountered the comely courtesans, adorned with ornaments.
305	10	25	As soon as they observed him coming, they came forward, and said, Do you, O Brāhmaṇa , come into our hermitage.
306	10	26	There are in that asylum diverse kinds of fruits and roots; and there you will surely feed your fill.
307	10	27	Thereupon hearing those words of theirs capable of influencing the heart, he became bent upon going, and the women brought him away.
308	10	28	When that great-souled Vipra had been brought over, the god, Indra , suddenly poured forth plenteous showers, enlivening the spirits of men.
309	10	29	When the ascetic had arrived, with showers, the king approached him in bumble guise, bending his head to the ground.
310	10	30	And taking him into the inner apartments, and in due form conferring upon him in sober mood his daughter Śāntā , the king became happy.
311	10	31	Thus the highly powerful Ṛṣyaśṛṅga together with his wife Śāntā, began to live there, respectfully ministered to in regard to every desire.
312	11	1	And he said again, O foremost of monarchs, do you listen to me as I relate how that intelligent Sanatkumāra , best of deities, spoke.
313	11	2	In the line of Ikṣvāku will be born a righteous king, named Daśaratha , fair of form, and firm in promise.
314	11	3	That king will contract friendship with the ruler of the Aṅgas . And the latter will have a highly pious daughter, Śāntā by name. And the (old) king of the Aṅgas will have a son, named Romapāda . And repairing to him, the highly famous king Daśaratha will speak to Romapāda, O righteous-souled one! I am without issue. Let Śāntā’s husband, desired by you, take charge of this sacrifice of mine, to be celebrated with the object of my obtaining a son to perpetuate the race.
315	11	4	Hearing these words of the king, and having pondered well, he will make over to him Ṛṣyaśṛṅga of subdued senses, together with Śāntā and his children.
316	11	5	And taking that Vipra , that king, his mind free from anxiety, with a glad heart, will prepare for that sacrifice.
317	11	6	And king Daśaratha, knowing duty and desirous of fame, with the intention of obtaining offspring and heaven, with folded hands, will appoint that best of Brāhmaṇas , Ṛṣyaśṛṅga, to conduct the ceremony. And that bringer of good will attain his object at the hands of that foremost of Brāhmaṇas.
318	11	7	And four sons will be born to him of immeasurable prowess, bringing fame to the family, and known by all. Thus spoke formerly in the divine age, that worshipful and foremost of deities, Sanatkumāra.
319	11	8	Therefore, do you, O tiger among men, repairing there, accompanied with your forces and equipage, yourself, O mighty king, bring Ṛṣyaśṛṅga over with due honours.
320	11	9	Hearing Sumantra ’s words, Daśaratha was exceedingly delighted. And hearing these words, and permitted by Vasiṣṭha , he, accompanied with the ladies, and his courtiers, set out for the place where that twice-born one was.
321	11	10	And gradually passing by woods and fells, he arrived at the place where that foremost of ascetics was.
322	11	11	And coming before that best of regenerate ones, he saw that sage’s son near Romapāda, like that of a flaming, fire.
323	11	12	Then the king received him respectfully, and with a delighted mind, on account of the friendship he bore him. He communicated to the intelligent son of the saint, the fact of their intimacy, and then the latter paid homage to Daśaratha.
324	11	13	Having passed seven or eight days with Romapāda, receiving high honours, that foremost of men, Daśaratha spoke to Romapāda, saying, Let your daughter, O king, together with her husbaṇd, O lord of men, repair to my city. I am going to be engaged in a mighty enterprise.
325	11	14	Hearing this as to the journey of that intelligent one, the king said to that Vipra, Do you repair with your wife! Thereupon the saint’s son, promising to go, said to the king, So be it!
326	11	15	Then with the king’s permission, he set out with his wife. Daśaratha and the puissant Romapāḍa clasping each other by the palm, and embracing each other in affection, attained excess, of joy. Then Raghu ’s son, bidding farewell to his friend, set out.
327	11	16	He despatched swift messengers to the citizens, saying, Let the entire city be embellished; let it be perfumed with dhūpa , and watered and decked with pennons.
328	11	17	Hearing of the king’s approach, the citizens joyfully did every thing as per message they had been communicated.
403	14	22	And being wrapped up in cloths, and worshipped with flowers, they looked like the seven Ṛṣis appearing in the welkin.
329	11	18	Then the monarch, preceded by the foremost of Brāhmaṇas before him, entered the decorated city, to the blares of conches and drums.
330	11	19	And beholding that Brāhmaṇa entering the city, duly honoured by the prime of men; subservient to Indra , like to Kaśyapa ’s son entering the celestial regions honoured of the thousand eyed lord of the celestials, all the citizens rejoiced exceedingly.
331	11	20	Then taking him into the inner apartment, and paying him homage according to the ordinance, the king considered himself as having gained his object, in consequence or the presence ot that Brāhmaṇa.
332	11	21	And all the inmates of the inner apartment, seeing the large-eyed Śāntā thus arrived with her husband, experienced excess of joy.
333	11	22	Then honoured by them and the king in especial, she happily spent there some time along with that twice-born one.
334	12	1	Then after a long while, when the charming spring had appeared on the earth, the king conceived the desire of celebrating the sacrifice.
335	12	2	Then bowing down the head before the Vipra effulgent like a celestial, he appointed him to undertake the ceremony, for the purpose of obtaining offspring to perpetuate his line.
336	12	3	Then that Brāhmaṇa said to the lord of the earth, the king, So be it! Get order the necessary provisions procured, free the horse set, and prepare a sacrificial ground on the north bank of the Sarayū .
337	12	4	Then the king spoke to Sumantra , saying, O Sumantra, do you summon speedily Brāhmaṇas versed in the Vedas and priests professing the Vedānta philosophy, Suyajña , and Vāmadeva , and Jābāli , and Kaśyapa , and the priest Vasiṣṭha , together with other excellent twice-born ones.
338	12	5	Thereupon Sumantra endowed with activity, bestirring himself, summoned all those versed in the Vedas.
339	12	6	Then, honouring them duly, the virthous king Daśaratha spoke to them these amiable words, consistent with duty and interest.
340	12	7	Aggrieved on account of a son, I have no happiness on earth, and, therefore, I have intended to celebrate a horse-sacrifice.
341	12	8	So, I would like to perform a horse-sacrifice. And by the grace of the saint’s son, I shall obtain my desire.
342	12	9	Thereupon, the Brāhmaṇas with Vasiṣṭha at their head honoured the words that fell from the king’s lips, saying, Well!
343	12	10	The Brāhmaṇas headed by Ṛṣyaśṛṅga addressed the king, saying, Do you arrange for the provisions, loose the horse, and prepare the sacrificial ground on the north bank of the Sarayū river!
344	12	11	Since you purpose so virtuously for obtaining offspring, you shall obtain four sons of immeasurable prowess.
345	12	12	Hearing those words of the regenerate ones, the king was exceedingly delighted. And cheerfully he spoke these auspicious words to his courtiers.
346	12	13	In accordance with the directions of my spiritual guides, do you speedily procure these provisions, loose the horse well protected, and followed by a priest.
347	12	14	And prepare the sacrificial ground on the north bank of the Sarayū. And perform the ceremonies capable of securing the rites from disturbance.
348	12	15	Surely every king is competent to perform this sacrifice yet care must be taken that no default occurs in it.
349	12	16	For flaws in this foremost of sacrifices are watched by learned Brahma-Rākṣasas . And should it come to be celebrated in violation of the ordinance, the performer thereof shall meet with instant destruction.
350	12	17	And do you so order that this sacrifice of mine may be completed according to the prescribed ritual.
351	12	18	Thereupon honouring those words of the king, the ministers did as ordered.
352	12	19	And having eulogised the king knowing duty, the twice-born ones, with the Monarch’s leave, departed for their respective quarters.
353	12	20	When the Vipras had gone, the mighty-minded lord of men dismissing his counsellors, entered his place.
354	13	1	When after a full one year, spring had again appeared on the face of the earth, the puissant king, intent upon getting offspring through the horse-sacrifice, sough Vasiṣṭha ’s side.
355	13	2	Having saluted Vasiṣṭha and duly paid him homage, he humbly spoke to that best of twice-born ones, with the intention of having offspring.
356	13	3	O Brahman , undertake to perform this sacrifice of mine, according to the ordinance, O foremost of ascetics! do you order so that no impediment may happen to the sacrifice!
357	13	4	You are my kind friend, and prime and mighty spiritual guide. Engaged in it, you will have to bear the entire burden of the ceremony.
358	13	5	Thereupon that best of Brāhmaṇas said to the king, So be it! I will do all that you asked.
359	13	6	He then said to the old Brāhmaṇas well-up in sacrificial affairs, and experienced car-makers, and highly pious aged people, and servants, carrying on the ceremonial operations till the end, and artists, and carpenters, and diggers, and astrologers, and artizans, and dancers, and conductors of theatres, and pure and learned persons variously versed in knowledge, Do you, in obedience to the royal mandate, engage in the sacrificial work!
360	13	7	And fetch bricks by thousands. And do raise structures for the kings, commanding every convenience.
361	13	8	Do you rear goodly and comfortable buildings by hundreds for the Brāhmaṇas, replenished with various meats and drinks.
362	13	9	You should provide spacious apartments for the citizens and the dwellers, of provinces, and separate quarters for the princes, coming from foreign parts. And stables and sleeping apartments be raised for warriors coming from foreign countries.
363	13	10	And dwellings filled with diverse kinds of viands, and commanding everything desirable, and mansions for the lower orders of the citizens, exceedingly beautiful to behold. And meats should be duly dispensed with all hospitality, and not in the indifference of festive occasions, so that all may regard themselves as honourably entertained. And none should be disregarded out of lust or passion.
364	13	11	Those persons, and artizans, that will labour eagerly in the sacrifice, should by turns, be especially entertained.
365	13	12	And servants, who being entertained with gifts, do every thing completely, and omit nothing. And do you, with hearts mollified by love, act so, that all our friends be well pleased with us.
366	13	13	Then they approached Vasiṣṭha, saying, Everything has been performed properly, without anything being left out. And what you say shall be performed, and nothing words, Do you invite all those kings that are pious, and Brāhmaṇas, and Kṣatriyas and Śūdras , by thousands. And do you with due honours bring people from all countries.
367	13	14	With proper honour yourself bring the righteous, truthful, and heroic Janaka , lord of Mithilā . And it is because he is our old friend that I first mention him.
368	13	15	Then do yourself bring the amiable and ever fair-spoken lord of Kāśī , of excellent character, resembling a celestial.
369	13	16	Then do you bring here along with his son, the highly-pious, old king of Kekaya , who is the father-in-law of this tiger of a monarch.
370	13	17	Then also bring with due honours the king of Aṅga , and that mighty archer, the illustrious Romapāda , the friend of that lion among the kings, along with his son.
371	13	18	Also bring with due respect the puissant king of Kosala . The heroic, and highly generous lord of Magadha , versed in all branches of learning. And in accordance with the mandate of the king, do invite the foremost monarchs! And summon the king, of the East, of the Sindhu and Sauvīra countries, and of Saurāṣṭra , and of the South! And speedily bring those monarchs that are attached to us, together with their friends and followers, the mandate of the monarch, bring over these, despatching dignified emissaries.
372	13	19	Having heard those words of Vasiṣtha, Sumantra speedily ordered the emissaries to bring the kings.
373	13	20	The virthous Sumantra, in accordance with the injunction of the ascetic, himself speedily set out for the purpose of bringing the monarchs.
374	13	21	Then the servants came and informed the intelligent Vasiṣtha as to the articles that had been got ready for the sacrifice.
375	13	22	Then well pleased that best of twice-born ones, the ascetic Vasiṣṭha, said to them, Do not give away disrespectfully or lightly. A gift bestowed with disrespect, indubitably destroy the giver.
376	13	23	Then for several days, kings began to pour into Daśaratha ’s city daily and nightly, bringing with them various kinds of gems.
377	13	24	Thereupon Vasiṣṭha well-pleased said to the king, O tiger among men, obeying your mandate the kings have come here; and I too according to merit, have received those excellent kings with respect.
378	13	25	Everything has been carefully made ready for the sacrifice by the persons concerned. Do you, therefore, repair to the sacrificial ground, for performing the sacrifice.
379	13	26	O foremost of monarchs, it behove you to view the place, filled with all desirable objects, and looking as if prepared by imagination herself.
380	13	27	Then in accordance with the injunctions of both Vasiṣṭha and Ṛṣyaśṛṅga , the king came to the sacrificial spot on a day presided over by an auspicious star.
381	13	28	Then, with, Ṛṣyaśṛṅga at their head, Vasiṣṭha and the other principal Brāhmaṇas wending to me sacrificial ground, began the ceremony, according to the ordinance; and in due form. And the auspicious king, in company with his wives, was initiated into the ceremony.
382	14	1	After the expiry of full one year, when the sacrificial horse had returned, the sacrifice, of the king commenced on the north bank of the Sarayū .
383	14	2	And with Ṛṣyaśṛṅga at their head, the principal twice-born ones began the proceedings in that mighty horse-sacrifice of that high-souled monarch.
384	14	3	And the priests, each duly and according to the ordinance performing his proper part, engaged in the ceremony in consonance with the scriptures.
385	14	4	And the regenerate ones, having performed the pravargya as well as the upasada according to the ordinance, duly completed the additional ceremonies. Then, worshipping the deities with glad hearts, those foremost of ascetics duly performed the morning ablutions and the other prescribed rites.
386	14	5	The oblations of clarified butter first having been offered to Indra , according to the ritual, the king with a purified heart performed his ablutions. And then the mid-day ablutions took place in proper sequence.
387	14	6	Those foremost of Brāhmaṇas , in due form, and according to the ordinance, officiated at the third bath of that high-souled monarch.
388	14	7	The priests presided over by Ṛṣyaśṛṅga, invoked Śakra and the other deities, reciting measured mantras .
389	14	8	The sacrificial priests, chanting sweet Samans and soft mantras , duly invoking the dwellers of the celestial regions, offered each his share of the oblations.
390	14	9	And no part of the ceremony was performed improperly, or left out, and every thing was satisfactorily celebrated with mantras .
391	14	10	And on that day no Brāhmaṇa ever felt tired, or hungry and there was none that was not learned, or that was not followed by an hundred persons.
392	14	11	Brāhmaṇas, and Śūdras having among them ascetics, and Śramaṇas , and the aged, and the infirm, and women, and children, were continually fed. And although they ate their fill, yet they know no repletion.
393	14	12	And Give food, and clothes of various kinds (was heard all around) And those employed in the task gave away profusely.
394	14	13	And every day food dressed properly in due form was to be seen in countless heaps resembling hills.
395	14	14	And men and women coming from various countries to the sacrifice of that high-souled one were excellently entertained with meats and drinks.
396	14	15	The foremost regenerate ones said, The viands have been prepared in the prescribed form, and they taste excellent. We have been gratified. God bless you! All this was heard by the descendant of Raghu .
397	14	16	Persons adorned with ornaments distributed the victuals among the Brāhmaṇas, and they were assisted by others wearing jewelled pendants.
398	14	17	In the interval between the completion of one bath and the beginning of the next, mild and eloquent Vipras , desirous of victory, engaged in various disputations.
399	14	18	Every day in that sacrifice, skilful Brāhmaṇas, engaged in the ceremony, did every thing, according to the ritual.
400	14	19	There was no twice-born one that was not versed in the Vedas and the Vedāṅgas , or that did not observe vows, or that was not profoundly learned, nor did any assist at the sacrifice that could not argue ably.
401	14	20	And when the time came for planting the Yūpas of bilva , as many of catechu, and as many of Palasa , and one of Śleṣmātaka , and two of Devadāru well-made and measuring two outstretched arms.
402	14	21	Persons versed in the arts and science of sacrifice constructed these Yūpas . And at the time of throwing up the Yūpas for embellishing the sacrifice, these one and twenty Yūpas , each measuring one and twenty Aratnis , having eight angles, and smooth-faced, were decked out in one and twenty pieces of cloth, and were firmly planted with due ceremonies by artisans.
404	14	23	And an adequate number of bricks was also duly made (for the ceremony.) And Brāhmaṇas accomplished in the arts constructed the sacrificial fire-place with those bricks.
405	14	24	That fire-place of that lion among kings, set by skilful Brāhmaṇas, consisting on three sides of eighteen bricks, looked like the goldenwinged Garuḍa . And for the purpose of sacrificing them to the respective deities were collect beasts and reptiles, and birds, and horses, and aquatic animals. And the priests sacrificed all these in proper form.
406	14	25	And to these Yūpas were bound, three hundred beasts, as well as the foremost of the best horses belonging to king Daśaratha .
407	14	26	Then Kausalyā , having performed the preliminary rites, with three strokes slew that horse, experiencing great glee.
408	14	27	And with the view of reaping merit, Kausalyā, with an undisturbed heart passed one night with that horse furnished with wings.
409	14	28	Hotas and Adhvaryus , and the Udgatās joined the king’s Vāvātā along with his Mahiṣī and Parivṛtti .* And priests of subdued senses, well-up in sacrificial rites, began to offer oblations with the fat of the winged-horse, according to the ordinance.
410	14	29	*The Kṣatriya kings could marry wives from among Ksatriyas , Vaiśyas and Śūdras. The Kṣatriya wife is called Mahiṣī , the Vaiśya wife Vāvātā and the Śūdra wife Parivṛtti .
411	14	30	The lord of men, desirous of removing his sins, at the proper time smelt the odour of the smoke arising from the fat, agreeably to the scriptures.
412	14	31	Then sixteen sacrificial priests in the prescribed form offered the various parts of the horse to the fire.
413	14	32	It is customary in other sacrifices to offer the oblations by means of a Plakṣa bough; but in the horse-sacrifice a cane is used instead. The horse-sacrifice, according to the Kalpa-Sūtras and the Brāhmaṇas, extend over three days. Thereafter, on the first day was the Catuṣṭoma celebrated; and on the second, the Uktha , and on the third the Atirātra .
414	14	33	And then the jyotiṣṭoma , and then Āyuṣtoma , and the Atirātra , and the Abhijit , and the Viśvajit , and the Āptoryāma , all these various great sacrifices were celebrated with due rites.
415	14	34	And in this mighty horse-sacrifice founded of yore by Svayambhū , that perpetuator of his line, the king, bestowed the Eastern quarter on his chief sacrificial priest, the Western on his Adhvaryu , the Southern on Brahmā , and the Northern on the Udgātā , as Dakṣiṇās .
416	14	35	Having completed that sacrifice, that perpetuator of his race, and foremost of men, the king, conferred on the priests the earth; and having conferred it, that auspicious descendant of Ikṣvāku experienced high delight. And then the priests spoke to that monarch, who had all his sins purged off saying.
417	14	36	You alone are worthy to protect the entire world. We do not want the earth; nor can we rule it, being, O lord of Earth, constantly engaged in Vedic studies. Do you, therefore, confer upon us something instead, as the price thereof.
418	14	37	Do you confer upon us gems, or gold, or kine, or anything else, for, O foremost of monarchs, we do not want earth.
419	14	38	Thus addressed by the Brāhmaṇas versed in the Veda , that best of kings bestowed upon them ten lace of kine, and ten Koṭis of gold, and forty of silver.
420	14	39	Then those priests in a body, accepting the wealth, brought it to the ascetic Ṛṣyaśṛṅga and the intelligent Vasiṣṭha . Then having received each his share, those foremost of regenerate ones were exceedingly pleased, and said, We have been highly gratified.
421	14	40	Then to those Brāhmaṇas that had come there, the king with due regard gave Koṭis of gold.
422	14	41	Then to a certain poor twice-born one that asked for gifts, the descendant of Raghu gave an excellent ornament from his own arm.
423	14	42	When the regenerate ones were thus properly gratified, that one cherishing the Brāhmaṇas, with senses intoxicated by excess of joy, reverentially bowed to them.
424	14	43	Thereupon the Brāhmaṇas uttered various blessings upon that generous king, bending low to the earth.
425	14	44	Then having celebrated that excellent and sin-destroying sacrifice, bringing heaven, and incapable of being celebrated by foremost monarchs, king Daśaratha, well pleased, spoke to Ṛṣyaśṛṅga, saying, O you of excellent vows, it behove you to do that whereby my line may increase.
426	14	45	Thereupon the best of Brāhmaṇas told the king that he would have four sons, born to him, as perpetuators of his race.
427	14	46	Hearing these sweet words of his, that foremost of monarchs bended low to him with controlled faculties, and experienced the excess of joy. And then that high-souled one again spoke to Ṛṣyaśṛṅga.
428	15	1	Then that one of capacious intelligence, versed in the Vedas , having pondered for a time, and regained his senses, returned to the king this excellent answer.
429	15	2	On your behalf and with the view of obtaining sons for you, I will by help of mantras laid down in the Atharva Veda , duly celebrate the famous ceremony, capable of crowning you with offspring.
430	15	3	Then with the view of obtaining sons (for the king,) that effulgent one set about the son-conferring ceremony; and in accordance with the ordinance, and with mantras , offered oblations to the sacrificial fire.
431	15	4	And the deities, with the Gandharvas , and the Siddhas , and the principal saints, assembled there duly with the object of each obtaining his share of the offerings.
432	15	5	And having duly assembled there, the deities addressed these words to Brahmā the lord of creatures.
433	15	6	O you possessed of the six attributes, through your grace, a Rākṣasa named Rāvaṇa oppresses us all by his prowess, nor can we baffle him.
434	15	7	O lord, as you have well-pleased conferred on him a boon, we always suffer him in deference to it.
435	15	8	The wicked-minded one harasses the three worlds furnished with prosperity, and bears ill-will against them and seek O defeat Indra , the king of Tridaśa .
436	15	9	And blinded by the boon he has received, that irrepressible one intends to bring down the lord himself of the celestials, and the Yakṣas , and the Gandharvas, and the Brāhmaṇas , and the Asuras .
437	15	10	And the Sun does not bum him, or the Wind blow about him; and at sight of him, that one engarlanded with billows, the Ocean, dares not stir.
438	15	11	Therefore, great is the fear that afflict us, coming from that Rākṣasa of dreadful appearance. And, O lord, it behoves you to devise some means for destroying him.
603	21	17	Suprabhā also brought forth fifty sons named Sanhāras, incapable of being borne, and infallible and powerful.
439	15	12	Thus addressed by the deities in a body, he said, Alas! I have, however, decided on the means of destroying that wicked-souled one. He had asked, ‘May I be incapable of being slain by Gandharvas, and Yakṣas, and gods, and Rākṣasas !,—whereat I said, ‘Be it so!’
440	15	13	Through disdain, the Rākṣasa did not at that time mention men. Therefore, by men alone he is capable of being slain; nor can his end be compassed by any other means.
441	15	14	Hearing this welcome speech uttered by Brahmā, the deities and the Maharṣis became exceedingly delighted.
442	15	15	At this juncture, that lord of the universe, the highly-effulgent Viṣṇu , clad in yellow apparel, and bearing in his hands the conch, the discus, and the mace, and adorned with burnished Keyūras , (A bracelet worn on the upper arm.) arrived there, riding Vinatā ’s son; like to the Sun riding the clouds. And worshipped by the foremost of the celestials, he drew near Brahmā, and sat down with a collected mind.
443	15	16	And bending low before him, the deities spoke to him saying, O Viṣṇu, for the benefit of the worlds, we shall appoint you to some work.
444	15	17	Do you, O lord, dividing yourself into four, O Viṣṇu, become born a sons in the three wives, resembling Modesty, Auspiciousness, and Fame, of Ayodhyā ’s lord, king Daśaratha , cognizant of Duty, and munificent, and possessing energy, and like to a Maharṣi . Do you, O Viṣṇu, becoming man, slay in battle this thorn of the worlds, the pampered Rāvaṇa, incapable of being slain by the gods; for the foolish Rākṣasa by virtue of sublimated prowess, baffles the deities, and the Gandharvas, and the Siddhas, and the foremost of saints.
445	15	18	And by him bereft of the sense of right and wrong, have saints and Gandharvas and Apsaras sporting in the groves of Nandana , been wantonly slain.
446	15	19	It is to compass his death that accompanied by the ascetics, we have come here: it is for this that the Siddhas and the Gandharvas and the Yakṣas have taken refuge in you! O God, you are the prime way of us all, O repressor of foes! Do you, for bringing destruction to the enemies of the gods, turn your thoughts to being born as man.
447	15	20	Thus besought, that foremost of gods and chief of celestials, Viṣṇu, worshipped of all creatures, addressed the assembled deities, following Duty, with the grand-sire at their head, saying.
448	15	21	Do you renounce fear! For your behoof, slaying in battle the wily and irrepressible Rāvaṇa, dreadful to the saints and the celestials, together with his sons, and grandsons, and friends, and counsellors, and relatives, and acquaintances, I will abide among mortals, ruling this earth for ten thousand and as many hundred years.
449	15	22	Having thus conferred a boon upon the gods, the lord Viṣṇu of subdued soul fell to thinking as to the place where he would be born among men.
450	15	23	Then that one of eyes resembling lotus-petals, dividing self into four parts, chose even king Daśaratha for his father.
451	15	24	Thereat the celestials and the saints and the Gandharvas and the Rudras and the Apsaras hymned the Slayer of Madhu in excellent hymns.
452	15	25	Do you utterly uproot the haughty Rāvaṇa of fierce prowess and enhanced insolence—that foe of the lord of celestials, who is the occasion of the tears of the three [1]
453	15	26	Slaying that one of terrible prowess, who distresses the three worlds, with his forces and friends, do you, O foremost of gods, your fever of heart removed, repair to the celestial regions protected by you and purged of all its faults and sins.
454	15	27	[back to top]
455	15	28	[1] :
456	15	29	Lit. the thorns of pious ascetics.
457	16	1	Thus besought by the foremost of the celestials, that searcher of hearts, Viṣṇu , although cognizant of the means whereby Rāvaṇa was to be destroyed, asked the gods these amiable words,—What, you gods, is the means of compassing which I could slay that thorn of the ascetics?
458	16	2	Nara means a multitude, and Ayana , dwelling-place. He whose dwelling-place is a multitude, is Nārāyaṇa . Metaphorically, the word means evidently the Scorcher of hearts,—worlds, and dreadful to ascetics!
459	16	3	Thus addressed, the deities answered Viṣṇu, incapable of deterioration, saying,—Assuming the form of a human being, do you in battle slay Rāvaṇa!
460	16	4	He, O repressor of foes, had for a long course of time performed rigid austerities; and thereat, that creator of all, the first-create Brahmā , was well pleased.
461	16	5	And propitiated by his penances, the Master conferred a boon on the Rākṣasa to the effect, that, save man, no fear should come to him from the various beings.
462	16	6	And in the matter of that boon-bestowing, man had formerly been disregarded (by Rāvaṇa). And puffed up with pride in consequence of the boon he received from the Grand-sire.
463	16	7	He commits ravages upon the three worlds and carries away the fair sex by violence. Therefore, O subduer of enemies, we have even fixed upon man for bringing about his death.
464	16	8	Hearing this speech of the celestials, Viṣṇu of subdued soul chose even king Daśaratha for his father.
465	16	9	At that time, eagerly wishing to have sons, that destroyer of enemies, the effulgent king Daśaratha, who was sonless, was celebrating the sacrifice that confer male offspring.
466	16	10	Then, having ascertained the course to follow, Viṣṇu, having greeted the Grand-sire, vanished there, worshipped by deities and the Maharṣis .
467	16	11	And then himself bearing in his hands a capacious vessel made of burnished gold, with a silver cover, dear like that of a spouse, and resembling the divine Creative energy, filled with celestial Pāyasa , (A preparation of milk, rice, and sugar), from out the sacrificial fire of Daśaratha initiated into the ceremony, there arose a mighty being, of unparalleled prowess, high energy, and huge strength, black, and wearing a crimson apparel, with a red face, uttering the blares of a trumpet, and having a body covered with leonine hair, having whiskers and an excellent head of hair, furnished with auspicious marks, and adorned with celestial ornaments, and resembling a mountain-peak, and bearing the prowess of a flaming tiger, and like to the Sun or tongues of flaming fire. And with his eyes fixed upon Daśaratha.
468	16	12	He addressed the king, saying, O monarch, take me as a person commissioned by Prajāpati .
469	16	13	Hearing him speak thus, Daśaratha, with folded hands, said, Lord, you are welcomed? What can I do for you?
470	16	14	Thereupon, that person despatched by Prajāpati again spoke thus, O king, having adored the deities, you have to-day obtained this.
506	17	26	And the mighty-armed Vālī of great prowess and redoubtable strength protected by virtue of the energy of his arms Ṛkṣas , and Gopucchas , and monkeys.
471	16	15	O tiger of a king, accept this excellent and divinely-prepared Pāyasa, conferring sons, health, and affluence, which you are to give to your worthy consorts, saying, Partake it. Through them you will, O monarch, obtain sons, for obtaining whom you have performed this sacrifice.
472	16	16	Thereupon, saying, So be it, the lord of men delightedly placed that divinely-bestowed golden vessel filled with the divine Pāyasa upon his head. And having saluted that wonderful being of gracious presence, he in excess of joy began to go round him again and again.
473	16	17	Then Daśaratha, having received that divinely prepared Pāyasa, waxed exceeding glad; like that of a pauper attaining plenty. Then that highly effulgent being of a wonderful form, having performed that mission of his, vanished even there.
474	16	18	And Daśaratha’s inner apartment, being graced with the rays of joy, looked like the welkin flooded with the lovely beams of the autumnal moon.
475	16	19	Then entering the inner apartment, he spoke to Kausalyā , saying, Take you this, Pāyasa; for this will make you bear a son.
476	16	20	Having said this, the king offered to her a half portion of this Pāyasa. Then he conferred upon Sumitrā a fourth of it.
477	16	21	Then in order that she might have a son, king Daśaratha made over to Kaikeyī an equal portion of what remained. And then having reflected, the mighty-minded one gave to Sumitrā the remaining portion of the Pāyasa resembling ambrosia.
478	16	22	Thus the king dispensed the Pāyasa to each and all of his wives. And those foremost wives of the king, having received that Pāyasa, became exceedingly delighted, and considered themselves as highly honoured.
479	16	23	Then those excellent consorts of the lord of earth, having separately partaken of that choice Pāyasa, shortly bore offspring, resembling fire or the Sun.
480	16	24	The king, beholding those wives of his bearing children, obtained his desire and became delighted; even as Viṣṇu, while being worshipped by the Siddhas and the ascetics.
481	17	1	When Viṣṇu had accepted the sonship of that high-souled king, the self-create Lord addressed the celestials, saying,
482	17	2	For assisting the heroic Viṣṇu firm in promise, always seeking the welfare of us all, do you create powerful beings, assuming shapes at will, cognizant of illusions, heroic, furnished with the celerity of the wind, versed in morality, possessing intelligence, like to Viṣṇu in prowess, unslayable, knowing the ways and means (of war and peace), gifted with excellent bodies, capable of resisting all weapons, and resembling immortals.
483	17	3	And from forth the bodies of the foremost Apsaras , Gandharvis , Yakṣīs , and Pannagis, Ṛkṣis (She-bears) and Vidhyādharis, Kinnaris and Vānaris (She-monkeys) do you produce sons wearing the shapes of monkeys.
484	17	4	Formerly I had created that foremost of bears, Jāmbavān , who suddenly came out of my mouth as I was yawning.
485	17	5	Hearing this mandate of Him possessed of the six attributes, they began to produce sons endowed with monkey’s forms.
486	17	6	And high-souled ascetics, and Siddhas , and Vidyādharas , and Uragas , and Cāraṇas , generated heroic sons, rangers of woods.
487	17	7	And Indra beget as his son that foremost of monkeys, Vālī , resembling the Mahendra hill, and that best of those imparting heat, the Sun, Sugrīva .
488	17	8	Bṛhaspati beget the mighty ape named Tāra , who was the most excellent and intelligent of the prime monkeys.
489	17	9	The Bestower of riches beget as his son the graceful ape Gandhamādana . And Viśvakarman beget that mighty monkey named Nala .
490	17	10	Agni beget as his son the powerful and graceful Nīla in effulgence like to the fire, who surpassed even his sire in energy, prowess, and renown.
491	17	11	And the beautiful Aśvins , endowed with the wealth of loveliness, beget Mainda and Dvivida .
492	17	12	Varuṇa beget the monkey named Suṣeṇa ; and Parjanya beget Śarabha , possessed of great strength.
493	17	13	And the Wind-god beget the graceful monkey named Hanumān , endued with a frame hard as adamant; in fleetness like to Vinatā ’s offspring.
494	17	14	And the most intelligent as well as the most powerful amongst all the principal monkeys. Thus produced, there suddenly came into being by thousands, mighty bears, and monkeys, and Gopucchas , (Cow-tailed monkeys.) and of immeasurable strength, and heroic, and powerful, assuming shapes at will, endowed with bodies resembling elephants or hills, even those who would engage in compassing the destruction of the Ten-headed Rāvaṇa .
495	17	15	The sons of the deities retained distinctly the respective hues, forms, and prowess, that characterized their several sires. And those that sprang from the Golāṅgulas , possessed even more than the might of the gods.
496	17	16	Likewise, on Ṛkṣīs and Kinnaris were gladly begot thousands upon thousands of monkeys, by the gods, Maharṣis , Gandharvas , Tārkṣyas , and famous Yakṣas , Nagas , and Kiṃpuruṣas (beings half-man and half-beast) Siddhas, Vidyādharas. and Uragas.
497	17	17	Upon the principal Apsaris , and the Vidyādharis , and the daughters of the Nāgas , and the Gandharvis were begot by the Cāraṇas as sons, heroic monkeys of gigantic bodies, ranging the forests and living on fruits and roots.
498	17	18	All these monkeys were endowed with strength; and could assume shapeṣ and repair everywhere, at will. And they were like to lions aṇd tigers, both in pride and in prowess. And they fought with crags and hurled hills.
499	17	19	And they fought with nails and teeth, and were accomplished in all weapons. And they could move the largest hills; and crush the fixed trees,
500	17	20	With their impetus, vex that lord of rivers, the Ocean. And they could with their kicks rend the Earth, and swim over the mighty main.
501	17	21	They could penetrate into the welkin, and capture the clouds. And they could subdue mad elephants ranging the forest.
502	17	22	And with their roars, they could bring down birds singing. Thus came into being Koṭis of high-souled leaders of monkey-herds, assuming forms at will.
503	17	23	And these became the leaders of the principal monkey-herds; and they, in their turn, generated heroic monkeys, the foremost of the leaders of herds.
504	17	24	Some of these monkeys began to dwell on the top of the Ṛkṣavān mountain; while others inhabited various other mountains and forests.
505	17	25	Ail the leaders of monkey-herds stayed with those brothers, Sugrīva, the son of the Sun-god and Vālī, that of Śakra , and also with Nala, and Nīla, and Hanumān, and other leaders of monkey-herds. And endowed with the might of Garuḍa , and accomplished in fight, they ranged around, pounding lions, and tigers, and mighty Uragas.
507	17	27	This earth, furnished with mountains, and forests, and oceans, began to teem with those heroic lords of leaders of monkey-herds, inhabiting different places, bearing characteristic marks, resembling masses of clouds, or mountain-peaks, possessed of mighty strength, and of terrible bodies and visages, in order that they might assist Rāma .
508	18	1	When the horse-sacrifice of the high-souled Daśaratha had been completed, the immortals, accepting each his share, returned whence they had come.
509	18	2	And the monarch, having observed all the rules of initiation, entered the palace with his equipage and retinue.
510	18	3	And the lords of the earth, having been received suitably by the king, with glad hearts set out for their own countries, saluting that foremost of ascetics ( Ṛṣyaśṛṅga ).
511	18	4	And clad in bright appard, the delighted forces belonging to those graceful kings repairing to their own homes, looked exceedingly beautiful.
512	18	5	When the lords of the earth had gone away, the graceful king Daśaratha re-entered his palace, with the foremost of regenerate ones at his head.
513	18	6	Followed by the intelligent monarch with his retinue, Ṛṣyaśṛṅga, having been duly honoured, set out with Śāntā . Having thus dismissed them all, the king, his object attained, began to dwell there happily, expecting sons.
514	18	7	And then when the six seasons had rolled away after the completion of the sacrifice, in the twelfth month, on the ninth lunar day, under the influence of the Punarvasu asterism presided by Aditi devatā , when the Sun, the Moon, Saturn, Jupiter, and Venus were at Arius, Capricorn, Libra, Cancer, And Pisces, and when Jupiter had arisen with the Moon at Cancer, Kausalyā gave birth to that lord of the universe, bowed to by all the worlds, Rāma , the descendant of Ikṣvāku , furnished with excellent marks, the one half of Viṣṇu ,—exceedingly righteous, with rosy eyes, and mighty arms, and crimson nether lip, and endowed with a voice like the Sound of a kettledrum. Then on having given birth to that son of immeasurable prowess, Kausalyā looked resplendent, like Aditi on having brought forth that foremost of celestials the wielder of the thunder-bolt.
515	18	8	Then was born of Kaikeyī , named Bharata , having truth for prowess, endowed with all the virtues, and representing the very fourṃ part of Viṣṇu.
516	18	9	Then Sumitrā gave birth to Lakṣmaṇa and Śatrughna , heroic, and skilled in all weapons, and endowed with the half of Viṣṇu.
517	18	10	And Bharata of purged intelligence was born under the asterism Puṣya , when the Sun had entered Pisces; while the two sons of Sumitrā were born when the Sun arose in Cancer, under the asterism of Āśleṣā . (The ninth lunar mansion)
518	18	11	Thus were separately born four high-souled sons to the king, crowned with qualities, and graceful, and in loveliness resembling the constellations Proṣṭhapaḍa [1] Thereat the Gandharvas began to chaunt sweetly, and the Apsaras to dance. And the celestial kettledrums sounded; and there showered down blossoms from the sky.
519	18	12	And high festivities were commenced by the multitude in Ayodhyā . And the spacious highways became filled with players and dancers, glittering with all kinds of gems, and resounding with the music of singers and performers on instruments. And the king bestowed gifts upon bards and genealogists and panegyrists, and he also gave kine by thousands to Brāhmaṇas .
520	18	13	When the eleventh day had gone by, the king performed the Naming ceremony of his sons. And experiencing great delight, Vasiṣṭha conferred the names. And the high-souled eldest one was called Rāma; and Kaikeyī’s son was called Bharata; and Sumitrā’s son was called Lakṣmaṇa, and the last was named Śatrughna.
521	18	14	And the king fed the Brāhmaṇas as well as the inhabitants rural and urban; and he bestowed heaps of jewels upon Brāhmaṇas.
522	18	15	Thus did he celebrate the natal rites of the princes. And among all those princes, the eldest, Rāma, like that of Keṃ, (The ninth of the planets.) and the special delight of his father, became the object of general regard, even as the self-create Himself. And all of them were versed in the Vedas , and heroic, and intent upon the welfare of others.
523	18	16	And all were accomplished in knowledge; and endowed with virtues. And among them all, the exceedingly puissant Rāma, having true for prowess, was the desire of every one, and spotless like to the Moon himself. He could ride on elephants and horses, and was an adept in managing cars. And he was ever engaged in the study of arms, and aye occupied in ministering to his sire.
524	18	17	And even from early youth, that enhancer of auspiciousness Lakṣmaṇa was ever attached to his eldest brother Rāma, that delight of all. And like to another life of Rāma, Lakṣmaṇa furnished with auspiciousness was in everything attentive to Rāma’s wishes, even at the neglect of his own person. And that foremost of persons did not even attain sleep without Rāma’s company, nor did he partake any sweetmeat that was offered, unless Rāma partook it with him.
525	18	18	When mounted on horse-back, Rāghava went a-hunting, Lakṣmaṇa went at his back bow in hand, protecting him. And that younger brother of Lakṣmaṇa, Śatrughna, likewise became ever dearer to Bharata than life itself.
526	18	19	On account of those exalted and well-beloved sons of his, Daśaratha experienced the excess of joy, like to the Grand-sire on account of the gods.
527	18	20	And when they came to be furnished with knowledge, and crowned with virtues, and endowed with bashfulness and fame, and to attain wisdom in everything, and to be farsighted, Daśaratha, the father of such powerful and flamingly effulgent sons, became delighted even like that lord of worlds— Brahmā .
528	18	21	Those tigers among men, ever engaged in the study of the Vedas, were accomplished in the art of archery, and always intent upon ministering to their father.
529	18	22	Once upon a time, when the virtuous king Daśaratha, surrounded by his priests and friends, was reflecting about the nuptials of his sons, to that high-souled one engaged in thought in the midst of his counsellors came the mighty ascetic Viśvāmitra .
530	18	23	Desirous of seeing the king, he said to the warders,—Do you speedily announce that I, Gādhi ’s son, sprung in the Kuśika line, have come!
531	18	24	Hearing those words of his, they, urged on by them, all hurriedly began to run towards the royal chambers. And coming to the royal apartments, they communicated to Ikṣvāku’s descendant the arrival of the ascetic Viśvāmitra.
532	18	25	Hearing those words of theirs, Daśaratha surrounded by his priests, went out delightedly to meet him, like Indra going out to meet Bṛhaspati . [2]
533	18	26	And having come to that ascetic observing vows and of flaming energy, the monarch with a cheerful countenance offered him the Arghya .
534	18	27	There upon, having accepted the king’s Arghya in accordance with the ordinance he enquired of the lord of men as to his continued prosperity and peace.
535	18	28	And the exceedingly virthous descendant of Kuśika asked the king concerning the welfare of the exchequer, and the provinces; and the peace of his friends and acquaintances.
536	18	29	And are they captains submissive: and have you vanquished your foes? And have you performed well the human and the divine rites?
537	18	30	And approaching Vasiṣṭha and the other anchorites, that foremost of ascetics of exalted piety duly asked them regarding their welfare.
538	18	31	And having been properly received by the monarch, they with glad hearts entered the royal residence, and sat them down according to precedence.
539	18	32	Then gladly worshipping the mighty ascetic, Viśvāmitra, the exceedingly generous king, well-pleased, addressed him saying.
540	18	33	Like that of the obtaining of ambrosia, like to a shower in a land suffering from drought, like to the birth of sons of worthy wives to him without issue, like that of the recovery of a lost thing, yea, like to the dawning of a mighty joy, I consider this your arrival. O illustrious ascetic, are you well come? What is even that which is nearest to your heart?
541	18	34	You, O Brāhmaṇa , are worthy of my best services. By luck it is that, O bestower of honour, I have gained you. To-day my birth has been crowned with fruit to-day has my life attained its object.
542	18	35	And truly yesterday night has been succeeded by an auspicious morning, since I have beheld you. Having first attained exceeding effulgence by virtue of austerities performed for obtaining the title of Rājarṣi , you have afterwards obtained the status of a Brahmarṣi . You are worthy of manifold homage from me. This your exceedingly holy arrival appear wonderful.
543	18	36	O lord, by beholding you, surely my body has been rendered pure. Tell me, what is it that you would have, and what is the purpose of your coming?
544	18	37	ṣṭ ftṃtf ^piīllṇḍMI ^ūīf ft wṭtfin wī -ṃwprrat fs^r i WflTR: ^wFTT fg^TUVUI I wish that I may be obliged by doing your will. And, O you of excellent vows, you ought not to hesitate. I will every way accomplish your will; for you are my god. O regenerate one, surely great prosperity come to me in consequence of your coming, inasmuch as it shall be the means of bringing me entire and excellent merit, O Brāhmaṇa!
545	18	38	Hearing this soul-soothing, ear-charming, and free-humble speech that was uttered, the illustrious prime of ascetics crowned with virtues, and furnished with all perfections, experienced exceeding delight.
546	18	39	[back to top]
547	18	40	[1] :
548	18	41	Otherwise called Uttarabhādrapada and Pūrvabhādrapadā .
549	18	42	[2] :
550	18	43	According to Śruti Bṛhaspati is the Brahmā of the gods— Bṛhaspatir devānām Brahmā .
551	19	1	Hearing those astonishing words of that lionlike king, the highly-energetic Viśvāmitra with his down standing on end, said.
552	19	2	O tiger of a king, sprung from an illustrious line, and having Vasiṣṭha , for your guide, these words become you alone on earṃ and no one else.
553	19	3	Do you, O tiger of a king, ascertain your course in respect of the matter I bear in my heart; and do you prove firm in promise!
554	19	4	For celebrating a sacrifice, I, O foremost of men, abide by some prescribed course. And it comes to pass that two Rākṣasas assuming shapes at will, have become bent upon disturbing the ceremony.
555	19	5	And in that sacrifice which I have determined to bring to a completion, and which is on the eve of being completed, both these Rākṣasas, Mārīca and Subāhu , accomplished in arms and possessed of prowess, shower flesh and gore upon the altar. And on that ceremony being thus disturbed and by purpose thus frustrated, I considered my labours as all lost, and, therefore, have left my country in dejection. And, O monarch, I cannot bring myself to vent my wrath.
556	19	6	For such is the nature of that business, that it is not proper for one engaged in it to utter a curse. Therefore, O tiger of a monarch, it behoves you to grant me your eldest son, the heroic Rāma of genuine prowess, with the side-locks.
557	19	7	By virtue of his own divine energy, he, being protected by me, is capable of even destroying those Rākṣasas disturbing the ceremony. And I will, without doubt, confer upon him manifold blessings, by means of which he will secure the golden opinions of the three worlds. And encountering Rāma, they will by no means be able to stand him, nor is there any other who dares to slay them. And puffed up wiṃ energy, they have become ensnared at the hands of Kāla , ( Yama , the god of death.) and, O tiger of a monarch, they are no match for Rāma.
558	19	8	Nor, O king, ought you to indulge in paternal affection. For ten nights only Rāma is to remain there, with the object of slaying those foes to my sacrifice, those Rākṣasas ḍisṃrbing the rites. I tell you, do you consider the Rākṣasas as already slain. I know full well Rāma of sterling prowess, as also the highly-energetic Vasiṣṭha and the other ascetics present here. And if you, O king, set your heart upon acquiring religious merit and high fame on earth, do you then grant me Rāma!
559	19	9	And, O Kākutstha , [1] if your counsellors together with the Brāhmaṇas having Vasiṣṭha at their head, consent, do you then dismiss Rāma!
560	19	10	Even this is my wish, and he also has come of age. Do you, therefore, part with your son, the lotus-eyed Rāma, for the ten days of the sacrifice! Do you act so, O descendant of Raghu , that the time appointed for the ceremony may not be overpassed. Good betide you! Let not your mind indulge in grief!
561	19	11	Having said these words consistent with virtue and interest, the mighty-minded and highly-powerful Viśvāmitra paused.
562	19	12	And hearing the auspicious words of Viśvāmitra, that foremost of kings shook with a mighty sorrow, and became bewildered.
563	19	13	Then, having regained his senses, he rose up, and became cast down through apprehension. Having heard the words of the ascetic, capable of rending the mind and heart, the high-souled king of men became stricken with grief and shook on his seat.
564	19	14	[back to top]
565	19	15	[1] :
566	19	16	From Kakud , an emblem of royalty, and Stha , residing, meaning a prince, the grandson of Ikṣvāku.
567	20	1	Hearing the words of Viśvāmitra , that tiger of a monarch remained insensible for a time, and then regaining his senses, spoke thus.
568	20	2	My lotus-eyed Rāma is not yet turned of sixteen; and I do not perceive his fitness to cope with Rākṣasas in battle.
569	20	3	I am the lord of this Akṣauhiṇī (A complete army consisting of 1,09,350 foot, 65,610 horse, 21,870 chariots, and 21,870 elephants.) of forces. Marching with this, will I engage with the night-rangers.
570	20	4	And these servants of mine are Valiant, and warlike, and accomplished in weapons, and capable of fighting the Rākṣasas,—therefore, it behove you not to take Rāma.
571	20	5	And myself bow in hand, stationed at the van of the array, will battle with the rangers of the night as long as life is spared to me.
572	20	6	Then well protected, your sacrifice will hold an unimpeded course. Therefore, I will repair thither, and it behoves you not to take Rāma.
573	20	7	Youthful, and unaccomplished, and not knowing what constitutes strength and what not, and not equipped with the science of missiles, and unskilful in fight,
574	20	8	He is not a match for Rākṣasas,—they being deceitful warriors. Bereft of Rāma, O tiger among ascetics, I cannot live for a moment. Therefore, it behove you not to take him. If, O Brahman , it is your intention to take Rāma, then O you of excellent vows, do you also take me along with the Caturaṅga forces! (An army consisting of foot, horse, elephants, and cars.)
575	20	9	O Kuśika ’s son, I am sixty thousand years old; and (at this age) I have obtained Rāma after undergoing extreme troubles, it therefore, become you not to take Rāma.
576	20	10	And among the four sons of mine, I find my highest delight in Rāma, my first-born, and the most virtuous of them all, therefore, it behoves you not to take Rāma.
577	20	11	What is the prowess of the Rākṣasas? And whose sons are they? And who, pray are they? And what are the proportions of their bodies? And who protects them O foremost of ascetics? And by what means shall either Rāma, or my forces, or, O Brahman, I myself be able to slay in fight those deceitful warriors—the Rākṣasas? Do you tell me, O adorable one, inflated as they are by virtue of their prowess, how can I stand them in fight?
578	20	12	Hearing that speech of his, Viśvāmitra said, There is a Rākṣasa named Rāvaṇa , sprung from the line of Pulastya . Having obtained a boon from Brahmā , he boldly opposes himself to three worlds, being possessed of great strength and prowess, and backed by innumerable Rākṣasas. And, O mighty monarch, I also hear that that lord of the Rākṣasas is the very brother of Vaiśravaṇa and the son of the ascetic Viśravaṇa.
579	20	13	When that one possessed of mighty strength does not stoop to disturb the sacrifice himself, those powerful Rākṣasas, Mārīca and Subāhu , being incited by him, disturb the rites.
580	20	14	The ascetic having spoken thus, the king then answered him, I am incapable of standing that wicked-souled one in fight.
581	20	15	Therefore, do you, O you versed in morality, extend your favour to my son! Of slender fortune as I am, you are my guide and my god.
582	20	16	Even the celestials and the Dānavas and the Gandharvas and the Birds and the Snakes are incapable of bearing Rāvaṇa in battle, what then is man?
583	20	17	O foremost of ascetics, whether you are accompanied with my son or my forces, you will not be able to stand him. And how can I, O Brāhmaṇa , make over to you my son, of tender years, resembling an immortal, who is ignorant of warfare? I will not part with my son.
584	20	18	The sons of Sunda and Upasunda resemble Kāla himself in battle, and it is they who are disturbing your sacrifice. Therefore I will not part with my son. And Mārīca and Subāhu are possessed of prowess, and accomplished in weapons.
585	20	19	But with my friends I will repair to encounter one of them. If you do not consent to this, I beseech you with my friends, (do you desist!)
586	20	20	Hearing these words of the lord of men, a mighty ire took possession of that foremost of regenerate ones, Kuśika’s son; and the fire of the Maharṣi ’s wrath flamed up even like to a fire fed by fuel and clarified butter.
587	21	1	Hearing those words of Daśaratha ’s composed of letters faltering with affection, Kuśika ’s son, stirred up with anger, answered the monarch, saying,
588	21	2	Having promised me first, you endeavour to renounce that promise of yours. This surely is unworthy of a descendant of Raghu , and this can bring destruction upon the dynasty.
589	21	3	If, O king, in acting thus, you have acted properly, I will then repair to the place whence I had come. O Kākutstha ’s descendant false in promise, do you attain happiness, being surrounded by your friends.
590	21	4	And when the intelligent Viśvāmitra was exercised with wrath, the entire earth began to tremble, and the gods even were inspired with awe.
591	21	5	And knowing that the entire universe was in trepidation, that mighty saint, the sedate Vasiṣṭha of excellent vows, said these words to the king.
592	21	6	Born in the line of Ikṣvāku , you are the very second self of virtue. And endowed with patience, and auspicious, and observing excellent vows, you ought not to renounce virtue.
593	21	7	The descendant of Raghu is famed over the three worlds as righteous-souled. Do you maintain your habit of adhering to promise; for it does not behove you to act unrighteously,
594	21	8	If having promised, I will do so, you do not act up to your word, the merit you have achieved by digging tanks , shall come to naught, therefore do you renounce Rama !
595	21	9	Accomplished or not accomplished in weapons, the Rākṣasas cannot bear him protected by Kuśika’s son, like ambrosia, by flaming fire.
596	21	10	This one is Virtue incarnate: this one is the foremost of those possessing prowess. This one surpass all others in learning, and is the refuge of asceticism.
597	21	11	This one is congnizant of all that exist in the three worlds furnished with mobile and immobile things;—but others do not know him,—nor yet shall know him hereafter.
598	21	12	And neither the gods, nor the saints, nor the immortals, nor the Rākṣasas, nor the foremost of Gandharvas and Yakṣas , nor the Kinnaras , nor the mighty Serpents can know him.
599	21	13	And formerly while the descendant of Kuśika was ruling his kingdom, Śiva conferred upon him the highly famous sons of Kṛśāśva in the shane of all weapons.
600	21	14	Those sons of Kṛśāśva were the offspring of Prajāpati ’s daughters. And they were endowed with various forms, and were effulgent and dreadful.
601	21	15	And Dakṣa ’s daughters of elegant waists, Jayā and Suprabhā , brought forth an hundred exceedingly effulgent weapons.
602	21	16	And by virtue of her boon, Jayā obtained fifty sons of immeasurable strength and endued with the power of becoming invisible for the purpose of slaughtering the hosts of the Asuras .
604	21	18	Kuśika’s son is adequately conversant with all those weapons. And that one knowing duty is also capable of creating wonderful weapons.
605	21	19	O descendant of Raghu, there is nothing present, past, or future which is not known by that foremost of ascetics of high soul, and cognizant of morality.
606	21	20	Such is the prowess of that highly famous Viśvāmitra possessed of mighty energy. Therefore, O king, it behove you not to hesitate in the matter of Rāma ’s going.
607	21	21	The descendant of Kuśika is himself capable of repressing the Rākṣasas; and it is in order to your son’s welfare that coming to you, he ask for him of you.
608	21	22	At this speech of the ascetic, that foremost of Raghus , the king, well-pleased, became exceedingly delighted. And that famous one, relishing the journey of Rāma, began to reflect in his mind about consigning him to Kuśika’s son.
609	22	1	Upon Vasiṣṭha ’s representing this, king Daśaratha himself, with a complacent countenance, summoned to him Rāma and Lakṣmaṇa .
610	22	2	And when the auspicious rites had been performed by both Rāma’s father and mother, and when the priest Vasiṣṭha had uttered mantras , king Daśaratha, smelling his son’s crown, with a glad heart, made him over to the descendant of Kuśika .
611	22	3	Then there blow a Breeze free from dust and of delicious fed, on witnessing the lotus-eyed Rāma at the hands of Viśvāmitra . And as the high-souled one was about to set out, blossoms began to shower down copiously, accompanied with the sounds of celestial kettle-drums and the loud blares of conch.
612	22	4	Viśvāmitra went first, and next the highly famous Rāma with the side-locks, holding the bow. And him followed Sumitrā ’s Sun
613	22	5	And equipped with quivers, and with bows in hand, gracing the ten cardinal points and resembling three-hooded serpents, they followed the high-souled Viśvāmitra, like the two stalwart Aśvins following the Grand-sire.
614	22	6	Those effulgent ones of faultless limbs went in the wake of the ascetic, illumining him with their grace. And like to those sons of him Skandha and Viśākha following the incomprehensible deity, Sthāṇu , those youthful brothers of comely persons and faultless limbs Rāma and Lakṣmaṇa, highly effulgent, carrying bows in hand, adorned with ornaments, and equipped with scimitars, with their fingers encased in Guana skin, flamingly followed Kuśika’s son, beautifying him with their splendour.
615	22	7	And having proceeded over half a Yojana , and arriving at the right bank of the Sarayū , Viśvāmitra addressed these sweet words to Rāma, O Rāma! do you, O child, take of this water: let no delay occur.
616	22	8	Do you receive the mantras Bala and Atibala , and you will not feel fatigue or fever or undergo any change of look, and whether asleep or heedless, the Rākṣasas will not be able to surprise you. And, O Rāma, the might of your arms will be unequalled in this world,—nay, in all the three worlds.
617	22	9	Do you, O Rāghava , recite Bala and Atibala, O child! And, O sinless one, when you have secured these two kinds of knowledge, none in this world will equal you in good fortune, or in talent or in philosophic wisdom, or in subtle apprehension, or in the capacity of answering a controversialist; for Bala and Atibala are the nurses of all knowledge.
618	22	10	And, O Rāma, O foremost of men, if you recite Bala and Atibala on the way, neither hunger nor thirst will exercise you, O descendant of Raghu ! And if you recite these, you will attain fame on earth. Those sciences fraught with energy are the daughters of the Grandsire.
619	22	11	I intend to confer them upon you, O Kākutstha ; and, O lord of earth, they are worthy to be conferred upon you; and they are possessed of various virtues. You need not entertain any doubt about it. And if you bear them in consonance with the precepts, they will prove of manifold good to you.
620	22	12	Thereat Rāma with a cheerful countenance sipping water with a purified body received those sciences from the Maharṣi of subdued soul.
621	22	13	And furnished with the sciences, Rāma of dreadful prowess appeared resplendent, even like the adorable autumnal Sun invested with a thousand rays.
622	22	14	Then Rāma having rendered to Kuśika’s son all the duties pertaining to a spiriṃal guide, the three happily spent that night on the banks of the Sarayū.
623	22	15	And although those excellent sons of Daśaratha lay down on an unbeseeming bed of grass, yet in consequence of the sweet converse of Kuśika’s son, the night seemed to pass pleasantly away.
624	23	1	And when the night had passed away, the mighty ascetic spoke to Kākutstha , lying down on a bed of leaves, O Rāma , surely has Kausalyā given birth to an excellent son! The first Sandhyā [1] should now be performed. Do you, O tiger among men, arise! You should perform the purificatory rites and contemplate the gods.
625	23	2	Hearing those proper words of the ascetic, those foremost of men, endowed with heroism, bathed, and, sipping water, began to recite the Gāyatrī . (The solar hymn of the Veda ).
626	23	3	And having performed these daily duties, those exceedingly powerful ones, greeting Viśvāmitra having asceticism for wealth, stood before him, with the object of starting on their journey.
627	23	4	And as those ones endowed with exceeding prowess were proceeding, at the shining confluence of the Sarayū and the Gaṅgā they beheld a noble river flowing in three branches.
628	23	5	There lay a holy hermitage, belonging to ascetics of subdued souls, where they had been carrying on their high austerities for thousands of years.
629	23	6	Beholding that sacred asylum those descendants of Raghu , exceedingly delighted, spoke to the high-souled Viśvāmitra, these words.
630	23	7	Whose is this sacred hermitage? And what man lives here? O worshipful one, we are desirous of hearing this. Surely, great is our curiosity.
631	23	8	At those words of theirs, that foremost of ascetics, smiling, said, Heap O Rāma, as to whom the asylum has belonged in time past.
632	23	9	Kandarpa , called Kāma by the wise, was once incarnate (on earth.) And it came to pass that as that lord of the deities, Sthāṇu , having performed here his austerities in accordance with the prescribed restrictions, was wending his way in company with the Maruts , that fool-hardy wight dared disturb the equanimity of his mind.
633	23	10	Thereupon, O descendant of Raghu, uttering a roar, the high-souled Rudra eyed him steadfastly. And thereat all the limbs of that perverse-hearted one became blasted.
634	23	11	And on his body being consumed by that high-souled one, Kāma was deprived of his person in consequence of the ire of that foremost among the deities.
850	33	13	And, O descendant of Raghu , once he said to her, I am gratified, good betide you! What good shall I render you?
635	23	12	O Rāghava , from that time forth, he has become known as Anaṅga . And the place where he was deprived of his body is the lovely land of Aṅga .
636	23	13	This sacred hermitage belongs to Śiva ; and these ascetics engaged in pious acts, O hero, have been from father to son his disciples. And no sin touch them.
637	23	14	Here, O Rāma, in the midst of the sacred streams, will we spend the night, O you of gracious presence, crossing over on the morrow.
638	23	15	Let us then, having purified ourselves, enter the holy hermitage! It is highly desirable for us to sojourn here, here will we happily spend the night, having bathed, and recited the mantras , and offered oblations to the sacrificial fire, O best of men.
639	23	16	As they were conversing thus, the ascetics were highly delighted on discovering them by means of their far-reaching spiritual vision, and they rejoiced greatly.
640	23	17	Then giving Kuśika ’s son water to wash his feet and Arghya , and extending to him also the rites of hospitality, they next entertained Rāma and Lakṣmaṇa .
641	23	18	Having experienced their hospitality, they (the guests) delighted them with their talk. And then the saints with collected minds recited their evening prayers.
642	23	19	And having been shown their destined place of rest along with ascetics of excellent vows, they happily passed that night in that hermitage affording every comfort.
643	23	20	And that foremost of ascetics, the righteous-souled son of Kuśika, by means of his excellent converse, charmed the prepossessing sons of the monarch.
644	23	21	[back to top]
645	23	22	[1] :
646	23	23	Brāhmaṇas have to perform their daily devotions thrice,—in the morning, at noon, and in the evening.
647	24	1	Then next morning which happened to be fine, those repressors of their foes, with Viśvāmitra at their head, came to the banks of the river. ( Gaṅgā ).
648	24	2	The legend is that when the saint Agastya had sucked up the ocean, the Ganges replenished it.
649	24	3	And those high-souled ascetics observing vows, having brought an elegant bark, addressed Viśvāmitra, saying.
650	24	4	Do you ascend the bark, with the princes at your head! May your journey be auspicious: let no delay occur
651	24	5	Thereupon saying, So be it! and having paid homage to those ascetics, Viśvāmitra set about crossing that river, which had replenished the ocean.
652	24	6	It came to pass that while thus engaged, they heard a sound augmented by the dashing of the waves. And having come to the middle of the stream, the highly energetic Rāma with his younger brother, became curious to ascertain the cause of that sound.
653	24	7	And reaching the middle of the river, Rāma asked that best of ascetics, What is this loud uproar that seem to come riving the waters?
654	24	8	Hearing Rāghava ’s words dictated by curiosity, that righteous-souled one spoke, unfolding the true cause of that noise.
655	24	9	O Rāma, there is in the Kailāsa mountain an exceedingly beautiful pool, created mentally by Brahmā , O foremost of men, and hence this watery expanse go by the name of Mānasa Pool.
656	24	10	And the stream that issues from that liquid lapse, flows through Ayodhyā : the sacred Sarayū issues from that pool of Brahmā.
657	24	11	And as the Sarayū meets the Jāhnavī , this tremendous uproar is heard, being produced by the clashing of the waters. Do you, O Rāma, bow down to them with a concentrated mind.
658	24	12	Thereupon, boṃ of those exceedingly righteous ones, bowed down to those streams; and betaking themselves to the right bank, began to proceed with fleet vigour.
659	24	13	And beholding a dreadful and trackless, forest, that son of the foremost of men, Ikṣvāku ’s descendant, asked that best of ascetics.
660	24	14	Ah! deep is this forest abounding in crickets; and filled with terrible ferocious beasts, and various birds possessed of shocking voices and creaming frightfully; and graced by lion, and tigers, and boars, and elephants; and crowded with Dhavas * (Grislea Tomentosa). and Aśvas and Karṇas (Cassia fistula) and Kakubhas and Vilvas (Aegle marmalos) and Tiṇḍukas \\ (Diospyros glutinosa) and Pāṭalas (Bignonia suave-olens) and Baḍarīs (Fujube). Whence is this dreadful forest?
661	24	15	Him answered thus the mighty ascetic Viśvāmitra endowed with high energy, Do you listen, O Kākutstha , as to whom belong this dreadful forest!
662	24	16	Here were formerly, O foremost of men, two flourishing provinces, named Maladā , and Karūṣa , built by celestial architects.
663	24	17	In days of yore, O Rāma, on the occasion of the destruction of Vṛtra , the thousand-eyed one came to have hunger, to be besmeared with excreta, and to slay a Brāhmaṇa .
664	24	18	When Indra had been thus besmeared, the deities, and the saints having asceticism for wealth, washed him here, and cleansed his person from the dirt.
665	24	19	And the deities, having renounced here the filth that had clung to the person of the mighty Indra, as well as his hunger, attained exceeding delight.
666	24	20	And thereat Indra becoming purified, attained his former brightness, and looked like to gold. And mightily pleased with this region, he conferred on it an excellent boon, saying, Since these two places have held excreta from my body, the going by the names of Maladā and Kārūṣa , shall attain exceeding prosperity and fame among men.
667	24	21	And beholding the land ṃus honoured by the intelligent Sacra, the deities said to the subduer of Pāka ,—Well Well!
668	24	22	O repressor of foes, these two places, Maladā and Karuṣā, enjoyed prosperity for a long time and were blessed with com and wealth.
669	24	23	Then after a space of time, was born a Yakṣīṇi capable of assuming forms at will, and endowed with the strength of a thousand elephants.
670	24	24	Her name, good betide you! was Tāṭakā , and she was the spouse of the intelligent Sunda —she whose son is the Rākṣasa , Mārīca , possessed of the prowess of Sacra; having round arms, with a huge head, a capacious mouth and a cyclopean body.
671	24	25	And that Rākṣasa of dreadful form daily frightens people. And, O descendant of Raghu , Ṭāṭakā of wicked deeds, daily commits havoc upon these countries, Maladā and Karuṣā.
672	24	26	And now at the distance of over half a Yojana , she stays, obstructing the way. And since this forest belong to Tāṭakā, you should repair there; and, resorting to the might of your own arms, slay this one of wicked deeds.
673	24	27	And, by my direction, do you again rid this region of its thorn; for no one dare to approach such a place, infested,
674	24	28	O Rāma, by the dreadful and unbearable Yakṣiṇī . And now I have related to you all about this fearful forest. And to this day none is capable of letting that Yakṣiṇī from committing ravages right an left.
675	25	1	Hearing this excellent speech of that ascetic of immeasurable energy, that foremost of men answered him in these happy words,
676	25	2	O best of ascetics, I have heard that the Yakṣa race is endowed with but small prowess. How can then that one of the weaker sex possess the strength of a thousand elephants?
677	25	3	Hearing this speech that was uttered by Rāghava of immeasurable energy, Viśvāmitra , delighting with his amiable words that subduer of foes, Rāma , and Lakṣmaṇa , said, Do you listen as to the means whereby attaining terrible strength, that one belonging to the weaker sex has come to possess strength and prowess by virtue of a boon.
678	25	4	In former times there was a mighty and exceedingly powerful Yakṣa, named Sukeṃ. And he had no issue. And he was of pure practices, and used to perform rigid austerities.
679	25	5	And, O Rāma, the Grand-sire endowed her with that lord of Yakṣas , conferred upon him a gem of a daughter, by name Tāṭakā .
680	25	6	And the Grand-sire endowed her with the strength of a thousand elephants; yet that illustrious one did not bestow a son on that Yakṣa.
681	25	7	When she had grown, and attained youth and beauty, he gave that famous damsel to Jambha ’s son, Sunda , for wife.
682	25	8	After a length of time, that Yakṣī gave birth to a son, named Mārīca , possessed of irrepressible energy, him who became a Rākṣasa in consequence of a curse.
683	25	9	O Rāma, when Sunḍa had been destroyed, Tāṭakā along with her son, set her heart upon afflicting that excellent saint Agastya .
684	25	10	And enraged with Agastya, she rushed at him with a roar, intending to devour him. And on seeing her thus rushing, that worshipful saint, Agastya, said to Mārīca, Do you become a Rākṣasa!
685	25	11	And, in exceeding wrath, he also cursed Tāṭakā. And, O mighty Yakṣī, since in frightful guise with a frightful face you have desired to eat up a human being, do you immediately leave this (your original) shape, and become of a terrible form!
686	25	12	Thus cursed by Agastya, Tāṭakā, overwhelmed with rage, lays waste this fair region, where Agastya carry on his austerities.
687	25	13	Do you, O descendant of Raghu , for the welfare of Brāhmaṇas and kine, slay this exceedingly terrible Yakṣī of wicked ways and vile prowess!
688	25	14	Nor, O son of Raghu, does any one in the three worlds, save, you, dare to slay this Yakṣī joined with a curse.
689	25	15	Nor should you, O best of men, shrink from slaying a woman; for even this should be accomplished by a prince in the interests of the four orders.
690	25	16	Whether an act be cruel or otherwise, slightly or highly sinful, it should for protecting the subjects, be performed by a ruler.
691	25	17	Of those engaged in the onerous task of government, even this is the eternal rule of conduct. Do you, O Kākutstha , slay this impious one; for she know no righteousness!
692	25	18	We hear, O king, that in days of yore, Śakra slew Virocana ’s daughter, Mantharā , who had intended to destroy the earth.
693	25	19	And formerly, O Rāma, Viṣṇu destroyed Kāvya ’s mother, the devoted wife of Bhṛgu , who had set her heart upon annihilating the world, deprived of sleep (through fear of her.)
694	25	20	By these as well as innumerable princes—foremost of men—have wicked women been slain. Therefore, O king, renouncing antipathy, do you, by my command, slay this one!
695	26	1	Hearing those bold words of the ascetic, the son of that foremost of men, Rāghava firm in his vows, with clasped hands answered.
696	26	2	In accordance with the desire of my sire, and in order to glorify it, I ought fearlessly to do even as Kuśika ’s son says. And having been desired to that end while at Ayodhyā by that high-souled one, my father Daśaratha , in the midst of the spiritual guides, I ought not to pass by your words.
697	26	3	Therefore, commanded by that upholder of the Veda , I, agreeably to my father’s mandate, will, without doubt, bring about that welcome event—the death of Tāṭakā .
698	26	4	And in the interests of Brāhmaṇas , kine, and celestials, I am ready to act as desired by you of immeasurable energy.
699	26	5	Having said this, that repressor of foes, with clenched fist, twanged his bow-string, filling the ten cardinal points with the sounds. And at those sounds, the dwellers in Tāṭakā’s forest were filled with perturbation,—and Tāṭakā also amazed at those sounds, became exceedingly wroth.
700	26	6	And rendered almost insensible by anger, that Rākṣasī furiously rushed in a main towards the spot whence had come the report.
701	26	7	And beholding that frightful one of hideous visage and colossal proportions, transported with rage, Raghu ’s descendant spoke to Lakṣmaṇa ,
702	26	8	“Behold, O Lakṣmaṇa, the terrible and hideous body of yonder Yakṣiṇī ! The sight of her strike terror into the hearts of even the brave.
703	26	9	Mark! This irrepressible one, possessing all ṃe resources of illusion, will I oppose, and deprive her of ears and nose.
704	26	10	But I dare not slay her, she being protected by virtue of her feminineness. I intend only to oppose her course, and deprive her of her prowess.”
705	26	11	As Rāma was speaking thus, Tāṭakā, deprived of sense through ire, uttering roars, with uplifted arms rushed against him.
706	26	12	And thereat the Brahmarṣi , Viśvāmitra , uttering a roar, upbraided her, and said, Svasti ! [1] May victory attend the descendants of Raghu!
707	26	13	And raising thick clouds of dust, Tāṭakā instantly bewildered both the descendants of Raghu.
708	26	14	And then by help of illusion, she began to pour upon them a mighty shower of crags. And thereat Raghu’s descendant was wroth.
709	26	15	And resisting that mighty shower of crags by vollies of shafts, Rāghava with arrows cut off her hands.
710	26	16	And with the fore-parts of her arms lopped off, as she was roaring before them, Sumitrā ’s son waxing wroth deprived her of her ears and nose.
711	26	17	Thereupon that one capable of assuming forms at will, began to assume various shapes; and to vanish from sight, bewildering her antagonists with her illusory displays.
750	28	2	O adorable one, I have received these weapons, incapable of being repressed even by the celestials themselves. Now, O best of ascetics, I would acquire a knowledge of with drawing them.
712	26	18	Terribly ranging the field, the Yakṣī showered crags upon her antagonists. And beholding them enveloped on all sides by that craggy downpour, the auspicious son of Gaḍhi spoke these words,—O Rāma, renounce your antipathy. This one of wicked ways is exceedingly impious. And this sacrifice-disturbing Yakṣī will, by virthe of her power of illusion, come to increase more and more in energy. Do you, therefore, against the arrival of dusk, slay her! The Rākṣasas are incapable of being controlled when evening sets in.
713	26	19	Thus addressed, Rāma, displaying his skill in aiming by sounds, enveloped with arrows that Yakṣī showering crags.
714	26	20	Being thus hemmed in with a network of shafts, she possessed of the powers of illusion, rushed against Kākutstha and Lakṣmaṇa, uttering terrible roars. And as that Yakṣī, in prowess like to a thunder-bolt, was rushing on, Rāma pierced her chest with arrows, and thereat she dropped down and died.
715	26	21	Upon seeing that grim-visaged one slain, the lord of the celestials together with the celestials themselves honouring Kākutstha, exclaimed Well, Well!.
716	26	22	And exceedingly pleased, the thousand-eyed Purandara , together with the delighted deities, said to Viśvāmitra.
717	26	23	O ascetic, O Kuśika’s son, good betide you! all the Maruts with Indra at their head, have been gratified with this act (of Rāma’s). Do you, O Brāhmaṇa , confer upon Raghu’s descendant the sons of Prajāpati Kṛśāśva , of true prowess, and charged with ascetic energy.
718	26	24	And ever following you, he, O Brāhmaṇa, is fit to receive them of you. And this son of the king is to accomplish a mighty task in the interests of the celestials.
719	26	25	Saying this, the deities, having paid homage to Viśvāmitra, joyfully entered the celestial regions.
720	26	26	And now came evening on, when that best of ascetics, gratified at the destruction of Tāṭakā, smelt Rāma’s crown and said these words,
721	26	27	“Here, O Rāma of gracious presence, shall we pass the night; and morrow morning, went to that hermitage of mine.”
722	26	28	Hearing Viśvāmitra’s words, Daśaratha’s son, glad at heart, happily passed that night in the forest of Tāṭakā.
723	26	29	And being thus freed from all disturbances, from that day forth that forest appeared charming, even like to the forest of Caitraratha .
724	26	30	Having thus slain the Yakṣa ’s daughter, Rāma, eulogised by celestials and Siddhas , spent there that night with the saint, being awakened by the latter at the break of day.
725	26	31	[back to top]
726	26	32	[1] :
727	26	33	A particle of benediction, indeclinable.
728	27	1	Having passed that night, the illustrious Viśvāmitra , smiling complacently, sweetly spoke to Rāghava , saying,
729	27	2	Pleased am I with you. Good betide you, O highly famous prince! With supreme pleasure, do I confer upon you all the weapons.
730	27	3	By means of which subduing such antagonists as celestials and Asuras backed on earth by Gandharvas and Uragas , you will in battle be crowned with victory.
731	27	4	All those celestial weapons, good betide you, I will confer upon you. And I will confer upon you, O Rāghava, the celestial and mighty Daṇḍacakra [1] and Dharmacakra , and also Kālacakra . And, O foremost of men, I will confer upon you the fierce Viṣṇucakra , and Indracakra .
732	27	5	The Vajra , and Śiva ’s Śūlavara, and the weapon Brahmaśiras , and Aiṣīka, O mighty-armed descendant of Raghu ! And, O tiger among men, I will, O king’s son, bestow upon you the matchless Brahmā weapon, and, O Kākutstha , the two excellent maces, the flaming Modakī and Śikhari . And, O Rāma , I will confer upon you Dharmapāśa, [2] and Kālapāśa, and the excellent Varuṇapāśa.
733	27	6	O descendant of Raghu, I will bestow upon you the two Aśanis , Śuṣka and Ārdra , and the Pināka weapon, and the Nārāyaṇa , and the Āgneya weapon called Śikhara , and the Vāyavya , called Prathama .
734	27	7	O sinless one! And, O Rāghava, I will confer upon you the weapon called Hayaśiras , and the Krauñca weapon, and, O Kākutstha, a couple of darts.
735	27	8	And I will confer upon you Kaṅkāla , and the dreadful Muśala , and Kapāla , and Kiṅkiṇī —all those that are intended for slaughtering Rākṣasas .
736	27	9	And, O mighty-armed one, O son of the best of men, I will confer upon you the mighty weapon Vidyādhara , and that excellent scimitar named Nandana , and the favourite Gandharva weapon, Mohana , and Prasvāpana , Paśamana, and Saumya , Rāghava! And, O tiger among men, do you accept Varṣaṇa , and Śoṣaṇa , and Santāpana , and Vilāpana , and Mādana hard to repress, beloved of Kandarpa , and that favourite Gandharva weapon, Mānava , and the favourite Piśāca weapon, O highly famous prince.
737	27	10	You, O mighty-armed Rāma, speedily accept the Tāmasa , O tiger among men, and the exceedingly powerful Saumana, and the irrepressible Saṃvarta and Mauśala, O son of the king, and the Satya weapon, and the supreme Māyāmaya, and the Saura . Tejaprabha, capable of depriving foes of energy, and the Soma , and the Siśira, and the Tvāṣṭra , and the terrible Dāruṇa belonging to Bhaga , and Śileṣu, and Mānava.
738	27	11	O long-armed king’s son, Rāma! receive instantly all powerful, highly exalted forms that can be modified at will.
739	27	12	Then with his face turned towards the east, that foremost of ascetics having purified himself, gladly conferred the mantras upon Rāma.
740	27	13	And the Vipra also bestowed upon Rāghava those weapons, of which even the celestials are incapable of holding all.
741	27	14	As that intelligent ascetic, Viśvāmitra, recited mantras, all those invaluable weapons appeared before that descendant of Raghu. And with clasped hands, they well-pleased, addressed Rāma,—These, O highly generous one, are your servants, O Rāghava. And whatever you wish, good betide you, shall by all means be accomplished by us.
742	27	15	Thus addressed by those highly powerful weapons, Kākutstha Rāma, with a delighted soul, accepting them, touched them with his hand, and said, Do you appear before me as I remember you!
743	27	16	Then the exceedingly energetic Rāma, well pleased, paying reverence to the mighty ascetic, Viśvāmitra, prepared to set out.
744	27	17	[back to top]
745	27	18	[1] :
746	27	19	Cakra means discus. These enumerations specify different kinds of the discus.
747	27	20	[2] :
748	27	21	Pāsa means noose
749	28	1	Having accepted those weapons with purity, Kākutstha while proceeding, with a complacent countenance spoke these words to sage Viśvāmitra ,—
751	28	3	Upon Kākutstha’s representing this, Viśvāmitra of high austerities, endowed with patience, of excellent vows, and pure in spirit, communicated to him the mantras for restraining the weapons.
752	28	4	Do you, O Rāma , accept Satyavat, and Satyakīrti, Dhṛṣṭa , Rabhasa , Pratihāratara, Parāṅmukha, Avāṅmukha, and also Lakṣya , Alakṣya, Dṛḍhanābha, Sunābha , Daśākṣa, Śatavaktra, Daśaśīrṣa, Śatodara, Padmanābha , Mahanābha, Indunābha, Svanābha, Jyotiṣa , Śakuna , Nairaṣya, Vimala , Yaugandhara, Vinidra , and the two Daityapramathanas, and Śucibāhu, Mahābāhu , Niṣkali, Viruca, Arcimāli, Dhṛtimāli, Vṛttimān, Rucira , Pitrya , Saumansa, Vidhuta , Makara , Karavīra , Rati , Dhana , and Dhānya , O Rāghava , and Kāmarūpa , Kāmaruci, Moha , Āvaraṇa and Jṛmhhaka, Sarpanātha, Panthāna, and Varuṇa ,—these sons of Kṛśāśva , O Rāma, effulgent, and assuming shapes at will. And, good betide you, O descendant of Raghu , you are worthy to receive these weapons.
753	28	5	Thereupon, Kākutstha with a heart overflowing with delight, said,—So be it! And those weapons were furnished with celestial and shining persons, and endowed with visible shapes, and capable of conferring happiness. And some of them were like (live) coals; and some comparable to smoke; and some were like to the Sun or the Moon. And with folded hands, they spoke to Rāma in honied accents; O chief of men, here we are! Do you command as to what we are to do on your behalf.
754	28	6	Then the descendant of Raghu answered, saying, Repair whither soever you will! Recurring to my memory, do you in time of need, render me assistance!
755	28	7	Thereupon paying homage to Rāma, and having gone round him, they replied to Kākutstha, What is yonder wood hard by the hill, appearing like clouds? Great is my curiosity.
756	28	8	It is pleasing to the sight, and abounds in beasts, and is exceedingly romantic, and is adorned with various birds singing sweetly.
757	28	9	Now, O foremost of ascetics, we have come out of a wilderness capable of making one’s hair stand on end. And from the pleasantness attaching to this place, I have come to a conclusion.
758	28	10	Tell me, O reverend sir, whose hermitage is this? Have we, O eminent ascetic, reached that spot where dwell those wicked minded wretches of impious deeds, given to slaughtering Brāhmaṇas , who disturb your sacrifice? Where, O adorable one, is that hermitage, repairing to which, O Brāhmaṇa , I am to protect your sacrificial rites, and to slay the Rākṣasas ? All this, O foremost of ascetics, I desire to hear, O lord.
759	29	1	Hearing those words of Rāma of measureless prowess, who had asked the question, the highly energetic Viśvāmitra answered, saying,
760	29	2	Here, O mighty-armed Rāma, Viṣṇu of mighty asceticism worshipped of all the deities, for years upon years, and hundreds of Yugas , dwelt for carrying on his austerities and Yoga . This, O Rāma, was formerly the hermitage of the high-souled Vāmana .
761	29	3	And this famed as Siddhāśrama , in consequence of that one of potent asceticism having attained fruition there. And it came to pass that at this time Virocana ’s son, king Vālī ; having vanquished the celestials with Indra and the Marats, established that dominion of his, famous in the three worlds.
762	29	4	And that mighty chief of the Asuras celebrated a sacrifice. And as Vālī was performing that sacrifice, the deities with Agni at their head, coming to Viṣṇu himself at this asylum, addressed him saying,
763	29	5	Virocana’s son, Vali , O. Viṣṇu, is celebrating a sacrifice. Do you, before the ceremony is finished, accomplish your own end.
764	29	6	He duly confer upon such as repair to him from various quarters all those things that they ask for. And do yourself.
765	29	7	O Viṣṇu, aided by your power of illusion, assuming a Dwarf form, accomplish the welfare of the gods.
766	29	8	In the meantime, O Rāma, the worshipful Kaśyapa resembling fire in splendour, and flaming in energy, having in company with, and with the assistance of, the divine Aditi , O Rāma, accomplished his vow, began to hymn the destroyer of Madhu ready to confer boons.
767	29	9	By means of warm austerities, will I behold you composed of penances, a mass of mortifications, and endowed with a form and a soul of austerities. And in your person, O lord, will I behold this entire universe. And in You without beginning, and incapable of being pointed out, do I take refuge! Thereupon exceedingly pleased, Hari spoke to Kaśyapa, with his sins purged off, saying, Do you mention the boon! Good betide you. Methinks you deserve a boon.
768	29	10	Hearing these words of his, Marīci ’s son, Kaśyapa, said, Aditi, the gods, and I myself, crave of you this, and, O bestower of boons, it behove you well pleased to confer on us this boon, O you of excellent vows! Do you, O sinless one, become born as my son in Aditi.
769	29	11	O adorable deity! Do you become the younger brother of Śakra , O destroyer of Asuras. It behove you to help the celestials afflicted with grief.
770	29	12	And this place through your grace will attain the name of Siddhāśrama. The work, O lord of the celestials, has been accomplished.
771	29	13	Do you now, O you of the six attributes, ascend from hence! And accordingly Viṣṇu of mighty energy took his birth in Aditi. And assuming the form of a dwarf, he presented himself before Virocana’s son.
772	29	14	And then asking for as much earth as could be covered by three footsteps, that one ever engaged in the welfare of all creatures; with the object of compassing the good of all, stood occupying the worlds. And having by his power restrained Bali , that one of exceeding energy, again conferred the three worlds upon the mighty Indra, and made them subject to his control.
773	29	15	Formerly he used to dwell in this asylum capable of removing fatigue. And hermitage is infested by Rākṣasas disturbing rites. And, O most puissant of men, here you should slay those ones of wicked ways.
774	29	16	To-day, O Rāma, will I repair to this supremely excellent Siddhāśrama. And this asylum, child, is as much your as mine.
775	29	17	Saying this, taking Rāma and Lakṣmaṇa , the mighty ascetic, experiencing exceeding delight, entered that asylum, and appeared graceful, like the Moon emerged from mist in conjunction with the Punarvasu stars.
776	29	18	And beholding Viśvāmitra, the ascetics inhabiting Siddhāśrama, suddenly rising in joy, worshipped that intelligent one, and extended to the princes the rites of hospitality.
777	29	19	And then having reposed for a while, those unreproved princes, the descendants of Raghu , wiṃ clasped hands, addressed that foremost of ascetics.
778	29	20	Be you even to-day initiated to the ceremony. Good betide you, O best of ascetics! Let this Siddhāśrama verily attain fruition, and let your words be verified!
779	29	21	Thus addressed, that mighty saint of exceeding energy, observing vows, and with his senses under restraint, caused himself to be initiated into the ceremony. And like to the Kumāras , ( Skanda and Viśākha ) Rāma and Lakṣmaṇa, having passed the night pleasantly, rose in the morning; and having finished their morning worship, and with purity and self-restraint recited the prime mantras , paid their obeisance to the sacrificial fire and the sacrifices, Viśvāmitra, who was seated.
780	30	1	Then those princes, repressors of foes, cognizant of place, and time, and words, thus spoke to Kuśika ’s son agreeably to time and place, saying,
781	30	2	O adorable one, do you tell us as to the time when we should oppose those rangers of the night! Let not that hour pass away!
782	30	3	Upon the two Kākutsthas ’ saying this, and finding them prompt for the encounter, those ascetics well-pleased, fell to extolling the sons of the king.
783	30	4	For six nights from to-day, you should protects us. This ascetic has been initiated into the sacrifice, and must, therefore, observe taciturnity.
784	30	5	Hearing these words of theirs, those illustrious princes, renouncing sleep, began to guard the hermitage day and night; and those heroic and mighty archers protected that best of ascetics and subduer of enemies.
785	30	6	When time had thus gone by and the sixth day had arrived, Rāma said to Sumitrā ’s son. Being well equipped, be you vigilant!
786	30	7	When Rāma, manifesting emotion, and being eager for encounter, had said this, the priests and spiritual guides lit up the altar. And along with Viśvāmitra and the family priests, they lit up the altar furnished with Kuśa , and Kāśa , and ladles, and faggots, and flowers.
787	30	8	And as reciting mantras , they were about to duly engage in that sacrifice, there arose a mighty and dreadful uproar in the sky.
788	30	9	And as in the rains, masses of clouds appear enveloping the firmament, the Rākṣasas , displaying illusions in that wise, began to rush onward. And Mārīca and Subāhu together with their followers coming in dreadful forms, began to shower down blood upon the altar.
789	30	10	And on seeing the altar deluged with gore, Rāma suddenly rushed forward, and behold them in the sky. And suddenly seeing them rushing in amain, the lotus-eyed Rāma fixing his gaze at Lakṣmaṇa , said.
790	30	11	Behold O Lakṣmaṇa, by means of a Mānava weapon, I shall, without doubt, drive away the wicked; flesh-eating Rākṣasas, even as the wind drive away clouds before it. Surely I cannot bring myself to slay such as these.
791	30	12	Saying this, that descendant of Raghu , Rāma, in vehemence fixing on his bow an exceedingly mighty and gloriously-dazzling Mānava weapon, discharged it in great wrath at Mārīca’s chest.
792	30	13	And wounded by that foremost of Mānava weapons, Mārīca carried off a sheer hundred Yojanas , dropped in the midst of the ocean.
793	30	14	And finding Mārīca senseless, and whirling, and afflicted by the might of the weapon, and overcome, Rāma addressed Lakṣmaṇa, saying.
794	30	15	Behold, O Lakṣmaṇa, this Mānava weapon first used by Manu , depriving him of his senses has carried him off, and yet has not taken his life!
795	30	16	But these shameless, wicked, and blooddrinking Rākṣasas, delighting in wrong-doing, these disturbers of sacrifices, will I slaughter.
796	30	17	Having said this, anon showing to Lakṣmaṇa his lightness of hand, Raghu’s descendant took out a mighty Āgneya weapon, and discharged it at the breast of Subāhu. Thereat being pierced with that shaft, he fell down upon the ground. Then taking a Vāyavya weapon, the illustrious and exceedingly generous Rāghava , bringing delight to those ascetics, slew the rest.
797	30	18	Having destroyed all those Rākṣasas disturbing sacrifices, Raghu’s descendant was honoured by the saints, even as Indra in day of yore, after having vanquished the Asuras .
798	30	19	When the sacrifice had been completed, the mighty ascetic Viśvāmitra, beholding all sides cleared of Rākṣasas, spoke to Kākutstha , saying,
799	30	20	O mighty-armed one, I have obtained my desire; and you have executed your preceptor’s mandate. And, O illustrious hero, you have truly made this a Siddhāśrama . Having thus extolled Rāma, he took Rāma and Lakṣmaṇa, to perform his evening devotions.
800	31	1	Those heroes, Rāma and Lakṣmaṇa , their interest secured, with glad hearts passed that night there.
801	31	2	And when the night had passed away and the morning come, they together appeared before the saint, Viśvāmitra , and the rest.
802	31	3	And having saluted that foremost of ascetics resembling flaming fire, your addressed him in gentle and honied accents.
803	31	4	These servants of yours, O best of ascetics, have come before you. Do you command, O chief of anchorites, what command of your are we to execute
804	31	5	Thus addressed by them the Maharṣis with yiśvāmitra at their head spoke to Rāma, saying,
805	31	6	A highly meritorious sacrifice, O foremost of men, is to be celebrated by Mithilā ’s lord, Janaka . Thither shall we repair.
806	31	7	And you, O tiger among men, must accompany us, and there behold a wonderful jewel of a bow.
807	31	8	And formerly this bow of immeasurable energy, and dreadful, and exceedingly effulgent at the sacrifice, had been conferred in court by the celestials (on king Dcvarata.)
808	31	9	And neither gods nor Gandharvas , neither Asuras nor Rākṣasas nor men, can fix the string upon it.
809	31	10	And desirous of being acquainted with the prowess of this bow, many kings and princes came; but they in spite of their mighty strength, failed in stringing it.
810	31	11	There, O Kākutstha , you will behold that bow belonging to the high-souled king of Mithilā, as well as his exceedingly wonderful sacrifice.
811	31	12	That rare bow, O foremost of men, furnished with an excellent device for griping it, had been solicited by Mithilā’s lord as the fruit of his sacrifice; and the celestials conferred it upon him.
812	31	13	Now, O descendant of Raghu , in the residence of the king, the bow is worshipped like a deity with aguru dhūpa , and various other incenses.
813	31	14	This having been said, that foremost of ascetics, in company with Kākutstha and the saints, departed.
814	31	15	And on the eve of setting out, he addressed the sylvan deities, saying, Luck! I will, with my desire obtained, go from forth this Siddhāśrama to the Himavat mountain on the north of the Jāhnavī .
815	31	16	Having said this, that tiger-like ascetic, Kuśika ’s son, along with other anchorets having asceticism for their wealth, set out in a northerly direction.
816	31	17	And as that best of ascetics proceeded, he was followed by Brāhmaṇas , unholding the Veda , carrying the sacrificial necessaries on an hundred cars.
817	31	18	And birds and beasts dwelling in Siddhāśrama followed the high-souled Viśvāmitra having asceticism for wealth.
818	31	19	Having proceeded a long way, when the sun was sloping down, the ascetics rested on the banks of the Śoṇa . And when the maker of day had set, having bathed and offered oblations to the fire those ascetics of immeasurable energy, placing Viśvāmitra in their front, sat them down. And Rāma also together with Sumitrā ’s son, having paid homage to those ascetics, sat him down before the intelligent Viśvāmitra.
819	31	20	Then Rama of exceeding energy, influenced by curiosity, asked that foremost of ascetics, Viśvāmitra, having asceticism for his wealth, saying, O worshipful one, what country is this, graced with luxuriant woods? I am desirous of hearing this Good betide you, it behove you to tell me this truly.
820	31	21	Thus addressed by Rāma, that one of high austerities and excellent vows began in the midst of the saints to describe the opulence of that region.
821	32	1	Once upon a time there was a mighty son of Brahmā , of high austerities, named Kuśa . And he was cognizant of duty, and ever engaged in observing vows and honouring good men.
822	32	2	That high-souled one beget on Vaidarbha , sprung from a respectable line and endowed with all noble qualities, four sons like to himself, and possessed of extraordinary prowess— Kuśāmba , and Kuśanābha , and Asūrtarajas, and Vasu , resplendent and breathing exhaustless spirits. And with the desire of enhancing Kṣetrya ( Kṣatra ?) merit, Kuśa said to his truthful and virtuous sons—‘You sons! do you engage in the task of governing, and thereby acquire immense merit.’
823	32	3	Hearing Kuśa’s words, those four foremost of men and best of sons addressed themselves to founding seats for their government. And the highly energetic Kuśāmba founded the city of Kauśāmbī ; and the righteous Kuśanābha, the metropolis of Mahoḍaya; and the magnanimous Asūrtarajas, Dharmāraṇya ;.and king Vasu, Girivraja , best of capitals.
824	32	4	This city (otherwise) called Vasumatī belongs to the high-souled Vasu. And the river known by the name of Sumāgadhī flows through the Māgadhas . And in the midst of the five foremost of hills, it looks like a garland.
825	32	5	And this Māgadhī , O Rāma , belongs to the high-souled Vasu, taking, O Rāma, an easterly course, and flowing through fertile fields furnished with com.
826	32	6	O descendant of Raghu , the Rājarṣi Kuśanābha beget an hundred godly daughters on Ghṛtācī .
827	32	7	And it came to pass that they endowed with youth, beautiful and like to the lighting in the rainy season, decked in excellent ornaments, coming to their garden were merrily singing and dancing and playing on musical instruments, O Rāghava ! And as they perfect in every limb, and unparalleled on earth in beauty, and endowed with all qualities, and furnished with youth and grace, were in the garden, like to stars embossed among clouds, that life of all (the air, beheld them and said.)
828	32	8	I seek for you: do you become my wives. Do you renounce this human guise, and attain long lives.
829	32	9	Youth verily is unstable, specially with the human beings: do you attaining unfading youth, become immortal!
830	32	10	Hearing this speech of the Air of ever fresh energy, the damsels ridiculing it, said.
831	32	11	You range the hearts of all creatures, O foremost of celestials, and we also know your influence. Wherefore, then, do you dishonour us?
832	32	12	O foremost of celestials, we are the daughters of Kuśanābha O divine one. And god as you are, we can dislodge you from your place; but we refrain from doing so, lest thereby we lose our ascetic merit.
833	32	13	May, O foolish one, that time never come, when disregarding our truthful sire, we following our inclination, shall resort to self choice.
834	32	14	Our father verily is our lord an prime god. Of him even shall we become the wives to whom our father give us away.
835	32	15	At these words of theirs, that lord and adorable one, the Air, exceedingly enraged, then entered into their bodies, and brake all their limbs. Their bodies being thus broken by Air, those damsels, exceedingly agitated and overwhelmed with shame, with tears in their eyes entered the residence of the king.
836	32	16	And finding his supremely beautiful and favourite daughters with their limbs broken, and woebegone, the king bewildered, spoke.
837	32	17	You daughters, what is this? Who is it that thus disregards virtue? By whom have you all come by this crooked form? And why demonstrating your grief, do you not answer me?’ Having said this, the king heaved a deep sigh and became eager to hear all about it.
838	33	1	Hearing those words of the intelligent Kuśanābha , his hundred daughters touching his feet with their heads, said,
839	33	2	O king, that life of all, the Air, was desirous of overcoming us, having recourse to an improper way; nor did he regard morality,
840	33	3	We have a father, good betide you; and we live at ease. Do you ask our father about it, if he consent conferring us on you.
841	33	4	But that wicked wight did not listen to our words; and as we were saying this, were we roughly handled by him.’
842	33	5	Hearing those words of theirs, the highly pious and puissant king addressed his hundred beautiful daughters, saying
843	33	6	You have displayed a signal example of that forgiveness which is fit to be followed by the forbearing; and that you have unanimously regarded the honour of my house, also conduces to your praise.
844	33	7	Alike to men and women, forbearance is an ornament. And difficult it is for one to exercise that forbearance, specially in respect of the celestials. And may every descendant of mine possess forbearance like to yours!
845	33	8	Forbearance is charity; forbearance is truth; forbearance, O daughters, is sacrifice; forbearance is fame; forbearance is virtue, you, the universe is established in forbearance;
846	33	9	Then dismissing his daughters, the king endowed with the prowess of celestials, and versed in counsel, began to consult with his counsellors about the bestowal of his daughters, in respect of time and place and person and equability of lineage.
847	33	10	It came to pass that at this time, an ascetic named Cūlī, highly effulgent, with his vital fluid under control, and of pure practices, was performing Brāhma austerities.
848	33	11	And as the saint was engaged in austerities, good betide you, Urmilā ’s daughter named Somadā —a Gandharvī —ministered to him.
849	33	12	And in all humility that virtuous one for a definite period was engaged in ministering to him. And thereat, her spiritual guide was gratified with her.
851	33	14	Thereupon, concluding that the ascetic was gratified, the Gandharvī, cognizant of words, exceedingly delighted, sweetly addressed that one versed in speech.
852	33	15	You are furnished with the Brāhma marks, art sprung from Brahmā , and art of mighty austerities. I desire of you a righteous son endowed with the Brāhma ascetic virtues.
853	33	16	I am without a husband, good betide you, and I am no one’s wife. Upon me who is your servant you should confer such a son by help of Brāhma means.
854	33	17	Thereupon, well pleased with her, Cūlina conferred upon her an excellent Brāhma mind-begotten son, named Brahmadatta .
855	33	18	And that king, Brahmadatta, founded the flourishing city of Kampilya , even as the sovereign of the celestials founded the celestial regions.
856	33	19	And, O Kākutstha , the righteous king Kuśanābha finally decided on conferring his hundred daughters upon Brahmadatta.
857	33	20	And inviting Brahmadatta, that highly energetic lord of earth, with a glad heart conferred his hundred daughters upon him.
858	33	21	And O descendant of Raghu, king Brahmadatta resembling the lord himself of the celestials, by turns received their hands in marriage.
859	33	22	And as soon as he touched them, the hundred daughters were cured of their crookedness, and became free from anguish, and were endowed with pre-eminent beauty.
860	33	23	And upon beholding them delivered from (the tyranny of) the Air, the monarch Kuśanābha became exceedingly delighted, and rejoiced again and again.
861	33	24	And he dismissed that lord of earth, king Brahmadatta, in company with his consorts and the priests.
862	33	25	And the Gandharvī Somadā rejoiced exceedingly at the completion of the nuptials of her son; and embracing her daughters-in-law again and again, and extolling her son, she expressed the fullness of her joy.
863	34	1	And, O Rāghava , when Brahmadatta was married, that sonless one, ( Kuśanābha ), with the intention of obtaining male offspring, took in hand a son-conferring sacrifice.
864	34	2	And when the sacrifice had commenced, that son of Brahmā , the exceedingly noble Kuśa , spoke to king Kuśanābha, saying,
865	34	3	O son, there will be born to you a virtuous son like to thyself: you will obtain even Gādhi , and through him enduring fame in this world.
866	34	4	Having said this to king Kuśanābha, Kuśa, O Rāma , entering the welkin, went to the eternal regions of Brahmā.
867	34	5	Then after sometime, an eminently virtuous son, named Gadhi , was born to the intelligent Kuśanābha.
868	34	6	O Kākutstha , even that highly pious Gadhi is my sire. And, O descendant of Raghu , I, called Kauśika , am sprung from Kuśa’s line.
869	34	7	O Rāghava, I had a sister of noble vows born before me. And her name was Satyavatī ; and she was bestowed upon Ṛcīkā.
870	34	8	And following her lord, she ascended heaven in her own proper person. And my highly generous sister, Kauśikī , has finally assumed the form of a mighty river.
871	34	9	And in order to compass the welfare of all creatures, my sister is now a noble and charming river of sacred waters, issuing from the Himavat mountains.
872	34	10	And thenceforth, out of affection for my sister, Kauśikī, I ever dwell happily in the vicinity of the Himavat, O Rāghava.
873	34	11	And that virtuous Kauśikī, Satyavatī, as well established in religion as truth, and chaste, and eminently pious, is now the foremost of streams.
874	34	12	And, O Rāma, it is only for the purpose of completing my sacrifice that leaving her behind, I have come to Siddhāśrama . And now by virtue of your energy, have I attained fruition.
875	34	13	Now, O Rāma, I have narrated to you the circumstances connected with the history of my line and myself, as also of this place, O mighty-armed one, which you had asked me to relate.
876	34	14	But, O Kākutstha, while I was speaking, half the night has been spent. Do you now sleep, good betide you, so that you may not feel any difficulty while on the journey.
877	34	15	The trees stand motionless, and the beasts and birds are silent, and, O descendant of Raghu, all sides have become enveloped in nocturnal gloom.
878	34	16	The noon of night is gradually passing away; and the firmament thick-studded with stars resembling eyes, is illumined up with their light.
879	34	17	And that dispeller of darkness, the mild-beaming moon is rising, gladdening the hearts of all creatures with his splendour.
880	34	18	And night-ranging being terrible carnivorous Yakṣas and Rākṣasas —walk here and there.
881	34	19	Having said this the mighty ascetic of exceeding energy paused. And those ascetics honouring him, said, Excellent! Excellent!
882	34	20	This line belonging to the Kuśikas is exalted and devoted to virtue. And those foremost of men sprung in the Kuśa race are high-souled and like to Brahmarṣis .
883	34	21	And specially you, O illustrious Viśvāmitra , art so. And that best of streams, Kauśikī, has added lustre to your lien.
884	34	22	And the auspicious son of Kuśika having been extolled by those delighted ascetic, the foremost of their order—slept, like to the sun, when setting.
885	34	23	Rāma too along with Sumitrā ’s son having in admiration praised that tiger among ascetics, enjoyed the luxury of slumber.
886	35	1	Having in company with the ascetics passed the remainder of the night on the banks of the Śoṇa , Viśvāmitra , when the day broke, spoke,
887	35	2	O Rāma , the night has passed away, and the mom has come. The hour for performing the prior devotions has arrived. Arise! arise! good betide you! Do you prepare for going.
888	35	3	Hearing these words of his, Rāma, having finished his morning devotions and rites, and ready for departure, said,
889	35	4	This is the Śoṇa, of excellent waters, fathomless, and studded with islets. O Brāhmaṇa , by which way shall we repair.
890	35	5	Thus addressed by Rāma, Viśvāmitra replied. Even this path has been fixed upon by men, that, namely, by which the Maharṣis go.
891	35	6	Having proceeded far, when the day had been half spent, they beheld that foremost of streams, the Jāhnavī , worshipped by ascetics.
892	35	7	Having beheld that river furnished with sacred waters, and frequented by swans and cranes, the ascetics who accompanied Rāghava were exceedingly delighted.
930	37	1	On that celestial being engaged in austerities, the deities with Indra and Agni at their head, desirous of gaining over the generalissimo, Appeared before the Grand-sire.
893	35	8	And they took up their quarters on the banks of the river. And then having bathed and duly offered oblations of water to the gods and the manes of their ancestors, and performed Agnihotra (Sacrifice with burnt offering.) sacrifices, and partaken of clarified butter like to nectar, those high-souled and auspicious ones, with glad hearts, sat down surrounding Viśvāmitra.
894	35	9	And the descendants of Raghu also sat down, occupying prominent places as befitted their rank. Then Rāma with a heart surcharged with cheerfulness spoke to Viśvāmitra, saying,
895	35	10	O adorable one, I desire to hear how the Gaṅgā flowing in three directions and embracing the three worlds, falls into the lord of streams and rivers.
896	35	11	Influenced by Rāma’s speech, the mighty ascetic Viśvāmitra entered upon the history of the Gaṅgā’s origin and progress.
897	35	12	O Rāma, that great mine of ore, Himavat is the foremost of mountains. To him were born two daughters, unparalleled on earth in loveliness.
898	35	13	O Rāma, their mother of dainty waist, the amiable daughter of Meru , named Menā , was the beloved wife of Himavat.
899	35	14	She of whom was born Gaṅgā the elder daughter of Himavat; and, O Rāghava, a second daughter was also born to him, named Umā.
900	35	15	And it came to pass that once upon a time, the deities, with the view of accomplishing some work appertaining to them as divine beings, in a body besought that foremost of mountains for that river flowing in three worlds, Himavat in obedience to duty, conferred upon them his daughter flowing everywhere at will, and sanctifying all creatures. Thereat in the interests of the three worlds, accepting her, those having the welfare of the three worlds, at heart, went away with Gaṅgā, considering themselves as having attained their desire.
901	35	16	The other daughter of the mountain, O descendant of Raghu, adopting a stem vow, began to carry on austerities, having asceticism for her wealth.
902	35	17	And that best of mountains bestowed upon Rudra of unequalled form his daughter Umā, furnished with fiery asceticism and worshipped of the worlds.
903	35	18	And these, O Rāghava, are the daughters of that king of mountains, worshipped of all, viz, Gaṅgā, the foremost of streams, and the divine Umā.
904	35	19	Now, O best of those endowed with motion, have I related to you how that sin-destroying one flowing with her waters in three diverse directions, first, O child, went to the firmament and then ascended the celestial regions.
905	36	1	When the ascetic had spoken thus, both the heroes, Rāma and Lakṣmaṇa , saluting that first of anchorites, said,
906	36	2	O Brāhmaṇa , you have delivered this noble narration fraught with morality. Now it behoves you to speak about the elder daughter of the mountain-king. You are extensively conversant with everything relative to men or gods.
907	36	3	Why is it that purifier of the worlds lave three directions? And why is that foremost of streams, Gaṅgā , famous as wending in three ways
908	36	4	And, O you cognizant of morality, what are her performances in the three worlds? Thereat Viśvāmitra having asceticism for this wealth, began to relate to Kākutstha that history in detail in the midst of the ascetics.
909	36	5	In days of yore, O Rāma, the blue-throated one of mighty asceticism, having entered into matrimony, commenced upon knowing the goddess. And as that intelligent blue-throated god, Mahādeva , was thus engaged in sport, a divine hundred years passed away.
910	36	6	And yet, O Rāma, chastiser of foes, no son was born of her. Thereat all the gods with the Grand-sire at their head became exceedingly anxious.
911	36	7	Who will be able to bear the offspring of this union? And thereupon the celestials repairing to Mahādeva, thus addressed him, saluting low,
912	36	8	O god of gods! O mighty deity! ever engaged in the welfare of all, it behove you to be propitious at the humble salutations of the celestials.
913	36	9	The worlds, O foremost of celestials, are incapable of bearing your energy. Therefore, for the welfare of the three worlds, do you, being furnished with Brahmā asceticism, in company with the goddess practise austerities, and rein in your energy by your native indomitableness.
914	36	10	Do you preserve these worlds; for it become you not to destroy all.’
915	36	11	Hearing the words of the deities, the great god of the worlds said to them, ‘So be it!’ And addressing them again he said,
916	36	12	You gods, by my own energy I will assisted by Umā bear my virile vigour, therefore let the creation find rest!
917	36	13	But tell me, you foremost of celestials, who will sustain my potent virility rushing out from its receptacle?’
918	36	14	Being thus addressed, the gods answered him having the bull for his mark, ‘The earth will today bear your vital flow.’
919	36	15	Thus assured, the mighty lord of the celestials let go his vital fluid; and thereat the earth containing mountains and forests was overspread with the energy.
920	36	16	Then the gods spoke to the Fire, saying, ‘Do you in company with the Wind entrain to this fierce an mighty energy!’
921	36	17	When the Wind had entered into it, it was developed into a white hill, and a forest of glossy reeds, resembling fire or the Sun.
922	36	18	Here sprang from Fire Kārtikeya of mighty energy. And thereupon the celestials and the saints, with gratified hearts, began to pay enthusiastic adorations to Umā and Śiva .
923	36	19	Then the Mountain’s daughter, O Rāma, addressed the celestials, cursing them with eyes reddened in wrath.
924	36	20	While in association with Mahādeva for obtaining sons, I was broken in upon by you, for this, you shall not be able yourselves to beget offspring on your wives. And from this day forth, your wives shall remain without issue.’
925	36	21	Having thus spoke to the celestials, she cursed the Earth also, saying, ‘O Earth, you will have multiform surface and many husbands.’
926	36	22	Nor, stained because of my ire, shall you experience the pleasure that is felt on obtaining a son, O you of wicked understanding, O you that do not wish me a son!
927	36	23	Witnessing the gods, thus distressed, the lord of the celestials set out in the direction presided over by Varuṇa (The West).
928	36	24	And having repaired to the north side of that mountain, Maheśvara along with the goddess became engaged in austerities on the peak Himavatprabhava.
929	36	25	I have now related to you, O Rāma, the spread of the Mountain’s daughter, (Gaṅgā). Do you now together with Lakṣmaṇa listen to the narration of Bhāgīrathī ’s potency.
931	37	2	And, O Rāma , the gods with Agni at their head, bowing to him, addressed that possessor of the six attributes, the Grand-sir, saying,
932	37	3	Do you now, O you conversant with resources, so order as is advisable in the interests of the worlds! Verily you are our prime way.’
933	37	4	Hearing the words of the deities, the Grand-sire of all creatures, consoling them with soft words, spoke to them saying:
934	37	5	‘Even as the Mountain’s daughter has said, sons will not be born to you of your own wives. Her words is infallible of a certainty: there is no doubt about it.
935	37	6	This is the celestial Gaṅgā she on whom Hutāśana will beget a son—the foe-subduing generalissimo of the celestials.
936	37	7	And the elder daughter of the Mountain will consider that son as brought forth by Umā; and Umā also will, without doubt, look upon him with regard.’
937	37	8	Hearing these words of him O descendant of Raghu , the gods bowing to the Grand-sire, paid him homage.
938	37	9	Then, O Rāma, repairing to the Kailāsa mountain teeming with metals, the deities commissioned Agni with the view of having a son (born to him.)
939	37	10	‘Do you, O god, accomplish this work of the oddities! O you of mighty energy, do you discharge your energy into that daughter of the Mountain, Gaṅgā.
940	37	11	Thereupon giving his promise to the gods, Pāvaka * (Fire) approached Gaṅgā, saying, ‘Do you, O Goddess, bear an embryo; for even this is the desire of the deities.’
941	37	12	Hearing this speech, she assumed a divine appearance. And beholding her mightiness, Agni was shrunk up on all sides.
942	37	13	And then Pavaka from all sides discharged his energy into her, and thereat all her streams became surcharged with it,
943	37	14	O descendant of Raghu. And to him staying at the head of all the deities, Gaṅgā spoke, saying, ‘O god, I am incapable of sustaining this new sprung energy of yours: I am burning with that fire, and my consciousness fails me.’
944	37	15	Thereupon that partaker of the oblations offered to the gods, said to Gaṅgā, ‘Do you bring forth your embryo on the side of this Himavat !’
945	37	16	Hearing Agni’s words, Gaṅgā of mighty energy cast her exceedingly effulgent embryo on her streams, O sinless one.
946	37	17	And as it came out of her, it wore the splendour of molten gold; and in consequence of its fiery virtue, objects near and objects far were converted into gold and silver of unsurpassed sheen, while those that were more distant were turned into copper and iron.
947	37	18	As soon as the embryo was brought forth, the woods adjoining the mountain, being overspread with that energy, were turned into gold.
948	37	19	And from that day, O descendant of Raghu, gold of effulgence like to that of fire, became known as Jātarūpa , O foremost of men!
949	37	20	And when the son was born, the deities with Indra and the Maruts enjoined upon the Kṛttikā stars to suckle him.
950	37	21	‘Surely he shall be son to us all’—concluding thus, they as soon as he was born, by turns began to dispense milk to him.
951	37	22	Then the celestials called him Kārtikeya , saying, ‘Without doubt, this son shall become famed over the three worlds.’
952	37	23	And hearing those words of theirs, the Kṛttikās bathed the offspring that had issued from her womb, flaming like fire, and with auspicious marks.
953	37	24	And, O Kākutstha , since Kārtikeya had issued from (Gaṅgā’s) womb the celestials called that effulgent and mighty-armed one, Skanda .
954	37	25	And then the teats of the Kṛttikās were filled with milk; and thereupon assuming six mouths, he began to suck milk from the teats of those six.
955	37	26	Having drunk the milk, that lord although then possessed of a tender frame, by virtue of his inborn prowess in one day vanquished the Dānava forces.
956	37	27	And him possessed of mighty effulgence, the celestials assembled with Agni as their leader sprinkled with water, by way of installing him as their generalissimo.
957	37	28	He who, O Kākutstha, on earth revere Kārtikeya, is blessed, and attain righteousness, and being long-lived and obtaining sons and grand-sons, repair to the regions of Skanda.
958	38	1	Having said those words to Rāma , composed of melodious letters, Kauśika again spoke to Kākutstha , saying,
959	38	2	Formerly there was a king—lord of Ayodhyā -named Sagara . And it came to pass that righteous one, though eagerly wishing for children was without issue.
960	38	3	O Rāma, Vidarbha ’s daughter, named Keśinī , was the elder wife of Sagara. And she was virtuous and truthful.
961	38	4	The second wife of Sagara was called Sumati , who was the daughter of Ariṣṭanemi and the sister of Suparṇa ( Garuḍa ).
962	38	5	And with those wives of his, that mighty king, coming to the Himavat , began to practice austerities on the mountain Bhṛguprasravaṇa.
963	38	6	When a full hundred years had been numbered, the ascetic that had been adored by means of these austerities, Bright, best of those endowed with truth, conferred a boon upon Sagara, saying.
964	38	7	O sinless one, you shall obtain glorious offspring; and, O foremost of men, you shall attain unparalleled renown among Man.
965	38	8	O child, one of your con sorts shall bring forth a son who will perpetuate your race; and the other give birth to sixty thousand sons.’
966	38	9	As that best of men was saying this, those daughters of kings, exceedingly delighted, propitiating him, addressed him with clasped hands.
967	38	10	Who of us, O Brāhmaṇa , shall produce a single son, and who many? This, O Brāhmaṇa, we wish to hear. May your word prove true!
968	38	11	Hearing this, the highly pious Bhṛgu said these pregnant words, ‘Do you unfold your minds. Who wishes for what boon, between a single perpetuator of the line, and innumerable sons, possessed of mighty strength, and furnished with fame, and endowed with high spirits?’
969	38	12	Hearing the ascetic’s words, O descendant of Raghu , Keśinī in the presence of the monarch chose, O Rāma, a single son to perpetuate the line.
970	38	13	And Suparṇa’s sister, Sumati, sixty thousand sons, high-spirited and furnished with fame.
971	38	14	Then, O son of Raghu, having gone round the saint and bowed down the head, the king went to his own capital, accompanied by his consorts.
972	38	15	And after a length of time, the elder, Keśinī, bore a son to Sagara, known by the name of Asamañja .
973	38	16	And Sumati, O foremost of men, brought forth a gourd. And when it burst open, out came from it sixty thousand sons.
974	38	17	And the nurses fostered them by keeping them in jars filled with clarified butter. And after a great length of time, they attained to youth.
975	38	18	And after a long lapse of time, Sagara’s sixty thousand sons attained to youth and beauty.
976	38	19	O foremost of men, [1] the eldest son of Sagara, taking those children, would, O descendant of Raghu, often cast them into the Sarayū , and in mirth behold them sinking in the waters.
977	38	20	Being thus evil-disposed, and injuring honest folks, and engaged in doing wrong to the citizens, he was banished by this father from the city.
978	38	21	Asamañja had a son possessed of prowess, named Aṃśumān . And he was beloved of all men and fair-spoken towards everyone.
979	38	22	O foremost of men, it came to pass that after a long time had gone by, that lord of earth Sagara made up his mind, saying, ‘I will sacrifice.’
980	38	23	Having determined upon it, that one versed in the Vedas set about it, in company with his priests.
981	38	24	[back to top]
982	38	25	[1] :
983	38	26	The text has Naraśreṣṭhas, put for Asamañja. Evidently this is an error. I make it a vocative.
984	39	1	When Viśvāmitra had ended, hearing his words, Rāma exceedingly pleased, spoke to that ascetic resembling flaming fire, saying,
985	39	2	I am anxious to hear in detail, good betide you, how, O Brāhmaṇa , my ancestor arranged for the sacrifice.
986	39	3	Hearing those words of his, Viśvāmitra, smiling, eagerly spoke to Kākutstha , saying,
987	39	4	Do you, O Rāma, hearken to the story of the high-souled Sagara ’s sacrifice. Śaṅkara ’s father-in-law is the far-famed Himavat . And approaching each other, the Himavat and the vindhya behold each other. And on the region lying between them took place, O foremost of men, that sacrifice of Sagara’s.
988	39	5	And that country, O best of men, is excellent as a sacrificial ground. And, O Kākutstha, equipped with a powerful bow, that mighty car-warrior, living under Sagara’s sway, Aṃśumat , O child, followed the horse, for the purpose of protecting it.
989	39	6	It came to pass that with the intention of disturbing the sacrifice of that monarch, on a certain day Vāsava , assuming the, form of a Rākṣasī , stole away the sacrificial horse.
990	39	7	O Kākutstha, on the horse of that high-souled one being stolen, the priests said to the king engaged in the ceremony, ‘On this auspicious day, has the sacrificial horse been stolen by violence. Do you, O Kākutstha, slay him that steals the horse, and bring it back. Otherwise the sacrifice will be defective, bringing us misfortune. Therefore, do you, O king, act so, that the sacrifice may not bemired with defects.’
991	39	8	Hearing the words of the priests, the king addressed his sixty thousand sons in the midst of his court, saying, Being, as this great sacrifice is, presided over by eminently pious Brāhmaṇas sanctified by mantras , I do not, you foremost of men, you sons, see how Rākṣasas may find entrance into it.’
992	39	9	Therefore, repair you, and seek for the horse, you sons. Good betide you! Do you search the entire earth engarlanded with oceans; and do you search Yojana after Yojana , you sons. And do you delve the earth till you light upon the horse, by my command following the track of that stealer of the horse.
993	39	10	I have been initiated into this sacrifice with my grand-sons and priests.’ I will stay here till you light upon the horse.
994	39	11	And thereat the mighty princes, enjoined by their father, breathing high spirits, began to range the earth.
995	39	12	O Rāma. Then, they each fell to delving the bowels of the earth for the space of a Yojana in length and breadth, with their hands resembling thunder-bolts in fed, and with darts like to thunder-bolts, and with gigantic ploughshares. And being thus rived, the earth, O descendant of Raghu , began to send forth loud cries.
996	39	13	O Rāghava , O you hard to repress, there arose an uproar from serpents, and Asuras , and Rākṣasas, and other creatures, that were being slaughtered.
997	39	14	O descendant of Raghu, they excavated the earth, O Rāma, for sixty thousand Yojanas , you, as if they had intended to reach the lowest depths underground.
998	39	15	Thus, O foremost of kings, those sons of the monarch dug all around Jambūdvīpa , filled with mountains.
999	39	16	Thereat, the gods together with the Gandharvas , and Asuras, and Pannagas , in trepidation appeared before the Grand-sire.
1000	39	17	And propitiating that high-souled one, they with melancholy countenances and in exceeding agitation, spoke these words to the Grand-sire,
1001	39	18	O adorable one, the entire earth is being excavated by the sons of Sagara; and many are the high-souled ones as well as the aquatic animals that are being slain in consequence.
1002	39	19	This one is the disturber of our sacrifice, and by him has the sacrificial horse been stolen, saying this Sagara’s sons are committing havoc upon all creatures.
1003	40	1	Hearing the speech of the celestials, that possessor of the six attributes, the Grand-sire, spoke to them exceedingly frightened and deprived of their senses on beholding the prowess of Sagara ’s sons like to the Destroyer himself,
1004	40	2	This entire Earth belong to the intelligent Vāsudeva , she being his consort. And that adorable one is indeed her lord. And assuming the form of Kapila , he unceasingly sustain the Earth. And the sons of king Sagara will be consumed by the fire of his wrath.
1005	40	3	The pre-ordained excavation of the Earth, as well as the destruction of Sagara’s sons, had been foreseen by the farsighted.
1006	40	4	Hearing the words of the Grand-sire those repressors of their foes, the three and thirty [1] celestials, being exceedingly rejoiced, went back to their respective quarters.
1007	40	5	And as the sons of Sagara were riving the Earth, there arose a mighty noise, like to the bursting of thunder.
1008	40	6	Then, having rived the entire Earth and ranged it all around, the sons, of Sagara together (returned to their father) and spoke to him.
1009	40	7	By us has the Earth been extensively surveyed, and have powerful deities and Dānavas . Rākṣasas , Piśācas , Uragas and Pannagas been slain; and yet do we find neither the horse nor the stealer thereof. What are we to do now? Good betide you, do you consider it well.
1010	40	8	Hearing those words of his sons, that foremost of kings, getting into a wrath, said, O descendant of Raghu .
1011	40	9	‘Do you yet again, good betide you, delve the earth, and having got at the stealer of the horse, cease.’
1012	40	10	Receiving this mandate of their sire, the sixty thousand sons of the high-souled Sagara rushed towards the depths of the earth.
1013	40	11	And as they were engaged in excavating, they beheld the elephant of the quarter resembling a hill, named Virūpākṣa , holding the earth.
1014	40	12	O son of Raghu, that mighty elephant, Virūpākṣa, held on his head the entire earth with its mountains and forests.
1015	40	13	And, O Kākutstha , when on sacred days the mighty elephant, from fatigue, shake his head, then takes place the earthquake.
1016	40	14	Thereupon, O Rāma , going round that mighty elephant, and honouring him duly, they went on piercing the under earth.
1017	40	15	And having pierced the East, they pierced the South, and in the Southern quarter also they beheld a mighty elephant, the high-souled Mahāpadma , resembling a huge hill, holding the earth on his head. And thereat they marvelled greatly.
1018	40	16	And having gone round him, the sixty thousand sons of the high-souled Sagara began to penetrate into the Western region.
1019	40	17	And in the western quarter also those highly powerful ones beheld the elephant of that quarter named Saumanas, resembling a mighty mountain.
1020	40	18	And having gone round him and asked him as to his welfare, they delving on, arrived at the Northern region.
1021	40	19	And on the North like wise, O foremost of the Raghus , they beheld Bhadra , white as snow, holding this earth on his goodly person.
1022	40	20	Having felt as well as gone round him, those sixty thousand sons of Sagara went on penetrating the depths of the earth.
1023	40	21	Then repairing to the famous North eastern region, Sagara’s sons becoming enraged, began to dig the earth.
1024	40	22	And there those high-souled, exceedingly powerful and vehement ones beheld the eternal Vasudeva in the guise of Kapila.
1025	40	23	And there also, experiencing exceeding delight, O descendant of Raghu, they found his horse, browsing hard by.
1026	40	24	And knowing him to be the destroyer of the sacrifice, they bearing spades, and ploughs, and innumerable trees and crags, with eyes reddened with ire, furiously rushed against him, exclaiming, ‘Stay! Stay! And you it is that hast stolen our sacrificial horse.’ O you of wicked understanding, know that you have fallen into the hands of the sons of Sagara.
1027	40	25	Hearing this speech of theirs, Kapila, O descendant of Raghu, overwhelmed with rage uttered a tremendous roar.
1028	40	26	And then, O Kākutstha, the sons of Sagara were reduced to ashes by the high-souled and incomparable Kapila.
1029	40	27	[back to top]
1030	40	28	[1] :
1031	40	29	The eight Vasus, eleven Rudras, twelve Adityas and two Aśvins.
1032	41	1	Seeing the delay on the part of his sons, King Sagara , O son of Raghu , addressed his grandson, flaming in his native energy, saying,
1033	41	2	You are heroic and accomplished and like to your uncles. Do you enquire into the circumstances that have befallen your uncles, as also about the way by which the horse has escaped.
1034	41	3	And as there are strong and mighty creatures inhabiting the Earth’s interior, with the view of resisting them, do you take your how along with your scimitar.
1035	41	4	And honouring those that deserve to be honoured and slaying such as disturb you, do you, having attained your end, come back, becoming the instrument for the completion of my sacrifice.’
1036	41	5	Thus duly enjoined by the high-souled Sagara, Aṃśumān endowed with fleet vigour, taking his bow as well as his scimitar, set out.
1037	41	6	An commanded by the monarch, he found the underground way that had been carved out by those high-souled ones.
1038	41	7	He found an exceedingly powerful elephant belonging to the cardinal point, worshipped by deities, and Dānavas , and Rākṣasas , anc goblins, and birds, and Uragas .
1039	41	8	Having gone round him, and asked him as to his welfare, he enquired after his uncles and the stealer of the horse.
1040	41	9	Hearing this, the mighty-minded elephant of that quarter answered, ‘O son of Asamañja having attained your object, you will speedily return with the horse.’
1041	41	10	And hearing those words of his, Aṃśumat by turns duly asked the same question of all the elephants belonging to the cardinal points.
1042	41	11	And being honoured by those guardians of the cardinal points, knowing words as well as their application in regard to time, place, and person he was asked by them saying, ‘Did you come with the horse?’
1043	41	12	Hearing those words of theirs, that one of fleet vigour repaired to the spot where the sons of Sagara, his uncles, had been reduced to a heap of ashes.
1044	41	13	And (arriving there), Asamañja’s son, smitten with grief, and being exceedingly afflicted at their destruction, bewailed in heaviness of heart.
1045	41	14	And exercised by grief and sorrow, at foremost of men espied there the sacrificial horse straying near.
1046	41	15	And desirous of offering oblations of water to those princes, that highly powerful one, in need of water, did not find any watery expanse in the neighbourhood.
1047	41	16	And it came to pass, O Rāma , that surveying wide, he descried the maternal uncle to the princes, Suparṇa , resembling the Wind.
1048	41	17	And thereupon Vinatā ’s son possessed of mighty strength spoke to him, saying, ‘Do not ament, O foremost of men. The destruction of hese was for the welfare of all.’
1049	41	18	These highly powerful ones had been consumed by the peerless Kapila , therefore, you ought not to offer water to them in consonance with social usage.
1050	41	19	Gaṅgā , O foremost of men, is the elder laughter of Himavat . In her (streams) do you perform the watery rites of your uncles,
1051	41	20	O mighty-armed one: let that purifier of the worlds lave these reduced to a heap of ashes. And on these ashes being watered by Gaṅgā, dear to all, the sixty thousand sons of Sagara will repair to the celestial regions.
1052	41	21	Do you, O highly pious one, go back, taking this horse, O foremost of men; and do you complete the sacrifice of your grand-father,
1053	41	22	O hero. Hearing Suparṇa’s speech, the exceedingly powerful Aṃśumat of mighty asceticism speedily taking the horse, retraced his steps.
1054	41	23	Then coming to the king who had been initiated into the ceremony, he, O descendant of Raghu, faithfully communicated to him the words of Suparṇa.
1055	41	24	Hearing this sorrowful intelligence, the king duly finished the sacrifice agreeably to the scriptures.
1056	41	25	And having seen the completion of the sacrifice, that lord of earth entered his capital; but the king could not see how to bring Gaṅgā on earth.
1057	41	26	And without being able to ascertain it, the mighty monarch after a long course of time, and having reigned for thirty thousand years, ascended heaven.
1058	42	1	When Sagara had bowed to the influence of Time, the subjects selected the righteous Aṃśumat for their king.
1059	42	2	O descendant of Raghu , Aṃśumat proved a great ruler. And his son, the celebrated Dilīpa , was also a great king.
1060	42	3	O Raghu’s son, consigning to Dilīpa his kingdom, Aṃśumat entered upon rigid austerities on the romantic summit of the Himavat .
1061	42	4	Having for the space of thirty-two you sand years carried on austerities in the woods, that highly famous one, crowned with the wealth of asceticism, attained the celestial regions.
1062	42	5	The exceedingly powerful Dilīpa, hearing of the destruction of his grand-fathers, was stricken with grief; yet he could not ascertain his grandfathers, was stricken with grief; yet he could not ascertain his course about it.
1063	42	6	He constantly thought as to how Gaṅgā could be brought down, how to perform their watery rites, and how to deliver them.
1064	42	7	As that pious one furnished with self-knowledge was always meditating upon this, an eminently virthous son was born to him named Bhagīratha .
1065	42	8	Performing numerous sacrifices, the mighty king Dilīpa reigned for thirty thousand years.
1066	42	9	And without having arrived at any definite decision in regard to their deliverance, the king, O puissant one, being attacked with an ailment, breathed his last.
1067	42	10	Having sprinkled his son Bhagīratha in the way of installing him in the kingdom, that prime of men, the king, by virtue of his own acts, repaired to the region of Indra .
1068	42	11	O descendant of Raghu, that royal saint Bhagīratha was possessed of righteousness. And being without issue, and desiring to obtain it, the mighty monarch consigned his kingdom and his subjects to the care of his counsellors, and engaged in bringing down Gaṅgā.
1069	42	12	And, O Raghu’s descendant, restraining his senses, and eating once a month, and surrounding himself with five fires, and with arms upraised, he for a long lapse of time performed austerities at Gokarṇa . And as he was performing his terrible austerities, a thousand years rolled away.
1070	42	13	And thereat that possessor of the six attributes and lord of all creatures, Brahmā , was well pleased with that high-souled monarch. And presenting himself together with the celestials, the Grand-sire thus spoke to the high-souled Bhagīratha engaged in austerities.
1071	42	14	O Bhagīratha, O mighty monarch, pleased am I with you. O lord of men, on account of your ardent austerities: do you, O you of excellent vows, ask for the boon you would have.
1072	42	15	Thereupon that great car-warrior, the highly powerful and mighty-armed Bhagīratha, with clasped hands, said to the grand sire of all creatures,
1073	42	16	If adorable one, you are pleased with me, if you would grant me the fruit of my asceticism, may Sagara’s sons receive water at my hands; and on the ashes of those high-souled ones being laved by the waters of Gaṅgā, may my great-grand-father without fail repair to heaven!
1074	42	17	And, O divine one, I beseech you, may our line never languish for want of offspring. May, O God, this prime boon light upon Ikṣvāku ’s race!
1075	42	18	When the king had said this, the Grand-sire addressed him these sweet and auspicious words composed of melting letters.
1076	42	19	O mighty car-warrior Bhagīratha, high is this your aim. Be it so, good betide you, you enhancer of the Ikṣvāku line.
1077	42	20	This Haimavatī Gaṅgā, Himavat’s elder daughter, even her to hold, O king do you employ Hara .
1078	42	21	For Gaṅgā’s fall, O king, Earth will not be able to sustain. And to hold her, O king find I none save the wielder of the Trident.’
1079	42	22	Having thus addressed the monarch, and greeted Gaṅgā, the creator of the worlds repaired to heaven with the celestials.
1080	43	1	When that god of gods had gone away, Bhagīratha , O Rāma , pressing the earth with his thumb, spent a year in adoring Śiva .
1081	43	2	And when the yea was complete, Umā’s lord, Paśupati , worshipped of all the worlds, spoke to the king, saying,
1082	43	3	O foremost of men, I am well pleased with you: I will do what will before your welfare. I will hold the Mountain’s daughter on my head.
1083	43	4	Then, O Rāma. that one bowed to by all creatures, the elder daughter of Himavat , assuming an exceedingly mighty shape, with irresistible impetus precipitated herself from the welkin upon Śiva’s gracious head.
1084	43	5	And that divine one, Gaṅgā , exceedingly difficult to sustain, thought, ‘I will enter the nether regions, carrying off Śaṅkara by my streams.’
1085	43	6	Knowing her proud intention, the adorable Hara waxed wroth; and the three-eyed deity set his heart upon enveloping Here
1086	43	7	O Rāma, as that sacred one plunged upon Rudra ’s holy head of tangled locks, resembling Himavat she could by no means reach the earth, despite all her endeavours; nor did she obtain egress from under the matted locks. And she wandered there for many a year.
1087	43	8	And finding Gaṅgā in this plight, Bhagīratha became again engaged in high austerities. And thereupon Śiva, O descendant of Raghu , was exceedingly gratified; and cast Gaṅgā off in the direction of the Binḍu lake. And as she was let off seven streams branched out from her.
1088	43	9	And the three streams of the excellent Gaṅgā of auspicious waters took an easterly direction; while the Sucakṣu , the Sītā , and that mighty river the Sindhu flowed on the auspicious west.
1089	43	10	And the seventh followed Bhagīratha’s car. And that royal saint, the exceedingly puissant Bhagīratha, mounted on a superb car, went before; and Gaṅgā followed him. And she descended from the welkin upon Śaṅkara’s head, thence alighting upon the earth.
1090	43	11	And there her waters flowed with thundering sounds. And earth looked beautiful with swarms of fallen and falling fishes, and tortoises, and porpoises.
1091	43	12	Then celestials and saints and Gandharvas and Yakṣas and Siddhas mounted on excellent elephants and horses and cars resembling cities, looked on Gaṅgā descending upon earth.
1092	43	13	And the celestials stationed on cars were struck with surprise; and all creatures marvelled at the excellent descent of Gaṅgā.
1130	45	3	And the live-long night has passed away as I in company with Sumitrā ’s son, was pondering over Viśvāmitra ’s auspicious speech.’
1093	43	14	And eager to witness the spectacle, celestial hosts of immeasurable energy thither and the effulgence of their ornaments, the firmament free from clouds, shone as if with an hundred suns.
1094	43	15	And the sky was graced with fast-fleeting porpoises and serpents and fishes resembling playing lightning; and the welkin scattered with pale foam-flakes by thousands, appeared as if it was scattered with autumnal clouds swarming with cranes.
1095	43	16	And the river proceeded sometimes rapidly, and sometimes awry, and sometimes in volumes and sometimes sloping, and sometimes ascending and sometimes languidly; and sometimes water clashed with water.
1096	43	17	Sometimes ascending an upland, it descended it no a dell. And the pellucid and pure water first descending upon Śaṅkara’s head, and thence on to the earth, appeared exceedingly beautiful.
1097	43	18	And there the saints and the Gandharvas, as well as the inhabitants of the earth, touched the sacred water flowing from Bhava ’s body.
1098	43	19	And those that had fallen from the sky to the earth in consequence of some curse of other, having bathed there, and thereby having their sins washed an removed by that sanctifying water, again ascended the sky and entered the celestial regions.
1099	43	20	And through the agency of that shining water, all beings, feeling delight, rejoiced, and having bathed in Gaṅgā, became cleansed from sin.
1100	43	21	And stationed on an excellent car that mighty king, the royal saint Bhagīratha, went first, and Gaṅgā went at his back.
1101	43	22	The gods, and the saints, and the Daityas , and the Dānavas , and the Rākṣasas , and the foremost of Gandharvas and Yakṣas, and the Kinnaras , and the mighty Uragas , and the Serpents, and the Apsaras , O Rāma, and the acquatic animals in a body following Bhagīrahta’s car, with glad hearts went in the wake of Gaṅgā.
1102	43	23	Whither soever king Bhagīratha went, the famous Gaṅgā, foremost of streams, capable of destroying all sins, went.
1103	43	24	And Gaṅgā flooded the sacrificial ground of the high-souled Jahnu of wonderful deeds, as he was performing a sacrifice.
1104	43	25	Thereat, O Rāghava , reading her insolence, Jahnu, waxing wroth, drank up all her wonderful waters. Thereupon, the deities, and the Gandharvas, and the saints, struck with amazement fell to worshipping that foremost of men, the high-souled Jahnu.
1105	43	26	And that highly energetic lord, being propitiated, let Gaṅgā off through his ears. Therefore it is that Gaṅgā goes by the name of Jahnu’s daughter.
1106	43	27	Then Gaṅgā again began to follow Bhagīratha’s car. And having reached the ocean, that foremost of streams, with the object of accomplishing that work, entered into the subterranean regions.
1107	43	28	Having carefully brought Gaṅgā, that royal saint, Bhagīratha, beheld his grand-fathers deprived of senses, and reduced to ashes.
1108	43	29	The excellent waters of Gaṅgā overflowed that heap of ashes; and thereupon, O best of the Raghus , they their sins purged; attained heaven.
1109	44	1	Then having arrived at the Ocean, the king wending in Gaṅgā ’s wake, entered underneath the Earth, at that spot where those (sons of Sagara ) had been reduced to ashes. And, O Rāma , on the ashes being washed by the waters of Gaṅgā, Brahmā , the lord of all creatures thus spoke to the monarch.
1110	44	2	O most puissant of men, the sixty thousand sons of the high-souled Sagara have been delivered and they have ascended heaven like to celestials themselves.
1111	44	3	O lord of earth, as long as the waters of the ocean shall endure in the world. Sagara’s sons shall reside in heaven like to celestials.
1112	44	4	This Gaṅgā shall become your eldest daughter; and she shall attain celebrity among all, being called after your name.
1113	44	5	And Gaṅgā is called both Tripathagā and Bhāgīrathī . And she is know as Tripathagā, is consequence of her proceeding in three directions.
1114	44	6	Do you now, O lord of men, her offer oblations of water to your grand-sires, and thereby, O king, make good your promise.
1115	44	7	O king, that foremost of righteous ones, your ancestor of exceeding renown, had failed to attain his desire.
1116	44	8	O child Aṃśumat likewise unparalleled in the worlds in energy, had failed in realising his cherished promise of bringing down Gaṅgā.
1117	44	9	Then again that royal saint, crowned with qualities; of austerities like to mine, ever abiding by his Kṣatriya duties, even Dilīpa ’s self, your exceedingly puissant sire.
1118	44	10	O eminently righteous one, had failed in bringing down Gaṅgā according to his cherished resolve, O sinless one. And now, O foremost of men, that promise having been fulfilled by you, you shall attain signal glory in the world by the common consent of all.
1119	44	11	And, O vanquisher of your foes, having brought about Gaṅgā’s dissension, you shall from this act of your also attain the regions of Brahmā.
1120	44	12	Do you, O best of me, lave thyself in these waters worthy of the pious, O prime of men, and thereby become purified, and attain sanctity.
1121	44	13	Do you perform the watery rites of your grand-sires. May luck be your, I shall now repair to my own regions: do you depart, O king.
1122	44	14	Having said this, the illustrious lord of the celestials the Grand-sire of all creatures, went to the celestial regions.
1123	44	15	The royal saint king Bhagīratha also of high fame having performed his ablutions and purified himself, and duly and in proper order offered oblations of water to the sons of Sagara, entered his capital. And attaining exceeding prosperity, that foremost of men ruled his kingdom.
1124	44	16	O descendant of Raghu , having him as their sovereign, the people rejoiced greatly; and with their griefs removed and prosperity secured, they lived in peace of mind.
1125	44	17	Thus, O Rāma, have I ḍefailed to you the history of Gaṅgā. Auspiciousness may you obtain! Good betide you, the evening draw nigh.
1126	44	18	He that recite this story conferring prosperity, fame, long life, and heaven to Vipras , Kṣatriyas , and other, attain the good graces of his ancestors and the celestials.
1127	44	19	O Kākutstha , he that listen to the sacred history of Gaṅgā’s descent, conferring length of days, attain all his desires, and all his sins are destroyed, and his life and fame increase.
1128	45	1	O Brāhmaṇa , wonderful is the story that you have recited to us, viz; that of Gaṅgā ’s sacred dissension and the replenishing of the Ocean.
1129	45	2	And, O afflicter of foes, as we had been reflecting upon all this at length, the night has passed away as if it were as moment.
1131	45	4	Then in the morning which happened to be bright, that subduer of his foes, Raghu ’s descendant, addressed the ascetic Viśvāmitra, who had finished his devotion.
1132	45	5	The auspicious night is past, and we shall (again) listen to your wonderful narrations. Let us now cross over this sacred stream, foremost of rivers, wending in three ways.
1133	45	6	And learning that you have arrived at this place, the pious ascetics have speedily come hither, and have also brought this barque with a spacious carpet.
1134	45	7	Hearing those words of the high-souled Rāghava , Kauśika crossed over the crowds of ascetics; and on reaching the north bank, he paid homage to the saints. And when they had landed on the banks of the Gaṅgā, they beheld a city named Viśālā .
1135	45	8	And thereupon speedily that that foremost of ascetics in company with Rāghava, went towards Viśālā, beautiful and elegant like to the celestial regions.
1136	45	9	Then the highly wise Rāma , with folded hands, asked that mighty ascetic Viśvāmitra concerning the excellent city of Viśālā.
1137	45	10	O mighty ascetic, what royal line reside in yonder large city? I desire to hear this, good betide you; and great is my curiosity.
1138	45	11	Hearing those words of Rāma, that foremost of ascetics began to relate the history of Viśālā, saying,
1139	45	12	Do you listen, O Rāma to what I had heard from Śakra relating this history; and, O descendant of Raghu, do you listen to all that befell in this city.
1140	45	13	Formerly in the Krita age, O Rāma, Diti ’s highly powerful sons, as well as those of Aditi , possessed of prowess, and virtuous and pious, high-souled ones both.
1141	45	14	O foremost of men, fell to reflecting, ‘How can we become exempt from decrepitude and disease, and immortal.’
1142	45	15	And as they reflected, it struck them, ‘By churning the ocean of milk, we must obtain ambrosia.’
1143	45	16	Then deciding upon churning (the ocean), those ones of immeasurable. energy making Vasuki the cord, and the Mandara (hill), the stick, began to chum the deep.
1144	45	17	After a thousand years had gone by, the hoods (of the serpent) serving as the churning cord, began to vomit virulent venom and to bite at the crags, with their fangs.
1145	45	18	And thereat there came out powerful poison like to fire; and in consequence the entire universe with celestials, and Asuras , and men, began to bum.
1146	45	19	And thereupon, intending to seek refuge, they appeared before that mighty god, Śaṅkara , or Paśupati , or Rudra , hymning him.
1147	45	20	‘Save us, Save us.’ When that master, the lord of the celestials, was being thus addressed by the deities, there appeared before them Hari bearing the conch and the discus.
1148	45	21	Smiling Hari said to the trident-bearing Rudra, ‘O chief of the celestials, since you are the foremost of the gods, this that has come out of the ocean churned by the celestials, in your. Remaining here, O lord, do you receive the first offering in the form of this poison.’
1149	45	22	Having said this, that best of celestials vanished there. Witnessing the dismay of the celestials, and hearing also the words of Śārṅgiṇa, Śiva took in that dreadful poison as if it were nectar; and then leaving the deities, the worshipful Hara wen away.
1150	45	23	And then, O descendant of Raghu, as the celestials resumed the churning, that foremost of hills serving as the cord, entered the subterranean regions.
1151	45	24	Thereupon the gods and the Gandharvas felt to extolling the slayer of Madhu , saying, ‘You are the way of all beings, of the celestials in especial, do you, O mighty-armed one, protect us, and recover the mountain.’
1152	45	25	Having heard this, Hṛṣīkeśa , or Hari, assuming the form of a tortoise, stood in the sea, supporting the hill on his back.
1153	45	26	That Soul of all, Keśava , best of male beings, taking hold of the top of the hill by his hand, began to chum the deep, stationed in the midst of the celestials.
1154	45	27	After a thousand years, had rolled on, arose a male being impregnated with the Āyurveda , of exceedingly righteous soul, called Dhanvantari , bearing in his hands a stick, and a Kamaṇḍalu And there arose also, from the cream of the churning waters, those magnificent dames the shining Apsaras .
1155	45	28	And, O foremost of men, as they had emerged from water, they are called Apsaras.
1156	45	29	There sprang sixty koṭis of shining Apsaras And, O Kākutstha , the female attendants of those are numberless.
1157	45	30	And neither the deities nor the Dānavas would accept them, and in consequence of this non-acceptance, they are known as women belonging to all.
1158	45	31	And then, O Raghu’s descendant, arose the eminently pious daughter of Vāruṇa , Vāruṇī who fell to looking for acceptance.
1159	45	32	And Diti's sons, O Rāma, did not accept the daughter of Vāruṇa and Aditi’s sons, O hero accepted that one of blameless limbs.
1160	45	33	Hence Diti’s son go by the name of Asuras and Aditi’s by that of Suras . And the celestials became exceeding glad, on having accepted Vāruṇī.
1161	45	34	O foremost of men, next arose ucchaiśravā best of horses, and also Kaustubha ; and next, the excellent ambrosia.
1162	45	35	O Rāma, tremendous was the carnage for the possession thereof (ambrosia); and Aditi’s and Diti’s sons fought together.
1163	45	36	And the Asuras assembled together with the Rākṣasas ; and, O hero, mighty was the battle that was fought, striking terror into the three worlds.
1164	45	37	And when a great havoc had been committed the highly powerful Viṣṇu , assuming a captivating form speedily stole away the ambrosia.
1165	45	38	And those that came forward before that best of male beings, Viṣṇu, knowing no deterioration, were crushed in conflict by Viṣṇu in a different form.
1166	45	39	And in that exceedingly dreadful battle between the sons of Diti and Aditi, those heroic ones viz., Aditi’s heroic sons slaughtered those of Diti.
1167	45	40	Having slaughtered the sons of Diti’s and regained his kingdom, he happily began to rule the worlds, containing saints and Cāraṇas .
1168	46	1	On those sons of her being slain, Diti afflicted with great grief, thus addressed her husband, Marīci ’s son, Kaśyapa .
1169	46	2	O adorable one, your high-souled sons have slain mine. I now wish for a son, who, obtained through long austerities, will be able to slay Śakra .
1170	46	3	I will engage in austerities: it behoves you to grant me such an embryo, such a slayer of Śakra it behoves you to promise me.
1171	46	4	Hearing those words of hers, Marīcī’s son, Kaśyapa of exceeding energy answered the deeply aggrieved Diti, saying.
1172	46	5	Be it so. Good betide you, do you become pure, O ascetic. If you remain pure, when a full thousand years shall be complete, you will give birth to a son who will slay Śakṣa in battle.
1173	46	6	And through me, you will give birth to a son that will destroy the three worlds. Having said this, that highly energetic one rubbed her persoṅ with his palm. And having rubbed her, he said, ‘Luck!’ and then went away to carry on austerities.
1174	46	7	When he had gone, Diti, O foremost of men, becoming exceedingly delighted, went to, Kuśaplava and began to practise rigid mortifications.
1175	46	8	O foremost of men, as she was practising austerities, the thousand-eyed deity most dutifully ministered to her.
1176	46	9	The thousand-eyed one provided for her fire, and Kuśa , and faggots, and water, and fruits, and roots, and other things that she wanted.
1177	46	10	And at all times, Śakra served Diti by rubbing her person, and removing her fatigue.
1178	46	11	When ten years only were wanting to complete the thousand years, Diti, O descendant of Raghu , being exceedingly delighted, thus spoke to the thousand-eyed one.
1179	46	12	O best of those endowed with prowess, of me engaged in austerities, ten years only remain (to complete the period.) And after that time, good betide you, you will behold your brother.
1180	46	13	I will, O son, bind him to you in affection, whom I had besought for to compass your destruction, so that, the fever of your heart removed, you will with him enjoy the victory of the three worlds.
1181	46	14	On your high-souled sire having been besought by me, he, O foremost of celestials, granted me the boon that after a thousand years, I shall obtain a son.
1182	46	15	And it came to pass that having said this, the sun being in his meridian, the worshipful Diti with her feet placed at that part of the bed which should contain her head, was overpowered by sleep.
1183	46	16	And thereupon seeing her resting her feet at the place where she should place her head, and consequently unclean, Śakra was exceedingly delighted, and smiled.
1184	46	17	O Rāma , Purandara entered into her womb, and that highly self-controlled one served the embryo in seven parts.
1185	46	18	And the embryo being pierced by the thunder-bold of an hundred knots, cried at the top of its voice, and thereat Diti awoke.
1186	46	19	‘Do not cry, do not cry,’ exclaimed Śakṣa: and even while it was crying, the mighty-minded Vāsava continued piercing it.
1187	46	20	‘Do not slay it; do not slay it’ said Diti. Thereupon, in consideration of the honour of his mother, Śakra went out.
1188	46	21	Then he with clasped palms accosted Diti, saying, ‘O worshipful one, you did sleep with they feet placed where your head should have lain, and hast therefore become impure. And finding this opportunity, I severed in seven pieces that would-be slayer of mine in battle. Do you, O worshipful one, excuse me.’
1189	47	1	When the embryo had been sundered is seven, Diti exceedingly aggrieved humbly spoke to the irrepressible thousand-eyed deity, saying,
1190	47	2	By my fault it is that the embryo has been sundered in seven. O chief of the celestials, herein you are guilty of no transgression, O destroyer of Bala .
1191	47	3	And since calamity has befallen the embryo, I wish to do you a good turn. Let the seven parts become the guardians of the seven Maruts .
1192	47	4	O son, let my sons having noble forms, becoming famous as Marutas range the Vātaskandha regions in heaven.
1193	47	5	Let one range Brahmā ’s regions, and another Indra ’s, and the highly illustrious third also range around, being known as Divya Vāyu , (Ether).
1194	47	6	O best of celestials, by they command, let the four remaining sons of mine, known by the name which you have mentioned, range about in appointed periods.’
1195	47	7	Hearing her words, that destroyer of Vala ; the thousand-eyed Purandara , with clasped palms said.
1196	47	8	All this that you have said must come to pass; there is no doubt about it. Good betide you, your sons endowed with celestial forms, shall range about.
1197	47	9	And it has been heard by us that having thus ascertained in that hermitage, the mother and the son, O Rāma , went to heaven, their desire obtained.
1198	47	10	Even this O Kākutstha , is the place where formerly the mighty Indra sojourned, and where he attended upon Diti of accomplished ascetic success.
1199	47	11	O most powerful of men, Ikṣvāku had an exceedingly righteous son born to him of Alambuṣa , known by the name of Viśāla . And here stood a palace, built by him, called Viśālā .
1200	47	12	Viśāla’s son, O Rāma, was the mighty Hemacandra . And after Hemacandra comes the celebrated Sucandra .
1201	47	13	O Rāma, the son of Sucandra was Dhumrāśva, and then was born Sṛñjaya son to Dhumrāśva.
1202	47	14	Sṛñjaya’s son was the powerful Sahadeva , And Sahadeva’s son was the pre-eminently pious Kuśāśva .
1203	47	15	Kuśāśva’s son was the puissant Somadatta . And now, O Kākutstha, Somadatta’s son, the effulgent and invincible and renowned Sumati reside in this mansion.
1204	47	16	And by the grace of Ikṣvāku, all the sovereigns of Viśālā are long-loved, and high-souled, and puissant, and pious.
1205	47	17	And here will we happily spend a night; an on the morning of the morrow you will, O foremost of men, behold Janaka .’
1206	47	18	And having heard that the illustrious Viśvāmitra had come, that best of kings, the effulgent Sumati, appeared before him.
1207	47	19	And having paid Viśvāmitra high homage together with his priests and friends, and with clasped hands enquired after the former’s welfare, he addressed Viśvāmitra, saying.
1208	47	20	Blessed are we, and obliged are we, whose domains, O ascetic, have been graced with your presence. Surely none is more blessed than I am.
1209	48	1	Having met together they enquired after each other’s welfare. And then Sumati spoke to the mighty ascetic, saying.
1210	48	2	Good betide you, boasting the prowess of celestials of elephantine or leonine gait, heroic, resembling tigers or bulls, possessed of expansive eyes like lotus-petals, bearing scimitars and bows and quivers, like to the Aśvins in grace, endowed with youth, like to celestials fancy-led, descended from ethereal regions to the earth beneath, whose sons; O ascetic, are these boys, and what for have they come hither, and why also is it that they journey of foot?
1398	56	15	Thus addressed, that highly energetic one of rigid austerities, became pacified.
1211	48	3	And adorning all directions, like to the Sun or the Moon adorning the firmament, and resembling each other, in personal proportions, and expressions, and gestures, and equipped with excellent weapons, and war-like, how have these paragons of men, come into this impracticable way? I Wish to hear all this related truly.
1212	48	4	Having heard his words, Viśvāmitra faithfully related all about it. Hearing Viśvāmitra’s words, the king was extremely surprised; and having those sons of Daśaratha as his all-worthy guests, received with becoming respect those highly powerful ones deserving of hospitality.
1213	48	5	Meeting with such splendid reception from Sumati, those descendants of Raghu spent there a night, and the next day set out for Mithila .
1214	48	6	Beholding Janaka ’s beauteous city, the ascetics exclaiming, ‘Excellent’ fell to admiring Mithilā .
1215	48	7	And in a grove at Mithilā, Rāghava saw an ancient, lonely, and romantic asylum, and asked that foremost of ascetics, saying.
1216	48	8	What is this that look like an asylum, though without any ascetics? I wish to hear, O worshipful one, to whom this asylum belonged in time past.
1217	48	9	Hearing this speech addressed by Raghu’s descendant that one versed in speech, the highly energetic and mighty saint, Viśvāmitra, answered.
1218	48	10	Ah! Do you listen. I will tell you through the wrath of what high-souled one this hermitage came to he cursed.
1219	48	11	O foremost of men, this excellent asylum honoured by the celestials themselves, formerly belonged to the high-souled Gautama .
1220	48	12	Here, O illustrious prince, in days of yore Gautama in company with Ahalyā earned on austerities for a long series of years.
1221	48	13	And perceiving occasion Śacī ’s lord, the thousand-eyed deity assuming the form of that ascetic thus addressed Ahalyā.
1222	48	14	O exceedingly beautiful one, those bent upon sport, do not stay for the menstrual season. And, O graceful one, I desire to enjoy your company (on the instant).
1223	48	15	Thereupon, out of curiosity, that one of perverse understanding consented to the proposals of the chief of the celestials.
1224	48	16	Then, having attained her object, she spoke to that foremost of the celestials, saying, ‘O best of the immortals, I have obtained my desire, do you speedily go from this place, O lord. Do you, O lord of the celestials, from a sense of respectability preserve yourself and me also.’
1225	48	17	Indra too said to Ahalyā, ‘O you of shapely hips, pleased am I. Now I repair to my own place?
1226	48	18	Having known her thus, Indra, O Rāma , exceedingly apprehensive of Gautama, then hurriedly sallied out of the thatched cottage.
1227	48	19	Just at this time, Indra saw that mighty ascetic Gautama entering, that foremost of anchorets, incapable of being repressed by the deities and the Dānavas , and equipped with ascetic energy, having based in the waters of holy spots, and flaming like fire, carrying faggots and Kuśa grass.
1228	48	20	And seeing him, the countenance of the lord of the celestials turned pale. And seeing the wicked thousand-eyed deity in the guise of an ascetic, the well-behaved anchorite fired with rage said.
1229	48	21	‘And since, O you of wicked understanding, assuming my form, you have done this foul-deed, you shall lose your scrotum.’
1230	48	22	And soon as the high-souled Gautama had said this in ire, the scrotum of the thousand-eyed one dropped to the earth.
1231	48	23	And having seen Śakra in this plight, he cursed his wife also, ‘These weary thousand years you shall pass, feeding upon air, without food, engaged in asceticism in the dust, and you shall remain in this hermitage unseen of any. And when the irrepressible son of Daśaratha, Rāma, shall come to this deep wood, you shall be cleansed of your sin. And, O wicked one, ministering to him the rites of hospitality with a mind free from ignorance and covetousness, you shall in your own form with joy regain my side.’
1232	48	24	Having said this the highly energetic Gautama of rigid austerities, forsaking this hermitage, began to carry on penances on the romantic summit of the Himavat , inhabited by Siddhas and Cāraṇas .
1233	49	1	And having been deprived of his scrotum, Śakra with eyes tremulous with fear, addressed the celestials with Agni at their head, as well as he Siddhas and the Gandharvas and the Cāraṇas , saying,
1234	49	2	I have accomplished the work of the celestials by stirring the ire of the high-souled Gautama , and thereby disturbing his austerities.
1235	49	3	And in doing so, I have been deprived of my scrotum; and Ahalyā also has been put down. And I have deprived him of his ascetic energy by causing him to utter a mighty curse.
1236	49	4	And, therefore, you celestials, and saints, and Cāraṇas, you should restore my scrotum to me who have served the gods.’
1237	49	5	Hearing Śatakratu ’s (performer of an hundred sacrifices, one of the appellations of Indra ). The manes of ancestors, words, the deities along with the Maruts led by Agni, presented themselves before the divine Pitṛs . And then Agni addressed the latter, saying.
1238	49	6	This ram is possessed of a scrotum; while Śakra has been deprived of his. Do you taking the scrotum of the ram furnish Śakra with it.
1239	49	7	And although deprived of the scrotum, the ram will be able to grant consummate satisfaction to you. And on those that will offer such a ram for your entertainment, you will bestow undying and profuse merit.’
1240	49	8	Hearing Agni’s speech, the assembled Pitṛs, rooting up the scrotum of the ram, joined it to the person of the thousand-eyed deity.
1241	49	9	Thence forth, O Kākutstha , the divine Pitṛs together feast upon scrotumless rams, for their scrotum had been joined to the person of Indra.
1242	49	10	Thenceforth, O Rāghava , Indra also through the high-souled Gautama’s ascetic energy, has been bearing the scrotum of a ram.
1243	49	11	Therefore, O highly powerful one, do you enter into the hermitage of that pious one, and deliver the dignified and divinely fair Ahalyā.
1244	49	12	On hearing Viśvāmitra ’s words, Rāghava in company with Lakṣmaṇa , placing Viśvāmitra in their front, entered the asylum.
1245	49	13	They beheld that magnificent dame flaming in ascetic energy; and incapable of being gazed at too near even by the celestials and the Asuras ; as if created by the Deity to be the divinely charming Woman; like a flame hid in smoke; or the brightness of the full moon clouded and dimmed in mist; or the solar splendour incapable of being beheld of account of clouds.
1246	49	14	And by virtue of Gautama’s word, she had been incapable of being seen by any in the three worlds, till the sight of Rāma . And now the curse having come to an end, she could be perceived by them.
1247	49	15	The two descendants of Raghu then took hold of her feet; but remembering Gautama’s words, she on her part took hold of theirs. And with a collected mind she gave them water for their feet as well as Arghya , and extended to them the rites of hospitality.
1248	49	16	And the Kākutstha accepted the homage thus rendered according to the ordinance. And blossoms began to shower copiously to the sounds of kettledrums; and the Gandharvas and the Apsaras began to rejoice greatly.
1249	49	17	And exclaiming, ‘Excellent, excellent,’ the celestials honoured Ahalyā, as with as person purified by penance, she again come under Gautama’s governance.
1250	49	18	And the highly energetic Gautama also happy on his union with Ahalyā, honoured Rāma highly, and that one of mighty mortifications then became engaged in austerities.
1251	49	19	And having duly received signal honours from the great ascetic Gautama, Rāma set out for Mithilā .
1252	50	1	Then proceeding north-east Rāma is company with Sumitrā ’s son, placing Viśvāmitra at their head, appeared before the sacrificial ground.
1253	50	2	And Rāma and Lakṣmaṇa said to that puissant ascetic, Great is the pomp and splendour of the high-souled Janaka ’s sacrifice. And, O pious one, many thousand of Brāhmaṇas inhabiting various regions, and well-read in the Vedas (have come to this sacrifice);
1254	50	3	And the abodes of ascetics are thronged with hundreds of cars. Do you, O Brāhmaṇa , arrange for some place were we may put up.
1255	50	4	Hearing Rāma’s words, the mighty ascetic Viśvāmitra selected for their abode a well-watered spot free from bustle and tumult.
1256	50	5	And hearing of Viśvāmitra’s arrival, the best of monarchs without blame, placing the priests Śatānanda before him, as well as the high-souled family priests, speedily taking the Arghya , at once went out in humble guise, and offered it to Viśvāmitra according to the ordinance.
1257	50	6	Having accepted that homage of the high-souled Janaka, the ascetic enquired after the king’s welfare, and the uninterrupted performance of his sacrifice. And the king together wiṃ his priests, having enquired of the ascetics as to their welfare, cheerfully embraced them all in a proper way.
1258	50	7	Then he with clasped hands, spoke to that foremost of anchorets, saying, O worshipful one, do you along with these eminent ascetics take your seat.
1259	50	8	Hearing Janaka’s words, the mighty ascetic sat him down. And the king also, in company with his priests and counsellors sat down around in order of rank.
1260	50	9	And then the monarch looking into Viśvāmitra’s face, said, To-day by the grace of the gods, has my sacrifice been crowned with success, to-day.
1261	50	10	Have I reaped the fruit of my sacrifice by beholding your worshipful self. Blessed and obliged am I whose sacrificial ground, O Brāhmaṇa, has been graced by you along with these ascetics.
1262	50	11	Twelve days, O Brahmarṣi , have been fixed for the period of initiation by the sages. On the expiry of that term, you will, O Kauśika , behold the celestials come to the sacrifice for claiming their respective shares.
1263	50	12	Having said this, the king with a cheerful countenance, with folded hands, again intently asked that foremost of ascetics.
1264	50	13	These youths, good betide you, like to celestials in prowess, of the gait of lions or elephants, heroic, and resembling tigers or bulls, of expansive eyes like to lotus-patals, bearing scimitars, quivers and bows, graceful like to the Aśvins , endowed with youth, resembling immortals fancy-led from heaven to the earth, whose sons, O ascetic, are they, and what for have they come, and why again have they come afoot? And bearing excellent arms, whose sons, O mighty anchorite, are these heroic ones, who grace this place even as the sun and the moon do the welkin, and resemble each other in bodily proportions, expression, and gestures; wearing side-locks and of warlike mien? This I would hear truly related.
1265	50	14	Hearing this speech of the high-souled Janaka, that ascetic of immeasurable soul related all about Daśaratha ’s sons.
1266	50	15	Their sojourn in Siddhāśrama , and the slaughter there of the Rākṣasas , their undaunted journey, the sight of Viśālā , the encounter with Ahalyā and Gautama , Rāma’s curiosity about the mighty bow, and visit there for beholding the same.
1267	50	16	Having related all this to the high-souled Janaka, that one endowed with exceeding energy, the mighty ascetic Viśvāmitra, paused.
1268	51	1	Hearing the narration of the intelligent Viśvāmitra , Gautama ’s eldest son, the exceedingly energetic Śatānanda of rigid austerities, highly effulgent by virtue of his asceticism, with his down standing on end wondered greatly at the sight of Rāma .
1269	51	2	And seeing the king’s sons seated at their ease, he said to that foremost of ascetics, Viśvāmitra.
1270	51	3	O most powerful of anchorets, by you was. my illustrious mother, grown old in asceticism, shown to the king’s son.
1271	51	4	Did my famous and exalted mother entertain with the produce of the woods this one worthy of every one’s homage?
1272	51	5	O highly energetic one, has that old story relative to my mother having been wronged by that celestial, been communicated to Rāma?
1273	51	6	O Kauśika good betide you, has my mother, in consequence of beholding Rāma, been united with my revered sire?
1274	51	7	And, O son of Kuśika , has the highly energetic Rāma come hither, after having been rendered homage by my high-souled revered sire?
1275	51	8	And, O Kuśika’s son, was my revered sire of quiescent soul, saluted by Rāma when he arrived there?
1276	51	9	Hearing those words of his, the mighty ascetic Viśvāmitra, skilled in speech, replied to Śatānanda, cognizant of words, saying.
1277	51	10	O best of ascetics, nothing necessary was omitted by me, but everything has been done. And the ascetic’s wife has been united with him, even as Renuka with Bhṛgu ’s son. ( Jamadagni , father of Paruśurāma).
1278	51	11	Hearing the speech of the intelligent Viśvāmitra, the exceedingly energetic Śatānanda said to Rāma.
1279	51	12	Art you well come, O chief of men? It is by our luck that, O descendant of Raghu , you have come to us, headed by the respected Maharṣi Viśvāmitra.
1280	51	13	This highly energetic. Viśvāmitra, this Brahmarṣi is of prowess measureless; and deeds inconceivable, by virtue of his asceticism. Him you know as the prime way.
1281	51	14	O Rāma, there exist of this earth not one that is more fortunate than thyself. Your protector is even Kuśika’s descendant, by whom mighty austerities have been performed.
1282	51	15	Do you listen as I faithfully describe to you the ascetic power of the high-souled Kauśika.
1283	51	16	Do you listen to me relating this. This righteous one was for a long time a king, subduing his enemies, cognizant of morality, accomplished, and intent upon the welfare of his subjects.
1284	51	17	And there was a king named Kuśa , the son of Prajāpati . And Kuśa’s son was the powerful and pious Kuśanābha .
1285	51	18	And Kuśanābha’s son was Gādhi . And Gādhi’s son is the highly energetic and mighty ascetic Viśvāmitra.
1286	51	19	And that king reigned for thousands of years.
1287	51	20	And it came to pass that once with his four fold forces marshalled, he set out for ranging the earth.
1288	51	21	The king went on by turns ranging cities and kingdoms, rivers and mountains and asylums. And at length that foremost of conquerors, the mighty Viśvāmitra, came upon Vasiṣṭha ’s asylum furnished with various blossoming plants and trees; abounding in animals; inhabited by Siddhas and Cāraṇas ; graced by celestials and Dānavas and Gandharvas and Kinnaras ; and filled with mild dear; frequented by the feathered tribes; crowded with Brahmarṣis ; with Devarṣis inhabiting it aye teeming with-souled ones of accomplished ascetic success and resembling fire; like an other region of Brahmā ; graceful; and adorned on all sides with high-souled saints and Valakhilyas and Vaikhanasas resembling Brahmā, feeding on water or air, or living on withered leaves, or subsisting on fruits and roots, and self-controlled, and free from faults, and of vanquished senses, and engaged in reciting mantras and performing homas .
1289	52	1	Upon seeing that foremost of these reciting mantras , the highly powerful and heroic Viśvāmitra , exceedingly delighted, bowed to him in humility.
1290	52	2	Having enquired as to the pleasantness of Viśvāmitra’s journey, the high-souled an adorable Vasiṣṭha ordered a seat for the former.
1291	52	3	And on the intelligent Viśvāmitra having been seated, that best of ascetics properly entertained him with fruits and roots.
1292	52	4	And having accepted Vasiṣṭha’s hospitality, that foremost of monarchs, the exceedingly energetic Viśvāmitra then enquired of Vasiṣṭha as to the welfare of his asceticism, his Agnihotras , and his disciples, and his trees. Thereupon Vasiṣṭha of fierce austerities communicated the welfare of all to that best of king, Viśvāmitra, seated at his ease.
1293	52	5	Then Brahmā ’s son, Vasiṣṭha, the best of those reciting mantras, asked Viśvāmitra, saying.
1294	52	6	O king, is it well with you? And, O king, do you rule your subjects pleasing them consistently with morality?
1295	52	7	O virtuous one, are your retainers maintained on salaries from the kingdom? Do they abode by your mandates? And, O destroyer of foes, hast you vanquished your enemies?
1296	52	8	And O repressor of foes, is it well with you as to, O most powerful of men, your forces; exchequer, and friends, and, O sinless one, sons and grandsons?’
1297	52	9	Thereupon the highly powerful king, Viśvāmitra, with humility communicated to Vasiṣṭha his complete welfare.
1298	52	10	Having conversed for a long time, those virtuous ones, experiencing exceeding joy, ministered to each other’s delight.
1299	52	11	Then, O descendant of Raghu , after the conversation had ended, the adorable Vasiṣṭha, smiling, addressed Viśvāmitra, saying.
1300	52	12	O highly powerful one, I desire to properly entertain you of immeasurable power, as well as your forces, do you, therefore, accept my hospitality.
1301	52	13	Do you receive the hospitality which I extend to you. O king, you are the foremost of guests, and art worthy of assiduous homage.’
1302	52	14	Being thus addressed by Vasiṣṭha, that mighty ascetic, king Viśvāmitra; said, ‘Even by this word of your relative to receiving me, hast you in fact done so.’
1303	52	15	And, O worshipful one, even with the fruits and roots that are in your asylum, with the water for washing my feet, and for sipping, you, with the sight of your revered self, have I been.
1304	52	16	O profoundly wise one, excellently entertained by you, who art yourself worthy of homage. I how to you. I will go now. Do you regard me with a friendly eye.’
1305	52	17	As the king was speaking thus, the righteous- souled and generous Vasiṣṭha again and again pressed him to accept his hospitality.
1306	52	18	Then Gādhi ’s son answered Vasiṣṭha, ‘Very well. O potent ascetic, let that be which find favour in your sight.’
1307	52	19	This having been said by him, Vasiṣṭha, the best of those reciting mantras, joyfully called his sacrificial dappled cow, capable of purging away sins.
1308	52	20	O Śabala ! do you come soon; and hear my words. I intend to entertain this royal saint together with his forces. Do you enable me to entertain him, by yielding excellent viands.
1309	52	21	And, O divine one, O you that confer everything that is desired, do you grant everyone whatever be ask among edibles impregnated with the six tastes.
1310	52	22	And do you, O Śabala, speedily create sapid viands to be chewed, sucked, licked, or drunk.
1311	53	1	Thus addressed by Vasiṣṭha , that bestower of all that was desired, Śabala , O destroyer of your foes, brought forth everything that was desired by everyone.
1312	53	2	And she produced sugarcanes, and honies, and fried rice, and excellent Maireyas , (A kind of wine prepared from molasses). A preparation of milk rice, and costly drinks, and various viands, and heaps of warm rice resembling hills, and other kinds of edibles, and soups, and Dadhikalyas , together with silver plates by thousands filled with meats of diverse tastes.
1313	53	3	And, O Rāma , the tarry of Viśvāmitra being superbly entertained by Vasiṣṭha, heartily filled, became exceedingly gratified.
1314	53	4	And the royal saint, Viśvāmitra himself, together with the priests and Brāhmaṇas and the inmates of the inner apartment, was also heartily filled.
1315	53	5	And being hospitably entertained with his courtiers and counsellors and retainers, he, exceedingly de-lighted, spoke to Vasiṣṭha, saying.
1316	53	6	Received and excellently entertained have I been by you, O Brāhmaṇa , who thyself art worthy of being honoured. Do you, O you conversant with speech, listen to me. I will tell you a word.
1317	53	7	Do you bestow on me Śabala for an hundred thousand kine. O worshipful one, verily this one is a jewel; and as it is the function of kings to acquire jewels, do you confer on me Śabala; for, O twice-born one, this one by right belongs to me.
1318	53	8	Thus addressed by Viśvāmitra, the righteous and adorable Vasiṣṭha best of ascetics, replied to that lord of earth.
1319	53	9	O king, neither for an hundred thousand nor for an hundred Koṭi of kine, nor yet for heaps of silver, will I part with Śabala. O subduer of enemies, this one deserves not to be separated from my side.
1320	53	10	Even like to the fame of the mighty, this Śabala is ever joined with me. my oblations to the gods and the Pitṛs as well as my subsistence itself are established even in her. And my Agnihotras , (Maintenance of the perpetual fire). bali , (Offering to the spirits of air) and Homa (Burnt offerings) depend upper her.
1321	53	11	And, O royal saint, my Svāhākāras and Vaṣaṭkāras [1] as well as my various lore depend upon her.
1322	53	12	All this is so: there is no doubt about it. Verily she is my all; and in her do I find my delight. And many are the reasons, O king, why I cannot give to you Śabala.’
1323	53	13	Thus addressed by Vasiṣṭha, that one versed in speech, Viśvāmitra, eagerly rejoined.
1324	53	14	I shall confer upon you fourteen thousand elephants decked in gold chains and gold neck-omaments and hooks.
1325	53	15	I will confer upon you eight hundred golden cars furnished with bells and reins, and each yoked with four white horses; and, O you of auspicious vows, I will confer upon you one thousand and ten high-mettled horses of noble breeds; and I will confer upon you a koṭi of youthful and variegated kine, do you grant to me Śabala.
1326	53	16	And as much of gems and gold, O best of regenerate ones, as you will ask for, shall I bestow upon you: do you grant me Śabala.’
1327	53	17	Thus besought by the intelligent Viśvāmitra, that adorable one replied, saying, ‘O king, Śabala I will not by any means give.’
1328	53	18	This is verily my jewel: this is verily my riches: this is verily my all: this is verily my subsistence. And this is my Darśa . [2] Gifts to Brāhmaṇas on occasions of sacrifice, and this my Paurṇamāsa , [3] and this my various sacrifices with dakṣiṇās ; and, O king, this my various rites.
1329	53	19	This, O king, is without doubt, the root of all my rites. And what need of dilating? This one bestowing everything that is desired will I not part with.
1330	53	20	[back to top]
1331	53	21	[1] :
1332	53	22	Sacrifice performed with the exclamation of svadhā and Vaṣaṭ respectively.
1333	53	23	[2] :
1334	53	24	Bi-monthly sacrifice, performed at change of the moon by persons maintaining a perpetual fire.
1335	53	25	[3] :
1336	53	26	A ceremony performed at the full moon by persons maintaining a perpetual fire.
1337	54	1	When the ascetic Vasiṣṭha would not part with the cow of plenty then Viśvāmitra , O Rāma , forced Śabala away.
1338	54	2	And, O Rāma, carried away by that high-souled king, Śabala, stricken with grief and afflicted with sorrow, bethought herself, weeping.
1339	54	3	Have I been forsaken by the high-souled Vasiṣṭha that the royal retainers carry me off thus aggrieved?
1340	54	4	What wrong have I done to that mighty ascetic of concentrated spirit, that, knowing me to be faultless, that righteous one leave her that was devoted to his service?’
1341	54	5	Revolving this in her mind and sighing again and again she darted to where the pre-eminently energetic Vasiṣṭha was; and cutting off those servants (of the king),
1342	54	6	She with the speed of the wind, appeared at the feet of that high-souled one. And weeping, she spoke in distressful accents.
1343	54	7	Brahma ’s son, wherefore have I been forsaken by you, that the servants of the king were carrying me from off your presence?
1344	54	8	Thus addressed the Brahmarṣi said these words to that one aggrieved, and of heart afflicted with sorrow, and like to a sister.
1345	54	9	O Śabala, not that I forsake you; nor hast you done me any wrong. But this mighty king proud of his prowess has been carrying you away.
1346	54	10	Surely, my strength is not equal to his. More specially, he is a king, a powerful king, more particularly, this day he should not be slain by me (inasmuch as he is my guest): he is a Kṣ atriya and lord of earth.
1347	54	11	And he is foremost in might by virtue of possessing this entire Akṣohiṇī abounding in elephants and horses and cars and standards.’
1348	54	12	Thus addressed by Vasiṣṭha, that one cognizant of words humbly said in reply to that Brahmarṣi of incomparable power.
1349	54	13	The might of the Kṣatriyas is not great, the Brāhmaṇas are more mighty than they. O Brāhmaṇa , super-human is the power of the Brāhmaṇas, excelling that of the Kṣatriyas.
1350	54	14	Your power is immeasurable; and the exceedingly energetic Viśvāmitra is not more powerful than thyself. Your energy is unequalled.
1351	54	15	O highly energetic one, do you command me bursting with Brahmā forces: the pride, power and endeavours of that wicked one will I bring down.
1352	54	16	Thus accosted by her, the highly famous Vasiṣṭha, O Rāma, said, ‘Create you forces capable of crushing the forces of the enemy?
1353	54	17	Hearing those words of his, Surabhi created (an army). And, O king, Pahlavas by hundreds brought into being by her lowing, begin even in Viśvāmitra’s sight to commit havoc upon his forces. Thereat, exceedingly angered, with eyes expanded in ire, that king commenced to slay the Pahlavas with various weapons. And beholding the Pahlavas by hundreds afflicted by Viśvāmitra, she again created grim-visaged Śakas mixed with Yavanas . And the field became thronged with the Śakas mixed with Yavanas, of dazzling splendour, exceedingly fierce, resembling golden filaments, bearing sharp scimitars and adzes, and clad in yellow apparel. And that entire host (of Viśvāmitra) was being consumed by them like to flaming fires. Then the exceedingly powerful Viśvāmitra hurled weapons at them; and with these the Yavanas, Kambojas and Barbaras (Barbarians) became sore afflicted.’
1354	55	1	And beholding them sore harassed, and overwhelmed by Viśvāmitra ’s weapons, Vasiṣṭha directed ( Śabala ) saying, ‘O cow of plenty, do you create (fresh troops), through your Yoga power.’
1355	55	2	And from her roar, there came into being Kāmbojas , resembling the Sun. And from her udders sprang Barbaras , arms in hand; and from her mysterious parts, Yavanas ; from her anus, Śakas ; and from the pores of her skin, those barbarians, Hārītas and Kirātas .
1356	55	3	And, O descendant of Raghu , anon Viśvāmitra’s entire host consisting of foot, and elephant, and horse, and car, was exterminated by them.
1357	55	4	Seeing the army annihilated by the high-souled Vasiṣṭha, the hundred sons of Viśvāmitra, equipped with various weapons, rushed in high ire against that best of mantra -reciting ones. Thereupon, uttering a roar, that mighty ascetic consumed them quite.
1358	55	5	In a moment, Viśvāmitra’s sons together with horse and car and foot were reduced to ashes by the high-souled Vasiṣṭha.
1359	55	6	And witnessing them all destroyed, together with the army, the illustrious Viśvāmitra, covered with shame, became plunged in thought.
1360	55	7	And like to a tideless ocean or a fangless snake, he instantly became shorn of his effulgence, like to the sun overwhelmed by Rāhu . [1]
1361	55	8	And deprived of his forces and sons, he appeared like a bird bereft of its wings; and losing his entire army and with it the high spirits that it had inspired him with, his heart died within him.
1362	55	9	Then entrusting one of his (remaining) sons with the sovereignty, with, ‘Do you rule the earth agree ably to the duties of the Kṣatriya ,’ he went into the forest.
1363	55	10	And repairing to the side of the Himavat inhabited by Kinnaras and Serpents that one of mighty asceticism began to perform austerities with the view of propitiating Mahādeva .
1364	55	11	On a certain occasion the lord of the celestials, Vṛṣadhvaja , [2] intending to confer a boon, appeared before a mighty ascetic Viśvāmitra.
1365	55	12	What for, O king, art you performing penance? Do you unfold what you-have to say. I am for conferring a boon: do you express what boon you would obtain.
1366	55	13	Thus addressed by that god, that performer of mighty austerities, Viśvāmitra, bowing down to him, addressed him, saying.
1367	55	14	If, O mighty god, you are pleased (with me), do you confer upon me the science of archery with all its mysteries and mantras , as well as its virtues of helping from far and near.
1368	55	15	O sinless one, may all those weapons that are with the celestials and the Dānavas and the Maharṣis and the Gandharvas and the Yakṣas and the Rākṣasa , shine on me! May this my desire be granted me through your grace, O god of gods!
1369	55	16	Thereupon, saying, ‘Be it so’ the lord of the celestials vanished. And obtaining the arms from the lord of the celestials, the mighty Viśvāmitra, naturally haughty, became swelled with insolence.
1370	55	17	surcharged with energy, like to the sea during the equinox, he considered, O Rāma , as if that foremost of saints, Vasiṣṭha, was already slain.
1371	55	18	And repairing to Vasiṣṭha’s asylum, the king began to discharge weapons; and by their energy the hermitage began to bum.
1372	55	19	Beholding those weapons discharged by the intelligent Viśvāmitra, the ascetics, overtaken by fear, by hundreds began to fly.
1373	55	20	Vasiṣṭha’s disciples as well as the aniṃals and birds inhabiting there, fled in all direction by thousands.
1374	55	21	For a time the hermitage of the high souled Vasiṣṭha was bare of living beings, and still like to a wilderness.
1375	55	22	And Vasiṣṭha cried momentarily, ‘Do not fear. To day will I slay Gādhi ’s son, even as the sun (destroys) mist.’
1376	55	23	Having said this, that best of mantra reciting ones, Vasiṣṭha, in high wrath, addressed Viśvāmitra, saying.
1377	55	24	Since, O fool, you have destroyed this hermitage that had been prospering for a long time, you of execrable ways shall not live long.
1378	55	25	Saying this, he, transported with wrath, and like to the smoking flame at universal dissolution, speedily upraised a staff resembling another mace of Yama itself?
1379	55	26	[back to top]
1380	55	27	[1] :
1381	55	28	A Daitya with the tail of a dragon, whose head was served from his body by Viṣṇu ; but being immortal, the head and tail retained their separate existence, and being transferred to the stellar sphere, became the author of eclipses.
1382	55	29	[2] :
1383	55	30	An appellation of Śiva : meaning who has the bull for his vehicle.
1384	56	1	Thus addressed by Vasiṣṭha , the mighty Viśvāmitra , aiming a fiery weapon, said, ‘Stay! Stay!’
1385	56	2	The worshipful Vasiṣṭha also on his part, raising a Brahmā staff resembling another staff of Kāla , exclaimed in wrath.
1386	56	3	Wretch of a Kṣatriya ! here am I, do you display the might you are master of. To-day, O Gādhi ’s son, will I humble your pride of arms.
1387	56	4	You disgrace of the race, where is your Kṣatriya might, and where my high Brahmā energy? Do you behold my superhuman Brahmā energy.
1388	56	5	And even as water ally the fierceness of a flame, the Brahmā staff quenched the energy of the powerful fiery weapon discharged by Gādhi’s Son.
1389	56	6	Then Gādhi’s son, waxing wroth, discharged Vāruṇa and Raudra and Aindra and Pāśupata and Aiṣika weapons.
1390	56	7	Mānava , and Mohana , and Gandharva , and Svapna , and Jṛmbhaṇa , and Mohana, and Santāpana , and Vilāpana , and Śoṣaṇa , and Dāruṇa , and Vajra hard to baffle, and Brahmapāśa, and Kālapāśa, and Varuṇapāśa, and Pināka (favourite of Śiva ), and the two Aśanis , wet and dry, and the Daṇḍa weapon, and Paiśāca , and the Krauñca weapon, and Dharmacakra , and Kālacakra , and Viṣṇucakra , and Vāyavya , and Mohana, and the Hayaśiras weapon, and the mighty weapon Vidyādhara , and the terrible Kala weapon, and the dreadful Triśūla weapon, and Kapāla , and Kaṅkaṇa , all these weapons hurled he (Viśvāmitra), at that best of mantra -reciting ones, O descendant of Raghu . And it was wonderful to behold. But Brahma ’s son baffled all those by means of his staff.
1391	56	8	And on those (weapons) being resisted, the son of Gadhi hurled a Brahmā weapon. And on that weapon being discharged the deities with Agni at their head, and the Devarṣis , and the Gandharvas , and the mighty Serpents, became afflicted with fear. And on that Brahmā weapon being discharged, all the three worlds became exceedingly alarmed.
1392	56	9	O Raghu’s descendant, Vasiṣṭha by virtue of his Brahmā energy completely baffled that terrible Brahmā weapon.
1393	56	10	When the high-souled Vasiṣṭha had baffled the Brahmā weapon, his form the three worlds.
1394	56	11	And from the pores of his body, resembling a smoking flame, darted out scintillation’s of fire.
1395	56	12	And resembling another staff of Yama , the Brahmā staff raised by Vasiṣṭha’s arm flamed like to the fire at the universal dissolution.
1396	56	13	Then the ascetics in a body fell to eulogizing that best of mantra-reciting ones, Vasiṣṭha, saying, ‘Your might, O Brāhmaṇa , is infallible. Do you rein in the (Brahmā) energy, by your own.’
1397	56	14	O Brāhmaṇa, Viśvāmitra of mighty strength has been subdued by you. Infallible is your extraordinary mighty. Let the creatures now be relieved from their distress.’
1399	56	16	And Viśvāmitra, being put down, heaving a sigh said, ‘Fie upon the Kṣatriya might: the strength begot of Brahma energy, is might indeed. By one Brahmā staff has all my weapons been put to the rout.
1400	56	17	Beholding this, I with a. placid mind and senses will engage in mighty austerities, which shall earn for me Brāhmaṇa-hood.
1401	57	1	Then with his heart burning, in consequence of the remembrance of his humiliation, and having made enemies with that high-souled one, Viśvāmitra of mighty asceticism sighing and sighing, went towards the south, in company with his queen, and became engaged in dreadful austerities.
1402	57	2	O Rāghava . And subsisting on fruits and roots, and restraining his senses, he performed the most rigid austerities. And four sons engaged in observing truth and duty, Haviṣpanda, Madhuṣpanda, Dhṛḍhanetra, and Mahāratha , were born to him.
1403	57	3	And when a thousand years had been completed, the Grand-sire of all, Brahmā , addressed the ascetic, Viśvāmitra in sweet words, saying, ‘O son of Kuśika , the regions of the Rājarṣis have been won by you through your austerities. And on account of this your asceticism, we recognise you as a Rājarṣi .’
1404	57	4	Having said this, the highly energetic prime Lord of all creatures went to the celestial regions in company with the celestials.
1405	57	5	Hearing this, Viśvāmitra hanging down his head from shame and possessed by a mighty sorrow, said, in piteous accents, T have performed rigid austerities, yet the deities and the saints recognise me only as a Rājarṣi. I do not consider the fruit of my asceticism as gained.’
1406	57	6	Ascertaining this in his mind, that righteous one of high austerities, O Kākutstha , again engaged in penances with a composed self.
1407	57	7	O Rāghava, it came to pass that at this time, that enhance of Ikṣvāku ’s line, the celebrated and truthful Triśaṅku of subdued senses made up his mind, saying, ‘I will perform a sacrifice, and in body win the prime way of the celestials.’
1408	57	8	And summoning Vasiṣṭha , he unfolded his mind to him. And on the high-souled Vasiṣṭha saying, ‘I am incapable of doing this,’
1409	57	9	And disregarded by the latter, the King went towards the southern quarter. And with the view of securing success to his endeavours, the king repaired to where Vasiṣṭha’s sons had for a long time been performing austerities.
1410	57	10	And the highly energetic Triśaṅku saw the hundred exceedingly effulgent sons of Vasiṣṭha engaged in austerities with fixed faculties. And approaching all those high-souled sons of his spiritual guide, and paying them reverence he, hanging down his head from shame, with clasped hands, addressed those mighty spirits, saying.
1411	57	11	I seek protection of you; and I take refuge in you capable of conferring it. Disregarded have I been, good betide you, by the high-souled Vasiṣṭha. I have set my heart upon celebrating a mighty sacrifice: it behove you to command me.
1412	57	12	And with the view of propitiating you, I, lowly bowing down my head, beseech the sons of my spiritual guide, Brāhmaṇas ever staying by asceticism, do you with collected minds officiate in this sacrifice, so that success may be secured to me; and that in body I may attain the regions of the celestials.
1413	57	13	Disregarded by the ascetic Vasiṣṭha, other way find I none, you anchorets, except the sons of my spiritual guide.
1414	57	14	To the Ikṣvākus , their preceptor is their prime way. Therefore after him (Vasiṣṭha), even you are the objects of my adoration.
1415	58	1	Hearing Triśaṅku ’s speech, the hundred sons of the saint, O Rāma , excited by wrath, said these words to the king, ‘Disregarded hast you been, O you of perverse understanding, by our truth-telling sire, why then, having passed him by, do you seek for others’ help?
1416	58	2	To the Ikṣvākus , their spiritual guide is their prime way; nor art you capable of setting at naught the words of that truth-telling one.
1417	58	3	That worshipful saint said, that he was incapable (of accomplishing this), how can we then undertake that sacrifice?
1418	58	4	You are ignorant, O foremost of men. Do you speedily retrace your steps. And, O king, that adorable one is competent to officiate at the sacrifice itself of the three worlds, how can we then contribute to his dishonour?’
1419	58	5	Hearing those words of theirs, that king, with accents tremulous with passion, again addressed them, saying, ‘Disregarded by that worshipful one as well as by the sons of my spiritual guide, I will go after another way, so peace he to you, ascetics.’
1420	58	6	The saint’s sons, on their part, hearing that speech couching a fierce intent, cursed him in exceeding wrath, saying, ‘You shall come by Caṇḍāla -hood.’ Having said this, those high-souled ones entered each into his dwelling.’
1421	58	7	And when the night had gone by the king came by Chandala -hood. And clad in a blue garb, blue and rough of person, having a short head of hair, wearing a garland composed of materials culled from a cemetery, his body bedaubed with ashes from the same quarter, he was decked out with iron ornaments.
1422	58	8	And, O Rāma, beholding him in the guise of a Chandala, his counsellors as well as followers, renouncing him, fled in a body. And, O Kākutstha , maintaining himself in patience, the monarch burning day and night, all alone went to the ascetic Viśvāmitra .
1423	58	9	And beholding to disappointed king in the guise of a Chandala, the ascetic, O Rāma, was touched with pity. And from commiseration, that pre-eminently pious and exceedingly energetic one said to that king frightful to behold, saying, ‘Good betide you, O heroic lord of Ayodhyā , you have fallen into Chandala-hood through a curse, what is the purpose of your coming, O highly powerful prince?’
1424	58	10	Hearing him, the king conversant with words, fallen into Caṇḍāla-hood, with folded hands, said to that one versed in speech.
1425	58	11	Disregarded had I been by my spiritual guide as well as his sons. And far from attaining my desire, I came by this calamity.
1426	58	12	O you of placid presence, I had desired to repair to heaven in body. By me have an hundred sacrifices been performed, but yet do I not obtain the fruit thereof.
1427	58	13	I have never before told an untruth; and I swear by my Kṣatriya morality, that albeit fallen on evil days, I will never do so in future, O gentle one.
1428	58	14	I have celebrated many sacrifices, and I have ruled my people in righteousness; and I have pleased my preceptors by my character and conduct. But, O best of ascetics, now endeavouring to do my duty and intending to perform a sacrifice, I have failed in enlisting the good graces of my spiritual guides. Therefore do I consider Destiny as supreme; and action as nothing.
1429	58	15	Density overtake all: Destiny is the prime way. Therefore it behove you to grant your favour to me extremely distressed, who crave your favour, and, good betide you, whole endeavours have been baffled by Density.
1430	58	16	Other way will I wend none; nor is there any other refuge for me. It behove you to meet Density with exertion.
1431	59	1	When the king had spoken thus, Kauśika ’s son, moved with pity, said these sweet words to the king who had undergone Caṇḍāla -hood.
1432	59	2	O descendant of Ikṣvāku , have you had a pleasant journey? I know you well, O highly virtuous one. Refuge will I grant you, so fear not, O best of monarchs.
1433	59	3	I shall summon all the pious Maharṣis , who shall assist at the sacrifice. O king, and then you will be able to accomplish your purpose easily. And should the guise you have come by in virtue of your preceptor’s curse, cling to you yet, you will bodily repair to heaven in this form. And since appearing before Kuśika ’s son, you have taken his refuge, I consider heaven, O lord of men, as if within they grasp.
1434	59	4	Having said this, that exceedingly energetic one ordered his highly virtuous and profoundly wise sons to provide the sacrificial necessaries.
1435	59	5	Summoning his disciples, he said, ‘Do you by my command bring hither all the saints together with Vasiṣṭha ’s sons; and our friends and their disciples an the family priests variously versed in lore.’
1436	59	6	Should any summoned by my mandate, say aught, ‘do you fully represent to me the expression of slight.’
1437	59	7	Hearing this speech, they set out in different directions; and Brahmavādis [1] began to pour in from various countries. And the disciples (of Viśvāmitra ) returning, fully communicated to that ascetic of flaming energy the words of the Brahmavādis, saying.
1438	59	8	Hearing your message, the regenerate ones resident in every part will come here, and some have already arrived, all save Mahodaya and the hundred sons of Vasiṣṭha.
1439	59	9	Do you, O foremost of ascetics, listen to the words that they said with accents tremulous with emotion.
1440	59	10	How can celestials and saints partake of offerings in the court of him that in addition to being a Chandala , has for this priest a Kṣatriya ? And how can high-souled Brāhmaṇas , patronised by Viśvāmitra, attain to heaven, having partaken of a Candāla’s fare?
1441	59	11	These cruel words, O powerful ascetic, did Vasiṣṭha’s sons together with Mahodaya, utter with reddened eyes.’
1442	59	12	Hearing those words of theirs, that foremost of ascetics, with eyes reddened in anger, wrathfully cried.
1443	59	13	Since blameless as I am, those wicked-minded ones censure me practising fierce austerities, they shall, without doubt, be reduced to ashes.
1444	59	14	And this very day bound by the noose of Kala , meeting with destruction at the hands of Vivaśvata’s son, ( Yama ) they shall for seven hundred firths range these worlds, wearing dead men’s clothes, always feeding on dogs’ flesh, going by the name of Mahodaya also has blamed me, although undeserving of blame; therefore, reproved of all, he shall undergo Niṣādahood. And becoming cruel, and engaged in taking life, he shall through my ire fare wretchedly for a long lapse of time?
1445	59	15	Having uttered this in the assembly of saints, that mighty ascetic, the highly powerful Viśvāmitra of fierce asceticism, paused.
1446	59	16	[back to top]
1447	59	17	[1] :
1448	59	18	A Brahmavādi is one who maintains that all things are Spirit.
1449	60	1	And knowing (by virtue of his Yoga power) Vasiṣṭha ’s sons together with Mahodaya as destroyed in consequence of his ascetic energy, the highly powerful Viśvāmitra said in the midst of the saints.
1450	60	2	This descendant of Ikṣvāku , the famous Triśaṅku , is virṃous and munificent, and has taken refuge in me, with the view of attaining the celestial regions in his own person. Therefore do you engage with me in the sacrifice, so that he may bodily repair to heaven.
1451	60	3	Hearing Viśvāmitra’s words, the pious Maharṣis readily spoke in harmony with duty, saying, ‘This descendant of Kuśika is a highly irascible ascetic, therefore what he said should, without doubt, he performed.’
1452	60	4	The worshipful one is like to fire, and, if angered, may curse us. Therefore, let us engage in this sacrifice, so that Ikṣvāku’s descendant through the potency of Viśvāmitra way repair to heaven in person.
1453	60	5	Then let us engage in this sacrifice. Saying this, the sages entered upon the ceremony.
1454	60	6	And in that sacrifice the highly energetic Viśvāmitra acted as the priest. And Ritwijas versed in mantras performed every thing in order with mantras, in accordance with scripture and prescription.
1455	60	7	Then after a long time, Viśvāmitra of mighty austerities invoked thither all the celestials for receiving their respective shares; but the deities did not come to receive them.
1456	60	8	Thereupon, getting into a wrath, the mighty ascetic Viśvāmitra, lifting up a garland, wrathfully exclaimed.
1457	60	9	O lord of men, do you witness the prowess of my self-earned asceticism. And, O king, do you in person repair to heaven hard to attain.
1458	60	10	Something yet remains in me of the self-earned fruit of my asceticism; and, O king, through the energy of that asceticism, do you repair to heaven in person.
1459	60	11	And on the ascetic saying this, O Kākutstha , that lord of men, bodily ascended heaven in the very sight of the anchorets.
1460	60	12	And beholding Triśaṅku risen to heaven, the subduer of Indra , together with all the celestial said.
1461	60	13	Triśaṅku, turn you back. You have not earned abode in heaven. O fool, you have been blighted by the curse of your spiritual guide. Do you therefore drop down headlong.
1462	60	14	The great Indra having spoken thus, Triśaṅku fell down, crying to the ascetic Viśvāmitra, ‘Save me, save me.’
1463	60	15	Thereupon, hearing his distressful cries, Kauśika waxed mightily wroth, and exclaimed, ‘Stay, stay.’
1464	60	16	In the midst of the ascetics, like to another Prajāpati , he created other seven Ṛṣis [1] on the Southern way: and also, overwhelmed with wrath created another set of stars.
1465	60	17	And collied [2] with passion, that illustrious one in the midst of the ascetics created another system of stars in the southern direction. And, saying, ‘I will create another Indra, or the world (that I create) shall be without an Indra.’ And in anger, he went the length of creating celestials.
1466	60	18	Thereupon, in trepidation, the saints and the celestials and the Asuras humbly addressed the high souled Viśvāmitra thus.
1467	60	19	‘This king, O highly exalted one, has been visited with the curse of his preceptor, therefore, O ascetic, he deserves not to ascend heaven in person.
1468	60	20	Hearing those words of theirs, that best of anchorets, Kauśika, in company with the celestials, said these pregnant words.
1469	60	21	Good betide you, I have vowed to this king, Triśaṅku’s bodily ascension unto heaven, therefore, I dare not falsify my vow.
1470	60	22	Let Triśaṅku evermore dwell in heaven in person, and let these stars created by me verily endure as long as the worlds. This it behove you, you gods, to ordain.
1471	60	23	Thus addressed, the deities answered that best of ascetics saying, ‘So be it, good betide you! All these innumerable stars, O foremost of anchorets, shall remain in the firmament outside the path of Vaiśvānara ( Zodiac ); and shining in their splendour, Triśaṅku shall dwell with bended head, like to an immortal. And all these luminous bodies shall follow that best of kings, illustrious and successful, as if he had attained heaven itself.’ And the virtuous and exceedingly energetic Viśvāmitra, thus assured by the celestials, said in the midst of the saints, ‘You gods, excellent well.’
1472	60	24	Then, after the sacrifice had concluded, the high-souled celestials and the saints of ascetic wealth went to their respective regions, O foremost of men.
1473	60	25	[back to top]
1474	60	26	[1] :
1475	60	27	Ursa major (?The Zodiac?)
1476	60	28	[2] :
1477	60	29	And passion having my best judgement callied.
1478	61	1	And, O puissant one, seeing those saints gone, the highly energetic Viśvāmitra addressed those inhabitants of the forest.
1479	61	2	A mighty disturbance has happened in regard to the southern quarter: let us therefore repairing to another region, carry on austerities.
1480	61	3	You high-souled ones, in the west there are extensive tracts; and there in Puṣkara will we peaceably carry on our austerities. That asylum is really pleasant.
1481	61	4	Having said this, that exceedingly energetic and mighty Muni (Ascetic) began to perform terrible austerities, subsisting on fruits and roots.
1482	61	5	And it came to pass that at this time that mighty lord of Ayodhyā , Ambarīṣa , prepared for celebrating a sacrifice.
1483	61	6	And as he was sacrificing, Indra stole away his sacrificial beast. And on the beast being stolen, the priest said unto the king.
1484	61	7	O king, the beast has been stolen (away); and it has been lost through your dereliction. And, O lord of men, his own fault destroy the king that fail to protect (the beast).
1485	61	8	O best of men, even this is the expiation: do you, while the ceremony lasts, speedily bring back the beast, or bring a man in its stead.
1486	61	9	Hearing the priest’s words, that highly intelligent king began to range various countries and provinces, cities, forests, and holy asylums, searching for the beast, with a thousand king (as the price thereof.)
1487	61	10	And, O child, it came to pass that arriving at Bhṛgutuṅga , (A mountain peak) he beheld Ṛcīka seated there in company with his wife and sons.
1488	61	11	O descendant of Raghu . And bowing to that Brahmarṣi flaming in asceticism, and propitiating him, the exceedingly energetic royal saint of unparalleled effulgence having enquired as to his complete welfare, addressed Ṛcīka, saying, ‘0 highly pious one, O Bhṛgu ’s son, if in order that I may have a substitute for my sacrificial beast, you sell your son, my desire I shall atain.’
1489	61	12	I have ranged every country; but the beast I do not find. Therefore, it behove you to part with one of your sons for price.’
1490	61	13	Thus addressed the exceedingly energetic Ṛcīka replied, ‘O best of men, my first-born I will in no wise dispose of.’
1491	61	14	Hearing the words of the high-souled Ṛcīka, their mother spoke to that foremost of men, Ambarīṣa, saying,
1492	61	15	The worshipful son of Bhṛgu has said that his first-born cannot be disposed of—do you, O lord, also know that the youngest, Śunaka , is my favourite. Therefore my youngest son will I not give to you.
1493	61	16	O foremost of men, the eldest sons are generally the best beloved of their fathers; and the youngest, of their mother, therefore the youngest I would retain.
1494	61	17	And when the ascetic as well as his wife had spoken thus, the second son, Śunaḥsepa, O Rāma , himself said.
1495	61	18	My father would not sell the eldest; nor my mother the youngest,—therefore, I consider even the second as disposable. Do you then, O prince, take me.
1496	61	19	When that one versed in the Veda had ended, that lord of men, O mighty-armed descendant of Raghu, taking possession of Śunaḥsepa, by paying koṭis of kine, and heaps of jewels, and gold and silver by hundreds and thousands, went away exceedingly delighted.
1497	61	20	That royal saint, the exceedingly energetic and highly famous Ambarīṣa, placing Śunaḥsepa on his car, speedily set out.
1498	62	1	O foremost of men, taking Śunaḥsepa, that illustrious king at noon rested in Puṣkara , O descendant of Raghu .
1499	62	2	And having arrived at the excellent Puṣkara, as the king was resting, the famous Śunaḥsepa with an aggrieved heart saw his maternal uncle Viśvāmitra in company with some saints engaged in asceticism. Thereupon, with a woebegone countenance, and sore afflicted with fatigue and thirst, he, O Rāma , flung himself into (Viśvāmitra’s) lap, and said.
1500	62	3	I have neither father, nor mother, nor relatives, nor friends anywhere. It therefore behoves you, O gentle one, to save me in the interests of virtue, O foremost of ascetics.
1501	62	4	And, O best of men, you are the protector of all, and their refuge. May the king have his desire and may I at the same time, attaining long life, and undeteriorating, gain heaven, having performed meritorious austerities!
1502	62	5	Do you with a delighted heart become a lord to me that am without one. And, O righteous one, even as a father rescue a son, do you deliver me from this peril.
1503	62	6	Hearing his words, Viśvāmitra of mighty austerities, pacifying him by every means, spoke to this sons, saying,
1504	62	7	That in view of which fathers beget well-wishing sons, the compassing of other's welfare is at hand.
1505	62	8	This youthful son. of the ascetic crave my protection. O you sons, do accomplish my desire by saving his life.
1506	62	9	You are all of virtuous deeds, you are all engaged in the observance of righteousness, do you confer satisfaction upon Agni by one of you becoming the (sacrificial) beast of the lord of men.
1507	62	10	Thus Śunaḥsepa will obtain protection, the sacrifice will be freed from hindrance the deities will be propitiated, and finally my word will be made good.
1508	62	11	Hearing the ascetic’s words, his sons, Madhucchanda and others, O foremost of me, haughtily and tauntingly answered.
1509	62	12	O lord, how, neglecting your own sons, you desire to deliver that of another? This we consider as heinous, even like to eating one’s own flesh.
1510	62	13	Hearing this speech of his sons, that best of anchorets, with eyes reddened with anger, said.
1511	62	14	Disregarding my words, you have uttered this audacious and shocking speech, disclaimed by morality, and capable of causing one’s hair to stand on end. Therefore, becoming Muṣṭikas , and living on dogs’ flesh, do you ah, even like Vasiṣṭha ’s sons, inhabit the earth for a thousand years.
1512	62	15	Having cursed his sons, that best of ascetics then, by all means cheering up the distressed Śunaḥsepa as to his protection, addressed him.
1513	62	16	Do you donning on a sacred zone, and wearing a garland of red flowers, and bedaubing your person with red sand paste, hymn Agni with mantras , approaching the Vaiṣṇava sacrificial stake; and, O ascetic’s son, (at the same time) chant these two verses in that sacrifice of Ambarīṣa . Then you will attain success.
1514	62	17	Thereupon, with a concentrated mind securing those two verses, Śunaḥsepa speedily presented himself before that leonine monarch saying,
1515	62	18	O lion of a king, O you endued with high intelligence, let us without delay repair hence. And, O foremost of monarchs, do you engage in the sacrifice and commence upon the initiation.
1516	62	19	Hearing those words of the ascetic’s son, the king, filled with delight, readily at once repaired to the sacrificial ground.
1517	62	20	With the consent of his court, the king fastened Śunaḥsepa with a Kuśa cord, and investing him with a crimson apparel tethered him to the stake as the (sacrificial) beast.
1518	62	21	Being bound (to the stake), the ascetic’s son first of all duly hymned Agni, and next those deities, Indra and his younger brother.
1519	62	22	Thereupon, gratified with the excellent eulogy, the thousand eyed Vāsava conferred upon Śunaḥsepa long life.
1520	62	23	And, O foremost of men, that king also, having completed the sacrifice, obtained the manifold fruit thereof through the grace of the thousand-eyed deity,
1521	62	24	O Rāma, And, O best of men, the righteous Viśvāmitra of mighty asceticism again carried on austerities at Puṣkara for ten hundred years.
1522	63	1	When the thousand years had been completed and the mighty ascetic had accomplished his vow, the celestials in a body desirous of conferring upon him the fruit thereof, appeared before him.
1523	63	2	The exceedingly effulgent Brahmā addressed him in soothing words, saying, ‘You are henceforth a saint, good to you,—and (this eminence) you have attained through your own laudable exertions.’
1524	63	3	Having spoken thus to him, the lord of celestials returned to heaven. And Viśvāmitra of mighty energy became again engaged in rigid austerities.
1525	63	4	And, O foremost of men, it came to pass that after a long lapse of time that prime of Apsaras , Menaka , was at that time perfonning her ablutions in Puṣkara , and she was observed by Kuśika ’s son like to lighting among clouds. And coming under the control of Kandarpa , (Cupid) the anchorite spoke to her, saying, ‘O Apsari, has your journey been a pleasant one? Do you abide in my asylum.’
1526	63	5	Do you favour me; for, good betide you, I have been rendered senseless by Madana . Thus addressed, that one of shapely hips began to dwell there.
1527	63	6	And mighty was the hindrance that befell Viśvāmitra as regarded his asceticism, as she, O Rāghava , staying in that asylum of his, pleasantly spent five and five years, O gentle one.
1528	63	7	And after this period had gone by, overwhelmed with shame and afflicted with anxiety and grief, the mighty ascetic Viśvāmitra impatiently thought,
1529	63	8	O son of Raghu , that all this mighty loss of austerities was the work of the celestials.
1530	63	9	And deprived of his senses by lust, the decade had passed away imperceptibly as if it were one day and night; and this impediment stood in the way of his austerities.
1531	63	10	Having a sigh, that best of ascetics burned in repentance. And with sweet words renouncing the terrified and trembling Menaka standing with clasped hands, Kuśika’s son, Viśvāmitra, O Rāma , went to the northern mountains.
1532	63	11	And practising the Brahmacarya mode of life with the intention of subduing lust, that highly famous one engaged in arduous austerities on the banks of the Kauśiki.
1533	63	12	And as he was thus engaged in profound austerities on the northern mountain, a thousand years, O Rāma passed away.
1534	63	13	Then taking counsel together, the celestials and the saints appeared before (Brahmā), saying, ‘Let Kuśika’s son obtain the title of Maharṣi .’
1535	63	14	Hearing the words of the celestials, the Grand sire of all addressed the ascetic Viśvāmitra, in these sweet words, ‘O mighty saint, hast you had a pleasant journey? Satisfied with your fierce austerities, O Kauśika , I confer upon you the eminence of the foremost saintship.’
1536	63	15	Hearing Brahma ’s speech, the anchorite Viśvāmitra bowing down thus answered the Grandsire with clasped hands, ‘The incomparable title of Brahmarṣi is to be won by one by performing sterling works. And since you have not addressed me (by that title), it appears that I have not yet succeeded in subduing my senses.’ [1]
1537	63	16	Thereupon Brahmā said to him, ‘Do you exert thyself until you conquer your senses?’ Saying this, Brahmā went to heaven.
1538	63	17	And when the celestials had gone, the mighty ascetic, Viśvāmitra, with upraised arms, and without any support, and subsisting on air, began to perform penances.
1539	63	18	And in summer, the ascetic surrounded himself with five fires, and in rains remained in an uncovered place, and in winter day and night stood submerged in water. Thus passed by a thousand years of terrible penances.
1540	63	19	And on the mighty ascetic Viśvāmitra being engaged in austerities, great was the agitation that exercised the celestials and Indra , in particular.
1541	63	20	Śakra together with the Maruts spoke to Rambhā these words, fraught with weal to himself, and woe to Kauśika.’
1542	63	21	[back to top]
1543	63	22	[1] :
1544	63	23	The text is very faulty. The literal meaning would be, since you have not...... I have subdued my senses, which would be absurd. I have therefore rendered the passage freely.
1545	64	1	O Rambhā , this mighty service you will have to perform in the interest of the celestials, even to lake Kauśika with the witchery of love.’
1546	64	2	Thus addressed by the intelligent thousand-eyed deity, the Apsarā , O Rāma , with clasped palms, thus bashfully answered the chief of the celestials,
1547	64	3	O lord of the celestials, this mighty ascetic, Viśvāmitra , is a terrible person; and, without doubt, he will, O divine one, waxing wroth, curse me.
1548	64	4	And O god, even this is my fear, and therefore it behove you to favour me. Thus apprehensively addressed by her in fear, the thousand-eyed one answered that damsel trembling and staying with clasped hands, ‘Never fear, O Rambhā, good to you! Do you perform my bidding;
1549	64	5	Assuming the form of a Cole, captivating the heart, I will in this spring crowned with graceful trees, stay by your side in company with Kandarpa .
1550	64	6	Do you adding to your beauty, diverse blandishments bewitch this ascetic, Kuśika ’s son, O gentle one?’
1551	64	7	Hearing Indra ’s words, that comely damsel of luminous smiles, heightening her charms exceedingly inspired Viśvāmitra with desire,
1552	64	8	He listened to the mellifluous strains of the Cole; and with a delighted heart, he beheld the fair one.
1553	64	9	Anon, listening to the warbling of the Cole and her own incomparable singing, as well as beholding Rambhā, the ascetic began to entertain doubts.
1554	64	10	And knowing for certain that it was the thousand-eyed deity who had devised all that, that foremost of anchorets, Kuśika’s son, overwhelmed with anger, cursed Rambhā, saying,
1555	64	11	Since, O Rambhā, you endeavour to seduce me who is bent upon subduing his anger and lust, you shall, O luckless one, remain as a stone for ten thousand years.
1556	64	12	And a highly energetic Brāhmaṇa equipped with ascetic energy, will, O Rambhā, deliver you, stained because of my ire.’
1557	64	13	Thus said that exceedingly energetic and mighty ascetic Viśvāmitra, unable to contain his anger and indignation of heart.
1558	64	14	And in consequence of his mighty curse, Rambhā was turned into a stone. Hearing the curse of the mighty saint, both Kandarpa and Indra left the place.
1559	64	15	O Rāma, on account of his anger, and his sense remaining still unsubdued he found no rest from deterioration of ascetic merit. And coming by decrease of ascetic merit, he thought within himself, ‘No more shall I suffer anger to exercise me,—nor will I ever say anything to any.’
1560	64	16	And I shall not breathe for an hundred years; and controlling my sense, I shall dry up my body.
1561	64	17	And so long as I do not attain Brāhmaṇa-hood as earned by my austerities, I shall suspending my breath and abstaining from food, stay for a long lapse of time.
1562	64	18	And engaged in austerities, my form will not undergo any deterioration. That foremost of ascetics bound himself by this unparalleled vow to lead a life of such self-denial.
1563	65	1	Forsaking the northern direction the mighty Muni , O Rāma , betaking himself to the Eastern quarter, became engaged in dreadful austerities.
1564	65	2	Adopting the high vow of taciturnity for a thousand years, he, O Rāma began to perform the most signal and arduous austerities.
1565	65	3	When the thousand years had been complete, many an impediment tried the mighty Muni staying like the trunk of a tree, yet could not anger enter his heart.
1566	65	4	And firmly deter mined to shut out anger, he, O Rāma, kept his asceticism from deterioration. And, O foremost of the Raghus , when his vow of a thousand years had been observed, that one of mighty vows became desirous of feeding on boiled rice. And it came to pass O best of the Raghus that at this time Indra assuming the guise of a regenerate one, asked for the rice.
1567	65	5	Thereupon he gave it away to the Vipra ; and when the rice had been thus exhausted, that worshipful one of mighty austerities went without foot.
1568	65	6	Nor, abiding by the vow of reticence, did he say aught to the Vipra. And he then again resumed his dumb guise, restraining his breath at the same time.
1569	65	7	And that puissant ascetic did not breathe for a you sand years. And as he restrained his breath, vapours began to issue out of his head.
1570	65	8	And at this, the three worlds became afflicted with fear. And bewildered on account of the energy of his asceticism, and shorn of their brightness, and afflicted with anguish, the Devarṣis and the Gandharvas and the Pannagas and the Uragas and the Rākṣasas in a body addressed the Pitāmaha , ( Brahmā ).
1571	65	9	0 divine one, various were the means by which we endeavoured to affect the mighty Muni Viśvāmitra with covetousness and lust; but for all that he increase in asceticism. ṣṭfPR
1572	65	10	Nor do we perceive in him ever so little of anger or lust. And if you do not confer upon him what his mind desire to have, he will annihilate the three worlds with all that is mobile and immobile in them. And the ten cardinal points are disconsolate: and nothing can be discovered therein.
1573	65	11	And the seas are vexed, and the mountains, riven. And the earth shake, and the winds keep steadily blowing.
1574	65	12	O Brāhmaṇa , we do not know how to remedy, this. And every one is inactive like an infidel. And the three worlds look as if stupefied, with their minds exceedingly exercised.
1575	65	13	By virtue of that mighty saint’s energy, the sun itself has been deprived of his splendour.
1576	65	14	Therefore, O god, against the mighty Muni bending his mind upon destruction, and consuming the three entire worlds like to the fire raging at the universal dissolution, that exalted one of exceeding effulgence resembling a flame, should be pacified.
1577	65	15	Even should he desires the dominion of the celestial regions, do you grant him his wish.
1578	65	16	Then the celestials with Pitāmaha at their head, addressed the high-souled Viśvāmitra in sweet-words, saying, ‘Welcome, O Brahmarṣi ! Well pleased have we been with your penances. And, O son of Kuśika , in consideration of your fiery asceticism, you have obtained Brāhmaṇa-hood.’
1579	65	17	O Brāhmaṇa, I will in company with the Maruts confer on you long life, hail to you! Do you accept this, good betide you. Go you, O gentle ascetic, bowing down to the celestials, said in delight,
1580	65	18	If Brāhmaṇa-hood has really been obtained by e together with length of days, let Oṃkāra and Vaṣaṭkāra and the Vedas crown me; and let, you gods, that foremost of those versed in Kṣtra Veda ad well as of those cognizant of the Brahmaveda , even Brahmā’s son, Vasiṣṭha , recognise me. Having granted this prime desire of mine, do you go away, you gods.
1581	65	19	Then pacified by the celestials, that best of reciters, the Brahmarṣi Vasiṣṭha, made friends (with Viśvāmitra), saying,
1582	65	20	‘So be it.’ You are a Brahmarṣi. There is no doubt about this. And every thing has been compassed in your behalf, having said this, the deities went to their respective regions.
1583	65	21	And that Brahmarṣi, the righteous Viśvāmitra also, having attained excellent Brāhmaṇa-hood, paid his homage to that best of reciters, Vasiṣṭha.
1584	65	22	And, having secured his end, began to range the entire world, staying in asceticism. In this wise, O Rāma, was Brāhmaṇya actually obtained by the high-souled one.
1585	65	23	This, O Rāma, is the foremost of ascetics, this one is Asceticism incarnate. This one ever abide by duty; and he is the stay of ascetic energy.
1586	65	24	Having said this, that best of regenerate persons paused. Hearing Śatānanda ’s narration delivered in the presence of Rāma and Lakṣmaṇa , Janaka with clasped hands addressed the son of Kuśika.
1587	65	25	Blessed and beholden am I, that you, O Kauśika , accompanied with Kākutstha , hast arrived at my sacrifice, O puissant anchorite. Purified am I, O Brāhmaṇa, by your very sight.
1588	65	26	O mighty Muni. And from your sight have I received various qualities. O Brāhmaṇa, your mighty austerities have been related in detail; and myself as well as he high-souled Rāma have listened to the narration relative to your formidable ascetic energy; and the assembled courtiers have heard of your various perfections.
1589	65	27	Immeasurable is your asceticism; and immeasurable your power; and ever immeasurable your qualities,
1590	65	28	O Kuśika’s son. I never, O lord, am tired of listening to that wonderful narration. Now, O foremost of ascetics, the hour for performing the daily devotions has arrived, and the solar disc hangs aslope.
1591	65	29	To-morrow morning, O highly energetic one, you will see me again. Welcome, best of reciters. It behove you to favour me.
1592	65	30	Thus addressed, that best of ascetics, extolling that powerful one, well pleased, dismissed the delighted Janaka.
1593	65	31	Thus accosted, Mithilā ’s lord, Vaideha , in company with his priests and friends, went round that foremost of ascetics.
1594	65	32	And the righteous Viśvāmitra also together with Rāma and Lakṣmaṇa, having been honoured by the high-souled ones, took up their quarters there.
1595	66	1	The next morning, which happened to be bright, the lord of men, having performed his daily devotions, welcomed Viśvāmitra and Rāghava . And having, in accordance with the scriptures, paid homage to the former as well as the two high-souled Rāghavas , that virtuous one said,
1596	66	2	Hail, O worshipful sir! What shall I do to you, O sinless one? Do you command. Surely, I deserve to be commanded by you.
1597	66	3	Thus addressed by the high-souled Janaka , that first of ascetics endowed with a righteous soul, well versed in speech, answered,
1598	66	4	These sons of Daśaratha — Kṣatriyas , famed among men, are eager to behold than best of bows.
1599	66	5	If it be with you, do you show it to them, may it be well with you! having obtained a sight of that bow, the king’s sons, their desires crowned with success, will success, will return as they list.
1600	66	6	Thus accosted, Janaka replied to the mighty Muni , saying, Listen to why the bow lie here.
1601	66	7	There was a king known by the name of Devarata . He was the elder brother of Nimi . And, O worshipful one, this bow was consigned to the hands of that high-souled one, this bow was consigned to the hands of that high-souled one as a trust.
1602	66	8	Formerly with the view of destroying Dakṣa ’s sacrifice, the puissant ( Śiva ), drawing this bow, sportively spoke to the celestials in ire, saying, ‘Since, you gods, you deny me the shares (of this sacrifice), which I lay claim to, I will with my bow even sever those heads of yours.’
1603	66	9	Thereat, O powerful ascetic, with agitated hearts, the deities fell to propitiating that lord of the celestials, and Bhava was pleased with them.
1604	66	10	And well-pleased with them, he conferred this upon those high-souled ones. And even this is that jewel of a bow belonging to the high-souled god of gods, and which was ultimately, O lord, consigned as a trust to our ancestor.
1605	66	11	And as I was ploughing the mead, arose a damsel, and as I obtained her while hallowing the field (for sacrifice), she has come to be known by the name of Sītā . And arising from the earth, she grew as my daughter.
1606	66	12	Unsprung from the usual source, she was then established here as my daughter, whose hand must be obtained by bending the bow. And, O foremost of ascetics, many a king, coming here, had saught to obtain my growing daughter arisen from the earth. But, O worshipful one, in consideration of her being one whose dower must be prowess in bending the bow, I would not bestow my daughter upon those lords of earth seeking for the kings in a body began to flock to Mithila , desirous of being acquainted with the strength of the bow.
1607	66	13	And on their being curious (as to the bow), I showed it to them; but they could neither hold nor wield it.
1608	66	14	And, O mighty Muni, finding those powerful kings to be but endowed with small prowess, I passed them by. Hear what then befell, O you of ascetic wealth. Then, O powerful anchorite, in high ire, the kings, doubtful as to their strength in stringing the bow, laid siege to Mithila. And those potent princes, conceiving themselves as frustrated by me, began to harass the city of Mithila, waxing wondrous wroth.
1609	66	15	And when a year had been completed, my defensive resources were entirely exhausted, and at this, I was exceedingly aggrieved.
1610	66	16	Then I sought to propitiate the deities; and well-pleased, the celestials granted me a Caturaṅga army.
1611	66	17	At length those wicked kings, meeting with slaughter, broke and fled in all directions, together with their adherents, bereft of vigour, and confidence in their strength.
1612	66	18	And, O puissant ascetic, this highly effulgent bow will I show to Rāma and Lakṣmaṇa .
1613	66	19	O you of excellent vows. And, if, Ascetic, Rāma succeeds in fixing string to it, I will confer upon Daśaratha’s son my daughter Sītā, unsprung from the usual source.
1614	67	1	Hearing Janaka ’s words, the mighty Muni Viśvāmitra said to the king, Do you show the bow to Rāma .
1615	67	2	Thereupon the king Janaka commanded his ministers, saying, Do you bring the wonderful bow furnished with unguents and garlands,
1616	67	3	Commanded by Janaka, the ministers entered the city; and placing the bow in their front, those, endowed with immeasurable energy, came out.
1617	67	4	And deposited in a case on a cart borne upon eight wheels, it was with difficulty drawn along by five thousand stalwart persons of well-developed frames.
1618	67	5	And having brought that bow plaited with iron, placed in its case, the royal counsellors spoke to Janaka resembling an immortal, saying,
1619	67	6	Here is the best of bow, O king, worshipped of all sovereigns. O foremost of kings, O lord of Mithilā , if it please you, behold the same.
1620	67	7	Hearing their speech, the king with clasped palms said to the high-souled Viśvāmitra as well as Rāma and Lakṣmaṇa ,
1621	67	8	This best of bows, O Brāhmaṇa , has always been worshipped by the Janakas : as also by mighty kings incapable (of wielding and stringing it.)
1622	67	9	And neither the celestials, nor the Asuras , nor the Rākṣasas , nor the Gandharvas , nor the Yakṣ as, nor the Kinnaras , nor the mighty Uragas , how shall men fare—have succeeded in stringing or stretching it, or fixing the arrow to it, or pulling its string, or wielding it.
1623	67	10	This foremost of bows has been brought here, O chief of ascetics. Do you, O exalted one, show it to these sons of the king.
1624	67	11	Hearing Janaka’s words, the righteous Viśvāmitra said to Rāghava , O Rāma, do you, my child, behold the bow.
1625	67	12	At the words of the Maharṣi , Rāma, opening the case, took a sight of the bow, and said,
1626	67	13	This divine bow will I touch with my hand, and shall I also strive to wield and draw it?
1627	67	14	Thereat both the king and the ascetic said,—Excellent well. At the words of the anchorite, in the sight of countless thousands of spectators, the righteous son of Raghu with exceeding ease took hold of the bow by the middle, and fixed the string upon it, and having fixed the string, drew it. And that foremost of men enjoying high fame, snapped the bow in the middle. And mighty was the sound that was heard on the occasion, like to the bursting of a thunder-clap: and the earth trembled terribly, as it does in the vicinity of a mountain splitting; and overwhelmed by the noise, all rolled head over heels, with the exception of that best of ascetics, the king, and the two Rāghavas .
1628	67	15	On the people being reassured, the king conversant with speech, his apprehension removed, with folded hands addressed that puissant ascetic, saying.
1629	67	16	O worshipful one, I have beheld the prowess of Daśaratha ’s son. This is verily wonderful and inconceivable; and I did not think this was possible.
1630	67	17	My daughter, Sītā , being united with her lord, Daśaratha’s son, Rāma, will shed lustre on Janaka’s line.
1631	67	18	My promise viz., that I will confer Sītā upon him that will bend the bow, has been fulfilled, O son of Kuśika . And this Sītā, this my daughter, dearer to me than life will I confer upon Rāma.
1632	67	19	O Brāhmaṇa, by your permission let my counsellors speedily post hence, O Kauśika , to Ayodhyā , in cars; and with humble speech bring the king to my capital. And let them communicate to him all about the bestowal of’ Sītā upon Rāma, in consequence of his having bent the bow.
1633	67	20	Let them acquaint the monarch with the welfare of the Kākutsthas protected by the ascetic; and let them, speedily posting hence, bring the delighted king.
1634	67	21	And thereupon Kuśika’s son said,—So be it. And the righteous king, summoning his counsellors, despatched them to Ayodhyā with his letter, to communicate all duly to the king, and bring him thither.
1635	68	1	Thus commissioned by Janaka , the envoys, having spent three nights on the way, entered the city of Ayodhyā , with their conveyances afflicted with fatigue.
1636	68	2	In accordance with the royal commission, entering the king’s residence, they saw the aged king Daśaratha , resembling a celestial.
1637	68	3	Freed from apprehension the envoys with clasped hands addressed the monarch in sweetly humble accents, saying, O mighty monarch, Mithilā ’s lord, king Janaka, in company with this priests, in sweet and affectionate words, repeatedly enquires after the complete welfare of thyself along with your priests and servants.
1638	68	4	After having enquired after your complete welfare, Mithilā's lord, Vaideha , by permission of Kauśika , addresses you thus,
1639	68	5	You know the vow I had made formerly—viz., to confer my daughter upon him that would bend the bow,—and the kings, in consequence of their having been deprived of prowess, and being baffled, have come to entertain spite against me.
1640	68	6	And that daughter of mine, O king, has been won by your son, arrived one, that divine, jewelled bow has been snapped in the middle by the high-souled Rāma in the midst of a large assembly.
1641	68	7	Upon that high-souled one should I confer Sītā , having prowess assigned for her dower. And in this wise will I free myself from my vow; and this you should permit.
1642	68	8	O mighty king, do you, good betide you, come speedily headed by your priests. It behove you to see the Rāghavas ;
1643	68	9	And, O foremost of kings, to see me delivered from this vow. And do you attain the joy incident to the nuptials of both your sons,
1644	68	10	Thus spoke sweetly the lord of Viḍeha, permitted by Viśvāmitra and staying by the opinions of Śatānanda .’
1645	68	11	Hearing the words of the envoys, the king, exceedingly rejoiced, addressed Vasiṣṭha and Vāmadeva , as well as his counsellors, saying,
1646	68	12	Protected by Kuśika ’s son, that exhancer of Kausalyā ’s joy stay in Videha in company with his brother, Lakṣmaṇa .
1647	68	13	And the high-souled Janaka has witnessed the prowess of Kākutstha ; and he wish to bestow his daughter upon Rāghava .
1648	68	14	If this alliance with the high-souled Janaka is relished by you, we shall speedily repair to his capital. Let there be no waste of time.
1649	68	15	Thereupon, the counsellors along with the Maharṣis said, Excellent! And the king highly delighted, said to the counsellors, Our journey commence on the morrow.
1650	68	16	And excellently ministered to, the counsellors of that foremost of monarchs (Janaka), endowed with every excellent quality, spent that night in joy.
1651	69	1	Then when the night had been spent, king Daśaratha accompanied with his priests and adherents, well pleased spoke to Sumantra , saying,
1652	69	2	To-day let the officers in charge of the treasury, taking plenty of excellent wealth, and furnished with various gems, go in advance under proper escort.
1653	69	3	And let the fore-fold forces sally out with speed. And at my command let horses and conveyances and elegant vehicles march out
1730	72	1	When Vaideha had spoken thus, the mighty ascetic Viśvāmitra is company with Vasiṣṭha addressed that heroic king, saying.
1654	69	4	And let Vasiṣṭha and Vāmadeva and Jābāli and Kaśyapa and Mārkaṇḍeya endowed with long life and the saint Katyāyana—let these regenerate ones go forward. And do you also yoke my car. Let not the proper time pass away; for the envoys urge speed upon me.
1655	69	5	At these words of the king, the four-fold forces together with the saints went in the wake of the monarch.
1656	69	6	After having passed four days on the way, they arrived at Videha . And bearing of Daśaratha’s arrival; the auspicious king Janaka experienced great delight, and having obtained the aged king Daśaratha, he honoured him duly. w to M ^iPewH,i wra % t^gṇr to i ft 11
1657	69	7	That chief of men well pleased, spoke these words, Have your journey been a pleasant one, O best of men? By luck have I obtained you, O descendant of Raghu .
1658	69	8	Do you experience the joy earned by the prowess of your sons. And by luck it is that I have obtained the highly energetic and worshipful saint Vasiṣṭha accompanied by the foremost regenerate ones, like him of an hundred sacrifices, by the celestials.
1659	69	9	By luck it is that I have overcome the obstacle; by luck it is that my race has attained renown, in consequence of alliance with those endowed with prowess, the exceedingly potent Rāghavas .
1660	69	10	O lord of men, to-morrow morning after the completion of the sacrifice, do you perform the nuptials, in company with the foremost of the saints.
1661	69	11	Hearing his speech in the midst of the saints, that best of those conversant with words, the lord of men, replied to the monarch, saying,
1662	69	12	A gift should be accepted, this I heard formerly. And what you say, O you cognizant of duty, will we accomplish.
1663	69	13	Hearing these words of the truthful (king), chiming in with morality and conducive to fame, the lord of Videha was filled with admiration.
1664	69	14	Then the ascetics experiencing great delight, passed the night in each other’s company.
1665	69	15	And the king, overjoyed on beholding his sons, the Rāghavas passed (the night) in exceeding delight, splendidly entertained of Janaka.
1666	69	16	And the exceedingly energetic Janaka also, versed in men and things, having in accordance with the ordinance completed the sacrifice and performed all the preliminary rites relative to the nuptials of his daughters, reposed for the night.
1667	70	1	Then next morning Janaka skilled in speech, having in company with the Maharṣis performed his daily duties, addressed the priest Śatānanda , saying
1668	70	2	My highly energetic, puissant and eminently righteous brother known by the name of Kuśadhvaja dwell in the auspicious city, Sāṅkāśyā , whose ramparts are ranged round with pointed weapons, and which is laved by the river Ikṣumatī , and which resembles the celestial regions or the aerial car, Puṣpaka .
1669	70	3	I wish to see him, and he is in charge of my sacrifice. And that highly energetic one will partake with me the joy of this occasion.
1670	70	4	This having been said to Śatānanḍa, some competent persons presented themselves; and Janaka commanded them (to set up) for Sāṅkāśyā.
1671	70	5	And commanded by the monarch, off they want, mounting on fleet coursers, with the view of bringing over that tiger among men, like Viṣ ṇu at the mandate of Indra .
1672	70	6	And arriving at Sāṅkāśyā, they presented themselves before Kuśadhvaja, and faithfully delivered to him the intention of Janaka.
1673	70	7	And hearing the tidings conveyed by those foremost of envoys endowed with great fleetness, Kuśadhvaja set out at the mandate of the monarch.
1674	70	8	And on coming to Viḍeha, he appeared before the high-souled Janaka addicted to righteousness. And saluting Śatānanda as well as the eminently virthous Janaka, he sat down on an excellent and superb seat worthy of a King.
1675	70	9	Having been seated, both the heroic brothers of immeasurable splendour addressed that foremost of counsellors, Sudāman , saying, ‘Go, foremost of counsellors, and speedily bring over the irrepressible Ikṣvāku of immeasurable splendour along with his sons and ministers.’
1676	70	10	Thereupon, repairing to the camp of that enhancer of the race of the Raghus , he saw Daśaratha , and saluting him with beaded head, addressed him.
1677	70	11	O heroic lord of Ayodhyā , Vaideha , the master of Mithila , has wished to see you along with your priests.
1678	70	12	Hearing the words of that best of counsellors, the king accompanied by the saints and his adherents, came to Janaka.
1679	70	13	And in company with his counsellors with his counsellors and priests and adherents, the king, foremost of those skilled in speech, spoke to Vaideha.
1680	70	14	O mighty king, you know that the worshipful saint Vasiṣṭha is the spiritual guide of our race; and in every ceremony that we undertake, he it is who serves the function of a spokesman.
1681	70	15	And permitted by Viśvāmitra along with all the Maharṣis, even this one of a righteous soul will relate my genealogy.
1682	70	16	And on Daśaratha resuming silence, the worshipful saint Vasiṣṭha, versed in speech, spoke to Vaideha in company with his priests, saying,
1683	70	17	The perpetual, everlasting, and undeterio- rating Brahmā sprang from the Unmanifest (Brahmā). From him sprang Marīci ; and Kaśyapa is son to Marīci. And from Kaśyapa sprung Vivasvat ; and Manu is son to Vivasvat. [1]
1684	70	18	This Manu is otherwise called Prajāpati ; and Ikṣvāku is Manu’s son. And this Ikṣvāku you must understand, was the first king of Ayodhyā.
1685	70	19	And Ikṣvāku’s son, it is well known, was the graceful Kukṣī . And Kukṣī’s son was the graceful Vikukṣī.
1686	70	20	And Vikukṣī’s son was the exceedingly energetic and powerful Bāṇa . And Bāṇa’s son was the highly energetic and powerful Anaraṇya .
1687	70	21	From Anaraṇya sprang Pṛthu ; and from Pṛthu, Triśaṅku . And Triśaṅku’s son was the highly famous Dhundhumāra .
1688	70	22	And from Dhundhumāra sprung the Mahāratha , Yuvanāśva . And from Yuvanāśva sprung Māndhātā , lord of earth.
1689	70	23	And Māndhātā’s son was the graceful Susandhi . And Susandhi’s two sons were Dhruvasandhi and Prasenajit .
1690	70	24	And from Dhruvasandhi sprung the famous Bharata . And from Bharata sprung Asita ; to fight whom were born as hostile kings, those heroes, the Haihayas , the Tālajaṅghas , and the Śaśabindus .
1691	70	25	And engaged in conflict with them, that king fled (from his kingdom); and repairing to the Himavat in company with his two consorts, the feeble Asita there paid his debt to nature.
1794	75	4	Hearing his words, king Daśaratha with a blank countenance, and clasped hands, said,
1692	70	26	The story runs that his two wives were in the family way; and that with the intention of destroying the embryo of the other, one of them administered poison to the former mixed in her food.And it came to pass that at this time, Bhṛgu ’s son, the ascetic Cyavana , had become addicted to the romantic Himavat, foremost of mountains. And here one of those exalted dames with eyes resembling lotus-petals, saluting Bhṛgu’s son born shining like a celestial, desired of him an excellent, son. And drawing near to that sage, Kālindi saluted him.
1693	70	27	And that Vipra said to her, who was desiring of having a son born of her,—In your womb, O exalted one, will be speedily born an excellent son mixed up with poison, highly powerful, and exceedingly energetic, and possessed of mighty strength, and graceful.
1694	70	28	Therefore, do you not grieve, O you of lotus-eyes. And having paid reverence to Cyavana, that chaste and worshipful princess, although bereft of her husband, gave birth to a son.
1695	70	29	And since intending to destroy her foetus she that was co-wife with her had administered poison to her, Sagara [2] was born together with the poison.
1696	70	30	And Sagara’s son was Asamañja , and Aṃśumat . And Dilīpa was son to Aṃśumat, and Bhagīratha to Dilīpa.
1697	70	31	And from Bhagīratha sprang Kākutstha , and from Kākutstha, Raghu . And Raghu’s son was the puissant Pravṛdha, feeding on human flesh.
1698	70	32	And he came finally to be known by the name of Kalmāṣapāda .* And from him sprung Śaṅkhaṇa . And Sudarśana was Śaṅkhaṇa’s and Agnivarṇa was Sudarśana’s son.
1699	70	33	He incurred Vasiṣṭha’s curse, and was turned into a Rākṣasa . He took up water, intending to clear scores with Vasiṣṭha; but at the request of his wife, desisted, pouring down the water at his own feet. Hence the name of Kalmāṣapāda.
1700	70	34	Śīghraga was Agnivarṇa’s, and Maru was Śīghraga’s son. And Mam’s son was Praśuśruka, and from Praśuśruka sprung Ambarīṣa .
1701	70	35	Ambarīṣa’s son was Nahuṣa , lord of earth. And Nahuṣa’s son was Yayāti , was Nābhāga . And Nābhāga’s son was Aja, and from Aja sprung Daśaratha. And from this Daśaratha have come the brothers Rāma and Lakṣmaṇa . snf^crṣṭfcrgsHr TḤrf wṃñfaTPḤ
1702	70	36	It is in the interests of Rāma and Lakṣmaṇa belonging to the heroic and truthful and pious sovereigns sprung in the Ikṣvāku line, and possessing purity of race even from the time of their founder, that, O king, we solicit the hands of your daughters. And, O foremost of men, it behove you to confer like brides upon like bridegrooms.
1703	70	37	[back to top]
1704	70	38	[1] :
1705	70	39	The Bengal Text reads: From Marīci sprang Aṅgiras; and his son was Pracetas; and Manu is Praceta’s son.
1706	70	40	(The Bengal Text: From Ikṣvāku sprung Vikukṣī.)
1707	70	41	[2] :
1708	70	42	Gara —poison. Sagara means, with poison, i.e. here, one born with poison.
1709	71	1	When Vasiṣṭha had spoken thus, Janaka with clasped hands answered to him, saying,—It behove you to listen to our genealogy as related by myself. In the matter of disposal of daughters, O foremost of anchorets, one’s own line should be described by one boasting of a noble ancestry. Do you then, O mighty-minded one, listen to the same.
1710	71	2	There was a king famed over the three worlds by his own acts, Nimi —eminently pious and the foremost of those endowed with strength.
1711	71	3	His son was named Mithi , and Mithi’s son was Janaka. And from this king Janaka have we derived that word as applied to every one of us. And from Janaka sprang Udāvasu ;
1712	71	4	Udāvasu’s son was the pious-souled Nandivardhana . And Nandivardha’s son was the heroic Suketu .
1713	71	5	Suketu’s son was the mighty and righteous Devarata . And the Rājarṣi Devarāta ’s son was Bṛhadratha .
1714	71	6	Bṛhadratha’s son was the heroic and puissant Mahāvīra . And Mahāvīra’s son was Sudhṛti , endowed with fortitude and having truth for prowess.
1715	71	7	Sudhṛtia’s son was the pious-spirited and eminently righteous Dhīṣṭaketu. And the Rājarṣi Dhīṣṭaketu’s son was Haryaśva .
1716	71	8	Haryaśva’s son was Maru ; and Maru’s son was Pratīndhaka. And Pratīndhaka’s son was the righteous king Kīrtiratha .
1717	71	9	Kīrtiratha’s son was Devamīḍha , and Devamīḍha’s Vibudha , and Vibudha’s Mahīdhraka.
1718	71	10	Mahīdhraka’s son was king Kīrtirāta endowed wūth great strength. And the Rājarṣi Kīrtirāta had Mahāroman born to him.
1719	71	11	Mahāroman, the virthous Svarṇaroman . And the Rājarṣi Svarṇaroman had Hrasvaroman born to him.
1720	71	12	This high-souled king conversant with morality had two sons: the elder, myself the younger, even my brother, who was the elder son, and consigning to my care Kuśadhvaja , our father sought the forest.
1721	71	13	And on my aged sire ascending heaven, I righteously ruled the kingdom and cherished my brother Kuśadvaja resembling a celestial, with the eye of affection.
1722	71	14	It came to pass that on one occasion a certain powerful king named Sudhanvan came before Mithilā intending to lay siege to it.
1723	71	15	He sent word to me, saying, ‘Do you give me the all-excellent bow of Śiva , as well as your daughter, the lotus-even Sītā .’
1724	71	16	And is consequence of my not granting him either, king Sudhanvan, O Brahmarṣi , entered into hostilities with me; but he was both defeated and slain by me in the encounter.
1725	71	17	O foremost of ascetics, slaying king Sudhanvan. I installed in Sāṅkāśyā my heroic brother Kuśadhvaja.
1726	71	18	Thus one, O mighty anchorite, is my younger brother, and I am his elder. O powerful ascetic, well pleased will I confer on you these as your daughter-in-law,
1727	71	19	Sītā on Rāma , good betide you, and Urmilā on Lakṣmaṇa . And, I take oath thrice that, without doubt, I will with a glad heart confer upon you, O potent ascetic, as your daughters-in-law my second daughter Urmilā and also Sītā resembling the daughter of a celestial, having prowess assigned for her dower.
1728	71	20	Do you now, O king, give away kine on behalf of the nuptials of Rāma and Lakṣmaṇa; and also perform their ancestral rites, good to you; and then complete the marriage ceremony.
1729	71	21	To-day the star Maghā is on the ascendant. On the third day, my master, when the Phalguna will be on the north, do you, O monarch, perform the marriage ceremony. Do you now, however, dispense gifts for invoking blessings upon Rāma and Lakṣmaṇa.
1731	72	2	O puissant one, the lines of the Ikṣvākus and the Vaidehas are exceedingly noble and incomparable. No other race can by any means compare with them.
1732	72	3	O monarch, this youthful union of Rāma and Lakṣmaṇa with Sītā and Urmilā is fit by all means; and it is worthy of their wealth of grace.
1733	72	4	Now do you, O foremost of men, listen to my words. This youthful brother of yours, king Kuśadhvaja , O you versed in morality, this pious-souled one, O king, has, O prime of men, a couple of daughters, unparalleled on earth in beauty, whom we would ask for, to become wives to the prince Bharata and the intelligent Śatrughna ; as we, O king, ask for your own daughters in the interests of those high-souled ones (Rāma and Lakṣmaṇa).
1734	72	5	And these sons of Daśaratha are endued with youth and beauty, resembling the Lokapalas , and possessed of the prowess of celestials.
1735	72	6	Therefore do you, O foremost of sovereigns, by this alliance with both the brothers, bind the Ikṣvāku race. And in this may your mind never waver!
1736	72	7	Hearing Viśvāmitra’s words embodying the sentiments of Vasiṣṭha, Janaka with clasped hands addressed both the potent ascetics, saying,
1737	72	8	‘I consider my line as blessed; since such puissant ascetics wish for such a desirable alliance.
1738	72	9	Whatever you wish, even that shall be done, good betide you. Let these daughters of Kuśadhvaja together become the wives of Śatrughna and Bharata.
1739	72	10	On the same day, O mighty Muni , let the four highly powerful princes espouse the hands of the four princesses.
1740	72	11	The learned consider bridal celebrated on the day succeeding those on which the Phalgunis are on the ascendant, and having for its presiding deity Bhagas —the most auspicious.’
1741	72	12	Having said these amiable words, king Janaka arose, and with clasped hands addressed both the foremost of ascetics, saying.
1742	72	13	I have reaped high religious merit (by these nuptials), and I also am your disciple. And do you, you anchorets, occupy these best of thrones, (belonging to us).
1743	72	14	And even as this kingdom is to Daśaratha is Ayodhyā to myself. Do you not therefore entertain any doubts as to your lordship. Do you therefore do as it behove you.
1744	72	15	And as Vaideha Janaka was speaking thus, Raghu ’s son, king Daśaratha, well pleased answered that monarch, saying,
1745	72	16	Countless are the excellences that pertain to you brothers, lords of Mithilā ; and saints and sovereigns are ever honoured by you, [1] auspiciousness be yours.
1746	72	17	Good betide you, I will repair to my own quarters, there to duly perform the Śrāddha ceremonies.
1747	72	18	Then having greeted that king of men, the illustrious Daśaratha, placing those foremost of ascetics in his front, went away.
1748	72	19	And reaching his quarters, the king performed the Śrāddha according to the ordinance, arose the next morning, and made excellent gifts of kine.
1749	72	20	And to Brāhmaṇas the monarch severally gave away kine by hundreds and by thousands, for the welfare of his sons.
1750	72	21	And that puissant one gave away to the regenerate ones four hundred thousands of kine furnished with horns plaited with gold, and each having her calf, together with bell-Mattel vessels for milking them.
1751	72	22	And that descendant of Raghu addicted to his sons made presents of various other valuables and the Brāhmaṇas, on behalf of his sons. And having given away kine, the surrounded by his sons looked like to the amiable Prajāpati surrounded by the Lokapālas .
1752	72	23	[back to top]
1753	72	24	[1] :
1754	72	25	The commentator here seems to be in fault. He explains,—By you have your royal ancestors been honoured. Evidently an error. I differ from him. The particle ca (and) makes the point clear.
1755	73	1	And it came to pass that the day on which the king made excellent presents of kine, the heroic Yudhājit , son to the lord of the Kekayas and maternal uncle to Bharata , presented himself before Daśaratha . And having seen the king and enquired after his welfare, he said to him.
1756	73	2	The lord of the Kekayas has from affection enquired after your welfare, sayiing,—‘They of whose peace you are anxious, are at present well.’ And, O foremost of kings, desirous of seeing (Bharata) together with his wife, that lord of earth repaired to Ayodhyā .
1757	73	3	O descendant of Raghu . And learning at Ayodhyā that your sons for the purpose of marriage had, O monarch, come to Mithilā with yourself, I have speedily hide hither, with the intention of seeing my sister’s son.
1758	73	4	Then king Daśaratha, on having that dear guest with him, rendered to him all the respect that he deserved.
1759	73	5	Then having passed the night in company with his high-souled sons, that one versed in men and things arose in the morning, and having disposed of his daily duties, approached the entrance of the sacrificial ground, headed by the saints.
1760	73	6	Then at an auspicious moment called Vijaya ; Rāma with Vasiṣṭha as well as other Maharṣis at his head, and accompanied by his brothers adorned with various ornaments, who had all performed the rites relative to their nuptials, (approached the entrance of the sacrificial ground). Then the worshipful Vasiṣṭha, coming to Vaideha , spoke as follows.
1761	73	7	King Daśaratha, O foremost of sovereigns, that chief among the best of men—accompanied with his son, who have performed all the rites relative to their nuptials, stay the orders of the bestower (of the bride); for the meeting of the giver and the receiver is indispensable to every transaction (of this nature). Do you therefore maintain your merit by accomplishing this excellent nuptial ceremony.
1762	73	8	Thus addressed by the high-souled Vasiṣṭha, that exceedingly generous and energetic one versed in morality answered, saying,
1763	73	9	Who act as my warder there? And whose commands does he stay? And what need of exercising judgement in such a matter? As this kingdom is mine, so it is verily your. O foremost of anchorets, my daughters resembling flames of fire, having performed all the rites relative to the incoming nuptials, are at the foot of the dais; and, sitting beside the dais.
1764	73	10	I myself had been expecting you every moment. Do you perform everything without let. What need of delaying further?
1765	73	11	Hearing those words uttered by Janaka , Daśaratha entered in together with his sons and the body of saints.
1766	73	12	Then to the king of the Videhas , Vasiṣṭha spoke as follows,—O saint, do you, O pious one, in company with the saints, perform, O master, the nuptial ceremonies of Rāma charming to all.
1767	73	13	Thereupon, saying, So be it to Janaka, the worshipful saint Vasiṣṭha of mighty austerities with Viśvāmitra and the pious Śatānanda in his front, constracted a dais agreeably to the scriptures, decking it out with fragrant flowers all around, and golden ladles, and variegated water-pots, and platters with ears of barley, and censers filled with Dhūpa , and conchs, and sacrificial spoons, and vessels furnished with Arghyas , and those containing fried paddy, and sanctified Akṣatas . And over the dais, Vasiṣṭha with due mantras and rites spread an awning consisting of Darbhas of equal proportions. And with prescribed rites and mantras placing fire upon the dais, the highly energetic one commenced upon offering oblations.
1768	73	14	Then bringing Sītā adorned with various ornaments near the fire, and placing her before Rāghava , king Janaka addressed the enchancer of Kausalyā ’s joy, saying,—This Sītā, my daughter, to you accept, good betide you, as your partner in the observance of every duty: do you take her hand by yours. May she be of excited piety, and devoted to her husband; ever following you like your shadow!
1769	73	15	Saying this, the king sprinkled Rāma’s palm with water sanctified with mantras; with the celestials and saints exclaiming, Excellent! Excellent!
1770	73	16	And the celestial kettle-drums sounded, and blossoms began to shower down copiously. Having thus given away his daughter Sītā, with water and mantras , king Janaka, overflowing with delight, said, Come forward, O Lakṣmaṇa , good to you. Receive you Urmilā ready to be bestowed by me upon you. Do you accept her hand: let there be no delay about it.
1771	73	17	Having addressed Lakṣmaṇa thus, Janaka spoke to Bharata, saying, Do you, O descendant of Raghu, take Māṇḍavya ’s hand by yours own.
1772	73	18	The righteous lord of Mithilā spoke also to Śatrughna , saying, Do you, O you of mighty arms, take Śrutakīrti ’s hand by your own. May you all be good, and vowed to excellent life! And be, you Kākutsthas , you united with your wives. Let there be no delay about it.
1773	73	19	Hearing Janaka’s speech, those four perpetuators of Raghus ’s line, staying by Vasiṣṭha’s opinions, taking the hands of the four brides with their own, went round the sacrificial fire, and the dais, and the king, and the high-souled saints; and in company with their wives, agreeably to direction entered into matrimony in accordance with the ordinance.
1774	73	20	There was a mighty shower of shining blossoms from the firmament accompanied with the sounds of celestial kettle-drums, and choiring and instrumental music. And the Apsaras , danced and the Gandharvas sang melodiously, at the bridal of the foremost of the Raghus. And this seemed wonderful to witness.
1775	73	21	To the blowing of trumpets, those exceedingly puissant ones, thrice going round the fire, in company with their wives went to the encampment.
1776	73	22	The king, having seen that all the auspicious ceremonies were performed, went in their wake accompanied by the sages and his adherents.
1777	74	1	Then when the right had passed away, the mighty Muni Viśvāmitra , having greeted the monarchs, yet out for the Northern mountains.
1778	74	2	When Viśvāmitra had gone away, king Daśaratha , greeting Mithilā ’s lord, Vaideha , actively prepared for setting out for his own capital.
1779	74	3	Then the king of the Viḍehas gave a dower consisting of various things. And Mithilā’s lord gave many hundred thousands of kine, and excellent woollen stuffs, and Koṭis of common cloths; and elephants, and horses, and cars, and footmen, as well as an hundred damsels adorned, endowed with elegance to form goodly waiting-maids. And well-pleased the king gave as a noble dower gold and silver and pearls and coral.
1780	74	4	Having given divers kinds of articles, that king, the lord of Mithilā, bidding adieu to the monarch (Daśaratha), re-entered his own capital. And the master of Ayodhyā accompanied with his high-souled sons, and headed by the saints in a body, started on the journey, followed by his own army.
1781	74	5	As that tiger-like one was on his way, in company with Rāghava and the saints, the fowls began to utter frightful cries all around, and the beasts on earth to stream in a Southern direction.
1782	74	6	Beholding them, that tiger-like monarch asked Vasiṣṭha , saying, Those birds of fierce aspects emit frightful cries and beasts stream in a Southerly direction. What is this? My heart tremble and my mind is not at ease.
1783	74	7	Hearing the speech of king Daśaratha, that mighty saint spoke sweetly, saying, 'These fowls of the air by their cries presage some dreadful impending evil; but these beasts betoken peace restored. Therefore do you renounce anxiety’
1784	74	8	As they were thus conversing, there blew a strong wind; and all the earth began to speak; and the trees to topple down. And a deep gloom enveloped the sun; and no quarter could be discovered. And enveloped in ashes, that host became stupefied.
1785	74	9	At that dreadful hour, Vasiṣṭha and the other saints and the king alone retained their senses, all else were deprived of their senses, and the army was enveloped with ashes.
1786	74	10	The king saw that repressor of kings, the descendant of Bhṛgu , Jamadagni ’s son, dreadful to behold, wearing a head of matted locks, like to the Kailāsa , had to baffle, resembling the fire at the universal dissolution, difficult to bear, flaming in energy, incapable of being looked at by the unrighteous, with his axe on his shoulder, equipped with a bow like to the lighting, and fierce arrows, looking like Śiva the slayer of Tripura .
1787	74	11	Beholding him of dreadful appearance like to flaming fire, the Vipras headed by Viśvāmitra, engaged in reciting mantras and offering oblations to the fire, those saints assembled together, began to converse with each other.
1788	74	12	Is this one, enraged because of the slaughter of this sire, intent upon exterminating the Kṣatriyas ? Formerly, having slaughtered the Kṣatriyas, he pacified his ire and mental ferment, therefore, the annihilate the Kṣatriya once again can never be his endeavour.
1789	74	13	Having said this, the saints offered Arghya to Bhṛgu’s son of dreadful appearance; and addressed him in soothing words, saying, ‘O Rāma ! O Rāma’.
1790	74	14	Accepting that homage rendered to him by the saints, that puissant one, Jamadagni’s son, Rāma, addressed Rāma, the son of Daśaratha.
1791	75	1	“ Rāma , son of Daśaratha , I have, O hero, heard of your wonderful prowess; and I have also heard all about your breaking of the bow.
1792	75	2	Having heard of that wonderful and inconceivable breaking of the bow, I have bent my steps hither. Do you take another auspicious bow, Do you stretch it, fix the arrow upon this mighty and dreadful bow, belonging to Jamadagni ; and thus display your prowess.
1793	75	3	Then, having witnessed your might in stretching the bow, I shall offer you combat, laying under contribution our utmost strength.”
1795	75	5	You have quenched your ire against the Kṣatriyas ; and, moreover, you are a Brāhmaṇa boasting of high austerities. It therefore behove you to dispel the fears of my sons who are boys. You bring your life from the race of the Bhārgavas engaged in observing vows, and studying you Veda ; and you have renounced arms vowing in the presence of the thousandeyed one.
1796	75	6	Embracing a life of righteousness, you did confer the earth upon Kaśyapa and repaired to the forest, making the Mahendra hill your home.
1797	75	7	O mighty Muni , you have come here to compass the destruction of my all; but if Rāma be slain, we shall never live.
1798	75	8	Thus addressed by Daśaratha, the powerful son of Jamadagni, disregarding his words, thus addressed Rāma,
1799	75	9	These two foremost of bows, extraordinary, and worshipped of all the worlds, and stout, and powerful, surpassingly excellent, were constructed with care by Viśvakarman .
1800	75	10	One of these, O foremost of men, for the destruction of Tripura , the celestials gave to Tryambaka , desirous of encounter, even that which, O Kākutstha , which you have snapped.
1801	75	11	This second, which is irrepressible, was given to Viṣṇu , by the chiefs of the celestials. And, O Rāma, this bow belonging to Viṣṇu, capable of conquering hostile cities, is,
1802	75	12	O Kākutstha, equal in energy to the bow belonging to Rudra . Once on a time the deities, with the object of ascertaining the respective prowess of Viṣṇu and the blue-throated one, asked the great-father, foremost of those abiding by truth, reading the intention of the deities, fomented a quarrel between them.
1803	75	13	Upon that quarrel breaking out among the deities, there took place a mighty contest capable of making one’s hair stand on end, between Viṣṇu and the blue-throated one, each burning to beat the other down.
1804	75	14	Then on Viṣṇu uttering a roar, Śiva ’s bow of dreadful prowess became flaccid. And thereupon the three-eyed Mahaḍeva became moveless.
1805	75	15	Upon the assembled gods with the saints and the Cāraṇas beseeching those two foremost of celestials, they became pacified.
1806	75	16	Upon beholding that bow of Śiva rendered flaccid by Viṣṇu’s prowess, the deities with the saints acknowledged Viṣṇu as the more powerful.
1807	75	17	The enraged Rudra of high fame made over the bow along with its shafts to the hands of the Rājarṣi , Devarāta of Videha .
1808	75	18	O Rāma, this bow belonging to Viṣṇu, capable of conquering hostile cities, Viṣṇu consigned to Bhṛgus ’ son, Ṛcīka , as a worthy trust.
1809	75	19	The exceedingly energetic Ṛcīka made over the divine bow to his son of immeasurable prowess, my sire the high-souled son of Jamadagni.
1810	75	20	Once on a time, on my sire surcharged with ascetic energy, renouncing the bow, Arjuna , under the influence of unrighteous sentiment, compassed the death of my father.
1811	75	21	Thereupon, learning of the lamentable and untoward slaughter of my sire, I from ire, annihilated the Kṣatryas, springing up afresh by numbers, then bringing under sway the whole earth, I, O Rāma, on the sacrifice being over, conferred it upon the righteous Kaśyapa as Dakṣiṇā .
1812	75	22	Having made this gift, I was dwelling in the Mahendra hill equipped with ascetic energy, when, hearing of your snapping of the bow, I have speedily come hither.
1813	75	23	Do you now, O Rāma, agreeably to the cannon of the Kṣatriya morality, take this excellent and mighty bow of Viṣṇu, that had belonged to my father and grand father. And do you set upon this best of bows an arrow capable of conquering hostile cities. And, O Kākutstha, if you succeed, I shall then offer you combat.
1814	76	1	Hearing Jamadagni ’s, words, the son of Daśaratha , in consideration of the presence of his father, said these words in subdued tone,
1815	76	2	O Bhṛgu ’s son, I have heard of the deeds you have performed, resolved on avenging your sire. O Brāhmaṇa , I acknowledge that.
1816	76	3	But, O Bhargava , you insulted me abiding by the Kṣatriya duties, as pusillanimous or devoid of prowess. Do you to-day witness my energy and vigour.
1817	76	4	Saying this, the enraged Rāghava , endowed with fleet vigour, took up Bhṛgu’s noble bow, together with the shaft.
1818	76	5	And fixing the string upon it he set the arrow. And then Rāma enraged addressed Jamadagni’s son, Rāma, saying,
1819	76	6	You are a Brāhmaṇa and through Viśvāmitra , art worthy of my homage. Therefore it is, O Rāma, that I can not let go this life-destroying shaft.
1820	76	7	Which of these shall I reduce to aught, O Rāma, Your aerial course, or the merit you have attained through your asceticism of ascending to certain incomparable regions. This wonderful arrow of ours sprung from Viṣṇu , capable of conquering hostile towns, never hit fruitless, with energy destroying the pride of prowess of foes.
1821	76	8	And with the object of beholding Rāma holding that foremost of weapons, there assembled in a body the celestials and the saints, with the great-father at their head.
1822	76	9	The Gandharvas and the Apsara and the Siddhas and the Cāraṇas and the Kinnaras and the Yakṣas and the Rākṣasas and the Nagas assembled to behold that mighty wonder.
1823	76	10	And on Bhārgava ’s energy having been observed by Rāma bearing that best of hows, Jamadagni’s son became bereft of prowess, and Rāma ( Paraśurāma ) kept steadily eyeing Rāma.
1824	76	11	And rendered inert in consequence of his energy having been dispelled by Rāma’s own, Jamadagna mildly addressed Rāma of eyes like lotus’ petals, saying,
1825	76	12	When formerly I gave away the earth to Kaśyapas , he said to me, You must no longer stay in my dominions.
1826	76	13	In consonance with the words of my spiritual guide, ever since that time I have never spent three nights together on earth. Even this had been promised by me, O Kākutstha .
1827	76	14	Therefore, O hero, it behove you not to destroy my course, O descendant of Raghu . With the speed of the mind shall I now wend my way to the Mahendra , best of hills.
1828	76	15	O Rāma, the regions I have conquered by my asceticism do you destroy with that foremost of arrows: let there be no delay about it.
1829	76	16	Even from your handing of this bow I know you to be the chief of the celestials even that eternal one, the slayer of Madhu . Hail to you,
1830	76	17	O vanquisher of foes! And all these celestials assembled are beholding you of unparalleled deeds, and without an antagonist in fight.
1831	76	18	And, O Kākutstha, neither ought I to be ashamed (because of this discomfiture); I have been baffled by the lord himself of the three worlds.
1832	76	19	And it behove, O Rāma to disengage this peerless shaft (from the bow), O you of noble vows; and on your shooting the shaft. I shall repair to that fore most of mountains, the Mahendra.
1833	76	20	When Jamadagni’s son, Rāma, had said this, the puissant and graceful son of Daśaratha, had said this, the puissant and graceful son of Daśaratha shot that excellent arrow.
1834	76	21	And witnessing the destruction by Rāma of his regions earned by his own austerities, Jamadagni’s son speedily started for that best of mountains, the Mahendra.
1835	76	22	Then all the quarters became cleared of gloom; and the celestials and saints fell to extol Rāma when he had shot the arrow.
1836	76	23	And that lord, Jamadagni’s son Rāma, having gone round Rāma, the son of Daśaratha, and honoured (by all), set out (for his own quarters).
1837	77	1	When Rāma had departed, Daśaratha ’s son the illustrious Rāma, of serene soul, made over the bow to the hands of Vanina of immeasurable strength.
1838	77	2	Then saluting the saints headed by Vasiṣṭha , Rāma, the descendant of Raghu , seeing his son stupefied, addressed him, saying,
1839	77	3	Now that Jamadagni ’s son has gone away, let the fourfold forces maintained by you as their lord, march in the direction of Ayodhyā .
1840	77	4	Hearing Rāma’s words, king Daśaratha embraced his son with his arms, and smelt Rāghava ’s crown; and hearing that Rāma had gone, the monarch became exceedingly delighted, and considered himself and his son as having attained a second birth.
1841	77	5	He urged on his army, and speedily arrived at the city, graced round with standards bearing pennons, and lovely to behold, and resounding with the sounds of trumpets, with its high-ways watered, and beauteous, and sprinkled around with flowers, crowded with citizens looking cheerful on account of the king’s approach, bearing auspicious articles in their hands, and beautified with the vast concourse of people. And received by the citizens as well as the regenerate ones inhabiting the city coming forward a long way, and followed by his graceful son, the handsome Majesty of illustrious name entered his own dear residence, like to the Himavat .
1842	77	6	And entertained by his own relatives with all objects of enjoyment, the monarch rejoiced exceedingly. And Kausalyā and Sumitrā and the slender waisted Kaikeyī , together with other wives of the king, were busy, receiving the brides, with the necessary ceremonies.
1843	77	7	And the royal spouses received the exalted Sītā and the famous Urmilā and both the daughters of Kuśadhvaya, graced with silken apparel, with homas performed and blessings invoked, on their behalf. And having paid reverence at the abodes of the gods, and rendered homage to those that deserved the same, the daughters of the kings, well pleased, in private, took joy with all the brothers.
1844	77	8	And having attained brides, and arms, with wealth and friends, those foremost of men, engaged in ministering to their father.
1845	77	9	And once on a time that descendant of Raghu, king Daśaratha addressed Bharata , saying,
1846	77	10	O son, this son of the king of the Kekayas your uncle, Yudhājit stay here, that hero, having come to take you over.
1847	77	11	Hearing these words of Daśaratha, Kaikeyī’s son, Bharata; prepared for the journey, together with Śatrughna .
1848	77	12	Having greeted his father, and Rāma of unflagging energy, and his mother, that foremost of men, the heroic (Bharata) departed with Śatrughna.
1849	77	13	And having Bharata as well as Śatrughna, the heroic Yudhājit, with a delighted heart, entered his own city; and his father rejoiced exceedingly.
1850	77	14	And on Bharata having departed Rāma and the exceedingly mighty Lakṣmaṇa , tended their sire resembling a celestial.
1851	77	15	And paying the utmost regard to the command of his father, Rāma discharged all the duties of the city, having for his object the pleasure or welfare (of the citizens).
1852	77	16	And heedfully rendering every service to his mothers, he on proper occasions observed the duties pertaining to his superiors.
1853	77	17	Daśaratha was exceedingly delighted; as also the Brāhmaṇas , and the traders, and the inhabitants generally, at the conduct and behaviour of Rāma.
1854	77	18	Rāma having truth for prowess, by virtue of his excellence appeared to everyone the most meritorious of (Daśaratha’s son) like to the self create Himself to all being.
1855	77	19	In the company of Sītā, the wise Rāma, bending his mind to Sītā, with his heart dedicated to her, passed many a season in delight.
1856	77	20	Rāma’s beloved Sītā, as having been bestowed upon him by his sire, by her loveliness, and her perfections as much as by her loveliness, went on enhancing his joy. And her lord came to exercise a double influence on her heart.
1857	77	21	And by her own heart, the daughter of Janaka , Mithilā ’s lord, resembling a goddess in grace, and like to Śrī (goddess of wealth) herself in loveliness, completely read his inmost sentiments.
1858	77	22	And experiencing delight, Rāma, receiving the Rājarṣi ’s daughter, exercising her own will—the excellent princess—looked graceful, even like the lord Viṣṇu the chief of celestials on being joined with Śrī.
1859	77	23	END OF THE BĀLAKĀṆḌA
\.


--
-- Data for Name: chapters; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.chapters (id, book_id, chapter_number, title, source_url, content) FROM stdin;
3	1	3	Chapter III	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365871.html	Having heard the entire prevalent history of the intelligent Rāma , capable of conferring religious merit and the two other cognate objects, as well as emancipation, Vālmīki again sought to get insight into it\n\nAnd, sitting himself facing the east on a cushion of kuśa grass, and sipping water according to the ordinance, he addressed himself to the contemplation of the subject through Yoga .\n\nAnd by virtue of his Yoga powers, he clearly observed before him Rāma, and Lakṣmaṇa , and Sītā , and Daśaratha together with his wives in his kingdom, laughing, and talking, and acting, and bearing themselves as in real life.\n\nHe also saw all that was endured by Rāma firm in promise, with his wife as the third accompanist roaming in the forest\n\nAnd like an embolic myrobalan on his palm, that righteous-souled sage by virtue of his yoga, perceived all that had happened as well as all that would happen in the past.\n\nHaving truly seen everything by virtue of his contemplation, that magnanimous one set about recording the charming Rāma’s history.\n\nAnd agreeably to what had been related by the mighty-souled Nāraḍa, that worshipful saint composed the history of Raghu ’s line, conferring profit and pleasure, and impregnated with qualities fraught with them, and like to the ocean, abounding in riches, and captivating ear and mind.\n\nRāma’s birth, his mighty prowess, and kindness to all, and popularity, and forbearance, and goodness, and truthfulness.\n\nAnd the wonderful converse he had with Visvāmitra ; wedding of Janaka ’s daughter; and breaking the bow; the hostilities of Rāma with Rāma ( Paraśurāma ); and the noble qualities of Daśaratha’s son: and Rāma’s installation; and the enmity of Kaikeyī ; and the obstacle in the way of the installation; and the exile of Rāma; and the kings grief, lamentations, and departure for the other regions; and the grief of the subjects, and their dismissal (by Rāma to Ayodhyā ); and the tidings of the lord of Niṣādas ; and the charioteer’s return.\n\nAnd the swimming of the Gaṅgā and Rāma sinter view with Bharadvāja ; and his arrival at Citrakūṭa in consonance with Bharadvāja’s injunction.\n\nAnd Rāma’s building a mansion there and sojourn; and Bharata ’s arrival, and his propitiation of Rāma; and Rāma’s offering oblations to the manes of his father.\n\nAnd the installation of the sandals; and Bharata’s dwelling at Nandigrāma : and Rāma’s removal to Daṇḍaka and killing of Virādha .\n\nAnd Rāma’s interview with Śarabhaṅga and meeting with Sutīkṣna; and Sītā’s companionship with Anasūyā , and the latter’s painting the former.\n\nAnd Rāma’s interview with Agastya , and his obtaining the bow from him; and the dialogue of Śūrpaṇakhā and her disfigurement.\n\nAnd the slaughter of Khara and Triśiras ; and the exertions of Rāvaṇa ; the killing of Mārīca , and the carrying away of Vaidehī .\n\nRāghava ’s lamentations, and the death of the king of vultures; Rāma’s encounter with Kabandha , and his view of Pampā .\n\nRāma’s interview with Śabarī , and his subsistence there on fruits and roots; Rāma’s lamentations at Pampā, and meeting with Hanumān .\n\nThe former’s sojourn to the Rṣyamūka, and meeting with Sugrīva ; Rāma’s raising the confidence of Sugrīva and his friendship with the latter; and the encounter between Vālī and Sugrīva.\n\nThe destruction of Vālī, and the installation of Sugrīva and Tārā ’s lamentations; the understanding between Rāma and Sugrīva as to the time for commencing the march. Rāma’s stay at the wet night; and the ire of Rāma the lion of Raghu’s race; the levying of forces; and the despatch of envoys in deferent directions; and the assignment by Sugrīva of different quarters to the monkeys.\n\nThe making over of his ring by Rāma to Hanumān; Ṛkṣa ’s discovery of the cave. The abstemious abode of the monkeys on the shore of the ocean; Hanumān’s interview with Sampāti .\n\nHanumān’s ascension of the mountain, and his bounding over the main; and his sight of the Maināka at the injunction of Ocean; the roaring of Rākṣasis; Hanumān’s meeting with the Rākṣasa Chāyāgrāha. Hanumān’s destruction of Siṃhikāyā; and Hanumān's sight of Laṅkā .\n\nHis entrance by night into Laṅkā; his ascertaining of conduct in times of helplessness; his journey to the Āpāna ground; and his sight of his car Puṣpaka ; his walk to the Aśoka forest, and sight there of Sītā.\n\nHis presentation of the ring to Sītā and converse with her; and the roaring of the Rākṣasis; and the dreaming of the dream by Trijaṭā .\n\nSītā’s handing a gem to Hanumān; and the breaking down of trees; and the fight of the Rākaṣasis, and the slaughter of the salves.\n\nThe wind-god’s son being taken captive; and his terrible roars while burning down Laṅkā; and his bounding back over the ocean; and the forcible possession of honey.\n\nHanumān's consoling Rāghava, and handing him the gem; Rāma’s interview with ocean; and Nala ’s constructing the bridge.\n\nThe army’s crossing of the ocean; and the nightly siege of Laṅkā; and Rāma, interview with Bibhishana ; the communication as to the means of destruction.\n\nAnd the killing of Kumbhakarṇa and Meghanāda ; and the destruction of Rāvaṇa, and the recovery of Sītā in the enemy’s city.\n\nAnd the coronation of Vibhīṣaṇa , and the sight of Puṣpaka; Rāma’s return towards Ayodhyā, and meeting with Bharadvāja.\n\nDespatch of Hanumān; and Rāma’s meeting with Bharata; and the installation of Rāma; and the dismissal of all the forces.\n\nRāma’s pleasing his subjects and renunciation of Sītā,—alleles besides concerning Rāma on earth, that has not yet taken place,—have been dealt with by the worshipful sage in the following poem.
4	1	4	Chapter IV	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365872.html	When Rāma had obtained his kingdom that worshipful sage, Vālmīki , composed the entire history (of that hero in) excellent metre and fraught with high meaning.\n\nThe saint recited twenty-four thousand ślokas ; and it consists of five hundred sections, and is divided into six Kāṇḍas with the Uttara .\n\nAnd having composed it, including as well future incidents to happen afterwards, that lord relected [reflected?] as to who should publish the same before assemblies.\n\nAnd as that great sage of purified soul was thus pounding, in came Kuśi and Lava , in the guise of the sons of ascetics, and touched his feet.\n\nAnd he found those illustrious princes the brothers Kuśi and lava, knowing morality, and living in a hermitage, and endowed with rythmic voice, well versed in the Vedas . And finding them of a retentive endowment, and initiated into Vedic studies, that lord thought them how to interpret the Vedas, and that vow-observing one taught them the great Rāmāyaṇa in full, treating of Sītā ’s great life, and the destruction of Paulastya ( Rāvaṇa ).\n\nThose sweet-voiced brothers, resembling Gandharvas in grace, accomplished in music and dancing, and cognizant of Sthāna and Mūrchanā , began to time to the accompaniment of stringed instruments, and fraught with the sentiments of love, pathos, risibility, the irascible, the terrible, and the heroic. And knowing the characteristics that go to make up the Drama , and gifted with mellifluous voices, those blameless princes, coming from Rāma’s body, and resembling him (like two images of one body, they were two images of made of Rāma’s body).\n\nEven as the reflection of the solar or the lunar disc resembles that disc; got by heart that excellent and moral story in its entirety; and those princes versed in the Fine arts, with a concentrated mind chanted it as they had learnt it, in the assemblies of ascetics and Brāhmaṇas and good men.\n\nOnce upon a time, those high-souled and pious ones, furnished with every auspicious mark, chanted this poem in an assembly of ascetics of purified souls. Having heard this music, all the ascetics were seized with surprise, and with eyes flooded with tears, exclaimed, Well done! Well done! And well pleased, those saints cherishing Duty.\n\nPraised the praiseworthy Kuśi and Lava as they sang, saying,—Ah! what charming music! What sweetness of the verses!\n\nAll this happened long ago, yet it seems as if we saw it before us. And unified with the theme, both of them singing together sweetly, and at a high pitch, by means of ṣaḍja and the other notes, they entranced the audience.\n\nThey two thus went on sweetly singing at a high pitch, praised by those mighty sages priding in their asceticism.\n\nSome one in the assembly pleased with them presented them with a water-pitcher; and some one of high fame, being delighted, made them a present of a bark garment; and some one gave them a dark deer skin and some holy thread.\n\nSome gave a kamaṇḍalu (An earthen or wooden water pot used by an ascetic) and some great saint conferred on them a muñja (grass) made girdle; and some person granted them a bṛsī (The seat of an ascetic), and some a kaupina (a small piece of cloth worn by ascetics.)\n\nThen some ascetic, well-pleased, gave them an axe; and some a saffron, another a casual clothings.\n\nAnd some, a thread for tying up their matted locks; and some gladly gave a twine for binding faggots with, and some ascetic presented them with a sacrificial pot; and some, a quantity of fire-wood; and some, a seat made of udumbara (The glamorous fig tree). And some exclaimed, ‘ Svasti ’; and some joyfully cried, “May you be long-lived!” And all those ascetics of truthful speech conferred on them blessings.\n\nThe sages said—Wonderful is the story! And, O you accomplished in all kinds of music! beautifully have you chanted and finished this poem, charming ear and heart, and conferring long life and prosperity, which will afford themes to poets.\n\nAnd admired everywhere, on one occasion those singers were seen by Bharata ’s elder brother, in a street of Ayodhyā , sparsely scattered with stalls. And having had the brothers Kuśi and Lava brought under his roof, that destroyer of enemies, Rāma, accorded those ones worthy of honour, a respectful reception. And having seated himself on a throne of excellent gold, in the midst of his brothers and counsellors, that lord, Rāma, beholding both the brothers, handsome and of modest demeanour, spoke to Lakṣmaṇa , Bharata and Śatrughna , saying, Do you listen to the story, fraught with excellent sense and composed in excellent measure, as sung by these ones endowed with the divine afflatus. And then he ordered the singers to begin.\n\nThereupon causing the down of the audience to stand on end, and ravishing their minds and hearts, they began to sing melodiously and distinctly and in as high a pitch as they could command, and in strains rivalling the notes of a Vīṇā . And that song of their enchanted the ear of that assembly.\n\nRāma said, Although these Kuśa and Lava, of rigid penances, look like ascetics, yet they bear on their persons the signs of royalty. And, besides, the story conduces to my fame. Do you, therefore, listen to that history fraught with great worth!\n\nAnd then commanded by Rāma, they began to chant according to the Mārga mode, and Rāma seated in the midst of his court, was drawn to the music, anxious for the perpetuation of his history.
6	1	6	Chapter VI	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365874.html	In that city of Ayodhyā resided king Daśaratha , versed in the Vedas , commanding all resources, far-sighted, of mighty prowess, dear to the inhabitants both rural and urban.\n\nHe was an Athiratha in the Ikṣvāku line, performing sacrifices, engaged in the performance of duties, self-controlled like a Maharṣi , a royal saint famed in the three worlds.\n\nHe possessed of strength, the destroyer of foes, having friends, of subdued senses, comparable to Śakra and Vaiśravaṇa by virtue of accumulated riches and other possessions.\n\nAs the highly-powerful Manu protected the people, Daśaratha did the same.\n\nAs Indra rules Amarāvatī , that one firm in promise, and following duty, profit, and pleasure, ruled that best of cities.\n\nIn that excellent city, the men were happy and righteous-souled, and widely-read, and each contented with his possessions, and devoid of covetousness, and speaking the truth.\n\nIn that prime of cities, there was none who had not at his command a plenteous supply of the good things, and there was no householder who was not well off in horses and kine, and com and wealth.\n\nAnd one could see nowhere in Ayodhyā persons given up to lust, or unsightly, or crooked-minded, or unlettered, or atheistical.\n\nAnd all the men and all the women were of excellent character, and subdued senses, and a happy frame of mind, and both on respect of occupation and conduct spotless like to the Maharṣis .\n\nAnd all wore ear-rings and tiaras and garlands, and abundantly enjoyed the good things of life. And all were clean, daubing their limbs, and perfuming their persons.\n\nAnd feeding on pure food, and giving away, and wearing Aṅgadas (A bracelet worn upon the upper arm) and Niṣkas (An ornament for the breast or neck.) and hand-omaments, and repressing passions.\n\nThere were not on Ayodhyā persons not lighting the sacrificial fire, or not performing sacrifices, or mean-minded, or thieving, or engaged in improper occupations, or of impure descent.\n\nThe Brāhmaṇas of subdued senses were always engaged in the performance of their own duties, giving away in charity, and studying, and receiving gifts with discrimination.\n\nNone of them was atheistical or untruthful or be reft of hearing scriptures or detracting or incompetent or illiterate.\n\nThere was no Brāhmaṇa who was not versed in the Vedas and Vedāṅgas , or poor-spiriṭ or of insane miad, or afflicted.\n\nAnd no man and no woman was seen devoid of grace or beauty, or lacking in reverence for their monarch.\n\nThe four orders with Brāhmaṇas at their head contained persons serving gods and guests, and endowed with gratitude, and munificent, and heroic, and possessing prowess.\n\nAnd the men were long-lived; and ever abode by duty and truth; and lived in that best of cities, always surrounded by sons and grandsons and wives.\n\nThe Kṣatriyas were obedient to the Brāhmaṇas, and the Vaiśyas followed the Kṣatriyas, and the Śūdras , occupied with their proper vocations, ministered to the three other orders.\n\nThat city was ably governed by Daśaratha that lord of Ikṣvāku’s line, even as that foremost of men, the intelligent Manu, had governed it before him.\n\nAnd as a mountain-cavern abounds with lions, it Was filled with warriors resembling flaming fire, of straight ways, unforbearing, and of accomplished learning.\n\nAnd the city abounded with excellent horses sprung in Kāmboja , and Vāhlika , and Vanāyu , and the banks of the Sindhu , and like to that best of horses, Hari ’s charger.\n\nWith fierce elephants spruhg on the Vindhya mountain, and the Himavat , filled with juice, and of exceeding strength, and resembling hills.\n\nAnd with Bhadra , Mandra , and Mṛga [1] elephants; and those sprung from the mixture of the three, and from the mixture of Bhadra and Mandra, and from Bhadra and Mṛga, and from Mṛga and Mandra, superior like to Airāvata , and coming from Mahāpadma , Añjanā , and Vāmana breeds; fierce, and looking like hills. And that city was over two Yojanas ; and truly it was called Ayodhyā. (incapable of being conquered.)\n\nRepressing enemies, that city was governed by the great and the exceedingly. And that lord of earth resembling Śakra governed that city of Ayodhya bearing a true name furnished with strong gates and bolts, and auspicious, and graced with excellent edifices, and teeming with thousands.\n\n[back to top]\n\n[1] :\n\n(Those elephants whose limbs are contracted are bhadras ; those whose bodies are fat, slack, and contracted are Mandras : and those whose bodies are lean and large are Mṛgas .)
7	1	7	Chapter VII	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365875.html	That high-souled one of Ikṣvāku ’s line had competent counsellors, capable of administering business, of diving into the motives of others, and ever intent upon the good of the monarch. And that heroic king had eight famous counsellors, pure and devoted to the royal service.\n\nThey were, Dhṛṣṭi , Jayanta , and Vijaya , and Surāṣṭra , and Rāṣṭravardhana , and Akopa and Dharmapāla , and Sumantra the eight, conversant with profit.\n\nAnd he had two family priests beloved to him; viz. those foremost of saints. Vasiṣṭha and Vāmadeva .\n\nAnd he had other counsellors besides, viz; Suyajña , and Jāvālī, and Kāśyapa , and Gautama , and the long-lived Markaṇḍeya, and the regenerate Kātyāyana .\n\nFver associated in counsel with these Brahmarṣis , his priests and counsellors serving the dynasty from father to son, were learned yet modest, and bashful, and conversant with policy, and of subdued-sense, and auspicious, and high-souled, and accomplished in the art of arms, and of high renown, and cautious, and acting according to their word, and possessing energy, forgiveness and fame and ever precluding their speech with a smile, and never committing themselves to a lie either from anger or interest or desire.\n\nAnd they were not unknown to what was done or sought to be done in the midst of their own or a hostile party. And they were adept in intercourse with people, and well-tried in friendship by the monarch.\n\nAnd they were ever busy in replenishing the exchequer and in levying troops. And they did not cherish ill will even towards enemies, when innocent.\n\nAnd they were heroic, and ever high-spirited, following policy, and protecting those citizens that were pure.\n\nAnd not bearing ill will towards Brāhmaṇas and Kṣatriyas , and filling the treasury, by inflicting punishments according to the offences of the persons guilty.\n\nAnd during the time when those pure ones of one mind presided over the justice of the kingdom, there was neither in the city nor the provinces any that was a liar, or wicked, or going after others’ wives. And peace reigned all around the city and the provinces.\n\nAnd the ministers wore excellent raiment, aṇd ornaments, and were engaged in observing pure vows, and ever kept their eye of policy open in the interest of the monarch.\n\nAnd the king considered them as crowned with virtues; and they were famed on account of their prowess, concluding unerringly in consequence of their intelligence of other countries. And in all climes and times they could manifest their noble qualities.\n\nThey inculcated noble qualities in all aspects and were not devoid of virtues. And they were cognizant of war and peace, and possessed of goodness, passion and ignorance.\n\nAnd they could keep their counsel and judge of things finely, and were well-versed in the art of policy, and ever fair-spoken.\n\nSurrounded by such counsellors endowed with various qualities, the faultless king Daśaratha ruled the earth.\n\nAnd gathering intelligence by means of spies, and righteously protecting the subjects, and preserving the people, and not sacrificing his duties.\n\nFamed over the three worlds , and munificent, and firm in promise in battle, the tiger among men ruled over this earth.\n\nNor did he ever meet with a foe that was either his equal or superior. And possessed of friends, and having obedient commanders, and extricating his thorns by his might, that king ruled the earth, even as the lord of celestials rules heaven.\n\nAnd surrounded by those counsellors studious of his welfare, and bearing affection towards him, and clever, and competent, that king, by virtue of his prowess in subduing others, resembled the sun surrounded by his rays.
9	1	9	Chapter IX	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365877.html	Hearing all about it, the king’s charioteer addressed the monarch in private, saying, Do you listen to what is related in the Purāṇas , and to what I have heard myself!\n\nThis horse-sacrifice is enjoined by the family priests; and I have myself heard the following story celebrated in ancient chronicle. And what the worshipful Sanatkumāra had said formerly in the presence of the saints, applies, O king, to the case of your having a son.\n\nKaśyapa has a son known by the name of Vibhāṇḍaka. He will get a son called Ṛṣyaśṛṅga . And he will grow up and pass his days in the forests.\n\nAnd that foremost of Brāhmaṇas will not know anything else save following his father. And, O king, it is rumoured abroad, and also always said by the Vipras , that the high-souled one will practise (Those that assume the staff and the kamaṇḍalu are reckoned the first order; while those that continue to live with their wives are considered as next in worth.) the two modes of Brahmacarya life.\n\nAnd he spent some time in serving the sacrificial fire and his famous sire. At this time, the powerful Romapāda of exceeding strength will be famed as king of the Aṅgas . And in consequence of some default on his part, there will occur in his kingdom a terrible and dreadful drought, capable of striking terror in the all.\n\nAnd filled with grief on account of this drought, the king will call about him Veda -accomplished Brāhmaṇas, and speak to them, saying, You are conversant with the Vedic ritual and the social duties. Do therefore, tell me how to expiate for this evil\n\nThus accosted by the king, those excellent Brāhmaṇas versed in the Vedas , will say to the ruler of earth.\n\nDo you, O monarch, by all means, bring Vibhāṇḍaka’s son. And having, O king, brought that Brāhmaṇa versed in the Vedas, Vibhāṇḍaka’s son Ṛṣyaśṛṅga, and duly honoured him, do you, O monarch, with a concentrated mind, perform the betrothal of your daughter Śāntā , with him according to the ordinance.\n\nAnd hearing those words of theirs, the king will began to think as to how he can bring over that one endowed with energy.\n\nThen in consultation with his counsellors, the prudent king having come to a conclusion will, honouring them duly, desire his priest and his courtiers to set out in quest of Ṛṣyaśṛṅga.\n\nThereupon hearing the king’s words, with aggrieved hearts, and wiṃ heads hanging down, they will beseech the monarch, saying, Afraid of the saint, Vibhāṇḍaka, we shall not be able to repair thither.\n\nAnon hitting upon the appropriate means, they say, ‘We will search for the Vipra , and no blame shall accrue to us.’\n\nThus by help of courtesans, the saint’s son was brought by the lord of the Aṅgas. And then the god ( Indra ) poured down showers; and the king conferred on him Śāntā.\n\nAnd now your son-in-law Ṛṣyaśṛṅga will help you in obtaining a son. Now I have related to you what Sanatkumāra had communicated.\n\nThereupon king Daśaratha , well pleased, asked Sumantra , Do you now tell me by what means Ṛṣyaśṛṅga was brought over (by the lord of the Aṅgas).
8	1	8	Chapter VIII	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365876.html	And although engaged in austerities with the view of having sons born to him, the powerful and high-souled king, had no son capable of perpetuating his race.\n\nMentally turning the matter over, the high-souled one thought, Why do I not celebrate a horse-sacrifice with the intention of obtaining a son?\n\nThat highly-energetic, pious and intelligent monarch, in consultation with all his counsellors of sedate minds, having made up his mind to celebrate the sacrifice, said to that best of counsellors, Sumantra ,—Do you speedily summon my spiritual guides, along with the family priests.\n\nThereupon, going out speeding, Sumantra of swift movements called together all the spiritual guides, as well as others versed in the Vedic ritual .\n\nThey were Suyajña , and Vāmadeva , and Jābāli , and Kaśyapa , and Vasiṣṭha , and other principal twice-born ones. And having paid homage to them, the virtuous king Daśaratha then spoke to them these sweet words.\n\nConsistent with duty and interest,—Ever pining on account of a son, I know no happiness,—therefore it is my intention that I should celebrate a horse sacrifice.\n\nI intend to celebrate it according to the ordinance. Do you, therefore, consider how I may attain my object.\n\nThereat, the Brāhmaṇas with Vasiṣṭha at their head, exclaiming well! Well I approved the words that had fallen from the lips of the monarch.\n\nAnd exceedingly pleased, they asked Daśaratha,—“Do you order the necessary articles, loose the horse, and prepare the sacrificial ground on the north bank of the Sarayū ." And, O king, since with the intention of obtaining offspring your purpose so piously, you will surely obtain sons after your heart.\n\nAnd hearing these words of the regenerate ones, the king was highly gratified. And with eyes expanded in delight, he asked his ministers, Do to procure the necessary sacrificial articles, according to the injunction of my spiritual preceptors; and loose a horse protected by a competent person, and followed by one of the chief family priests; and prepare the sacrificial ground on the north bank of the Sarayū; and in due order and according to the ordinance perform the śānti rites required to secure an uninterrupted completion to the ceremony. This ceremony is incapable of being celebrated by every king. Particular care should be taken that the sacrifice is not defective on account of any serious omission; inasmuch as with learned Brahma-Rākṣasas ever on the look-out to spy shortcomings in the ceremony.\n\nThe performer thereof speedily perishes, should anything take place not consonant to the ordinance. And do you possessed of ability so arrange, that this sacrifice may be completed in harmony with the ritual.\n\nThus addressed With due respect, the counsellors listened to the word of the monarch, and said, So be it.\n\nThen hearing those words of that best king again, as heard before, conversant with their duty, having blessed the monarch, taking permission of the king, they returned to their respective quarters.\n\nDismissing those Brāhmaṇas, the king spoke to his ministers, saying, Do you, even as the family priests have ordered, arrange for the sacrifice!\n\nHaving said this, that mighty-minded tiger among men dismissed his ministers, and himself entered into the inner apartment.\n\nAnd coming there, that lord of men said to his favourite wives, Do you know it for certain that in order to obtain a son I am going to perform a sacrifice.\n\nAnd hearing those sweet words, the countenances of those shining dames looked resplendent, like lotuses after the cold season is over.
10	1	10	Chapter X	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365878.html	Thus asked by the king, Sumantra said these words—I will relate to you how the counsellors brought Ṛṣyaśṛṅga . Do you listen with your counsellors!\n\nThe priest together with the counsellors spoke to Romapāda , saying,\n\n“The means that we have hit upon can never fail of effect.’\n\nṚṣyaśṛṅga has been brought up in woods; and is engaged in austerities and the study of the Vedas . He is ignorant of the pleasure that ensues from contact with women.\n\nBy help of things agreeably ministering to the sense, and ravishing the soul, we shall bring him to the city. Do you, therefore, arrange for them!\n\nLet courtezans of comely presence, clad in ornaments, repair thither. And if well treated, they will by various means bring him here.“\n\nHearing this, the king said to the priest, “So be it!” Then the priest and courtiers acted accordingly.\n\nIn accordance with the instructions, the courtezans entered that great forest; and remaining at some distance from the hermitage, endeavoured to meet with the sober son of the saint ever dwelling in the woods. And satisfied with serving his sire, he never strayed from the hermitage.\n\nSince his birth he had never before seen men and women, or any other creatures living in cities and towns.\n\nIt came to pass that on one occasion, walking about at will, Vibhāṇḍaka’s son came to that spot and beheld the courtezans.\n\nColourfully attired, and singing sweet songs, the women came to the saint’s son and said,\n\n“Who are you? And where are you going, O Brahman ? We wish to learn all this. And why is it that you range alone this far-off forest?\n\nBeholding these beautiful damsels never seen before, he from delight, hastened to inform them of his lineage.\n\nMy father is Vibhāṇḍaka; and I am his son. My name is Ṛṣyaśṛṅga and my occupation is known the world over.\n\nThis auspicious hermitage hard by belongs to us; and there I shall receive you all in due form O' lovely ones!.”\n\nHearing the words of the saint’s son, they all consented, and the women went to behold that asylum.\n\nWhen they had come there, the saint’s son received them hospitably, saying, “Here is Arghya ,” “Here is water for washing the feet,” “Here are fruits and roots.”\n\nAnd thereupon they readily received his hospitality. And actuated by the fear of the saint, Vibhāṇḍaka, they bent their minds upon departing soon.\n\nThey said, Do you also, O twice-born one, receive from us these excellent fruits! O Vipra ! good betide you, eat them without delay.\n\nThereupon, embracing him joyfully, they gave him sweetmeats and various kinds of savoury viands.\n\nAnd tasting those things, the glorious one took them for fruits, never tasted before by the dwellers of the forest.\n\nThen, having accosted him the women, feigning the observance of some vow, went away, inspired with the fear of his father.\n\nAnd when they had gone, that twice-born one, Kaśyapa ’s son, became sad, and suffered from grief of heart and became restless due to sadness.\n\nAnd the next day his mind momentarily running upon it, the graceful son of Vibhāṇḍaka, endowed with prowess, came to that spot where he had encountered the comely courtesans, adorned with ornaments.\n\nAs soon as they observed him coming, they came forward, and said, Do you, O Brāhmaṇa , come into our hermitage.\n\nThere are in that asylum diverse kinds of fruits and roots; and there you will surely feed your fill.\n\nThereupon hearing those words of theirs capable of influencing the heart, he became bent upon going, and the women brought him away.\n\nWhen that great-souled Vipra had been brought over, the god, Indra , suddenly poured forth plenteous showers, enlivening the spirits of men.\n\nWhen the ascetic had arrived, with showers, the king approached him in bumble guise, bending his head to the ground.\n\nAnd taking him into the inner apartments, and in due form conferring upon him in sober mood his daughter Śāntā , the king became happy.\n\nThus the highly powerful Ṛṣyaśṛṅga together with his wife Śāntā, began to live there, respectfully ministered to in regard to every desire.
11	1	11	Chapter XI	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365879.html	And he said again, O foremost of monarchs, do you listen to me as I relate how that intelligent Sanatkumāra , best of deities, spoke.\n\nIn the line of Ikṣvāku will be born a righteous king, named Daśaratha , fair of form, and firm in promise.\n\nThat king will contract friendship with the ruler of the Aṅgas . And the latter will have a highly pious daughter, Śāntā by name. And the (old) king of the Aṅgas will have a son, named Romapāda . And repairing to him, the highly famous king Daśaratha will speak to Romapāda, O righteous-souled one! I am without issue. Let Śāntā’s husband, desired by you, take charge of this sacrifice of mine, to be celebrated with the object of my obtaining a son to perpetuate the race.\n\nHearing these words of the king, and having pondered well, he will make over to him Ṛṣyaśṛṅga of subdued senses, together with Śāntā and his children.\n\nAnd taking that Vipra , that king, his mind free from anxiety, with a glad heart, will prepare for that sacrifice.\n\nAnd king Daśaratha, knowing duty and desirous of fame, with the intention of obtaining offspring and heaven, with folded hands, will appoint that best of Brāhmaṇas , Ṛṣyaśṛṅga, to conduct the ceremony. And that bringer of good will attain his object at the hands of that foremost of Brāhmaṇas.\n\nAnd four sons will be born to him of immeasurable prowess, bringing fame to the family, and known by all. Thus spoke formerly in the divine age, that worshipful and foremost of deities, Sanatkumāra.\n\nTherefore, do you, O tiger among men, repairing there, accompanied with your forces and equipage, yourself, O mighty king, bring Ṛṣyaśṛṅga over with due honours.\n\nHearing Sumantra ’s words, Daśaratha was exceedingly delighted. And hearing these words, and permitted by Vasiṣṭha , he, accompanied with the ladies, and his courtiers, set out for the place where that twice-born one was.\n\nAnd gradually passing by woods and fells, he arrived at the place where that foremost of ascetics was.\n\nAnd coming before that best of regenerate ones, he saw that sage’s son near Romapāda, like that of a flaming, fire.\n\nThen the king received him respectfully, and with a delighted mind, on account of the friendship he bore him. He communicated to the intelligent son of the saint, the fact of their intimacy, and then the latter paid homage to Daśaratha.\n\nHaving passed seven or eight days with Romapāda, receiving high honours, that foremost of men, Daśaratha spoke to Romapāda, saying, Let your daughter, O king, together with her husbaṇd, O lord of men, repair to my city. I am going to be engaged in a mighty enterprise.\n\nHearing this as to the journey of that intelligent one, the king said to that Vipra, Do you repair with your wife! Thereupon the saint’s son, promising to go, said to the king, So be it!\n\nThen with the king’s permission, he set out with his wife. Daśaratha and the puissant Romapāḍa clasping each other by the palm, and embracing each other in affection, attained excess, of joy. Then Raghu ’s son, bidding farewell to his friend, set out.\n\nHe despatched swift messengers to the citizens, saying, Let the entire city be embellished; let it be perfumed with dhūpa , and watered and decked with pennons.\n\nHearing of the king’s approach, the citizens joyfully did every thing as per message they had been communicated.\n\nThen the monarch, preceded by the foremost of Brāhmaṇas before him, entered the decorated city, to the blares of conches and drums.\n\nAnd beholding that Brāhmaṇa entering the city, duly honoured by the prime of men; subservient to Indra , like to Kaśyapa ’s son entering the celestial regions honoured of the thousand eyed lord of the celestials, all the citizens rejoiced exceedingly.\n\nThen taking him into the inner apartment, and paying him homage according to the ordinance, the king considered himself as having gained his object, in consequence or the presence ot that Brāhmaṇa.\n\nAnd all the inmates of the inner apartment, seeing the large-eyed Śāntā thus arrived with her husband, experienced excess of joy.\n\nThen honoured by them and the king in especial, she happily spent there some time along with that twice-born one.
13	1	13	Chapter XIII	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365881.html	When after a full one year, spring had again appeared on the face of the earth, the puissant king, intent upon getting offspring through the horse-sacrifice, sough Vasiṣṭha ’s side.\n\nHaving saluted Vasiṣṭha and duly paid him homage, he humbly spoke to that best of twice-born ones, with the intention of having offspring.\n\nO Brahman , undertake to perform this sacrifice of mine, according to the ordinance, O foremost of ascetics! do you order so that no impediment may happen to the sacrifice!\n\nYou are my kind friend, and prime and mighty spiritual guide. Engaged in it, you will have to bear the entire burden of the ceremony.\n\nThereupon that best of Brāhmaṇas said to the king, So be it! I will do all that you asked.\n\nHe then said to the old Brāhmaṇas well-up in sacrificial affairs, and experienced car-makers, and highly pious aged people, and servants, carrying on the ceremonial operations till the end, and artists, and carpenters, and diggers, and astrologers, and artizans, and dancers, and conductors of theatres, and pure and learned persons variously versed in knowledge, Do you, in obedience to the royal mandate, engage in the sacrificial work!\n\nAnd fetch bricks by thousands. And do raise structures for the kings, commanding every convenience.\n\nDo you rear goodly and comfortable buildings by hundreds for the Brāhmaṇas, replenished with various meats and drinks.\n\nYou should provide spacious apartments for the citizens and the dwellers, of provinces, and separate quarters for the princes, coming from foreign parts. And stables and sleeping apartments be raised for warriors coming from foreign countries.\n\nAnd dwellings filled with diverse kinds of viands, and commanding everything desirable, and mansions for the lower orders of the citizens, exceedingly beautiful to behold. And meats should be duly dispensed with all hospitality, and not in the indifference of festive occasions, so that all may regard themselves as honourably entertained. And none should be disregarded out of lust or passion.\n\nThose persons, and artizans, that will labour eagerly in the sacrifice, should by turns, be especially entertained.\n\nAnd servants, who being entertained with gifts, do every thing completely, and omit nothing. And do you, with hearts mollified by love, act so, that all our friends be well pleased with us.\n\nThen they approached Vasiṣṭha, saying, Everything has been performed properly, without anything being left out. And what you say shall be performed, and nothing words, Do you invite all those kings that are pious, and Brāhmaṇas, and Kṣatriyas and Śūdras , by thousands. And do you with due honours bring people from all countries.\n\nWith proper honour yourself bring the righteous, truthful, and heroic Janaka , lord of Mithilā . And it is because he is our old friend that I first mention him.\n\nThen do yourself bring the amiable and ever fair-spoken lord of Kāśī , of excellent character, resembling a celestial.\n\nThen do you bring here along with his son, the highly-pious, old king of Kekaya , who is the father-in-law of this tiger of a monarch.\n\nThen also bring with due honours the king of Aṅga , and that mighty archer, the illustrious Romapāda , the friend of that lion among the kings, along with his son.\n\nAlso bring with due respect the puissant king of Kosala . The heroic, and highly generous lord of Magadha , versed in all branches of learning. And in accordance with the mandate of the king, do invite the foremost monarchs! And summon the king, of the East, of the Sindhu and Sauvīra countries, and of Saurāṣṭra , and of the South! And speedily bring those monarchs that are attached to us, together with their friends and followers, the mandate of the monarch, bring over these, despatching dignified emissaries.\n\nHaving heard those words of Vasiṣtha, Sumantra speedily ordered the emissaries to bring the kings.\n\nThe virthous Sumantra, in accordance with the injunction of the ascetic, himself speedily set out for the purpose of bringing the monarchs.\n\nThen the servants came and informed the intelligent Vasiṣtha as to the articles that had been got ready for the sacrifice.\n\nThen well pleased that best of twice-born ones, the ascetic Vasiṣṭha, said to them, Do not give away disrespectfully or lightly. A gift bestowed with disrespect, indubitably destroy the giver.\n\nThen for several days, kings began to pour into Daśaratha ’s city daily and nightly, bringing with them various kinds of gems.\n\nThereupon Vasiṣṭha well-pleased said to the king, O tiger among men, obeying your mandate the kings have come here; and I too according to merit, have received those excellent kings with respect.\n\nEverything has been carefully made ready for the sacrifice by the persons concerned. Do you, therefore, repair to the sacrificial ground, for performing the sacrifice.\n\nO foremost of monarchs, it behove you to view the place, filled with all desirable objects, and looking as if prepared by imagination herself.\n\nThen in accordance with the injunctions of both Vasiṣṭha and Ṛṣyaśṛṅga , the king came to the sacrificial spot on a day presided over by an auspicious star.\n\nThen, with, Ṛṣyaśṛṅga at their head, Vasiṣṭha and the other principal Brāhmaṇas wending to me sacrificial ground, began the ceremony, according to the ordinance; and in due form. And the auspicious king, in company with his wives, was initiated into the ceremony.
14	1	14	Chapter XIV	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365882.html	After the expiry of full one year, when the sacrificial horse had returned, the sacrifice, of the king commenced on the north bank of the Sarayū .\n\nAnd with Ṛṣyaśṛṅga at their head, the principal twice-born ones began the proceedings in that mighty horse-sacrifice of that high-souled monarch.\n\nAnd the priests, each duly and according to the ordinance performing his proper part, engaged in the ceremony in consonance with the scriptures.\n\nAnd the regenerate ones, having performed the pravargya as well as the upasada according to the ordinance, duly completed the additional ceremonies. Then, worshipping the deities with glad hearts, those foremost of ascetics duly performed the morning ablutions and the other prescribed rites.\n\nThe oblations of clarified butter first having been offered to Indra , according to the ritual, the king with a purified heart performed his ablutions. And then the mid-day ablutions took place in proper sequence.\n\nThose foremost of Brāhmaṇas , in due form, and according to the ordinance, officiated at the third bath of that high-souled monarch.\n\nThe priests presided over by Ṛṣyaśṛṅga, invoked Śakra and the other deities, reciting measured mantras .\n\nThe sacrificial priests, chanting sweet Samans and soft mantras , duly invoking the dwellers of the celestial regions, offered each his share of the oblations.\n\nAnd no part of the ceremony was performed improperly, or left out, and every thing was satisfactorily celebrated with mantras .\n\nAnd on that day no Brāhmaṇa ever felt tired, or hungry and there was none that was not learned, or that was not followed by an hundred persons.\n\nBrāhmaṇas, and Śūdras having among them ascetics, and Śramaṇas , and the aged, and the infirm, and women, and children, were continually fed. And although they ate their fill, yet they know no repletion.\n\nAnd Give food, and clothes of various kinds (was heard all around) And those employed in the task gave away profusely.\n\nAnd every day food dressed properly in due form was to be seen in countless heaps resembling hills.\n\nAnd men and women coming from various countries to the sacrifice of that high-souled one were excellently entertained with meats and drinks.\n\nThe foremost regenerate ones said, The viands have been prepared in the prescribed form, and they taste excellent. We have been gratified. God bless you! All this was heard by the descendant of Raghu .\n\nPersons adorned with ornaments distributed the victuals among the Brāhmaṇas, and they were assisted by others wearing jewelled pendants.\n\nIn the interval between the completion of one bath and the beginning of the next, mild and eloquent Vipras , desirous of victory, engaged in various disputations.\n\nEvery day in that sacrifice, skilful Brāhmaṇas, engaged in the ceremony, did every thing, according to the ritual.\n\nThere was no twice-born one that was not versed in the Vedas and the Vedāṅgas , or that did not observe vows, or that was not profoundly learned, nor did any assist at the sacrifice that could not argue ably.\n\nAnd when the time came for planting the Yūpas of bilva , as many of catechu, and as many of Palasa , and one of Śleṣmātaka , and two of Devadāru well-made and measuring two outstretched arms.\n\nPersons versed in the arts and science of sacrifice constructed these Yūpas . And at the time of throwing up the Yūpas for embellishing the sacrifice, these one and twenty Yūpas , each measuring one and twenty Aratnis , having eight angles, and smooth-faced, were decked out in one and twenty pieces of cloth, and were firmly planted with due ceremonies by artisans.\n\nAnd being wrapped up in cloths, and worshipped with flowers, they looked like the seven Ṛṣis appearing in the welkin.\n\nAnd an adequate number of bricks was also duly made (for the ceremony.) And Brāhmaṇas accomplished in the arts constructed the sacrificial fire-place with those bricks.\n\nThat fire-place of that lion among kings, set by skilful Brāhmaṇas, consisting on three sides of eighteen bricks, looked like the goldenwinged Garuḍa . And for the purpose of sacrificing them to the respective deities were collect beasts and reptiles, and birds, and horses, and aquatic animals. And the priests sacrificed all these in proper form.\n\nAnd to these Yūpas were bound, three hundred beasts, as well as the foremost of the best horses belonging to king Daśaratha .\n\nThen Kausalyā , having performed the preliminary rites, with three strokes slew that horse, experiencing great glee.\n\nAnd with the view of reaping merit, Kausalyā, with an undisturbed heart passed one night with that horse furnished with wings.\n\nHotas and Adhvaryus , and the Udgatās joined the king’s Vāvātā along with his Mahiṣī and Parivṛtti .* And priests of subdued senses, well-up in sacrificial rites, began to offer oblations with the fat of the winged-horse, according to the ordinance.\n\n*The Kṣatriya kings could marry wives from among Ksatriyas , Vaiśyas and Śūdras. The Kṣatriya wife is called Mahiṣī , the Vaiśya wife Vāvātā and the Śūdra wife Parivṛtti .\n\nThe lord of men, desirous of removing his sins, at the proper time smelt the odour of the smoke arising from the fat, agreeably to the scriptures.\n\nThen sixteen sacrificial priests in the prescribed form offered the various parts of the horse to the fire.\n\nIt is customary in other sacrifices to offer the oblations by means of a Plakṣa bough; but in the horse-sacrifice a cane is used instead. The horse-sacrifice, according to the Kalpa-Sūtras and the Brāhmaṇas, extend over three days. Thereafter, on the first day was the Catuṣṭoma celebrated; and on the second, the Uktha , and on the third the Atirātra .\n\nAnd then the jyotiṣṭoma , and then Āyuṣtoma , and the Atirātra , and the Abhijit , and the Viśvajit , and the Āptoryāma , all these various great sacrifices were celebrated with due rites.\n\nAnd in this mighty horse-sacrifice founded of yore by Svayambhū , that perpetuator of his line, the king, bestowed the Eastern quarter on his chief sacrificial priest, the Western on his Adhvaryu , the Southern on Brahmā , and the Northern on the Udgātā , as Dakṣiṇās .\n\nHaving completed that sacrifice, that perpetuator of his race, and foremost of men, the king, conferred on the priests the earth; and having conferred it, that auspicious descendant of Ikṣvāku experienced high delight. And then the priests spoke to that monarch, who had all his sins purged off saying.\n\nYou alone are worthy to protect the entire world. We do not want the earth; nor can we rule it, being, O lord of Earth, constantly engaged in Vedic studies. Do you, therefore, confer upon us something instead, as the price thereof.\n\nDo you confer upon us gems, or gold, or kine, or anything else, for, O foremost of monarchs, we do not want earth.\n\nThus addressed by the Brāhmaṇas versed in the Veda , that best of kings bestowed upon them ten lace of kine, and ten Koṭis of gold, and forty of silver.\n\nThen those priests in a body, accepting the wealth, brought it to the ascetic Ṛṣyaśṛṅga and the intelligent Vasiṣṭha . Then having received each his share, those foremost of regenerate ones were exceedingly pleased, and said, We have been highly gratified.\n\nThen to those Brāhmaṇas that had come there, the king with due regard gave Koṭis of gold.\n\nThen to a certain poor twice-born one that asked for gifts, the descendant of Raghu gave an excellent ornament from his own arm.\n\nWhen the regenerate ones were thus properly gratified, that one cherishing the Brāhmaṇas, with senses intoxicated by excess of joy, reverentially bowed to them.\n\nThereupon the Brāhmaṇas uttered various blessings upon that generous king, bending low to the earth.\n\nThen having celebrated that excellent and sin-destroying sacrifice, bringing heaven, and incapable of being celebrated by foremost monarchs, king Daśaratha, well pleased, spoke to Ṛṣyaśṛṅga, saying, O you of excellent vows, it behove you to do that whereby my line may increase.\n\nThereupon the best of Brāhmaṇas told the king that he would have four sons, born to him, as perpetuators of his race.\n\nHearing these sweet words of his, that foremost of monarchs bended low to him with controlled faculties, and experienced the excess of joy. And then that high-souled one again spoke to Ṛṣyaśṛṅga.
15	1	15	Chapter XV	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365883.html	Then that one of capacious intelligence, versed in the Vedas , having pondered for a time, and regained his senses, returned to the king this excellent answer.\n\nOn your behalf and with the view of obtaining sons for you, I will by help of mantras laid down in the Atharva Veda , duly celebrate the famous ceremony, capable of crowning you with offspring.\n\nThen with the view of obtaining sons (for the king,) that effulgent one set about the son-conferring ceremony; and in accordance with the ordinance, and with mantras , offered oblations to the sacrificial fire.\n\nAnd the deities, with the Gandharvas , and the Siddhas , and the principal saints, assembled there duly with the object of each obtaining his share of the offerings.\n\nAnd having duly assembled there, the deities addressed these words to Brahmā the lord of creatures.\n\nO you possessed of the six attributes, through your grace, a Rākṣasa named Rāvaṇa oppresses us all by his prowess, nor can we baffle him.\n\nO lord, as you have well-pleased conferred on him a boon, we always suffer him in deference to it.\n\nThe wicked-minded one harasses the three worlds furnished with prosperity, and bears ill-will against them and seek O defeat Indra , the king of Tridaśa .\n\nAnd blinded by the boon he has received, that irrepressible one intends to bring down the lord himself of the celestials, and the Yakṣas , and the Gandharvas, and the Brāhmaṇas , and the Asuras .\n\nAnd the Sun does not bum him, or the Wind blow about him; and at sight of him, that one engarlanded with billows, the Ocean, dares not stir.\n\nTherefore, great is the fear that afflict us, coming from that Rākṣasa of dreadful appearance. And, O lord, it behoves you to devise some means for destroying him.\n\nThus addressed by the deities in a body, he said, Alas! I have, however, decided on the means of destroying that wicked-souled one. He had asked, ‘May I be incapable of being slain by Gandharvas, and Yakṣas, and gods, and Rākṣasas !,—whereat I said, ‘Be it so!’\n\nThrough disdain, the Rākṣasa did not at that time mention men. Therefore, by men alone he is capable of being slain; nor can his end be compassed by any other means.\n\nHearing this welcome speech uttered by Brahmā, the deities and the Maharṣis became exceedingly delighted.\n\nAt this juncture, that lord of the universe, the highly-effulgent Viṣṇu , clad in yellow apparel, and bearing in his hands the conch, the discus, and the mace, and adorned with burnished Keyūras , (A bracelet worn on the upper arm.) arrived there, riding Vinatā ’s son; like to the Sun riding the clouds. And worshipped by the foremost of the celestials, he drew near Brahmā, and sat down with a collected mind.\n\nAnd bending low before him, the deities spoke to him saying, O Viṣṇu, for the benefit of the worlds, we shall appoint you to some work.\n\nDo you, O lord, dividing yourself into four, O Viṣṇu, become born a sons in the three wives, resembling Modesty, Auspiciousness, and Fame, of Ayodhyā ’s lord, king Daśaratha , cognizant of Duty, and munificent, and possessing energy, and like to a Maharṣi . Do you, O Viṣṇu, becoming man, slay in battle this thorn of the worlds, the pampered Rāvaṇa, incapable of being slain by the gods; for the foolish Rākṣasa by virtue of sublimated prowess, baffles the deities, and the Gandharvas, and the Siddhas, and the foremost of saints.\n\nAnd by him bereft of the sense of right and wrong, have saints and Gandharvas and Apsaras sporting in the groves of Nandana , been wantonly slain.\n\nIt is to compass his death that accompanied by the ascetics, we have come here: it is for this that the Siddhas and the Gandharvas and the Yakṣas have taken refuge in you! O God, you are the prime way of us all, O repressor of foes! Do you, for bringing destruction to the enemies of the gods, turn your thoughts to being born as man.\n\nThus besought, that foremost of gods and chief of celestials, Viṣṇu, worshipped of all creatures, addressed the assembled deities, following Duty, with the grand-sire at their head, saying.\n\nDo you renounce fear! For your behoof, slaying in battle the wily and irrepressible Rāvaṇa, dreadful to the saints and the celestials, together with his sons, and grandsons, and friends, and counsellors, and relatives, and acquaintances, I will abide among mortals, ruling this earth for ten thousand and as many hundred years.\n\nHaving thus conferred a boon upon the gods, the lord Viṣṇu of subdued soul fell to thinking as to the place where he would be born among men.\n\nThen that one of eyes resembling lotus-petals, dividing self into four parts, chose even king Daśaratha for his father.\n\nThereat the celestials and the saints and the Gandharvas and the Rudras and the Apsaras hymned the Slayer of Madhu in excellent hymns.\n\nDo you utterly uproot the haughty Rāvaṇa of fierce prowess and enhanced insolence—that foe of the lord of celestials, who is the occasion of the tears of the three [1]\n\nSlaying that one of terrible prowess, who distresses the three worlds, with his forces and friends, do you, O foremost of gods, your fever of heart removed, repair to the celestial regions protected by you and purged of all its faults and sins.\n\n[back to top]\n\n[1] :\n\nLit. the thorns of pious ascetics.
16	1	16	Chapter XVI	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365884.html	Thus besought by the foremost of the celestials, that searcher of hearts, Viṣṇu , although cognizant of the means whereby Rāvaṇa was to be destroyed, asked the gods these amiable words,—What, you gods, is the means of compassing which I could slay that thorn of the ascetics?\n\nNara means a multitude, and Ayana , dwelling-place. He whose dwelling-place is a multitude, is Nārāyaṇa . Metaphorically, the word means evidently the Scorcher of hearts,—worlds, and dreadful to ascetics!\n\nThus addressed, the deities answered Viṣṇu, incapable of deterioration, saying,—Assuming the form of a human being, do you in battle slay Rāvaṇa!\n\nHe, O repressor of foes, had for a long course of time performed rigid austerities; and thereat, that creator of all, the first-create Brahmā , was well pleased.\n\nAnd propitiated by his penances, the Master conferred a boon on the Rākṣasa to the effect, that, save man, no fear should come to him from the various beings.\n\nAnd in the matter of that boon-bestowing, man had formerly been disregarded (by Rāvaṇa). And puffed up with pride in consequence of the boon he received from the Grand-sire.\n\nHe commits ravages upon the three worlds and carries away the fair sex by violence. Therefore, O subduer of enemies, we have even fixed upon man for bringing about his death.\n\nHearing this speech of the celestials, Viṣṇu of subdued soul chose even king Daśaratha for his father.\n\nAt that time, eagerly wishing to have sons, that destroyer of enemies, the effulgent king Daśaratha, who was sonless, was celebrating the sacrifice that confer male offspring.\n\nThen, having ascertained the course to follow, Viṣṇu, having greeted the Grand-sire, vanished there, worshipped by deities and the Maharṣis .\n\nAnd then himself bearing in his hands a capacious vessel made of burnished gold, with a silver cover, dear like that of a spouse, and resembling the divine Creative energy, filled with celestial Pāyasa , (A preparation of milk, rice, and sugar), from out the sacrificial fire of Daśaratha initiated into the ceremony, there arose a mighty being, of unparalleled prowess, high energy, and huge strength, black, and wearing a crimson apparel, with a red face, uttering the blares of a trumpet, and having a body covered with leonine hair, having whiskers and an excellent head of hair, furnished with auspicious marks, and adorned with celestial ornaments, and resembling a mountain-peak, and bearing the prowess of a flaming tiger, and like to the Sun or tongues of flaming fire. And with his eyes fixed upon Daśaratha.\n\nHe addressed the king, saying, O monarch, take me as a person commissioned by Prajāpati .\n\nHearing him speak thus, Daśaratha, with folded hands, said, Lord, you are welcomed? What can I do for you?\n\nThereupon, that person despatched by Prajāpati again spoke thus, O king, having adored the deities, you have to-day obtained this.\n\nO tiger of a king, accept this excellent and divinely-prepared Pāyasa, conferring sons, health, and affluence, which you are to give to your worthy consorts, saying, Partake it. Through them you will, O monarch, obtain sons, for obtaining whom you have performed this sacrifice.\n\nThereupon, saying, So be it, the lord of men delightedly placed that divinely-bestowed golden vessel filled with the divine Pāyasa upon his head. And having saluted that wonderful being of gracious presence, he in excess of joy began to go round him again and again.\n\nThen Daśaratha, having received that divinely prepared Pāyasa, waxed exceeding glad; like that of a pauper attaining plenty. Then that highly effulgent being of a wonderful form, having performed that mission of his, vanished even there.\n\nAnd Daśaratha’s inner apartment, being graced with the rays of joy, looked like the welkin flooded with the lovely beams of the autumnal moon.\n\nThen entering the inner apartment, he spoke to Kausalyā , saying, Take you this, Pāyasa; for this will make you bear a son.\n\nHaving said this, the king offered to her a half portion of this Pāyasa. Then he conferred upon Sumitrā a fourth of it.\n\nThen in order that she might have a son, king Daśaratha made over to Kaikeyī an equal portion of what remained. And then having reflected, the mighty-minded one gave to Sumitrā the remaining portion of the Pāyasa resembling ambrosia.\n\nThus the king dispensed the Pāyasa to each and all of his wives. And those foremost wives of the king, having received that Pāyasa, became exceedingly delighted, and considered themselves as highly honoured.\n\nThen those excellent consorts of the lord of earth, having separately partaken of that choice Pāyasa, shortly bore offspring, resembling fire or the Sun.\n\nThe king, beholding those wives of his bearing children, obtained his desire and became delighted; even as Viṣṇu, while being worshipped by the Siddhas and the ascetics.
17	1	17	Chapter XVII	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365885.html	When Viṣṇu had accepted the sonship of that high-souled king, the self-create Lord addressed the celestials, saying,\n\nFor assisting the heroic Viṣṇu firm in promise, always seeking the welfare of us all, do you create powerful beings, assuming shapes at will, cognizant of illusions, heroic, furnished with the celerity of the wind, versed in morality, possessing intelligence, like to Viṣṇu in prowess, unslayable, knowing the ways and means (of war and peace), gifted with excellent bodies, capable of resisting all weapons, and resembling immortals.\n\nAnd from forth the bodies of the foremost Apsaras , Gandharvis , Yakṣīs , and Pannagis, Ṛkṣis (She-bears) and Vidhyādharis, Kinnaris and Vānaris (She-monkeys) do you produce sons wearing the shapes of monkeys.\n\nFormerly I had created that foremost of bears, Jāmbavān , who suddenly came out of my mouth as I was yawning.\n\nHearing this mandate of Him possessed of the six attributes, they began to produce sons endowed with monkey’s forms.\n\nAnd high-souled ascetics, and Siddhas , and Vidyādharas , and Uragas , and Cāraṇas , generated heroic sons, rangers of woods.\n\nAnd Indra beget as his son that foremost of monkeys, Vālī , resembling the Mahendra hill, and that best of those imparting heat, the Sun, Sugrīva .\n\nBṛhaspati beget the mighty ape named Tāra , who was the most excellent and intelligent of the prime monkeys.\n\nThe Bestower of riches beget as his son the graceful ape Gandhamādana . And Viśvakarman beget that mighty monkey named Nala .\n\nAgni beget as his son the powerful and graceful Nīla in effulgence like to the fire, who surpassed even his sire in energy, prowess, and renown.\n\nAnd the beautiful Aśvins , endowed with the wealth of loveliness, beget Mainda and Dvivida .\n\nVaruṇa beget the monkey named Suṣeṇa ; and Parjanya beget Śarabha , possessed of great strength.\n\nAnd the Wind-god beget the graceful monkey named Hanumān , endued with a frame hard as adamant; in fleetness like to Vinatā ’s offspring.\n\nAnd the most intelligent as well as the most powerful amongst all the principal monkeys. Thus produced, there suddenly came into being by thousands, mighty bears, and monkeys, and Gopucchas , (Cow-tailed monkeys.) and of immeasurable strength, and heroic, and powerful, assuming shapes at will, endowed with bodies resembling elephants or hills, even those who would engage in compassing the destruction of the Ten-headed Rāvaṇa .\n\nThe sons of the deities retained distinctly the respective hues, forms, and prowess, that characterized their several sires. And those that sprang from the Golāṅgulas , possessed even more than the might of the gods.\n\nLikewise, on Ṛkṣīs and Kinnaris were gladly begot thousands upon thousands of monkeys, by the gods, Maharṣis , Gandharvas , Tārkṣyas , and famous Yakṣas , Nagas , and Kiṃpuruṣas (beings half-man and half-beast) Siddhas, Vidyādharas. and Uragas.\n\nUpon the principal Apsaris , and the Vidyādharis , and the daughters of the Nāgas , and the Gandharvis were begot by the Cāraṇas as sons, heroic monkeys of gigantic bodies, ranging the forests and living on fruits and roots.\n\nAll these monkeys were endowed with strength; and could assume shapeṣ and repair everywhere, at will. And they were like to lions aṇd tigers, both in pride and in prowess. And they fought with crags and hurled hills.\n\nAnd they fought with nails and teeth, and were accomplished in all weapons. And they could move the largest hills; and crush the fixed trees,\n\nWith their impetus, vex that lord of rivers, the Ocean. And they could with their kicks rend the Earth, and swim over the mighty main.\n\nThey could penetrate into the welkin, and capture the clouds. And they could subdue mad elephants ranging the forest.\n\nAnd with their roars, they could bring down birds singing. Thus came into being Koṭis of high-souled leaders of monkey-herds, assuming forms at will.\n\nAnd these became the leaders of the principal monkey-herds; and they, in their turn, generated heroic monkeys, the foremost of the leaders of herds.\n\nSome of these monkeys began to dwell on the top of the Ṛkṣavān mountain; while others inhabited various other mountains and forests.\n\nAil the leaders of monkey-herds stayed with those brothers, Sugrīva, the son of the Sun-god and Vālī, that of Śakra , and also with Nala, and Nīla, and Hanumān, and other leaders of monkey-herds. And endowed with the might of Garuḍa , and accomplished in fight, they ranged around, pounding lions, and tigers, and mighty Uragas.\n\nAnd the mighty-armed Vālī of great prowess and redoubtable strength protected by virtue of the energy of his arms Ṛkṣas , and Gopucchas , and monkeys.\n\nThis earth, furnished with mountains, and forests, and oceans, began to teem with those heroic lords of leaders of monkey-herds, inhabiting different places, bearing characteristic marks, resembling masses of clouds, or mountain-peaks, possessed of mighty strength, and of terrible bodies and visages, in order that they might assist Rāma .
19	1	19	Chapter XIX	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365887.html	Hearing those astonishing words of that lionlike king, the highly-energetic Viśvāmitra with his down standing on end, said.\n\nO tiger of a king, sprung from an illustrious line, and having Vasiṣṭha , for your guide, these words become you alone on earṃ and no one else.\n\nDo you, O tiger of a king, ascertain your course in respect of the matter I bear in my heart; and do you prove firm in promise!\n\nFor celebrating a sacrifice, I, O foremost of men, abide by some prescribed course. And it comes to pass that two Rākṣasas assuming shapes at will, have become bent upon disturbing the ceremony.\n\nAnd in that sacrifice which I have determined to bring to a completion, and which is on the eve of being completed, both these Rākṣasas, Mārīca and Subāhu , accomplished in arms and possessed of prowess, shower flesh and gore upon the altar. And on that ceremony being thus disturbed and by purpose thus frustrated, I considered my labours as all lost, and, therefore, have left my country in dejection. And, O monarch, I cannot bring myself to vent my wrath.\n\nFor such is the nature of that business, that it is not proper for one engaged in it to utter a curse. Therefore, O tiger of a monarch, it behoves you to grant me your eldest son, the heroic Rāma of genuine prowess, with the side-locks.\n\nBy virtue of his own divine energy, he, being protected by me, is capable of even destroying those Rākṣasas disturbing the ceremony. And I will, without doubt, confer upon him manifold blessings, by means of which he will secure the golden opinions of the three worlds. And encountering Rāma, they will by no means be able to stand him, nor is there any other who dares to slay them. And puffed up wiṃ energy, they have become ensnared at the hands of Kāla , ( Yama , the god of death.) and, O tiger of a monarch, they are no match for Rāma.\n\nNor, O king, ought you to indulge in paternal affection. For ten nights only Rāma is to remain there, with the object of slaying those foes to my sacrifice, those Rākṣasas ḍisṃrbing the rites. I tell you, do you consider the Rākṣasas as already slain. I know full well Rāma of sterling prowess, as also the highly-energetic Vasiṣṭha and the other ascetics present here. And if you, O king, set your heart upon acquiring religious merit and high fame on earth, do you then grant me Rāma!\n\nAnd, O Kākutstha , [1] if your counsellors together with the Brāhmaṇas having Vasiṣṭha at their head, consent, do you then dismiss Rāma!\n\nEven this is my wish, and he also has come of age. Do you, therefore, part with your son, the lotus-eyed Rāma, for the ten days of the sacrifice! Do you act so, O descendant of Raghu , that the time appointed for the ceremony may not be overpassed. Good betide you! Let not your mind indulge in grief!\n\nHaving said these words consistent with virtue and interest, the mighty-minded and highly-powerful Viśvāmitra paused.\n\nAnd hearing the auspicious words of Viśvāmitra, that foremost of kings shook with a mighty sorrow, and became bewildered.\n\nThen, having regained his senses, he rose up, and became cast down through apprehension. Having heard the words of the ascetic, capable of rending the mind and heart, the high-souled king of men became stricken with grief and shook on his seat.\n\n[back to top]\n\n[1] :\n\nFrom Kakud , an emblem of royalty, and Stha , residing, meaning a prince, the grandson of Ikṣvāku.
20	1	20	Chapter XX	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365888.html	Hearing the words of Viśvāmitra , that tiger of a monarch remained insensible for a time, and then regaining his senses, spoke thus.\n\nMy lotus-eyed Rāma is not yet turned of sixteen; and I do not perceive his fitness to cope with Rākṣasas in battle.\n\nI am the lord of this Akṣauhiṇī (A complete army consisting of 1,09,350 foot, 65,610 horse, 21,870 chariots, and 21,870 elephants.) of forces. Marching with this, will I engage with the night-rangers.\n\nAnd these servants of mine are Valiant, and warlike, and accomplished in weapons, and capable of fighting the Rākṣasas,—therefore, it behove you not to take Rāma.\n\nAnd myself bow in hand, stationed at the van of the array, will battle with the rangers of the night as long as life is spared to me.\n\nThen well protected, your sacrifice will hold an unimpeded course. Therefore, I will repair thither, and it behoves you not to take Rāma.\n\nYouthful, and unaccomplished, and not knowing what constitutes strength and what not, and not equipped with the science of missiles, and unskilful in fight,\n\nHe is not a match for Rākṣasas,—they being deceitful warriors. Bereft of Rāma, O tiger among ascetics, I cannot live for a moment. Therefore, it behove you not to take him. If, O Brahman , it is your intention to take Rāma, then O you of excellent vows, do you also take me along with the Caturaṅga forces! (An army consisting of foot, horse, elephants, and cars.)\n\nO Kuśika ’s son, I am sixty thousand years old; and (at this age) I have obtained Rāma after undergoing extreme troubles, it therefore, become you not to take Rāma.\n\nAnd among the four sons of mine, I find my highest delight in Rāma, my first-born, and the most virtuous of them all, therefore, it behoves you not to take Rāma.\n\nWhat is the prowess of the Rākṣasas? And whose sons are they? And who, pray are they? And what are the proportions of their bodies? And who protects them O foremost of ascetics? And by what means shall either Rāma, or my forces, or, O Brahman, I myself be able to slay in fight those deceitful warriors—the Rākṣasas? Do you tell me, O adorable one, inflated as they are by virtue of their prowess, how can I stand them in fight?\n\nHearing that speech of his, Viśvāmitra said, There is a Rākṣasa named Rāvaṇa , sprung from the line of Pulastya . Having obtained a boon from Brahmā , he boldly opposes himself to three worlds, being possessed of great strength and prowess, and backed by innumerable Rākṣasas. And, O mighty monarch, I also hear that that lord of the Rākṣasas is the very brother of Vaiśravaṇa and the son of the ascetic Viśravaṇa.\n\nWhen that one possessed of mighty strength does not stoop to disturb the sacrifice himself, those powerful Rākṣasas, Mārīca and Subāhu , being incited by him, disturb the rites.\n\nThe ascetic having spoken thus, the king then answered him, I am incapable of standing that wicked-souled one in fight.\n\nTherefore, do you, O you versed in morality, extend your favour to my son! Of slender fortune as I am, you are my guide and my god.\n\nEven the celestials and the Dānavas and the Gandharvas and the Birds and the Snakes are incapable of bearing Rāvaṇa in battle, what then is man?\n\nO foremost of ascetics, whether you are accompanied with my son or my forces, you will not be able to stand him. And how can I, O Brāhmaṇa , make over to you my son, of tender years, resembling an immortal, who is ignorant of warfare? I will not part with my son.\n\nThe sons of Sunda and Upasunda resemble Kāla himself in battle, and it is they who are disturbing your sacrifice. Therefore I will not part with my son. And Mārīca and Subāhu are possessed of prowess, and accomplished in weapons.\n\nBut with my friends I will repair to encounter one of them. If you do not consent to this, I beseech you with my friends, (do you desist!)\n\nHearing these words of the lord of men, a mighty ire took possession of that foremost of regenerate ones, Kuśika’s son; and the fire of the Maharṣi ’s wrath flamed up even like to a fire fed by fuel and clarified butter.
21	1	21	Chapter XXI	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365889.html	Hearing those words of Daśaratha ’s composed of letters faltering with affection, Kuśika ’s son, stirred up with anger, answered the monarch, saying,\n\nHaving promised me first, you endeavour to renounce that promise of yours. This surely is unworthy of a descendant of Raghu , and this can bring destruction upon the dynasty.\n\nIf, O king, in acting thus, you have acted properly, I will then repair to the place whence I had come. O Kākutstha ’s descendant false in promise, do you attain happiness, being surrounded by your friends.\n\nAnd when the intelligent Viśvāmitra was exercised with wrath, the entire earth began to tremble, and the gods even were inspired with awe.\n\nAnd knowing that the entire universe was in trepidation, that mighty saint, the sedate Vasiṣṭha of excellent vows, said these words to the king.\n\nBorn in the line of Ikṣvāku , you are the very second self of virtue. And endowed with patience, and auspicious, and observing excellent vows, you ought not to renounce virtue.\n\nThe descendant of Raghu is famed over the three worlds as righteous-souled. Do you maintain your habit of adhering to promise; for it does not behove you to act unrighteously,\n\nIf having promised, I will do so, you do not act up to your word, the merit you have achieved by digging tanks , shall come to naught, therefore do you renounce Rama !\n\nAccomplished or not accomplished in weapons, the Rākṣasas cannot bear him protected by Kuśika’s son, like ambrosia, by flaming fire.\n\nThis one is Virtue incarnate: this one is the foremost of those possessing prowess. This one surpass all others in learning, and is the refuge of asceticism.\n\nThis one is congnizant of all that exist in the three worlds furnished with mobile and immobile things;—but others do not know him,—nor yet shall know him hereafter.\n\nAnd neither the gods, nor the saints, nor the immortals, nor the Rākṣasas, nor the foremost of Gandharvas and Yakṣas , nor the Kinnaras , nor the mighty Serpents can know him.\n\nAnd formerly while the descendant of Kuśika was ruling his kingdom, Śiva conferred upon him the highly famous sons of Kṛśāśva in the shane of all weapons.\n\nThose sons of Kṛśāśva were the offspring of Prajāpati ’s daughters. And they were endowed with various forms, and were effulgent and dreadful.\n\nAnd Dakṣa ’s daughters of elegant waists, Jayā and Suprabhā , brought forth an hundred exceedingly effulgent weapons.\n\nAnd by virtue of her boon, Jayā obtained fifty sons of immeasurable strength and endued with the power of becoming invisible for the purpose of slaughtering the hosts of the Asuras .\n\nSuprabhā also brought forth fifty sons named Sanhāras, incapable of being borne, and infallible and powerful.\n\nKuśika’s son is adequately conversant with all those weapons. And that one knowing duty is also capable of creating wonderful weapons.\n\nO descendant of Raghu, there is nothing present, past, or future which is not known by that foremost of ascetics of high soul, and cognizant of morality.\n\nSuch is the prowess of that highly famous Viśvāmitra possessed of mighty energy. Therefore, O king, it behove you not to hesitate in the matter of Rāma ’s going.\n\nThe descendant of Kuśika is himself capable of repressing the Rākṣasas; and it is in order to your son’s welfare that coming to you, he ask for him of you.\n\nAt this speech of the ascetic, that foremost of Raghus , the king, well-pleased, became exceedingly delighted. And that famous one, relishing the journey of Rāma, began to reflect in his mind about consigning him to Kuśika’s son.
22	1	22	Chapter XXII	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365890.html	Upon Vasiṣṭha ’s representing this, king Daśaratha himself, with a complacent countenance, summoned to him Rāma and Lakṣmaṇa .\n\nAnd when the auspicious rites had been performed by both Rāma’s father and mother, and when the priest Vasiṣṭha had uttered mantras , king Daśaratha, smelling his son’s crown, with a glad heart, made him over to the descendant of Kuśika .\n\nThen there blow a Breeze free from dust and of delicious fed, on witnessing the lotus-eyed Rāma at the hands of Viśvāmitra . And as the high-souled one was about to set out, blossoms began to shower down copiously, accompanied with the sounds of celestial kettle-drums and the loud blares of conch.\n\nViśvāmitra went first, and next the highly famous Rāma with the side-locks, holding the bow. And him followed Sumitrā ’s Sun\n\nAnd equipped with quivers, and with bows in hand, gracing the ten cardinal points and resembling three-hooded serpents, they followed the high-souled Viśvāmitra, like the two stalwart Aśvins following the Grand-sire.\n\nThose effulgent ones of faultless limbs went in the wake of the ascetic, illumining him with their grace. And like to those sons of him Skandha and Viśākha following the incomprehensible deity, Sthāṇu , those youthful brothers of comely persons and faultless limbs Rāma and Lakṣmaṇa, highly effulgent, carrying bows in hand, adorned with ornaments, and equipped with scimitars, with their fingers encased in Guana skin, flamingly followed Kuśika’s son, beautifying him with their splendour.\n\nAnd having proceeded over half a Yojana , and arriving at the right bank of the Sarayū , Viśvāmitra addressed these sweet words to Rāma, O Rāma! do you, O child, take of this water: let no delay occur.\n\nDo you receive the mantras Bala and Atibala , and you will not feel fatigue or fever or undergo any change of look, and whether asleep or heedless, the Rākṣasas will not be able to surprise you. And, O Rāma, the might of your arms will be unequalled in this world,—nay, in all the three worlds.\n\nDo you, O Rāghava , recite Bala and Atibala, O child! And, O sinless one, when you have secured these two kinds of knowledge, none in this world will equal you in good fortune, or in talent or in philosophic wisdom, or in subtle apprehension, or in the capacity of answering a controversialist; for Bala and Atibala are the nurses of all knowledge.\n\nAnd, O Rāma, O foremost of men, if you recite Bala and Atibala on the way, neither hunger nor thirst will exercise you, O descendant of Raghu ! And if you recite these, you will attain fame on earth. Those sciences fraught with energy are the daughters of the Grandsire.\n\nI intend to confer them upon you, O Kākutstha ; and, O lord of earth, they are worthy to be conferred upon you; and they are possessed of various virtues. You need not entertain any doubt about it. And if you bear them in consonance with the precepts, they will prove of manifold good to you.\n\nThereat Rāma with a cheerful countenance sipping water with a purified body received those sciences from the Maharṣi of subdued soul.\n\nAnd furnished with the sciences, Rāma of dreadful prowess appeared resplendent, even like the adorable autumnal Sun invested with a thousand rays.\n\nThen Rāma having rendered to Kuśika’s son all the duties pertaining to a spiriṃal guide, the three happily spent that night on the banks of the Sarayū.\n\nAnd although those excellent sons of Daśaratha lay down on an unbeseeming bed of grass, yet in consequence of the sweet converse of Kuśika’s son, the night seemed to pass pleasantly away.
24	1	24	Chapter XXIV	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365892.html	Then next morning which happened to be fine, those repressors of their foes, with Viśvāmitra at their head, came to the banks of the river. ( Gaṅgā ).\n\nThe legend is that when the saint Agastya had sucked up the ocean, the Ganges replenished it.\n\nAnd those high-souled ascetics observing vows, having brought an elegant bark, addressed Viśvāmitra, saying.\n\nDo you ascend the bark, with the princes at your head! May your journey be auspicious: let no delay occur\n\nThereupon saying, So be it! and having paid homage to those ascetics, Viśvāmitra set about crossing that river, which had replenished the ocean.\n\nIt came to pass that while thus engaged, they heard a sound augmented by the dashing of the waves. And having come to the middle of the stream, the highly energetic Rāma with his younger brother, became curious to ascertain the cause of that sound.\n\nAnd reaching the middle of the river, Rāma asked that best of ascetics, What is this loud uproar that seem to come riving the waters?\n\nHearing Rāghava ’s words dictated by curiosity, that righteous-souled one spoke, unfolding the true cause of that noise.\n\nO Rāma, there is in the Kailāsa mountain an exceedingly beautiful pool, created mentally by Brahmā , O foremost of men, and hence this watery expanse go by the name of Mānasa Pool.\n\nAnd the stream that issues from that liquid lapse, flows through Ayodhyā : the sacred Sarayū issues from that pool of Brahmā.\n\nAnd as the Sarayū meets the Jāhnavī , this tremendous uproar is heard, being produced by the clashing of the waters. Do you, O Rāma, bow down to them with a concentrated mind.\n\nThereupon, boṃ of those exceedingly righteous ones, bowed down to those streams; and betaking themselves to the right bank, began to proceed with fleet vigour.\n\nAnd beholding a dreadful and trackless, forest, that son of the foremost of men, Ikṣvāku ’s descendant, asked that best of ascetics.\n\nAh! deep is this forest abounding in crickets; and filled with terrible ferocious beasts, and various birds possessed of shocking voices and creaming frightfully; and graced by lion, and tigers, and boars, and elephants; and crowded with Dhavas * (Grislea Tomentosa). and Aśvas and Karṇas (Cassia fistula) and Kakubhas and Vilvas (Aegle marmalos) and Tiṇḍukas \\ (Diospyros glutinosa) and Pāṭalas (Bignonia suave-olens) and Baḍarīs (Fujube). Whence is this dreadful forest?\n\nHim answered thus the mighty ascetic Viśvāmitra endowed with high energy, Do you listen, O Kākutstha , as to whom belong this dreadful forest!\n\nHere were formerly, O foremost of men, two flourishing provinces, named Maladā , and Karūṣa , built by celestial architects.\n\nIn days of yore, O Rāma, on the occasion of the destruction of Vṛtra , the thousand-eyed one came to have hunger, to be besmeared with excreta, and to slay a Brāhmaṇa .\n\nWhen Indra had been thus besmeared, the deities, and the saints having asceticism for wealth, washed him here, and cleansed his person from the dirt.\n\nAnd the deities, having renounced here the filth that had clung to the person of the mighty Indra, as well as his hunger, attained exceeding delight.\n\nAnd thereat Indra becoming purified, attained his former brightness, and looked like to gold. And mightily pleased with this region, he conferred on it an excellent boon, saying, Since these two places have held excreta from my body, the going by the names of Maladā and Kārūṣa , shall attain exceeding prosperity and fame among men.\n\nAnd beholding the land ṃus honoured by the intelligent Sacra, the deities said to the subduer of Pāka ,—Well Well!\n\nO repressor of foes, these two places, Maladā and Karuṣā, enjoyed prosperity for a long time and were blessed with com and wealth.\n\nThen after a space of time, was born a Yakṣīṇi capable of assuming forms at will, and endowed with the strength of a thousand elephants.\n\nHer name, good betide you! was Tāṭakā , and she was the spouse of the intelligent Sunda —she whose son is the Rākṣasa , Mārīca , possessed of the prowess of Sacra; having round arms, with a huge head, a capacious mouth and a cyclopean body.\n\nAnd that Rākṣasa of dreadful form daily frightens people. And, O descendant of Raghu , Ṭāṭakā of wicked deeds, daily commits havoc upon these countries, Maladā and Karuṣā.\n\nAnd now at the distance of over half a Yojana , she stays, obstructing the way. And since this forest belong to Tāṭakā, you should repair there; and, resorting to the might of your own arms, slay this one of wicked deeds.\n\nAnd, by my direction, do you again rid this region of its thorn; for no one dare to approach such a place, infested,\n\nO Rāma, by the dreadful and unbearable Yakṣiṇī . And now I have related to you all about this fearful forest. And to this day none is capable of letting that Yakṣiṇī from committing ravages right an left.
26	1	26	Chapter XXVI	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365894.html	Hearing those bold words of the ascetic, the son of that foremost of men, Rāghava firm in his vows, with clasped hands answered.\n\nIn accordance with the desire of my sire, and in order to glorify it, I ought fearlessly to do even as Kuśika ’s son says. And having been desired to that end while at Ayodhyā by that high-souled one, my father Daśaratha , in the midst of the spiritual guides, I ought not to pass by your words.\n\nTherefore, commanded by that upholder of the Veda , I, agreeably to my father’s mandate, will, without doubt, bring about that welcome event—the death of Tāṭakā .\n\nAnd in the interests of Brāhmaṇas , kine, and celestials, I am ready to act as desired by you of immeasurable energy.\n\nHaving said this, that repressor of foes, with clenched fist, twanged his bow-string, filling the ten cardinal points with the sounds. And at those sounds, the dwellers in Tāṭakā’s forest were filled with perturbation,—and Tāṭakā also amazed at those sounds, became exceedingly wroth.\n\nAnd rendered almost insensible by anger, that Rākṣasī furiously rushed in a main towards the spot whence had come the report.\n\nAnd beholding that frightful one of hideous visage and colossal proportions, transported with rage, Raghu ’s descendant spoke to Lakṣmaṇa ,\n\n“Behold, O Lakṣmaṇa, the terrible and hideous body of yonder Yakṣiṇī ! The sight of her strike terror into the hearts of even the brave.\n\nMark! This irrepressible one, possessing all ṃe resources of illusion, will I oppose, and deprive her of ears and nose.\n\nBut I dare not slay her, she being protected by virtue of her feminineness. I intend only to oppose her course, and deprive her of her prowess.”\n\nAs Rāma was speaking thus, Tāṭakā, deprived of sense through ire, uttering roars, with uplifted arms rushed against him.\n\nAnd thereat the Brahmarṣi , Viśvāmitra , uttering a roar, upbraided her, and said, Svasti ! [1] May victory attend the descendants of Raghu!\n\nAnd raising thick clouds of dust, Tāṭakā instantly bewildered both the descendants of Raghu.\n\nAnd then by help of illusion, she began to pour upon them a mighty shower of crags. And thereat Raghu’s descendant was wroth.\n\nAnd resisting that mighty shower of crags by vollies of shafts, Rāghava with arrows cut off her hands.\n\nAnd with the fore-parts of her arms lopped off, as she was roaring before them, Sumitrā ’s son waxing wroth deprived her of her ears and nose.\n\nThereupon that one capable of assuming forms at will, began to assume various shapes; and to vanish from sight, bewildering her antagonists with her illusory displays.\n\nTerribly ranging the field, the Yakṣī showered crags upon her antagonists. And beholding them enveloped on all sides by that craggy downpour, the auspicious son of Gaḍhi spoke these words,—O Rāma, renounce your antipathy. This one of wicked ways is exceedingly impious. And this sacrifice-disturbing Yakṣī will, by virthe of her power of illusion, come to increase more and more in energy. Do you, therefore, against the arrival of dusk, slay her! The Rākṣasas are incapable of being controlled when evening sets in.\n\nThus addressed, Rāma, displaying his skill in aiming by sounds, enveloped with arrows that Yakṣī showering crags.\n\nBeing thus hemmed in with a network of shafts, she possessed of the powers of illusion, rushed against Kākutstha and Lakṣmaṇa, uttering terrible roars. And as that Yakṣī, in prowess like to a thunder-bolt, was rushing on, Rāma pierced her chest with arrows, and thereat she dropped down and died.\n\nUpon seeing that grim-visaged one slain, the lord of the celestials together with the celestials themselves honouring Kākutstha, exclaimed Well, Well!.\n\nAnd exceedingly pleased, the thousand-eyed Purandara , together with the delighted deities, said to Viśvāmitra.\n\nO ascetic, O Kuśika’s son, good betide you! all the Maruts with Indra at their head, have been gratified with this act (of Rāma’s). Do you, O Brāhmaṇa , confer upon Raghu’s descendant the sons of Prajāpati Kṛśāśva , of true prowess, and charged with ascetic energy.\n\nAnd ever following you, he, O Brāhmaṇa, is fit to receive them of you. And this son of the king is to accomplish a mighty task in the interests of the celestials.\n\nSaying this, the deities, having paid homage to Viśvāmitra, joyfully entered the celestial regions.\n\nAnd now came evening on, when that best of ascetics, gratified at the destruction of Tāṭakā, smelt Rāma’s crown and said these words,\n\n“Here, O Rāma of gracious presence, shall we pass the night; and morrow morning, went to that hermitage of mine.”\n\nHearing Viśvāmitra’s words, Daśaratha’s son, glad at heart, happily passed that night in the forest of Tāṭakā.\n\nAnd being thus freed from all disturbances, from that day forth that forest appeared charming, even like to the forest of Caitraratha .\n\nHaving thus slain the Yakṣa ’s daughter, Rāma, eulogised by celestials and Siddhas , spent there that night with the saint, being awakened by the latter at the break of day.\n\n[back to top]\n\n[1] :\n\nA particle of benediction, indeclinable.
27	1	27	Chapter XXVII	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365895.html	Having passed that night, the illustrious Viśvāmitra , smiling complacently, sweetly spoke to Rāghava , saying,\n\nPleased am I with you. Good betide you, O highly famous prince! With supreme pleasure, do I confer upon you all the weapons.\n\nBy means of which subduing such antagonists as celestials and Asuras backed on earth by Gandharvas and Uragas , you will in battle be crowned with victory.\n\nAll those celestial weapons, good betide you, I will confer upon you. And I will confer upon you, O Rāghava, the celestial and mighty Daṇḍacakra [1] and Dharmacakra , and also Kālacakra . And, O foremost of men, I will confer upon you the fierce Viṣṇucakra , and Indracakra .\n\nThe Vajra , and Śiva ’s Śūlavara, and the weapon Brahmaśiras , and Aiṣīka, O mighty-armed descendant of Raghu ! And, O tiger among men, I will, O king’s son, bestow upon you the matchless Brahmā weapon, and, O Kākutstha , the two excellent maces, the flaming Modakī and Śikhari . And, O Rāma , I will confer upon you Dharmapāśa, [2] and Kālapāśa, and the excellent Varuṇapāśa.\n\nO descendant of Raghu, I will bestow upon you the two Aśanis , Śuṣka and Ārdra , and the Pināka weapon, and the Nārāyaṇa , and the Āgneya weapon called Śikhara , and the Vāyavya , called Prathama .\n\nO sinless one! And, O Rāghava, I will confer upon you the weapon called Hayaśiras , and the Krauñca weapon, and, O Kākutstha, a couple of darts.\n\nAnd I will confer upon you Kaṅkāla , and the dreadful Muśala , and Kapāla , and Kiṅkiṇī —all those that are intended for slaughtering Rākṣasas .\n\nAnd, O mighty-armed one, O son of the best of men, I will confer upon you the mighty weapon Vidyādhara , and that excellent scimitar named Nandana , and the favourite Gandharva weapon, Mohana , and Prasvāpana , Paśamana, and Saumya , Rāghava! And, O tiger among men, do you accept Varṣaṇa , and Śoṣaṇa , and Santāpana , and Vilāpana , and Mādana hard to repress, beloved of Kandarpa , and that favourite Gandharva weapon, Mānava , and the favourite Piśāca weapon, O highly famous prince.\n\nYou, O mighty-armed Rāma, speedily accept the Tāmasa , O tiger among men, and the exceedingly powerful Saumana, and the irrepressible Saṃvarta and Mauśala, O son of the king, and the Satya weapon, and the supreme Māyāmaya, and the Saura . Tejaprabha, capable of depriving foes of energy, and the Soma , and the Siśira, and the Tvāṣṭra , and the terrible Dāruṇa belonging to Bhaga , and Śileṣu, and Mānava.\n\nO long-armed king’s son, Rāma! receive instantly all powerful, highly exalted forms that can be modified at will.\n\nThen with his face turned towards the east, that foremost of ascetics having purified himself, gladly conferred the mantras upon Rāma.\n\nAnd the Vipra also bestowed upon Rāghava those weapons, of which even the celestials are incapable of holding all.\n\nAs that intelligent ascetic, Viśvāmitra, recited mantras, all those invaluable weapons appeared before that descendant of Raghu. And with clasped hands, they well-pleased, addressed Rāma,—These, O highly generous one, are your servants, O Rāghava. And whatever you wish, good betide you, shall by all means be accomplished by us.\n\nThus addressed by those highly powerful weapons, Kākutstha Rāma, with a delighted soul, accepting them, touched them with his hand, and said, Do you appear before me as I remember you!\n\nThen the exceedingly energetic Rāma, well pleased, paying reverence to the mighty ascetic, Viśvāmitra, prepared to set out.\n\n[back to top]\n\n[1] :\n\nCakra means discus. These enumerations specify different kinds of the discus.\n\n[2] :\n\nPāsa means noose
28	1	28	Chapter XXVIII	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365896.html	Having accepted those weapons with purity, Kākutstha while proceeding, with a complacent countenance spoke these words to sage Viśvāmitra ,—\n\nO adorable one, I have received these weapons, incapable of being repressed even by the celestials themselves. Now, O best of ascetics, I would acquire a knowledge of with drawing them.\n\nUpon Kākutstha’s representing this, Viśvāmitra of high austerities, endowed with patience, of excellent vows, and pure in spirit, communicated to him the mantras for restraining the weapons.\n\nDo you, O Rāma , accept Satyavat, and Satyakīrti, Dhṛṣṭa , Rabhasa , Pratihāratara, Parāṅmukha, Avāṅmukha, and also Lakṣya , Alakṣya, Dṛḍhanābha, Sunābha , Daśākṣa, Śatavaktra, Daśaśīrṣa, Śatodara, Padmanābha , Mahanābha, Indunābha, Svanābha, Jyotiṣa , Śakuna , Nairaṣya, Vimala , Yaugandhara, Vinidra , and the two Daityapramathanas, and Śucibāhu, Mahābāhu , Niṣkali, Viruca, Arcimāli, Dhṛtimāli, Vṛttimān, Rucira , Pitrya , Saumansa, Vidhuta , Makara , Karavīra , Rati , Dhana , and Dhānya , O Rāghava , and Kāmarūpa , Kāmaruci, Moha , Āvaraṇa and Jṛmhhaka, Sarpanātha, Panthāna, and Varuṇa ,—these sons of Kṛśāśva , O Rāma, effulgent, and assuming shapes at will. And, good betide you, O descendant of Raghu , you are worthy to receive these weapons.\n\nThereupon, Kākutstha with a heart overflowing with delight, said,—So be it! And those weapons were furnished with celestial and shining persons, and endowed with visible shapes, and capable of conferring happiness. And some of them were like (live) coals; and some comparable to smoke; and some were like to the Sun or the Moon. And with folded hands, they spoke to Rāma in honied accents; O chief of men, here we are! Do you command as to what we are to do on your behalf.\n\nThen the descendant of Raghu answered, saying, Repair whither soever you will! Recurring to my memory, do you in time of need, render me assistance!\n\nThereupon paying homage to Rāma, and having gone round him, they replied to Kākutstha, What is yonder wood hard by the hill, appearing like clouds? Great is my curiosity.\n\nIt is pleasing to the sight, and abounds in beasts, and is exceedingly romantic, and is adorned with various birds singing sweetly.\n\nNow, O foremost of ascetics, we have come out of a wilderness capable of making one’s hair stand on end. And from the pleasantness attaching to this place, I have come to a conclusion.\n\nTell me, O reverend sir, whose hermitage is this? Have we, O eminent ascetic, reached that spot where dwell those wicked minded wretches of impious deeds, given to slaughtering Brāhmaṇas , who disturb your sacrifice? Where, O adorable one, is that hermitage, repairing to which, O Brāhmaṇa , I am to protect your sacrificial rites, and to slay the Rākṣasas ? All this, O foremost of ascetics, I desire to hear, O lord.
29	1	29	Chapter XXIX	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365897.html	Hearing those words of Rāma of measureless prowess, who had asked the question, the highly energetic Viśvāmitra answered, saying,\n\nHere, O mighty-armed Rāma, Viṣṇu of mighty asceticism worshipped of all the deities, for years upon years, and hundreds of Yugas , dwelt for carrying on his austerities and Yoga . This, O Rāma, was formerly the hermitage of the high-souled Vāmana .\n\nAnd this famed as Siddhāśrama , in consequence of that one of potent asceticism having attained fruition there. And it came to pass that at this time Virocana ’s son, king Vālī ; having vanquished the celestials with Indra and the Marats, established that dominion of his, famous in the three worlds.\n\nAnd that mighty chief of the Asuras celebrated a sacrifice. And as Vālī was performing that sacrifice, the deities with Agni at their head, coming to Viṣṇu himself at this asylum, addressed him saying,\n\nVirocana’s son, Vali , O. Viṣṇu, is celebrating a sacrifice. Do you, before the ceremony is finished, accomplish your own end.\n\nHe duly confer upon such as repair to him from various quarters all those things that they ask for. And do yourself.\n\nO Viṣṇu, aided by your power of illusion, assuming a Dwarf form, accomplish the welfare of the gods.\n\nIn the meantime, O Rāma, the worshipful Kaśyapa resembling fire in splendour, and flaming in energy, having in company with, and with the assistance of, the divine Aditi , O Rāma, accomplished his vow, began to hymn the destroyer of Madhu ready to confer boons.\n\nBy means of warm austerities, will I behold you composed of penances, a mass of mortifications, and endowed with a form and a soul of austerities. And in your person, O lord, will I behold this entire universe. And in You without beginning, and incapable of being pointed out, do I take refuge! Thereupon exceedingly pleased, Hari spoke to Kaśyapa, with his sins purged off, saying, Do you mention the boon! Good betide you. Methinks you deserve a boon.\n\nHearing these words of his, Marīci ’s son, Kaśyapa, said, Aditi, the gods, and I myself, crave of you this, and, O bestower of boons, it behove you well pleased to confer on us this boon, O you of excellent vows! Do you, O sinless one, become born as my son in Aditi.\n\nO adorable deity! Do you become the younger brother of Śakra , O destroyer of Asuras. It behove you to help the celestials afflicted with grief.\n\nAnd this place through your grace will attain the name of Siddhāśrama. The work, O lord of the celestials, has been accomplished.\n\nDo you now, O you of the six attributes, ascend from hence! And accordingly Viṣṇu of mighty energy took his birth in Aditi. And assuming the form of a dwarf, he presented himself before Virocana’s son.\n\nAnd then asking for as much earth as could be covered by three footsteps, that one ever engaged in the welfare of all creatures; with the object of compassing the good of all, stood occupying the worlds. And having by his power restrained Bali , that one of exceeding energy, again conferred the three worlds upon the mighty Indra, and made them subject to his control.\n\nFormerly he used to dwell in this asylum capable of removing fatigue. And hermitage is infested by Rākṣasas disturbing rites. And, O most puissant of men, here you should slay those ones of wicked ways.\n\nTo-day, O Rāma, will I repair to this supremely excellent Siddhāśrama. And this asylum, child, is as much your as mine.\n\nSaying this, taking Rāma and Lakṣmaṇa , the mighty ascetic, experiencing exceeding delight, entered that asylum, and appeared graceful, like the Moon emerged from mist in conjunction with the Punarvasu stars.\n\nAnd beholding Viśvāmitra, the ascetics inhabiting Siddhāśrama, suddenly rising in joy, worshipped that intelligent one, and extended to the princes the rites of hospitality.\n\nAnd then having reposed for a while, those unreproved princes, the descendants of Raghu , wiṃ clasped hands, addressed that foremost of ascetics.\n\nBe you even to-day initiated to the ceremony. Good betide you, O best of ascetics! Let this Siddhāśrama verily attain fruition, and let your words be verified!\n\nThus addressed, that mighty saint of exceeding energy, observing vows, and with his senses under restraint, caused himself to be initiated into the ceremony. And like to the Kumāras , ( Skanda and Viśākha ) Rāma and Lakṣmaṇa, having passed the night pleasantly, rose in the morning; and having finished their morning worship, and with purity and self-restraint recited the prime mantras , paid their obeisance to the sacrificial fire and the sacrifices, Viśvāmitra, who was seated.
30	1	30	Chapter XXX	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365898.html	Then those princes, repressors of foes, cognizant of place, and time, and words, thus spoke to Kuśika ’s son agreeably to time and place, saying,\n\nO adorable one, do you tell us as to the time when we should oppose those rangers of the night! Let not that hour pass away!\n\nUpon the two Kākutsthas ’ saying this, and finding them prompt for the encounter, those ascetics well-pleased, fell to extolling the sons of the king.\n\nFor six nights from to-day, you should protects us. This ascetic has been initiated into the sacrifice, and must, therefore, observe taciturnity.\n\nHearing these words of theirs, those illustrious princes, renouncing sleep, began to guard the hermitage day and night; and those heroic and mighty archers protected that best of ascetics and subduer of enemies.\n\nWhen time had thus gone by and the sixth day had arrived, Rāma said to Sumitrā ’s son. Being well equipped, be you vigilant!\n\nWhen Rāma, manifesting emotion, and being eager for encounter, had said this, the priests and spiritual guides lit up the altar. And along with Viśvāmitra and the family priests, they lit up the altar furnished with Kuśa , and Kāśa , and ladles, and faggots, and flowers.\n\nAnd as reciting mantras , they were about to duly engage in that sacrifice, there arose a mighty and dreadful uproar in the sky.\n\nAnd as in the rains, masses of clouds appear enveloping the firmament, the Rākṣasas , displaying illusions in that wise, began to rush onward. And Mārīca and Subāhu together with their followers coming in dreadful forms, began to shower down blood upon the altar.\n\nAnd on seeing the altar deluged with gore, Rāma suddenly rushed forward, and behold them in the sky. And suddenly seeing them rushing in amain, the lotus-eyed Rāma fixing his gaze at Lakṣmaṇa , said.\n\nBehold O Lakṣmaṇa, by means of a Mānava weapon, I shall, without doubt, drive away the wicked; flesh-eating Rākṣasas, even as the wind drive away clouds before it. Surely I cannot bring myself to slay such as these.\n\nSaying this, that descendant of Raghu , Rāma, in vehemence fixing on his bow an exceedingly mighty and gloriously-dazzling Mānava weapon, discharged it in great wrath at Mārīca’s chest.\n\nAnd wounded by that foremost of Mānava weapons, Mārīca carried off a sheer hundred Yojanas , dropped in the midst of the ocean.\n\nAnd finding Mārīca senseless, and whirling, and afflicted by the might of the weapon, and overcome, Rāma addressed Lakṣmaṇa, saying.\n\nBehold, O Lakṣmaṇa, this Mānava weapon first used by Manu , depriving him of his senses has carried him off, and yet has not taken his life!\n\nBut these shameless, wicked, and blooddrinking Rākṣasas, delighting in wrong-doing, these disturbers of sacrifices, will I slaughter.\n\nHaving said this, anon showing to Lakṣmaṇa his lightness of hand, Raghu’s descendant took out a mighty Āgneya weapon, and discharged it at the breast of Subāhu. Thereat being pierced with that shaft, he fell down upon the ground. Then taking a Vāyavya weapon, the illustrious and exceedingly generous Rāghava , bringing delight to those ascetics, slew the rest.\n\nHaving destroyed all those Rākṣasas disturbing sacrifices, Raghu’s descendant was honoured by the saints, even as Indra in day of yore, after having vanquished the Asuras .\n\nWhen the sacrifice had been completed, the mighty ascetic Viśvāmitra, beholding all sides cleared of Rākṣasas, spoke to Kākutstha , saying,\n\nO mighty-armed one, I have obtained my desire; and you have executed your preceptor’s mandate. And, O illustrious hero, you have truly made this a Siddhāśrama . Having thus extolled Rāma, he took Rāma and Lakṣmaṇa, to perform his evening devotions.
32	1	32	Chapter XXXII	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365900.html	Once upon a time there was a mighty son of Brahmā , of high austerities, named Kuśa . And he was cognizant of duty, and ever engaged in observing vows and honouring good men.\n\nThat high-souled one beget on Vaidarbha , sprung from a respectable line and endowed with all noble qualities, four sons like to himself, and possessed of extraordinary prowess— Kuśāmba , and Kuśanābha , and Asūrtarajas, and Vasu , resplendent and breathing exhaustless spirits. And with the desire of enhancing Kṣetrya ( Kṣatra ?) merit, Kuśa said to his truthful and virtuous sons—‘You sons! do you engage in the task of governing, and thereby acquire immense merit.’\n\nHearing Kuśa’s words, those four foremost of men and best of sons addressed themselves to founding seats for their government. And the highly energetic Kuśāmba founded the city of Kauśāmbī ; and the righteous Kuśanābha, the metropolis of Mahoḍaya; and the magnanimous Asūrtarajas, Dharmāraṇya ;.and king Vasu, Girivraja , best of capitals.\n\nThis city (otherwise) called Vasumatī belongs to the high-souled Vasu. And the river known by the name of Sumāgadhī flows through the Māgadhas . And in the midst of the five foremost of hills, it looks like a garland.\n\nAnd this Māgadhī , O Rāma , belongs to the high-souled Vasu, taking, O Rāma, an easterly course, and flowing through fertile fields furnished with com.\n\nO descendant of Raghu , the Rājarṣi Kuśanābha beget an hundred godly daughters on Ghṛtācī .\n\nAnd it came to pass that they endowed with youth, beautiful and like to the lighting in the rainy season, decked in excellent ornaments, coming to their garden were merrily singing and dancing and playing on musical instruments, O Rāghava ! And as they perfect in every limb, and unparalleled on earth in beauty, and endowed with all qualities, and furnished with youth and grace, were in the garden, like to stars embossed among clouds, that life of all (the air, beheld them and said.)\n\nI seek for you: do you become my wives. Do you renounce this human guise, and attain long lives.\n\nYouth verily is unstable, specially with the human beings: do you attaining unfading youth, become immortal!\n\nHearing this speech of the Air of ever fresh energy, the damsels ridiculing it, said.\n\nYou range the hearts of all creatures, O foremost of celestials, and we also know your influence. Wherefore, then, do you dishonour us?\n\nO foremost of celestials, we are the daughters of Kuśanābha O divine one. And god as you are, we can dislodge you from your place; but we refrain from doing so, lest thereby we lose our ascetic merit.\n\nMay, O foolish one, that time never come, when disregarding our truthful sire, we following our inclination, shall resort to self choice.\n\nOur father verily is our lord an prime god. Of him even shall we become the wives to whom our father give us away.\n\nAt these words of theirs, that lord and adorable one, the Air, exceedingly enraged, then entered into their bodies, and brake all their limbs. Their bodies being thus broken by Air, those damsels, exceedingly agitated and overwhelmed with shame, with tears in their eyes entered the residence of the king.\n\nAnd finding his supremely beautiful and favourite daughters with their limbs broken, and woebegone, the king bewildered, spoke.\n\nYou daughters, what is this? Who is it that thus disregards virtue? By whom have you all come by this crooked form? And why demonstrating your grief, do you not answer me?’ Having said this, the king heaved a deep sigh and became eager to hear all about it.
33	1	33	Chapter XXXIII	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365901.html	Hearing those words of the intelligent Kuśanābha , his hundred daughters touching his feet with their heads, said,\n\nO king, that life of all, the Air, was desirous of overcoming us, having recourse to an improper way; nor did he regard morality,\n\nWe have a father, good betide you; and we live at ease. Do you ask our father about it, if he consent conferring us on you.\n\nBut that wicked wight did not listen to our words; and as we were saying this, were we roughly handled by him.’\n\nHearing those words of theirs, the highly pious and puissant king addressed his hundred beautiful daughters, saying\n\nYou have displayed a signal example of that forgiveness which is fit to be followed by the forbearing; and that you have unanimously regarded the honour of my house, also conduces to your praise.\n\nAlike to men and women, forbearance is an ornament. And difficult it is for one to exercise that forbearance, specially in respect of the celestials. And may every descendant of mine possess forbearance like to yours!\n\nForbearance is charity; forbearance is truth; forbearance, O daughters, is sacrifice; forbearance is fame; forbearance is virtue, you, the universe is established in forbearance;\n\nThen dismissing his daughters, the king endowed with the prowess of celestials, and versed in counsel, began to consult with his counsellors about the bestowal of his daughters, in respect of time and place and person and equability of lineage.\n\nIt came to pass that at this time, an ascetic named Cūlī, highly effulgent, with his vital fluid under control, and of pure practices, was performing Brāhma austerities.\n\nAnd as the saint was engaged in austerities, good betide you, Urmilā ’s daughter named Somadā —a Gandharvī —ministered to him.\n\nAnd in all humility that virtuous one for a definite period was engaged in ministering to him. And thereat, her spiritual guide was gratified with her.\n\nAnd, O descendant of Raghu , once he said to her, I am gratified, good betide you! What good shall I render you?\n\nThereupon, concluding that the ascetic was gratified, the Gandharvī, cognizant of words, exceedingly delighted, sweetly addressed that one versed in speech.\n\nYou are furnished with the Brāhma marks, art sprung from Brahmā , and art of mighty austerities. I desire of you a righteous son endowed with the Brāhma ascetic virtues.\n\nI am without a husband, good betide you, and I am no one’s wife. Upon me who is your servant you should confer such a son by help of Brāhma means.\n\nThereupon, well pleased with her, Cūlina conferred upon her an excellent Brāhma mind-begotten son, named Brahmadatta .\n\nAnd that king, Brahmadatta, founded the flourishing city of Kampilya , even as the sovereign of the celestials founded the celestial regions.\n\nAnd, O Kākutstha , the righteous king Kuśanābha finally decided on conferring his hundred daughters upon Brahmadatta.\n\nAnd inviting Brahmadatta, that highly energetic lord of earth, with a glad heart conferred his hundred daughters upon him.\n\nAnd O descendant of Raghu, king Brahmadatta resembling the lord himself of the celestials, by turns received their hands in marriage.\n\nAnd as soon as he touched them, the hundred daughters were cured of their crookedness, and became free from anguish, and were endowed with pre-eminent beauty.\n\nAnd upon beholding them delivered from (the tyranny of) the Air, the monarch Kuśanābha became exceedingly delighted, and rejoiced again and again.\n\nAnd he dismissed that lord of earth, king Brahmadatta, in company with his consorts and the priests.\n\nAnd the Gandharvī Somadā rejoiced exceedingly at the completion of the nuptials of her son; and embracing her daughters-in-law again and again, and extolling her son, she expressed the fullness of her joy.
35	1	35	Chapter XXXV	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365903.html	Having in company with the ascetics passed the remainder of the night on the banks of the Śoṇa , Viśvāmitra , when the day broke, spoke,\n\nO Rāma , the night has passed away, and the mom has come. The hour for performing the prior devotions has arrived. Arise! arise! good betide you! Do you prepare for going.\n\nHearing these words of his, Rāma, having finished his morning devotions and rites, and ready for departure, said,\n\nThis is the Śoṇa, of excellent waters, fathomless, and studded with islets. O Brāhmaṇa , by which way shall we repair.\n\nThus addressed by Rāma, Viśvāmitra replied. Even this path has been fixed upon by men, that, namely, by which the Maharṣis go.\n\nHaving proceeded far, when the day had been half spent, they beheld that foremost of streams, the Jāhnavī , worshipped by ascetics.\n\nHaving beheld that river furnished with sacred waters, and frequented by swans and cranes, the ascetics who accompanied Rāghava were exceedingly delighted.\n\nAnd they took up their quarters on the banks of the river. And then having bathed and duly offered oblations of water to the gods and the manes of their ancestors, and performed Agnihotra (Sacrifice with burnt offering.) sacrifices, and partaken of clarified butter like to nectar, those high-souled and auspicious ones, with glad hearts, sat down surrounding Viśvāmitra.\n\nAnd the descendants of Raghu also sat down, occupying prominent places as befitted their rank. Then Rāma with a heart surcharged with cheerfulness spoke to Viśvāmitra, saying,\n\nO adorable one, I desire to hear how the Gaṅgā flowing in three directions and embracing the three worlds, falls into the lord of streams and rivers.\n\nInfluenced by Rāma’s speech, the mighty ascetic Viśvāmitra entered upon the history of the Gaṅgā’s origin and progress.\n\nO Rāma, that great mine of ore, Himavat is the foremost of mountains. To him were born two daughters, unparalleled on earth in loveliness.\n\nO Rāma, their mother of dainty waist, the amiable daughter of Meru , named Menā , was the beloved wife of Himavat.\n\nShe of whom was born Gaṅgā the elder daughter of Himavat; and, O Rāghava, a second daughter was also born to him, named Umā.\n\nAnd it came to pass that once upon a time, the deities, with the view of accomplishing some work appertaining to them as divine beings, in a body besought that foremost of mountains for that river flowing in three worlds, Himavat in obedience to duty, conferred upon them his daughter flowing everywhere at will, and sanctifying all creatures. Thereat in the interests of the three worlds, accepting her, those having the welfare of the three worlds, at heart, went away with Gaṅgā, considering themselves as having attained their desire.\n\nThe other daughter of the mountain, O descendant of Raghu, adopting a stem vow, began to carry on austerities, having asceticism for her wealth.\n\nAnd that best of mountains bestowed upon Rudra of unequalled form his daughter Umā, furnished with fiery asceticism and worshipped of the worlds.\n\nAnd these, O Rāghava, are the daughters of that king of mountains, worshipped of all, viz, Gaṅgā, the foremost of streams, and the divine Umā.\n\nNow, O best of those endowed with motion, have I related to you how that sin-destroying one flowing with her waters in three diverse directions, first, O child, went to the firmament and then ascended the celestial regions.
34	1	34	Chapter XXXIV	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365902.html	And, O Rāghava , when Brahmadatta was married, that sonless one, ( Kuśanābha ), with the intention of obtaining male offspring, took in hand a son-conferring sacrifice.\n\nAnd when the sacrifice had commenced, that son of Brahmā , the exceedingly noble Kuśa , spoke to king Kuśanābha, saying,\n\nO son, there will be born to you a virtuous son like to thyself: you will obtain even Gādhi , and through him enduring fame in this world.\n\nHaving said this to king Kuśanābha, Kuśa, O Rāma , entering the welkin, went to the eternal regions of Brahmā.\n\nThen after sometime, an eminently virtuous son, named Gadhi , was born to the intelligent Kuśanābha.\n\nO Kākutstha , even that highly pious Gadhi is my sire. And, O descendant of Raghu , I, called Kauśika , am sprung from Kuśa’s line.\n\nO Rāghava, I had a sister of noble vows born before me. And her name was Satyavatī ; and she was bestowed upon Ṛcīkā.\n\nAnd following her lord, she ascended heaven in her own proper person. And my highly generous sister, Kauśikī , has finally assumed the form of a mighty river.\n\nAnd in order to compass the welfare of all creatures, my sister is now a noble and charming river of sacred waters, issuing from the Himavat mountains.\n\nAnd thenceforth, out of affection for my sister, Kauśikī, I ever dwell happily in the vicinity of the Himavat, O Rāghava.\n\nAnd that virtuous Kauśikī, Satyavatī, as well established in religion as truth, and chaste, and eminently pious, is now the foremost of streams.\n\nAnd, O Rāma, it is only for the purpose of completing my sacrifice that leaving her behind, I have come to Siddhāśrama . And now by virtue of your energy, have I attained fruition.\n\nNow, O Rāma, I have narrated to you the circumstances connected with the history of my line and myself, as also of this place, O mighty-armed one, which you had asked me to relate.\n\nBut, O Kākutstha, while I was speaking, half the night has been spent. Do you now sleep, good betide you, so that you may not feel any difficulty while on the journey.\n\nThe trees stand motionless, and the beasts and birds are silent, and, O descendant of Raghu, all sides have become enveloped in nocturnal gloom.\n\nThe noon of night is gradually passing away; and the firmament thick-studded with stars resembling eyes, is illumined up with their light.\n\nAnd that dispeller of darkness, the mild-beaming moon is rising, gladdening the hearts of all creatures with his splendour.\n\nAnd night-ranging being terrible carnivorous Yakṣas and Rākṣasas —walk here and there.\n\nHaving said this the mighty ascetic of exceeding energy paused. And those ascetics honouring him, said, Excellent! Excellent!\n\nThis line belonging to the Kuśikas is exalted and devoted to virtue. And those foremost of men sprung in the Kuśa race are high-souled and like to Brahmarṣis .\n\nAnd specially you, O illustrious Viśvāmitra , art so. And that best of streams, Kauśikī, has added lustre to your lien.\n\nAnd the auspicious son of Kuśika having been extolled by those delighted ascetic, the foremost of their order—slept, like to the sun, when setting.\n\nRāma too along with Sumitrā ’s son having in admiration praised that tiger among ascetics, enjoyed the luxury of slumber.
37	1	37	Chapter XXXVII	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365905.html	On that celestial being engaged in austerities, the deities with Indra and Agni at their head, desirous of gaining over the generalissimo, Appeared before the Grand-sire.\n\nAnd, O Rāma , the gods with Agni at their head, bowing to him, addressed that possessor of the six attributes, the Grand-sir, saying,\n\nDo you now, O you conversant with resources, so order as is advisable in the interests of the worlds! Verily you are our prime way.’\n\nHearing the words of the deities, the Grand-sire of all creatures, consoling them with soft words, spoke to them saying:\n\n‘Even as the Mountain’s daughter has said, sons will not be born to you of your own wives. Her words is infallible of a certainty: there is no doubt about it.\n\nThis is the celestial Gaṅgā she on whom Hutāśana will beget a son—the foe-subduing generalissimo of the celestials.\n\nAnd the elder daughter of the Mountain will consider that son as brought forth by Umā; and Umā also will, without doubt, look upon him with regard.’\n\nHearing these words of him O descendant of Raghu , the gods bowing to the Grand-sire, paid him homage.\n\nThen, O Rāma, repairing to the Kailāsa mountain teeming with metals, the deities commissioned Agni with the view of having a son (born to him.)\n\n‘Do you, O god, accomplish this work of the oddities! O you of mighty energy, do you discharge your energy into that daughter of the Mountain, Gaṅgā.\n\nThereupon giving his promise to the gods, Pāvaka * (Fire) approached Gaṅgā, saying, ‘Do you, O Goddess, bear an embryo; for even this is the desire of the deities.’\n\nHearing this speech, she assumed a divine appearance. And beholding her mightiness, Agni was shrunk up on all sides.\n\nAnd then Pavaka from all sides discharged his energy into her, and thereat all her streams became surcharged with it,\n\nO descendant of Raghu. And to him staying at the head of all the deities, Gaṅgā spoke, saying, ‘O god, I am incapable of sustaining this new sprung energy of yours: I am burning with that fire, and my consciousness fails me.’\n\nThereupon that partaker of the oblations offered to the gods, said to Gaṅgā, ‘Do you bring forth your embryo on the side of this Himavat !’\n\nHearing Agni’s words, Gaṅgā of mighty energy cast her exceedingly effulgent embryo on her streams, O sinless one.\n\nAnd as it came out of her, it wore the splendour of molten gold; and in consequence of its fiery virtue, objects near and objects far were converted into gold and silver of unsurpassed sheen, while those that were more distant were turned into copper and iron.\n\nAs soon as the embryo was brought forth, the woods adjoining the mountain, being overspread with that energy, were turned into gold.\n\nAnd from that day, O descendant of Raghu, gold of effulgence like to that of fire, became known as Jātarūpa , O foremost of men!\n\nAnd when the son was born, the deities with Indra and the Maruts enjoined upon the Kṛttikā stars to suckle him.\n\n‘Surely he shall be son to us all’—concluding thus, they as soon as he was born, by turns began to dispense milk to him.\n\nThen the celestials called him Kārtikeya , saying, ‘Without doubt, this son shall become famed over the three worlds.’\n\nAnd hearing those words of theirs, the Kṛttikās bathed the offspring that had issued from her womb, flaming like fire, and with auspicious marks.\n\nAnd, O Kākutstha , since Kārtikeya had issued from (Gaṅgā’s) womb the celestials called that effulgent and mighty-armed one, Skanda .\n\nAnd then the teats of the Kṛttikās were filled with milk; and thereupon assuming six mouths, he began to suck milk from the teats of those six.\n\nHaving drunk the milk, that lord although then possessed of a tender frame, by virtue of his inborn prowess in one day vanquished the Dānava forces.\n\nAnd him possessed of mighty effulgence, the celestials assembled with Agni as their leader sprinkled with water, by way of installing him as their generalissimo.\n\nHe who, O Kākutstha, on earth revere Kārtikeya, is blessed, and attain righteousness, and being long-lived and obtaining sons and grand-sons, repair to the regions of Skanda.
38	1	38	Chapter XXXVIII	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365906.html	Having said those words to Rāma , composed of melodious letters, Kauśika again spoke to Kākutstha , saying,\n\nFormerly there was a king—lord of Ayodhyā -named Sagara . And it came to pass that righteous one, though eagerly wishing for children was without issue.\n\nO Rāma, Vidarbha ’s daughter, named Keśinī , was the elder wife of Sagara. And she was virtuous and truthful.\n\nThe second wife of Sagara was called Sumati , who was the daughter of Ariṣṭanemi and the sister of Suparṇa ( Garuḍa ).\n\nAnd with those wives of his, that mighty king, coming to the Himavat , began to practice austerities on the mountain Bhṛguprasravaṇa.\n\nWhen a full hundred years had been numbered, the ascetic that had been adored by means of these austerities, Bright, best of those endowed with truth, conferred a boon upon Sagara, saying.\n\nO sinless one, you shall obtain glorious offspring; and, O foremost of men, you shall attain unparalleled renown among Man.\n\nO child, one of your con sorts shall bring forth a son who will perpetuate your race; and the other give birth to sixty thousand sons.’\n\nAs that best of men was saying this, those daughters of kings, exceedingly delighted, propitiating him, addressed him with clasped hands.\n\nWho of us, O Brāhmaṇa , shall produce a single son, and who many? This, O Brāhmaṇa, we wish to hear. May your word prove true!\n\nHearing this, the highly pious Bhṛgu said these pregnant words, ‘Do you unfold your minds. Who wishes for what boon, between a single perpetuator of the line, and innumerable sons, possessed of mighty strength, and furnished with fame, and endowed with high spirits?’\n\nHearing the ascetic’s words, O descendant of Raghu , Keśinī in the presence of the monarch chose, O Rāma, a single son to perpetuate the line.\n\nAnd Suparṇa’s sister, Sumati, sixty thousand sons, high-spirited and furnished with fame.\n\nThen, O son of Raghu, having gone round the saint and bowed down the head, the king went to his own capital, accompanied by his consorts.\n\nAnd after a length of time, the elder, Keśinī, bore a son to Sagara, known by the name of Asamañja .\n\nAnd Sumati, O foremost of men, brought forth a gourd. And when it burst open, out came from it sixty thousand sons.\n\nAnd the nurses fostered them by keeping them in jars filled with clarified butter. And after a great length of time, they attained to youth.\n\nAnd after a long lapse of time, Sagara’s sixty thousand sons attained to youth and beauty.\n\nO foremost of men, [1] the eldest son of Sagara, taking those children, would, O descendant of Raghu, often cast them into the Sarayū , and in mirth behold them sinking in the waters.\n\nBeing thus evil-disposed, and injuring honest folks, and engaged in doing wrong to the citizens, he was banished by this father from the city.\n\nAsamañja had a son possessed of prowess, named Aṃśumān . And he was beloved of all men and fair-spoken towards everyone.\n\nO foremost of men, it came to pass that after a long time had gone by, that lord of earth Sagara made up his mind, saying, ‘I will sacrifice.’\n\nHaving determined upon it, that one versed in the Vedas set about it, in company with his priests.\n\n[back to top]\n\n[1] :\n\nThe text has Naraśreṣṭhas, put for Asamañja. Evidently this is an error. I make it a vocative.
39	1	39	Chapter XXXIX	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365907.html	When Viśvāmitra had ended, hearing his words, Rāma exceedingly pleased, spoke to that ascetic resembling flaming fire, saying,\n\nI am anxious to hear in detail, good betide you, how, O Brāhmaṇa , my ancestor arranged for the sacrifice.\n\nHearing those words of his, Viśvāmitra, smiling, eagerly spoke to Kākutstha , saying,\n\nDo you, O Rāma, hearken to the story of the high-souled Sagara ’s sacrifice. Śaṅkara ’s father-in-law is the far-famed Himavat . And approaching each other, the Himavat and the vindhya behold each other. And on the region lying between them took place, O foremost of men, that sacrifice of Sagara’s.\n\nAnd that country, O best of men, is excellent as a sacrificial ground. And, O Kākutstha, equipped with a powerful bow, that mighty car-warrior, living under Sagara’s sway, Aṃśumat , O child, followed the horse, for the purpose of protecting it.\n\nIt came to pass that with the intention of disturbing the sacrifice of that monarch, on a certain day Vāsava , assuming the, form of a Rākṣasī , stole away the sacrificial horse.\n\nO Kākutstha, on the horse of that high-souled one being stolen, the priests said to the king engaged in the ceremony, ‘On this auspicious day, has the sacrificial horse been stolen by violence. Do you, O Kākutstha, slay him that steals the horse, and bring it back. Otherwise the sacrifice will be defective, bringing us misfortune. Therefore, do you, O king, act so, that the sacrifice may not bemired with defects.’\n\nHearing the words of the priests, the king addressed his sixty thousand sons in the midst of his court, saying, Being, as this great sacrifice is, presided over by eminently pious Brāhmaṇas sanctified by mantras , I do not, you foremost of men, you sons, see how Rākṣasas may find entrance into it.’\n\nTherefore, repair you, and seek for the horse, you sons. Good betide you! Do you search the entire earth engarlanded with oceans; and do you search Yojana after Yojana , you sons. And do you delve the earth till you light upon the horse, by my command following the track of that stealer of the horse.\n\nI have been initiated into this sacrifice with my grand-sons and priests.’ I will stay here till you light upon the horse.\n\nAnd thereat the mighty princes, enjoined by their father, breathing high spirits, began to range the earth.\n\nO Rāma. Then, they each fell to delving the bowels of the earth for the space of a Yojana in length and breadth, with their hands resembling thunder-bolts in fed, and with darts like to thunder-bolts, and with gigantic ploughshares. And being thus rived, the earth, O descendant of Raghu , began to send forth loud cries.\n\nO Rāghava , O you hard to repress, there arose an uproar from serpents, and Asuras , and Rākṣasas, and other creatures, that were being slaughtered.\n\nO descendant of Raghu, they excavated the earth, O Rāma, for sixty thousand Yojanas , you, as if they had intended to reach the lowest depths underground.\n\nThus, O foremost of kings, those sons of the monarch dug all around Jambūdvīpa , filled with mountains.\n\nThereat, the gods together with the Gandharvas , and Asuras, and Pannagas , in trepidation appeared before the Grand-sire.\n\nAnd propitiating that high-souled one, they with melancholy countenances and in exceeding agitation, spoke these words to the Grand-sire,\n\nO adorable one, the entire earth is being excavated by the sons of Sagara; and many are the high-souled ones as well as the aquatic animals that are being slain in consequence.\n\nThis one is the disturber of our sacrifice, and by him has the sacrificial horse been stolen, saying this Sagara’s sons are committing havoc upon all creatures.
40	1	40	Chapter XL	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365908.html	Hearing the speech of the celestials, that possessor of the six attributes, the Grand-sire, spoke to them exceedingly frightened and deprived of their senses on beholding the prowess of Sagara ’s sons like to the Destroyer himself,\n\nThis entire Earth belong to the intelligent Vāsudeva , she being his consort. And that adorable one is indeed her lord. And assuming the form of Kapila , he unceasingly sustain the Earth. And the sons of king Sagara will be consumed by the fire of his wrath.\n\nThe pre-ordained excavation of the Earth, as well as the destruction of Sagara’s sons, had been foreseen by the farsighted.\n\nHearing the words of the Grand-sire those repressors of their foes, the three and thirty [1] celestials, being exceedingly rejoiced, went back to their respective quarters.\n\nAnd as the sons of Sagara were riving the Earth, there arose a mighty noise, like to the bursting of thunder.\n\nThen, having rived the entire Earth and ranged it all around, the sons, of Sagara together (returned to their father) and spoke to him.\n\nBy us has the Earth been extensively surveyed, and have powerful deities and Dānavas . Rākṣasas , Piśācas , Uragas and Pannagas been slain; and yet do we find neither the horse nor the stealer thereof. What are we to do now? Good betide you, do you consider it well.\n\nHearing those words of his sons, that foremost of kings, getting into a wrath, said, O descendant of Raghu .\n\n‘Do you yet again, good betide you, delve the earth, and having got at the stealer of the horse, cease.’\n\nReceiving this mandate of their sire, the sixty thousand sons of the high-souled Sagara rushed towards the depths of the earth.\n\nAnd as they were engaged in excavating, they beheld the elephant of the quarter resembling a hill, named Virūpākṣa , holding the earth.\n\nO son of Raghu, that mighty elephant, Virūpākṣa, held on his head the entire earth with its mountains and forests.\n\nAnd, O Kākutstha , when on sacred days the mighty elephant, from fatigue, shake his head, then takes place the earthquake.\n\nThereupon, O Rāma , going round that mighty elephant, and honouring him duly, they went on piercing the under earth.\n\nAnd having pierced the East, they pierced the South, and in the Southern quarter also they beheld a mighty elephant, the high-souled Mahāpadma , resembling a huge hill, holding the earth on his head. And thereat they marvelled greatly.\n\nAnd having gone round him, the sixty thousand sons of the high-souled Sagara began to penetrate into the Western region.\n\nAnd in the western quarter also those highly powerful ones beheld the elephant of that quarter named Saumanas, resembling a mighty mountain.\n\nAnd having gone round him and asked him as to his welfare, they delving on, arrived at the Northern region.\n\nAnd on the North like wise, O foremost of the Raghus , they beheld Bhadra , white as snow, holding this earth on his goodly person.\n\nHaving felt as well as gone round him, those sixty thousand sons of Sagara went on penetrating the depths of the earth.\n\nThen repairing to the famous North eastern region, Sagara’s sons becoming enraged, began to dig the earth.\n\nAnd there those high-souled, exceedingly powerful and vehement ones beheld the eternal Vasudeva in the guise of Kapila.\n\nAnd there also, experiencing exceeding delight, O descendant of Raghu, they found his horse, browsing hard by.\n\nAnd knowing him to be the destroyer of the sacrifice, they bearing spades, and ploughs, and innumerable trees and crags, with eyes reddened with ire, furiously rushed against him, exclaiming, ‘Stay! Stay! And you it is that hast stolen our sacrificial horse.’ O you of wicked understanding, know that you have fallen into the hands of the sons of Sagara.\n\nHearing this speech of theirs, Kapila, O descendant of Raghu, overwhelmed with rage uttered a tremendous roar.\n\nAnd then, O Kākutstha, the sons of Sagara were reduced to ashes by the high-souled and incomparable Kapila.\n\n[back to top]\n\n[1] :\n\nThe eight Vasus, eleven Rudras, twelve Adityas and two Aśvins.
41	1	41	Chapter XLI	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365909.html	Seeing the delay on the part of his sons, King Sagara , O son of Raghu , addressed his grandson, flaming in his native energy, saying,\n\nYou are heroic and accomplished and like to your uncles. Do you enquire into the circumstances that have befallen your uncles, as also about the way by which the horse has escaped.\n\nAnd as there are strong and mighty creatures inhabiting the Earth’s interior, with the view of resisting them, do you take your how along with your scimitar.\n\nAnd honouring those that deserve to be honoured and slaying such as disturb you, do you, having attained your end, come back, becoming the instrument for the completion of my sacrifice.’\n\nThus duly enjoined by the high-souled Sagara, Aṃśumān endowed with fleet vigour, taking his bow as well as his scimitar, set out.\n\nAn commanded by the monarch, he found the underground way that had been carved out by those high-souled ones.\n\nHe found an exceedingly powerful elephant belonging to the cardinal point, worshipped by deities, and Dānavas , and Rākṣasas , anc goblins, and birds, and Uragas .\n\nHaving gone round him, and asked him as to his welfare, he enquired after his uncles and the stealer of the horse.\n\nHearing this, the mighty-minded elephant of that quarter answered, ‘O son of Asamañja having attained your object, you will speedily return with the horse.’\n\nAnd hearing those words of his, Aṃśumat by turns duly asked the same question of all the elephants belonging to the cardinal points.\n\nAnd being honoured by those guardians of the cardinal points, knowing words as well as their application in regard to time, place, and person he was asked by them saying, ‘Did you come with the horse?’\n\nHearing those words of theirs, that one of fleet vigour repaired to the spot where the sons of Sagara, his uncles, had been reduced to a heap of ashes.\n\nAnd (arriving there), Asamañja’s son, smitten with grief, and being exceedingly afflicted at their destruction, bewailed in heaviness of heart.\n\nAnd exercised by grief and sorrow, at foremost of men espied there the sacrificial horse straying near.\n\nAnd desirous of offering oblations of water to those princes, that highly powerful one, in need of water, did not find any watery expanse in the neighbourhood.\n\nAnd it came to pass, O Rāma , that surveying wide, he descried the maternal uncle to the princes, Suparṇa , resembling the Wind.\n\nAnd thereupon Vinatā ’s son possessed of mighty strength spoke to him, saying, ‘Do not ament, O foremost of men. The destruction of hese was for the welfare of all.’\n\nThese highly powerful ones had been consumed by the peerless Kapila , therefore, you ought not to offer water to them in consonance with social usage.\n\nGaṅgā , O foremost of men, is the elder laughter of Himavat . In her (streams) do you perform the watery rites of your uncles,\n\nO mighty-armed one: let that purifier of the worlds lave these reduced to a heap of ashes. And on these ashes being watered by Gaṅgā, dear to all, the sixty thousand sons of Sagara will repair to the celestial regions.\n\nDo you, O highly pious one, go back, taking this horse, O foremost of men; and do you complete the sacrifice of your grand-father,\n\nO hero. Hearing Suparṇa’s speech, the exceedingly powerful Aṃśumat of mighty asceticism speedily taking the horse, retraced his steps.\n\nThen coming to the king who had been initiated into the ceremony, he, O descendant of Raghu, faithfully communicated to him the words of Suparṇa.\n\nHearing this sorrowful intelligence, the king duly finished the sacrifice agreeably to the scriptures.\n\nAnd having seen the completion of the sacrifice, that lord of earth entered his capital; but the king could not see how to bring Gaṅgā on earth.\n\nAnd without being able to ascertain it, the mighty monarch after a long course of time, and having reigned for thirty thousand years, ascended heaven.
42	1	42	Chapter XLII	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365910.html	When Sagara had bowed to the influence of Time, the subjects selected the righteous Aṃśumat for their king.\n\nO descendant of Raghu , Aṃśumat proved a great ruler. And his son, the celebrated Dilīpa , was also a great king.\n\nO Raghu’s son, consigning to Dilīpa his kingdom, Aṃśumat entered upon rigid austerities on the romantic summit of the Himavat .\n\nHaving for the space of thirty-two you sand years carried on austerities in the woods, that highly famous one, crowned with the wealth of asceticism, attained the celestial regions.\n\nThe exceedingly powerful Dilīpa, hearing of the destruction of his grand-fathers, was stricken with grief; yet he could not ascertain his grandfathers, was stricken with grief; yet he could not ascertain his course about it.\n\nHe constantly thought as to how Gaṅgā could be brought down, how to perform their watery rites, and how to deliver them.\n\nAs that pious one furnished with self-knowledge was always meditating upon this, an eminently virthous son was born to him named Bhagīratha .\n\nPerforming numerous sacrifices, the mighty king Dilīpa reigned for thirty thousand years.\n\nAnd without having arrived at any definite decision in regard to their deliverance, the king, O puissant one, being attacked with an ailment, breathed his last.\n\nHaving sprinkled his son Bhagīratha in the way of installing him in the kingdom, that prime of men, the king, by virtue of his own acts, repaired to the region of Indra .\n\nO descendant of Raghu, that royal saint Bhagīratha was possessed of righteousness. And being without issue, and desiring to obtain it, the mighty monarch consigned his kingdom and his subjects to the care of his counsellors, and engaged in bringing down Gaṅgā.\n\nAnd, O Raghu’s descendant, restraining his senses, and eating once a month, and surrounding himself with five fires, and with arms upraised, he for a long lapse of time performed austerities at Gokarṇa . And as he was performing his terrible austerities, a thousand years rolled away.\n\nAnd thereat that possessor of the six attributes and lord of all creatures, Brahmā , was well pleased with that high-souled monarch. And presenting himself together with the celestials, the Grand-sire thus spoke to the high-souled Bhagīratha engaged in austerities.\n\nO Bhagīratha, O mighty monarch, pleased am I with you. O lord of men, on account of your ardent austerities: do you, O you of excellent vows, ask for the boon you would have.\n\nThereupon that great car-warrior, the highly powerful and mighty-armed Bhagīratha, with clasped hands, said to the grand sire of all creatures,\n\nIf adorable one, you are pleased with me, if you would grant me the fruit of my asceticism, may Sagara’s sons receive water at my hands; and on the ashes of those high-souled ones being laved by the waters of Gaṅgā, may my great-grand-father without fail repair to heaven!\n\nAnd, O divine one, I beseech you, may our line never languish for want of offspring. May, O God, this prime boon light upon Ikṣvāku ’s race!\n\nWhen the king had said this, the Grand-sire addressed him these sweet and auspicious words composed of melting letters.\n\nO mighty car-warrior Bhagīratha, high is this your aim. Be it so, good betide you, you enhancer of the Ikṣvāku line.\n\nThis Haimavatī Gaṅgā, Himavat’s elder daughter, even her to hold, O king do you employ Hara .\n\nFor Gaṅgā’s fall, O king, Earth will not be able to sustain. And to hold her, O king find I none save the wielder of the Trident.’\n\nHaving thus addressed the monarch, and greeted Gaṅgā, the creator of the worlds repaired to heaven with the celestials.
44	1	44	Chapter XLIV	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365912.html	Then having arrived at the Ocean, the king wending in Gaṅgā ’s wake, entered underneath the Earth, at that spot where those (sons of Sagara ) had been reduced to ashes. And, O Rāma , on the ashes being washed by the waters of Gaṅgā, Brahmā , the lord of all creatures thus spoke to the monarch.\n\nO most puissant of men, the sixty thousand sons of the high-souled Sagara have been delivered and they have ascended heaven like to celestials themselves.\n\nO lord of earth, as long as the waters of the ocean shall endure in the world. Sagara’s sons shall reside in heaven like to celestials.\n\nThis Gaṅgā shall become your eldest daughter; and she shall attain celebrity among all, being called after your name.\n\nAnd Gaṅgā is called both Tripathagā and Bhāgīrathī . And she is know as Tripathagā, is consequence of her proceeding in three directions.\n\nDo you now, O lord of men, her offer oblations of water to your grand-sires, and thereby, O king, make good your promise.\n\nO king, that foremost of righteous ones, your ancestor of exceeding renown, had failed to attain his desire.\n\nO child Aṃśumat likewise unparalleled in the worlds in energy, had failed in realising his cherished promise of bringing down Gaṅgā.\n\nThen again that royal saint, crowned with qualities; of austerities like to mine, ever abiding by his Kṣatriya duties, even Dilīpa ’s self, your exceedingly puissant sire.\n\nO eminently righteous one, had failed in bringing down Gaṅgā according to his cherished resolve, O sinless one. And now, O foremost of men, that promise having been fulfilled by you, you shall attain signal glory in the world by the common consent of all.\n\nAnd, O vanquisher of your foes, having brought about Gaṅgā’s dissension, you shall from this act of your also attain the regions of Brahmā.\n\nDo you, O best of me, lave thyself in these waters worthy of the pious, O prime of men, and thereby become purified, and attain sanctity.\n\nDo you perform the watery rites of your grand-sires. May luck be your, I shall now repair to my own regions: do you depart, O king.\n\nHaving said this, the illustrious lord of the celestials the Grand-sire of all creatures, went to the celestial regions.\n\nThe royal saint king Bhagīratha also of high fame having performed his ablutions and purified himself, and duly and in proper order offered oblations of water to the sons of Sagara, entered his capital. And attaining exceeding prosperity, that foremost of men ruled his kingdom.\n\nO descendant of Raghu , having him as their sovereign, the people rejoiced greatly; and with their griefs removed and prosperity secured, they lived in peace of mind.\n\nThus, O Rāma, have I ḍefailed to you the history of Gaṅgā. Auspiciousness may you obtain! Good betide you, the evening draw nigh.\n\nHe that recite this story conferring prosperity, fame, long life, and heaven to Vipras , Kṣatriyas , and other, attain the good graces of his ancestors and the celestials.\n\nO Kākutstha , he that listen to the sacred history of Gaṅgā’s descent, conferring length of days, attain all his desires, and all his sins are destroyed, and his life and fame increase.
45	1	45	Chapter XLV	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365913.html	O Brāhmaṇa , wonderful is the story that you have recited to us, viz; that of Gaṅgā ’s sacred dissension and the replenishing of the Ocean.\n\nAnd, O afflicter of foes, as we had been reflecting upon all this at length, the night has passed away as if it were as moment.\n\nAnd the live-long night has passed away as I in company with Sumitrā ’s son, was pondering over Viśvāmitra ’s auspicious speech.’\n\nThen in the morning which happened to be bright, that subduer of his foes, Raghu ’s descendant, addressed the ascetic Viśvāmitra, who had finished his devotion.\n\nThe auspicious night is past, and we shall (again) listen to your wonderful narrations. Let us now cross over this sacred stream, foremost of rivers, wending in three ways.\n\nAnd learning that you have arrived at this place, the pious ascetics have speedily come hither, and have also brought this barque with a spacious carpet.\n\nHearing those words of the high-souled Rāghava , Kauśika crossed over the crowds of ascetics; and on reaching the north bank, he paid homage to the saints. And when they had landed on the banks of the Gaṅgā, they beheld a city named Viśālā .\n\nAnd thereupon speedily that that foremost of ascetics in company with Rāghava, went towards Viśālā, beautiful and elegant like to the celestial regions.\n\nThen the highly wise Rāma , with folded hands, asked that mighty ascetic Viśvāmitra concerning the excellent city of Viśālā.\n\nO mighty ascetic, what royal line reside in yonder large city? I desire to hear this, good betide you; and great is my curiosity.\n\nHearing those words of Rāma, that foremost of ascetics began to relate the history of Viśālā, saying,\n\nDo you listen, O Rāma to what I had heard from Śakra relating this history; and, O descendant of Raghu, do you listen to all that befell in this city.\n\nFormerly in the Krita age, O Rāma, Diti ’s highly powerful sons, as well as those of Aditi , possessed of prowess, and virtuous and pious, high-souled ones both.\n\nO foremost of men, fell to reflecting, ‘How can we become exempt from decrepitude and disease, and immortal.’\n\nAnd as they reflected, it struck them, ‘By churning the ocean of milk, we must obtain ambrosia.’\n\nThen deciding upon churning (the ocean), those ones of immeasurable. energy making Vasuki the cord, and the Mandara (hill), the stick, began to chum the deep.\n\nAfter a thousand years had gone by, the hoods (of the serpent) serving as the churning cord, began to vomit virulent venom and to bite at the crags, with their fangs.\n\nAnd thereat there came out powerful poison like to fire; and in consequence the entire universe with celestials, and Asuras , and men, began to bum.\n\nAnd thereupon, intending to seek refuge, they appeared before that mighty god, Śaṅkara , or Paśupati , or Rudra , hymning him.\n\n‘Save us, Save us.’ When that master, the lord of the celestials, was being thus addressed by the deities, there appeared before them Hari bearing the conch and the discus.\n\nSmiling Hari said to the trident-bearing Rudra, ‘O chief of the celestials, since you are the foremost of the gods, this that has come out of the ocean churned by the celestials, in your. Remaining here, O lord, do you receive the first offering in the form of this poison.’\n\nHaving said this, that best of celestials vanished there. Witnessing the dismay of the celestials, and hearing also the words of Śārṅgiṇa, Śiva took in that dreadful poison as if it were nectar; and then leaving the deities, the worshipful Hara wen away.\n\nAnd then, O descendant of Raghu, as the celestials resumed the churning, that foremost of hills serving as the cord, entered the subterranean regions.\n\nThereupon the gods and the Gandharvas felt to extolling the slayer of Madhu , saying, ‘You are the way of all beings, of the celestials in especial, do you, O mighty-armed one, protect us, and recover the mountain.’\n\nHaving heard this, Hṛṣīkeśa , or Hari, assuming the form of a tortoise, stood in the sea, supporting the hill on his back.\n\nThat Soul of all, Keśava , best of male beings, taking hold of the top of the hill by his hand, began to chum the deep, stationed in the midst of the celestials.\n\nAfter a thousand years, had rolled on, arose a male being impregnated with the Āyurveda , of exceedingly righteous soul, called Dhanvantari , bearing in his hands a stick, and a Kamaṇḍalu And there arose also, from the cream of the churning waters, those magnificent dames the shining Apsaras .\n\nAnd, O foremost of men, as they had emerged from water, they are called Apsaras.\n\nThere sprang sixty koṭis of shining Apsaras And, O Kākutstha , the female attendants of those are numberless.\n\nAnd neither the deities nor the Dānavas would accept them, and in consequence of this non-acceptance, they are known as women belonging to all.\n\nAnd then, O Raghu’s descendant, arose the eminently pious daughter of Vāruṇa , Vāruṇī who fell to looking for acceptance.\n\nAnd Diti's sons, O Rāma, did not accept the daughter of Vāruṇa and Aditi’s sons, O hero accepted that one of blameless limbs.\n\nHence Diti’s son go by the name of Asuras and Aditi’s by that of Suras . And the celestials became exceeding glad, on having accepted Vāruṇī.\n\nO foremost of men, next arose ucchaiśravā best of horses, and also Kaustubha ; and next, the excellent ambrosia.\n\nO Rāma, tremendous was the carnage for the possession thereof (ambrosia); and Aditi’s and Diti’s sons fought together.\n\nAnd the Asuras assembled together with the Rākṣasas ; and, O hero, mighty was the battle that was fought, striking terror into the three worlds.\n\nAnd when a great havoc had been committed the highly powerful Viṣṇu , assuming a captivating form speedily stole away the ambrosia.\n\nAnd those that came forward before that best of male beings, Viṣṇu, knowing no deterioration, were crushed in conflict by Viṣṇu in a different form.\n\nAnd in that exceedingly dreadful battle between the sons of Diti and Aditi, those heroic ones viz., Aditi’s heroic sons slaughtered those of Diti.\n\nHaving slaughtered the sons of Diti’s and regained his kingdom, he happily began to rule the worlds, containing saints and Cāraṇas .
46	1	46	Chapter XLVI	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365914.html	On those sons of her being slain, Diti afflicted with great grief, thus addressed her husband, Marīci ’s son, Kaśyapa .\n\nO adorable one, your high-souled sons have slain mine. I now wish for a son, who, obtained through long austerities, will be able to slay Śakra .\n\nI will engage in austerities: it behoves you to grant me such an embryo, such a slayer of Śakra it behoves you to promise me.\n\nHearing those words of hers, Marīcī’s son, Kaśyapa of exceeding energy answered the deeply aggrieved Diti, saying.\n\nBe it so. Good betide you, do you become pure, O ascetic. If you remain pure, when a full thousand years shall be complete, you will give birth to a son who will slay Śakṣa in battle.\n\nAnd through me, you will give birth to a son that will destroy the three worlds. Having said this, that highly energetic one rubbed her persoṅ with his palm. And having rubbed her, he said, ‘Luck!’ and then went away to carry on austerities.\n\nWhen he had gone, Diti, O foremost of men, becoming exceedingly delighted, went to, Kuśaplava and began to practise rigid mortifications.\n\nO foremost of men, as she was practising austerities, the thousand-eyed deity most dutifully ministered to her.\n\nThe thousand-eyed one provided for her fire, and Kuśa , and faggots, and water, and fruits, and roots, and other things that she wanted.\n\nAnd at all times, Śakra served Diti by rubbing her person, and removing her fatigue.\n\nWhen ten years only were wanting to complete the thousand years, Diti, O descendant of Raghu , being exceedingly delighted, thus spoke to the thousand-eyed one.\n\nO best of those endowed with prowess, of me engaged in austerities, ten years only remain (to complete the period.) And after that time, good betide you, you will behold your brother.\n\nI will, O son, bind him to you in affection, whom I had besought for to compass your destruction, so that, the fever of your heart removed, you will with him enjoy the victory of the three worlds.\n\nOn your high-souled sire having been besought by me, he, O foremost of celestials, granted me the boon that after a thousand years, I shall obtain a son.\n\nAnd it came to pass that having said this, the sun being in his meridian, the worshipful Diti with her feet placed at that part of the bed which should contain her head, was overpowered by sleep.\n\nAnd thereupon seeing her resting her feet at the place where she should place her head, and consequently unclean, Śakra was exceedingly delighted, and smiled.\n\nO Rāma , Purandara entered into her womb, and that highly self-controlled one served the embryo in seven parts.\n\nAnd the embryo being pierced by the thunder-bold of an hundred knots, cried at the top of its voice, and thereat Diti awoke.\n\n‘Do not cry, do not cry,’ exclaimed Śakṣa: and even while it was crying, the mighty-minded Vāsava continued piercing it.\n\n‘Do not slay it; do not slay it’ said Diti. Thereupon, in consideration of the honour of his mother, Śakra went out.\n\nThen he with clasped palms accosted Diti, saying, ‘O worshipful one, you did sleep with they feet placed where your head should have lain, and hast therefore become impure. And finding this opportunity, I severed in seven pieces that would-be slayer of mine in battle. Do you, O worshipful one, excuse me.’
48	1	48	Chapter XLVIII	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365916.html	Having met together they enquired after each other’s welfare. And then Sumati spoke to the mighty ascetic, saying.\n\nGood betide you, boasting the prowess of celestials of elephantine or leonine gait, heroic, resembling tigers or bulls, possessed of expansive eyes like lotus-petals, bearing scimitars and bows and quivers, like to the Aśvins in grace, endowed with youth, like to celestials fancy-led, descended from ethereal regions to the earth beneath, whose sons; O ascetic, are these boys, and what for have they come hither, and why also is it that they journey of foot?\n\nAnd adorning all directions, like to the Sun or the Moon adorning the firmament, and resembling each other, in personal proportions, and expressions, and gestures, and equipped with excellent weapons, and war-like, how have these paragons of men, come into this impracticable way? I Wish to hear all this related truly.\n\nHaving heard his words, Viśvāmitra faithfully related all about it. Hearing Viśvāmitra’s words, the king was extremely surprised; and having those sons of Daśaratha as his all-worthy guests, received with becoming respect those highly powerful ones deserving of hospitality.\n\nMeeting with such splendid reception from Sumati, those descendants of Raghu spent there a night, and the next day set out for Mithila .\n\nBeholding Janaka ’s beauteous city, the ascetics exclaiming, ‘Excellent’ fell to admiring Mithilā .\n\nAnd in a grove at Mithilā, Rāghava saw an ancient, lonely, and romantic asylum, and asked that foremost of ascetics, saying.\n\nWhat is this that look like an asylum, though without any ascetics? I wish to hear, O worshipful one, to whom this asylum belonged in time past.\n\nHearing this speech addressed by Raghu’s descendant that one versed in speech, the highly energetic and mighty saint, Viśvāmitra, answered.\n\nAh! Do you listen. I will tell you through the wrath of what high-souled one this hermitage came to he cursed.\n\nO foremost of men, this excellent asylum honoured by the celestials themselves, formerly belonged to the high-souled Gautama .\n\nHere, O illustrious prince, in days of yore Gautama in company with Ahalyā earned on austerities for a long series of years.\n\nAnd perceiving occasion Śacī ’s lord, the thousand-eyed deity assuming the form of that ascetic thus addressed Ahalyā.\n\nO exceedingly beautiful one, those bent upon sport, do not stay for the menstrual season. And, O graceful one, I desire to enjoy your company (on the instant).\n\nThereupon, out of curiosity, that one of perverse understanding consented to the proposals of the chief of the celestials.\n\nThen, having attained her object, she spoke to that foremost of the celestials, saying, ‘O best of the immortals, I have obtained my desire, do you speedily go from this place, O lord. Do you, O lord of the celestials, from a sense of respectability preserve yourself and me also.’\n\nIndra too said to Ahalyā, ‘O you of shapely hips, pleased am I. Now I repair to my own place?\n\nHaving known her thus, Indra, O Rāma , exceedingly apprehensive of Gautama, then hurriedly sallied out of the thatched cottage.\n\nJust at this time, Indra saw that mighty ascetic Gautama entering, that foremost of anchorets, incapable of being repressed by the deities and the Dānavas , and equipped with ascetic energy, having based in the waters of holy spots, and flaming like fire, carrying faggots and Kuśa grass.\n\nAnd seeing him, the countenance of the lord of the celestials turned pale. And seeing the wicked thousand-eyed deity in the guise of an ascetic, the well-behaved anchorite fired with rage said.\n\n‘And since, O you of wicked understanding, assuming my form, you have done this foul-deed, you shall lose your scrotum.’\n\nAnd soon as the high-souled Gautama had said this in ire, the scrotum of the thousand-eyed one dropped to the earth.\n\nAnd having seen Śakra in this plight, he cursed his wife also, ‘These weary thousand years you shall pass, feeding upon air, without food, engaged in asceticism in the dust, and you shall remain in this hermitage unseen of any. And when the irrepressible son of Daśaratha, Rāma, shall come to this deep wood, you shall be cleansed of your sin. And, O wicked one, ministering to him the rites of hospitality with a mind free from ignorance and covetousness, you shall in your own form with joy regain my side.’\n\nHaving said this the highly energetic Gautama of rigid austerities, forsaking this hermitage, began to carry on penances on the romantic summit of the Himavat , inhabited by Siddhas and Cāraṇas .
49	1	49	Chapter XLIX	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365917.html	And having been deprived of his scrotum, Śakra with eyes tremulous with fear, addressed the celestials with Agni at their head, as well as he Siddhas and the Gandharvas and the Cāraṇas , saying,\n\nI have accomplished the work of the celestials by stirring the ire of the high-souled Gautama , and thereby disturbing his austerities.\n\nAnd in doing so, I have been deprived of my scrotum; and Ahalyā also has been put down. And I have deprived him of his ascetic energy by causing him to utter a mighty curse.\n\nAnd, therefore, you celestials, and saints, and Cāraṇas, you should restore my scrotum to me who have served the gods.’\n\nHearing Śatakratu ’s (performer of an hundred sacrifices, one of the appellations of Indra ). The manes of ancestors, words, the deities along with the Maruts led by Agni, presented themselves before the divine Pitṛs . And then Agni addressed the latter, saying.\n\nThis ram is possessed of a scrotum; while Śakra has been deprived of his. Do you taking the scrotum of the ram furnish Śakra with it.\n\nAnd although deprived of the scrotum, the ram will be able to grant consummate satisfaction to you. And on those that will offer such a ram for your entertainment, you will bestow undying and profuse merit.’\n\nHearing Agni’s speech, the assembled Pitṛs, rooting up the scrotum of the ram, joined it to the person of the thousand-eyed deity.\n\nThence forth, O Kākutstha , the divine Pitṛs together feast upon scrotumless rams, for their scrotum had been joined to the person of Indra.\n\nThenceforth, O Rāghava , Indra also through the high-souled Gautama’s ascetic energy, has been bearing the scrotum of a ram.\n\nTherefore, O highly powerful one, do you enter into the hermitage of that pious one, and deliver the dignified and divinely fair Ahalyā.\n\nOn hearing Viśvāmitra ’s words, Rāghava in company with Lakṣmaṇa , placing Viśvāmitra in their front, entered the asylum.\n\nThey beheld that magnificent dame flaming in ascetic energy; and incapable of being gazed at too near even by the celestials and the Asuras ; as if created by the Deity to be the divinely charming Woman; like a flame hid in smoke; or the brightness of the full moon clouded and dimmed in mist; or the solar splendour incapable of being beheld of account of clouds.\n\nAnd by virtue of Gautama’s word, she had been incapable of being seen by any in the three worlds, till the sight of Rāma . And now the curse having come to an end, she could be perceived by them.\n\nThe two descendants of Raghu then took hold of her feet; but remembering Gautama’s words, she on her part took hold of theirs. And with a collected mind she gave them water for their feet as well as Arghya , and extended to them the rites of hospitality.\n\nAnd the Kākutstha accepted the homage thus rendered according to the ordinance. And blossoms began to shower copiously to the sounds of kettledrums; and the Gandharvas and the Apsaras began to rejoice greatly.\n\nAnd exclaiming, ‘Excellent, excellent,’ the celestials honoured Ahalyā, as with as person purified by penance, she again come under Gautama’s governance.\n\nAnd the highly energetic Gautama also happy on his union with Ahalyā, honoured Rāma highly, and that one of mighty mortifications then became engaged in austerities.\n\nAnd having duly received signal honours from the great ascetic Gautama, Rāma set out for Mithilā .
50	1	50	Chapter L	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365918.html	Then proceeding north-east Rāma is company with Sumitrā ’s son, placing Viśvāmitra at their head, appeared before the sacrificial ground.\n\nAnd Rāma and Lakṣmaṇa said to that puissant ascetic, Great is the pomp and splendour of the high-souled Janaka ’s sacrifice. And, O pious one, many thousand of Brāhmaṇas inhabiting various regions, and well-read in the Vedas (have come to this sacrifice);\n\nAnd the abodes of ascetics are thronged with hundreds of cars. Do you, O Brāhmaṇa , arrange for some place were we may put up.\n\nHearing Rāma’s words, the mighty ascetic Viśvāmitra selected for their abode a well-watered spot free from bustle and tumult.\n\nAnd hearing of Viśvāmitra’s arrival, the best of monarchs without blame, placing the priests Śatānanda before him, as well as the high-souled family priests, speedily taking the Arghya , at once went out in humble guise, and offered it to Viśvāmitra according to the ordinance.\n\nHaving accepted that homage of the high-souled Janaka, the ascetic enquired after the king’s welfare, and the uninterrupted performance of his sacrifice. And the king together wiṃ his priests, having enquired of the ascetics as to their welfare, cheerfully embraced them all in a proper way.\n\nThen he with clasped hands, spoke to that foremost of anchorets, saying, O worshipful one, do you along with these eminent ascetics take your seat.\n\nHearing Janaka’s words, the mighty ascetic sat him down. And the king also, in company with his priests and counsellors sat down around in order of rank.\n\nAnd then the monarch looking into Viśvāmitra’s face, said, To-day by the grace of the gods, has my sacrifice been crowned with success, to-day.\n\nHave I reaped the fruit of my sacrifice by beholding your worshipful self. Blessed and obliged am I whose sacrificial ground, O Brāhmaṇa, has been graced by you along with these ascetics.\n\nTwelve days, O Brahmarṣi , have been fixed for the period of initiation by the sages. On the expiry of that term, you will, O Kauśika , behold the celestials come to the sacrifice for claiming their respective shares.\n\nHaving said this, the king with a cheerful countenance, with folded hands, again intently asked that foremost of ascetics.\n\nThese youths, good betide you, like to celestials in prowess, of the gait of lions or elephants, heroic, and resembling tigers or bulls, of expansive eyes like to lotus-patals, bearing scimitars, quivers and bows, graceful like to the Aśvins , endowed with youth, resembling immortals fancy-led from heaven to the earth, whose sons, O ascetic, are they, and what for have they come, and why again have they come afoot? And bearing excellent arms, whose sons, O mighty anchorite, are these heroic ones, who grace this place even as the sun and the moon do the welkin, and resemble each other in bodily proportions, expression, and gestures; wearing side-locks and of warlike mien? This I would hear truly related.\n\nHearing this speech of the high-souled Janaka, that ascetic of immeasurable soul related all about Daśaratha ’s sons.\n\nTheir sojourn in Siddhāśrama , and the slaughter there of the Rākṣasas , their undaunted journey, the sight of Viśālā , the encounter with Ahalyā and Gautama , Rāma’s curiosity about the mighty bow, and visit there for beholding the same.\n\nHaving related all this to the high-souled Janaka, that one endowed with exceeding energy, the mighty ascetic Viśvāmitra, paused.
52	1	52	Chapter LII	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365920.html	Upon seeing that foremost of these reciting mantras , the highly powerful and heroic Viśvāmitra , exceedingly delighted, bowed to him in humility.\n\nHaving enquired as to the pleasantness of Viśvāmitra’s journey, the high-souled an adorable Vasiṣṭha ordered a seat for the former.\n\nAnd on the intelligent Viśvāmitra having been seated, that best of ascetics properly entertained him with fruits and roots.\n\nAnd having accepted Vasiṣṭha’s hospitality, that foremost of monarchs, the exceedingly energetic Viśvāmitra then enquired of Vasiṣṭha as to the welfare of his asceticism, his Agnihotras , and his disciples, and his trees. Thereupon Vasiṣṭha of fierce austerities communicated the welfare of all to that best of king, Viśvāmitra, seated at his ease.\n\nThen Brahmā ’s son, Vasiṣṭha, the best of those reciting mantras, asked Viśvāmitra, saying.\n\nO king, is it well with you? And, O king, do you rule your subjects pleasing them consistently with morality?\n\nO virtuous one, are your retainers maintained on salaries from the kingdom? Do they abode by your mandates? And, O destroyer of foes, hast you vanquished your enemies?\n\nAnd O repressor of foes, is it well with you as to, O most powerful of men, your forces; exchequer, and friends, and, O sinless one, sons and grandsons?’\n\nThereupon the highly powerful king, Viśvāmitra, with humility communicated to Vasiṣṭha his complete welfare.\n\nHaving conversed for a long time, those virtuous ones, experiencing exceeding joy, ministered to each other’s delight.\n\nThen, O descendant of Raghu , after the conversation had ended, the adorable Vasiṣṭha, smiling, addressed Viśvāmitra, saying.\n\nO highly powerful one, I desire to properly entertain you of immeasurable power, as well as your forces, do you, therefore, accept my hospitality.\n\nDo you receive the hospitality which I extend to you. O king, you are the foremost of guests, and art worthy of assiduous homage.’\n\nBeing thus addressed by Vasiṣṭha, that mighty ascetic, king Viśvāmitra; said, ‘Even by this word of your relative to receiving me, hast you in fact done so.’\n\nAnd, O worshipful one, even with the fruits and roots that are in your asylum, with the water for washing my feet, and for sipping, you, with the sight of your revered self, have I been.\n\nO profoundly wise one, excellently entertained by you, who art yourself worthy of homage. I how to you. I will go now. Do you regard me with a friendly eye.’\n\nAs the king was speaking thus, the righteous- souled and generous Vasiṣṭha again and again pressed him to accept his hospitality.\n\nThen Gādhi ’s son answered Vasiṣṭha, ‘Very well. O potent ascetic, let that be which find favour in your sight.’\n\nThis having been said by him, Vasiṣṭha, the best of those reciting mantras, joyfully called his sacrificial dappled cow, capable of purging away sins.\n\nO Śabala ! do you come soon; and hear my words. I intend to entertain this royal saint together with his forces. Do you enable me to entertain him, by yielding excellent viands.\n\nAnd, O divine one, O you that confer everything that is desired, do you grant everyone whatever be ask among edibles impregnated with the six tastes.\n\nAnd do you, O Śabala, speedily create sapid viands to be chewed, sucked, licked, or drunk.
51	1	51	Chapter LI	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365919.html	Hearing the narration of the intelligent Viśvāmitra , Gautama ’s eldest son, the exceedingly energetic Śatānanda of rigid austerities, highly effulgent by virtue of his asceticism, with his down standing on end wondered greatly at the sight of Rāma .\n\nAnd seeing the king’s sons seated at their ease, he said to that foremost of ascetics, Viśvāmitra.\n\nO most powerful of anchorets, by you was. my illustrious mother, grown old in asceticism, shown to the king’s son.\n\nDid my famous and exalted mother entertain with the produce of the woods this one worthy of every one’s homage?\n\nO highly energetic one, has that old story relative to my mother having been wronged by that celestial, been communicated to Rāma?\n\nO Kauśika good betide you, has my mother, in consequence of beholding Rāma, been united with my revered sire?\n\nAnd, O son of Kuśika , has the highly energetic Rāma come hither, after having been rendered homage by my high-souled revered sire?\n\nAnd, O Kuśika’s son, was my revered sire of quiescent soul, saluted by Rāma when he arrived there?\n\nHearing those words of his, the mighty ascetic Viśvāmitra, skilled in speech, replied to Śatānanda, cognizant of words, saying.\n\nO best of ascetics, nothing necessary was omitted by me, but everything has been done. And the ascetic’s wife has been united with him, even as Renuka with Bhṛgu ’s son. ( Jamadagni , father of Paruśurāma).\n\nHearing the speech of the intelligent Viśvāmitra, the exceedingly energetic Śatānanda said to Rāma.\n\nArt you well come, O chief of men? It is by our luck that, O descendant of Raghu , you have come to us, headed by the respected Maharṣi Viśvāmitra.\n\nThis highly energetic. Viśvāmitra, this Brahmarṣi is of prowess measureless; and deeds inconceivable, by virtue of his asceticism. Him you know as the prime way.\n\nO Rāma, there exist of this earth not one that is more fortunate than thyself. Your protector is even Kuśika’s descendant, by whom mighty austerities have been performed.\n\nDo you listen as I faithfully describe to you the ascetic power of the high-souled Kauśika.\n\nDo you listen to me relating this. This righteous one was for a long time a king, subduing his enemies, cognizant of morality, accomplished, and intent upon the welfare of his subjects.\n\nAnd there was a king named Kuśa , the son of Prajāpati . And Kuśa’s son was the powerful and pious Kuśanābha .\n\nAnd Kuśanābha’s son was Gādhi . And Gādhi’s son is the highly energetic and mighty ascetic Viśvāmitra.\n\nAnd that king reigned for thousands of years.\n\nAnd it came to pass that once with his four fold forces marshalled, he set out for ranging the earth.\n\nThe king went on by turns ranging cities and kingdoms, rivers and mountains and asylums. And at length that foremost of conquerors, the mighty Viśvāmitra, came upon Vasiṣṭha ’s asylum furnished with various blossoming plants and trees; abounding in animals; inhabited by Siddhas and Cāraṇas ; graced by celestials and Dānavas and Gandharvas and Kinnaras ; and filled with mild dear; frequented by the feathered tribes; crowded with Brahmarṣis ; with Devarṣis inhabiting it aye teeming with-souled ones of accomplished ascetic success and resembling fire; like an other region of Brahmā ; graceful; and adorned on all sides with high-souled saints and Valakhilyas and Vaikhanasas resembling Brahmā, feeding on water or air, or living on withered leaves, or subsisting on fruits and roots, and self-controlled, and free from faults, and of vanquished senses, and engaged in reciting mantras and performing homas .
54	1	54	Chapter LIV	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365922.html	When the ascetic Vasiṣṭha would not part with the cow of plenty then Viśvāmitra , O Rāma , forced Śabala away.\n\nAnd, O Rāma, carried away by that high-souled king, Śabala, stricken with grief and afflicted with sorrow, bethought herself, weeping.\n\nHave I been forsaken by the high-souled Vasiṣṭha that the royal retainers carry me off thus aggrieved?\n\nWhat wrong have I done to that mighty ascetic of concentrated spirit, that, knowing me to be faultless, that righteous one leave her that was devoted to his service?’\n\nRevolving this in her mind and sighing again and again she darted to where the pre-eminently energetic Vasiṣṭha was; and cutting off those servants (of the king),\n\nShe with the speed of the wind, appeared at the feet of that high-souled one. And weeping, she spoke in distressful accents.\n\nBrahma ’s son, wherefore have I been forsaken by you, that the servants of the king were carrying me from off your presence?\n\nThus addressed the Brahmarṣi said these words to that one aggrieved, and of heart afflicted with sorrow, and like to a sister.\n\nO Śabala, not that I forsake you; nor hast you done me any wrong. But this mighty king proud of his prowess has been carrying you away.\n\nSurely, my strength is not equal to his. More specially, he is a king, a powerful king, more particularly, this day he should not be slain by me (inasmuch as he is my guest): he is a Kṣ atriya and lord of earth.\n\nAnd he is foremost in might by virtue of possessing this entire Akṣohiṇī abounding in elephants and horses and cars and standards.’\n\nThus addressed by Vasiṣṭha, that one cognizant of words humbly said in reply to that Brahmarṣi of incomparable power.\n\nThe might of the Kṣatriyas is not great, the Brāhmaṇas are more mighty than they. O Brāhmaṇa , super-human is the power of the Brāhmaṇas, excelling that of the Kṣatriyas.\n\nYour power is immeasurable; and the exceedingly energetic Viśvāmitra is not more powerful than thyself. Your energy is unequalled.\n\nO highly energetic one, do you command me bursting with Brahmā forces: the pride, power and endeavours of that wicked one will I bring down.\n\nThus accosted by her, the highly famous Vasiṣṭha, O Rāma, said, ‘Create you forces capable of crushing the forces of the enemy?\n\nHearing those words of his, Surabhi created (an army). And, O king, Pahlavas by hundreds brought into being by her lowing, begin even in Viśvāmitra’s sight to commit havoc upon his forces. Thereat, exceedingly angered, with eyes expanded in ire, that king commenced to slay the Pahlavas with various weapons. And beholding the Pahlavas by hundreds afflicted by Viśvāmitra, she again created grim-visaged Śakas mixed with Yavanas . And the field became thronged with the Śakas mixed with Yavanas, of dazzling splendour, exceedingly fierce, resembling golden filaments, bearing sharp scimitars and adzes, and clad in yellow apparel. And that entire host (of Viśvāmitra) was being consumed by them like to flaming fires. Then the exceedingly powerful Viśvāmitra hurled weapons at them; and with these the Yavanas, Kambojas and Barbaras (Barbarians) became sore afflicted.’
53	1	53	Chapter LIII	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365921.html	Thus addressed by Vasiṣṭha , that bestower of all that was desired, Śabala , O destroyer of your foes, brought forth everything that was desired by everyone.\n\nAnd she produced sugarcanes, and honies, and fried rice, and excellent Maireyas , (A kind of wine prepared from molasses). A preparation of milk rice, and costly drinks, and various viands, and heaps of warm rice resembling hills, and other kinds of edibles, and soups, and Dadhikalyas , together with silver plates by thousands filled with meats of diverse tastes.\n\nAnd, O Rāma , the tarry of Viśvāmitra being superbly entertained by Vasiṣṭha, heartily filled, became exceedingly gratified.\n\nAnd the royal saint, Viśvāmitra himself, together with the priests and Brāhmaṇas and the inmates of the inner apartment, was also heartily filled.\n\nAnd being hospitably entertained with his courtiers and counsellors and retainers, he, exceedingly de-lighted, spoke to Vasiṣṭha, saying.\n\nReceived and excellently entertained have I been by you, O Brāhmaṇa , who thyself art worthy of being honoured. Do you, O you conversant with speech, listen to me. I will tell you a word.\n\nDo you bestow on me Śabala for an hundred thousand kine. O worshipful one, verily this one is a jewel; and as it is the function of kings to acquire jewels, do you confer on me Śabala; for, O twice-born one, this one by right belongs to me.\n\nThus addressed by Viśvāmitra, the righteous and adorable Vasiṣṭha best of ascetics, replied to that lord of earth.\n\nO king, neither for an hundred thousand nor for an hundred Koṭi of kine, nor yet for heaps of silver, will I part with Śabala. O subduer of enemies, this one deserves not to be separated from my side.\n\nEven like to the fame of the mighty, this Śabala is ever joined with me. my oblations to the gods and the Pitṛs as well as my subsistence itself are established even in her. And my Agnihotras , (Maintenance of the perpetual fire). bali , (Offering to the spirits of air) and Homa (Burnt offerings) depend upper her.\n\nAnd, O royal saint, my Svāhākāras and Vaṣaṭkāras [1] as well as my various lore depend upon her.\n\nAll this is so: there is no doubt about it. Verily she is my all; and in her do I find my delight. And many are the reasons, O king, why I cannot give to you Śabala.’\n\nThus addressed by Vasiṣṭha, that one versed in speech, Viśvāmitra, eagerly rejoined.\n\nI shall confer upon you fourteen thousand elephants decked in gold chains and gold neck-omaments and hooks.\n\nI will confer upon you eight hundred golden cars furnished with bells and reins, and each yoked with four white horses; and, O you of auspicious vows, I will confer upon you one thousand and ten high-mettled horses of noble breeds; and I will confer upon you a koṭi of youthful and variegated kine, do you grant to me Śabala.\n\nAnd as much of gems and gold, O best of regenerate ones, as you will ask for, shall I bestow upon you: do you grant me Śabala.’\n\nThus besought by the intelligent Viśvāmitra, that adorable one replied, saying, ‘O king, Śabala I will not by any means give.’\n\nThis is verily my jewel: this is verily my riches: this is verily my all: this is verily my subsistence. And this is my Darśa . [2] Gifts to Brāhmaṇas on occasions of sacrifice, and this my Paurṇamāsa , [3] and this my various sacrifices with dakṣiṇās ; and, O king, this my various rites.\n\nThis, O king, is without doubt, the root of all my rites. And what need of dilating? This one bestowing everything that is desired will I not part with.\n\n[back to top]\n\n[1] :\n\nSacrifice performed with the exclamation of svadhā and Vaṣaṭ respectively.\n\n[2] :\n\nBi-monthly sacrifice, performed at change of the moon by persons maintaining a perpetual fire.\n\n[3] :\n\nA ceremony performed at the full moon by persons maintaining a perpetual fire.
57	1	57	Chapter LVII	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365925.html	Then with his heart burning, in consequence of the remembrance of his humiliation, and having made enemies with that high-souled one, Viśvāmitra of mighty asceticism sighing and sighing, went towards the south, in company with his queen, and became engaged in dreadful austerities.\n\nO Rāghava . And subsisting on fruits and roots, and restraining his senses, he performed the most rigid austerities. And four sons engaged in observing truth and duty, Haviṣpanda, Madhuṣpanda, Dhṛḍhanetra, and Mahāratha , were born to him.\n\nAnd when a thousand years had been completed, the Grand-sire of all, Brahmā , addressed the ascetic, Viśvāmitra in sweet words, saying, ‘O son of Kuśika , the regions of the Rājarṣis have been won by you through your austerities. And on account of this your asceticism, we recognise you as a Rājarṣi .’\n\nHaving said this, the highly energetic prime Lord of all creatures went to the celestial regions in company with the celestials.\n\nHearing this, Viśvāmitra hanging down his head from shame and possessed by a mighty sorrow, said, in piteous accents, T have performed rigid austerities, yet the deities and the saints recognise me only as a Rājarṣi. I do not consider the fruit of my asceticism as gained.’\n\nAscertaining this in his mind, that righteous one of high austerities, O Kākutstha , again engaged in penances with a composed self.\n\nO Rāghava, it came to pass that at this time, that enhance of Ikṣvāku ’s line, the celebrated and truthful Triśaṅku of subdued senses made up his mind, saying, ‘I will perform a sacrifice, and in body win the prime way of the celestials.’\n\nAnd summoning Vasiṣṭha , he unfolded his mind to him. And on the high-souled Vasiṣṭha saying, ‘I am incapable of doing this,’\n\nAnd disregarded by the latter, the King went towards the southern quarter. And with the view of securing success to his endeavours, the king repaired to where Vasiṣṭha’s sons had for a long time been performing austerities.\n\nAnd the highly energetic Triśaṅku saw the hundred exceedingly effulgent sons of Vasiṣṭha engaged in austerities with fixed faculties. And approaching all those high-souled sons of his spiritual guide, and paying them reverence he, hanging down his head from shame, with clasped hands, addressed those mighty spirits, saying.\n\nI seek protection of you; and I take refuge in you capable of conferring it. Disregarded have I been, good betide you, by the high-souled Vasiṣṭha. I have set my heart upon celebrating a mighty sacrifice: it behove you to command me.\n\nAnd with the view of propitiating you, I, lowly bowing down my head, beseech the sons of my spiritual guide, Brāhmaṇas ever staying by asceticism, do you with collected minds officiate in this sacrifice, so that success may be secured to me; and that in body I may attain the regions of the celestials.\n\nDisregarded by the ascetic Vasiṣṭha, other way find I none, you anchorets, except the sons of my spiritual guide.\n\nTo the Ikṣvākus , their preceptor is their prime way. Therefore after him (Vasiṣṭha), even you are the objects of my adoration.
58	1	58	Chapter LVIII	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365926.html	Hearing Triśaṅku ’s speech, the hundred sons of the saint, O Rāma , excited by wrath, said these words to the king, ‘Disregarded hast you been, O you of perverse understanding, by our truth-telling sire, why then, having passed him by, do you seek for others’ help?\n\nTo the Ikṣvākus , their spiritual guide is their prime way; nor art you capable of setting at naught the words of that truth-telling one.\n\nThat worshipful saint said, that he was incapable (of accomplishing this), how can we then undertake that sacrifice?\n\nYou are ignorant, O foremost of men. Do you speedily retrace your steps. And, O king, that adorable one is competent to officiate at the sacrifice itself of the three worlds, how can we then contribute to his dishonour?’\n\nHearing those words of theirs, that king, with accents tremulous with passion, again addressed them, saying, ‘Disregarded by that worshipful one as well as by the sons of my spiritual guide, I will go after another way, so peace he to you, ascetics.’\n\nThe saint’s sons, on their part, hearing that speech couching a fierce intent, cursed him in exceeding wrath, saying, ‘You shall come by Caṇḍāla -hood.’ Having said this, those high-souled ones entered each into his dwelling.’\n\nAnd when the night had gone by the king came by Chandala -hood. And clad in a blue garb, blue and rough of person, having a short head of hair, wearing a garland composed of materials culled from a cemetery, his body bedaubed with ashes from the same quarter, he was decked out with iron ornaments.\n\nAnd, O Rāma, beholding him in the guise of a Chandala, his counsellors as well as followers, renouncing him, fled in a body. And, O Kākutstha , maintaining himself in patience, the monarch burning day and night, all alone went to the ascetic Viśvāmitra .\n\nAnd beholding to disappointed king in the guise of a Chandala, the ascetic, O Rāma, was touched with pity. And from commiseration, that pre-eminently pious and exceedingly energetic one said to that king frightful to behold, saying, ‘Good betide you, O heroic lord of Ayodhyā , you have fallen into Chandala-hood through a curse, what is the purpose of your coming, O highly powerful prince?’\n\nHearing him, the king conversant with words, fallen into Caṇḍāla-hood, with folded hands, said to that one versed in speech.\n\nDisregarded had I been by my spiritual guide as well as his sons. And far from attaining my desire, I came by this calamity.\n\nO you of placid presence, I had desired to repair to heaven in body. By me have an hundred sacrifices been performed, but yet do I not obtain the fruit thereof.\n\nI have never before told an untruth; and I swear by my Kṣatriya morality, that albeit fallen on evil days, I will never do so in future, O gentle one.\n\nI have celebrated many sacrifices, and I have ruled my people in righteousness; and I have pleased my preceptors by my character and conduct. But, O best of ascetics, now endeavouring to do my duty and intending to perform a sacrifice, I have failed in enlisting the good graces of my spiritual guides. Therefore do I consider Destiny as supreme; and action as nothing.\n\nDensity overtake all: Destiny is the prime way. Therefore it behove you to grant your favour to me extremely distressed, who crave your favour, and, good betide you, whole endeavours have been baffled by Density.\n\nOther way will I wend none; nor is there any other refuge for me. It behove you to meet Density with exertion.
59	1	59	Chapter LIX	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365927.html	When the king had spoken thus, Kauśika ’s son, moved with pity, said these sweet words to the king who had undergone Caṇḍāla -hood.\n\nO descendant of Ikṣvāku , have you had a pleasant journey? I know you well, O highly virtuous one. Refuge will I grant you, so fear not, O best of monarchs.\n\nI shall summon all the pious Maharṣis , who shall assist at the sacrifice. O king, and then you will be able to accomplish your purpose easily. And should the guise you have come by in virtue of your preceptor’s curse, cling to you yet, you will bodily repair to heaven in this form. And since appearing before Kuśika ’s son, you have taken his refuge, I consider heaven, O lord of men, as if within they grasp.\n\nHaving said this, that exceedingly energetic one ordered his highly virtuous and profoundly wise sons to provide the sacrificial necessaries.\n\nSummoning his disciples, he said, ‘Do you by my command bring hither all the saints together with Vasiṣṭha ’s sons; and our friends and their disciples an the family priests variously versed in lore.’\n\nShould any summoned by my mandate, say aught, ‘do you fully represent to me the expression of slight.’\n\nHearing this speech, they set out in different directions; and Brahmavādis [1] began to pour in from various countries. And the disciples (of Viśvāmitra ) returning, fully communicated to that ascetic of flaming energy the words of the Brahmavādis, saying.\n\nHearing your message, the regenerate ones resident in every part will come here, and some have already arrived, all save Mahodaya and the hundred sons of Vasiṣṭha.\n\nDo you, O foremost of ascetics, listen to the words that they said with accents tremulous with emotion.\n\nHow can celestials and saints partake of offerings in the court of him that in addition to being a Chandala , has for this priest a Kṣatriya ? And how can high-souled Brāhmaṇas , patronised by Viśvāmitra, attain to heaven, having partaken of a Candāla’s fare?\n\nThese cruel words, O powerful ascetic, did Vasiṣṭha’s sons together with Mahodaya, utter with reddened eyes.’\n\nHearing those words of theirs, that foremost of ascetics, with eyes reddened in anger, wrathfully cried.\n\nSince blameless as I am, those wicked-minded ones censure me practising fierce austerities, they shall, without doubt, be reduced to ashes.\n\nAnd this very day bound by the noose of Kala , meeting with destruction at the hands of Vivaśvata’s son, ( Yama ) they shall for seven hundred firths range these worlds, wearing dead men’s clothes, always feeding on dogs’ flesh, going by the name of Mahodaya also has blamed me, although undeserving of blame; therefore, reproved of all, he shall undergo Niṣādahood. And becoming cruel, and engaged in taking life, he shall through my ire fare wretchedly for a long lapse of time?\n\nHaving uttered this in the assembly of saints, that mighty ascetic, the highly powerful Viśvāmitra of fierce asceticism, paused.\n\n[back to top]\n\n[1] :\n\nA Brahmavādi is one who maintains that all things are Spirit.
60	1	60	Chapter LX	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365928.html	And knowing (by virtue of his Yoga power) Vasiṣṭha ’s sons together with Mahodaya as destroyed in consequence of his ascetic energy, the highly powerful Viśvāmitra said in the midst of the saints.\n\nThis descendant of Ikṣvāku , the famous Triśaṅku , is virṃous and munificent, and has taken refuge in me, with the view of attaining the celestial regions in his own person. Therefore do you engage with me in the sacrifice, so that he may bodily repair to heaven.\n\nHearing Viśvāmitra’s words, the pious Maharṣis readily spoke in harmony with duty, saying, ‘This descendant of Kuśika is a highly irascible ascetic, therefore what he said should, without doubt, he performed.’\n\nThe worshipful one is like to fire, and, if angered, may curse us. Therefore, let us engage in this sacrifice, so that Ikṣvāku’s descendant through the potency of Viśvāmitra way repair to heaven in person.\n\nThen let us engage in this sacrifice. Saying this, the sages entered upon the ceremony.\n\nAnd in that sacrifice the highly energetic Viśvāmitra acted as the priest. And Ritwijas versed in mantras performed every thing in order with mantras, in accordance with scripture and prescription.\n\nThen after a long time, Viśvāmitra of mighty austerities invoked thither all the celestials for receiving their respective shares; but the deities did not come to receive them.\n\nThereupon, getting into a wrath, the mighty ascetic Viśvāmitra, lifting up a garland, wrathfully exclaimed.\n\nO lord of men, do you witness the prowess of my self-earned asceticism. And, O king, do you in person repair to heaven hard to attain.\n\nSomething yet remains in me of the self-earned fruit of my asceticism; and, O king, through the energy of that asceticism, do you repair to heaven in person.\n\nAnd on the ascetic saying this, O Kākutstha , that lord of men, bodily ascended heaven in the very sight of the anchorets.\n\nAnd beholding Triśaṅku risen to heaven, the subduer of Indra , together with all the celestial said.\n\nTriśaṅku, turn you back. You have not earned abode in heaven. O fool, you have been blighted by the curse of your spiritual guide. Do you therefore drop down headlong.\n\nThe great Indra having spoken thus, Triśaṅku fell down, crying to the ascetic Viśvāmitra, ‘Save me, save me.’\n\nThereupon, hearing his distressful cries, Kauśika waxed mightily wroth, and exclaimed, ‘Stay, stay.’\n\nIn the midst of the ascetics, like to another Prajāpati , he created other seven Ṛṣis [1] on the Southern way: and also, overwhelmed with wrath created another set of stars.\n\nAnd collied [2] with passion, that illustrious one in the midst of the ascetics created another system of stars in the southern direction. And, saying, ‘I will create another Indra, or the world (that I create) shall be without an Indra.’ And in anger, he went the length of creating celestials.\n\nThereupon, in trepidation, the saints and the celestials and the Asuras humbly addressed the high souled Viśvāmitra thus.\n\n‘This king, O highly exalted one, has been visited with the curse of his preceptor, therefore, O ascetic, he deserves not to ascend heaven in person.\n\nHearing those words of theirs, that best of anchorets, Kauśika, in company with the celestials, said these pregnant words.\n\nGood betide you, I have vowed to this king, Triśaṅku’s bodily ascension unto heaven, therefore, I dare not falsify my vow.\n\nLet Triśaṅku evermore dwell in heaven in person, and let these stars created by me verily endure as long as the worlds. This it behove you, you gods, to ordain.\n\nThus addressed, the deities answered that best of ascetics saying, ‘So be it, good betide you! All these innumerable stars, O foremost of anchorets, shall remain in the firmament outside the path of Vaiśvānara ( Zodiac ); and shining in their splendour, Triśaṅku shall dwell with bended head, like to an immortal. And all these luminous bodies shall follow that best of kings, illustrious and successful, as if he had attained heaven itself.’ And the virtuous and exceedingly energetic Viśvāmitra, thus assured by the celestials, said in the midst of the saints, ‘You gods, excellent well.’\n\nThen, after the sacrifice had concluded, the high-souled celestials and the saints of ascetic wealth went to their respective regions, O foremost of men.\n\n[back to top]\n\n[1] :\n\nUrsa major (?The Zodiac?)\n\n[2] :\n\nAnd passion having my best judgement callied.
61	1	61	Chapter LXI	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365929.html	And, O puissant one, seeing those saints gone, the highly energetic Viśvāmitra addressed those inhabitants of the forest.\n\nA mighty disturbance has happened in regard to the southern quarter: let us therefore repairing to another region, carry on austerities.\n\nYou high-souled ones, in the west there are extensive tracts; and there in Puṣkara will we peaceably carry on our austerities. That asylum is really pleasant.\n\nHaving said this, that exceedingly energetic and mighty Muni (Ascetic) began to perform terrible austerities, subsisting on fruits and roots.\n\nAnd it came to pass that at this time that mighty lord of Ayodhyā , Ambarīṣa , prepared for celebrating a sacrifice.\n\nAnd as he was sacrificing, Indra stole away his sacrificial beast. And on the beast being stolen, the priest said unto the king.\n\nO king, the beast has been stolen (away); and it has been lost through your dereliction. And, O lord of men, his own fault destroy the king that fail to protect (the beast).\n\nO best of men, even this is the expiation: do you, while the ceremony lasts, speedily bring back the beast, or bring a man in its stead.\n\nHearing the priest’s words, that highly intelligent king began to range various countries and provinces, cities, forests, and holy asylums, searching for the beast, with a thousand king (as the price thereof.)\n\nAnd, O child, it came to pass that arriving at Bhṛgutuṅga , (A mountain peak) he beheld Ṛcīka seated there in company with his wife and sons.\n\nO descendant of Raghu . And bowing to that Brahmarṣi flaming in asceticism, and propitiating him, the exceedingly energetic royal saint of unparalleled effulgence having enquired as to his complete welfare, addressed Ṛcīka, saying, ‘0 highly pious one, O Bhṛgu ’s son, if in order that I may have a substitute for my sacrificial beast, you sell your son, my desire I shall atain.’\n\nI have ranged every country; but the beast I do not find. Therefore, it behove you to part with one of your sons for price.’\n\nThus addressed the exceedingly energetic Ṛcīka replied, ‘O best of men, my first-born I will in no wise dispose of.’\n\nHearing the words of the high-souled Ṛcīka, their mother spoke to that foremost of men, Ambarīṣa, saying,\n\nThe worshipful son of Bhṛgu has said that his first-born cannot be disposed of—do you, O lord, also know that the youngest, Śunaka , is my favourite. Therefore my youngest son will I not give to you.\n\nO foremost of men, the eldest sons are generally the best beloved of their fathers; and the youngest, of their mother, therefore the youngest I would retain.\n\nAnd when the ascetic as well as his wife had spoken thus, the second son, Śunaḥsepa, O Rāma , himself said.\n\nMy father would not sell the eldest; nor my mother the youngest,—therefore, I consider even the second as disposable. Do you then, O prince, take me.\n\nWhen that one versed in the Veda had ended, that lord of men, O mighty-armed descendant of Raghu, taking possession of Śunaḥsepa, by paying koṭis of kine, and heaps of jewels, and gold and silver by hundreds and thousands, went away exceedingly delighted.\n\nThat royal saint, the exceedingly energetic and highly famous Ambarīṣa, placing Śunaḥsepa on his car, speedily set out.
62	1	62	Chapter LXII	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365930.html	O foremost of men, taking Śunaḥsepa, that illustrious king at noon rested in Puṣkara , O descendant of Raghu .\n\nAnd having arrived at the excellent Puṣkara, as the king was resting, the famous Śunaḥsepa with an aggrieved heart saw his maternal uncle Viśvāmitra in company with some saints engaged in asceticism. Thereupon, with a woebegone countenance, and sore afflicted with fatigue and thirst, he, O Rāma , flung himself into (Viśvāmitra’s) lap, and said.\n\nI have neither father, nor mother, nor relatives, nor friends anywhere. It therefore behoves you, O gentle one, to save me in the interests of virtue, O foremost of ascetics.\n\nAnd, O best of men, you are the protector of all, and their refuge. May the king have his desire and may I at the same time, attaining long life, and undeteriorating, gain heaven, having performed meritorious austerities!\n\nDo you with a delighted heart become a lord to me that am without one. And, O righteous one, even as a father rescue a son, do you deliver me from this peril.\n\nHearing his words, Viśvāmitra of mighty austerities, pacifying him by every means, spoke to this sons, saying,\n\nThat in view of which fathers beget well-wishing sons, the compassing of other's welfare is at hand.\n\nThis youthful son. of the ascetic crave my protection. O you sons, do accomplish my desire by saving his life.\n\nYou are all of virtuous deeds, you are all engaged in the observance of righteousness, do you confer satisfaction upon Agni by one of you becoming the (sacrificial) beast of the lord of men.\n\nThus Śunaḥsepa will obtain protection, the sacrifice will be freed from hindrance the deities will be propitiated, and finally my word will be made good.\n\nHearing the ascetic’s words, his sons, Madhucchanda and others, O foremost of me, haughtily and tauntingly answered.\n\nO lord, how, neglecting your own sons, you desire to deliver that of another? This we consider as heinous, even like to eating one’s own flesh.\n\nHearing this speech of his sons, that best of anchorets, with eyes reddened with anger, said.\n\nDisregarding my words, you have uttered this audacious and shocking speech, disclaimed by morality, and capable of causing one’s hair to stand on end. Therefore, becoming Muṣṭikas , and living on dogs’ flesh, do you ah, even like Vasiṣṭha ’s sons, inhabit the earth for a thousand years.\n\nHaving cursed his sons, that best of ascetics then, by all means cheering up the distressed Śunaḥsepa as to his protection, addressed him.\n\nDo you donning on a sacred zone, and wearing a garland of red flowers, and bedaubing your person with red sand paste, hymn Agni with mantras , approaching the Vaiṣṇava sacrificial stake; and, O ascetic’s son, (at the same time) chant these two verses in that sacrifice of Ambarīṣa . Then you will attain success.\n\nThereupon, with a concentrated mind securing those two verses, Śunaḥsepa speedily presented himself before that leonine monarch saying,\n\nO lion of a king, O you endued with high intelligence, let us without delay repair hence. And, O foremost of monarchs, do you engage in the sacrifice and commence upon the initiation.\n\nHearing those words of the ascetic’s son, the king, filled with delight, readily at once repaired to the sacrificial ground.\n\nWith the consent of his court, the king fastened Śunaḥsepa with a Kuśa cord, and investing him with a crimson apparel tethered him to the stake as the (sacrificial) beast.\n\nBeing bound (to the stake), the ascetic’s son first of all duly hymned Agni, and next those deities, Indra and his younger brother.\n\nThereupon, gratified with the excellent eulogy, the thousand eyed Vāsava conferred upon Śunaḥsepa long life.\n\nAnd, O foremost of men, that king also, having completed the sacrifice, obtained the manifold fruit thereof through the grace of the thousand-eyed deity,\n\nO Rāma, And, O best of men, the righteous Viśvāmitra of mighty asceticism again carried on austerities at Puṣkara for ten hundred years.
63	1	63	Chapter LXIII	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365931.html	When the thousand years had been completed and the mighty ascetic had accomplished his vow, the celestials in a body desirous of conferring upon him the fruit thereof, appeared before him.\n\nThe exceedingly effulgent Brahmā addressed him in soothing words, saying, ‘You are henceforth a saint, good to you,—and (this eminence) you have attained through your own laudable exertions.’\n\nHaving spoken thus to him, the lord of celestials returned to heaven. And Viśvāmitra of mighty energy became again engaged in rigid austerities.\n\nAnd, O foremost of men, it came to pass that after a long lapse of time that prime of Apsaras , Menaka , was at that time perfonning her ablutions in Puṣkara , and she was observed by Kuśika ’s son like to lighting among clouds. And coming under the control of Kandarpa , (Cupid) the anchorite spoke to her, saying, ‘O Apsari, has your journey been a pleasant one? Do you abide in my asylum.’\n\nDo you favour me; for, good betide you, I have been rendered senseless by Madana . Thus addressed, that one of shapely hips began to dwell there.\n\nAnd mighty was the hindrance that befell Viśvāmitra as regarded his asceticism, as she, O Rāghava , staying in that asylum of his, pleasantly spent five and five years, O gentle one.\n\nAnd after this period had gone by, overwhelmed with shame and afflicted with anxiety and grief, the mighty ascetic Viśvāmitra impatiently thought,\n\nO son of Raghu , that all this mighty loss of austerities was the work of the celestials.\n\nAnd deprived of his senses by lust, the decade had passed away imperceptibly as if it were one day and night; and this impediment stood in the way of his austerities.\n\nHaving a sigh, that best of ascetics burned in repentance. And with sweet words renouncing the terrified and trembling Menaka standing with clasped hands, Kuśika’s son, Viśvāmitra, O Rāma , went to the northern mountains.\n\nAnd practising the Brahmacarya mode of life with the intention of subduing lust, that highly famous one engaged in arduous austerities on the banks of the Kauśiki.\n\nAnd as he was thus engaged in profound austerities on the northern mountain, a thousand years, O Rāma passed away.\n\nThen taking counsel together, the celestials and the saints appeared before (Brahmā), saying, ‘Let Kuśika’s son obtain the title of Maharṣi .’\n\nHearing the words of the celestials, the Grand sire of all addressed the ascetic Viśvāmitra, in these sweet words, ‘O mighty saint, hast you had a pleasant journey? Satisfied with your fierce austerities, O Kauśika , I confer upon you the eminence of the foremost saintship.’\n\nHearing Brahma ’s speech, the anchorite Viśvāmitra bowing down thus answered the Grandsire with clasped hands, ‘The incomparable title of Brahmarṣi is to be won by one by performing sterling works. And since you have not addressed me (by that title), it appears that I have not yet succeeded in subduing my senses.’ [1]\n\nThereupon Brahmā said to him, ‘Do you exert thyself until you conquer your senses?’ Saying this, Brahmā went to heaven.\n\nAnd when the celestials had gone, the mighty ascetic, Viśvāmitra, with upraised arms, and without any support, and subsisting on air, began to perform penances.\n\nAnd in summer, the ascetic surrounded himself with five fires, and in rains remained in an uncovered place, and in winter day and night stood submerged in water. Thus passed by a thousand years of terrible penances.\n\nAnd on the mighty ascetic Viśvāmitra being engaged in austerities, great was the agitation that exercised the celestials and Indra , in particular.\n\nŚakra together with the Maruts spoke to Rambhā these words, fraught with weal to himself, and woe to Kauśika.’\n\n[back to top]\n\n[1] :\n\nThe text is very faulty. The literal meaning would be, since you have not...... I have subdued my senses, which would be absurd. I have therefore rendered the passage freely.
65	1	65	Chapter LXV	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365933.html	Forsaking the northern direction the mighty Muni , O Rāma , betaking himself to the Eastern quarter, became engaged in dreadful austerities.\n\nAdopting the high vow of taciturnity for a thousand years, he, O Rāma began to perform the most signal and arduous austerities.\n\nWhen the thousand years had been complete, many an impediment tried the mighty Muni staying like the trunk of a tree, yet could not anger enter his heart.\n\nAnd firmly deter mined to shut out anger, he, O Rāma, kept his asceticism from deterioration. And, O foremost of the Raghus , when his vow of a thousand years had been observed, that one of mighty vows became desirous of feeding on boiled rice. And it came to pass O best of the Raghus that at this time Indra assuming the guise of a regenerate one, asked for the rice.\n\nThereupon he gave it away to the Vipra ; and when the rice had been thus exhausted, that worshipful one of mighty austerities went without foot.\n\nNor, abiding by the vow of reticence, did he say aught to the Vipra. And he then again resumed his dumb guise, restraining his breath at the same time.\n\nAnd that puissant ascetic did not breathe for a you sand years. And as he restrained his breath, vapours began to issue out of his head.\n\nAnd at this, the three worlds became afflicted with fear. And bewildered on account of the energy of his asceticism, and shorn of their brightness, and afflicted with anguish, the Devarṣis and the Gandharvas and the Pannagas and the Uragas and the Rākṣasas in a body addressed the Pitāmaha , ( Brahmā ).\n\n0 divine one, various were the means by which we endeavoured to affect the mighty Muni Viśvāmitra with covetousness and lust; but for all that he increase in asceticism. ṣṭfPR\n\nNor do we perceive in him ever so little of anger or lust. And if you do not confer upon him what his mind desire to have, he will annihilate the three worlds with all that is mobile and immobile in them. And the ten cardinal points are disconsolate: and nothing can be discovered therein.\n\nAnd the seas are vexed, and the mountains, riven. And the earth shake, and the winds keep steadily blowing.\n\nO Brāhmaṇa , we do not know how to remedy, this. And every one is inactive like an infidel. And the three worlds look as if stupefied, with their minds exceedingly exercised.\n\nBy virtue of that mighty saint’s energy, the sun itself has been deprived of his splendour.\n\nTherefore, O god, against the mighty Muni bending his mind upon destruction, and consuming the three entire worlds like to the fire raging at the universal dissolution, that exalted one of exceeding effulgence resembling a flame, should be pacified.\n\nEven should he desires the dominion of the celestial regions, do you grant him his wish.\n\nThen the celestials with Pitāmaha at their head, addressed the high-souled Viśvāmitra in sweet-words, saying, ‘Welcome, O Brahmarṣi ! Well pleased have we been with your penances. And, O son of Kuśika , in consideration of your fiery asceticism, you have obtained Brāhmaṇa-hood.’\n\nO Brāhmaṇa, I will in company with the Maruts confer on you long life, hail to you! Do you accept this, good betide you. Go you, O gentle ascetic, bowing down to the celestials, said in delight,\n\nIf Brāhmaṇa-hood has really been obtained by e together with length of days, let Oṃkāra and Vaṣaṭkāra and the Vedas crown me; and let, you gods, that foremost of those versed in Kṣtra Veda ad well as of those cognizant of the Brahmaveda , even Brahmā’s son, Vasiṣṭha , recognise me. Having granted this prime desire of mine, do you go away, you gods.\n\nThen pacified by the celestials, that best of reciters, the Brahmarṣi Vasiṣṭha, made friends (with Viśvāmitra), saying,\n\n‘So be it.’ You are a Brahmarṣi. There is no doubt about this. And every thing has been compassed in your behalf, having said this, the deities went to their respective regions.\n\nAnd that Brahmarṣi, the righteous Viśvāmitra also, having attained excellent Brāhmaṇa-hood, paid his homage to that best of reciters, Vasiṣṭha.\n\nAnd, having secured his end, began to range the entire world, staying in asceticism. In this wise, O Rāma, was Brāhmaṇya actually obtained by the high-souled one.\n\nThis, O Rāma, is the foremost of ascetics, this one is Asceticism incarnate. This one ever abide by duty; and he is the stay of ascetic energy.\n\nHaving said this, that best of regenerate persons paused. Hearing Śatānanda ’s narration delivered in the presence of Rāma and Lakṣmaṇa , Janaka with clasped hands addressed the son of Kuśika.\n\nBlessed and beholden am I, that you, O Kauśika , accompanied with Kākutstha , hast arrived at my sacrifice, O puissant anchorite. Purified am I, O Brāhmaṇa, by your very sight.\n\nO mighty Muni. And from your sight have I received various qualities. O Brāhmaṇa, your mighty austerities have been related in detail; and myself as well as he high-souled Rāma have listened to the narration relative to your formidable ascetic energy; and the assembled courtiers have heard of your various perfections.\n\nImmeasurable is your asceticism; and immeasurable your power; and ever immeasurable your qualities,\n\nO Kuśika’s son. I never, O lord, am tired of listening to that wonderful narration. Now, O foremost of ascetics, the hour for performing the daily devotions has arrived, and the solar disc hangs aslope.\n\nTo-morrow morning, O highly energetic one, you will see me again. Welcome, best of reciters. It behove you to favour me.\n\nThus addressed, that best of ascetics, extolling that powerful one, well pleased, dismissed the delighted Janaka.\n\nThus accosted, Mithilā ’s lord, Vaideha , in company with his priests and friends, went round that foremost of ascetics.\n\nAnd the righteous Viśvāmitra also together with Rāma and Lakṣmaṇa, having been honoured by the high-souled ones, took up their quarters there.
2	1	2	Chapter II	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365870.html	Hearing those words of Nārada , that one of virtuous soul, skilled in speech, together with his disciples, worshipped that great sage.\n\nHaving received due honours, that Devarṣi Nārada taking leave of him went to his ethereal regions.\n\nAnd when Nārada had left for the celestial regions, that holy person went to the banks of the Tamasā not very far from Jāhnavī .\n\nAnd having arrived at the banks of that river, the pious one, observing a holy spot devoid of mud, spoke to his disciple standing by.\n\nSaying—O Bharadvāja , behold this holy spot devoid of mud. And it is beautiful, and contains pleasant waters, even like the minds of good men.\n\nO child, do you, put down your pitcher, and give me my bark. I will bathe even in this Tamasā, the best of holy spots.\n\nThus accosted by the high-souled Vālmīki , Bharadvāja ever intent upon serving his spiritual guide, presented the sage his bark.\n\nThat one of subdued senses, having received his bark from his disciple, began to range around, surveying that extensive forest.\n\nIn the vicinity of the forest, that worshipful one espied a pair of Krauñcas , emitting melodious notes, and ranging around never parting from one another.\n\nAt this juncturere, a wicked-minded fowler, singling out the male , without any cause of hostility, slew him in the very presence of the holy man.\n\nObserving him struggling on the earth, bathed in blood, his female companion began to bewail in piteous accents.\n\nAt the prospect of her separation from her copper-crested oviparous husband, engaged in sport with extended plumage.\n\nFinding the bird in that condition thus brought down by the fowler, the pity of that pious and righteous-souled Ṛṣi was excited exceedingly.\n\nThen considering it to be an unrighteous deed, with a heart moved with pity, that twice-born one, beholding the weeping Krauñci, spoke these words.\n\nO fowler, since you have slain one of a pair of Krauñcas, you shall never attain prosperity (respect)!\n\nHaving uttered this, he got worried within himself What is this that I have said, afflicted with grief for the bird?\n\nResolving thus in his mind, that highly-wise one and best of sages addressed his disciple, saying.\n\nThis speech that I have uttered is of equal bound with metre and accents; it has rhythm and is capable of being chanted according to measure to stringed accompaniment. Let it therefore go forth as a śloka !\n\nWhen the sage had spoken thus, his disciple, well pleased, assented to his excellent speech; and thereat that pious person was gratified.\n\nThen having duly performed his ablutions at that holy spot, the reverend sage retraced his steps, pondering over the incidents touching the śloka .\n\nHis disciple also, accomplished in learning, and of meek demeanour, followed Vālmīki, carrying on his back a pitcher filled with water.\n\nHaving entered the hermitage along with his disciple, conversant with righteousness engaged in diverse kinds of talk, revolved in his mind the circumstances connected with the verses.\n\nIt came to pass that desirous of seeing the best of sages, there arrived, that lord and creator of all, the effulgent Brahmā , furnished with four countenances.\n\nBeholding him Vālmīki rose up suddenly and, wondering greatly, humbly and silently stood before him with clasped hands.\n\nAnd duly bending low in reverence, Vālmīki offered that deity water to wash his feet, and other things for reception.\n\nHaving sat-down on a highly-honoured seat, that worshipful one enquired after the welfare of that sage Vālmīki knowing no deterioration; and then asked him to be seated.\n\nHaving been seated in the presence of the Grand-sire of all, Vālmīki, his mind running upon the self-same subject, became plunged in thought. What a sin has been committed by the wicked-minded one, incited by hostile feeling, that he without cause slew that sweetly-singing Krauñca !\n\nAnd thereupon, again lamenting that female Krauñca, he, in grief of heart, mentally recited those verses.\n\nThen smiling, Brahmā spoke to the excellent sage,—Those verses of your which you have composed a śloka shall attain celebrity: no doubt need be entertained on this head. It is because I had intended so, that those verses had come out of your lips.\n\nDo you now, O best of saints, compose the entire history of Rāma . Do you relate to the world the history of the righteous-souled and intelligent Rāma crowned with qualities. And do you, as you have heard it from Nārada.\n\nRelate all what is known, and all what is unknown to the world, O wise one, concerning Rāma, and Lakṣmaṇa , and Videha ’s daughter, and all the Rākṣasas . And even what is not knowm to Nārada, shall be unfolded to you.\n\nNo words of yours in this poem shall contain an untruth sacred. Therefore, now compose into verses. This delightful story of Rāma.\n\nAs long as the mountains and the seas exist on earth, the history of Rāmāyaṇa will remain prevalent among men.\n\nAs long as this story of Rāmāyaṇa shall retain its currency, you shall reside both in this world and in mine.\n\nHaving said this, the Lord Brahmā disappeared there. And thereat the sage and his disciples marvelled greatly.\n\nHis disciples sang those verses again and again; and, momentarily experiencing pleasure, recited it with exceeding wonder.\n\nThose verses, composed of equal accents, and furnished with four parts, have been sung by the great saint, have, in virtue of frequent repetition, been associated with a world of pathos and have attained the eminence of a śloka .\n\nNow it is the intention of that illustrious and self-centred sage to compose the entire Rāmāyaṇa in this metre.\n\nThe great ascetic Vālmīki of gracious appearance and unparalleled renown composed a poetry consisting of hundreds of verses in melodious measure, couching the significance of the history of Rāma.\n\nListen to the annals of the foremost of Raghu ’s race, and the destruction of the Ten-headed one composed by the ascetic, with Samāsas , Sandhis , Prakṛtis , and Pratayas ; and lucid with sweet and equally-accented words.
23	1	23	Chapter XXIII	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365891.html	And when the night had passed away, the mighty ascetic spoke to Kākutstha , lying down on a bed of leaves, O Rāma , surely has Kausalyā given birth to an excellent son! The first Sandhyā [1] should now be performed. Do you, O tiger among men, arise! You should perform the purificatory rites and contemplate the gods.\n\nHearing those proper words of the ascetic, those foremost of men, endowed with heroism, bathed, and, sipping water, began to recite the Gāyatrī . (The solar hymn of the Veda ).\n\nAnd having performed these daily duties, those exceedingly powerful ones, greeting Viśvāmitra having asceticism for wealth, stood before him, with the object of starting on their journey.\n\nAnd as those ones endowed with exceeding prowess were proceeding, at the shining confluence of the Sarayū and the Gaṅgā they beheld a noble river flowing in three branches.\n\nThere lay a holy hermitage, belonging to ascetics of subdued souls, where they had been carrying on their high austerities for thousands of years.\n\nBeholding that sacred asylum those descendants of Raghu , exceedingly delighted, spoke to the high-souled Viśvāmitra, these words.\n\nWhose is this sacred hermitage? And what man lives here? O worshipful one, we are desirous of hearing this. Surely, great is our curiosity.\n\nAt those words of theirs, that foremost of ascetics, smiling, said, Heap O Rāma, as to whom the asylum has belonged in time past.\n\nKandarpa , called Kāma by the wise, was once incarnate (on earth.) And it came to pass that as that lord of the deities, Sthāṇu , having performed here his austerities in accordance with the prescribed restrictions, was wending his way in company with the Maruts , that fool-hardy wight dared disturb the equanimity of his mind.\n\nThereupon, O descendant of Raghu, uttering a roar, the high-souled Rudra eyed him steadfastly. And thereat all the limbs of that perverse-hearted one became blasted.\n\nAnd on his body being consumed by that high-souled one, Kāma was deprived of his person in consequence of the ire of that foremost among the deities.\n\nO Rāghava , from that time forth, he has become known as Anaṅga . And the place where he was deprived of his body is the lovely land of Aṅga .\n\nThis sacred hermitage belongs to Śiva ; and these ascetics engaged in pious acts, O hero, have been from father to son his disciples. And no sin touch them.\n\nHere, O Rāma, in the midst of the sacred streams, will we spend the night, O you of gracious presence, crossing over on the morrow.\n\nLet us then, having purified ourselves, enter the holy hermitage! It is highly desirable for us to sojourn here, here will we happily spend the night, having bathed, and recited the mantras , and offered oblations to the sacrificial fire, O best of men.\n\nAs they were conversing thus, the ascetics were highly delighted on discovering them by means of their far-reaching spiritual vision, and they rejoiced greatly.\n\nThen giving Kuśika ’s son water to wash his feet and Arghya , and extending to him also the rites of hospitality, they next entertained Rāma and Lakṣmaṇa .\n\nHaving experienced their hospitality, they (the guests) delighted them with their talk. And then the saints with collected minds recited their evening prayers.\n\nAnd having been shown their destined place of rest along with ascetics of excellent vows, they happily passed that night in that hermitage affording every comfort.\n\nAnd that foremost of ascetics, the righteous-souled son of Kuśika, by means of his excellent converse, charmed the prepossessing sons of the monarch.\n\n[back to top]\n\n[1] :\n\nBrāhmaṇas have to perform their daily devotions thrice,—in the morning, at noon, and in the evening.
5	1	5	Chapter V	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365873.html	This great story of Rāmāyaṇa treats of those victorious kings commencing with Prajāpati , and having Ikṣvāku for their founder, who ruled the entire earth as no other kings had done so before them, and in whose line Sagara was born—Sagara who dug the ocean, and whom, while out in progress, his sixty-thousand sons followed.\n\nWe shall now chant the entire history of that dynasty from the beginning. Do you, with minds free from ill will, listen to that story conferring merit, profit and pleasure.\n\nThere is on the banks of the Sarayū a great and flourishing country called Kośala abounding in com and wealth, in which the inhabitants passed their days pleasantly.\n\nThe capital of that country was Ayodhyā famed among men, which was founded by Manu himself that foremost of men.\n\nThat beautiful and mighty city was twelve Yojanas in length and Three in breadth; and was intersected outside with spacious roads laid out orderly.\n\nAnd scattered with blown blossoms, and regularly sprinkled with water; the well-arranged broad high-ways looked beautiful.\n\nThat one bringing prosperity into great kingdoms, King Daśaratha , lived in that city, like that of the lord of the deities inhabiting the celestial regions.\n\nAnd the city was furnished with doors and gates, and well-arranged rows of shops. And it contained all kinds of instruments and arms, and was inhabited by all classes of artizans.\n\nAnd that graceful and matchlessly brilliant city abounded in eulogists and genealogists. And it was crowned with stately edifices with flags, and guarded by hundreds of Śatāghnīs . (A weapon commonly described as a stone set round with iron spiles).\n\nAnd the mighty city contained theatres for females, and gardens, and mango-groves; and was enclosed by a wall of sāla trees.\n\nAnd encircled by a deep moat, the city was not accessible for enemies. And it abounded with elephants and horses, and kine and camels and asses.\n\nIt was thronged with neighbouring kings come to pay tribute, and inhabited by merchants from various countries.\n\nAnd adorned with mountain like palaces glittering with gems, and filled with sporting-places for females, and like to Indra ’s Amarāvatī .\n\nThe city was wonderful to behold, gleaming with gold-bumished ornaments, and inhabited by troops of courtezans, and abounding in all kinds of gems, and graced with royal palaces.\n\nAnd it abounded in paddy and rice, and its water was sweet as the juice of the sugar-cane.\n\nAnd it resounded with the sounds of Dundubhis and Mṛdaṅgas and Vīṇās and Paṇavas .\n\nAnd that foremost spot of all the earth was like an aerial car obtained in heaven by the Siddhas , through force of ascetic austerities, and thronged with the best specimens of humanity.\n\nThat city was filled by king Daśaratha with thousands of such Mahārathas [1] light-handed and accomplished in fight, as could by force of arms or sharpened shafts slaughter infuriated lions and tigers and boars roaming in the forest; yet as would not pierce with arrows persons lorn or abandoned or hiding or fugitive.\n\nA warrior fighting ten thousand Mahārathas .\n\nIt abounded mostly in excellent Brāhmaṇas , lighting the sacrificial fire, and crowned with qualities, and versed in the Vedas and the Vedāṅgas , and giving away thousands, and ever abiding by truth, and high-souled, and resembling might ascetics.\n\n[back to top]\n\n[1] :\n\nA warrior coping with ten thousand persons, and protecting both his charioteer and steeds.
1	1	1	Chapter I	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365869.html	The ascetic Vālmīki asked Nārada , the best of sages and foremost of those conversant with words, ever engaged in austerities and Vedic studies.\n\nWho at present in this world is like crowned with qualities, and with prowess, knowing duty, and grateful, and truthful, and firm in vow.\n\nWho is qualified by virtue of his character, and who is engaged in the welfare of all creatures? Who is learned and capable. Who alone is ever lovely to behold?\n\nWho has subdued his heart, and controlled his anger, is endowed with splendour, and devoid of malice; and whom enraged in battle, do even the gods, fear?\n\nI have great curiosity to hear of such a person. You can, O Maharṣi , [1] know about a man of this description.\n\nHearing Vālmīki’s words, Nārada, cognizant of the three worlds, said with alacrity, “listen to me”!\n\nRare as are the qualities mentioned by you, I wifi, O sage, having duly considered, describe to you a person endued with them.\n\nThere is one sprung from the line of Ikṣvāku , known by the name of Rāma . He is of subdued soul; and is exceedingly powerful; effulgent; endowed with patience; having senses under control.\n\nHe is intelligent; learned in morality; eloquent; crowned with grace; the slayer of foes: broad-shouldered; possessed of mighty arms, a conch-shaped neck, fleshy jaws.\n\nAnd a broad chest; a powerful bowman; the repressor of foes; having plump shoulder-blades; of arms reaching down to his knees; with a beautiful head, and a graceful forehead; and endowed with excellent might.\n\nAnd having symmetrical limbs; and of a cool hue; and possessed of prowess; and having a well-developed chest; with expansive eyes; crowned with auspiciousness and favourable marks.\n\nKnowing duty; firm in promise; always engaged in the good of his subjects; of accomplished renown; furnished with knowledge; pure in body and spirit; obedient towards superiors; versed in self-knowledge.\n\nNāraḍa says—Like Prajāpati himself; blessed with prosperity; protecting all; the destroyer of enemies, and protector of all living beings.\n\nPractising all the duties of his class; and preserving those cleaving to him; versed in the profundities of the Vedas and the Vedāṅgas ; accomplished in archery.\n\nWell versed in the dicta of all the sciences; brilliant; gifted with a good memory; the darling of all; unreproved; of unvanquished spirit; proficient in every branch of learning.\n\nEver resorted to by the good persons even as the ocean is by the rivers; worthy of being honoured; having an equal regard for all; and capable of filling the heart with ever new sensations.\n\nCrowned with all sort of qualities, he enhances the joys of Kausalyā ; being like that of the sea in gravity, and that of the Himavat in patience.\n\nIn prowess, he is like as Viṣṇu , and boasts of the personal attractions of the Moon. In anger he resembles the fire raging at the time of dissolution; and in forgiveness, he is like that of the Earth.\n\nIn giving away, he is like the Bestower of riches Kubera , and in truth, he is like another Dharma . Desirous of doing that which would be acceptable to his subjects, king Daśaratha , from fullness of affection, wished to install as his associate in the kingdom his beloved and meritorious eldest son.\n\nRāma who of infallible prowess, and endued with sterling virtues, and ever intent on the welfare of the people. The king Daśaratha with great pleasure wished to install as the hair-apparent of the kingdom.\n\nBeholding the provisions of the installation, that lady the king’s consort, Kaikeyī , who had previously been promised two boons, even asked him for those viz ., the exile of Rāma, and the installation of Bharata .\n\nBound by the ties of duty in consequence of his promise, king Daśaratha banished his favourite son Rāma.\n\nIn pursuance of his father’s promise, and with the view of compassing the pleasure of Kaikeyī, that heroic one, commanded by his sire, repaired to the forest.\n\nOn the eve of his departure for the forest, that enhancer of Sumitrā ’s joy and favourite of his brother (Rāma), his dear brother Lakṣmaṇa , endowed with humility, displaying brotherliness, followed him out of affection.\n\nAs Rohiṇī followed with the moon, Rāma’s beloved spouse, sprung in Janaka ’s line—like as an embodiment of Divine power—sear (Rāma) as life itself, and engaged in acts of good, and furnished with every auspicious mark, and the best of wives, followed Rāma. Having been followed far by his father Daśaratha along with the citizens.\n\nRāma met with the virtuous and beloved king of the Niṣādas ; and then in company with Guha , Lakṣmaṇa, and Sītā , Rāma dismissed his charioteer on the banks of the Ganges at Śṛṅgaverapura .\n\nThen wending from one forest to another, and having crossed many broad rivers, they, in accordance with Bharadvāja ’s directions, arrived at the Citrakūṭa ; and constructing a romantic abode, the three began to live there.\n\nThey spent their days in delight, in the company of gods and Gandharvas . And when Rāma had reached the Citrakūṭa, king Daśaratha, distressed on account of his son, went to heaven, bewailing the latter.\n\nWhen king Daśaratha had passed away heaven, the mighty Bharata, although pressed by the Brāhmaṇas headed by Vasiṣṭha , to rule the kingdom, did not wish for dominion. And that hero went the forest, with the view of propitiating Rāma.\n\nHaving come to the high-souled Rāma, with truth for his prowess, he besought his brother, with every mark of respect.\n\nBharata said, You are only the king conversant with Dharma. And the exceedingly generous, illustrious and mighty Rāma of a cheerful countenance did not wish for the kingdom, in consonance with his father’s injunction. And having made over to Bharata, as his substitute on the throne, his own sandals, Bharata’s elder brother repeatedly forbade him.\n\nAnd then Bharata, finding his desire not fulfilled, touched Rāma’s feet, and began to rule at Nandigrāma , expecting the return of Rāma.\n\nAnd when the auspicious Bharata, firm in his promise and of subdued sense, had gone away, Rāma again perceiving there the influx of citizens and others, eagerly entered Daṇḍaka .\n\nHaving entered that mighty vast, the lotus-eyed Rāma slew the Rākṣasa Virādha , and saw Śarabhaṅga , Sutīkṣna, Agastya and Agastya’s brother.\n\nHe then, advised by Agastya, gladly possessed himself of Indra ’s bow, the inexhaustible arrows, the scimitar, and the quiver.\n\nWhile Rāma was dwelling there with the rangers of forests, the sages came to him in a body, for the destruction of the Asuras and Rākṣasas .\n\nThereupon in the presence of those ascetics like the flaming fire, inhabiting the Daṇḍaka forest, he promised to slay those Rākṣasas in battle.\n\nIt was while he was living there that, that dweller of Janasthāna , the Rākṣasī Śūrpaṇakhā , capable of assuming any form at will, was disfigured.\n\nIt was while living there in the society of the inhabitants of Janasthāna, that Rāma slew in battle the Rākṣasas Khara and Triśiras and Dūṣaṇa , together with their followers, who all had been stirred up by the words of Śūrpaṇakhā. And fourteen thousand Rākṣasas were slain in that battle.\n\nHaving leart of the destruction of his relatives, Rāvaṇa wrought into frenzy by anger, sought the help of a Rākṣasa named Mārīca .\n\nAnd although strongly dissuaded by Mārīca, saying. You ought not to enter into hostilities with that powerful one. Do you, therefore, O Rāvaṇa, excuse me! yet, disregarding those words of his, Rāvaṇa, urged on by Fate, went into that asylum in company with Mārīca.\n\nThat one (Mārīca) commanding illusions, having drawn far the king’s sons (Rāma and Lakṣmaṇa), he (Rāvaṇa) carried away Rāma’s wife, slaying the vulture Jaṭāyu .\n\nAnd beholding the vulture slain and learning of the kidnapping of Mithilā ’s daughter, the descendant of Raghu , deprived of sense, bewailed in grief.\n\nHaving with unassuaged sorrow burnt the vulture Jaṭāyu, as he was searching for Sītā in that forest, he fell in with a Rākṣasa, Kabandha by name, of a dreadful and deformed shape. Having slain him, the mighty-armed one burnt his body,—and thereupon he went to heaven.\n\nAnd the Rākṣasa addressed Rāma saying, O descendant of Raghu, Do you repair to the ascetic, Śabarī , conversant with all systems of morality.\n\nRepairing to Śabarī, that destroyer of foes, gifted with exceeding energy, Rāma, the son of Daśaratha, highly honoured by Śabarī.\n\nThan he met with Hanumān on the banks of the Pampā . Then, agreeably to Hanumān’s advice, the exceedingly powerful Rāma saw Sugrīva . And detailed to him all specially touching Sītā.\n\nThen the monkey Sugrīva, having heard all from Rāma was well pleased with Rāma, and in the presence of fire, made friends with him.\n\nThen the king of monkeys, out of friendship, mournfully related to him all about his hostilities with Vālī .\n\nThen Rāma vowed that he would slay Vālī. Thereupon the monkey described to Rāghava the prowess of Vālī, and he feared lest Rāma should not prove a match for Vālī.\n\nAnd with the view of convincing Rāghava (as to Vālī’s might), Sugrīva showed to him the huge corpse of Dundubhi , resembling a hill.\n\nAnd looking at the skeleton, Rāma endued with exceeding prowess, smiling the while, with his toe cast it off at the distance of full ninety miles.\n\nWith a single mighty shaft he pierced seven palmyra palms, a hill, and the sixth nether worlds, carrying conviction to Sugrīva.\n\nThus convinced, the mighty monkey well pleased went with Rāma towards the cave called Kiṣkindhā .\n\nAnd having arrived there, that best of monkeys, Sugrīva of a tawny and golden hue, set up loud roars. And at those mighty sounds, out came the lord of monkeys; and having obtained Tārā ’s consent came before Sugrīva for battle. Then Rāghava killed Vālī on the spot with a single shaft.\n\nAnd, in compliance with Sugrīva’s request, having slain Vālī in battle, Rāghava conferred the kingdom on Sugrīva.\n\nThen that best of monkeys having summoned all the various monkeys, sent them in various directions in search of Janaka’s daughter.\n\nThen at the suggestion of the vulture Sampāti , the mighty Hanumān crossed the salt sea extending for a hundred Yojanas (900 miles).\n\nThereby arriving at the city of Laṅkā , ruled by Rāvaṇa, he found Sītā in the midst of an Aśoka garden, absorbed in thought.\n\nThen having shown her the sign, he related to her all about the friendship between Rāma and Sugrīva, and having convinced Videha ’s daughter, he smashed the gate of the place.\n\nThen having slain five generals, and seven counsellors’ sons, and crushed the heroic Akṣa , he was bound fast (by the armsof Indrajit .)\n\nThen knowing that in virtue of the grand-sire’s boon, he was free, he forgave those Rākṣasas that were leading him (to Rāvaṇa.)\n\nThen having burnt down the city of Laṅkā, with the exception of the place occupied by Mithilā’s daughter, the mighty one returned, with the intention of delivering the glad tidings to Rāma.\n\nThat one of immeasurable soul having come before the high-souled Rāma, and circled him addressed him, saying,—I have truly seen Sītā.\n\nThereafter accompanied by Sugrīva, Rāma repaired to the shore of the mighty ocean, and with shafts resembling the sun, vexed the deep.\n\nThen that lord of rivers, the Ocean, showed himself. And agreeably to the advice of the Ocean, Nala constructed a bridge (over the water.)\n\nBy that bridge Rāma went to the city of Laṅkā, and slew Rāvaṇa in battle. And, having recovered Sītā, Rāma experienced high shame (in consequence of Sītā’s having lived so long in Rāvaṇa’s place.)\n\nLanguage towards Sītā in the presence of all. Incapable of bearing it, the chaste Sītā entered flaming fire.\n\nThereupon assured by Agni as to the sinlessness of Sītā, Rāma became exceedingly pleased, and was honoured by all the deities. And at that great act of Rāma’s the three worlds with all that was mobile and immobile in them, along with the sages and gods, were well pleased with the mighty-souled Rāghava.\n\nThen installing that foremost of Rākṣasas, Vibhīṣaṇa , on the throne of Laṅkā, Rāma was perfectly easy, and rejoiced exceedingly.\n\nThen Rāma, obtaining a boon from the celestials, revived the monkeys fallen in battle, and surrounded by friends, set out for Ayodhyā on the Puṣpaka .\n\nAnd repairing to Bharadvāja’s hermitage, Rāma, having truth for his prowess, despatched Hanumān to Bharata.\n\nThen talking over past affairs, accompanied with Sugrīva, Rāma, mounted on the Puṣpaka, and departed for Nandigrāma.\n\nHaving arrived at Nandigrāma, the sinless Rāma sheared himself of his matted locks along with his brothers, and having regained Sītā, got back his kingdom\n\n(During his reign) his subjects will enjoy happiness, and contentment, and become hale, and grow in righteousness, and be devoid of mental disquietude and disease, and free from the fear of famine.\n\nWhere a no person is to witness his son’s death, and women will be ever chaste, and never bear widow-hood.\n\nAnd no fear of conflagration (will exercise people), nor creatures be drowned in water. And no danger will come from hunger, or from thieves. And all will live happily as at the Kṛta age.\n\nHaving performed with countless gold an hundred horse-sacrifices, and bestowed with due rites ayutas and koṭis [2] of kine on learned persons, and countless wealth on famous Brāhmaṇas, Rāghava will establish an hundred royal families, and will employ each of the four castes in its own duties.\n\nAnd having reigned for ten thousand and as many hundred years. Rāma will depart for the regions of Brahmā .\n\nHe that reads this sacred, sin-destroying, merit-bestowing history of Rāma like that of the Veda itself, becomes cleansed from all sin.\n\nAnd the man that reads this Rāmāyaṇa conferring length of days, after death, is honoured in heaven, along with his sons, and grandsons, and relations.\n\nIf a Brāhmaṇa reads it, he attains excellence in speech; if a Kṣatriya , he will acquire lordship over landed possessions; if a Vaiśya , abundance of wealth in trade; and if a Śūdra , greatness.\n\n[back to top]\n\n[1] :\n\nA great saint. The word, however, signifies one belonging to a particular order of saints.\n\n[2] :\n\nAyuta is ten thousand; and koṭi is ten millions.
18	1	18	Chapter XVIII	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365886.html	When the horse-sacrifice of the high-souled Daśaratha had been completed, the immortals, accepting each his share, returned whence they had come.\n\nAnd the monarch, having observed all the rules of initiation, entered the palace with his equipage and retinue.\n\nAnd the lords of the earth, having been received suitably by the king, with glad hearts set out for their own countries, saluting that foremost of ascetics ( Ṛṣyaśṛṅga ).\n\nAnd clad in bright appard, the delighted forces belonging to those graceful kings repairing to their own homes, looked exceedingly beautiful.\n\nWhen the lords of the earth had gone away, the graceful king Daśaratha re-entered his palace, with the foremost of regenerate ones at his head.\n\nFollowed by the intelligent monarch with his retinue, Ṛṣyaśṛṅga, having been duly honoured, set out with Śāntā . Having thus dismissed them all, the king, his object attained, began to dwell there happily, expecting sons.\n\nAnd then when the six seasons had rolled away after the completion of the sacrifice, in the twelfth month, on the ninth lunar day, under the influence of the Punarvasu asterism presided by Aditi devatā , when the Sun, the Moon, Saturn, Jupiter, and Venus were at Arius, Capricorn, Libra, Cancer, And Pisces, and when Jupiter had arisen with the Moon at Cancer, Kausalyā gave birth to that lord of the universe, bowed to by all the worlds, Rāma , the descendant of Ikṣvāku , furnished with excellent marks, the one half of Viṣṇu ,—exceedingly righteous, with rosy eyes, and mighty arms, and crimson nether lip, and endowed with a voice like the Sound of a kettledrum. Then on having given birth to that son of immeasurable prowess, Kausalyā looked resplendent, like Aditi on having brought forth that foremost of celestials the wielder of the thunder-bolt.\n\nThen was born of Kaikeyī , named Bharata , having truth for prowess, endowed with all the virtues, and representing the very fourṃ part of Viṣṇu.\n\nThen Sumitrā gave birth to Lakṣmaṇa and Śatrughna , heroic, and skilled in all weapons, and endowed with the half of Viṣṇu.\n\nAnd Bharata of purged intelligence was born under the asterism Puṣya , when the Sun had entered Pisces; while the two sons of Sumitrā were born when the Sun arose in Cancer, under the asterism of Āśleṣā . (The ninth lunar mansion)\n\nThus were separately born four high-souled sons to the king, crowned with qualities, and graceful, and in loveliness resembling the constellations Proṣṭhapaḍa [1] Thereat the Gandharvas began to chaunt sweetly, and the Apsaras to dance. And the celestial kettledrums sounded; and there showered down blossoms from the sky.\n\nAnd high festivities were commenced by the multitude in Ayodhyā . And the spacious highways became filled with players and dancers, glittering with all kinds of gems, and resounding with the music of singers and performers on instruments. And the king bestowed gifts upon bards and genealogists and panegyrists, and he also gave kine by thousands to Brāhmaṇas .\n\nWhen the eleventh day had gone by, the king performed the Naming ceremony of his sons. And experiencing great delight, Vasiṣṭha conferred the names. And the high-souled eldest one was called Rāma; and Kaikeyī’s son was called Bharata; and Sumitrā’s son was called Lakṣmaṇa, and the last was named Śatrughna.\n\nAnd the king fed the Brāhmaṇas as well as the inhabitants rural and urban; and he bestowed heaps of jewels upon Brāhmaṇas.\n\nThus did he celebrate the natal rites of the princes. And among all those princes, the eldest, Rāma, like that of Keṃ, (The ninth of the planets.) and the special delight of his father, became the object of general regard, even as the self-create Himself. And all of them were versed in the Vedas , and heroic, and intent upon the welfare of others.\n\nAnd all were accomplished in knowledge; and endowed with virtues. And among them all, the exceedingly puissant Rāma, having true for prowess, was the desire of every one, and spotless like to the Moon himself. He could ride on elephants and horses, and was an adept in managing cars. And he was ever engaged in the study of arms, and aye occupied in ministering to his sire.\n\nAnd even from early youth, that enhancer of auspiciousness Lakṣmaṇa was ever attached to his eldest brother Rāma, that delight of all. And like to another life of Rāma, Lakṣmaṇa furnished with auspiciousness was in everything attentive to Rāma’s wishes, even at the neglect of his own person. And that foremost of persons did not even attain sleep without Rāma’s company, nor did he partake any sweetmeat that was offered, unless Rāma partook it with him.\n\nWhen mounted on horse-back, Rāghava went a-hunting, Lakṣmaṇa went at his back bow in hand, protecting him. And that younger brother of Lakṣmaṇa, Śatrughna, likewise became ever dearer to Bharata than life itself.\n\nOn account of those exalted and well-beloved sons of his, Daśaratha experienced the excess of joy, like to the Grand-sire on account of the gods.\n\nAnd when they came to be furnished with knowledge, and crowned with virtues, and endowed with bashfulness and fame, and to attain wisdom in everything, and to be farsighted, Daśaratha, the father of such powerful and flamingly effulgent sons, became delighted even like that lord of worlds— Brahmā .\n\nThose tigers among men, ever engaged in the study of the Vedas, were accomplished in the art of archery, and always intent upon ministering to their father.\n\nOnce upon a time, when the virtuous king Daśaratha, surrounded by his priests and friends, was reflecting about the nuptials of his sons, to that high-souled one engaged in thought in the midst of his counsellors came the mighty ascetic Viśvāmitra .\n\nDesirous of seeing the king, he said to the warders,—Do you speedily announce that I, Gādhi ’s son, sprung in the Kuśika line, have come!\n\nHearing those words of his, they, urged on by them, all hurriedly began to run towards the royal chambers. And coming to the royal apartments, they communicated to Ikṣvāku’s descendant the arrival of the ascetic Viśvāmitra.\n\nHearing those words of theirs, Daśaratha surrounded by his priests, went out delightedly to meet him, like Indra going out to meet Bṛhaspati . [2]\n\nAnd having come to that ascetic observing vows and of flaming energy, the monarch with a cheerful countenance offered him the Arghya .\n\nThere upon, having accepted the king’s Arghya in accordance with the ordinance he enquired of the lord of men as to his continued prosperity and peace.\n\nAnd the exceedingly virthous descendant of Kuśika asked the king concerning the welfare of the exchequer, and the provinces; and the peace of his friends and acquaintances.\n\nAnd are they captains submissive: and have you vanquished your foes? And have you performed well the human and the divine rites?\n\nAnd approaching Vasiṣṭha and the other anchorites, that foremost of ascetics of exalted piety duly asked them regarding their welfare.\n\nAnd having been properly received by the monarch, they with glad hearts entered the royal residence, and sat them down according to precedence.\n\nThen gladly worshipping the mighty ascetic, Viśvāmitra, the exceedingly generous king, well-pleased, addressed him saying.\n\nLike that of the obtaining of ambrosia, like to a shower in a land suffering from drought, like to the birth of sons of worthy wives to him without issue, like that of the recovery of a lost thing, yea, like to the dawning of a mighty joy, I consider this your arrival. O illustrious ascetic, are you well come? What is even that which is nearest to your heart?\n\nYou, O Brāhmaṇa , are worthy of my best services. By luck it is that, O bestower of honour, I have gained you. To-day my birth has been crowned with fruit to-day has my life attained its object.\n\nAnd truly yesterday night has been succeeded by an auspicious morning, since I have beheld you. Having first attained exceeding effulgence by virtue of austerities performed for obtaining the title of Rājarṣi , you have afterwards obtained the status of a Brahmarṣi . You are worthy of manifold homage from me. This your exceedingly holy arrival appear wonderful.\n\nO lord, by beholding you, surely my body has been rendered pure. Tell me, what is it that you would have, and what is the purpose of your coming?\n\nṣṭ ftṃtf ^piīllṇḍMI ^ūīf ft wṭtfin wī -ṃwprrat fs^r i WflTR: ^wFTT fg^TUVUI I wish that I may be obliged by doing your will. And, O you of excellent vows, you ought not to hesitate. I will every way accomplish your will; for you are my god. O regenerate one, surely great prosperity come to me in consequence of your coming, inasmuch as it shall be the means of bringing me entire and excellent merit, O Brāhmaṇa!\n\nHearing this soul-soothing, ear-charming, and free-humble speech that was uttered, the illustrious prime of ascetics crowned with virtues, and furnished with all perfections, experienced exceeding delight.\n\n[back to top]\n\n[1] :\n\nOtherwise called Uttarabhādrapada and Pūrvabhādrapadā .\n\n[2] :\n\nAccording to Śruti Bṛhaspati is the Brahmā of the gods— Bṛhaspatir devānām Brahmā .
25	1	25	Chapter XXV	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365893.html	Hearing this excellent speech of that ascetic of immeasurable energy, that foremost of men answered him in these happy words,\n\nO best of ascetics, I have heard that the Yakṣa race is endowed with but small prowess. How can then that one of the weaker sex possess the strength of a thousand elephants?\n\nHearing this speech that was uttered by Rāghava of immeasurable energy, Viśvāmitra , delighting with his amiable words that subduer of foes, Rāma , and Lakṣmaṇa , said, Do you listen as to the means whereby attaining terrible strength, that one belonging to the weaker sex has come to possess strength and prowess by virtue of a boon.\n\nIn former times there was a mighty and exceedingly powerful Yakṣa, named Sukeṃ. And he had no issue. And he was of pure practices, and used to perform rigid austerities.\n\nAnd, O Rāma, the Grand-sire endowed her with that lord of Yakṣas , conferred upon him a gem of a daughter, by name Tāṭakā .\n\nAnd the Grand-sire endowed her with the strength of a thousand elephants; yet that illustrious one did not bestow a son on that Yakṣa.\n\nWhen she had grown, and attained youth and beauty, he gave that famous damsel to Jambha ’s son, Sunda , for wife.\n\nAfter a length of time, that Yakṣī gave birth to a son, named Mārīca , possessed of irrepressible energy, him who became a Rākṣasa in consequence of a curse.\n\nO Rāma, when Sunḍa had been destroyed, Tāṭakā along with her son, set her heart upon afflicting that excellent saint Agastya .\n\nAnd enraged with Agastya, she rushed at him with a roar, intending to devour him. And on seeing her thus rushing, that worshipful saint, Agastya, said to Mārīca, Do you become a Rākṣasa!\n\nAnd, in exceeding wrath, he also cursed Tāṭakā. And, O mighty Yakṣī, since in frightful guise with a frightful face you have desired to eat up a human being, do you immediately leave this (your original) shape, and become of a terrible form!\n\nThus cursed by Agastya, Tāṭakā, overwhelmed with rage, lays waste this fair region, where Agastya carry on his austerities.\n\nDo you, O descendant of Raghu , for the welfare of Brāhmaṇas and kine, slay this exceedingly terrible Yakṣī of wicked ways and vile prowess!\n\nNor, O son of Raghu, does any one in the three worlds, save, you, dare to slay this Yakṣī joined with a curse.\n\nNor should you, O best of men, shrink from slaying a woman; for even this should be accomplished by a prince in the interests of the four orders.\n\nWhether an act be cruel or otherwise, slightly or highly sinful, it should for protecting the subjects, be performed by a ruler.\n\nOf those engaged in the onerous task of government, even this is the eternal rule of conduct. Do you, O Kākutstha , slay this impious one; for she know no righteousness!\n\nWe hear, O king, that in days of yore, Śakra slew Virocana ’s daughter, Mantharā , who had intended to destroy the earth.\n\nAnd formerly, O Rāma, Viṣṇu destroyed Kāvya ’s mother, the devoted wife of Bhṛgu , who had set her heart upon annihilating the world, deprived of sleep (through fear of her.)\n\nBy these as well as innumerable princes—foremost of men—have wicked women been slain. Therefore, O king, renouncing antipathy, do you, by my command, slay this one!
31	1	31	Chapter XXXI	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365899.html	Those heroes, Rāma and Lakṣmaṇa , their interest secured, with glad hearts passed that night there.\n\nAnd when the night had passed away and the morning come, they together appeared before the saint, Viśvāmitra , and the rest.\n\nAnd having saluted that foremost of ascetics resembling flaming fire, your addressed him in gentle and honied accents.\n\nThese servants of yours, O best of ascetics, have come before you. Do you command, O chief of anchorites, what command of your are we to execute\n\nThus addressed by them the Maharṣis with yiśvāmitra at their head spoke to Rāma, saying,\n\nA highly meritorious sacrifice, O foremost of men, is to be celebrated by Mithilā ’s lord, Janaka . Thither shall we repair.\n\nAnd you, O tiger among men, must accompany us, and there behold a wonderful jewel of a bow.\n\nAnd formerly this bow of immeasurable energy, and dreadful, and exceedingly effulgent at the sacrifice, had been conferred in court by the celestials (on king Dcvarata.)\n\nAnd neither gods nor Gandharvas , neither Asuras nor Rākṣasas nor men, can fix the string upon it.\n\nAnd desirous of being acquainted with the prowess of this bow, many kings and princes came; but they in spite of their mighty strength, failed in stringing it.\n\nThere, O Kākutstha , you will behold that bow belonging to the high-souled king of Mithilā, as well as his exceedingly wonderful sacrifice.\n\nThat rare bow, O foremost of men, furnished with an excellent device for griping it, had been solicited by Mithilā’s lord as the fruit of his sacrifice; and the celestials conferred it upon him.\n\nNow, O descendant of Raghu , in the residence of the king, the bow is worshipped like a deity with aguru dhūpa , and various other incenses.\n\nThis having been said, that foremost of ascetics, in company with Kākutstha and the saints, departed.\n\nAnd on the eve of setting out, he addressed the sylvan deities, saying, Luck! I will, with my desire obtained, go from forth this Siddhāśrama to the Himavat mountain on the north of the Jāhnavī .\n\nHaving said this, that tiger-like ascetic, Kuśika ’s son, along with other anchorets having asceticism for their wealth, set out in a northerly direction.\n\nAnd as that best of ascetics proceeded, he was followed by Brāhmaṇas , unholding the Veda , carrying the sacrificial necessaries on an hundred cars.\n\nAnd birds and beasts dwelling in Siddhāśrama followed the high-souled Viśvāmitra having asceticism for wealth.\n\nHaving proceeded a long way, when the sun was sloping down, the ascetics rested on the banks of the Śoṇa . And when the maker of day had set, having bathed and offered oblations to the fire those ascetics of immeasurable energy, placing Viśvāmitra in their front, sat them down. And Rāma also together with Sumitrā ’s son, having paid homage to those ascetics, sat him down before the intelligent Viśvāmitra.\n\nThen Rama of exceeding energy, influenced by curiosity, asked that foremost of ascetics, Viśvāmitra, having asceticism for his wealth, saying, O worshipful one, what country is this, graced with luxuriant woods? I am desirous of hearing this Good betide you, it behove you to tell me this truly.\n\nThus addressed by Rāma, that one of high austerities and excellent vows began in the midst of the saints to describe the opulence of that region.
36	1	36	Chapter XXXVI	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365904.html	When the ascetic had spoken thus, both the heroes, Rāma and Lakṣmaṇa , saluting that first of anchorites, said,\n\nO Brāhmaṇa , you have delivered this noble narration fraught with morality. Now it behoves you to speak about the elder daughter of the mountain-king. You are extensively conversant with everything relative to men or gods.\n\nWhy is it that purifier of the worlds lave three directions? And why is that foremost of streams, Gaṅgā , famous as wending in three ways\n\nAnd, O you cognizant of morality, what are her performances in the three worlds? Thereat Viśvāmitra having asceticism for this wealth, began to relate to Kākutstha that history in detail in the midst of the ascetics.\n\nIn days of yore, O Rāma, the blue-throated one of mighty asceticism, having entered into matrimony, commenced upon knowing the goddess. And as that intelligent blue-throated god, Mahādeva , was thus engaged in sport, a divine hundred years passed away.\n\nAnd yet, O Rāma, chastiser of foes, no son was born of her. Thereat all the gods with the Grand-sire at their head became exceedingly anxious.\n\nWho will be able to bear the offspring of this union? And thereupon the celestials repairing to Mahādeva, thus addressed him, saluting low,\n\nO god of gods! O mighty deity! ever engaged in the welfare of all, it behove you to be propitious at the humble salutations of the celestials.\n\nThe worlds, O foremost of celestials, are incapable of bearing your energy. Therefore, for the welfare of the three worlds, do you, being furnished with Brahmā asceticism, in company with the goddess practise austerities, and rein in your energy by your native indomitableness.\n\nDo you preserve these worlds; for it become you not to destroy all.’\n\nHearing the words of the deities, the great god of the worlds said to them, ‘So be it!’ And addressing them again he said,\n\nYou gods, by my own energy I will assisted by Umā bear my virile vigour, therefore let the creation find rest!\n\nBut tell me, you foremost of celestials, who will sustain my potent virility rushing out from its receptacle?’\n\nBeing thus addressed, the gods answered him having the bull for his mark, ‘The earth will today bear your vital flow.’\n\nThus assured, the mighty lord of the celestials let go his vital fluid; and thereat the earth containing mountains and forests was overspread with the energy.\n\nThen the gods spoke to the Fire, saying, ‘Do you in company with the Wind entrain to this fierce an mighty energy!’\n\nWhen the Wind had entered into it, it was developed into a white hill, and a forest of glossy reeds, resembling fire or the Sun.\n\nHere sprang from Fire Kārtikeya of mighty energy. And thereupon the celestials and the saints, with gratified hearts, began to pay enthusiastic adorations to Umā and Śiva .\n\nThen the Mountain’s daughter, O Rāma, addressed the celestials, cursing them with eyes reddened in wrath.\n\nWhile in association with Mahādeva for obtaining sons, I was broken in upon by you, for this, you shall not be able yourselves to beget offspring on your wives. And from this day forth, your wives shall remain without issue.’\n\nHaving thus spoke to the celestials, she cursed the Earth also, saying, ‘O Earth, you will have multiform surface and many husbands.’\n\nNor, stained because of my ire, shall you experience the pleasure that is felt on obtaining a son, O you of wicked understanding, O you that do not wish me a son!\n\nWitnessing the gods, thus distressed, the lord of the celestials set out in the direction presided over by Varuṇa (The West).\n\nAnd having repaired to the north side of that mountain, Maheśvara along with the goddess became engaged in austerities on the peak Himavatprabhava.\n\nI have now related to you, O Rāma, the spread of the Mountain’s daughter, (Gaṅgā). Do you now together with Lakṣmaṇa listen to the narration of Bhāgīrathī ’s potency.
43	1	43	Chapter XLIII	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365911.html	When that god of gods had gone away, Bhagīratha , O Rāma , pressing the earth with his thumb, spent a year in adoring Śiva .\n\nAnd when the yea was complete, Umā’s lord, Paśupati , worshipped of all the worlds, spoke to the king, saying,\n\nO foremost of men, I am well pleased with you: I will do what will before your welfare. I will hold the Mountain’s daughter on my head.\n\nThen, O Rāma. that one bowed to by all creatures, the elder daughter of Himavat , assuming an exceedingly mighty shape, with irresistible impetus precipitated herself from the welkin upon Śiva’s gracious head.\n\nAnd that divine one, Gaṅgā , exceedingly difficult to sustain, thought, ‘I will enter the nether regions, carrying off Śaṅkara by my streams.’\n\nKnowing her proud intention, the adorable Hara waxed wroth; and the three-eyed deity set his heart upon enveloping Here\n\nO Rāma, as that sacred one plunged upon Rudra ’s holy head of tangled locks, resembling Himavat she could by no means reach the earth, despite all her endeavours; nor did she obtain egress from under the matted locks. And she wandered there for many a year.\n\nAnd finding Gaṅgā in this plight, Bhagīratha became again engaged in high austerities. And thereupon Śiva, O descendant of Raghu , was exceedingly gratified; and cast Gaṅgā off in the direction of the Binḍu lake. And as she was let off seven streams branched out from her.\n\nAnd the three streams of the excellent Gaṅgā of auspicious waters took an easterly direction; while the Sucakṣu , the Sītā , and that mighty river the Sindhu flowed on the auspicious west.\n\nAnd the seventh followed Bhagīratha’s car. And that royal saint, the exceedingly puissant Bhagīratha, mounted on a superb car, went before; and Gaṅgā followed him. And she descended from the welkin upon Śaṅkara’s head, thence alighting upon the earth.\n\nAnd there her waters flowed with thundering sounds. And earth looked beautiful with swarms of fallen and falling fishes, and tortoises, and porpoises.\n\nThen celestials and saints and Gandharvas and Yakṣas and Siddhas mounted on excellent elephants and horses and cars resembling cities, looked on Gaṅgā descending upon earth.\n\nAnd the celestials stationed on cars were struck with surprise; and all creatures marvelled at the excellent descent of Gaṅgā.\n\nAnd eager to witness the spectacle, celestial hosts of immeasurable energy thither and the effulgence of their ornaments, the firmament free from clouds, shone as if with an hundred suns.\n\nAnd the sky was graced with fast-fleeting porpoises and serpents and fishes resembling playing lightning; and the welkin scattered with pale foam-flakes by thousands, appeared as if it was scattered with autumnal clouds swarming with cranes.\n\nAnd the river proceeded sometimes rapidly, and sometimes awry, and sometimes in volumes and sometimes sloping, and sometimes ascending and sometimes languidly; and sometimes water clashed with water.\n\nSometimes ascending an upland, it descended it no a dell. And the pellucid and pure water first descending upon Śaṅkara’s head, and thence on to the earth, appeared exceedingly beautiful.\n\nAnd there the saints and the Gandharvas, as well as the inhabitants of the earth, touched the sacred water flowing from Bhava ’s body.\n\nAnd those that had fallen from the sky to the earth in consequence of some curse of other, having bathed there, and thereby having their sins washed an removed by that sanctifying water, again ascended the sky and entered the celestial regions.\n\nAnd through the agency of that shining water, all beings, feeling delight, rejoiced, and having bathed in Gaṅgā, became cleansed from sin.\n\nAnd stationed on an excellent car that mighty king, the royal saint Bhagīratha, went first, and Gaṅgā went at his back.\n\nThe gods, and the saints, and the Daityas , and the Dānavas , and the Rākṣasas , and the foremost of Gandharvas and Yakṣas, and the Kinnaras , and the mighty Uragas , and the Serpents, and the Apsaras , O Rāma, and the acquatic animals in a body following Bhagīrahta’s car, with glad hearts went in the wake of Gaṅgā.\n\nWhither soever king Bhagīratha went, the famous Gaṅgā, foremost of streams, capable of destroying all sins, went.\n\nAnd Gaṅgā flooded the sacrificial ground of the high-souled Jahnu of wonderful deeds, as he was performing a sacrifice.\n\nThereat, O Rāghava , reading her insolence, Jahnu, waxing wroth, drank up all her wonderful waters. Thereupon, the deities, and the Gandharvas, and the saints, struck with amazement fell to worshipping that foremost of men, the high-souled Jahnu.\n\nAnd that highly energetic lord, being propitiated, let Gaṅgā off through his ears. Therefore it is that Gaṅgā goes by the name of Jahnu’s daughter.\n\nThen Gaṅgā again began to follow Bhagīratha’s car. And having reached the ocean, that foremost of streams, with the object of accomplishing that work, entered into the subterranean regions.\n\nHaving carefully brought Gaṅgā, that royal saint, Bhagīratha, beheld his grand-fathers deprived of senses, and reduced to ashes.\n\nThe excellent waters of Gaṅgā overflowed that heap of ashes; and thereupon, O best of the Raghus , they their sins purged; attained heaven.
47	1	47	Chapter XLVII	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365915.html	When the embryo had been sundered is seven, Diti exceedingly aggrieved humbly spoke to the irrepressible thousand-eyed deity, saying,\n\nBy my fault it is that the embryo has been sundered in seven. O chief of the celestials, herein you are guilty of no transgression, O destroyer of Bala .\n\nAnd since calamity has befallen the embryo, I wish to do you a good turn. Let the seven parts become the guardians of the seven Maruts .\n\nO son, let my sons having noble forms, becoming famous as Marutas range the Vātaskandha regions in heaven.\n\nLet one range Brahmā ’s regions, and another Indra ’s, and the highly illustrious third also range around, being known as Divya Vāyu , (Ether).\n\nO best of celestials, by they command, let the four remaining sons of mine, known by the name which you have mentioned, range about in appointed periods.’\n\nHearing her words, that destroyer of Vala ; the thousand-eyed Purandara , with clasped palms said.\n\nAll this that you have said must come to pass; there is no doubt about it. Good betide you, your sons endowed with celestial forms, shall range about.\n\nAnd it has been heard by us that having thus ascertained in that hermitage, the mother and the son, O Rāma , went to heaven, their desire obtained.\n\nEven this O Kākutstha , is the place where formerly the mighty Indra sojourned, and where he attended upon Diti of accomplished ascetic success.\n\nO most powerful of men, Ikṣvāku had an exceedingly righteous son born to him of Alambuṣa , known by the name of Viśāla . And here stood a palace, built by him, called Viśālā .\n\nViśāla’s son, O Rāma, was the mighty Hemacandra . And after Hemacandra comes the celebrated Sucandra .\n\nO Rāma, the son of Sucandra was Dhumrāśva, and then was born Sṛñjaya son to Dhumrāśva.\n\nSṛñjaya’s son was the powerful Sahadeva , And Sahadeva’s son was the pre-eminently pious Kuśāśva .\n\nKuśāśva’s son was the puissant Somadatta . And now, O Kākutstha, Somadatta’s son, the effulgent and invincible and renowned Sumati reside in this mansion.\n\nAnd by the grace of Ikṣvāku, all the sovereigns of Viśālā are long-loved, and high-souled, and puissant, and pious.\n\nAnd here will we happily spend a night; an on the morning of the morrow you will, O foremost of men, behold Janaka .’\n\nAnd having heard that the illustrious Viśvāmitra had come, that best of kings, the effulgent Sumati, appeared before him.\n\nAnd having paid Viśvāmitra high homage together with his priests and friends, and with clasped hands enquired after the former’s welfare, he addressed Viśvāmitra, saying.\n\nBlessed are we, and obliged are we, whose domains, O ascetic, have been graced with your presence. Surely none is more blessed than I am.
55	1	55	Chapter LV	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365923.html	And beholding them sore harassed, and overwhelmed by Viśvāmitra ’s weapons, Vasiṣṭha directed ( Śabala ) saying, ‘O cow of plenty, do you create (fresh troops), through your Yoga power.’\n\nAnd from her roar, there came into being Kāmbojas , resembling the Sun. And from her udders sprang Barbaras , arms in hand; and from her mysterious parts, Yavanas ; from her anus, Śakas ; and from the pores of her skin, those barbarians, Hārītas and Kirātas .\n\nAnd, O descendant of Raghu , anon Viśvāmitra’s entire host consisting of foot, and elephant, and horse, and car, was exterminated by them.\n\nSeeing the army annihilated by the high-souled Vasiṣṭha, the hundred sons of Viśvāmitra, equipped with various weapons, rushed in high ire against that best of mantra -reciting ones. Thereupon, uttering a roar, that mighty ascetic consumed them quite.\n\nIn a moment, Viśvāmitra’s sons together with horse and car and foot were reduced to ashes by the high-souled Vasiṣṭha.\n\nAnd witnessing them all destroyed, together with the army, the illustrious Viśvāmitra, covered with shame, became plunged in thought.\n\nAnd like to a tideless ocean or a fangless snake, he instantly became shorn of his effulgence, like to the sun overwhelmed by Rāhu . [1]\n\nAnd deprived of his forces and sons, he appeared like a bird bereft of its wings; and losing his entire army and with it the high spirits that it had inspired him with, his heart died within him.\n\nThen entrusting one of his (remaining) sons with the sovereignty, with, ‘Do you rule the earth agree ably to the duties of the Kṣatriya ,’ he went into the forest.\n\nAnd repairing to the side of the Himavat inhabited by Kinnaras and Serpents that one of mighty asceticism began to perform austerities with the view of propitiating Mahādeva .\n\nOn a certain occasion the lord of the celestials, Vṛṣadhvaja , [2] intending to confer a boon, appeared before a mighty ascetic Viśvāmitra.\n\nWhat for, O king, art you performing penance? Do you unfold what you-have to say. I am for conferring a boon: do you express what boon you would obtain.\n\nThus addressed by that god, that performer of mighty austerities, Viśvāmitra, bowing down to him, addressed him, saying.\n\nIf, O mighty god, you are pleased (with me), do you confer upon me the science of archery with all its mysteries and mantras , as well as its virtues of helping from far and near.\n\nO sinless one, may all those weapons that are with the celestials and the Dānavas and the Maharṣis and the Gandharvas and the Yakṣas and the Rākṣasa , shine on me! May this my desire be granted me through your grace, O god of gods!\n\nThereupon, saying, ‘Be it so’ the lord of the celestials vanished. And obtaining the arms from the lord of the celestials, the mighty Viśvāmitra, naturally haughty, became swelled with insolence.\n\nsurcharged with energy, like to the sea during the equinox, he considered, O Rāma , as if that foremost of saints, Vasiṣṭha, was already slain.\n\nAnd repairing to Vasiṣṭha’s asylum, the king began to discharge weapons; and by their energy the hermitage began to bum.\n\nBeholding those weapons discharged by the intelligent Viśvāmitra, the ascetics, overtaken by fear, by hundreds began to fly.\n\nVasiṣṭha’s disciples as well as the aniṃals and birds inhabiting there, fled in all direction by thousands.\n\nFor a time the hermitage of the high souled Vasiṣṭha was bare of living beings, and still like to a wilderness.\n\nAnd Vasiṣṭha cried momentarily, ‘Do not fear. To day will I slay Gādhi ’s son, even as the sun (destroys) mist.’\n\nHaving said this, that best of mantra reciting ones, Vasiṣṭha, in high wrath, addressed Viśvāmitra, saying.\n\nSince, O fool, you have destroyed this hermitage that had been prospering for a long time, you of execrable ways shall not live long.\n\nSaying this, he, transported with wrath, and like to the smoking flame at universal dissolution, speedily upraised a staff resembling another mace of Yama itself?\n\n[back to top]\n\n[1] :\n\nA Daitya with the tail of a dragon, whose head was served from his body by Viṣṇu ; but being immortal, the head and tail retained their separate existence, and being transferred to the stellar sphere, became the author of eclipses.\n\n[2] :\n\nAn appellation of Śiva : meaning who has the bull for his vehicle.
66	1	66	Chapter LXVI	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365934.html	The next morning, which happened to be bright, the lord of men, having performed his daily devotions, welcomed Viśvāmitra and Rāghava . And having, in accordance with the scriptures, paid homage to the former as well as the two high-souled Rāghavas , that virtuous one said,\n\nHail, O worshipful sir! What shall I do to you, O sinless one? Do you command. Surely, I deserve to be commanded by you.\n\nThus addressed by the high-souled Janaka , that first of ascetics endowed with a righteous soul, well versed in speech, answered,\n\nThese sons of Daśaratha — Kṣatriyas , famed among men, are eager to behold than best of bows.\n\nIf it be with you, do you show it to them, may it be well with you! having obtained a sight of that bow, the king’s sons, their desires crowned with success, will success, will return as they list.\n\nThus accosted, Janaka replied to the mighty Muni , saying, Listen to why the bow lie here.\n\nThere was a king known by the name of Devarata . He was the elder brother of Nimi . And, O worshipful one, this bow was consigned to the hands of that high-souled one, this bow was consigned to the hands of that high-souled one as a trust.\n\nFormerly with the view of destroying Dakṣa ’s sacrifice, the puissant ( Śiva ), drawing this bow, sportively spoke to the celestials in ire, saying, ‘Since, you gods, you deny me the shares (of this sacrifice), which I lay claim to, I will with my bow even sever those heads of yours.’\n\nThereat, O powerful ascetic, with agitated hearts, the deities fell to propitiating that lord of the celestials, and Bhava was pleased with them.\n\nAnd well-pleased with them, he conferred this upon those high-souled ones. And even this is that jewel of a bow belonging to the high-souled god of gods, and which was ultimately, O lord, consigned as a trust to our ancestor.\n\nAnd as I was ploughing the mead, arose a damsel, and as I obtained her while hallowing the field (for sacrifice), she has come to be known by the name of Sītā . And arising from the earth, she grew as my daughter.\n\nUnsprung from the usual source, she was then established here as my daughter, whose hand must be obtained by bending the bow. And, O foremost of ascetics, many a king, coming here, had saught to obtain my growing daughter arisen from the earth. But, O worshipful one, in consideration of her being one whose dower must be prowess in bending the bow, I would not bestow my daughter upon those lords of earth seeking for the kings in a body began to flock to Mithila , desirous of being acquainted with the strength of the bow.\n\nAnd on their being curious (as to the bow), I showed it to them; but they could neither hold nor wield it.\n\nAnd, O mighty Muni, finding those powerful kings to be but endowed with small prowess, I passed them by. Hear what then befell, O you of ascetic wealth. Then, O powerful anchorite, in high ire, the kings, doubtful as to their strength in stringing the bow, laid siege to Mithila. And those potent princes, conceiving themselves as frustrated by me, began to harass the city of Mithila, waxing wondrous wroth.\n\nAnd when a year had been completed, my defensive resources were entirely exhausted, and at this, I was exceedingly aggrieved.\n\nThen I sought to propitiate the deities; and well-pleased, the celestials granted me a Caturaṅga army.\n\nAt length those wicked kings, meeting with slaughter, broke and fled in all directions, together with their adherents, bereft of vigour, and confidence in their strength.\n\nAnd, O puissant ascetic, this highly effulgent bow will I show to Rāma and Lakṣmaṇa .\n\nO you of excellent vows. And, if, Ascetic, Rāma succeeds in fixing string to it, I will confer upon Daśaratha’s son my daughter Sītā, unsprung from the usual source.
67	1	67	Chapter LXVII	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365935.html	Hearing Janaka ’s words, the mighty Muni Viśvāmitra said to the king, Do you show the bow to Rāma .\n\nThereupon the king Janaka commanded his ministers, saying, Do you bring the wonderful bow furnished with unguents and garlands,\n\nCommanded by Janaka, the ministers entered the city; and placing the bow in their front, those, endowed with immeasurable energy, came out.\n\nAnd deposited in a case on a cart borne upon eight wheels, it was with difficulty drawn along by five thousand stalwart persons of well-developed frames.\n\nAnd having brought that bow plaited with iron, placed in its case, the royal counsellors spoke to Janaka resembling an immortal, saying,\n\nHere is the best of bow, O king, worshipped of all sovereigns. O foremost of kings, O lord of Mithilā , if it please you, behold the same.\n\nHearing their speech, the king with clasped palms said to the high-souled Viśvāmitra as well as Rāma and Lakṣmaṇa ,\n\nThis best of bows, O Brāhmaṇa , has always been worshipped by the Janakas : as also by mighty kings incapable (of wielding and stringing it.)\n\nAnd neither the celestials, nor the Asuras , nor the Rākṣasas , nor the Gandharvas , nor the Yakṣ as, nor the Kinnaras , nor the mighty Uragas , how shall men fare—have succeeded in stringing or stretching it, or fixing the arrow to it, or pulling its string, or wielding it.\n\nThis foremost of bows has been brought here, O chief of ascetics. Do you, O exalted one, show it to these sons of the king.\n\nHearing Janaka’s words, the righteous Viśvāmitra said to Rāghava , O Rāma, do you, my child, behold the bow.\n\nAt the words of the Maharṣi , Rāma, opening the case, took a sight of the bow, and said,\n\nThis divine bow will I touch with my hand, and shall I also strive to wield and draw it?\n\nThereat both the king and the ascetic said,—Excellent well. At the words of the anchorite, in the sight of countless thousands of spectators, the righteous son of Raghu with exceeding ease took hold of the bow by the middle, and fixed the string upon it, and having fixed the string, drew it. And that foremost of men enjoying high fame, snapped the bow in the middle. And mighty was the sound that was heard on the occasion, like to the bursting of a thunder-clap: and the earth trembled terribly, as it does in the vicinity of a mountain splitting; and overwhelmed by the noise, all rolled head over heels, with the exception of that best of ascetics, the king, and the two Rāghavas .\n\nOn the people being reassured, the king conversant with speech, his apprehension removed, with folded hands addressed that puissant ascetic, saying.\n\nO worshipful one, I have beheld the prowess of Daśaratha ’s son. This is verily wonderful and inconceivable; and I did not think this was possible.\n\nMy daughter, Sītā , being united with her lord, Daśaratha’s son, Rāma, will shed lustre on Janaka’s line.\n\nMy promise viz., that I will confer Sītā upon him that will bend the bow, has been fulfilled, O son of Kuśika . And this Sītā, this my daughter, dearer to me than life will I confer upon Rāma.\n\nO Brāhmaṇa, by your permission let my counsellors speedily post hence, O Kauśika , to Ayodhyā , in cars; and with humble speech bring the king to my capital. And let them communicate to him all about the bestowal of’ Sītā upon Rāma, in consequence of his having bent the bow.\n\nLet them acquaint the monarch with the welfare of the Kākutsthas protected by the ascetic; and let them, speedily posting hence, bring the delighted king.\n\nAnd thereupon Kuśika’s son said,—So be it. And the righteous king, summoning his counsellors, despatched them to Ayodhyā with his letter, to communicate all duly to the king, and bring him thither.
70	1	70	Chapter LXX	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365938.html	Then next morning Janaka skilled in speech, having in company with the Maharṣis performed his daily duties, addressed the priest Śatānanda , saying\n\nMy highly energetic, puissant and eminently righteous brother known by the name of Kuśadhvaja dwell in the auspicious city, Sāṅkāśyā , whose ramparts are ranged round with pointed weapons, and which is laved by the river Ikṣumatī , and which resembles the celestial regions or the aerial car, Puṣpaka .\n\nI wish to see him, and he is in charge of my sacrifice. And that highly energetic one will partake with me the joy of this occasion.\n\nThis having been said to Śatānanḍa, some competent persons presented themselves; and Janaka commanded them (to set up) for Sāṅkāśyā.\n\nAnd commanded by the monarch, off they want, mounting on fleet coursers, with the view of bringing over that tiger among men, like Viṣ ṇu at the mandate of Indra .\n\nAnd arriving at Sāṅkāśyā, they presented themselves before Kuśadhvaja, and faithfully delivered to him the intention of Janaka.\n\nAnd hearing the tidings conveyed by those foremost of envoys endowed with great fleetness, Kuśadhvaja set out at the mandate of the monarch.\n\nAnd on coming to Viḍeha, he appeared before the high-souled Janaka addicted to righteousness. And saluting Śatānanda as well as the eminently virthous Janaka, he sat down on an excellent and superb seat worthy of a King.\n\nHaving been seated, both the heroic brothers of immeasurable splendour addressed that foremost of counsellors, Sudāman , saying, ‘Go, foremost of counsellors, and speedily bring over the irrepressible Ikṣvāku of immeasurable splendour along with his sons and ministers.’\n\nThereupon, repairing to the camp of that enhancer of the race of the Raghus , he saw Daśaratha , and saluting him with beaded head, addressed him.\n\nO heroic lord of Ayodhyā , Vaideha , the master of Mithila , has wished to see you along with your priests.\n\nHearing the words of that best of counsellors, the king accompanied by the saints and his adherents, came to Janaka.\n\nAnd in company with his counsellors with his counsellors and priests and adherents, the king, foremost of those skilled in speech, spoke to Vaideha.\n\nO mighty king, you know that the worshipful saint Vasiṣṭha is the spiritual guide of our race; and in every ceremony that we undertake, he it is who serves the function of a spokesman.\n\nAnd permitted by Viśvāmitra along with all the Maharṣis, even this one of a righteous soul will relate my genealogy.\n\nAnd on Daśaratha resuming silence, the worshipful saint Vasiṣṭha, versed in speech, spoke to Vaideha in company with his priests, saying,\n\nThe perpetual, everlasting, and undeterio- rating Brahmā sprang from the Unmanifest (Brahmā). From him sprang Marīci ; and Kaśyapa is son to Marīci. And from Kaśyapa sprung Vivasvat ; and Manu is son to Vivasvat. [1]\n\nThis Manu is otherwise called Prajāpati ; and Ikṣvāku is Manu’s son. And this Ikṣvāku you must understand, was the first king of Ayodhyā.\n\nAnd Ikṣvāku’s son, it is well known, was the graceful Kukṣī . And Kukṣī’s son was the graceful Vikukṣī.\n\nAnd Vikukṣī’s son was the exceedingly energetic and powerful Bāṇa . And Bāṇa’s son was the highly energetic and powerful Anaraṇya .\n\nFrom Anaraṇya sprang Pṛthu ; and from Pṛthu, Triśaṅku . And Triśaṅku’s son was the highly famous Dhundhumāra .\n\nAnd from Dhundhumāra sprung the Mahāratha , Yuvanāśva . And from Yuvanāśva sprung Māndhātā , lord of earth.\n\nAnd Māndhātā’s son was the graceful Susandhi . And Susandhi’s two sons were Dhruvasandhi and Prasenajit .\n\nAnd from Dhruvasandhi sprung the famous Bharata . And from Bharata sprung Asita ; to fight whom were born as hostile kings, those heroes, the Haihayas , the Tālajaṅghas , and the Śaśabindus .\n\nAnd engaged in conflict with them, that king fled (from his kingdom); and repairing to the Himavat in company with his two consorts, the feeble Asita there paid his debt to nature.\n\nThe story runs that his two wives were in the family way; and that with the intention of destroying the embryo of the other, one of them administered poison to the former mixed in her food.And it came to pass that at this time, Bhṛgu ’s son, the ascetic Cyavana , had become addicted to the romantic Himavat, foremost of mountains. And here one of those exalted dames with eyes resembling lotus-petals, saluting Bhṛgu’s son born shining like a celestial, desired of him an excellent, son. And drawing near to that sage, Kālindi saluted him.\n\nAnd that Vipra said to her, who was desiring of having a son born of her,—In your womb, O exalted one, will be speedily born an excellent son mixed up with poison, highly powerful, and exceedingly energetic, and possessed of mighty strength, and graceful.\n\nTherefore, do you not grieve, O you of lotus-eyes. And having paid reverence to Cyavana, that chaste and worshipful princess, although bereft of her husband, gave birth to a son.\n\nAnd since intending to destroy her foetus she that was co-wife with her had administered poison to her, Sagara [2] was born together with the poison.\n\nAnd Sagara’s son was Asamañja , and Aṃśumat . And Dilīpa was son to Aṃśumat, and Bhagīratha to Dilīpa.\n\nAnd from Bhagīratha sprang Kākutstha , and from Kākutstha, Raghu . And Raghu’s son was the puissant Pravṛdha, feeding on human flesh.\n\nAnd he came finally to be known by the name of Kalmāṣapāda .* And from him sprung Śaṅkhaṇa . And Sudarśana was Śaṅkhaṇa’s and Agnivarṇa was Sudarśana’s son.\n\nHe incurred Vasiṣṭha’s curse, and was turned into a Rākṣasa . He took up water, intending to clear scores with Vasiṣṭha; but at the request of his wife, desisted, pouring down the water at his own feet. Hence the name of Kalmāṣapāda.\n\nŚīghraga was Agnivarṇa’s, and Maru was Śīghraga’s son. And Mam’s son was Praśuśruka, and from Praśuśruka sprung Ambarīṣa .\n\nAmbarīṣa’s son was Nahuṣa , lord of earth. And Nahuṣa’s son was Yayāti , was Nābhāga . And Nābhāga’s son was Aja, and from Aja sprung Daśaratha. And from this Daśaratha have come the brothers Rāma and Lakṣmaṇa . snf^crṣṭfcrgsHr TḤrf wṃñfaTPḤ\n\nIt is in the interests of Rāma and Lakṣmaṇa belonging to the heroic and truthful and pious sovereigns sprung in the Ikṣvāku line, and possessing purity of race even from the time of their founder, that, O king, we solicit the hands of your daughters. And, O foremost of men, it behove you to confer like brides upon like bridegrooms.\n\n[back to top]\n\n[1] :\n\nThe Bengal Text reads: From Marīci sprang Aṅgiras; and his son was Pracetas; and Manu is Praceta’s son.\n\n(The Bengal Text: From Ikṣvāku sprung Vikukṣī.)\n\n[2] :\n\nGara —poison. Sagara means, with poison, i.e. here, one born with poison.
71	1	71	Chapter LXXI	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365939.html	When Vasiṣṭha had spoken thus, Janaka with clasped hands answered to him, saying,—It behove you to listen to our genealogy as related by myself. In the matter of disposal of daughters, O foremost of anchorets, one’s own line should be described by one boasting of a noble ancestry. Do you then, O mighty-minded one, listen to the same.\n\nThere was a king famed over the three worlds by his own acts, Nimi —eminently pious and the foremost of those endowed with strength.\n\nHis son was named Mithi , and Mithi’s son was Janaka. And from this king Janaka have we derived that word as applied to every one of us. And from Janaka sprang Udāvasu ;\n\nUdāvasu’s son was the pious-souled Nandivardhana . And Nandivardha’s son was the heroic Suketu .\n\nSuketu’s son was the mighty and righteous Devarata . And the Rājarṣi Devarāta ’s son was Bṛhadratha .\n\nBṛhadratha’s son was the heroic and puissant Mahāvīra . And Mahāvīra’s son was Sudhṛti , endowed with fortitude and having truth for prowess.\n\nSudhṛtia’s son was the pious-spirited and eminently righteous Dhīṣṭaketu. And the Rājarṣi Dhīṣṭaketu’s son was Haryaśva .\n\nHaryaśva’s son was Maru ; and Maru’s son was Pratīndhaka. And Pratīndhaka’s son was the righteous king Kīrtiratha .\n\nKīrtiratha’s son was Devamīḍha , and Devamīḍha’s Vibudha , and Vibudha’s Mahīdhraka.\n\nMahīdhraka’s son was king Kīrtirāta endowed wūth great strength. And the Rājarṣi Kīrtirāta had Mahāroman born to him.\n\nMahāroman, the virthous Svarṇaroman . And the Rājarṣi Svarṇaroman had Hrasvaroman born to him.\n\nThis high-souled king conversant with morality had two sons: the elder, myself the younger, even my brother, who was the elder son, and consigning to my care Kuśadhvaja , our father sought the forest.\n\nAnd on my aged sire ascending heaven, I righteously ruled the kingdom and cherished my brother Kuśadvaja resembling a celestial, with the eye of affection.\n\nIt came to pass that on one occasion a certain powerful king named Sudhanvan came before Mithilā intending to lay siege to it.\n\nHe sent word to me, saying, ‘Do you give me the all-excellent bow of Śiva , as well as your daughter, the lotus-even Sītā .’\n\nAnd is consequence of my not granting him either, king Sudhanvan, O Brahmarṣi , entered into hostilities with me; but he was both defeated and slain by me in the encounter.\n\nO foremost of ascetics, slaying king Sudhanvan. I installed in Sāṅkāśyā my heroic brother Kuśadhvaja.\n\nThus one, O mighty anchorite, is my younger brother, and I am his elder. O powerful ascetic, well pleased will I confer on you these as your daughter-in-law,\n\nSītā on Rāma , good betide you, and Urmilā on Lakṣmaṇa . And, I take oath thrice that, without doubt, I will with a glad heart confer upon you, O potent ascetic, as your daughters-in-law my second daughter Urmilā and also Sītā resembling the daughter of a celestial, having prowess assigned for her dower.\n\nDo you now, O king, give away kine on behalf of the nuptials of Rāma and Lakṣmaṇa; and also perform their ancestral rites, good to you; and then complete the marriage ceremony.\n\nTo-day the star Maghā is on the ascendant. On the third day, my master, when the Phalguna will be on the north, do you, O monarch, perform the marriage ceremony. Do you now, however, dispense gifts for invoking blessings upon Rāma and Lakṣmaṇa.
72	1	72	Chapter LXXII	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365940.html	When Vaideha had spoken thus, the mighty ascetic Viśvāmitra is company with Vasiṣṭha addressed that heroic king, saying.\n\nO puissant one, the lines of the Ikṣvākus and the Vaidehas are exceedingly noble and incomparable. No other race can by any means compare with them.\n\nO monarch, this youthful union of Rāma and Lakṣmaṇa with Sītā and Urmilā is fit by all means; and it is worthy of their wealth of grace.\n\nNow do you, O foremost of men, listen to my words. This youthful brother of yours, king Kuśadhvaja , O you versed in morality, this pious-souled one, O king, has, O prime of men, a couple of daughters, unparalleled on earth in beauty, whom we would ask for, to become wives to the prince Bharata and the intelligent Śatrughna ; as we, O king, ask for your own daughters in the interests of those high-souled ones (Rāma and Lakṣmaṇa).\n\nAnd these sons of Daśaratha are endued with youth and beauty, resembling the Lokapalas , and possessed of the prowess of celestials.\n\nTherefore do you, O foremost of sovereigns, by this alliance with both the brothers, bind the Ikṣvāku race. And in this may your mind never waver!\n\nHearing Viśvāmitra’s words embodying the sentiments of Vasiṣṭha, Janaka with clasped hands addressed both the potent ascetics, saying,\n\n‘I consider my line as blessed; since such puissant ascetics wish for such a desirable alliance.\n\nWhatever you wish, even that shall be done, good betide you. Let these daughters of Kuśadhvaja together become the wives of Śatrughna and Bharata.\n\nOn the same day, O mighty Muni , let the four highly powerful princes espouse the hands of the four princesses.\n\nThe learned consider bridal celebrated on the day succeeding those on which the Phalgunis are on the ascendant, and having for its presiding deity Bhagas —the most auspicious.’\n\nHaving said these amiable words, king Janaka arose, and with clasped hands addressed both the foremost of ascetics, saying.\n\nI have reaped high religious merit (by these nuptials), and I also am your disciple. And do you, you anchorets, occupy these best of thrones, (belonging to us).\n\nAnd even as this kingdom is to Daśaratha is Ayodhyā to myself. Do you not therefore entertain any doubts as to your lordship. Do you therefore do as it behove you.\n\nAnd as Vaideha Janaka was speaking thus, Raghu ’s son, king Daśaratha, well pleased answered that monarch, saying,\n\nCountless are the excellences that pertain to you brothers, lords of Mithilā ; and saints and sovereigns are ever honoured by you, [1] auspiciousness be yours.\n\nGood betide you, I will repair to my own quarters, there to duly perform the Śrāddha ceremonies.\n\nThen having greeted that king of men, the illustrious Daśaratha, placing those foremost of ascetics in his front, went away.\n\nAnd reaching his quarters, the king performed the Śrāddha according to the ordinance, arose the next morning, and made excellent gifts of kine.\n\nAnd to Brāhmaṇas the monarch severally gave away kine by hundreds and by thousands, for the welfare of his sons.\n\nAnd that puissant one gave away to the regenerate ones four hundred thousands of kine furnished with horns plaited with gold, and each having her calf, together with bell-Mattel vessels for milking them.\n\nAnd that descendant of Raghu addicted to his sons made presents of various other valuables and the Brāhmaṇas, on behalf of his sons. And having given away kine, the surrounded by his sons looked like to the amiable Prajāpati surrounded by the Lokapālas .\n\n[back to top]\n\n[1] :\n\nThe commentator here seems to be in fault. He explains,—By you have your royal ancestors been honoured. Evidently an error. I differ from him. The particle ca (and) makes the point clear.
73	1	73	Chapter LXXIII	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365941.html	And it came to pass that the day on which the king made excellent presents of kine, the heroic Yudhājit , son to the lord of the Kekayas and maternal uncle to Bharata , presented himself before Daśaratha . And having seen the king and enquired after his welfare, he said to him.\n\nThe lord of the Kekayas has from affection enquired after your welfare, sayiing,—‘They of whose peace you are anxious, are at present well.’ And, O foremost of kings, desirous of seeing (Bharata) together with his wife, that lord of earth repaired to Ayodhyā .\n\nO descendant of Raghu . And learning at Ayodhyā that your sons for the purpose of marriage had, O monarch, come to Mithilā with yourself, I have speedily hide hither, with the intention of seeing my sister’s son.\n\nThen king Daśaratha, on having that dear guest with him, rendered to him all the respect that he deserved.\n\nThen having passed the night in company with his high-souled sons, that one versed in men and things arose in the morning, and having disposed of his daily duties, approached the entrance of the sacrificial ground, headed by the saints.\n\nThen at an auspicious moment called Vijaya ; Rāma with Vasiṣṭha as well as other Maharṣis at his head, and accompanied by his brothers adorned with various ornaments, who had all performed the rites relative to their nuptials, (approached the entrance of the sacrificial ground). Then the worshipful Vasiṣṭha, coming to Vaideha , spoke as follows.\n\nKing Daśaratha, O foremost of sovereigns, that chief among the best of men—accompanied with his son, who have performed all the rites relative to their nuptials, stay the orders of the bestower (of the bride); for the meeting of the giver and the receiver is indispensable to every transaction (of this nature). Do you therefore maintain your merit by accomplishing this excellent nuptial ceremony.\n\nThus addressed by the high-souled Vasiṣṭha, that exceedingly generous and energetic one versed in morality answered, saying,\n\nWho act as my warder there? And whose commands does he stay? And what need of exercising judgement in such a matter? As this kingdom is mine, so it is verily your. O foremost of anchorets, my daughters resembling flames of fire, having performed all the rites relative to the incoming nuptials, are at the foot of the dais; and, sitting beside the dais.\n\nI myself had been expecting you every moment. Do you perform everything without let. What need of delaying further?\n\nHearing those words uttered by Janaka , Daśaratha entered in together with his sons and the body of saints.\n\nThen to the king of the Videhas , Vasiṣṭha spoke as follows,—O saint, do you, O pious one, in company with the saints, perform, O master, the nuptial ceremonies of Rāma charming to all.\n\nThereupon, saying, So be it to Janaka, the worshipful saint Vasiṣṭha of mighty austerities with Viśvāmitra and the pious Śatānanda in his front, constracted a dais agreeably to the scriptures, decking it out with fragrant flowers all around, and golden ladles, and variegated water-pots, and platters with ears of barley, and censers filled with Dhūpa , and conchs, and sacrificial spoons, and vessels furnished with Arghyas , and those containing fried paddy, and sanctified Akṣatas . And over the dais, Vasiṣṭha with due mantras and rites spread an awning consisting of Darbhas of equal proportions. And with prescribed rites and mantras placing fire upon the dais, the highly energetic one commenced upon offering oblations.\n\nThen bringing Sītā adorned with various ornaments near the fire, and placing her before Rāghava , king Janaka addressed the enchancer of Kausalyā ’s joy, saying,—This Sītā, my daughter, to you accept, good betide you, as your partner in the observance of every duty: do you take her hand by yours. May she be of excited piety, and devoted to her husband; ever following you like your shadow!\n\nSaying this, the king sprinkled Rāma’s palm with water sanctified with mantras; with the celestials and saints exclaiming, Excellent! Excellent!\n\nAnd the celestial kettle-drums sounded, and blossoms began to shower down copiously. Having thus given away his daughter Sītā, with water and mantras , king Janaka, overflowing with delight, said, Come forward, O Lakṣmaṇa , good to you. Receive you Urmilā ready to be bestowed by me upon you. Do you accept her hand: let there be no delay about it.\n\nHaving addressed Lakṣmaṇa thus, Janaka spoke to Bharata, saying, Do you, O descendant of Raghu, take Māṇḍavya ’s hand by yours own.\n\nThe righteous lord of Mithilā spoke also to Śatrughna , saying, Do you, O you of mighty arms, take Śrutakīrti ’s hand by your own. May you all be good, and vowed to excellent life! And be, you Kākutsthas , you united with your wives. Let there be no delay about it.\n\nHearing Janaka’s speech, those four perpetuators of Raghus ’s line, staying by Vasiṣṭha’s opinions, taking the hands of the four brides with their own, went round the sacrificial fire, and the dais, and the king, and the high-souled saints; and in company with their wives, agreeably to direction entered into matrimony in accordance with the ordinance.\n\nThere was a mighty shower of shining blossoms from the firmament accompanied with the sounds of celestial kettle-drums, and choiring and instrumental music. And the Apsaras , danced and the Gandharvas sang melodiously, at the bridal of the foremost of the Raghus. And this seemed wonderful to witness.\n\nTo the blowing of trumpets, those exceedingly puissant ones, thrice going round the fire, in company with their wives went to the encampment.\n\nThe king, having seen that all the auspicious ceremonies were performed, went in their wake accompanied by the sages and his adherents.
74	1	74	Chapter LXXIV	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365942.html	Then when the right had passed away, the mighty Muni Viśvāmitra , having greeted the monarchs, yet out for the Northern mountains.\n\nWhen Viśvāmitra had gone away, king Daśaratha , greeting Mithilā ’s lord, Vaideha , actively prepared for setting out for his own capital.\n\nThen the king of the Viḍehas gave a dower consisting of various things. And Mithilā’s lord gave many hundred thousands of kine, and excellent woollen stuffs, and Koṭis of common cloths; and elephants, and horses, and cars, and footmen, as well as an hundred damsels adorned, endowed with elegance to form goodly waiting-maids. And well-pleased the king gave as a noble dower gold and silver and pearls and coral.\n\nHaving given divers kinds of articles, that king, the lord of Mithilā, bidding adieu to the monarch (Daśaratha), re-entered his own capital. And the master of Ayodhyā accompanied with his high-souled sons, and headed by the saints in a body, started on the journey, followed by his own army.\n\nAs that tiger-like one was on his way, in company with Rāghava and the saints, the fowls began to utter frightful cries all around, and the beasts on earth to stream in a Southern direction.\n\nBeholding them, that tiger-like monarch asked Vasiṣṭha , saying, Those birds of fierce aspects emit frightful cries and beasts stream in a Southerly direction. What is this? My heart tremble and my mind is not at ease.\n\nHearing the speech of king Daśaratha, that mighty saint spoke sweetly, saying, 'These fowls of the air by their cries presage some dreadful impending evil; but these beasts betoken peace restored. Therefore do you renounce anxiety’\n\nAs they were thus conversing, there blew a strong wind; and all the earth began to speak; and the trees to topple down. And a deep gloom enveloped the sun; and no quarter could be discovered. And enveloped in ashes, that host became stupefied.\n\nAt that dreadful hour, Vasiṣṭha and the other saints and the king alone retained their senses, all else were deprived of their senses, and the army was enveloped with ashes.\n\nThe king saw that repressor of kings, the descendant of Bhṛgu , Jamadagni ’s son, dreadful to behold, wearing a head of matted locks, like to the Kailāsa , had to baffle, resembling the fire at the universal dissolution, difficult to bear, flaming in energy, incapable of being looked at by the unrighteous, with his axe on his shoulder, equipped with a bow like to the lighting, and fierce arrows, looking like Śiva the slayer of Tripura .\n\nBeholding him of dreadful appearance like to flaming fire, the Vipras headed by Viśvāmitra, engaged in reciting mantras and offering oblations to the fire, those saints assembled together, began to converse with each other.\n\nIs this one, enraged because of the slaughter of this sire, intent upon exterminating the Kṣatriyas ? Formerly, having slaughtered the Kṣatriyas, he pacified his ire and mental ferment, therefore, the annihilate the Kṣatriya once again can never be his endeavour.\n\nHaving said this, the saints offered Arghya to Bhṛgu’s son of dreadful appearance; and addressed him in soothing words, saying, ‘O Rāma ! O Rāma’.\n\nAccepting that homage rendered to him by the saints, that puissant one, Jamadagni’s son, Rāma, addressed Rāma, the son of Daśaratha.
75	1	75	Chapter LXXV	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365943.html	“ Rāma , son of Daśaratha , I have, O hero, heard of your wonderful prowess; and I have also heard all about your breaking of the bow.\n\nHaving heard of that wonderful and inconceivable breaking of the bow, I have bent my steps hither. Do you take another auspicious bow, Do you stretch it, fix the arrow upon this mighty and dreadful bow, belonging to Jamadagni ; and thus display your prowess.\n\nThen, having witnessed your might in stretching the bow, I shall offer you combat, laying under contribution our utmost strength.”\n\nHearing his words, king Daśaratha with a blank countenance, and clasped hands, said,\n\nYou have quenched your ire against the Kṣatriyas ; and, moreover, you are a Brāhmaṇa boasting of high austerities. It therefore behove you to dispel the fears of my sons who are boys. You bring your life from the race of the Bhārgavas engaged in observing vows, and studying you Veda ; and you have renounced arms vowing in the presence of the thousandeyed one.\n\nEmbracing a life of righteousness, you did confer the earth upon Kaśyapa and repaired to the forest, making the Mahendra hill your home.\n\nO mighty Muni , you have come here to compass the destruction of my all; but if Rāma be slain, we shall never live.\n\nThus addressed by Daśaratha, the powerful son of Jamadagni, disregarding his words, thus addressed Rāma,\n\nThese two foremost of bows, extraordinary, and worshipped of all the worlds, and stout, and powerful, surpassingly excellent, were constructed with care by Viśvakarman .\n\nOne of these, O foremost of men, for the destruction of Tripura , the celestials gave to Tryambaka , desirous of encounter, even that which, O Kākutstha , which you have snapped.\n\nThis second, which is irrepressible, was given to Viṣṇu , by the chiefs of the celestials. And, O Rāma, this bow belonging to Viṣṇu, capable of conquering hostile cities, is,\n\nO Kākutstha, equal in energy to the bow belonging to Rudra . Once on a time the deities, with the object of ascertaining the respective prowess of Viṣṇu and the blue-throated one, asked the great-father, foremost of those abiding by truth, reading the intention of the deities, fomented a quarrel between them.\n\nUpon that quarrel breaking out among the deities, there took place a mighty contest capable of making one’s hair stand on end, between Viṣṇu and the blue-throated one, each burning to beat the other down.\n\nThen on Viṣṇu uttering a roar, Śiva ’s bow of dreadful prowess became flaccid. And thereupon the three-eyed Mahaḍeva became moveless.\n\nUpon the assembled gods with the saints and the Cāraṇas beseeching those two foremost of celestials, they became pacified.\n\nUpon beholding that bow of Śiva rendered flaccid by Viṣṇu’s prowess, the deities with the saints acknowledged Viṣṇu as the more powerful.\n\nThe enraged Rudra of high fame made over the bow along with its shafts to the hands of the Rājarṣi , Devarāta of Videha .\n\nO Rāma, this bow belonging to Viṣṇu, capable of conquering hostile cities, Viṣṇu consigned to Bhṛgus ’ son, Ṛcīka , as a worthy trust.\n\nThe exceedingly energetic Ṛcīka made over the divine bow to his son of immeasurable prowess, my sire the high-souled son of Jamadagni.\n\nOnce on a time, on my sire surcharged with ascetic energy, renouncing the bow, Arjuna , under the influence of unrighteous sentiment, compassed the death of my father.\n\nThereupon, learning of the lamentable and untoward slaughter of my sire, I from ire, annihilated the Kṣatryas, springing up afresh by numbers, then bringing under sway the whole earth, I, O Rāma, on the sacrifice being over, conferred it upon the righteous Kaśyapa as Dakṣiṇā .\n\nHaving made this gift, I was dwelling in the Mahendra hill equipped with ascetic energy, when, hearing of your snapping of the bow, I have speedily come hither.\n\nDo you now, O Rāma, agreeably to the cannon of the Kṣatriya morality, take this excellent and mighty bow of Viṣṇu, that had belonged to my father and grand father. And do you set upon this best of bows an arrow capable of conquering hostile cities. And, O Kākutstha, if you succeed, I shall then offer you combat.
76	1	76	Chapter LXXVI	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365944.html	Hearing Jamadagni ’s, words, the son of Daśaratha , in consideration of the presence of his father, said these words in subdued tone,\n\nO Bhṛgu ’s son, I have heard of the deeds you have performed, resolved on avenging your sire. O Brāhmaṇa , I acknowledge that.\n\nBut, O Bhargava , you insulted me abiding by the Kṣatriya duties, as pusillanimous or devoid of prowess. Do you to-day witness my energy and vigour.\n\nSaying this, the enraged Rāghava , endowed with fleet vigour, took up Bhṛgu’s noble bow, together with the shaft.\n\nAnd fixing the string upon it he set the arrow. And then Rāma enraged addressed Jamadagni’s son, Rāma, saying,\n\nYou are a Brāhmaṇa and through Viśvāmitra , art worthy of my homage. Therefore it is, O Rāma, that I can not let go this life-destroying shaft.\n\nWhich of these shall I reduce to aught, O Rāma, Your aerial course, or the merit you have attained through your asceticism of ascending to certain incomparable regions. This wonderful arrow of ours sprung from Viṣṇu , capable of conquering hostile towns, never hit fruitless, with energy destroying the pride of prowess of foes.\n\nAnd with the object of beholding Rāma holding that foremost of weapons, there assembled in a body the celestials and the saints, with the great-father at their head.\n\nThe Gandharvas and the Apsara and the Siddhas and the Cāraṇas and the Kinnaras and the Yakṣas and the Rākṣasas and the Nagas assembled to behold that mighty wonder.\n\nAnd on Bhārgava ’s energy having been observed by Rāma bearing that best of hows, Jamadagni’s son became bereft of prowess, and Rāma ( Paraśurāma ) kept steadily eyeing Rāma.\n\nAnd rendered inert in consequence of his energy having been dispelled by Rāma’s own, Jamadagna mildly addressed Rāma of eyes like lotus’ petals, saying,\n\nWhen formerly I gave away the earth to Kaśyapas , he said to me, You must no longer stay in my dominions.\n\nIn consonance with the words of my spiritual guide, ever since that time I have never spent three nights together on earth. Even this had been promised by me, O Kākutstha .\n\nTherefore, O hero, it behove you not to destroy my course, O descendant of Raghu . With the speed of the mind shall I now wend my way to the Mahendra , best of hills.\n\nO Rāma, the regions I have conquered by my asceticism do you destroy with that foremost of arrows: let there be no delay about it.\n\nEven from your handing of this bow I know you to be the chief of the celestials even that eternal one, the slayer of Madhu . Hail to you,\n\nO vanquisher of foes! And all these celestials assembled are beholding you of unparalleled deeds, and without an antagonist in fight.\n\nAnd, O Kākutstha, neither ought I to be ashamed (because of this discomfiture); I have been baffled by the lord himself of the three worlds.\n\nAnd it behove, O Rāma to disengage this peerless shaft (from the bow), O you of noble vows; and on your shooting the shaft. I shall repair to that fore most of mountains, the Mahendra.\n\nWhen Jamadagni’s son, Rāma, had said this, the puissant and graceful son of Daśaratha, had said this, the puissant and graceful son of Daśaratha shot that excellent arrow.\n\nAnd witnessing the destruction by Rāma of his regions earned by his own austerities, Jamadagni’s son speedily started for that best of mountains, the Mahendra.\n\nThen all the quarters became cleared of gloom; and the celestials and saints fell to extol Rāma when he had shot the arrow.\n\nAnd that lord, Jamadagni’s son Rāma, having gone round Rāma, the son of Daśaratha, and honoured (by all), set out (for his own quarters).
77	1	77	Chapter LXXVII	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365945.html	When Rāma had departed, Daśaratha ’s son the illustrious Rāma, of serene soul, made over the bow to the hands of Vanina of immeasurable strength.\n\nThen saluting the saints headed by Vasiṣṭha , Rāma, the descendant of Raghu , seeing his son stupefied, addressed him, saying,\n\nNow that Jamadagni ’s son has gone away, let the fourfold forces maintained by you as their lord, march in the direction of Ayodhyā .\n\nHearing Rāma’s words, king Daśaratha embraced his son with his arms, and smelt Rāghava ’s crown; and hearing that Rāma had gone, the monarch became exceedingly delighted, and considered himself and his son as having attained a second birth.\n\nHe urged on his army, and speedily arrived at the city, graced round with standards bearing pennons, and lovely to behold, and resounding with the sounds of trumpets, with its high-ways watered, and beauteous, and sprinkled around with flowers, crowded with citizens looking cheerful on account of the king’s approach, bearing auspicious articles in their hands, and beautified with the vast concourse of people. And received by the citizens as well as the regenerate ones inhabiting the city coming forward a long way, and followed by his graceful son, the handsome Majesty of illustrious name entered his own dear residence, like to the Himavat .\n\nAnd entertained by his own relatives with all objects of enjoyment, the monarch rejoiced exceedingly. And Kausalyā and Sumitrā and the slender waisted Kaikeyī , together with other wives of the king, were busy, receiving the brides, with the necessary ceremonies.\n\nAnd the royal spouses received the exalted Sītā and the famous Urmilā and both the daughters of Kuśadhvaya, graced with silken apparel, with homas performed and blessings invoked, on their behalf. And having paid reverence at the abodes of the gods, and rendered homage to those that deserved the same, the daughters of the kings, well pleased, in private, took joy with all the brothers.\n\nAnd having attained brides, and arms, with wealth and friends, those foremost of men, engaged in ministering to their father.\n\nAnd once on a time that descendant of Raghu, king Daśaratha addressed Bharata , saying,\n\nO son, this son of the king of the Kekayas your uncle, Yudhājit stay here, that hero, having come to take you over.\n\nHearing these words of Daśaratha, Kaikeyī’s son, Bharata; prepared for the journey, together with Śatrughna .\n\nHaving greeted his father, and Rāma of unflagging energy, and his mother, that foremost of men, the heroic (Bharata) departed with Śatrughna.\n\nAnd having Bharata as well as Śatrughna, the heroic Yudhājit, with a delighted heart, entered his own city; and his father rejoiced exceedingly.\n\nAnd on Bharata having departed Rāma and the exceedingly mighty Lakṣmaṇa , tended their sire resembling a celestial.\n\nAnd paying the utmost regard to the command of his father, Rāma discharged all the duties of the city, having for his object the pleasure or welfare (of the citizens).\n\nAnd heedfully rendering every service to his mothers, he on proper occasions observed the duties pertaining to his superiors.\n\nDaśaratha was exceedingly delighted; as also the Brāhmaṇas , and the traders, and the inhabitants generally, at the conduct and behaviour of Rāma.\n\nRāma having truth for prowess, by virtue of his excellence appeared to everyone the most meritorious of (Daśaratha’s son) like to the self create Himself to all being.\n\nIn the company of Sītā, the wise Rāma, bending his mind to Sītā, with his heart dedicated to her, passed many a season in delight.\n\nRāma’s beloved Sītā, as having been bestowed upon him by his sire, by her loveliness, and her perfections as much as by her loveliness, went on enhancing his joy. And her lord came to exercise a double influence on her heart.\n\nAnd by her own heart, the daughter of Janaka , Mithilā ’s lord, resembling a goddess in grace, and like to Śrī (goddess of wealth) herself in loveliness, completely read his inmost sentiments.\n\nAnd experiencing delight, Rāma, receiving the Rājarṣi ’s daughter, exercising her own will—the excellent princess—looked graceful, even like the lord Viṣṇu the chief of celestials on being joined with Śrī.\n\nEND OF THE BĀLAKĀṆḌA
64	1	64	Chapter LXIV	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365932.html	O Rambhā , this mighty service you will have to perform in the interest of the celestials, even to lake Kauśika with the witchery of love.’\n\nThus addressed by the intelligent thousand-eyed deity, the Apsarā , O Rāma , with clasped palms, thus bashfully answered the chief of the celestials,\n\nO lord of the celestials, this mighty ascetic, Viśvāmitra , is a terrible person; and, without doubt, he will, O divine one, waxing wroth, curse me.\n\nAnd O god, even this is my fear, and therefore it behove you to favour me. Thus apprehensively addressed by her in fear, the thousand-eyed one answered that damsel trembling and staying with clasped hands, ‘Never fear, O Rambhā, good to you! Do you perform my bidding;\n\nAssuming the form of a Cole, captivating the heart, I will in this spring crowned with graceful trees, stay by your side in company with Kandarpa .\n\nDo you adding to your beauty, diverse blandishments bewitch this ascetic, Kuśika ’s son, O gentle one?’\n\nHearing Indra ’s words, that comely damsel of luminous smiles, heightening her charms exceedingly inspired Viśvāmitra with desire,\n\nHe listened to the mellifluous strains of the Cole; and with a delighted heart, he beheld the fair one.\n\nAnon, listening to the warbling of the Cole and her own incomparable singing, as well as beholding Rambhā, the ascetic began to entertain doubts.\n\nAnd knowing for certain that it was the thousand-eyed deity who had devised all that, that foremost of anchorets, Kuśika’s son, overwhelmed with anger, cursed Rambhā, saying,\n\nSince, O Rambhā, you endeavour to seduce me who is bent upon subduing his anger and lust, you shall, O luckless one, remain as a stone for ten thousand years.\n\nAnd a highly energetic Brāhmaṇa equipped with ascetic energy, will, O Rambhā, deliver you, stained because of my ire.’\n\nThus said that exceedingly energetic and mighty ascetic Viśvāmitra, unable to contain his anger and indignation of heart.\n\nAnd in consequence of his mighty curse, Rambhā was turned into a stone. Hearing the curse of the mighty saint, both Kandarpa and Indra left the place.\n\nO Rāma, on account of his anger, and his sense remaining still unsubdued he found no rest from deterioration of ascetic merit. And coming by decrease of ascetic merit, he thought within himself, ‘No more shall I suffer anger to exercise me,—nor will I ever say anything to any.’\n\nAnd I shall not breathe for an hundred years; and controlling my sense, I shall dry up my body.\n\nAnd so long as I do not attain Brāhmaṇa-hood as earned by my austerities, I shall suspending my breath and abstaining from food, stay for a long lapse of time.\n\nAnd engaged in austerities, my form will not undergo any deterioration. That foremost of ascetics bound himself by this unparalleled vow to lead a life of such self-denial.
68	1	68	Chapter LXVIII	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365936.html	Thus commissioned by Janaka , the envoys, having spent three nights on the way, entered the city of Ayodhyā , with their conveyances afflicted with fatigue.\n\nIn accordance with the royal commission, entering the king’s residence, they saw the aged king Daśaratha , resembling a celestial.\n\nFreed from apprehension the envoys with clasped hands addressed the monarch in sweetly humble accents, saying, O mighty monarch, Mithilā ’s lord, king Janaka, in company with this priests, in sweet and affectionate words, repeatedly enquires after the complete welfare of thyself along with your priests and servants.\n\nAfter having enquired after your complete welfare, Mithilā's lord, Vaideha , by permission of Kauśika , addresses you thus,\n\nYou know the vow I had made formerly—viz., to confer my daughter upon him that would bend the bow,—and the kings, in consequence of their having been deprived of prowess, and being baffled, have come to entertain spite against me.\n\nAnd that daughter of mine, O king, has been won by your son, arrived one, that divine, jewelled bow has been snapped in the middle by the high-souled Rāma in the midst of a large assembly.\n\nUpon that high-souled one should I confer Sītā , having prowess assigned for her dower. And in this wise will I free myself from my vow; and this you should permit.\n\nO mighty king, do you, good betide you, come speedily headed by your priests. It behove you to see the Rāghavas ;\n\nAnd, O foremost of kings, to see me delivered from this vow. And do you attain the joy incident to the nuptials of both your sons,\n\nThus spoke sweetly the lord of Viḍeha, permitted by Viśvāmitra and staying by the opinions of Śatānanda .’\n\nHearing the words of the envoys, the king, exceedingly rejoiced, addressed Vasiṣṭha and Vāmadeva , as well as his counsellors, saying,\n\nProtected by Kuśika ’s son, that exhancer of Kausalyā ’s joy stay in Videha in company with his brother, Lakṣmaṇa .\n\nAnd the high-souled Janaka has witnessed the prowess of Kākutstha ; and he wish to bestow his daughter upon Rāghava .\n\nIf this alliance with the high-souled Janaka is relished by you, we shall speedily repair to his capital. Let there be no waste of time.\n\nThereupon, the counsellors along with the Maharṣis said, Excellent! And the king highly delighted, said to the counsellors, Our journey commence on the morrow.\n\nAnd excellently ministered to, the counsellors of that foremost of monarchs (Janaka), endowed with every excellent quality, spent that night in joy.
69	1	69	Chapter LXIX	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365937.html	Then when the night had been spent, king Daśaratha accompanied with his priests and adherents, well pleased spoke to Sumantra , saying,\n\nTo-day let the officers in charge of the treasury, taking plenty of excellent wealth, and furnished with various gems, go in advance under proper escort.\n\nAnd let the fore-fold forces sally out with speed. And at my command let horses and conveyances and elegant vehicles march out\n\nAnd let Vasiṣṭha and Vāmadeva and Jābāli and Kaśyapa and Mārkaṇḍeya endowed with long life and the saint Katyāyana—let these regenerate ones go forward. And do you also yoke my car. Let not the proper time pass away; for the envoys urge speed upon me.\n\nAt these words of the king, the four-fold forces together with the saints went in the wake of the monarch.\n\nAfter having passed four days on the way, they arrived at Videha . And bearing of Daśaratha’s arrival; the auspicious king Janaka experienced great delight, and having obtained the aged king Daśaratha, he honoured him duly. w to M ^iPewH,i wra % t^gṇr to i ft 11\n\nThat chief of men well pleased, spoke these words, Have your journey been a pleasant one, O best of men? By luck have I obtained you, O descendant of Raghu .\n\nDo you experience the joy earned by the prowess of your sons. And by luck it is that I have obtained the highly energetic and worshipful saint Vasiṣṭha accompanied by the foremost regenerate ones, like him of an hundred sacrifices, by the celestials.\n\nBy luck it is that I have overcome the obstacle; by luck it is that my race has attained renown, in consequence of alliance with those endowed with prowess, the exceedingly potent Rāghavas .\n\nO lord of men, to-morrow morning after the completion of the sacrifice, do you perform the nuptials, in company with the foremost of the saints.\n\nHearing his speech in the midst of the saints, that best of those conversant with words, the lord of men, replied to the monarch, saying,\n\nA gift should be accepted, this I heard formerly. And what you say, O you cognizant of duty, will we accomplish.\n\nHearing these words of the truthful (king), chiming in with morality and conducive to fame, the lord of Videha was filled with admiration.\n\nThen the ascetics experiencing great delight, passed the night in each other’s company.\n\nAnd the king, overjoyed on beholding his sons, the Rāghavas passed (the night) in exceeding delight, splendidly entertained of Janaka.\n\nAnd the exceedingly energetic Janaka also, versed in men and things, having in accordance with the ordinance completed the sacrifice and performed all the preliminary rites relative to the nuptials of his daughters, reposed for the night.
12	1	12	Chapter XII	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365880.html	Then after a long while, when the charming spring had appeared on the earth, the king conceived the desire of celebrating the sacrifice.\n\nThen bowing down the head before the Vipra effulgent like a celestial, he appointed him to undertake the ceremony, for the purpose of obtaining offspring to perpetuate his line.\n\nThen that Brāhmaṇa said to the lord of the earth, the king, So be it! Get order the necessary provisions procured, free the horse set, and prepare a sacrificial ground on the north bank of the Sarayū .\n\nThen the king spoke to Sumantra , saying, O Sumantra, do you summon speedily Brāhmaṇas versed in the Vedas and priests professing the Vedānta philosophy, Suyajña , and Vāmadeva , and Jābāli , and Kaśyapa , and the priest Vasiṣṭha , together with other excellent twice-born ones.\n\nThereupon Sumantra endowed with activity, bestirring himself, summoned all those versed in the Vedas.\n\nThen, honouring them duly, the virthous king Daśaratha spoke to them these amiable words, consistent with duty and interest.\n\nAggrieved on account of a son, I have no happiness on earth, and, therefore, I have intended to celebrate a horse-sacrifice.\n\nSo, I would like to perform a horse-sacrifice. And by the grace of the saint’s son, I shall obtain my desire.\n\nThereupon, the Brāhmaṇas with Vasiṣṭha at their head honoured the words that fell from the king’s lips, saying, Well!\n\nThe Brāhmaṇas headed by Ṛṣyaśṛṅga addressed the king, saying, Do you arrange for the provisions, loose the horse, and prepare the sacrificial ground on the north bank of the Sarayū river!\n\nSince you purpose so virtuously for obtaining offspring, you shall obtain four sons of immeasurable prowess.\n\nHearing those words of the regenerate ones, the king was exceedingly delighted. And cheerfully he spoke these auspicious words to his courtiers.\n\nIn accordance with the directions of my spiritual guides, do you speedily procure these provisions, loose the horse well protected, and followed by a priest.\n\nAnd prepare the sacrificial ground on the north bank of the Sarayū. And perform the ceremonies capable of securing the rites from disturbance.\n\nSurely every king is competent to perform this sacrifice yet care must be taken that no default occurs in it.\n\nFor flaws in this foremost of sacrifices are watched by learned Brahma-Rākṣasas . And should it come to be celebrated in violation of the ordinance, the performer thereof shall meet with instant destruction.\n\nAnd do you so order that this sacrifice of mine may be completed according to the prescribed ritual.\n\nThereupon honouring those words of the king, the ministers did as ordered.\n\nAnd having eulogised the king knowing duty, the twice-born ones, with the Monarch’s leave, departed for their respective quarters.\n\nWhen the Vipras had gone, the mighty-minded lord of men dismissing his counsellors, entered his place.
56	1	56	Chapter LVI	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365924.html	Thus addressed by Vasiṣṭha , the mighty Viśvāmitra , aiming a fiery weapon, said, ‘Stay! Stay!’\n\nThe worshipful Vasiṣṭha also on his part, raising a Brahmā staff resembling another staff of Kāla , exclaimed in wrath.\n\nWretch of a Kṣatriya ! here am I, do you display the might you are master of. To-day, O Gādhi ’s son, will I humble your pride of arms.\n\nYou disgrace of the race, where is your Kṣatriya might, and where my high Brahmā energy? Do you behold my superhuman Brahmā energy.\n\nAnd even as water ally the fierceness of a flame, the Brahmā staff quenched the energy of the powerful fiery weapon discharged by Gādhi’s Son.\n\nThen Gādhi’s son, waxing wroth, discharged Vāruṇa and Raudra and Aindra and Pāśupata and Aiṣika weapons.\n\nMānava , and Mohana , and Gandharva , and Svapna , and Jṛmbhaṇa , and Mohana, and Santāpana , and Vilāpana , and Śoṣaṇa , and Dāruṇa , and Vajra hard to baffle, and Brahmapāśa, and Kālapāśa, and Varuṇapāśa, and Pināka (favourite of Śiva ), and the two Aśanis , wet and dry, and the Daṇḍa weapon, and Paiśāca , and the Krauñca weapon, and Dharmacakra , and Kālacakra , and Viṣṇucakra , and Vāyavya , and Mohana, and the Hayaśiras weapon, and the mighty weapon Vidyādhara , and the terrible Kala weapon, and the dreadful Triśūla weapon, and Kapāla , and Kaṅkaṇa , all these weapons hurled he (Viśvāmitra), at that best of mantra -reciting ones, O descendant of Raghu . And it was wonderful to behold. But Brahma ’s son baffled all those by means of his staff.\n\nAnd on those (weapons) being resisted, the son of Gadhi hurled a Brahmā weapon. And on that weapon being discharged the deities with Agni at their head, and the Devarṣis , and the Gandharvas , and the mighty Serpents, became afflicted with fear. And on that Brahmā weapon being discharged, all the three worlds became exceedingly alarmed.\n\nO Raghu’s descendant, Vasiṣṭha by virtue of his Brahmā energy completely baffled that terrible Brahmā weapon.\n\nWhen the high-souled Vasiṣṭha had baffled the Brahmā weapon, his form the three worlds.\n\nAnd from the pores of his body, resembling a smoking flame, darted out scintillation’s of fire.\n\nAnd resembling another staff of Yama , the Brahmā staff raised by Vasiṣṭha’s arm flamed like to the fire at the universal dissolution.\n\nThen the ascetics in a body fell to eulogizing that best of mantra-reciting ones, Vasiṣṭha, saying, ‘Your might, O Brāhmaṇa , is infallible. Do you rein in the (Brahmā) energy, by your own.’\n\nO Brāhmaṇa, Viśvāmitra of mighty strength has been subdued by you. Infallible is your extraordinary mighty. Let the creatures now be relieved from their distress.’\n\nThus addressed, that highly energetic one of rigid austerities, became pacified.\n\nAnd Viśvāmitra, being put down, heaving a sigh said, ‘Fie upon the Kṣatriya might: the strength begot of Brahma energy, is might indeed. By one Brahmā staff has all my weapons been put to the rout.\n\nBeholding this, I with a. placid mind and senses will engage in mighty austerities, which shall earn for me Brāhmaṇa-hood.
\.


--
-- Data for Name: character_aliases; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.character_aliases (id, character_id, alias) FROM stdin;
1	1	Rāma
2	1	Rama
3	1	Raghava
4	1	Rāghava
5	1	Kākutstha
6	1	Kakutstha
7	2	Sītā
8	2	Sita
9	2	Vaidehī
10	2	Vaidehi
11	2	Janakātmajā
12	3	Lakṣmaṇa
13	3	Lakshmana
14	3	Saumitri
15	3	Saumitra
16	4	Dasaratha
17	4	Daśaratha
18	5	Valmiki
19	5	Vālmīki
20	6	Narada
21	6	Nārada
22	7	Bharata
23	8	Śatrughna
24	9	Kausalyā
25	10	Kaikeyī
26	11	Sumitrā
27	12	Janaka
28	13	Viśvāmitra
29	14	Bharadvāja
30	15	Ikṣvāku
31	16	Ṛṣyaśṛṅga
32	17	Romapāda
33	18	Vibhāṇḍaka
34	19	Śāntā
35	20	Indra
36	21	Kaśyapa
37	16	Rsyasringa
38	16	Rishyasringa
39	17	Romapada
40	18	Vibhandaka
41	19	Shanta
43	21	Kashyapa
\.


--
-- Data for Name: character_events; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.character_events (id, character_id, chapter_id, event_title, event_summary, paragraph_start, paragraph_end, importance) FROM stdin;
1	1	1	Rāma is introduced	Rāma is introduced as a powerful and virtuous prince of the Ikṣvāku lineage, possessing patience, self-control and other exceptional qualities.	7	9	5
2	1	1	Rāma is exiled	King Daśaratha, bound by his promise to Kaikeyī, banishes Rāma. Rāma accepts his father’s command and leaves for the forest.	21	23	5
3	1	1	Rāma enters the forest	In obedience to his father’s command and to fulfill the promise made to Kaikeyī, Rāma leaves Ayodhyā and enters the forest.	23	27	5
5	2	1	Sītā accompanies Rāma into exile	Sītā follows Rāma when he leaves Ayodhyā for the forest and becomes his companion during his exile.	24	28	5
6	2	1	Sītā is found in Laṅkā	Hanumān reaches Laṅkā and discovers Sītā in the Aśoka garden while searching for her.	57	60	5
7	2	1	Sītā is recovered	Rāma reaches Laṅkā, defeats Rāvaṇa and recovers Sītā.	65	67	5
8	2	1	Sītā undergoes the fire ordeal	After Rāma speaks to Sītā before all, Sītā enters the flaming fire and is subsequently affirmed to be sinless.	67	69	5
9	2	66	Sītā is found by Janaka	Janaka describes discovering Sītā while ploughing the field and accepting her as his daughter after she arose from the earth.	11	12	5
10	2	73	Sītā marries Rāma	Janaka brings Sītā before Rāma and gives her to him as his partner in the observance of their duties.	14	16	5
11	2	77	Sītā arrives in Ayodhyā	Sītā and the other brides are received by the royal household after arriving in Ayodhyā.	5	7	5
12	2	77	Sītā begins married life with Rāma	Sītā and Rāma live together in happiness during their early married life.	19	22	4
13	3	18	Lakṣmaṇa is born	Sumitrā gives birth to Lakṣmaṇa and Śatrughna, and Lakṣmaṇa is later named during the royal naming ceremony.	9	13	4
14	3	18	Lakṣmaṇa becomes devoted to Rāma	From early youth, Lakṣmaṇa remains deeply attached to Rāma, attentive to his wishes and unwilling to separate himself from his elder brother.	17	18	5
15	3	22	Lakṣmaṇa accompanies Rāma on Viśvāmitra’s journey	Lakṣmaṇa accompanies Rāma when Viśvāmitra takes the brothers on his journey, following the sage equipped with bow and weapons.	1	6	5
16	3	1	Lakṣmaṇa follows Rāma into exile	Lakṣmaṇa follows Rāma when he leaves for the forest, joining him out of affection and remaining with Rāma and Sītā on their journey.	24	26	5
17	3	71	Lakṣmaṇa marries Urmilā	Janaka agrees to give Urmilā to Lakṣmaṇa, and the marriage of Lakṣmaṇa and Urmilā is arranged and performed alongside the marriages of the other princes.	19	21	5
18	4	8	Daśaratha seeks sons through sacrifice	Daśaratha performs a great sacrifice with the desire to obtain sons and continue his royal lineage.	5	9	5
19	4	1	Daśaratha prepares to establish Rāma as successor	Desiring the welfare of his subjects, Daśaratha wishes to install his eldest and meritorious son Rāma as his associate in the kingdom and heir.	19	20	5
20	4	1	Daśaratha is bound to exile Rāma	Because of his previous promise to Kaikeyī, Daśaratha is compelled by his duty to banish his beloved son Rāma.	21	22	5
21	4	22	Daśaratha entrusts Rāma and Lakṣmaṇa to Viśvāmitra	After Vasiṣṭha’s intervention, Daśaratha summons Rāma and Lakṣmaṇa and entrusts them to Viśvāmitra for the sage’s journey.	1	2	5
22	4	1	Daśaratha follows Rāma and grieves	Daśaratha follows Rāma when he leaves Ayodhyā and suffers deep grief over his son’s departure.	25	28	5
23	4	1	Daśaratha dies after Rāma’s departure	After Rāma reaches Citrakūṭa, Daśaratha, distressed by separation from his son, dies while mourning him.	28	29	5
24	7	18	Bharata is born	Bharata is born to Kaikeyī and is later named during the ceremony performed for Daśaratha’s sons.	8	13	4
25	7	1	Bharata rejects the throne	After Daśaratha’s death, Bharata refuses to accept the kingdom for himself and goes to the forest with the intention of persuading Rāma to return.	29	31	5
26	7	1	Bharata accepts Rāma’s sandals and rules from Nandigrāma	When Rāma does not return, Bharata accepts his sandals as a symbol of his rightful rule and governs from Nandigrāma while awaiting Rāma’s return.	31	32	5
27	7	72	Bharata is chosen to marry Māṇḍavī	The marriage arrangements include Bharata and Māṇḍavī as one of the royal couples, alongside the marriages of Rāma, Sītā, Lakṣmaṇa and Urmilā.	4	9	5
28	7	77	Bharata departs with Śatrughna	Bharata prepares for his journey and departs together with Śatrughna after greeting his father, Rāma and his mother.	9	13	4
29	5	1	Vālmīki asks Nārada about the ideal person	Vālmīki asks Nārada whether there is a person in the world possessing exceptional virtue, courage, truthfulness, knowledge, self-control and devotion to the welfare of all creatures.	1	6	5
30	5	2	Vālmīki witnesses the killing of the Krauñca bird	After beholding the killing of the Krauñca bird, Vālmīki reflects deeply on the act and becomes absorbed in thought.	24	27	5
31	5	2	Vālmīki composes the history of Rāma	The great ascetic Vālmīki composes a poetic work consisting of hundreds of verses and expressing the history of Rāma.	39	39	5
32	5	4	Vālmīki composes the complete history of Rāma	After Rāma has obtained his kingdom, Vālmīki composes the entire history of Rāma in excellent metre and with profound meaning.	1	1	5
33	6	1	Nārada answers Vālmīki’s question	Nārada, who knows the three worlds, responds to Vālmīki’s question about whether there is a person possessing exceptional virtue, courage, truthfulness, knowledge and self-control.	1	6	5
34	6	2	Nārada departs for the celestial regions	After being honored by Vālmīki, the sage Nārada takes leave and returns to the celestial regions.	1	3	4
35	6	2	Nārada’s account becomes the foundation of the Ramayana	Vālmīki is instructed to compose the entire history of Rāma as he heard it from Nārada, establishing Nārada’s account as the source for the composition.	30	31	5
36	8	18	Śatrughna is born and named	Sumitrā gives birth to Śatrughna, and he is later named during the ceremony performed for Daśaratha’s sons.	9	13	4
37	8	72	Śatrughna is chosen to marry Śrutakīrti	The marriage arrangements include Śatrughna and Śrutakīrti among the royal couples.	4	9	5
38	8	73	Śatrughna marries Śrutakīrti	Janaka gives Śrutakīrti to Śatrughna and completes the marriage ceremony of the couple.	18	18	5
39	8	77	Śatrughna departs with Bharata	Bharata prepares for his journey and departs together with Śatrughna after greeting their family.	11	13	4
40	9	16	Kausalyā receives the sacrificial pāyasa	Daśaratha gives Kausalyā a portion of the sacred pāyasa prepared through the sacrifice, intended to enable her to bear a son.	19	19	4
41	9	14	Kausalyā performs the horse-sacrifice rite	Kausalyā performs the prescribed rite associated with the sacrificial horse and subsequently spends a night with the horse as part of the ritual.	26	27	5
42	9	18	Kausalyā gives birth to Rāma	After the completion of the sacrifice, Kausalyā gives birth to Rāma, who is described as possessing extraordinary qualities and divine significance.	7	7	5
43	10	16	Kaikeyī receives the sacrificial pāyasa	Daśaratha gives Kaikeyī an equal portion of the remaining sacred pāyasa so that she may bear a son.	21	21	4
44	10	1	Kaikeyī demands the two boons	Kaikeyī invokes the two boons previously promised by Daśaratha, asking for Rāma’s exile and Bharata’s installation, setting the course for Rāma’s departure to the forest.	21	23	5
45	11	16	Sumitrā receives the sacrificial pāyasa	Daśaratha gives Sumitrā portions of the sacred pāyasa so that she may bear sons.	20	21	4
46	11	18	Sumitrā gives birth to Lakṣmaṇa and Śatrughna	Sumitrā gives birth to Lakṣmaṇa and Śatrughna, who are described as heroic and skilled in weapons.	9	10	5
47	11	22	Sumitrā’s son accompanies Rāma	Lakṣmaṇa, identified as Sumitrā’s son, follows Rāma on the journey with Viśvāmitra.	4	4	4
48	12	50	Janaka hosts the great sacrifice	Janaka presides over the great sacrifice at Mithilā and receives Viśvāmitra, Rāma and Lakṣmaṇa among the distinguished visitors.	2	16	4
49	12	66	Janaka explains Sītā’s origin and the bow-vow	Janaka explains that Sītā arose from the earth while he was ploughing the field and describes his vow that she would be given in marriage to the one capable of bending the divine bow.	3	6	5
50	12	67	Janaka presents the divine bow to Rāma	At Viśvāmitra’s request, Janaka orders the divine bow to be brought before Rāma and allows Rāma to demonstrate his strength.	1	11	5
51	12	67	Janaka confirms Sītā for Rāma	After witnessing Rāma’s prowess, Janaka declares that his promise has been fulfilled and agrees to give his daughter Sītā to Rāma.	17	21	5
52	12	73	Janaka gives Sītā to Rāma	During the wedding ceremony, Janaka brings Sītā before Rāma and gives her to him as his partner in the observance of their duties.	11	16	5
53	13	18	Viśvāmitra arrives at Daśaratha’s court	The mighty ascetic Viśvāmitra arrives while Daśaratha is considering the marriages of his sons and is respectfully received by the king.	22	32	5
54	13	22	Viśvāmitra takes Rāma and Lakṣmaṇa on his journey	Viśvāmitra leads Rāma and Lakṣmaṇa away from Ayodhyā and begins their journey, instructing and guiding the young princes.	3	7	5
55	13	27	Viśvāmitra gives Rāma divine weapons	Viśvāmitra recites the necessary mantras, causing powerful divine weapons to appear before Rāma and placing them under his command.	14	16	5
56	13	29	Viśvāmitra leads the protection of his sacrifice	At Siddhāśrama, Viśvāmitra conducts his sacred ceremony while Rāma and Lakṣmaṇa protect the sacrifice from the Rākṣasas.	18	21	5
57	13	35	Viśvāmitra recounts the history of the Gaṅgā	At Rāma’s request, Viśvāmitra narrates the history and origin of the sacred Gaṅgā in detail.	11	11	4
58	13	54	Viśvāmitra is defeated by Vasiṣṭha	Viśvāmitra confronts Vasiṣṭha in a struggle involving Śabala and powerful armies, but Vasiṣṭha defeats his forces and destroys his sons, leaving Viśvāmitra deeply humiliated.	1	17	5
59	13	63	Viśvāmitra attains Brahmarṣi-hood	After prolonged austerities and repeated spiritual trials, Viśvāmitra is recognized by the celestials as having attained Brahma-hood and is reconciled with Vasiṣṭha.	14	21	5
60	14	1	Bharadvāja guides Rāma toward Citrakūṭa	Bharadvāja provides directions that lead Rāma, Lakṣmaṇa and Sītā toward Citrakūṭa, where they establish their forest dwelling.	27	27	5
61	14	2	Bharadvāja receives Vālmīki	At the sacred spot near the river, Bharadvāja serves his spiritual guide Vālmīki and participates in the opening events surrounding the composition of the Ramayana.	5	7	4
62	14	1	Bharadvāja receives Rāma on his return	On Rāma’s return journey to Ayodhyā, Rāma stops at Bharadvāja’s hermitage before sending Hanumān to Bharata.	72	72	4
63	15	70	Ikṣvāku is established as the first king of Ayodhyā	The genealogy identifies Ikṣvāku as the son of Manu and the first king of Ayodhyā, establishing his foundational place in the royal lineage from which Rāma descends.	18	18	5
64	16	9	Ṛṣyaśṛṅga is raised in the forest	Ṛṣyaśṛṅga, the son of Vibhāṇḍaka, grows up in the forest devoted to austerities and Vedic learning.	3	4	5
65	16	9	Ṛṣyaśṛṅga marries Śāntā	The king is instructed to bring Ṛṣyaśṛṅga and arrange his marriage with Śāntā according to the prescribed rites.	8	15	5
66	16	11	Ṛṣyaśṛṅga conducts Daśaratha’s sacrifice	Ṛṣyaśṛṅga is appointed to conduct the sacrificial ceremony intended to help Daśaratha obtain sons and later presides over the sacrificial proceedings.	6	8	5
67	16	18	Ṛṣyaśṛṅga returns with Śāntā	After being honored by Daśaratha, Ṛṣyaśṛṅga sets out with Śāntā while Daśaratha remains in expectation of sons.	3	6	4
68	17	9	Romapāda rules the Aṅgas during a severe drought	Romapāda is described as the powerful king of the Aṅgas, whose kingdom suffers a terrible drought resulting from a failure on his part.	5	5	4
69	17	11	Romapāda receives Daśaratha and Ṛṣyaśṛṅga	Romapāda receives Daśaratha with honor and becomes involved in the arrangement through which Ṛṣyaśṛṅga and Śāntā are brought into connection with Daśaratha’s plans.	3	13	5
70	18	9	Vibhāṇḍaka becomes the father of Ṛṣyaśṛṅga	Vibhāṇḍaka is identified as the father of Ṛṣyaśṛṅga, who grows up and spends his early life in the forest.	3	3	4
71	18	9	Vibhāṇḍaka’s authority influences the search for Ṛṣyaśṛṅga	Those seeking Ṛṣyaśṛṅga are afraid of Vibhāṇḍaka and hesitate to approach him directly, reflecting the ascetic’s formidable reputation.	11	11	4
72	19	9	Śāntā is betrothed to Ṛṣyaśṛṅga	Romapāda is instructed to bring Ṛṣyaśṛṅga and arrange the betrothal of his daughter Śāntā with the ascetic.	8	8	5
73	19	9	Śāntā is given in marriage to Ṛṣyaśṛṅga	After Ṛṣyaśṛṅga is brought to the kingdom, the king gives Śāntā to him in marriage.	13	13	5
74	19	10	Śāntā lives with Ṛṣyaśṛṅga	Śāntā is formally received as Ṛṣyaśṛṅga’s wife, and the couple begins living together in the royal household.	30	31	4
75	20	9	Indra brings rain after Ṛṣyaśṛṅga arrives	After Ṛṣyaśṛṅga is brought to the kingdom of the Aṅgas, Indra causes abundant rain to fall, bringing relief to the drought-stricken land.	13	13	5
76	20	48	Indra encounters Ahalyā and Gautama	Indra approaches Ahalyā while Gautama is away, but becomes fearful when Gautama returns and realizes that the ascetic is approaching.	17	19	5
77	20	60	Indra opposes Triśaṅku’s ascent to heaven	Indra rejects Triśaṅku’s attempt to reach heaven in his physical body, after which Triśaṅku falls back and appeals to Viśvāmitra for protection.	12	14	5
78	20	61	Indra steals a sacrificial animal	During the sacrifice, Indra takes away the sacrificial animal, creating a crisis for the king and the priests conducting the ceremony.	6	6	5
79	21	29	Kaśyapa performs austerities with Aditi	Kaśyapa, together with Aditi, completes his vow through austerities and hymns Hari, asking that he be born as their son.	8	10	5
80	21	46	Kaśyapa responds to Diti’s grief	After Diti suffers the loss of her sons, Kaśyapa responds to her grief and addresses her in the midst of her sorrow.	1	4	4
81	21	75	Kaśyapa receives the earth	After the destruction of the Kṣatriyas, the earth is given to the righteous Kaśyapa as a sacrificial gift.	6	21	5
\.


--
-- Data for Name: character_mentions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.character_mentions (id, character_id, alias_id, chapter_id, paragraph_number, mentioned_text, start_position, end_position) FROM stdin;
1	5	19	1	1	Vālmīki	12	19
2	6	21	1	1	Nārada	26	32
3	5	19	1	6	Vālmīki	8	15
4	6	21	1	6	Nārada	25	31
5	15	30	1	8	Ikṣvāku	37	44
6	1	1	1	8	Rāma	68	72
7	9	24	1	17	Kausalyā	60	68
8	4	17	1	19	Daśaratha	172	181
9	4	17	1	20	Daśaratha	121	130
10	1	1	1	20	Rāma	0	4
11	10	25	1	21	Kaikeyī	76	83
12	7	22	1	21	Bharata	205	212
13	1	1	1	21	Rāma	175	179
14	4	17	1	22	Daśaratha	62	71
15	1	1	1	22	Rāma	99	103
16	10	25	1	23	Kaikeyī	86	93
17	3	12	1	24	Lakṣmaṇa	130	138
18	11	26	1	24	Sumitrā	61	68
19	1	1	1	24	Rāma	106	110
20	4	17	1	25	Daśaratha	296	305
21	12	27	1	25	Janaka	67	73
22	1	1	1	25	Rāma	34	38
23	1	1	1	25	Rāma	126	130
24	1	1	1	25	Rāma	251	255
25	3	12	1	26	Lakṣmaṇa	93	101
26	2	7	1	26	Sītā	107	111
27	1	1	1	26	Rāma	0	4
28	1	1	1	26	Rāma	114	118
29	14	29	1	27	Bharadvāja	104	114
30	4	17	1	28	Daśaratha	120	129
31	1	1	1	28	Rāma	83	87
32	4	17	1	29	Daśaratha	10	19
33	7	22	1	29	Bharata	55	62
34	1	1	1	29	Rāma	228	232
35	1	1	1	30	Rāma	31	35
36	7	22	1	31	Bharata	0	7
37	7	22	1	31	Bharata	242	249
38	7	22	1	31	Bharata	301	308
39	1	1	1	31	Rāma	113	117
40	7	22	1	32	Bharata	9	16
41	1	1	1	32	Rāma	60	64
42	1	1	1	32	Rāma	131	135
43	7	22	1	33	Bharata	24	31
44	1	1	1	33	Rāma	90	94
45	1	1	1	34	Rāma	48	52
46	20	35	1	35	Indra	57	62
47	1	1	1	36	Rāma	6	10
48	1	1	1	39	Rāma	80	84
49	3	12	1	42	Lakṣmaṇa	83	91
50	1	1	1	42	Rāma	74	78
51	1	1	1	42	Rāma	119	123
52	2	7	1	44	Sītā	80	84
53	1	1	1	45	Rāma	26	30
54	4	17	1	46	Daśaratha	92	101
55	1	1	1	46	Rāma	75	79
56	2	7	1	47	Sītā	177	181
57	1	1	1	47	Rāma	115	119
58	1	1	1	48	Rāma	47	51
59	1	1	1	48	Rāma	74	78
60	1	4	1	50	Rāghava	75	82
61	1	1	1	50	Rāma	5	9
62	1	1	1	50	Rāma	123	127
63	1	4	1	51	Rāghava	32	39
64	1	1	1	52	Rāma	29	33
65	1	1	1	54	Rāma	57	61
66	1	4	1	55	Rāghava	233	240
67	1	4	1	56	Rāghava	72	79
68	12	27	1	57	Janaka	112	118
69	2	7	1	59	Sītā	66	70
70	1	1	1	60	Rāma	83	87
71	1	1	1	63	Rāma	184	188
72	2	7	1	64	Sītā	128	132
73	1	1	1	64	Rāma	65	69
74	1	1	1	65	Rāma	35	39
75	2	7	1	67	Sītā	96	100
76	2	7	1	67	Sītā	149	153
77	1	1	1	67	Rāma	15	19
78	1	1	1	67	Rāma	102	106
79	2	7	1	68	Sītā	17	21
80	2	7	1	68	Sītā	82	86
81	1	4	1	69	Rāghava	295	302
82	2	7	1	69	Sītā	51	55
83	1	1	1	69	Rāma	57	61
84	1	1	1	69	Rāma	152	156
85	1	1	1	70	Rāma	79	83
86	1	1	1	71	Rāma	5	9
87	14	29	1	72	Bharadvāja	17	27
88	7	22	1	72	Bharata	99	106
89	1	1	1	72	Rāma	41	45
90	1	1	1	73	Rāma	58	62
91	2	7	1	74	Sītā	128	132
92	1	1	1	74	Rāma	42	46
93	1	4	1	78	Rāghava	185	192
94	1	1	1	79	Rāma	63	67
95	1	1	1	80	Rāma	70	74
96	6	21	2	1	Nārada	23	29
97	6	21	2	2	Nārada	42	48
98	6	21	2	3	Nārada	9	15
99	14	29	2	5	Bharadvāja	9	19
100	14	29	2	7	Bharadvāja	43	53
101	5	19	2	7	Vālmīki	33	40
102	5	19	2	21	Vālmīki	77	84
103	5	19	2	24	Vālmīki	14	21
104	5	19	2	25	Vālmīki	35	42
105	5	19	2	26	Vālmīki	103	110
106	5	19	2	27	Vālmīki	61	68
107	6	21	2	30	Nārada	213	219
108	1	1	2	30	Rāma	60	64
109	1	1	2	30	Rāma	146	150
110	3	12	2	31	Lakṣmaṇa	97	105
111	6	21	2	31	Nārada	185	191
112	1	1	2	31	Rāma	87	91
113	1	1	2	32	Rāma	125	129
114	5	19	2	39	Vālmīki	18	25
115	1	1	2	39	Rāma	190	194
116	5	19	3	1	Vālmīki	166	173
117	1	1	3	1	Rāma	61	65
118	4	17	3	3	Daśaratha	101	110
119	3	12	3	3	Lakṣmaṇa	75	83
120	2	7	3	3	Sītā	90	94
121	1	1	3	3	Rāma	65	69
122	1	1	3	4	Rāma	36	40
123	1	1	3	6	Rāma	115	119
124	1	1	3	8	Rāma	0	4
125	4	17	3	9	Daśaratha	182	191
126	10	25	3	9	Kaikeyī	242	249
127	12	27	3	9	Janaka	63	69
128	1	1	3	9	Rāma	124	128
129	1	1	3	9	Rāma	134	138
130	1	1	3	9	Rāma	203	207
131	1	1	3	9	Rāma	318	322
132	1	1	3	9	Rāma	451	455
133	14	29	3	10	Bharadvāja	56	66
134	14	29	3	10	Bharadvāja	117	127
135	1	1	3	10	Rāma	34	38
136	7	22	3	11	Bharata	53	60
137	1	1	3	11	Rāma	4	8
138	1	1	3	11	Rāma	97	101
139	1	1	3	11	Rāma	107	111
140	7	22	3	12	Bharata	41	48
141	1	1	3	12	Rāma	80	84
142	2	7	3	13	Sītā	68	72
143	1	1	3	13	Rāma	4	8
144	1	1	3	14	Rāma	4	8
145	2	9	3	15	Vaidehī	121	128
146	1	4	3	16	Rāghava	0	7
147	1	1	3	16	Rāma	64	68
148	1	1	3	17	Rāma	0	4
149	1	1	3	17	Rāma	78	82
150	1	1	3	18	Rāma	65	69
151	1	1	3	19	Rāma	109	113
152	1	1	3	19	Rāma	167	171
153	1	1	3	19	Rāma	212	216
154	1	1	3	20	Rāma	31	35
155	2	7	3	22	Sītā	205	209
156	2	7	3	23	Sītā	32	36
157	2	7	3	24	Sītā	0	4
158	1	4	3	26	Rāghava	20	27
159	1	1	3	26	Rāma	54	58
160	1	1	3	27	Rāma	70	74
161	2	7	3	28	Sītā	98	102
162	14	29	3	29	Bharadvāja	108	118
163	1	1	3	29	Rāma	60	64
164	7	22	3	30	Bharata	45	52
165	1	1	3	30	Rāma	25	29
166	1	1	3	30	Rāma	78	82
167	2	7	3	31	Sītā	49	53
168	1	1	3	31	Rāma	0	4
169	1	1	3	31	Rāma	82	86
170	5	19	4	1	Vālmīki	57	64
171	1	1	4	1	Rāma	5	9
172	2	7	4	5	Sītā	378	382
173	1	1	4	6	Rāma	437	441
174	1	1	4	6	Rāma	531	535
175	8	23	4	17	Śatrughna	526	535
176	3	12	4	17	Lakṣmaṇa	503	511
177	7	22	4	17	Bharata	67	74
178	7	22	4	17	Bharata	514	521
179	1	1	4	17	Rāma	243	247
180	1	1	4	17	Rāma	425	429
181	1	1	4	19	Rāma	0	4
182	1	1	4	20	Rāma	22	26
183	1	1	4	20	Rāma	81	85
184	15	30	5	1	Ikṣvāku	101	108
185	4	17	5	7	Daśaratha	55	64
186	20	35	5	13	Indra	118	123
187	4	17	5	18	Daśaratha	29	38
188	4	17	6	1	Daśaratha	37	46
189	15	30	6	2	Ikṣvāku	27	34
190	4	17	6	4	Daśaratha	50	59
191	20	35	6	5	Indra	3	8
192	4	17	6	20	Daśaratha	31	40
193	15	30	6	20	Ikṣvāku	54	61
194	15	30	7	1	Ikṣvāku	24	31
195	4	17	7	15	Daśaratha	82	91
196	4	17	8	5	Daśaratha	164	173
197	21	36	8	5	Kaśyapa	52	59
198	4	17	8	9	Daśaratha	36	45
199	18	33	9	3	Vibhāṇḍaka	39	49
200	16	31	9	3	Ṛṣyaśṛṅga	76	85
201	21	36	9	3	Kaśyapa	0	7
202	17	32	9	5	Romapāda	103	111
203	18	33	9	8	Vibhāṇḍaka	39	49
204	18	33	9	8	Vibhāṇḍaka	120	130
205	16	31	9	8	Ṛṣyaśṛṅga	137	146
206	19	34	9	8	Śāntā	255	260
207	16	31	9	10	Ṛṣyaśṛṅga	174	183
208	18	33	9	11	Vibhāṇḍaka	147	157
209	19	34	9	13	Śāntā	160	165
210	20	35	9	13	Indra	101	106
211	16	31	9	14	Ṛṣyaśṛṅga	24	33
212	16	31	9	15	Ṛṣyaśṛṅga	91	100
213	4	17	9	15	Daśaratha	15	24
214	16	31	10	1	Ṛṣyaśṛṅga	99	108
215	17	32	10	2	Romapāda	50	58
216	16	31	10	4	Ṛṣyaśṛṅga	0	9
217	18	33	10	10	Vibhāṇḍaka	61	71
218	18	33	10	14	Vibhāṇḍaka	13	23
219	16	31	10	14	Ṛṣyaśṛṅga	54	63
220	18	33	10	18	Vibhāṇḍaka	92	102
221	21	36	10	23	Kaśyapa	45	52
222	18	33	10	24	Vibhāṇḍaka	75	85
223	20	35	10	28	Indra	61	66
224	19	34	10	30	Śāntā	105	110
225	16	31	10	31	Ṛṣyaśṛṅga	25	34
226	19	34	10	31	Śāntā	58	63
227	4	17	11	2	Daśaratha	60	69
228	15	30	11	2	Ikṣvāku	15	22
229	4	17	11	3	Daśaratha	241	250
230	17	32	11	3	Romapāda	185	193
231	17	32	11	3	Romapāda	265	273
232	19	34	11	3	Śāntā	115	120
233	19	34	11	3	Śāntā	323	328
234	16	31	11	4	Ṛṣyaśṛṅga	84	93
235	19	34	11	4	Śāntā	127	132
236	16	31	11	6	Ṛṣyaśṛṅga	166	175
237	4	17	11	6	Daśaratha	9	18
238	16	31	11	8	Ṛṣyaśṛṅga	129	138
239	4	17	11	9	Daśaratha	27	36
240	17	32	11	11	Romapāda	76	84
241	4	17	11	12	Daśaratha	226	235
242	4	17	11	13	Daśaratha	95	104
243	17	32	11	13	Romapāda	39	47
244	17	32	11	13	Romapāda	114	122
245	4	17	11	15	Daśaratha	59	68
246	21	36	11	19	Kaśyapa	113	120
247	20	35	11	19	Indra	97	102
248	19	34	11	21	Śāntā	66	71
249	21	36	12	4	Kaśyapa	196	203
250	4	17	12	6	Daśaratha	45	54
251	16	31	12	10	Ṛṣyaśṛṅga	24	33
252	12	27	13	14	Janaka	70	76
253	17	32	13	17	Romapāda	92	100
254	4	17	13	23	Daśaratha	48	57
255	16	31	13	27	Ṛṣyaśṛṅga	61	70
256	16	31	13	28	Ṛṣyaśṛṅga	12	21
257	16	31	14	2	Ṛṣyaśṛṅga	9	18
258	20	35	14	5	Indra	63	68
259	16	31	14	7	Ṛṣyaśṛṅga	29	38
260	4	17	14	25	Daśaratha	114	123
261	9	24	14	26	Kausalyā	5	13
262	9	24	14	27	Kausalyā	36	44
263	15	30	14	35	Ikṣvāku	185	192
264	16	31	14	39	Ṛṣyaśṛṅga	78	87
265	16	31	14	44	Ṛṣyaśṛṅga	180	189
266	4	17	14	44	Daśaratha	146	155
267	16	31	14	46	Ṛṣyaśṛṅga	185	194
268	20	35	15	8	Indra	125	130
269	4	17	15	17	Daśaratha	164	173
270	4	17	15	23	Daśaratha	94	103
271	4	17	16	8	Daśaratha	77	86
272	4	17	16	9	Daśaratha	90	99
273	4	17	16	11	Daśaratha	279	288
274	4	17	16	11	Daśaratha	808	817
275	4	17	16	13	Daśaratha	24	33
276	4	17	16	17	Daśaratha	5	14
277	4	17	16	18	Daśaratha	4	13
278	9	24	16	19	Kausalyā	47	55
279	11	26	16	20	Sumitrā	96	103
280	4	17	16	21	Daśaratha	46	55
281	10	25	16	21	Kaikeyī	69	76
282	11	26	16	21	Sumitrā	169	176
283	20	35	17	7	Indra	4	9
284	1	1	17	27	Rāma	334	338
285	4	17	18	1	Daśaratha	44	53
286	16	31	18	3	Ṛṣyaśṛṅga	158	167
287	4	17	18	5	Daśaratha	61	70
288	16	31	18	6	Ṛṣyaśṛṅga	54	63
289	19	34	18	6	Śāntā	105	110
290	9	24	18	7	Kausalyā	361	369
291	9	24	18	7	Kausalyā	731	739
292	15	30	18	7	Ikṣvāku	464	471
293	1	1	18	7	Rāma	439	443
294	10	25	18	8	Kaikeyī	17	24
295	7	22	18	8	Bharata	33	40
296	8	23	18	9	Śatrughna	40	49
297	3	12	18	9	Lakṣmaṇa	27	35
298	11	26	18	9	Sumitrā	5	12
299	11	26	18	10	Sumitrā	126	133
300	7	22	18	10	Bharata	4	11
301	8	23	18	13	Śatrughna	297	306
302	3	12	18	13	Lakṣmaṇa	264	272
303	10	25	18	13	Kaikeyī	201	208
304	11	26	18	13	Sumitrā	239	246
305	7	22	18	13	Bharata	226	233
306	1	1	18	13	Rāma	191	195
307	1	1	18	15	Rāma	95	99
308	1	1	18	16	Rāma	111	115
309	3	12	18	17	Lakṣmaṇa	59	67
310	3	12	18	17	Lakṣmaṇa	169	177
311	1	1	18	17	Rāma	108	112
312	1	1	18	17	Rāma	163	167
313	1	1	18	17	Rāma	239	243
314	1	1	18	17	Rāma	356	360
315	1	1	18	17	Rāma	430	434
316	8	23	18	18	Śatrughna	145	154
317	3	12	18	18	Lakṣmaṇa	52	60
318	3	12	18	18	Lakṣmaṇa	135	143
319	1	4	18	18	Rāghava	28	35
320	7	22	18	18	Bharata	187	194
321	4	17	18	19	Daśaratha	58	67
322	4	17	18	20	Daśaratha	174	183
323	13	28	18	22	Viśvāmitra	237	247
324	4	17	18	22	Daśaratha	41	50
325	13	28	18	24	Viśvāmitra	212	222
326	15	30	18	24	Ikṣvāku	164	171
327	4	17	18	25	Daśaratha	31	40
328	20	35	18	25	Indra	107	112
329	13	28	18	32	Viśvāmitra	44	54
330	13	28	19	1	Viśvāmitra	76	86
331	1	1	19	6	Rāma	191	195
332	1	1	19	7	Rāma	287	291
333	1	1	19	7	Rāma	536	540
334	1	1	19	8	Rāma	77	81
335	1	1	19	8	Rāma	269	273
336	1	1	19	8	Rāma	481	485
337	1	5	19	9	Kākutstha	7	16
338	1	1	19	9	Rāma	131	135
339	1	1	19	10	Rāma	105	109
340	13	28	19	11	Viśvāmitra	99	109
341	13	28	19	12	Viśvāmitra	36	46
342	15	30	19	16	Ikṣvāku	90	97
343	13	28	20	1	Viśvāmitra	21	31
344	1	1	20	2	Rāma	14	18
345	1	1	20	4	Rāma	157	161
346	1	1	20	6	Rāma	132	136
347	1	1	20	8	Rāma	73	77
348	1	1	20	8	Rāma	218	222
349	1	1	20	9	Rāma	82	86
350	1	1	20	9	Rāma	159	163
351	1	1	20	10	Rāma	62	66
352	1	1	20	10	Rāma	156	160
353	1	1	20	11	Rāma	209	213
354	13	28	20	12	Viśvāmitra	28	38
355	4	17	21	1	Daśaratha	23	32
356	1	5	21	3	Kākutstha	106	115
357	13	28	21	4	Viśvāmitra	25	35
358	15	30	21	6	Ikṣvāku	20	27
359	1	2	21	8	Rama	161	165
360	13	28	21	20	Viśvāmitra	42	52
361	1	1	21	20	Rāma	147	151
362	1	1	21	22	Rāma	157	161
363	4	17	22	1	Daśaratha	41	50
364	3	12	22	1	Lakṣmaṇa	116	124
365	1	1	22	1	Rāma	107	111
366	4	17	22	2	Daśaratha	139	148
367	1	1	22	2	Rāma	57	61
368	13	28	22	3	Viśvāmitra	112	122
369	1	1	22	3	Rāma	91	95
370	13	28	22	4	Viśvāmitra	0	10
371	11	26	22	4	Sumitrā	110	117
372	1	1	22	4	Rāma	50	54
373	13	28	22	5	Viśvāmitra	150	160
374	3	12	22	6	Lakṣmaṇa	274	282
375	1	1	22	6	Rāma	265	269
376	13	28	22	7	Viśvāmitra	89	99
377	1	1	22	7	Rāma	131	135
378	1	1	22	7	Rāma	139	143
379	1	1	22	8	Rāma	202	206
380	1	4	22	9	Rāghava	10	17
381	1	1	22	10	Rāma	7	11
382	1	5	22	11	Kākutstha	36	45
383	1	1	22	12	Rāma	8	12
384	1	1	22	13	Rāma	33	37
385	1	1	22	14	Rāma	5	9
386	4	17	22	15	Daśaratha	37	46
387	1	5	23	1	Kākutstha	64	73
388	9	24	23	1	Kausalyā	127	135
389	1	1	23	1	Rāma	109	113
390	13	28	23	3	Viśvāmitra	83	93
391	13	28	23	6	Viśvāmitra	106	116
392	1	1	23	8	Rāma	75	79
393	1	4	23	12	Rāghava	2	9
394	1	1	23	14	Rāma	8	12
395	3	12	23	17	Lakṣmaṇa	145	153
396	1	1	23	17	Rāma	136	140
397	13	28	24	1	Viśvāmitra	82	92
398	13	28	24	3	Viśvāmitra	89	99
399	13	28	24	5	Viśvāmitra	70	80
400	1	1	24	6	Rāma	165	169
401	1	1	24	7	Rāma	38	42
402	1	4	24	8	Rāghava	8	15
403	1	1	24	9	Rāma	2	6
404	1	1	24	11	Rāma	127	131
405	15	30	24	13	Ikṣvāku	81	88
406	13	28	24	15	Viśvāmitra	37	47
407	1	5	24	15	Kākutstha	91	100
408	1	1	24	17	Rāma	19	23
409	20	35	24	18	Indra	5	10
410	20	35	24	19	Indra	92	97
411	20	35	24	20	Indra	12	17
412	1	1	24	28	Rāma	2	6
413	13	28	25	3	Viśvāmitra	72	82
414	3	12	25	3	Lakṣmaṇa	152	160
415	1	4	25	3	Rāghava	40	47
416	1	1	25	3	Rāma	141	145
417	1	1	25	5	Rāma	7	11
418	1	1	25	9	Rāma	2	6
419	1	5	25	17	Kākutstha	104	113
420	1	1	25	19	Rāma	16	20
421	1	4	26	1	Rāghava	74	81
422	4	17	26	2	Daśaratha	211	220
423	3	12	26	7	Lakṣmaṇa	129	137
424	3	12	26	8	Lakṣmaṇa	11	19
425	1	1	26	11	Rāma	3	7
426	13	28	26	12	Viśvāmitra	28	38
427	1	4	26	15	Rāghava	64	71
428	11	26	26	16	Sumitrā	80	87
429	1	1	26	18	Rāma	191	195
430	1	1	26	19	Rāma	16	20
431	1	5	26	20	Kākutstha	103	112
432	3	12	26	20	Lakṣmaṇa	117	125
433	1	1	26	20	Rāma	222	226
434	1	5	26	21	Kākutstha	118	127
435	13	28	26	22	Viśvāmitra	100	110
436	20	35	26	23	Indra	64	69
437	1	1	26	23	Rāma	123	127
438	13	28	26	25	Viśvāmitra	48	58
439	1	1	26	26	Rāma	99	103
440	1	1	26	27	Rāma	9	13
441	13	28	26	28	Viśvāmitra	8	18
442	4	17	26	28	Daśaratha	28	37
443	1	1	26	30	Rāma	41	45
444	13	28	27	1	Viśvāmitra	42	52
445	1	4	27	1	Rāghava	94	101
446	1	4	27	4	Rāghava	100	107
447	1	5	27	5	Kākutstha	210	219
448	1	1	27	5	Rāma	287	291
449	1	5	27	7	Kākutstha	115	124
450	1	4	27	7	Rāghava	22	29
451	1	4	27	9	Rāghava	234	241
452	1	1	27	10	Rāma	20	24
453	1	1	27	11	Rāma	25	29
454	1	1	27	12	Rāma	129	133
455	1	4	27	13	Rāghava	33	40
456	13	28	27	14	Viśvāmitra	29	39
457	1	4	27	14	Rāghava	239	246
458	1	1	27	14	Rāma	182	186
459	1	5	27	15	Kākutstha	49	58
460	1	1	27	15	Rāma	59	63
461	13	28	27	16	Viśvāmitra	91	101
462	1	1	27	16	Rāma	31	35
463	13	28	28	1	Viśvāmitra	127	137
464	1	5	28	1	Kākutstha	43	52
465	13	28	28	3	Viśvāmitra	36	46
466	1	5	28	3	Kākutstha	5	14
467	1	4	28	4	Rāghava	496	503
468	1	1	28	4	Rāma	10	14
469	1	1	28	4	Rāma	621	625
470	1	5	28	5	Kākutstha	11	20
471	1	1	28	5	Rāma	366	370
472	1	5	28	7	Kākutstha	76	85
473	1	1	28	7	Rāma	27	31
474	13	28	29	1	Viśvāmitra	101	111
475	1	1	29	1	Rāma	23	27
476	1	1	29	2	Rāma	21	25
477	1	1	29	2	Rāma	188	192
478	20	35	29	3	Indra	217	222
479	21	36	29	8	Kaśyapa	40	47
480	1	1	29	8	Rāma	19	23
481	1	1	29	8	Rāma	174	178
482	21	36	29	9	Kaśyapa	340	347
483	21	36	29	10	Kaśyapa	43	50
484	20	35	29	14	Indra	325	330
485	1	1	29	16	Rāma	10	14
486	3	12	29	17	Lakṣmaṇa	29	37
487	1	1	29	17	Rāma	20	24
488	13	28	29	18	Viśvāmitra	14	24
489	13	28	29	21	Viśvāmitra	454	464
490	3	12	29	21	Lakṣmaṇa	216	224
491	1	1	29	21	Rāma	207	211
492	11	26	30	6	Sumitrā	71	78
493	1	1	30	6	Rāma	58	62
494	13	28	30	7	Viśvāmitra	144	154
495	1	1	30	7	Rāma	5	9
496	3	12	30	10	Lakṣmaṇa	183	191
497	1	1	30	10	Rāma	43	47
498	1	1	30	10	Rāma	159	163
499	3	12	30	11	Lakṣmaṇa	9	17
500	1	1	30	12	Rāma	40	44
501	3	12	30	14	Lakṣmaṇa	115	123
502	1	1	30	14	Rāma	100	104
503	3	12	30	15	Lakṣmaṇa	10	18
504	3	12	30	17	Lakṣmaṇa	34	42
505	1	4	30	17	Rāghava	301	308
506	20	35	30	18	Indra	114	119
507	13	28	30	19	Viśvāmitra	58	68
508	1	5	30	19	Kākutstha	120	129
509	3	12	30	20	Lakṣmaṇa	205	213
510	1	1	30	20	Rāma	182	186
511	1	1	30	20	Rāma	196	200
512	3	12	31	1	Lakṣmaṇa	23	31
513	1	1	31	1	Rāma	14	18
514	13	28	31	2	Viśvāmitra	98	108
515	1	1	31	5	Rāma	75	79
516	12	27	31	6	Janaka	91	97
517	1	5	31	11	Kākutstha	9	18
518	1	5	31	14	Kākutstha	66	75
519	13	28	31	18	Viśvāmitra	70	80
520	13	28	31	19	Viśvāmitra	237	247
521	13	28	31	19	Viśvāmitra	397	407
522	11	26	31	19	Sumitrā	307	314
523	1	1	31	19	Rāma	283	287
524	13	28	31	20	Viśvāmitra	89	99
525	1	2	31	20	Rama	5	9
526	1	1	31	21	Rāma	18	22
527	1	1	32	5	Rāma	21	25
528	1	1	32	5	Rāma	71	75
529	1	4	32	7	Rāghava	231	238
530	1	5	33	19	Kākutstha	7	16
531	1	4	34	1	Rāghava	7	14
532	1	1	34	4	Rāma	44	48
533	1	5	34	6	Kākutstha	2	11
534	1	4	34	7	Rāghava	2	9
535	1	4	34	10	Rāghava	113	120
536	1	1	34	12	Rāma	7	11
537	1	1	34	13	Rāma	7	11
538	1	5	34	14	Kākutstha	7	16
539	13	28	34	21	Viśvāmitra	33	43
540	11	26	34	23	Sumitrā	20	27
541	1	1	34	23	Rāma	0	4
542	13	28	35	1	Viśvāmitra	97	107
543	1	1	35	2	Rāma	2	6
544	1	1	35	3	Rāma	28	32
545	13	28	35	5	Viśvāmitra	24	34
546	1	1	35	5	Rāma	18	22
547	1	4	35	7	Rāghava	120	127
548	13	28	35	8	Viśvāmitra	360	370
549	13	28	35	9	Viśvāmitra	156	166
550	1	1	35	9	Rāma	100	104
551	13	28	35	11	Viśvāmitra	48	58
552	1	1	35	11	Rāma	14	18
553	1	1	35	12	Rāma	2	6
554	1	1	35	13	Rāma	2	6
555	1	4	35	14	Rāghava	65	72
556	1	4	35	18	Rāghava	13	20
557	3	12	36	1	Lakṣmaṇa	60	68
558	1	1	36	1	Rāma	51	55
559	13	28	36	4	Viśvāmitra	89	99
560	1	5	36	4	Kākutstha	154	163
561	1	1	36	5	Rāma	19	23
562	1	1	36	6	Rāma	11	15
563	1	1	36	19	Rāma	32	36
564	3	12	36	25	Lakṣmaṇa	108	116
565	1	1	36	25	Rāma	29	33
566	20	35	37	1	Indra	65	70
567	1	1	37	2	Rāma	7	11
568	1	1	37	9	Rāma	8	12
569	20	35	37	20	Indra	44	49
570	1	5	37	24	Kākutstha	7	16
571	1	5	37	28	Kākutstha	10	19
572	1	5	38	1	Kākutstha	88	97
573	1	1	38	1	Rāma	27	31
574	1	1	38	3	Rāma	2	6
575	1	1	38	12	Rāma	100	104
576	13	28	39	1	Viśvāmitra	5	15
577	1	1	39	1	Rāma	46	50
578	13	28	39	3	Viśvāmitra	28	38
579	1	5	39	3	Kākutstha	66	75
580	1	1	39	4	Rāma	10	14
581	1	5	39	5	Kākutstha	78	87
582	1	5	39	7	Kākutstha	2	11
583	1	5	39	7	Kākutstha	204	213
584	1	1	39	12	Rāma	2	6
585	1	4	39	13	Rāghava	2	9
586	1	1	39	14	Rāma	51	55
587	1	5	40	13	Kākutstha	7	16
588	1	1	40	14	Rāma	13	17
589	1	5	40	26	Kākutstha	12	21
590	1	1	41	16	Rāma	23	27
591	20	35	42	10	Indra	163	168
592	15	30	42	17	Ikṣvāku	124	131
593	15	30	42	19	Ikṣvāku	103	110
594	1	1	43	1	Rāma	52	56
595	1	1	43	4	Rāma	8	12
596	1	1	43	7	Rāma	2	6
598	1	1	43	22	Rāma	205	209
599	1	4	43	25	Rāghava	11	18
600	1	1	44	1	Rāma	176	180
601	1	1	44	17	Rāma	8	12
602	1	5	44	19	Kākutstha	2	11
603	13	28	45	3	Viśvāmitra	96	106
604	11	26	45	3	Sumitrā	61	68
605	13	28	45	4	Viśvāmitra	118	128
606	1	4	45	7	Rāghava	39	46
607	1	4	45	8	Rāghava	70	77
608	13	28	45	9	Viśvāmitra	73	83
609	1	1	45	9	Rāma	21	25
610	1	1	45	11	Rāma	23	27
611	1	1	45	12	Rāma	17	21
612	1	1	45	13	Rāma	29	33
613	1	5	45	29	Kākutstha	51	60
614	1	1	45	32	Rāma	19	23
615	1	1	45	35	Rāma	2	6
616	21	36	46	1	Kaśyapa	110	117
617	21	36	46	4	Kaśyapa	43	50
618	1	1	46	17	Rāma	2	6
619	20	35	47	5	Indra	45	50
620	1	1	47	9	Rāma	102	106
621	1	5	47	10	Kākutstha	12	21
622	20	35	47	10	Indra	63	68
623	15	30	47	11	Ikṣvāku	24	31
624	1	1	47	12	Rāma	16	20
625	1	1	47	13	Rāma	2	6
626	1	5	47	15	Kākutstha	54	63
627	15	30	47	16	Ikṣvāku	20	27
628	12	27	47	17	Janaka	108	114
629	13	28	47	18	Viśvāmitra	38	48
630	13	28	47	19	Viśvāmitra	16	26
631	13	28	47	19	Viśvāmitra	151	161
632	13	28	48	4	Viśvāmitra	24	34
633	13	28	48	4	Viśvāmitra	76	86
634	4	17	48	4	Daśaratha	155	164
635	12	27	48	6	Janaka	10	16
636	1	4	48	7	Rāghava	27	34
637	13	28	48	9	Viśvāmitra	118	128
638	20	35	48	17	Indra	0	5
639	20	35	48	18	Indra	23	28
640	1	1	48	18	Rāma	32	36
641	20	35	48	19	Indra	19	24
642	4	17	48	23	Daśaratha	262	271
643	1	1	48	23	Rāma	273	277
644	20	35	49	5	Indra	85	90
645	1	5	49	9	Kākutstha	16	25
646	20	35	49	9	Indra	134	139
647	1	4	49	10	Rāghava	15	22
648	20	35	49	10	Indra	25	30
649	13	28	49	12	Viśvāmitra	11	21
650	13	28	49	12	Viśvāmitra	75	85
651	3	12	49	12	Lakṣmaṇa	56	64
652	1	4	49	12	Rāghava	32	39
653	1	1	49	14	Rāma	116	120
654	1	5	49	16	Kākutstha	8	17
655	1	1	49	18	Rāma	79	83
656	1	1	49	19	Rāma	72	76
657	13	28	50	1	Viśvāmitra	72	82
658	11	26	50	1	Sumitrā	48	55
659	1	1	50	1	Rāma	27	31
660	3	12	50	2	Lakṣmaṇa	13	21
661	12	27	50	2	Janaka	104	110
662	1	1	50	2	Rāma	4	8
663	13	28	50	4	Viśvāmitra	41	51
664	1	1	50	4	Rāma	8	12
665	13	28	50	5	Viśvāmitra	15	25
666	13	28	50	5	Viśvāmitra	239	249
667	12	27	50	6	Janaka	47	53
668	12	27	50	8	Janaka	8	14
669	13	28	50	9	Viśvāmitra	34	44
670	4	17	50	14	Daśaratha	99	108
671	12	27	50	14	Janaka	39	45
672	1	1	50	15	Rāma	160	164
673	13	28	50	16	Viśvāmitra	110	120
674	12	27	50	16	Janaka	43	49
675	13	28	51	1	Viśvāmitra	41	51
676	1	1	51	1	Rāma	244	248
677	13	28	51	2	Viśvāmitra	87	97
678	1	1	51	5	Rāma	125	129
679	1	1	51	6	Rāma	70	74
680	1	1	51	7	Rāma	48	52
681	1	1	51	8	Rāma	71	75
682	13	28	51	9	Viśvāmitra	47	57
683	13	28	51	11	Viśvāmitra	38	48
684	1	1	51	11	Rāma	94	98
685	13	28	51	12	Viśvāmitra	136	146
686	13	28	51	13	Viśvāmitra	23	33
687	1	1	51	14	Rāma	2	6
688	13	28	51	18	Viśvāmitra	91	101
689	13	28	51	21	Viśvāmitra	143	153
690	13	28	52	1	Viśvāmitra	85	95
691	13	28	52	2	Viśvāmitra	42	52
692	13	28	52	3	Viśvāmitra	23	33
693	13	28	52	4	Viśvāmitra	97	107
694	13	28	52	4	Viśvāmitra	317	327
695	13	28	52	5	Viśvāmitra	72	82
696	13	28	52	9	Viśvāmitra	36	46
697	13	28	52	11	Viśvāmitra	106	116
698	13	28	52	14	Viśvāmitra	60	70
699	13	28	53	3	Viśvāmitra	27	37
700	1	1	53	3	Rāma	7	11
701	13	28	53	4	Viśvāmitra	21	31
702	13	28	53	8	Viśvāmitra	18	28
703	13	28	53	13	Viśvāmitra	55	65
704	13	28	53	17	Viśvāmitra	33	43
705	13	28	54	1	Viśvāmitra	69	79
706	1	1	54	1	Rāma	84	88
707	1	1	54	2	Rāma	7	11
708	13	28	54	14	Viśvāmitra	58	68
709	1	1	54	16	Rāma	52	56
710	13	28	54	17	Viśvāmitra	137	147
711	13	28	54	17	Viśvāmitra	361	371
712	13	28	54	17	Viśvāmitra	656	666
713	13	28	54	17	Viśvāmitra	748	758
714	13	28	55	1	Viśvāmitra	53	63
715	13	28	55	3	Viśvāmitra	34	44
716	13	28	55	4	Viśvāmitra	77	87
717	13	28	55	5	Viśvāmitra	13	23
718	13	28	55	6	Viśvāmitra	75	85
719	13	28	55	11	Viśvāmitra	128	138
720	13	28	55	13	Viśvāmitra	66	76
721	13	28	55	16	Viśvāmitra	134	144
722	1	1	55	17	Rāma	77	81
723	13	28	55	19	Viśvāmitra	54	64
724	13	28	55	23	Viśvāmitra	88	98
725	13	28	56	1	Viśvāmitra	40	50
726	13	28	56	7	Viśvāmitra	591	601
727	13	28	56	14	Viśvāmitra	12	22
728	13	28	56	16	Viśvāmitra	4	14
729	13	28	57	1	Viśvāmitra	134	144
730	1	4	57	2	Rāghava	2	9
731	13	28	57	3	Viśvāmitra	101	111
732	13	28	57	5	Viśvāmitra	14	24
733	1	5	57	6	Kākutstha	73	82
734	1	4	57	7	Rāghava	2	9
735	15	30	57	7	Ikṣvāku	62	69
736	1	1	58	1	Rāma	61	65
737	13	28	58	8	Viśvāmitra	242	252
738	1	5	58	8	Kākutstha	132	141
739	1	1	58	8	Rāma	7	11
740	1	1	58	9	Rāma	78	82
741	15	30	59	2	Ikṣvāku	16	23
742	13	28	59	7	Viśvāmitra	142	152
743	13	28	59	10	Viśvāmitra	193	203
744	13	28	59	15	Viśvāmitra	88	98
745	13	28	60	1	Viśvāmitra	153	163
746	15	30	60	2	Ikṣvāku	19	26
747	13	28	60	3	Viśvāmitra	8	18
748	13	28	60	4	Viśvāmitra	163	173
749	15	30	60	4	Ikṣvāku	119	126
750	13	28	60	6	Viśvāmitra	43	53
751	13	28	60	7	Viśvāmitra	24	34
752	13	28	60	8	Viśvāmitra	52	62
753	1	5	60	11	Kākutstha	34	43
754	20	35	60	12	Indra	55	60
755	13	28	60	14	Viśvāmitra	78	88
756	20	35	60	14	Indra	10	15
757	20	35	60	17	Indra	175	180
758	20	35	60	17	Indra	231	236
759	13	28	60	18	Viśvāmitra	105	115
760	13	28	60	23	Viśvāmitra	486	496
761	13	28	61	1	Viśvāmitra	68	78
762	20	35	61	6	Indra	27	32
763	1	1	61	17	Rāma	87	91
764	13	28	62	2	Viśvāmitra	138	148
765	13	28	62	2	Viśvāmitra	318	328
766	1	1	62	2	Rāma	291	295
767	13	28	62	6	Viśvāmitra	19	29
768	20	35	62	21	Indra	101	106
769	13	28	62	24	Viśvāmitra	42	52
770	1	1	62	24	Rāma	2	6
771	13	28	63	3	Viśvāmitra	74	84
772	13	28	63	6	Viśvāmitra	41	51
773	1	4	63	6	Rāghava	90	97
774	13	28	63	7	Viśvāmitra	115	125
775	13	28	63	10	Viśvāmitra	169	179
776	1	1	63	10	Rāma	183	187
777	1	1	63	12	Rāma	97	101
778	13	28	63	14	Viśvāmitra	81	91
779	13	28	63	15	Viśvāmitra	40	50
780	13	28	63	17	Viśvāmitra	54	64
781	13	28	63	19	Viśvāmitra	26	36
782	20	35	63	19	Indra	125	130
783	1	1	64	2	Rāma	70	74
784	13	28	64	3	Viśvāmitra	47	57
785	13	28	64	7	Viśvāmitra	107	117
786	20	35	64	7	Indra	8	13
787	13	28	64	13	Viśvāmitra	56	66
788	20	35	64	14	Indra	129	134
789	1	1	64	15	Rāma	2	6
790	1	1	65	1	Rāma	53	57
791	1	1	65	2	Rāma	65	69
792	20	35	65	4	Indra	304	309
793	1	1	65	4	Rāma	48	52
794	13	28	65	9	Viśvāmitra	87	97
795	13	28	65	16	Viśvāmitra	75	85
796	13	28	65	19	Viśvāmitra	99	109
797	13	28	65	21	Viśvāmitra	34	44
798	1	1	65	22	Rāma	101	105
799	1	1	65	23	Rāma	8	12
800	3	12	65	24	Lakṣmaṇa	127	135
801	12	27	65	24	Janaka	138	144
802	1	1	65	24	Rāma	118	122
803	1	5	65	25	Kākutstha	66	75
804	1	1	65	26	Rāma	172	176
805	12	27	65	30	Janaka	106	112
806	13	28	65	32	Viśvāmitra	18	28
807	3	12	65	32	Lakṣmaṇa	57	65
808	1	1	65	32	Rāma	48	52
809	13	28	66	1	Viśvāmitra	111	121
810	1	4	66	1	Rāghava	126	133
811	12	27	66	3	Janaka	34	40
812	4	17	66	4	Daśaratha	14	23
813	12	27	66	6	Janaka	15	21
814	2	7	66	11	Sītā	154	158
815	3	12	66	18	Lakṣmaṇa	75	83
816	1	1	66	18	Rāma	66	70
817	4	17	66	19	Daśaratha	100	109
818	2	7	66	19	Sītā	128	132
819	1	1	66	19	Rāma	43	47
820	13	28	67	1	Viśvāmitra	41	51
821	12	27	67	1	Janaka	8	14
822	1	1	67	1	Rāma	93	97
823	12	27	67	2	Janaka	19	25
824	12	27	67	3	Janaka	13	19
825	12	27	67	5	Janaka	98	104
826	13	28	67	7	Viśvāmitra	74	84
827	3	12	67	7	Lakṣmaṇa	105	113
828	1	1	67	7	Rāma	96	100
829	13	28	67	11	Viśvāmitra	38	48
830	1	4	67	11	Rāghava	57	64
831	12	27	67	11	Janaka	8	14
832	1	1	67	11	Rāma	69	73
833	1	1	67	12	Rāma	30	34
834	4	17	67	16	Daśaratha	47	56
835	4	17	67	17	Daśaratha	48	57
836	12	27	67	17	Janaka	91	97
837	2	7	67	17	Sītā	13	17
838	1	1	67	17	Rāma	65	69
839	2	7	67	18	Sītā	36	40
840	2	7	67	18	Sītā	121	125
841	1	1	67	18	Rāma	187	191
842	2	7	67	19	Sītā	217	221
843	1	1	67	19	Rāma	227	231
844	12	27	68	1	Janaka	21	27
845	4	17	68	2	Daśaratha	95	104
846	12	27	68	3	Janaka	151	157
847	1	1	68	6	Rāma	150	154
848	2	7	68	7	Sītā	42	46
849	13	28	68	10	Viśvāmitra	52	62
850	3	12	68	12	Lakṣmaṇa	105	113
851	9	24	68	12	Kausalyā	45	53
852	1	5	68	13	Kākutstha	56	65
853	1	4	68	13	Rāghava	108	115
854	12	27	68	13	Janaka	20	26
855	12	27	68	14	Janaka	38	44
856	12	27	68	16	Janaka	77	83
857	4	17	69	1	Daśaratha	41	50
858	21	36	69	4	Kaśyapa	45	52
859	4	17	69	6	Daśaratha	82	91
860	4	17	69	6	Daśaratha	191	200
861	12	27	69	6	Janaka	123	129
862	12	27	69	15	Janaka	127	133
863	12	27	69	16	Janaka	30	36
864	12	27	70	1	Janaka	18	24
865	12	27	70	4	Janaka	85	91
866	20	35	70	5	Indra	156	161
867	12	27	70	6	Janaka	120	126
868	12	27	70	8	Janaka	60	66
869	12	27	70	8	Janaka	151	157
870	15	30	70	9	Ikṣvāku	201	208
871	4	17	70	10	Daśaratha	85	94
872	12	27	70	12	Janaka	109	115
873	13	28	70	15	Viśvāmitra	17	27
874	4	17	70	16	Daśaratha	7	16
875	21	36	70	17	Kaśyapa	123	130
876	21	36	70	17	Kaśyapa	158	165
877	15	30	70	18	Ikṣvāku	46	53
878	15	30	70	18	Ikṣvāku	78	85
879	15	30	70	19	Ikṣvāku	4	11
880	7	22	70	24	Bharata	40	47
881	7	22	70	24	Bharata	59	66
882	1	5	70	31	Kākutstha	27	36
883	1	5	70	31	Kākutstha	48	57
884	4	17	70	35	Daśaratha	134	143
885	4	17	70	35	Daśaratha	159	168
886	3	12	70	35	Lakṣmaṇa	201	209
887	1	1	70	35	Rāma	192	196
888	3	12	70	36	Lakṣmaṇa	35	43
889	15	30	70	36	Ikṣvāku	116	123
890	1	1	70	36	Rāma	26	30
891	15	30	70	40	Ikṣvāku	23	30
892	12	27	71	1	Janaka	31	37
893	12	27	71	3	Janaka	46	52
894	12	27	71	3	Janaka	73	79
895	12	27	71	3	Janaka	146	152
896	2	7	71	15	Sītā	117	121
897	3	12	71	19	Lakṣmaṇa	46	54
898	2	7	71	19	Sītā	0	4
899	2	7	71	19	Sītā	222	226
900	1	1	71	19	Rāma	8	12
901	3	12	71	20	Lakṣmaṇa	73	81
902	1	1	71	20	Rāma	64	68
903	3	12	71	21	Lakṣmaṇa	235	243
904	1	1	71	21	Rāma	226	230
905	13	28	72	1	Viśvāmitra	49	59
906	3	12	72	3	Lakṣmaṇa	43	51
907	2	7	72	3	Sītā	57	61
908	1	1	72	3	Rāma	34	38
909	8	23	72	4	Śatrughna	316	325
910	3	12	72	4	Lakṣmaṇa	423	431
911	7	22	72	4	Bharata	288	295
912	1	1	72	4	Rāma	414	418
913	4	17	72	5	Daśaratha	18	27
914	15	30	72	6	Ikṣvāku	94	101
915	13	28	72	7	Viśvāmitra	8	18
916	12	27	72	7	Janaka	65	71
917	8	23	72	9	Śatrughna	124	133
918	7	22	72	9	Bharata	138	145
919	12	27	72	12	Janaka	38	44
920	4	17	72	14	Daśaratha	31	40
921	4	17	72	15	Daśaratha	60	69
922	12	27	72	15	Janaka	15	21
923	4	17	72	18	Daśaratha	54	63
924	4	17	73	1	Daśaratha	194	203
925	7	22	73	1	Bharata	159	166
926	7	22	73	2	Bharata	187	194
927	4	17	73	4	Daśaratha	10	19
928	1	1	73	6	Rāma	45	49
929	4	17	73	7	Daśaratha	5	14
930	4	17	73	11	Daśaratha	40	49
931	12	27	73	11	Janaka	31	37
932	1	1	73	12	Rāma	164	168
933	13	28	73	13	Viśvāmitra	96	106
934	12	27	73	13	Janaka	31	37
935	9	24	73	14	Kausalyā	137	145
936	1	4	73	14	Rāghava	88	95
937	12	27	73	14	Janaka	103	109
938	2	7	73	14	Sītā	14	18
939	2	7	73	14	Sītā	167	171
940	1	1	73	15	Rāma	32	36
941	3	12	73	16	Lakṣmaṇa	213	221
942	12	27	73	16	Janaka	157	163
943	2	7	73	16	Sītā	121	125
944	3	12	73	17	Lakṣmaṇa	17	25
945	7	22	73	17	Bharata	48	55
946	12	27	73	17	Janaka	32	38
947	8	23	73	18	Śatrughna	44	53
948	12	27	73	19	Janaka	8	14
949	13	28	74	1	Viśvāmitra	53	63
950	13	28	74	2	Viśvāmitra	5	15
951	4	17	74	2	Daśaratha	36	45
952	4	17	74	4	Daśaratha	101	110
953	1	4	74	5	Rāghava	55	62
954	4	17	74	7	Daśaratha	27	36
955	13	28	74	11	Viśvāmitra	80	90
956	1	1	74	13	Rāma	131	135
957	1	1	74	13	Rāma	140	144
958	4	17	74	14	Daśaratha	122	131
959	1	1	74	14	Rāma	89	93
960	1	1	74	14	Rāma	105	109
961	4	17	75	1	Daśaratha	16	25
962	1	1	75	1	Rāma	2	6
963	4	17	75	4	Daśaratha	24	33
964	21	36	75	6	Kaśyapa	65	72
965	1	1	75	7	Rāma	80	84
966	4	17	75	8	Daśaratha	18	27
967	1	1	75	8	Rāma	99	103
968	1	5	75	10	Kākutstha	143	152
969	1	1	75	11	Rāma	98	102
970	1	5	75	12	Kākutstha	2	11
971	1	1	75	18	Rāma	2	6
972	21	36	75	21	Kaśyapa	257	264
973	1	1	75	21	Rāma	190	194
974	1	5	75	23	Kākutstha	256	265
975	1	1	75	23	Rāma	14	18
976	4	17	76	1	Daśaratha	40	49
977	1	4	76	4	Rāghava	25	32
978	1	1	76	5	Rāma	57	61
979	1	1	76	5	Rāma	97	101
980	13	28	76	6	Viśvāmitra	31	41
981	1	1	76	6	Rāma	88	92
982	1	1	76	7	Rāma	42	46
983	1	1	76	8	Rāma	33	37
984	1	1	76	10	Rāma	50	54
985	1	1	76	10	Rāma	128	132
986	1	1	76	10	Rāma	169	173
987	1	1	76	11	Rāma	73	77
988	1	1	76	11	Rāma	112	116
989	1	5	76	13	Kākutstha	161	170
990	1	1	76	15	Rāma	2	6
991	1	5	76	18	Kākutstha	7	16
992	1	1	76	19	Rāma	17	21
993	4	17	76	20	Daśaratha	76	85
994	4	17	76	20	Daśaratha	135	144
995	1	1	76	20	Rāma	22	26
996	1	1	76	21	Rāma	34	38
997	1	1	76	22	Rāma	91	95
998	4	17	76	23	Daśaratha	72	81
999	1	1	76	23	Rāma	31	35
1000	1	1	76	23	Rāma	55	59
1001	4	17	77	1	Daśaratha	24	33
1002	1	1	77	1	Rāma	5	9
1003	1	1	77	1	Rāma	57	61
1004	1	1	77	2	Rāma	46	50
1005	4	17	77	4	Daśaratha	27	36
1006	1	4	77	4	Rāghava	79	86
1007	1	1	77	4	Rāma	8	12
1008	1	1	77	4	Rāma	114	118
1009	9	24	77	6	Kausalyā	106	114
1010	10	25	77	6	Kaikeyī	151	158
1011	11	26	77	6	Sumitrā	119	126
1012	2	7	77	7	Sītā	43	47
1013	4	17	77	9	Daśaratha	50	59
1014	7	22	77	9	Bharata	70	77
1015	8	23	77	11	Śatrughna	98	107
1016	4	17	77	11	Daśaratha	23	32
1017	10	25	77	11	Kaikeyī	34	41
1018	7	22	77	11	Bharata	49	56
1019	8	23	77	12	Śatrughna	131	140
1020	7	22	77	12	Bharata	108	115
1021	1	1	77	12	Rāma	31	35
1022	8	23	77	13	Śatrughna	30	39
1023	7	22	77	13	Bharata	11	18
1024	3	12	77	14	Lakṣmaṇa	63	71
1025	7	22	77	14	Bharata	7	14
1026	1	1	77	14	Rāma	31	35
1027	1	1	77	15	Rāma	59	63
1028	4	17	77	17	Daśaratha	0	9
1029	1	1	77	17	Rāma	141	145
1030	4	17	77	18	Daśaratha	105	114
1031	1	1	77	18	Rāma	0	4
1032	2	7	77	19	Sītā	18	22
1033	2	7	77	19	Sītā	59	63
1034	1	1	77	19	Rāma	33	37
1035	2	7	77	20	Sītā	15	19
1036	1	1	77	20	Rāma	0	4
1037	12	27	77	21	Janaka	38	44
1038	1	1	77	22	Rāma	26	30
\.


--
-- Data for Name: character_profiles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.character_profiles (id, character_id, description, background, role, source_url) FROM stdin;
1	1	Rāma is the eldest son of King Daśaratha and the central character of the Ramayana.	Rāma belongs to the Ikṣvāku lineage and is presented as a virtuous, powerful, truthful and dutiful prince. In Bāla-kāṇḍa, his qualities, education, relationship with his family, and early adventures are described.	Prince of Ayodhyā and central protagonist	\N
2	2	Sītā is the daughter of King Janaka and the wife of Rāma.	Sītā is introduced as Janaka’s daughter and becomes Rāma’s wife. Her connection with Rāma is established during the events surrounding the breaking of Śiva’s bow and their marriage.	Princess of Mithilā and wife of Rāma	\N
3	3	Lakṣmaṇa is the younger brother of Rāma and son of Sumitrā.	Lakṣmaṇa is deeply devoted to Rāma. In Bāla-kāṇḍa, he accompanies Rāma during Viśvāmitra’s journey and participates in the protection of the sage’s sacrifice.	Brother and companion of Rāma	\N
4	4	Daśaratha is the king of Ayodhyā and the father of Rāma, Bharata, Lakṣmaṇa and Śatrughna.	Daśaratha rules the kingdom of Ayodhyā and is described as a powerful king. His desire to establish Rāma as his successor and his family relationships are important to the early narrative.	King of Ayodhyā and father of Rāma	\N
5	5	Vālmīki is the sage who asks Nārada about the ideal human being and becomes the narrator of the Ramayana.	At the beginning of Bāla-kāṇḍa, Vālmīki asks Nārada whether there is a person possessing exceptional virtue, courage, truthfulness, knowledge and self-control.	Sage and narrator of the Ramayana	\N
6	6	Nārada is a revered sage who knows the events of the three worlds.	Nārada answers Vālmīki’s question by identifying Rāma as the person possessing the qualities Vālmīki describes. He provides Vālmīki with the essential outline of Rāma’s story.	Sage and source of the story of Rāma	\N
7	7	Bharata is one of the sons of King Daśaratha.	Bharata is introduced as one of Daśaratha’s sons and an important member of the royal family of Ayodhyā.	Son of Daśaratha and brother of Rāma	\N
8	8	Śatrughna is one of the sons of King Daśaratha and the brother of Rāma.	Śatrughna belongs to the royal family of Ayodhyā and is one of Daśaratha’s four sons.	Son of Daśaratha and brother of Rāma	\N
9	9	Kausalyā is one of the queens of King Daśaratha and the mother of Rāma.	Kausalyā is associated with Rāma as his mother and is part of the royal household of Ayodhyā.	Queen of Ayodhyā and mother of Rāma	\N
10	10	Kaikeyī is one of King Daśaratha’s queens and the mother of Bharata.	Kaikeyī is a member of Daśaratha’s royal household and is involved in the succession-related events of the royal family.	Queen of Ayodhyā and mother of Bharata	\N
11	11	Sumitrā is one of King Daśaratha’s queens and the mother of Lakṣmaṇa and Śatrughna.	Sumitrā belongs to the royal family of Ayodhyā and is associated with two of Daśaratha’s sons.	Queen of Ayodhyā and mother of Lakṣmaṇa and Śatrughna	\N
12	12	Janaka is the king of Mithilā and the father of Sītā.	Janaka is associated with Mithilā and plays a major role in the events leading to the marriage of Sītā and Rāma.	King of Mithilā and father of Sītā	\N
13	13	Viśvāmitra is a powerful sage who requests Rāma and Lakṣmaṇa to accompany him.	Viśvāmitra approaches King Daśaratha and asks that Rāma accompany him to protect his sacrifice. This journey becomes one of the major episodes of Bāla-kāṇḍa and leads Rāma into several important encounters.	Sage, teacher and guide of Rāma	\N
14	14	Bharadvāja is a revered sage encountered during the early events of the Ramayana.	Bharadvāja is associated with an important hermitage and appears in the early narrative involving Vālmīki and the development of the Ramayana story.	Sage	\N
15	15	Ikṣvāku is the ancestral figure from whom the royal lineage of Rāma descends.	Rāma is described as being born in the line of Ikṣvāku. The Ikṣvāku lineage is therefore important to Rāma’s royal identity.	Ancestor of the Ikṣvāku royal lineage	\N
16	16	Ṛṣyaśṛṅga is a powerful ascetic and son of Vibhāṇḍaka.	Ṛṣyaśṛṅga is raised in the forest in austerity and Vedic learning. His arrival is connected with rainfall and important events involving King Romapāda.	Ascetic and sage	\N
17	17	Romapāda is a king associated with the story of Ṛṣyaśṛṅga.	Romapāda seeks to bring Ṛṣyaśṛṅga from the forest to his kingdom. The story explains how Ṛṣyaśṛṅga becomes connected with the royal family.	King	\N
18	18	Vibhāṇḍaka is the father of Ṛṣyaśṛṅga.	Vibhāṇḍaka raises Ṛṣyaśṛṅga in the forest and keeps him devoted to austerities and Vedic studies.	Sage and father of Ṛṣyaśṛṅga	\N
19	19	Śāntā is the daughter of King Romapāda.	Śāntā becomes connected with Ṛṣyaśṛṅga when Romapāda receives the ascetic into his kingdom.	Princess and wife of Ṛṣyaśṛṅga	\N
20	20	Indra is the king of the gods in the Ramayana tradition.	Indra appears in the narrative in connection with divine events, including the rain that follows Ṛṣyaśṛṅga’s arrival.	King of the gods	\N
21	21	Kaśyapa is an ancient sage whose lineage is referenced in the narrative.	Kaśyapa is mentioned in connection with the lineage of characters in the early narrative.	Sage and ancestral figure	\N
\.


--
-- Data for Name: characters; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.characters (id, name, description) FROM stdin;
1	Rāma	The central protagonist of the Ramayana and prince of Ayodhya.
2	Sītā	Rāma's wife and daughter of Janaka.
3	Lakṣmaṇa	Rāma's younger brother and devoted companion.
4	Daśaratha	King of Ayodhya and father of Rāma, Lakṣmaṇa, Bharata and Śatrughna.
5	Vālmīki	The sage who narrates and composes the Ramayana.
6	Nārada	The divine sage who relates the story of Rāma to Vālmīki.
7	Bharata	Rāma's younger brother and son of Daśaratha and Kaikeyī.
8	Śatrughna	Rāma's younger brother and son of Daśaratha.
9	Kausalyā	One of Daśaratha's wives and the mother of Rāma.
10	Kaikeyī	One of Daśaratha's wives and the mother of Bharata.
11	Sumitrā	One of Daśaratha's wives and the mother of Lakṣmaṇa and Śatrughna.
12	Janaka	King of Videha and father of Sītā.
13	Viśvāmitra	The sage who becomes an important guide and companion of Rāma and Lakṣmaṇa.
14	Bharadvāja	A sage encountered by Vālmīki in the opening portion of the Ramayana.
15	Ikṣvāku	An ancestor of Rāma and the founder of the Ikṣvāku dynasty.
16	Ṛṣyaśṛṅga	\N
17	Romapāda	\N
18	Vibhāṇḍaka	\N
19	Śāntā	\N
20	Indra	\N
21	Kaśyapa	\N
\.


--
-- Data for Name: sources; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sources (id, title, author, translator, year, language, url) FROM stdin;
2	The Ramayana	Valmiki	Manmatha Nath Dutt	1891	English	https://www.wisdomlib.org/hinduism/book/the-ramayana/d/doc365868.html
\.


--
-- Name: books_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.books_id_seq', 1, true);


--
-- Name: chapter_paragraphs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.chapter_paragraphs_id_seq', 1859, true);


--
-- Name: chapters_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.chapters_id_seq', 77, true);


--
-- Name: character_aliases_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.character_aliases_id_seq', 56, true);


--
-- Name: character_events_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.character_events_id_seq', 81, true);


--
-- Name: character_mentions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.character_mentions_id_seq', 1038, true);


--
-- Name: character_profiles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.character_profiles_id_seq', 21, true);


--
-- Name: characters_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.characters_id_seq', 21, true);


--
-- Name: sources_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.sources_id_seq', 2, true);


--
-- Name: books books_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.books
    ADD CONSTRAINT books_pkey PRIMARY KEY (id);


--
-- Name: chapter_paragraphs chapter_paragraphs_chapter_id_paragraph_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chapter_paragraphs
    ADD CONSTRAINT chapter_paragraphs_chapter_id_paragraph_number_key UNIQUE (chapter_id, paragraph_number);


--
-- Name: chapter_paragraphs chapter_paragraphs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chapter_paragraphs
    ADD CONSTRAINT chapter_paragraphs_pkey PRIMARY KEY (id);


--
-- Name: chapters chapters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chapters
    ADD CONSTRAINT chapters_pkey PRIMARY KEY (id);


--
-- Name: character_aliases character_aliases_character_id_alias_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_aliases
    ADD CONSTRAINT character_aliases_character_id_alias_key UNIQUE (character_id, alias);


--
-- Name: character_aliases character_aliases_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_aliases
    ADD CONSTRAINT character_aliases_pkey PRIMARY KEY (id);


--
-- Name: character_events character_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_events
    ADD CONSTRAINT character_events_pkey PRIMARY KEY (id);


--
-- Name: character_mentions character_mentions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_mentions
    ADD CONSTRAINT character_mentions_pkey PRIMARY KEY (id);


--
-- Name: character_profiles character_profiles_character_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_profiles
    ADD CONSTRAINT character_profiles_character_id_key UNIQUE (character_id);


--
-- Name: character_profiles character_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_profiles
    ADD CONSTRAINT character_profiles_pkey PRIMARY KEY (id);


--
-- Name: characters characters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.characters
    ADD CONSTRAINT characters_pkey PRIMARY KEY (id);


--
-- Name: sources sources_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sources
    ADD CONSTRAINT sources_pkey PRIMARY KEY (id);


--
-- Name: character_mentions_unique_mention; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX character_mentions_unique_mention ON public.character_mentions USING btree (character_id, alias_id, chapter_id, paragraph_number, start_position, end_position);


--
-- Name: books books_source_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.books
    ADD CONSTRAINT books_source_id_fkey FOREIGN KEY (source_id) REFERENCES public.sources(id);


--
-- Name: chapter_paragraphs chapter_paragraphs_chapter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chapter_paragraphs
    ADD CONSTRAINT chapter_paragraphs_chapter_id_fkey FOREIGN KEY (chapter_id) REFERENCES public.chapters(id) ON DELETE CASCADE;


--
-- Name: chapters chapters_book_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chapters
    ADD CONSTRAINT chapters_book_id_fkey FOREIGN KEY (book_id) REFERENCES public.books(id);


--
-- Name: character_aliases character_aliases_character_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_aliases
    ADD CONSTRAINT character_aliases_character_id_fkey FOREIGN KEY (character_id) REFERENCES public.characters(id) ON DELETE CASCADE;


--
-- Name: character_events character_events_chapter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_events
    ADD CONSTRAINT character_events_chapter_id_fkey FOREIGN KEY (chapter_id) REFERENCES public.chapters(id) ON DELETE CASCADE;


--
-- Name: character_events character_events_character_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_events
    ADD CONSTRAINT character_events_character_id_fkey FOREIGN KEY (character_id) REFERENCES public.characters(id) ON DELETE CASCADE;


--
-- Name: character_mentions character_mentions_alias_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_mentions
    ADD CONSTRAINT character_mentions_alias_id_fkey FOREIGN KEY (alias_id) REFERENCES public.character_aliases(id) ON DELETE SET NULL;


--
-- Name: character_mentions character_mentions_chapter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_mentions
    ADD CONSTRAINT character_mentions_chapter_id_fkey FOREIGN KEY (chapter_id) REFERENCES public.chapters(id) ON DELETE CASCADE;


--
-- Name: character_mentions character_mentions_character_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_mentions
    ADD CONSTRAINT character_mentions_character_id_fkey FOREIGN KEY (character_id) REFERENCES public.characters(id) ON DELETE CASCADE;


--
-- Name: character_profiles character_profiles_character_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.character_profiles
    ADD CONSTRAINT character_profiles_character_id_fkey FOREIGN KEY (character_id) REFERENCES public.characters(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict s2fUyASr3p6B0xNf1nMtuX8FC2GlaDGmkbIw2t7OxXmMOylNiUcmJGU4kAW2BlF

