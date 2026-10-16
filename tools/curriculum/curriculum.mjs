// The V1 curriculum plan for the Islam module.
//
// This file is DECLARATIVE: it describes units and lessons, and each lesson
// lists "items" that build.mjs expands into concrete exercises. Item kinds:
//
//   { k: 'authored',    groups: ['taharah.g1', ...], limit: N }
//       Picks N authored MCQs round-robin across the listed groups.
//
//   { k: 'dua', id: '<duaId>', mode: 'askWhich' | 'askWhen' | 'both' }
//       Builds scenario MCQs from the dua dataset.
//
//   { k: 'match', terms: ['wudu', 'ghusl', ...] }         (3+ terms)
//       Builds one matchPairs exercise: Arabic term -> English meaning.
//
//   { k: 'termMeaning', term: '<termId>' }   "What does <term> mean?"
//   { k: 'meaningTerm', term: '<termId>' }   "Which term means <meaning>?"
//
//   { k: 'order', seq: '<sequenceKey>' }
//       Builds one orderSteps exercise from the sequences dataset.
//
// Lesson ids are assigned automatically as `islam.<unitId>.l<n>` and exercise
// ids as `<lessonId>.e<n>`. Keep every lesson >= 3 exercises.

export const MODULE = {
  schemaVersion: 1,
  id: 'islam',
  title: 'Islam',
  tagline: 'Daily worship, one small step at a time',
  description:
    'A gamified micro-course on the daily practice of Islam: purification (taharah), prayer (salah), everyday etiquette (adab), character (akhlaq), and purifying the heart from envy (hasad) and showing off (riya). Content is built from the Quran and authentic hadith.',
  disclaimer:
    'Content review notice: this module summarizes widely accepted Islamic practices from the Quran and hadith collections. Hadith gradings are shown with each exercise and sources are listed in docs/curriculum-sources.md. Reports of scholarly verification are welcome before relying on this app for religious rulings (fiqh) - consult a qualified teacher for detailed questions.',
  assetDir: 'app/assets/modules/islam',
};

export const UNITS = [
  {
    id: 'taharah',
    title: 'Taharah',
    subtitle: 'Purification before worship',
    colorIndex: 0,
    lessons: [
      {
        title: 'What Purity Means',
        items: [
          { k: 'match', terms: ['taharah', 'wudu', 'ghusl', 'tayammum', 'najasah'] },
          { k: 'termMeaning', term: 'wudu' },
          { k: 'meaningTerm', term: 'taharah' },
          { k: 'authored', groups: ['taharah.g1'], limit: 4 },
        ],
      },
      {
        title: 'Wudu Step by Step',
        items: [
          { k: 'order', seq: 'wudu' },
          { k: 'dua', id: 'beforeWudu', mode: 'askWhich' },
          { k: 'dua', id: 'afterWudu', mode: 'askWhich' },
          { k: 'match', terms: ['wudu', 'ghusl', 'miswak', 'fitrah'] },
          { k: 'authored', groups: ['taharah.g2'], limit: 4 },
        ],
      },
      {
        title: 'What Breaks Wudu',
        items: [
          { k: 'authored', groups: ['taharah.g3'], limit: 4 },
          { k: 'match', terms: ['wudu', 'taharah', 'najasah', 'ghusl'] },
          { k: 'termMeaning', term: 'najasah' },
          { k: 'meaningTerm', term: 'ghusl' },
          { k: 'dua', id: 'beforeWudu', mode: 'askWhen' },
        ],
      },
      {
        title: 'Cleanliness Habits',
        items: [
          { k: 'match', terms: ['najasah', 'miswak', 'istinja', 'fitrah'] },
          { k: 'authored', groups: ['taharah.g4'], limit: 4 },
          { k: 'termMeaning', term: 'miswak' },
          { k: 'meaningTerm', term: 'istinja' },
        ],
      },
      {
        title: 'When Water Is Not Found',
        items: [
          { k: 'order', seq: 'tayammum' },
          { k: 'authored', groups: ['taharah.g5'], limit: 4 },
          { k: 'termMeaning', term: 'tayammum' },
          { k: 'dua', id: 'afterWudu', mode: 'askWhen' },
          { k: 'match', terms: ['tayammum', 'ghusl', 'taharah', 'wudu'] },
        ],
      },
      {
        title: 'Taharah Review',
        xp: 15,
        items: [
          {
            k: 'authored',
            groups: ['taharah.g1', 'taharah.g2', 'taharah.g3', 'taharah.g4', 'taharah.g5'],
            limit: 6,
          },
          { k: 'match', terms: ['wudu', 'ghusl', 'tayammum', 'najasah', 'istinja', 'miswak'] },
          { k: 'termMeaning', term: 'taharah' },
          { k: 'dua', id: 'afterWudu', mode: 'askWhich' },
        ],
      },
    ],
  },

  {
    id: 'salah',
    title: 'Salah',
    subtitle: 'The five daily prayers',
    colorIndex: 1,
    lessons: [
      {
        title: 'Why We Pray',
        items: [
          { k: 'match', terms: ['salah', 'khushu', 'qiblah', 'imam'] },
          { k: 'termMeaning', term: 'salah' },
          { k: 'meaningTerm', term: 'salah' },
          { k: 'authored', groups: ['salah.g1'], limit: 4 },
        ],
      },
      {
        title: 'Getting Ready to Pray',
        items: [
          { k: 'order', seq: 'salahPrep' },
          { k: 'authored', groups: ['salah.g2'], limit: 4 },
          { k: 'termMeaning', term: 'khushu' },
          { k: 'meaningTerm', term: 'qiblah' },
        ],
      },
      {
        title: 'The Five Times',
        items: [
          { k: 'order', seq: 'salahTimes' },
          { k: 'authored', groups: ['salah.g3'], limit: 4 },
          { k: 'match', terms: ['salah', 'rakah', 'takbir', 'athan'] },
          { k: 'termMeaning', term: 'athan' },
        ],
      },
      {
        title: 'Inside the Rakah',
        items: [
          { k: 'order', seq: 'rakah' },
          { k: 'authored', groups: ['salah.g4'], limit: 5 },
          { k: 'match', terms: ['rakah', 'takbir', 'sujud', 'ruku'] },
          { k: 'termMeaning', term: 'ruku' },
          { k: 'meaningTerm', term: 'sujud' },
        ],
      },
      {
        title: 'Praying with Focus',
        items: [
          { k: 'authored', groups: ['salah.g5'], limit: 4 },
          { k: 'match', terms: ['khushu', 'salah', 'imam', 'qiblah'] },
          { k: 'termMeaning', term: 'imam' },
          { k: 'meaningTerm', term: 'khushu' },
        ],
      },
      {
        title: 'Salah Review',
        xp: 15,
        items: [
          {
            k: 'authored',
            groups: ['salah.g1', 'salah.g2', 'salah.g3', 'salah.g4', 'salah.g5'],
            limit: 6,
          },
          { k: 'order', seq: 'rakah' },
          { k: 'match', terms: ['salah', 'takbir', 'sujud', 'qiblah', 'khushu', 'athan'] },
        ],
      },
    ],
  },

  {
    id: 'adab',
    title: 'Daily Adab',
    subtitle: 'Etiquette for every day',
    colorIndex: 2,
    lessons: [
      {
        title: 'Living with Bismillah',
        items: [
          { k: 'match', terms: ['dua', 'dhikr', 'bismillah', 'alhamdulillah'] },
          { k: 'termMeaning', term: 'dhikr' },
          { k: 'meaningTerm', term: 'dua' },
          { k: 'authored', groups: ['adab.g1'], limit: 4 },
        ],
      },
      {
        title: 'Waking and Sleeping',
        items: [
          { k: 'dua', id: 'afterWaking', mode: 'askWhich' },
          { k: 'dua', id: 'beforeSleep', mode: 'askWhich' },
          { k: 'order', seq: 'morning' },
          { k: 'authored', groups: ['adab.g2'], limit: 4 },
        ],
      },
      {
        title: 'Eating and Drinking',
        items: [
          { k: 'order', seq: 'eating' },
          { k: 'dua', id: 'beforeEating', mode: 'askWhich' },
          { k: 'dua', id: 'forgotBismillah', mode: 'both' },
          { k: 'dua', id: 'afterEating', mode: 'askWhich' },
          { k: 'authored', groups: ['adab.g3'], limit: 4 },
        ],
      },
      {
        title: 'Mirror, Clothes and Doors',
        items: [
          { k: 'dua', id: 'mirror', mode: 'askWhich' },
          { k: 'dua', id: 'clothes', mode: 'both' },
          { k: 'dua', id: 'leavingHouse', mode: 'askWhich' },
          { k: 'dua', id: 'enteringHouse', mode: 'askWhich' },
          { k: 'order', seq: 'home' },
          { k: 'authored', groups: ['adab.g4'], limit: 4 },
        ],
      },
      {
        title: 'Salaam and Kind Words',
        items: [
          { k: 'match', terms: ['salaam', 'subhanallah', 'athan', 'adab'] },
          { k: 'termMeaning', term: 'salaam' },
          { k: 'termMeaning', term: 'subhanallah' },
          { k: 'meaningTerm', term: 'adab' },
          { k: 'authored', groups: ['adab.g5'], limit: 4 },
        ],
      },
      {
        title: 'Bathroom, Travel and Rain',
        items: [
          { k: 'dua', id: 'enteringBathroom', mode: 'both' },
          { k: 'dua', id: 'leavingBathroom', mode: 'askWhich' },
          { k: 'dua', id: 'vehicle', mode: 'both' },
          { k: 'dua', id: 'rain', mode: 'askWhich' },
          { k: 'dua', id: 'afterSneeze', mode: 'askWhich' },
          { k: 'order', seq: 'sneeze' },
          { k: 'authored', groups: ['adab.g6'], limit: 3 },
        ],
      },
      {
        title: 'Adab Review',
        xp: 15,
        items: [
          {
            k: 'authored',
            groups: ['adab.g1', 'adab.g2', 'adab.g3', 'adab.g4', 'adab.g5', 'adab.g6'],
            limit: 6,
          },
          { k: 'match', terms: ['dua', 'dhikr', 'salaam', 'bismillah', 'alhamdulillah', 'subhanallah'] },
          { k: 'dua', id: 'beforeEating', mode: 'askWhen' },
          { k: 'dua', id: 'forgotBismillah', mode: 'askWhen' },
          { k: 'dua', id: 'afterEating', mode: 'askWhen' },
          { k: 'dua', id: 'beforeSleep', mode: 'askWhen' },
          { k: 'dua', id: 'anger', mode: 'both' },
          { k: 'dua', id: 'seekingKnowledge', mode: 'both' },
        ],
      },
    ],
  },

  {
    id: 'akhlaq',
    title: 'Akhlaq',
    subtitle: 'Character in action',
    colorIndex: 3,
    lessons: [
      {
        title: 'The Weight of Good Character',
        items: [
          { k: 'match', terms: ['birr', 'akhlaq', 'sidq', 'tawadu'] },
          { k: 'termMeaning', term: 'akhlaq' },
          { k: 'meaningTerm', term: 'sidq' },
          { k: 'authored', groups: ['akhlaq.g1'], limit: 4 },
        ],
      },
      {
        title: 'Etiquette with Parents',
        items: [
          { k: 'authored', groups: ['akhlaq.g2'], limit: 4 },
          { k: 'termMeaning', term: 'birr' },
          { k: 'meaningTerm', term: 'tawadu' },
          { k: 'dua', id: 'anger', mode: 'askWhich' },
        ],
      },
      {
        title: 'Family and Elders',
        items: [
          { k: 'authored', groups: ['akhlaq.g3'], limit: 4 },
          { k: 'match', terms: ['birr', 'sidq', 'tawadu', 'salaam'] },
          { k: 'termMeaning', term: 'tawadu' },
        ],
      },
      {
        title: 'Neighbors and Guests',
        items: [
          { k: 'authored', groups: ['akhlaq.g4'], limit: 4 },
          { k: 'match', terms: ['sadaqah', 'ghibah', 'ikhlas', 'sidq'] },
          { k: 'termMeaning', term: 'sadaqah' },
          { k: 'meaningTerm', term: 'ikhlas' },
          { k: 'dua', id: 'beforeEating', mode: 'askWhen' },
        ],
      },
      {
        title: 'Guarding the Tongue',
        items: [
          { k: 'authored', groups: ['akhlaq.g5'], limit: 4 },
          { k: 'termMeaning', term: 'ghibah' },
          { k: 'meaningTerm', term: 'sidq' },
        ],
      },
      {
        title: 'Everyday Life',
        items: [
          { k: 'authored', groups: ['akhlaq.g6'], limit: 5 },
          { k: 'dua', id: 'seekingKnowledge', mode: 'both' },
          { k: 'dua', id: 'anger', mode: 'askWhen' },
          { k: 'termMeaning', term: 'ikhlas' },
        ],
      },
      {
        title: 'Akhlaq Review',
        xp: 15,
        items: [
          {
            k: 'authored',
            groups: ['akhlaq.g1', 'akhlaq.g2', 'akhlaq.g3', 'akhlaq.g4', 'akhlaq.g5', 'akhlaq.g6'],
            limit: 6,
          },
          { k: 'match', terms: ['akhlaq', 'birr', 'sidq', 'tawadu', 'sadaqah', 'ghibah', 'ikhlas'] },
          { k: 'dua', id: 'anger', mode: 'askWhich' },
        ],
      },
    ],
  },

  {
    id: 'hasad',
    title: 'Hasad',
    subtitle: 'Freeing the heart from envy',
    colorIndex: 4,
    lessons: [
      {
        title: 'What Envy Is',
        items: [
          { k: 'match', terms: ['hasad', 'ghibta', 'tazkiyah', 'niyyah'] },
          { k: 'termMeaning', term: 'hasad' },
          { k: 'meaningTerm', term: 'ghibta' },
          { k: 'authored', groups: ['hasad.g1'], limit: 4 },
        ],
      },
      {
        title: 'The Damage of Envy',
        items: [
          { k: 'authored', groups: ['hasad.g2'], limit: 4 },
          { k: 'termMeaning', term: 'ghibta' },
          { k: 'meaningTerm', term: 'hasad' },
          { k: 'match', terms: ['hasad', 'ghibta', 'niyyah', 'ikhlas'] },
        ],
      },
      {
        title: 'Envy in Daily Life',
        items: [
          { k: 'authored', groups: ['hasad.g3'], limit: 4 },
          { k: 'termMeaning', term: 'tazkiyah' },
          { k: 'meaningTerm', term: 'niyyah' },
          { k: 'match', terms: ['tazkiyah', 'hasad', 'ghibta', 'niyyah'] },
        ],
      },
      {
        title: 'The Cure for Envy',
        items: [
          { k: 'authored', groups: ['hasad.g4'], limit: 4 },
          { k: 'match', terms: ['hasad', 'tazkiyah', 'ghibta', 'sidq'] },
          { k: 'termMeaning', term: 'tazkiyah' },
          { k: 'meaningTerm', term: 'hasad' },
        ],
      },
      {
        title: 'Hasad Review',
        xp: 15,
        items: [
          { k: 'authored', groups: ['hasad.g1', 'hasad.g2', 'hasad.g3', 'hasad.g4'], limit: 6 },
          { k: 'match', terms: ['hasad', 'ghibta', 'tazkiyah', 'niyyah', 'ikhlas', 'sidq'] },
          { k: 'dua', id: 'anger', mode: 'askWhich' },
        ],
      },
    ],
  },

  {
    id: 'riya',
    title: 'Riya',
    subtitle: 'Worship for Allah alone',
    colorIndex: 5,
    lessons: [
      {
        title: 'Why Intention Matters',
        items: [
          { k: 'match', terms: ['riya', 'niyyah', 'ikhlas', 'tazkiyah'] },
          { k: 'termMeaning', term: 'riya' },
          { k: 'meaningTerm', term: 'niyyah' },
          { k: 'authored', groups: ['riya.g1'], limit: 4 },
        ],
      },
      {
        title: 'Hidden and Open',
        items: [
          { k: 'authored', groups: ['riya.g2'], limit: 4 },
          { k: 'termMeaning', term: 'ikhlas' },
          { k: 'meaningTerm', term: 'riya' },
          { k: 'match', terms: ['riya', 'ikhlas', 'niyyah', 'sadaqah'] },
        ],
      },
      {
        title: 'The Three Who Were Judged',
        items: [
          { k: 'authored', groups: ['riya.g3'], limit: 4 },
          { k: 'match', terms: ['riya', 'sadaqah', 'ikhlas', 'sidq'] },
          { k: 'termMeaning', term: 'niyyah' },
          { k: 'meaningTerm', term: 'sadaqah' },
        ],
      },
      {
        title: 'Purifying Intention',
        items: [
          { k: 'authored', groups: ['riya.g4'], limit: 4 },
          { k: 'dua', id: 'seekingKnowledge', mode: 'askWhich' },
          { k: 'match', terms: ['riya', 'niyyah', 'ikhlas', 'tazkiyah'] },
          { k: 'termMeaning', term: 'tazkiyah' },
        ],
      },
      {
        title: 'Riya Review',
        xp: 20,
        items: [
          { k: 'authored', groups: ['riya.g1', 'riya.g2', 'riya.g3', 'riya.g4'], limit: 6 },
          { k: 'match', terms: ['niyyah', 'riya', 'ikhlas', 'sadaqah', 'sidq', 'ghibta'] },
          { k: 'dua', id: 'seekingKnowledge', mode: 'askWhen' },
        ],
      },
    ],
  },
];
