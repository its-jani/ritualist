// Arabic -> English vocabulary used by matching exercises and meaning MCQs.
// `unit` only groups the terms thematically; the curriculum plan decides which
// lesson actually uses each term.
export const TERMS = [
  // --- Taharah (purification) ---
  { id: 'taharah', arabic: 'طَهَارَة', translit: 'taharah', meaning: 'Purification / purity', unit: 'taharah' },
  { id: 'wudu', arabic: 'وُضُوء', translit: 'wudu', meaning: 'Ablution (washing before prayer)', unit: 'taharah' },
  { id: 'ghusl', arabic: 'غُسْل', translit: 'ghusl', meaning: 'Full-body ritual bath', unit: 'taharah' },
  { id: 'tayammum', arabic: 'تَيَمُّم', translit: 'tayammum', meaning: 'Dry purification using clean earth', unit: 'taharah' },
  { id: 'najasah', arabic: 'نَجَاسَة', translit: 'najasah', meaning: 'Ritual impurity (something najis)', unit: 'taharah' },
  { id: 'miswak', arabic: 'سِوَاك', translit: 'miswak', meaning: 'A natural tooth-cleaning stick', unit: 'taharah' },
  { id: 'istinja', arabic: 'اِسْتِنْجَاء', translit: 'istinja', meaning: 'Cleaning oneself after relieving', unit: 'taharah' },
  { id: 'fitrah', arabic: 'فِطْرَة', translit: 'fitrah', meaning: 'Natural human disposition', unit: 'taharah' },

  // --- Salah (prayer) ---
  { id: 'salah', arabic: 'صَلَاة', translit: 'salah', meaning: 'The ritual prayer', unit: 'salah' },
  { id: 'rakah', arabic: 'رَكْعَة', translit: 'rak\u2019ah', meaning: 'One unit of the prayer', unit: 'salah' },
  { id: 'takbir', arabic: 'تَكْبِير', translit: 'takbir', meaning: 'Saying "Allahu Akbar"', unit: 'salah' },
  { id: 'qiblah', arabic: 'قِبْلَة', translit: 'qiblah', meaning: 'The direction of the Ka\u2019bah', unit: 'salah' },
  { id: 'khushu', arabic: 'خُشُوع', translit: 'khushu\u2019', meaning: 'Humble, focused presence in prayer', unit: 'salah' },
  { id: 'sujud', arabic: 'سُجُود', translit: 'sujud', meaning: 'Prostration', unit: 'salah' },
  { id: 'ruku', arabic: 'رُكُوع', translit: 'ruku\u2019', meaning: 'Bowing in prayer', unit: 'salah' },
  { id: 'athan', arabic: 'أَذَان', translit: 'athan', meaning: 'The call to prayer', unit: 'salah' },
  { id: 'imam', arabic: 'إِمَام', translit: 'imam', meaning: 'The one who leads the prayer', unit: 'salah' },

  // --- Daily adab ---
  { id: 'adab', arabic: 'أَدَب', translit: 'adab', meaning: 'Etiquette and good manners', unit: 'adab' },
  { id: 'dua', arabic: 'دُعَاء', translit: 'du\u2019a', meaning: 'Supplication / calling upon Allah', unit: 'adab' },
  { id: 'dhikr', arabic: 'ذِكْر', translit: 'dhikr', meaning: 'Remembrance of Allah', unit: 'adab' },
  { id: 'bismillah', arabic: 'بِسْمِ اللَّه', translit: 'bismillah', meaning: 'Saying "In the name of Allah"', unit: 'adab' },
  { id: 'alhamdulillah', arabic: 'الْحَمْدُ لِلَّه', translit: 'alhamdulillah', meaning: 'Saying "All praise is for Allah"', unit: 'adab' },
  { id: 'subhanallah', arabic: 'سُبْحَانَ اللَّه', translit: 'subhanallah', meaning: 'Saying "Glory be to Allah"', unit: 'adab' },
  { id: 'salaam', arabic: 'سَلَام', translit: 'salaam', meaning: 'The greeting of peace', unit: 'adab' },

  // --- Akhlaq (character) ---
  { id: 'akhlaq', arabic: 'أَخْلَاق', translit: 'akhlaq', meaning: 'Character and moral conduct', unit: 'akhlaq' },
  { id: 'birr', arabic: 'بِرّ', translit: 'birr', meaning: 'Kindness and devotion to parents', unit: 'akhlaq' },
  { id: 'sidq', arabic: 'صِدْق', translit: 'sidq', meaning: 'Truthfulness', unit: 'akhlaq' },
  { id: 'tawadu', arabic: 'تَوَاضُع', translit: 'tawadu\u2019', meaning: 'Humility', unit: 'akhlaq' },
  { id: 'sadaqah', arabic: 'صَدَقَة', translit: 'sadaqah', meaning: 'Charity given for Allah\u2019s sake', unit: 'akhlaq' },
  { id: 'ghibah', arabic: 'غِيبَة', translit: 'ghibah', meaning: 'Backbiting (saying what a person dislikes)', unit: 'akhlaq' },
  { id: 'ikhlas', arabic: 'إِخْلَاص', translit: 'ikhlas', meaning: 'Sincere devotion, purely for Allah', unit: 'akhlaq' },

  // --- Tazkiyah (heart-work) ---
  { id: 'tazkiyah', arabic: 'تَزْكِيَة', translit: 'tazkiyah', meaning: 'Purification of the self and heart', unit: 'tazkiyah' },
  { id: 'hasad', arabic: 'حَسَد', translit: 'hasad', meaning: 'Envy (resenting someone\u2019s blessing)', unit: 'tazkiyah' },
  { id: 'ghibta', arabic: 'غِبْطَة', translit: 'ghibta', meaning: 'Benign wish for a similar blessing (without wanting it removed)', unit: 'tazkiyah' },
  { id: 'riya', arabic: 'رِيَاء', translit: 'riya', meaning: 'Showing off in worship or good deeds', unit: 'tazkiyah' },
  { id: 'niyyah', arabic: 'نِيَّة', translit: 'niyyah', meaning: 'Intention', unit: 'tazkiyah' },
];

export function termById(id) {
  const term = TERMS.find((t) => t.id === id);
  if (!term) throw new Error(`Unknown term id: ${id}`);
  return term;
}
