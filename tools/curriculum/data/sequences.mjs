// Ordered-procedure datasets used by "order steps" exercises.
//
// Steps MUST be listed in their CORRECT order - the engine shuffles them for
// display (deterministically, seeded by exercise id). `prompt`/`explanation`/
// `src` are copied verbatim onto the generated exercise. Every sequence needs
// at least 3 steps with unique texts (engine content rule).
//
// Sources follow the V1 policy: exact hadith numbers only where verified,
// otherwise collection + book name; `grading` is stated whenever relevant.

import { s } from './helpers.mjs';

export const SEQUENCES = {
  'wudu': {
    unit: 'taharah',
    title: 'Steps of Wudu',
    prompt: 'Arrange the steps of wudu in the correct order.',
    explanation:
      'Wudu follows the order the Quran and the Prophet (peace be upon him) described: hands, mouth, nose, face, forearms, head, ears, feet.',
    steps: [
      'Make the intention and say "Bismillah"',
      'Wash both hands up to the wrists three times',
      'Rinse the mouth (madmadah) three times',
      'Rinse the nose (istinshaq) three times',
      'Wash the face three times',
      'Wash the forearms up to the elbows three times',
      'Wipe the head once with wet hands',
      'Wipe the ears once',
      'Wash the feet up to the ankles three times',
    ],
    src: s(
      'Sahih al-Bukhari',
      '159',
      'sahih',
      'Uthman ibn Affan called for water and performed ablution, washing each part three times, then said: "I saw the Messenger of Allah perform ablution like this."',
    ),
  },

  'tayammum': {
    unit: 'taharah',
    title: 'Steps of Tayammum',
    prompt: 'Arrange the steps of tayammum in the correct order.',
    explanation:
      'Tayammum replaces wudu or ghusl when water is unavailable or harmful: one strike of clean earth, then wipe the face and the hands.',
    steps: [
      'Make the intention and say "Bismillah"',
      'Strike clean earth lightly with both palms',
      'Wipe the face once',
      'Wipe the backs of the hands up to the wrists',
    ],
    src: s(
      'Qur\u2019an',
      '5:6',
      null,
      'If you are ill or on a journey... and you do not find water, then strike clean earth and wipe your faces and hands with it.',
    ),
  },

  'salahPrep': {
    unit: 'salah',
    title: 'Getting Ready for Prayer',
    prompt: 'Arrange the steps of preparing for prayer in the correct order.',
    explanation:
      'Before prayer: purify your body, clothes and place, perform wudu, face the qiblah, make the intention in your heart, then begin with the takbir.',
    steps: [
      'Make sure your body, clothes and place of prayer are clean',
      'Perform wudu',
      'Face the qiblah',
      'Make the intention (niyyah) in your heart',
      'Raise your hands and say the opening takbir',
      'Begin reciting al-Fatihah',
    ],
    src: s(
      'Qur\u2019an',
      '5:6',
      null,
      'O you who believe, when you rise to pray, wash your faces and your forearms to the elbows, wipe over your heads and wash your feet to the ankles.',
    ),
  },

  'salahTimes': {
    unit: 'salah',
    title: 'The Five Prayer Times',
    prompt: 'Put the five daily prayers in time order, starting with the first.',
    explanation:
      'Allah fixed five prayers across the day: Fajr at dawn, Dhuhr after midday, Asr in the afternoon, Maghrib just after sunset, and Isha at night.',
    steps: [
      'Fajr - at dawn, before sunrise',
      'Dhuhr - just after midday',
      'Asr - in the afternoon',
      'Maghrib - just after sunset',
      'Isha - at night',
    ],
    src: s(
      'Qur\u2019an',
      '4:103',
      null,
      'Indeed, prayer has been decreed upon the believers at specified times.',
    ),
  },

  'rakah': {
    unit: 'salah',
    title: 'What Happens in a Rakah',
    prompt: 'Arrange what happens inside one rakah in the correct order.',
    explanation:
      'The Prophet taught the steps of a rakah: takbir, reciting al-Fatihah and a short surah, bowing, rising, then two prostrations with a sitting between them.',
    steps: [
      'Say "Allahu Akbar" to begin',
      'Recite Surah al-Fatihah',
      'Recite a short surah (in the first two rakahs)',
      'Bow in ruku saying "Subhana Rabbiyal-Azim"',
      'Rise saying "Sami Allahu liman hamidah"',
      'Prostrate in sujud saying "Subhana Rabbiyal-Ala"',
      'Sit up between the two prostrations',
      'Make the second prostration',
    ],
    src: s(
      'Sahih Muslim',
      '397',
      'sahih',
      'The Prophet taught the man who prayed badly: when you stand for prayer say the takbir, then recite, then bow until at rest, then rise, then prostrate until at rest...',
    ),
  },

  'morning': {
    unit: 'adab',
    title: 'A Morning Routine',
    prompt: 'Arrange the start of a Muslim day in the correct order.',
    explanation:
      'The day starts with the waking dua, washing the hands before touching water, wudu with its dua, then dressing and dhikr.',
    steps: [
      'Say the waking dua: "Alhamdulillahi alladhi ahyana..."',
      'Wash your hands three times before touching the water',
      'Perform wudu',
      'Say the shahada dua after wudu',
      'Get dressed saying the clothing dua',
      'Start the day with Bismillah and dhikr',
    ],
    src: s(
      'Sahih al-Bukhari',
      '6312, 162',
      'sahih',
      'When the Prophet woke he would say: "All praise is for Allah who gave us life after death, and to Him is the return." He also said: when one of you wakes, let him not dip his hands in the vessel until he washes them three times.',
    ),
  },

  'eating': {
    unit: 'adab',
    title: 'Etiquette of Eating',
    prompt: 'Arrange the etiquette of a meal in the correct order.',
    explanation:
      'The Prophet taught the young boy: say Bismillah, eat with your right hand, eat from what is in front of you, and praise Allah when you finish.',
    steps: [
      'Say "Bismillah"',
      'Eat with your right hand',
      'Eat from the food closest to you',
      'Say "Alhamdulillah" when you finish',
    ],
    src: s(
      'Sahih al-Bukhari',
      '5376',
      'sahih',
      'The Prophet said to me: "O young man, say Bismillah, eat with your right hand, and eat from what is in front of you."',
    ),
  },

  'sneeze': {
    unit: 'adab',
    title: 'The Sneeze Exchange',
    prompt: 'Arrange the sneeze exchange in the correct order.',
    explanation:
      'The sneezer praises Allah, the one who hears replies with a dua of mercy, and the sneezer answers with a dua of guidance.',
    steps: [
      'The sneezer says "Alhamdulillah"',
      'The companion replies "Yarhamukallah"',
      'The sneezer answers "Yahdikumullahu wa yuslihu balakum"',
    ],
    src: s(
      'Sahih al-Bukhari',
      '6224',
      'sahih',
      'When one of you sneezes, let him say Alhamdulillah, and let his companion say Yarhamukallah; the sneezer then replies: Yahdikumullahu wa yuslihu balakum.',
    ),
  },

  'home': {
    unit: 'adab',
    title: 'Coming Home',
    prompt: 'Arrange the etiquette of arriving home in the correct order.',
    explanation:
      'When you return home: say the dua for entering, greet your household with salaam, and begin eating with Bismillah.',
    steps: [
      'Say the entering dua: "Bismillahi walajna..."',
      'Give salaam to the household',
      'Say "Bismillah" before eating',
    ],
    src: s(
      'Sunan Abu Dawud',
      '5096',
      'hasan',
      'When the Prophet entered his home he would say: "In the name of Allah we enter and in the name of Allah we leave, and upon our Lord we depend."',
    ),
  },
};
