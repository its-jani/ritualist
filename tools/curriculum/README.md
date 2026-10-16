# Curriculum pipeline (Islam module, V1)

The course content is generated, not hand-written JSON. This folder contains
the seed datasets, the declarative curriculum plan, and the build script that
turns both into engine-ready assets for the Flutter app.

```
tools/curriculum/
  data/
    terms.mjs       36 Arabic terms (script, transliteration, meaning)
    sequences.mjs   9 ordered procedures (wudu, tayammum, rakah, ...)
    duas.mjs        18 supplications with scenario prompts + sources
    principles_a.mjs  authored MCQs: taharah + salah
    principles_b.mjs  authored MCQs: adab + akhlaq
    principles_c.mjs  authored MCQs: hasad + riya
  curriculum.mjs    module meta + units + lesson plans (declarative)
  build.mjs         generator: emits assets + sources doc
```

## Build / verify

```powershell
# from the repo root
node tools/curriculum/build.mjs

# from packages/ritualist_engine
dart run tool/validate_content.dart   # engine content rules against the assets
dart run tool/run_tests.dart          # includes a test over the real module
```

`build.mjs` is deterministic (seeded shuffles): rebuilding yields identical
output. It fails loudly on content-rule violations instead of emitting bad
assets.

Outputs:

| Path | Contents |
| --- | --- |
| `app/assets/modules/islam/module.json` | manifest + lesson summaries (loaded at startup) |
| `app/assets/modules/islam/units/<unit>.json` | full lesson bodies (lazy-loaded) |
| `docs/curriculum-sources.md` | generated source/grading review checklist |

## Adding content

- **New scenario question** - add a `q(prompt, correct, distractors, why, src)`
  entry to the right group in `principles_*.mjs`, then reference the group (or
  increase `limit`) in a lesson plan in `curriculum.mjs`.
- **New dua** - add an entry to `duas.mjs` (unique `translation` and
  `scenarioShort`; use `conflicts` to keep near-identical duas from ever
  becoming each other's distractor options), then place it in a lesson with
  `{ k: 'dua', id, mode }`.
- **New ordering exercise** - add a sequence to `sequences.mjs` (steps listed
  in CORRECT order, at least 3, unique) and reference it with
  `{ k: 'order', seq }`.
- **New term** - add it to `terms.mjs`, then use it in `match` / `termMeaning`
  / `meaningTerm` items.

## Content policy (V1 Islam module)

- Every exercise carries an `explanation` and a `source`; the engine's
  `ContentValidator` enforces this (`requireSources: true`).
- Hadith references use **exact numbers only when verified**; otherwise the
  collection + book name is cited. `grading` is stated whenever it matters
  (`sahih`, `hasan`, `da'if (weak ...)`) - never silently upgraded.
- The generated `docs/curriculum-sources.md` is the scholarly review checklist:
  flagged gradings (hasan / da'if / per-some) are listed at the top.
- Arabic script lives only in these seed files; a native speaker should
  proofread BOTH the Arabic text and the transliterations before any public
  release. See the module `disclaimer` in `curriculum.mjs`.

## Source of content truth

`curriculum.mjs` defines lesson ids as `islam.<unitId>.l<n>` and `build.mjs`
assigns exercise ids as `<lessonId>.e<n>`. Exercise ids are the seed for all
deterministic shuffles in the app, so never renumber lessons casually - it
reshuffles option order for returning learners (harmless, but noisy).
