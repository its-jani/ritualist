// Authored scenario MCQs - part B: Daily Adab + Akhlaq (character).
// Same conventions as principles_a.mjs (see header there).

import { q, s } from './helpers.mjs';

const BUKHARI = 'Sahih al-Bukhari';
const MUSLIM = 'Sahih Muslim';
const ABU_DAWUD = 'Sunan Abu Dawud';
const TIRMIDHI = 'Jami\u2019 at-Tirmidhi';
const QURAN = 'Qur\u2019an';

export const GROUPS = {
  // ------------------------------------------------------------------- Adab
  'adab.g1': {
    unit: 'adab',
    title: 'Bismillah and dhikr',
    items: [
      q(
        'What does "Bismillah" mean?',
        'In the name of Allah',
        ['All praise is for Allah', 'Glory be to Allah', 'Allah is the greatest'],
        'The basmalah opens the Quran and every good act: it names the One whose help is being sought.',
        s(QURAN, '27:30', null, 'Indeed, it is from Solomon, and indeed, it reads: In the name of Allah, the Entirely Merciful, the Especially Merciful.'),
      ),
      q(
        'A Muslim says Bismillah before which of these?',
        'Eating, drinking, entering the home and other good acts',
        ['Only before formal prayer', 'Only when leaving for travel', 'Only when nervous'],
        'The basmalah is a lifestyle tool: it converts ordinary moments into remembered, blessed moments.',
        s(BUKHARI, '5376', 'sahih', 'When one of you eats, let him mention the name of Allah.'),
      ),
      q(
        'What is dhikr?',
        'Remembrance of Allah with the heart, the tongue and in action',
        ['A silent meditation without words or movement', 'Only reciting the Quran in Arabic', 'A formal prayer said in congregation'],
        'Allah commands abundant remembrance - it is the continuous background hum of a believer\u2019s day.',
        s(QURAN, '33:41', null, 'O you who believe, remember Allah with much remembrance.'),
      ),
      q(
        'Why does a believer say Alhamdulillah even after hardship?',
        'Because the affair of the believer is always good - in ease and in difficulty',
        ['Because hardship is not real', 'Because saying it removes the hardship', 'Because it impresses others'],
        'The Prophet\u2019s criterion: the believer\u2019s affairs are all good - gratitude in ease, patience in hardship, both counted as good.',
        s(MUSLIM, '2999', 'sahih', 'Amazing is the affair of the believer: if good befalls him he is grateful, and if hardship befalls him he is patient - and both are good for him.'),
      ),
    ],
  },

  'adab.g2': {
    unit: 'adab',
    title: 'Waking and sleeping',
    items: [
      q(
        'Your alarm goes off. What did the Prophet say when waking?',
        '"Alhamdulillahi alladhi ahyana ba\u2019da ma amatana wa ilayhin-nushur"',
        ['"Bismika Allahumma amutu wa ahya"', '"Allahu Akbar"', 'Nothing - just get up'],
        'The day begins with gratitude: life itself was returned after sleep, and the return to Allah is always the destination.',
        s(BUKHARI, '6312', 'sahih', 'When the Prophet woke up he would say: All praise is for Allah who gave us life after death and to Him is the return.'),
      ),
      q(
        'What did the Prophet advise before sleeping?',
        'Perform wudu as for prayer, then lie down on the right side',
        ['Sleep on the back facing the door', 'Eat a heavy meal first', 'Sleep only after midnight'],
        'The Prophet taught al-Bara: wudu before sleep, then the bedtime shahada-style dua - sleep as a prepared servant.',
        s(BUKHARI, '6311', 'sahih', 'When you go to bed, perform ablution as you do for prayer, then lie on your right side.'),
      ),
      q(
        'What do you say as you lie down to sleep?',
        '"Bismika Allahumma amutu wa ahya"',
        ['"Ghufranak"', '"Yahdikumullah"', '"Subhanal-ladhi sakhkhara lana hadha"'],
        'Sleep is a minor death; the bedtime words name the One who holds life and death.',
        s(BUKHARI, '6324', 'sahih', 'When the Prophet went to bed he would say: In Your name, O Allah, I die and I live.'),
      ),
      q(
        'Late-night scroll until 2am, then struggle for Fajr. What does the Prophetic guidance favor?',
        'Guarding sleep and daily dhikr over entertainment that wrecks the night',
        ['Completely abandoning all screens forever', 'Skipping Fajr and compensating with Dhuhr', 'Sleeping right after Isha only'],
        'The Prophet disliked idle talk after Isha; rest exists to power worship, and Fajr is where the day\u2019s barakah begins.',
        s(BUKHARI, 'Book of Prayer Times (Mawaqit as-Salah)', 'sahih', 'The Prophet disliked sleeping before Isha and idle talk after it.'),
      ),
    ],
  },

  'adab.g3': {
    unit: 'adab',
    title: 'Eating and drinking',
    items: [
      q(
        'What three things did the Prophet teach a young boy about meals?',
        'Say Bismillah, eat with your right hand, eat from what is in front of you',
        ['Eat fast, take big bites, finish everything', 'Eat only with family, never alone', 'Never eat meat on Mondays'],
        'The famous instruction to Umar ibn Abi Salamah packs the whole meal etiquette into one sentence.',
        s(BUKHARI, '5376', 'sahih', 'O young man, say Bismillah, eat with your right hand, and eat from what is in front of you.'),
      ),
      q(
        'Halfway through your meal you realize you never said Bismillah. What now?',
        'Say "Bismillahi awwalahu wa akhirah"',
        ['Stop eating immediately', 'Restart the entire meal', 'Say nothing - the chance has passed'],
        'The Sunnah covers the forgetful: the dua for mid-meal recognizes both ends of the meal.',
        s(ABU_DAWUD, '3767', 'hasan', 'When one of you eats and forgets to mention Allah, let him say: Bismillahi awwalahu wa akhirah.'),
      ),
      q(
        'Which behavior should you avoid while drinking?',
        'Breathing into the water vessel',
        ['Sitting down comfortably', 'Saying Bismillah first', 'Sharing the water with others'],
        'The Prophet would pause and breathe outside the vessel - hygiene and manners in one habit.',
        s(BUKHARI, 'Book of Drinks (Kitab al-Ashribah)', 'sahih', 'The Prophet would breathe three times while drinking (pausing outside the vessel).'),
      ),
      q(
        'How should a Muslim think about filling the stomach?',
        'A third for food, a third for drink, a third for breath',
        ['Eat until tired, then rest', 'Only eat when in pain', 'Fill it completely - wasting food is wrong'],
        'The Prophet\u2019s rule about the stomach: moderate portions keep the body light for worship.',
        s(TIRMIDHI, '2380', 'hasan (per some scholars)', 'The son of Adam fills no vessel worse than his stomach. A few morsels suffice; if he must, then a third for food, a third for drink, a third for breath.'),
      ),
    ],
  },

  'adab.g4': {
    unit: 'adab',
    title: 'Mirror, clothes and doors',
    items: [
      q(
        'What do you say when looking in the mirror?',
        '"Allahumma anta hassanta khalqi fa hassin khuluqi"',
        ['"Ghufranak"', '"Rabbi zidni ilma"', '"Allahumma sayyiban nafi\u2019a"'],
        'The mirror dua connects outside to inside: if the reflection is good, the character inside should be better.',
        s('Musnad Ahmad; also reported by Ibn Hibban', 'Book of Supplications', 'hasan (per some scholars)', 'O Allah, You have beautified my creation, so beautify my character.'),
      ),
      q(
        'You put on a new shirt. What do you say?',
        '"Alhamdulillahi alladhi kasani hadha wa razaqanihi min ghayri hawlin minni wa la quwwah"',
        ['"Bismika Allahumma amutu wa ahya"', 'Nothing - it is just clothing', '"Subhana Rabbiyal-Azim"'],
        'The clothing dua strips pride from fashion: the garment is provision from Allah, not an achievement.',
        s(ABU_DAWUD, '4023', 'hasan', 'Whoever puts on a garment and says this dua, his previous sins will be forgiven.'),
      ),
      q(
        'Stepping out of your front door, what is said?',
        '"Bismillahi tawakkaltu alallah, la hawla wa la quwwata illa billah"',
        ['"Bismillahi walajna"', '"Alhamdulillah"', '"Yarhamukallah"'],
        'Leaving home is trusting home\u2019s Owner: the dua hands over the trip and its outcome to Allah.',
        s(ABU_DAWUD, '5095', 'hasan', 'It is said to him: you have been guided, protected and taken care of.'),
      ),
      q(
        'You return home after work. What do you say as you enter?',
        '"Bismillahi walajna wa bismillahi kharajna wa ala rabbina tawakkalna"',
        ['"Allahumma sayyiban nafi\u2019a"', '"Rabbi zidni ilma"', '"Subhanal-ladhi sakhkhara lana hadha"'],
        'Entering with Allah\u2019s name welcomes barakah into the household - and it is followed by salaam to the family.',
        s(ABU_DAWUD, '5096', 'hasan', 'When the Prophet entered his home he would say: In the name of Allah we enter and in the name of Allah we leave, and upon our Lord we depend.'),
      ),
    ],
  },

  'adab.g5': {
    unit: 'adab',
    title: 'Salaam and speech',
    items: [
      q(
        'What is the complete form of the greeting?',
        '"As-salamu alaykum wa rahmatullahi wa barakatuh"',
        ['"As-salamu alaykum" only', '"Salam alayk"', '"Good morning"'],
        'The fuller greeting carries peace, mercy and blessings - and returning it better is Quranically encouraged.',
        s(ABU_DAWUD, '5195', 'hasan', 'A man came and said: As-salamu alaykum. The Prophet responded and said: Ten (rewards). Another added: wa rahmatullah - Twenty. Another: wa barakatuh - Thirty.'),
      ),
      q(
        'Who greets whom first according to the Sunnah?',
        'The rider greets the walker, the walker the seated, the smaller group the larger',
        ['The elder greets only other elders', 'Nobody greets first until names are known', 'The seated greet the walker'],
        'The Prophet set the order so that salaam flows from strength and movement toward stillness and need.',
        s(MUSLIM, '2160', 'sahih', 'The rider should greet the pedestrian, the pedestrian the one seated, and the smaller group the larger.'),
      ),
      q(
        'Someone greets you: "As-salamu alaykum". What is the better reply?',
        '"Wa alaykum as-salam wa rahmatullahi wa barakatuh"',
        ['A silent nod', '"Alaykum salam" with a wave', '"Hello, how are you?"'],
        'Allah commands: when greeted, greet with something better or at least return it - generosity starts with words.',
        s(QURAN, '4:86', null, 'When you are greeted with a greeting, greet with one better than it or return it.'),
      ),
      q(
        'What did the Prophet say increases love between people?',
        'Spreading salaam',
        ['Giving expensive gifts only', 'Long conversations late at night', 'Matching clothes'],
        'The Prophet tied faith itself to a simple free habit: warm greetings everywhere.',
        s(MUSLIM, '54', 'sahih', 'You will not enter Paradise until you believe, and you will not believe until you love one another. Shall I tell you what makes you love one another? Spread salaam among you.'),
      ),
    ],
  },

  'adab.g6': {
    unit: 'adab',
    title: 'Bathroom, travel and weather',
    items: [
      q(
        'What do you say before entering the bathroom?',
        '"Allahumma inni a\u2019udhu bika minal-khubthi wal-khaba\u2019ith"',
        ['"Ghufranak"', '"Bismillah" only', '"A\u2019udhu billahi minash-shaytanir-rajim"'],
        'The bathroom is a private moment - and it is protected with refuge sought from male and female devils.',
        s(BUKHARI, '142', 'sahih', 'When the Prophet entered the privy he would say: O Allah, I seek refuge in You from male and female devils.'),
      ),
      q(
        'What is said when leaving the bathroom?',
        '"Ghufranak" - I ask Your forgiveness',
        ['"Alhamdulillah"', '"Yahdikumullah"', 'Nothing at all'],
        'A tiny dua after a humbling necessity - the believer\u2019s tongue stays connected to Allah even in the washroom doorway.',
        s(ABU_DAWUD, '30', 'hasan', 'When the Prophet left the privy he would say: Ghufranak.'),
      ),
      q(
        'You get into a car for a long highway trip. What do you recite?',
        '"Subhanal-ladhi sakhkhara lana hadha..." - the journey dua',
        ['"Rabbi zidni ilma"', '"Allahumma sayyiban nafi\u2019a"', '"Subhana Rabbiyal-Ala"'],
        'The vehicle is subjected to us by Allah - the dua honors the Giver and remembers the final return.',
        s(QURAN, '43:13-14', null, 'That you may settle upon their backs, then remember the favor of your Lord and say: Glory to Him who has subjected this to us... and indeed to our Lord we are returning.'),
      ),
      q(
        'Rain begins after months of drought. What do you say?',
        '"Allahumma sayyiban nafi\u2019a"',
        ['"Ghufranak"', '"Bismika Allahumma amutu wa ahya"', '"Allahu Akbar"'],
        'Rain is mercy in motion; the dua asks that the mercy arrive as benefit, not harm.',
        s(BUKHARI, '1032', 'sahih', 'When the Prophet saw rain he would say: O Allah, make it a beneficial rain.'),
      ),
    ],
  },

  // ----------------------------------------------------------------- Akhlaq
  'akhlaq.g1': {
    unit: 'akhlaq',
    title: 'The weight of good character',
    items: [
      q(
        'What did the Prophet say he was sent to perfect?',
        'Good character (makarim al-akhlaq)',
        ['Trade and business rules', 'Physical strength', 'Poetry and eloquence'],
        'The mission statement itself: character is the center of the religion, not an accessory to it.',
        s('Musnad Ahmad', 'Book of Manners', 'sahih (per some scholars)', 'I was sent only to perfect good character.'),
      ),
      q(
        'What did the Prophet say is placed on the believer\u2019s scale heavier than anything?',
        'Good character',
        ['Wealth given in charity', 'Long night prayers', 'Years of fasting'],
        'On the Day of Judgement the scales weigh character - daily kindness can outweigh impressive feats.',
        s(ABU_DAWUD, '4799', 'sahih (per some scholars)', 'Nothing is placed on the scales heavier than good character.'),
      ),
      q(
        'What does sidq (truthfulness) mean in practice?',
        'Being truthful even when the truth is hard',
        ['Never telling anyone bad news', 'Always being brutally harsh', 'Saying only what people want to hear'],
        'The Quran places the truthful on a path of safety: truthfulness is a lifestyle, not just honest words.',
        s(QURAN, '9:119', null, 'O you who believe, fear Allah and be with the truthful.'),
      ),
      q(
        'What did the Prophet say happens to the one who humbles himself for Allah?',
        'Allah raises him up',
        ['He loses respect', 'He is ignored', 'He must lower his standards'],
        'Tawadu is strength disguised as lowliness: no one humbles himself for Allah except that Allah elevates him.',
        s(MUSLIM, '2588', 'sahih', 'No one humbles himself for Allah except that Allah raises him.'),
      ),
    ],
  },

  'akhlaq.g2': {
    unit: 'akhlaq',
    title: 'Etiquette with parents',
    items: [
      q(
        'In Surah al-Isra, how are parents linked with Allah?',
        'Allah commands worship of Him alone, then immediately commands kindness to parents',
        ['Parents come after all other relatives', 'Parents are mentioned only once in passing', 'Kindness to parents is only recommended, not commanded'],
        'Allah joins His own right with the parents\u2019 right in one breath - that is the weight of birr.',
        s(QURAN, '17:23', null, 'Your Lord has decreed that you worship none but Him, and that you be kind to your parents.'),
      ),
      q(
        'Your elderly parent asks something that frustrates you. What did Allah explicitly forbid?',
        'Even saying "uff" (a word of annoyance) to them',
        ['Disagreeing politely', 'Being too busy to call', 'Asking a sibling for help'],
        'The Quran names the smallest irritation - uff - and forbids it. Anything harsher is already far past the line.',
        s(QURAN, '17:23', null, 'Do not say to them "uff", nor repel them, but speak to them a noble word.'),
      ),
      q(
        'What image does the Quran use for how you should treat your parents?',
        'Lower to them the wing of humility (mercy) and pray for them',
        ['Stand above them to guide them', 'Give them only financial support', 'Decide for them without consulting them'],
        'The wings of mercy replace the wings you had as a child - the parent-child role reverses with age.',
        s(QURAN, '17:24', null, 'And lower to them the wing of humility out of mercy, and say: My Lord, have mercy on them as they brought me up when I was small.'),
      ),
      q(
        'A man asked the Prophet: who deserves my best companionship? What did he answer?',
        'Your mother - three times - then your father',
        ['Your father - three times - then your mother', 'Your spouse first, then parents', 'Your closest friend first'],
        'The Prophet repeated "your mother" three times before mentioning the father - a direct answer to the question of priority.',
        s(BUKHARI, '5971', 'sahih', 'Your mother, your mother, your mother, then your father.'),
      ),
    ],
  },

  'akhlaq.g3': {
    unit: 'akhlaq',
    title: 'Family and elders',
    items: [
      q(
        'What did the Prophet say happens to the one who maintains family ties?',
        'His provision is expanded and his life is extended',
        ['He becomes wealthy automatically', 'He avoids all arguments forever', 'He never needs to work'],
        'Kinship maintenance is treated as an investment: the reward is written in this world before the next.',
        s(BUKHARI, '5986', 'sahih', 'Whoever loves to have his provision expanded and his lifespan extended, let him maintain his family ties.'),
      ),
      q(
        'How did the Prophet summarize the duty toward the old and young?',
        'Honor the elders and show mercy to the young',
        ['Command the elders and discipline the young', 'Treat everyone exactly alike in every situation', 'Leave children to themselves'],
        'A two-line social contract: respect flows upward, tenderness flows downward.',
        s(ABU_DAWUD, '4943', 'hasan', 'He is not one of us who does not respect our elders and show mercy to our young.'),
      ),
      q(
        'A relative has cut you off and skipped your calls. What does the Sunnah prefer?',
        'Keep maintaining the tie - the true maintainer keeps ties even when others sever',
        ['Cut back exactly the same way', 'Maintain the tie only after they apologize', 'Post about the issue publicly'],
        'The Prophet redefined winning: the one who keeps giving even when the tie is one-sided.',
        s(BUKHARI, '5991', 'sahih', 'The maintainer of ties is not the one who does it only when reciprocated; the maintainer keeps ties even when the other severs them.'),
      ),
      q(
        'Who did the Prophet greet when he passed children playing?',
        'He greeted them with salaam',
        ['He walked past quietly', 'He insisted they stand', 'He only greeted the adults nearby'],
        'Anas described the Prophet passing a group of boys and giving salaam - teaching children dignity and believers humility.',
        s(BUKHARI, '6247', 'sahih', 'The Prophet passed by a group of boys and gave them salaam.'),
      ),
    ],
  },

  'akhlaq.g4': {
    unit: 'akhlaq',
    title: 'Neighbors and guests',
    items: [
      q(
        'What did the Prophet say about a person whose neighbor is not safe from his harm?',
        'He is not a (complete) believer',
        ['He must move houses', 'He should apologize once', 'He only owes a gift'],
        'The Prophet swore three times about this to make the point stick: faith is measured at the property line.',
        s(BUKHARI, '6016', 'sahih', 'By Allah, he is not a believer - the one whose neighbor is not safe from his harm.'),
      ),
      q(
        'Honoring the guest is linked in the hadith to what?',
        'Belief in Allah and the Last Day',
        ['The size of your house', 'Your income bracket', 'Being the same age as the guest'],
        'The Prophet tied hospitality to faith itself - the guest is a test of what you claim to believe.',
        s(BUKHARI, '6136', 'sahih', 'Whoever believes in Allah and the Last Day, let him honor his guest.'),
      ),
      q(
        'A new family moves in next door. Which action fits the Sunnah?',
        'Greet them, introduce yourself, and share something simple like food',
        ['Wait for them to come to you first', 'Complain about their parking before introductions', 'Keep to yourself - they might be busy'],
        'The Prophet instructed adding water to the broth and sharing with the neighbor - welcome begins with warmth.',
        s(MUSLIM, '2625', 'sahih', 'When you cook broth, add enough water and share some with your neighbors.'),
      ),
      q(
        'Which people does the Quran list as deserving kindness alongside parents?',
        'Relatives, orphans, the poor, the near and distant neighbor, the companion and the wayfarer',
        ['Only close family and friends', 'Only people of the same income', 'Only those who can return the favor'],
        'Surah an-Nisa expands the circle of goodness outward: from family to neighbor to traveler - nobody is outside the web.',
        s(QURAN, '4:36', null, 'Be good to parents, relatives, orphans, the poor, the neighbor who is near, the neighbor who is distant, the companion at your side, the traveler, and those in your charge.'),
      ),
    ],
  },

  'akhlaq.g5': {
    unit: 'akhlaq',
    title: 'Guarding the tongue',
    items: [
      q(
        'What is ghibah (backbiting)?',
        'Mentioning something about a person - behind their back - that they would dislike',
        ['Any true statement about someone', 'Only telling lies about someone', 'Praising someone publicly'],
        'The Prophet asked the Companions: do you know what backbiting is? It is to mention about your brother what he dislikes - even if it is true.',
        s(MUSLIM, '2589', 'sahih', 'Do you know what backbiting is? Mentioning about your brother what he dislikes. It was said: even if it is true? He said: if it is true, that is backbiting; if it is not true, that is slander.'),
      ),
      q(
        'What rule did the Prophet pair with belief in Allah and the Last Day regarding speech?',
        'Speak good or remain silent',
        ['Speak whatever is on your mind', 'Only speak to close friends', 'Speak only when asked questions'],
        'One sentence filters a whole day of conversation: good words earn, silence is safe, the rest is loss.',
        s(MUSLIM, '47', 'sahih', 'Whoever believes in Allah and the Last Day, let him speak good or remain silent.'),
      ),
      q(
        'When is speaking about an absent person permissible per scholars?',
        'When seeking help to stop oppression or warning someone from real harm',
        ['When it makes the group laugh', 'When you are bored', 'When the person is not religious'],
        'The Quran forbids spying and backbiting; scholarship carves narrow exceptions for protecting people from harm - not for entertainment.',
        s(QURAN, '49:12', null, 'O you who believe, avoid much suspicion, do not spy, and do not backbite one another.'),
      ),
      q(
        'What did the Prophet say truthfulness leads to?',
        'Righteousness, and righteousness leads to Paradise',
        ['Immediate wealth', 'Popularity among people', 'A life without conflict'],
        'Truthfulness is a path with a destination: the honest tongue trains the whole character upward.',
        s(BUKHARI, '6094', 'sahih', 'Truthfulness leads to righteousness, and righteousness leads to Paradise. A man continues to be truthful until he is recorded with Allah as truthful.'),
      ),
    ],
  },

  'akhlaq.g6': {
    unit: 'akhlaq',
    title: 'Everyday life',
    items: [
      q(
        'You sit down to study. Which dua fits the moment?',
        '"Rabbi zidni ilma" - My Lord, increase me in knowledge',
        ['"Allahumma sayyiban nafi\u2019a"', '"Ghufranak"', '"Bismika Allahumma amutu wa ahya"'],
        'The Quran\u2019s own study dua: knowledge is requested from its true Giver before the books are even open.',
        s(QURAN, '20:114', null, 'My Lord, increase me in knowledge.'),
      ),
      q(
        'Your sibling breaks your headphones and anger spikes. What is the Prophetic action?',
        'Say "A\u2019udhu billahi minash-shaytanir-rajim" and let the anger cool',
        ['Yell once and move on', 'Break something of theirs in return', 'Stay silent but plan revenge'],
        'Anger is from the devil, and refuge is its exit route - the Prophet named the word that cools the fire.',
        s(BUKHARI, '6115', 'sahih', 'I know a word which, if he said it, his anger would leave him: I seek refuge in Allah from the accursed devil.'),
      ),
      q(
        'Someone insults you in an online comment. Which response follows the Quran?',
        'Do not trade insults - respond with calm words or disengage',
        ['Reply with a sharper insult to win', 'Screenshot and mock them publicly', 'Delete your account forever'],
        'Repel evil with what is better: the Quran promises that even an enemy can become a close friend through good words.',
        s(QURAN, '41:34', null, 'Repel evil with that which is better; then the one who had enmity between you and him may become like a close friend.'),
      ),
      q(
        'A shocking headline lands in your feed. What does the Quran require before sharing?',
        'Verify it first - do not spread news you cannot check',
        ['Share it with a disclaimer', 'Share it if it feels true', 'Only share if it has many likes already'],
        'The believer is a filter, not a megaphone: verification protects people from rumors that cause real harm.',
        s(QURAN, '49:6', null, 'If a troublemaker comes to you with news, verify it, lest you harm people in ignorance and become regretful over what you have done.'),
      ),
      q(
        'Which small act did the Prophet count as sadaqah (charity)?',
        'A smile in your brother\u2019s face',
        ['Only money given to the poor', 'Only large donations', 'Only feeding a whole meal'],
        'Charity is not only currency: every kindness - even a smile - is written as sadaqah.',
        s(TIRMIDHI, '1956', 'hasan (per some scholars)', 'Your smile in the face of your brother is charity.'),
      ),
    ],
  },
};
