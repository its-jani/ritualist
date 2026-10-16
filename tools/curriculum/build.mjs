// Curriculum generator for the Ritualist Islam module.
//
//   node tools/curriculum/build.mjs          (run from the repo root)
//
// Reads the declarative plan in curriculum.mjs + the seed datasets in data/
// and emits engine-ready JSON assets:
//
//   app/assets/modules/islam/module.json           (manifest + lesson summaries)
//   app/assets/modules/islam/units/<unitId>.json   (full lesson bodies)
//   docs/curriculum-sources.md                     (generated review checklist)
//
// All shuffles are deterministic (seeded by exercise/lesson id), so rebuilding
// produces byte-identical output. The script fails loudly on any content rule
// violation instead of emitting invalid assets.

import { mkdirSync, writeFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

import { MODULE, UNITS } from './curriculum.mjs';
import { TERMS, termById } from './data/terms.mjs';
import { DUAS, duaById } from './data/duas.mjs';
import { SEQUENCES } from './data/sequences.mjs';
import { GROUPS as GROUPS_A } from './data/principles_a.mjs';
import { GROUPS as GROUPS_B } from './data/principles_b.mjs';
import { GROUPS as GROUPS_C } from './data/principles_c.mjs';

const HERE = dirname(fileURLToPath(import.meta.url));
const REPO = resolve(HERE, '..', '..');

// ---------------------------------------------------------------- utilities

/** fnv1a string hash -> 32-bit unsigned int. */
function fnv1a(str) {
  let h = 0x811c9dc5;
  for (let i = 0; i < str.length; i++) {
    h ^= str.charCodeAt(i);
    h = Math.imul(h, 0x01000193) >>> 0;
  }
  return h >>> 0;
}

/** mulberry32 PRNG seeded by a string. */
function rng(seedStr) {
  let a = fnv1a(seedStr);
  return function next() {
    a = (a + 0x6d2b79f5) >>> 0;
    let t = a;
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

/** Deterministic Fisher-Yates shuffle. Returns a new array. */
function shuffle(arr, seedStr) {
  const out = arr.slice();
  const next = rng(seedStr);
  for (let i = out.length - 1; i > 0; i--) {
    const j = Math.floor(next() * (i + 1));
    [out[i], out[j]] = [out[j], out[i]];
  }
  return out;
}

const norm = (t) => String(t).trim().toLowerCase();
const lowerFirst = (t) => t.charAt(0).toLowerCase() + t.slice(1);

/** Dedupe candidate texts against a taken set (case-insensitive). */
function pickDistinct(pool, count, taken) {
  const seen = new Set(taken.map(norm));
  const out = [];
  for (const cand of pool) {
    const key = norm(typeof cand === 'string' ? cand : cand.text);
    if (seen.has(key)) continue;
    seen.add(key);
    out.push(cand);
    if (out.length === count) break;
  }
  return out;
}

// ------------------------------------------------------------ group merging

const ALL_GROUPS = { ...GROUPS_A, ...GROUPS_B, ...GROUPS_C };
{
  const dupes = Object.keys(GROUPS_A).filter((k) => k in GROUPS_B || k in GROUPS_C);
  const dupes2 = Object.keys(GROUPS_B).filter((k) => k in GROUPS_C);
  if (dupes.length || dupes2.length) {
    throw new Error(`duplicate group keys across principle files: ${[...dupes, ...dupes2].join(', ')}`);
  }
}

// ------------------------------------------------------- exercise builders

const GLOSSARY_SOURCE = {
  collection: 'Ritualist module glossary',
  reference: 'Arabic-English vocabulary (Islam module)',
  text: 'Vocabulary pairs compiled for this module using standard English renderings. Verify details with a qualified teacher.',
};

let lessonIdForContext = '(unknown)';
const stats = { byType: { multipleChoice: 0, orderSteps: 0, matchPairs: 0 }, authored: 0, dua: 0, term: 0, order: 0, flagged: 0 };

function finalizeMcq(id, prompt, correct, distractors, explanation, source) {
  const texts = [correct, ...distractors];
  const seen = new Set([norm(correct)]);
  const options = [correct];
  for (const d of distractors) {
    const k = norm(typeof d === 'string' ? d : d.text);
    if (seen.has(k)) continue;
    seen.add(k);
    options.push(d);
  }
  if (options.length < 2) {
    throw new Error(`${id}: fewer than 2 distinct options`);
  }
  const order = shuffle(options.map((_, i) => i), `${id}:options`);
  const shuffled = order.map((i) => options[i]);
  const correctIndex = order.indexOf(0);
  const toOption = (o) => (typeof o === 'string' ? { text: o } : { text: o.text, ...(o.arabic ? { arabic: o.arabic } : {}) });
  stats.byType.multipleChoice += 1;
  return {
    id,
    type: 'multipleChoice',
    prompt,
    explanation,
    source,
    options: shuffled.map(toOption),
    correctIndex,
  };
}

function buildAuthoredMcq(id, item, group) {
  stats.authored += 1;
  return finalizeMcq(
    id,
    item.prompt,
    item.correct,
    item.distractors,
    item.explanation,
    item.source ?? (() => { throw new Error(`${id}: authored item missing source (group ${group})`); })(),
  );
}

/** Round-robin pick across groups so a review lesson samples every group. */
function pickAuthored(groups, limit, seedStr) {
  const perGroup = groups.map((g) => {
    const grp = ALL_GROUPS[g];
    if (!grp) throw new Error(`unknown authored group "${g}"`);
    return shuffle(grp.items, `${seedStr}:${g}`).map((item) => ({ item, group: g }));
  });
  const out = [];
  let round = 0;
  while (out.length < limit) {
    let added = false;
    for (const list of perGroup) {
      if (round < list.length && out.length < limit) {
        out.push(list[round]);
        added = true;
      }
    }
    if (!added) break;
    round += 1;
  }
  if (out.length < limit) {
    throw new Error(`authored pool for ${seedStr} exhausted: wanted ${limit}, got ${out.length}`);
  }
  return out;
}

function buildDuaMcq(id, dua, mode) {
  if (mode === 'askWhich') {
    stats.dua += 1;
    const pool = shuffle(DUAS, `${id}:pool`)
      .filter((d) => d.id !== dua.id && !(dua.conflicts ?? []).includes(d.id))
      .map((d) => d.translation);
    const distractors = pickDistinct(pool, 3, [dua.translation]);
    if (distractors.length < 3) throw new Error(`${id}: not enough dua translation distractors`);
    return finalizeMcq(
      id,
      dua.scenarioAsk,
      dua.translation,
      distractors,
      `${dua.translation} (${dua.translit}). ${dua.when}`,
      dua.src,
    );
  }
  // askWhen
  stats.dua += 1;
  const pool = shuffle(DUAS, `${id}:pool`)
    .filter((d) => d.id !== dua.id && !(dua.conflicts ?? []).includes(d.id))
    .map((d) => d.scenarioShort);
  const distractors = pickDistinct(pool, 3, [dua.scenarioShort]);
  if (distractors.length < 3) throw new Error(`${id}: not enough dua scenario distractors`);
  return finalizeMcq(
    id,
    `When would you say: "${dua.translation}"`,
    dua.scenarioShort,
    distractors,
    `${dua.translit} (${dua.arabic}): ${dua.translation} Said ${lowerFirst(dua.scenarioShort)}.`,
    dua.src,
  );
}

function buildTermMeaningMcq(id, term) {
  stats.term += 1;
  const sameUnit = shuffle(
    TERMS.filter((t) => t.id !== term.id && t.unit === term.unit),
    `${id}:pool`,
  );
  const others = shuffle(
    TERMS.filter((t) => t.id !== term.id && t.unit !== term.unit),
    `${id}:pool2`,
  );
  const pool = [...sameUnit, ...others].map((t) => t.meaning);
  const distractors = pickDistinct(pool, 3, [term.meaning]);
  if (distractors.length < 3) throw new Error(`${id}: not enough term-meaning distractors`);
  return finalizeMcq(
    id,
    `What does "${term.translit}" (${term.arabic}) mean?`,
    term.meaning,
    distractors,
    `${term.translit} (${term.arabic}) means "${term.meaning}".`,
    GLOSSARY_SOURCE,
  );
}

function buildMeaningTermMcq(id, term) {
  stats.term += 1;
  const toOpt = (t) => ({ text: t.translit, arabic: t.arabic });
  const sameUnit = shuffle(
    TERMS.filter((t) => t.id !== term.id && t.unit === term.unit),
    `${id}:pool`,
  );
  const others = shuffle(
    TERMS.filter((t) => t.id !== term.id && t.unit !== term.unit),
    `${id}:pool2`,
  );
  const pool = [...sameUnit, ...others].map(toOpt);
  const correct = toOpt(term);
  const distractors = pickDistinct(pool, 3, [correct.text]);
  if (distractors.length < 3) throw new Error(`${id}: not enough meaning-term distractors`);
  return finalizeMcq(
    id,
    `Which term means "${term.meaning}"?`,
    correct,
    distractors,
    `"${term.meaning}" is ${term.translit} (${term.arabic}).`,
    GLOSSARY_SOURCE,
  );
}

function buildMatch(id, termIds) {
  if (termIds.length < 3) throw new Error(`${id}: match needs at least 3 terms`);
  stats.term += 1;
  stats.byType.matchPairs += 1;
  const terms = termIds.map((t) => termById(t));
  const pairs = terms.map((t) => ({
    left: t.translit,
    right: t.meaning,
    leftArabic: t.arabic,
  }));
  const explanation = `Term check: ${terms.map((t) => `${t.translit} = ${t.meaning}`).join('; ')}.`;
  return {
    id,
    type: 'matchPairs',
    prompt: 'Match each term to its meaning.',
    explanation,
    source: GLOSSARY_SOURCE,
    pairs,
  };
}

function buildOrder(id, seqKey) {
  const seq = SEQUENCES[seqKey];
  if (!seq) throw new Error(`${id}: unknown sequence "${seqKey}"`);
  stats.order += 1;
  stats.byType.orderSteps += 1;
  const stepTexts = new Set(seq.steps.map(norm));
  if (stepTexts.size !== seq.steps.length) throw new Error(`${id}: duplicate step texts in sequence "${seqKey}"`);
  return {
    id,
    type: 'orderSteps',
    prompt: seq.prompt,
    explanation: seq.explanation,
    source: seq.src,
    steps: seq.steps.map((stepText) => {
      const m = /^(.*?)\s*\|(.*)$/.exec(stepText);
      return m ? { text: m[1].trim(), arabic: m[2].trim() } : { text: stepText };
    }),
  };
}

// ------------------------------------------------------------ lesson builder

function buildLesson(lessonId, lessonSpec) {
  lessonIdForContext = lessonId;
  const exercises = [];
  for (const item of lessonSpec.items) {
    switch (item.k) {
      case 'authored': {
        const picks = pickAuthored(item.groups, item.limit, lessonId);
        for (const { item: authored, group } of picks) {
          exercises.push(buildAuthoredMcq(`${lessonId}.e${exercises.length + 1}`, authored, group));
        }
        break;
      }
      case 'dua': {
        const dua = duaById(item.id);
        const modes = item.mode === 'both' ? ['askWhich', 'askWhen'] : [item.mode];
        for (const mode of modes) {
          if (mode !== 'askWhich' && mode !== 'askWhen') throw new Error(`${lessonId}: bad dua mode "${item.mode}"`);
          exercises.push(buildDuaMcq(`${lessonId}.e${exercises.length + 1}`, dua, mode));
        }
        break;
      }
      case 'match':
        exercises.push(buildMatch(`${lessonId}.e${exercises.length + 1}`, item.terms));
        break;
      case 'termMeaning':
        exercises.push(buildTermMeaningMcq(`${lessonId}.e${exercises.length + 1}`, termById(item.term)));
        break;
      case 'meaningTerm':
        exercises.push(buildMeaningTermMcq(`${lessonId}.e${exercises.length + 1}`, termById(item.term)));
        break;
      case 'order':
        exercises.push(buildOrder(`${lessonId}.e${exercises.length + 1}`, item.seq));
        break;
      default:
        throw new Error(`${lessonId}: unknown item kind "${item.k}"`);
    }
  }
  if (exercises.length < 3) throw new Error(`${lessonId}: fewer than 3 exercises`);

  // Hard content rules (mirrors the engine's ContentValidator, fail fast).
  for (const ex of exercises) {
    if (!ex.explanation || !ex.explanation.trim()) throw new Error(`${ex.id}: missing explanation`);
    if (!ex.source) throw new Error(`${ex.id}: missing source`);
    if (ex.type === 'multipleChoice') {
      const texts = ex.options.map((o) => norm(o.text));
      if (new Set(texts).size !== texts.length) throw new Error(`${ex.id}: duplicate option texts`);
      if (ex.correctIndex < 0 || ex.correctIndex >= ex.options.length) throw new Error(`${ex.id}: bad correctIndex`);
    }
    const src = ex.source;
    if (src.grading && /hasan|da\u2019if|per some/.test(src.grading)) stats.flagged += 1;
  }

  return {
    id: lessonId,
    title: lessonSpec.title,
    xp: lessonSpec.xp ?? 10,
    exercises,
  };
}

// ----------------------------------------------------------------- assembly

const manifestUnits = [];
const unitFiles = [];
const allLessons = [];

for (const unit of UNITS) {
  const lessons = unit.lessons.map((spec, i) => buildLesson(`${MODULE.id}.${unit.id}.l${i + 1}`, spec));
  allLessons.push(...lessons);

  const file = `units/${unit.id}.json`;
  unitFiles.push({ file, data: { unitId: unit.id, lessons } });
  manifestUnits.push({
    id: unit.id,
    title: unit.title,
    subtitle: unit.subtitle,
    colorIndex: unit.colorIndex,
    file,
    lessons: lessons.map((l) => ({ id: l.id, title: l.title, exercises: l.exercises.length })),
  });
}

const manifest = {
  schemaVersion: MODULE.schemaVersion,
  id: MODULE.id,
  title: MODULE.title,
  tagline: MODULE.tagline,
  description: MODULE.description,
  disclaimer: MODULE.disclaimer,
  units: manifestUnits,
};

// ------------------------------------------------------------------- output

function writeJson(relPath, data) {
  const abs = join(REPO, relPath);
  mkdirSync(dirname(abs), { recursive: true });
  writeFileSync(abs, `${JSON.stringify(data, null, 2)}\n`, 'utf8');
  return abs;
}

writeJson(`${MODULE.assetDir}/module.json`, manifest);
for (const { file, data } of unitFiles) {
  writeJson(`${MODULE.assetDir}/${file}`, data);
}

// --------------------------------------------------- sources review document

const sourceIndex = new Map();
for (const lesson of allLessons) {
  for (const ex of lesson.exercises) {
    const key = `${ex.source.collection} \u2014 ${ex.source.reference}${ex.source.grading ? ` [${ex.source.grading}]` : ''}`;
    const entry = sourceIndex.get(key) ?? { count: 0, examples: [] };
    entry.count += 1;
    if (entry.examples.length < 3) entry.examples.push(ex.id);
    sourceIndex.set(key, entry);
  }
}

const flaggedSources = [...sourceIndex.entries()].filter(([k]) => /hasan|da\u2019if|per some/.test(k));
const totalExercises = allLessons.reduce((n, l) => n + l.exercises.length, 0);

const docLines = [];
docLines.push('# Curriculum Sources (generated - do not edit by hand)');
docLines.push('');
docLines.push('Generated by `node tools/curriculum/build.mjs`. Every exercise in the Islam module carries one of the sources below. This page is the scholarly review checklist: verify each reference and grading before release.');
docLines.push('');
docLines.push(`Module: **${MODULE.title}** - ${manifestUnits.length} units, ${allLessons.length} lessons, ${totalExercises} exercises.`);
docLines.push('');
docLines.push('## Content review notice');
docLines.push('');
docLines.push(`> ${MODULE.disclaimer}`);
docLines.push('');
docLines.push('## Review flags (gradings needing scholarly attention)');
docLines.push('');
if (flaggedSources.length === 0) {
  docLines.push('_None._');
} else {
  docLines.push('| Source | Grading / note | Exercises |');
  docLines.push('| --- | --- | --- |');
  for (const [key, entry] of flaggedSources) {
    const m = /^(.*) \u2014 (.*) \[(.*)\]$/.exec(key);
    docLines.push(`| ${m[1]} ${m[2]} | ${m[3]} | ${entry.count} |`);
  }
}
docLines.push('');
docLines.push('## All sources');
docLines.push('');
docLines.push('| Source | Reference | Grading | Exercises | Examples |');
docLines.push('| --- | --- | --- | --- | --- |');
for (const [key, entry] of sourceIndex) {
  const m = /^(.*) \u2014 (.*?)(?: \[(.*)\])?$/.exec(key);
  docLines.push(`| ${m[1]} | ${m[2]} | ${m[3] ?? ''} | ${entry.count} | ${entry.examples.join(', ')} |`);
}
docLines.push('');
docLines.push('## Arabic text');
docLines.push('');
docLines.push('All Arabic script used in the app (terms, duas, steps) lives in the seed datasets under `tools/curriculum/data/`. A native speaker should proofread the Arabic text and transliterations before public release.');
docLines.push('');
writeFileSync(join(REPO, 'docs', 'curriculum-sources.md'), `${docLines.join('\n')}\n`, 'utf8');

// --------------------------------------------------------------------- report

console.log('ritualist curriculum build');
console.log('==========================');
console.log(`module "${MODULE.id}" -> ${MODULE.assetDir}/module.json + ${unitFiles.length} unit files`);
console.log(`units: ${manifestUnits.length}  lessons: ${allLessons.length}  exercises: ${totalExercises}`);
console.log(
  `by type: multipleChoice=${stats.byType.multipleChoice} orderSteps=${stats.byType.orderSteps} matchPairs=${stats.byType.matchPairs}`,
);
console.log(`by source: authored=${stats.authored} duas=${stats.dua} terms=${stats.term} sequences=${stats.order}`);
console.log(`flagged gradings (hasan / da'if / per-some): ${stats.flagged} exercises - see docs/curriculum-sources.md`);
console.log('docs/curriculum-sources.md written.');
