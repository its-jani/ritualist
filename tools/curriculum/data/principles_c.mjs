// Authored scenario MCQs - part C: Tazkiyah (heart-work): Hasad + Riya.
// Same conventions as principles_a.mjs (see header there).

import { q, s } from './helpers.mjs';

const BUKHARI = 'Sahih al-Bukhari';
const MUSLIM = 'Sahih Muslim';
const ABU_DAWUD = 'Sunan Abu Dawud';
const QURAN = 'Qur\u2019an';

export const GROUPS = {
  // ------------------------------------------------------------------ Hasad
  'hasad.g1': {
    unit: 'hasad',
    title: 'What envy is',
    items: [
      q(
        'What is hasad (envy)?',
        'Resenting someone\u2019s blessing and wishing it were removed from them',
        ['Wanting a similar blessing for yourself', 'Feeling sad when someone is harmed', 'Being competitive at work'],
        'Hasad targets the blessing itself: the envier wants it gone, not matched - that is what the Quran seeks refuge from.',
        s(QURAN, '113:5', null, 'And from the evil of an envier when he envies.'),
      ),
      q(
        'What is ghibta, and how does it differ from hasad?',
        'Wishing for a similar blessing without wanting it removed from the other person',
        ['Another word for hasad', 'Watching others succeed without caring at all', 'Copying someone\u2019s exact lifestyle'],
        'Ghibta is clean aspiration - the Prophet\u2019s hadith allows this kind of "envy" in two cases only.',
        s(BUKHARI, '73', 'sahih', 'There is no (harmful) envy except in two cases: a man whom Allah gave wealth and he spends it in truth, and a man whom Allah gave knowledge and he teaches it.'),
      ),
      q(
        'Which two situations did the Prophet describe as the only acceptable form of "envy"?',
        'Aspiration for someone who spends wealth in truth and someone who teaches knowledge',
        ['Aspiration for famous people and rich people', 'Aspiration for athletes and actors', 'Aspiration for whoever has more followers'],
        'The only permitted envy is the desire to do MORE good - not to have more things.',
        s(BUKHARI, '73', 'sahih', 'There is no envy except in two cases: a man whom Allah has given wealth and he spends it in the right way, and a man whom Allah has given wisdom and he judges by it and teaches it.'),
      ),
      q(
        'Envy of someone\u2019s blessings is really a complaint against whom?',
        'Allah - the One who distributed His bounty',
        ['The blessed person', 'The envier\u2019s family', 'Society in general'],
        'Before envy becomes a feeling about a person, it is a hidden objection to Allah\u2019s distribution.',
        s(QURAN, '4:54', null, 'Or do they envy people for what Allah has given them of His bounty?'),
      ),
    ],
  },

  'hasad.g2': {
    unit: 'hasad',
    title: 'The damage of envy',
    items: [
      q(
        'What did the Prophet warn envy does to good deeds?',
        'It consumes them the way fire consumes wood',
        ['It delays them until Ramadan', 'It makes them count double', 'It has no effect on deeds'],
        'A warning worth taking seriously - with an honest note on its grading, since scholars differ about this narration.',
        s(ABU_DAWUD, '4903', 'da\u2019if (weak per some scholars; some grade it hasan)', 'Envy consumes good deeds the way fire consumes wood.'),
      ),
      q(
        'Who does envy damage first?',
        'The person who carries it - it eats their peace before it reaches anyone else',
        ['The envied person only', 'Nobody - it is just a feeling', 'The envier\u2019s friends'],
        'The envier\u2019s chest is the first casualty: anxiety, insomnia and bitterness arrive long before the "revenge".',
        s(QURAN, '113:5', null, 'And from the evil of an envier when he envies - the envier\u2019s harm starts with his own state.'),
      ),
      q(
        'Why did Iblis refuse to prostrate to Adam?',
        'Arrogance and envy of Adam\u2019s honored station',
        ['He did not hear the command', 'He was busy in worship', 'He thought Adam had wronged him'],
        'The first act of hasad in history was the first act of defiance - envy and arrogance travel together.',
        s(QURAN, '7:12', null, 'He said: I am better than him; You created me from fire and created him from clay.'),
      ),
      q(
        'An envious person watches someone else\u2019s blessing fade and feels relief. What did the Prophet guard against with daily dua?',
        'That our good be not lost or transferred',
        ['That we gain more followers', 'That our enemies fail', 'That we never hear bad news'],
        'Envy wishes loss on others; the cure is asking Allah to protect your own blessing rather than delighting in anyone losing theirs.',
        s(MUSLIM, '2732', 'sahih', 'The dua of a Muslim for his brother in his absence is answered; the angel says: Ameen, and may you have the same.'),
      ),
    ],
  },

  'hasad.g3': {
    unit: 'hasad',
    title: 'Envy in daily life',
    items: [
      q(
        'A classmate posts a great exam result and your chest tightens. What does iman ask of you?',
        'Wish for them what you love for yourself - and ask Allah for your own share',
        ['Comment something backhanded', 'Mute them immediately - problem solved', 'Keep the anger and let it grow'],
        'The Prophet\u2019s measure of love: wanting for your brother what you want for yourself - even in exam results.',
        s(BUKHARI, '13', 'sahih', 'None of you truly believes until he loves for his brother what he loves for himself.'),
      ),
      q(
        'Your cousin buys the house you also hoped for. What is the clean alternative to hasad?',
        'Ghibta - be glad for them and ask Allah from His bounty for yourself too',
        ['Find something wrong with their house', 'Never visit their home again', 'Compare their loan terms critically'],
        'The two permitted kinds of "envy" turn the sting of comparison into fuel: aspire to give and to teach.',
        s(BUKHARI, '73', 'sahih', 'There is no envy except: a man given wealth who spends it in truth, and a man given knowledge who teaches it.'),
      ),
      q(
        'You catch yourself comparing followers and feeling resentment. What breaks the habit?',
        'Trading comparison for gratitude - and making dua for the people you envy',
        ['Deleting the app and staying offline forever', 'Working until you out-perform everyone visible', 'Avoiding anyone more successful than you'],
        'The Quran promises: gratitude grows blessings, and resentment only consumes the blessing of the envier.',
        s(QURAN, '14:7', null, 'If you are grateful, I will surely increase you [in favor].'),
      ),
      q(
        'What did the Prophet say to say when you admire something in someone else?',
        'Make dua for barakah in it',
        ['Compliment only if they deserve it', 'Say nothing - truth brings envy', 'Point out its price'],
        'Asking for barakah is the opposite of hasad: you are praying the blessing stays and grows.',
        s(MUSLIM, 'Book of Greetings and Manners', 'sahih', 'When one of you sees something pleasing in himself, his brother or his property, let him ask Allah to bless it.'),
      ),
    ],
  },

  'hasad.g4': {
    unit: 'hasad',
    title: 'The cure for envy',
    items: [
      q(
        'You make dua for someone in their absence. What did the Prophet say happens?',
        'The angel says: Ameen - and you get the same',
        ['The dua is ignored', 'The person must be told', 'You gain only half'],
        'This is the exact medicine for hasad: you cannot fear someone\u2019s blessing and sincerely pray for it at the same time.',
        s(MUSLIM, '2732', 'sahih', 'Whoever makes dua for his brother in his absence, the angel says: Ameen, and may you have the same.'),
      ),
      q(
        'Where does the cure for envy start?',
        'Knowing the blessing is Allah\u2019s distribution - and being content with your share',
        ['Collecting more than the other person', 'Avoiding all social contact', 'Explaining your own goodness to people'],
        'Once you settle that the scales belong to Allah, the enemy of the envier becomes a paper tiger.',
        s(QURAN, '4:54', null, 'Or do they envy people for what Allah has given them of His bounty? And We had already given... which is better than whatever they accumulate.'),
      ),
      q(
        'You feel envy toward your sibling\u2019s success. What is the specific, active Sunnah move?',
        'Deliberately make dua for them to have even more',
        ['Compete silently and say nothing', 'Share their news negatively with others', 'Ignore the feeling until it fades'],
        'Repel the bad impulse with a good one: dua for the envied person rewires the heart from resentment to generosity.',
        s(QURAN, '41:34', null, 'Repel evil with that which is better; then the one who had enmity between you and him may become like a close friend.'),
      ),
      q(
        'Followers, salaries and house sizes keep changing. What scale did the Prophet point to?',
        'Hearts and deeds - not appearances or numbers',
        ['Bank balances and property', 'Notability in society', 'The size of one\u2019s friend group'],
        'Allah does not look at your forms or appearances; He looks at your hearts and your actions - the only scoreboard that holds still.',
        s(MUSLIM, '2564', 'sahih', 'Allah does not look at your bodies or your appearances, but He looks at your hearts and your actions.'),
      ),
    ],
  },

  // ------------------------------------------------------------------- Riya
  'riya.g1': {
    unit: 'riya',
    title: 'Why intention matters',
    items: [
      q(
        'With which hadith does Sahih al-Bukhari open?',
        '"Actions are only judged by intentions"',
        ['"Cleanliness is half of faith"', '"The imam is to be followed"', '"Speak good or remain silent"'],
        'The very first hadith of the most authentic collection is about intention - because the heart decides the value of everything.',
        s(BUKHARI, '1', 'sahih', 'Actions are only judged by intentions, and every person will have what he intended.'),
      ),
      q(
        'What is riya?',
        'Doing good deeds so people see and praise you',
        ['Making dua for others openly', 'Reciting the Quran aloud in prayer', 'Giving charity where it is most needed'],
        'The Quran calls it out sharply: woe to those who pray to be seen - worship with an audience in mind.',
        s(QURAN, '107:4-6', null, 'So woe to those who pray, yet are heedless of their prayer, those who make a show of their deeds.'),
      ),
      q(
        'Can a deed done for people\u2019s praise carry reward?',
        'No - Allah accepts only what is done purely for Him alone',
        ['Yes, if the deed itself is good', 'Yes, half reward', 'Yes, reward only in Ramadan'],
        'The Quran\u2019s condition: righteous work plus no partner associated in the worship - the motive is part of the act.',
        s(QURAN, '18:110', null, 'So whoever hopes to meet his Lord, let him do righteous work and associate no one in the worship of his Lord.'),
      ),
      q(
        'Two people give the same $100 to charity; one for Allah and one for a photo-op. What differs?',
        'The same action earns reward or nothing depending on the heart behind it',
        ['Nothing - the amount matters', 'The photo adds reach, so more reward', 'Both earn reward equally'],
        'The Quran warns that what follows a charity can void it: showing off burns the very deed that looked good.',
        s(QURAN, '2:264', null, 'O you who believe, do not invalidate your charities with reminders of it or injury, like one who spends to be seen by people.'),
      ),
    ],
  },

  'riya.g2': {
    unit: 'riya',
    title: 'Hidden and open',
    items: [
      q(
        'A man prays beautifully when the group watches but rushes alone. What describes him?',
        'A person whose worship shifts with the audience - riya has entered',
        ['A beginner who needs practice', 'A model of khushu', 'A person with a quiet style'],
        'The tell is the shift: worship should look the same whether one human or zero humans can see.',
        s(QURAN, '107:6', null, 'Those who make a show of their deeds.'),
      ),
      q(
        'You film your street charity delivery for content. What remains of the reward?',
        'Whatever was genuinely for Allah; the showing-off part earns no reward',
        ['Everything - the delivery was real', 'Nothing - delete the video', 'Double - more people were inspired'],
        'The deed is judged by the intention behind it; a camera changes the motive test, not the number of meals delivered.',
        s(QURAN, '2:264', null, 'Do not invalidate your charities with reminders of it or injury, like one who spends to be seen by people.'),
      ),
      q(
        'What single question helps separate riya from sincerity?',
        '"Would I still do this if no human could ever find out?"',
        ['"Will this make me happy?"', '"Will this grow my following?"', '"Is this id hard to do?"'],
        'The heart-check question: deeds that survive zero visibility are deeds built for Allah.',
        s(BUKHARI, 'Book of Heart-Melting Traditions (Kitab ar-Riqaq)', 'sahih', 'Whoever makes his good deeds heard of for show, Allah will expose his reality.'),
      ),
      q(
        'Why is secret charity described as a protection?',
        'It hides the deed from the desire for praise - only Allah sees it',
        ['It is embarrassing to give publicly', 'It saves tax paperwork', 'It guarantees the money is used well'],
        'The closer a deed is to secrecy, the further it is from riya - some scholars kept their best deeds hidden from everyone.',
        s(MUSLIM, 'Book of Zakat', 'sahih', 'A man who gives in charity and conceals it so that his left hand does not know what his right hand spends is among those shaded on the Day of Judgement.'),
      ),
    ],
  },

  'riya.g3': {
    unit: 'riya',
    title: 'The three who were judged',
    items: [
      q(
        'In the famous hadith of the three men judged first, why is the generous man condemned despite his charity?',
        'He gave to be called generous - and received that title instead of reward',
        ['He gave too little', 'He gave to the wrong people', 'He delayed his charity'],
        'Muslim 1905 tells of three people whose impressive deeds were exposed by their motives - the wealthy man wanted the label, and got it.',
        s(MUSLIM, '1905', 'sahih', 'A man whom Allah gave wealth: he spent for show. It was said to him: you have received what you wanted.'),
      ),
      q(
        'The martyr of that hadith fought bravely and died - what was his verdict?',
        'He fought so it would be said he was brave; he is dragged into the Fire',
        ['He was forgiven for his courage', 'His family received the reward', 'He was granted intercession'],
        'Even bravery on the battlefield is weighed by motive - the most dramatic deed can be hollowed out by an audience of one\u2019s own reputation.',
        s(MUSLIM, '1905', 'sahih', 'He fought to be called brave. It was said: you have received what you wanted.'),
      ),
      q(
        'The scholar of that hadith learned and taught. Where did he go wrong?',
        'He sought to be called a scholar for himself',
        ['He studied the wrong books', 'He taught only a few people', 'He charged for teaching'],
        'The third man of the hadith: knowledge used as currency for reputation turns the same lessons into evidence against the teacher.',
        s(MUSLIM, '1905', 'sahih', 'He learned knowledge and taught it and recited Quran to be called a scholar and a reciter. It was said: you have received what you wanted.'),
      ),
      q(
        'What single thread unites all three men of Muslim 1905?',
        'They acted for people\u2019s praise instead of for Allah',
        ['They broke the law in secret', 'They all lacked sincerity in worship only', 'They were all show-offs online'],
        'Three different arenas - wealth, war, scholarship - and one shared defect: visibility mattered more than Allah\u2019s acceptance.',
        s(MUSLIM, '1905', 'sahih', 'All three were brought and judged first, and all three were told: you have received what you wanted.'),
      ),
    ],
  },

  'riya.g4': {
    unit: 'riya',
    title: 'Purifying intention',
    items: [
      q(
        'What shirk did the Prophet say he feared most for his ummah?',
        'The lesser shirk - showing off (riya)',
        ['He feared poverty the most', 'He feared war the most', 'He feared disease the most'],
        'Transparent about grading: the narration is in Musnad Ahmad and graded hasan/sahih by different scholars - the warning itself is well established.',
        s('Musnad Ahmad', 'Book of Musnad al-Ansar', 'hasan (per some scholars; some grade it sahih)', 'The thing I fear most for you is the lesser shirk. They asked: what is it? He said: showing off.'),
      ),
      q(
        'What dua is taught as the shield against hidden shirk?',
        '"Allahumma inni a\u2019udhu bika an ushrika bika wa ana a\u2019lam, wa astaghfiruka lima la a\u2019lam"',
        ['"Rabbi zidni ilma"', '"Allahumma sayyiban nafi\u2019a"', '"Ghufranak"'],
        'The dua covers both known and unknown shirk - a daily reminder that motives can hide even from the one doing the deed.',
        s('Musnad Ahmad', 'Book of Supplications', 'sahih (per some scholars)', 'O Allah, I seek refuge in You from knowingly associating anything with You, and I ask Your forgiveness for what I do not know.'),
      ),
      q(
        'Your daily Quran reading is now recorded and posted for an audience. How can riya creep in?',
        'The practice turns into content for people instead of worship for Allah',
        ['Posting makes the recitation invalid', 'Public recitation is always riya', 'The audience earns the reward'],
        'The act may stay halal and even beneficial - the danger is the axle it now turns around.',
        s(QURAN, '2:264', null, 'Do not invalidate your charities with reminders or injury, like one who spends to be seen by people.'),
      ),
      q(
        'What are practical daily shields against riya?',
        'Renewing intention often and hiding some good deeds completely',
        ['Announcing your charity so it spreads', 'Keeping a public good-deeds log', 'Only acting when inspired'],
        'The habit pattern: intentions refreshed at the start of acts, and a private reserve of deeds with zero witnesses.',
        s(BUKHARI, 'Book of Heart-Melting Traditions (Kitab ar-Riqaq)', 'sahih', 'Whoever intends show, Allah will expose; the one who keeps some deeds private protects their sincerity.'),
      ),
    ],
  },
};
