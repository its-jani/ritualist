// Authored scenario MCQs - part A: Taharah + Salah.
//
// Groups are keyed `<unit>.g<n>` and referenced by name from curriculum.mjs
// lesson plans ({kind:'authored', groups:[...], limit:N}). Exercise ids are
// assigned by build.mjs as `<group>.q<n>`, options are shuffled there with the
// correct option always recoverable (correct is listed FIRST here).

import { q, s } from './helpers.mjs';

const BUKHARI = 'Sahih al-Bukhari';
const MUSLIM = 'Sahih Muslim';
const ABU_DAWUD = 'Sunan Abu Dawud';
const QURAN = 'Qur\u2019an';

export const GROUPS = {
  // ---------------------------------------------------------------- Taharah
  'taharah.g1': {
    unit: 'taharah',
    title: 'Why purity matters',
    items: [
      q(
        'The Prophet called cleanliness "half of faith". What does that mean for daily life?',
        'Keeping body, clothes and surroundings clean is a major part of the religion',
        [
          'Only clothes must be clean before prayer',
          'Cleanliness matters only inside a mosque',
          'Washing more than three times is always better',
        ],
        'Taharah is not a formality - it is worship itself: the same care you give your body is counted as faith.',
        s(MUSLIM, '223', 'sahih', 'Cleanliness is half of faith.'),
      ),
      q(
        'What is taharah about?',
        'Being clean and free from anything that blocks valid worship',
        [
          'Looking presentable for other people',
          'Avoiding all contact with dust and soil',
          'Keeping only the face and hands clean',
        ],
        'Taharah means ritual purity: removing impurity (najasah) and the state that wudu or ghusl fixes.',
        s(QURAN, '74:4', null, 'And purify your clothing.'),
      ),
      q(
        'When does wudu matter most?',
        'Before the ritual prayer and when handling the Quran (per most scholars)',
        ['Only on Fridays', 'Only inside the mosque', 'Only during Ramadan'],
        'Allah commands wudu when you rise to pray: purity is the gateway to standing before Him.',
        s(QURAN, '5:6', null, 'O you who believe, when you rise to pray, wash your faces and your forearms to the elbows.'),
      ),
      q(
        'Your shirt has a small stain of urine from a child you carried. What is the ruling mindset?',
        'Treat it as najasah - clean the area before praying in it',
        ['Ignore it, it will dry out', 'Burn the shirt', 'Only clean it on Fridays'],
        'Najasah is ritual impurity; cleaning it is required before prayer is valid in that garment.',
        s(BUKHARI, 'Book of Wudu (Kitab al-Wudu)', 'sahih', 'The Prophet washed the urine of a child with water.'),
      ),
    ],
  },

  'taharah.g2': {
    unit: 'taharah',
    title: 'Wudu step by step',
    items: [
      q(
        'How many times did the Prophet commonly wash each limb in wudu?',
        'Three times',
        ['Exactly once', 'Seven times', 'As many times as possible'],
        'Uthman described the Prophet\u2019s wudu washing each part three times - the middle path of the Sunnah.',
        s(BUKHARI, '159', 'sahih', 'Uthman performed ablution washing each part three times, then said: I saw the Messenger of Allah perform ablution like this.'),
      ),
      q(
        'What must accompany your first movement of wudu?',
        'The intention (niyyah) in the heart',
        ['A spoken announcement to others', 'Reciting a full surah', 'Raising both hands like the takbir'],
        'Wudu is an act of worship, and worship is judged by the intention - no announcement needed.',
        s(BUKHARI, '1', 'sahih', 'Actions are only judged by intentions.'),
      ),
      q(
        'What is said at the start of wudu?',
        '"Bismillah"',
        ['"Alhamdulillah"', '"Subhanallah"', 'Nothing is said at all'],
        'Beginning with Allah\u2019s name is a small habit with a big reward attached to wudu.',
        s(ABU_DAWUD, '101', 'hasan', 'There is no wudu for the one who does not mention the name of Allah upon it.'),
      ),
      q(
        'Which parts are wiped with wet hands rather than washed?',
        'The head and the ears',
        ['The face and the chin', 'The forearms and elbows', 'The feet and ankles'],
        'The Quran orders washing for the face, arms and feet, and wiping (mas-h) for the head; the ears share the head\u2019s ruling.',
        s(QURAN, '5:6', null, 'Wash your faces and your forearms to the elbows, wipe over your heads, and wash your feet to the ankles.'),
      ),
      q(
        'What did the Prophet say after finishing wudu?',
        'The shahada dua - and the eight gates of Paradise open for it',
        ['"Ghufranak"', '"Yarhamukallah"', 'Nothing is said after wudu'],
        'The shahada dua after wudu is the full-circle moment: purification ends with a testimony of faith.',
        s(MUSLIM, '234', 'sahih', 'Whoever performs wudu and says the shahada, the eight gates of Paradise are opened for him.'),
      ),
    ],
  },

  'taharah.g3': {
    unit: 'taharah',
    title: 'What breaks wudu',
    items: [
      q(
        'Which of these breaks wudu?',
        'Using the toilet',
        ['Eating a light snack', 'Shaking someone\u2019s hand', 'Washing your hands'],
        'Anything exiting from the front or back passage breaks wudu - the classic case is using the toilet.',
        s(BUKHARI, 'Book of Wudu (Kitab al-Wudu)', 'sahih', 'Wudu is broken by what exits from the two passages.'),
      ),
      q(
        'You feel a faint sensation after praying but are 90% sure it is nothing. What do you rely on?',
        'Certainty - wudu stays valid until breaking it is certain',
        ['You repeat wudu every time you doubt', 'You ask a scholar online', 'You skip that prayer'],
        'Doubt does not break certainty: the Prophet said one should not leave prayer for a mere doubt until hearing a sound or smelling an odor.',
        s(BUKHARI, 'Book of Wudu (Kitab al-Wudu)', 'sahih', 'He should not leave (the prayer) until he hears a sound or smells an odor.'),
      ),
      q(
        'Which of these does NOT break wudu?',
        'Washing your hands for a meal',
        ['Using the toilet', 'Passing wind', 'Deep sleep lying down'],
        'Wudu breaks by what leaves the body or by losing awareness in deep sleep - simple washing never breaks it.',
        s(BUKHARI, 'Book of Wudu (Kitab al-Wudu)', 'sahih', 'The Prophet distinguished acts that require renewal of wudu from ordinary daily actions.'),
      ),
      q(
        'Why does deep sleep while lying down break wudu, while light dozing while seated may not?',
        'Because full awareness of bodily control is lost',
        ['Because sleep is a sin', 'Because lying down is always impure', 'Because the bed may be dirty'],
        'The issue is not sleep itself but awareness: deep sleep while lying down removes the certainty needed for wudu\u2019s validity.',
        s(BUKHARI, 'Book of Wudu (Kitab al-Wudu)', 'sahih', 'The Companions waited for the Prophet to wake for prayer; deep sleep was treated as breaking wudu.'),
      ),
    ],
  },

  'taharah.g4': {
    unit: 'taharah',
    title: 'Cleanliness habits',
    items: [
      q(
        'Why did the Prophet stress the miswak so much?',
        'It cleans the mouth that remembers Allah and recites His book',
        ['It replaces wudu', 'It is required before every meal', 'It is only for elders'],
        'The Prophet wished he could make the miswak obligatory at every prayer - purity of the mouth is worship hygiene.',
        s(BUKHARI, '887', 'sahih', 'Were it not that I would burden my community, I would have ordered them to use the miswak with every prayer.'),
      ),
      q(
        'What is istinja?',
        'Cleaning yourself with water after using the toilet',
        ['Washing the face before prayer', 'A type of voluntary fast', 'Sprinkling water on the floor'],
        'Istinja is basic dignity hygiene and was practiced by the Prophet - it removes impurity right at its source.',
        s(BUKHARI, 'Book of Wudu (Kitab al-Wudu)', 'sahih', 'The Prophet used water for istinja and taught the Companions to do so.'),
      ),
      q(
        'Which habits did the Prophet list as part of the natural fitrah?',
        'Trimming the moustache, cleaning after the toilet, cutting nails and using the siwak',
        ['Wearing perfume daily', 'Fasting every Monday', 'Sleeping before sunset'],
        'These are the everyday hygiene habits of the fitrah - Islam builds cleanliness into routine.',
        s(MUSLIM, 'Book of Purification (Kitab al-Taharah)', 'sahih', 'The fitrah includes clipping the moustache, trimming nails and cleaning the private parts with water.'),
      ),
      q(
        'You are travelling with no water after using the toilet. What do you do?',
        'Clean yourself with whatever pure dry material is available until the impurity is gone',
        ['Leave it until you find water days later', 'Use any liquid including juice', 'Skip istinja completely'],
        'Impurity must be removed; where water is unavailable, clean dry material serves the purpose, and tayammum covers the wudu need.',
        s(ABU_DAWUD, 'Book of Purification (Kitab al-Taharah)', 'sahih', 'The Prophet allowed cleaning with stones (dry material) when water was scarce.'),
      ),
    ],
  },

  'taharah.g5': {
    unit: 'taharah',
    title: 'When water is not found',
    items: [
      q(
        'When is tayammum allowed?',
        'When water is unavailable or unusable, or illness makes using it harmful',
        ['Whenever it is faster than wudu', 'Only in desert countries', 'Only during Hajj'],
        'Tayammum is Allah\u2019s concession: no one is trapped without a path to prayer.',
        s(QURAN, '5:6', null, 'If you are ill or on a journey... and you do not find water, then strike clean earth and wipe your faces and hands with it.'),
      ),
      q(
        'What do you strike for tayammum?',
        'Clean earth or a dusty, pure surface',
        ['Your clothes', 'A painted wall', 'A wet towel'],
        'The Quran says "clean earth (sa\u2019id tayyib)" - any natural pure dusty surface works.',
        s(QURAN, '5:6', null, 'Then strike clean earth and wipe your faces and hands with it.'),
      ),
      q(
        'Which parts are wiped in tayammum?',
        'The face and the hands',
        ['The head and the feet', 'The hands only', 'The arms up to the elbows'],
        'One strike, two wipes: the face and the hands - simpler than wudu, same purpose.',
        s(QURAN, '5:6', null, 'Wipe your faces and hands with it.'),
      ),
      q(
        'When is ghusl required?',
        'In states of major impurity, such as after a wet dream or after a woman\u2019s menses end',
        ['Every Friday morning', 'Before every prayer', 'Whenever you feel tired'],
        'Ghusl is the full purifying bath for major impurity - and Islam makes it accessible: the Quran\u2019s command is followed by the concession of tayammum when water is not usable.',
        s(QURAN, '5:6', null, 'If you are in a state of major impurity, purify yourselves; but if you are ill or... do not find water, then strike clean earth.'),
      ),
    ],
  },

  // ------------------------------------------------------------------ Salah
  'salah.g1': {
    unit: 'salah',
    title: 'Why prayer',
    items: [
      q(
        'What is salah?',
        'The five daily ritual prayers performed at fixed times',
        ['Any personal dua made during the day', 'A weekly community gathering', 'A type of charity (sadaqah)'],
        'Salah is the second pillar of Islam - structured worship at fixed times, not an optional extra.',
        s(QURAN, '4:103', null, 'Indeed, prayer has been decreed upon the believers at specified times.'),
      ),
      q(
        'How many fard prayers are there each day?',
        'Five',
        ['Three', 'Seven', 'Two'],
        'Fajr, Dhuhr, Asr, Maghrib and Isha - five anchors that structure the whole day.',
        s(QURAN, '4:103', null, 'Prayer has been decreed upon the believers at specified times.'),
      ),
      q(
        'What is khushu?',
        'Presence of heart and humility during prayer',
        ['Praying as fast as possible', 'Raising the voice so others hear', 'Praying only in a congregation'],
        'The Quran opens Surah al-Mu\u2019minun with the successful believers - those humble in their prayer.',
        s(QURAN, '23:2', null, 'Those who are humble in their prayer.'),
      ),
      q(
        'Which pillar of Islam is the one that immediately follows the testimony of faith?',
        'Prayer',
        ['Fasting Ramadan', 'Zakat', 'Hajj'],
        'The Prophet built Islam on five: shahada, prayer, zakat, fasting and Hajj - prayer comes first after belief.',
        s(BUKHARI, '8', 'sahih', 'Islam is built upon five: the testimony of faith, the prayer, zakat, the fast of Ramadan and the pilgrimage.'),
      ),
    ],
  },

  'salah.g2': {
    unit: 'salah',
    title: 'Getting ready to pray',
    items: [
      q(
        'Which three things must be clean before you point your prayer mat toward the qiblah?',
        'Body, clothes and place of prayer',
        ['Only your face and hands', 'Only the prayer mat', 'Only your clothes'],
        'Purification covers the person, the garment and the ground - the earth itself is a place of purification for the ummah.',
        s(BUKHARI, '335', 'sahih', 'The earth has been made for me a place of worship and a means of purification.'),
      ),
      q(
        'Which direction do Muslims face in prayer?',
        'Toward the Ka\u2019bah in Makkah - the qiblah',
        ['Toward the sunrise', 'Toward the nearest mosque', 'Toward al-Aqsa in every city'],
        'Allah commanded the turning to al-Masjid al-Haram; every mosque\u2019s mihrab marks that direction.',
        s(QURAN, '2:144', null, 'So turn your face toward al-Masjid al-Haram; wherever you are, turn your faces toward it.'),
      ),
      q(
        'Where does the niyyah (intention) of prayer live?',
        'In the heart',
        ['In the words announced out loud', 'In a written note', 'In the raised hands'],
        'The intention is the heart\u2019s orientation - the Prophet and his Companions never announced it aloud.',
        s(BUKHARI, '1', 'sahih', 'Actions are only judged by intentions, and every person will have what he intended.'),
      ),
      q(
        'You are praying behind an imam. When do you move?',
        'You follow the imam - never moving before him',
        ['Half a second before him to be ready', 'Whenever you finish your own recitation', 'Only on the final salam'],
        'The imam is appointed to be followed: you say takbir after his takbir, bow after he bows.',
        s(BUKHARI, '722', 'sahih', 'The imam is to be followed: say the takbir when he says it, bow when he bows, prostrate when he prostrates.'),
      ),
    ],
  },

  'salah.g3': {
    unit: 'salah',
    title: 'The five times',
    items: [
      q(
        'Which prayer comes at dawn, before sunrise?',
        'Fajr',
        ['Isha', 'Dhuhr', 'Maghrib'],
        'The Quran calls it the recitation of dawn - witnessed by angels as the day opens.',
        s(QURAN, '17:78', null, 'Establish prayer at the decline of the sun until the darkness of night, and the recitation of dawn - indeed it is witnessed.'),
      ),
      q(
        'Which prayer comes just after midday?',
        'Dhuhr',
        ['Asr', 'Fajr', 'Isha'],
        'The working day pauses: Dhuhr is established when the sun passes its highest point.',
        s(QURAN, '17:78', null, 'Establish prayer at the decline of the sun.'),
      ),
      q(
        'What did the Prophet compare the five daily prayers to?',
        'A river at your door, washing away dirt five times a day',
        ['A mountain of gold', 'A journey around the world', 'A locked vault'],
        'The river simile makes the math easy: sins wash off as the prayer-cycle repeats.',
        s(BUKHARI, '528', 'sahih', 'If there was a river at your door and you bathed in it five times a day, would any dirt remain? That is the case with the five prayers.'),
      ),
      q(
        'You oversleep and miss Asr entirely. What should you do?',
        'Pray it as soon as you remember',
        ['Wait for next year\u2019s same day', 'Never speak of it', 'Pay charity instead'],
        'Missing a prayer through sleep or forgetfulness is prayed the moment it is remembered - no penalty beyond that.',
        s(MUSLIM, '684', 'sahih', 'Whoever forgets a prayer or sleeps through it, let him pray it when he remembers it.'),
      ),
    ],
  },

  'salah.g4': {
    unit: 'salah',
    title: 'Inside the rakah',
    items: [
      q(
        'What begins the prayer?',
        'The opening takbir - "Allahu Akbar"',
        ['Reciting al-Fatihah', 'The first ruku', 'The final salam'],
        'The takbir marks the boundary: before it you move freely, after it you are standing before Allah.',
        s(MUSLIM, '397', 'sahih', 'When you stand for prayer, say the takbir, then recite...'),
      ),
      q(
        'Which surah is recited in every single rakah?',
        'Surah al-Fatihah',
        ['Surah al-Ikhlas', 'Surah Yasin', 'Any surah chosen freely instead'],
        'There is no prayer for the one who does not recite the Opening of the Book - al-Fatihah is the heartbeat of every rakah.',
        s(BUKHARI, '756', 'sahih', 'There is no prayer for the one who does not recite the Opening of the Book (al-Fatihah).'),
      ),
      q(
        'What is said while bowing (ruku)?',
        '"Subhana Rabbiyal-Azim"',
        ['"Subhana Rabbiyal-Ala" (that is for sujud)', '"Allahu Akbar"', '"Sami Allahu liman hamidah"'],
        'Ruku glorifies Allah as the Supreme One; sujud glorifies Him as the Most High - each posture has its own words.',
        s(MUSLIM, '397', 'sahih', 'The Prophet bowed saying: Glory to my Lord the Supreme.'),
      ),
      q(
        'What is said while prostrating (sujud)?',
        '"Subhana Rabbiyal-Ala"',
        ['"Subhana Rabbiyal-Azim"', 'The shahada', '"Rabbi zidni ilma"'],
        'Sujud is the closest a servant comes to Allah - and the words glorify Him as the Most High.',
        s(MUSLIM, '482', 'sahih', 'The Prophet prostrated saying: Glory to my Lord the Most High.'),
      ),
      q(
        'What concludes the prayer?',
        'The salam - turning to the right and left: "As-salamu alaykum wa rahmatullah"',
        ['Raising both hands', 'Saying "Amin" loudly', 'Standing up immediately'],
        'As the takbir opens the prayer, the taslim closes it - peace spoken to the sides and to the angels.',
        s(ABU_DAWUD, '61', 'hasan (per some scholars)', 'The key of the prayer is purification, its opening is the takbir, and its closing is the taslim.'),
      ),
    ],
  },

  'salah.g5': {
    unit: 'salah',
    title: 'Praying with focus',
    items: [
      q(
        'Your mind wanders mid-prayer. What is the first practical step?',
        'Return your attention to the words you are saying',
        ['Restart the prayer from zero each time', 'Pray faster to finish sooner', 'Abandon the prayer'],
        'Khushu is a practice of returning - awareness drifts, and the trained heart brings it back to the words.',
        s(QURAN, '23:2', null, 'Those who are humble and focused in their prayer.'),
      ),
      q(
        'What did the Prophet say about a prayer rushed without its essential parts?',
        'It is not accepted as a proper prayer - he made the man repeat it',
        ['It counts fully anyway', 'It counts as half', 'It only needs repeating on Fridays'],
        'The man who prayed badly was taught the full sequence - rushing strips a prayer to the bone.',
        s(MUSLIM, '397', 'sahih', 'The Prophet made the man who rushed his prayer repeat it, and taught him each part until he did it properly.'),
      ),
      q(
        'Standing hurts because of illness. What does the Sunnah allow?',
        'Pray sitting, and if you cannot, then lying on your side',
        ['Pray only when you recover', 'Pray with a shortened Fatihah standing', 'Have someone pray in your place'],
        'Islam is ease: the Prophet\u2019s guidance adapts prayer to ability rather than dropping it.',
        s(BUKHARI, '1117', 'sahih', 'Pray standing; if you cannot, then sitting; if you cannot, then lying on your side.'),
      ),
      q(
        'What builds khushu over time?',
        'Praying on time and learning the meaning of what you recite',
        ['Praying as late as possible to feel urgency', 'Memorizing long surahs for display', 'Praying only when motivated'],
        'Focus grows from familiarity: a mind that understands the words wanders less.',
        s(QURAN, '4:103', null, 'Prayer is decreed at specified times - punctuality trains the heart.'),
      ),
    ],
  },
};
