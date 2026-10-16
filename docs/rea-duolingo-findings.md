# REA Findings: Duolingo (local install) → Ritualist design inputs

Date: 2026-10-16 · Analyst: Qoder (REA CLI v6.5.0)
Target: user-owned local Duolingo installation on this machine.

> Legal/ethical note: this inspection studies **behavioral patterns, data schemas and
> design-token relationships** of a user-owned app for interoperability/inspiration.
> Ritualist reimplements mechanics with **original code, original art and a distinct
> palette/typeface**. No Duolingo assets, artwork, copy, mascot, fonts or code are
> copied. Duolingo's owl mascot, name and brand are trademarks and are not used.

## 1. Target identity & method

| Item | Value |
|---|---|
| Shortcut inspected | `D:\OneDrive\Desktop\Duolingo.lnk` |
| Shortcut target | `msedge_proxy.exe --app-id=jneocipojkkahfcibhjaiilegofacenn --app-url=https://www.duolingo.com/` → **Edge PWA (web app)** |
| Secondary install (not analyzed) | MS Store AppX `D5EA27B7.Duolingo-LearnLanguagesforFree 1.178.3.0` |
| Runtime used | Edge 155 headless, temporary clean profile, loopback CDP `http://127.0.0.1:9222` |
| REA evidence | `ev_36739cea…` (target list), `ev_7073a0da…` (web-bundle analysis), scenario 425 KB capture |

REA operations performed (all via `rea` CLI 6.5.0):

1. `rea list-browser-targets` → page target on `https://www.duolingo.com/`.
2. `rea analyze-web-bundle` (landing, already-loaded → only late inline scripts; rejected as insufficient).
3. `rea capture-browser-scenario` (connect mode; navigated to `/learn`, 8 s settle; DOM + console + page-errors). Limitations hit and workarounds — see §7.
4. Bundle download (public static CDN assets observed in captured DOM) into `evidence/bundles/` + `evidence/css/`.
5. `rea analyze-javascript-application` on the bundle tree → complete application graph retained (`evidence/js-app-graph.json`, 162 MB; summary/projections intentionally not re-run — see §7).
6. Local mining passes over retained sources: `keyword-report.md`, `tokens-report.md`, `home-dom.html`.

Known limitation: the 9 analyzed artifacts are the **logged-out webapp surface** (marketing + app shell + bundles). The authenticated path/lesson UI cannot be rendered headlessly without the user's session; behavior claims below distinguish **observed in bundles** vs **inferred/common knowledge**.

## 2. Observed application architecture (evidence: bundles/, keyword-report.md)

- **Webpack chunked SPA.** `window.duo` global namespace (`window.duo.l10n.strings`, `window.duo.supportedFeatures`). Named chunks: `homePage`, `path`, `pathSections`, `session`, `evergreenPage`, `lottie_light_canvas`, plus `debug*`. 291 chunk entries in `manifest-9de2ea75.js` — route-level code splitting; e.g. the **lesson ("session") UI is a separate lazily loaded chunk**.
- **Runtime capability gating**: `features-*.js` detects ~26 browser capabilities (CSS container units, `:has()`, BigInt, WeakRef, CompressionStream, SpeechRecognition…) and exposes `window.duo.supportedFeatures` with `no-<name>` markers.
- **Offline-first machinery** (very relevant to Ritualist): IndexedDB object stores incl. `queue`, `submittableRequests`, `prefetchedSessions`; telemetry `"prefetch_sessions_end"` records `download_time_seconds` — **lessons are prefetched ahead of time** and answers are queued offline (`submittableRequests`) then flushed (`remove_user_heart_failed` implies POST-answer flows can fail and retry).
- **State management**: Redux-style action objects observed, e.g. `{type:"UPDATE_USER", …}`, `{type:"UPDATE_HEARTS_STATE", currentTimestampMs, heartsConfig, type:"UPDATE_HEARTS_STATE"}`, `SET_LEADERBOARD_POSITION_STATE`, `SEARCH…`. Challenge/session state is immutable-patch style (`UPDATE_CHALLENGE_STATE` family).
- **Localization**: numeric message-ID table (`748:"Correct!"`, `10549:"Hard exercise"`…), ICU-style placeholders `{{plural:cardinal:streak}}`, `{{num:…}}`, `{{select:…}}`, `{{group:language:language_name}}`; per-snippet tracking properties.
- **API surface (observed)**: versioned base (`"/2023-05-23"` prefix builder), `POST https://excess.duolingo.com/challenge_response/batch` (challenge telemetry with `challenge_response_timestamp`), `GET /users/{id}/streak-goal-current` & `streak-goal-next-options` (404 logged-out but paths observed), `Idempotency-Key` header constant, `/api/v1/sessions/math-tutor` pattern.
- **Route evidence**: client paths `/leaderboard`, `/shop`, `/characters`, `/learn`; onboarding funnel step IDs: `coursePicker → proficiency → learningReason → dailyGoal → courseOverview → notificationPrimer/accountLink → choosePath`.

## 3. UI/UX pattern inventory (the addictive loop)

Observed in bundles/strings unless marked "inferred".

**a. Path tree** — chunk names `path`, `pathSections`; data: `sectionedPath`, `unitIndex`, `pathLevelClientData.crownLevelIndex`, per-level scopes `skill/story/alphabetsPathProgressKey`; assignment types `SKILL|STORY`; modes incl. `LEGENDARY` (`isLegendaryMode`, `--color-legendary-foreground: 140,65,3`). *Inferred (well-known product behavior):* vertical winding trail of circular nodes; active node pulses; unit color-band headers; locked nodes grey.

**b. Strengths/streak systems** — `streakData.currentStreak / longestStreak / previousStreak`; shop item `streak_freeze`; strings: "Reach a {{num}} day streak", "You're two days away from a {{num}} day streak", "Streak Freeze allows your streak to remain intact…"; streak repair flow (`streakRepairOffer`, `REPAIR`/earn-back sessions).

**c. Hearts (lives)** — `health`/`heartsConfig` on user; `maxHearts`; session types incl. `unlimitedHearts`; "You need hearts to start new lessons!", "You ran out of hearts!", "You have no hearts left! Try an option below"; `completedWithHeartsRemaining` grants bonus XP; `heartsInSession` UI callbacks.

**d. XP & economy** — `xpGains`, `xpGoal` (per-day target, `dailyGoalXp`), `gainedXp`, `numSessions`, `frozen`, `repaired`, `totalXp`, `totalXpThisSession`, `totalXpToday`; bonus: `enableBonusPoints`, `bonusXp`; gems (`gemsInHomepage`); shop (`shopItems`, `shop.misc.streak_freeze`).

**e. Combos & instant feedback** — combo counter strings: "Amazing! {{num}} in a row!", "Outstanding! …"; feedback strings "Correct!", "Common mistake!", "You have an extra space.", "Correct solution:", "Let's review the exercise you missed!", "Challenge complete!"; hints: `hintsShown/hintsUsed/hintPosition`.

**f. Lesson session model** — `session.challenges[]`, `challengeStates[]` (per-challenge: `completed`, `hintsUsed`, `score`, `maxScore`, `hintPosition`), `currentIndex`, `furthestPosition`; **mistake re-injection**: `mistakesReplacementChallenges[]` + `mistakesReplacementChallengeIndex` — missed challenges are re-queued into the same session (evidence: `mistakesReplacementChallenges[t.length]=a`).

**g. Meta-game** — leaderboards & leagues (SVG assets `images/leagues/*.svg`, strings "Complete a lesson to join this week's leaderboard", "Top {{num}} advance to the next league", "You finished #…#"); tournaments ("Your stats from the tournament"); daily quests framework with tiers DAILY/CORE/HARD (`daily_goal_daily_quest`, `combo_xp_core_daily_quest`, `five_in_a_row_core_daily_quest`, `eighty_accuracy_lessons_hard_daily_quest`…).

**h. Motion** — Lottie animations (`lottie` chunk + `lottie_light_canvas`, JSON effects, `--funboarding-duo-offset-*` CSS vars, `reduced_motion` handling). *Inferred:* node pulses, XP count-up, mascot bobbing; we adopt the *economy of motion* (few, juicy, cheap implicit animations) without Lottie.

## 4. Lesson/exercise schema (observed challenge types & fields)

**Challenge type enum (observed literal values):** `tapCloze`, `tapClozeTable`, `tapComplete`, `tapCompleteTable`, `tapDescribe`, `translate`, `completeReverseTranslation`, `partialReverseTranslate`, `definition`, `dialogue`, `match`, `extendedMatch`, `listenMatch`, `extendedListenMatch`, `radioListenRecognize`, `radioListenMatch`, `selectPronunciation`, `selectTranscription`, `characterMatch`, `syllableTap`, `orderTapComplete…`, `listenComplete`, `partialListen`, `listenIsolation`. Telemetry maps to snake_case (`complete_reverse_translation`, `definition`, `dialogue`, `extended_match`…).

**Challenge object fields (observed):**

| Field | Meaning |
|---|---|
| `type` | challenge-type enum above |
| `prompt` | instruction string |
| `choices: [{text, correctIndex}]` | MCQ/listen select; **ordering uses `choices` + `correctIndex` + `currentOrder`** (evidence: `currentOrder.every((v,i) => choices[v].correctIndex === i)`) |
| `correctIndices: []` | accepted indexes (multi-answer) |
| `correctSolutions: []` | expected text solution(s) (grading + "correct solution" replay) |
| `pairs: [{learningToken|learningWord, translation, character, tts}]` | match-type content (token/translation pairs, script chars for e.g. characterMatch) |
| `tokens / displayTokens: [{text, isBlank}]` | token-bank & cloze content (`blankStartIndex`, `blankEndIndex`) |
| `tts`, `slowTts` | audio URLs per challenge |
| `challengeGeneratorIdentifier`, `challengeResponseTrackingProperties` | generation + telemetry metadata |
| `explanation`, `character`, `solutionTranslation` | post-answer content |
| per-state | `mistakeCount`, `hintsShown`, `score/maxScore` |

**Inferences for our schema (informed, not copied):** MC → options+correctIndex; **ordering** → ordered array of step tokens; **matching** → pairs with stable ids; every exercise carries optional `explanation` + `source` for post-answer learning (Duolingo: `explanation`/`solutionTranslation`).

## 5. Design tokens (evidence: tokens-report.md, html-colors.mjs output)

- **Color system**: semantic animal-named RGB triplets (300 tokens), with `-always-dark`/`-always-light` variants for theme stability. Anchor values incl.: `owl 88,204,2` (brand green #58CC02), `tree-frog 88,167,0` (darker "lip" of green buttons), `macaw 28,176,246`, `cardinal 255,75,75`, `fox 255,150,0` (streak), `bee 255,200,0`, `hare 175,175,175` (inactive), `swan 229,229,229` (borders), `wolf 119,119,119`, `eel 75,75,75`, `polar 247,247,247` (bg), `black-text 60,60,60`, dark theme: `manta-ray 4,44,96`, `eclipse 0,4,55`.
- **Component tokens**: `--web-ui_button-*` → height 50px, border-radius 12px, **`lip-width: 4px`** (the signature 3-D bottom edge), disabled→hare, borders `whale`; button text 17px / letter-spacing 0.8px / bold.
- **Typography scale**: `--text-heading-*` (700 weight, 2rem→1rem sizes), `--text-body-*` (500, 1.25rem/1.75rem), `--text-caption-*` (1rem), `--text-label-*` (uppercase, 700, letter-spacing 0.04em). Fonts: `duolingo-sans` (UI), `DIN Next for Duolingo` (display), `feather` (icon font), KaTeX (math course).
- **RTL/motion/environment**: `--rtl-sign: 1`, `--viewport-height: 100dvh`, reduced-motion respected.

**Ritualist adoption (original):** same *relationships* (brand base + darker lip shade; neutral ramp; one alert red; one reward amber; uppercase bold small labels with wide tracking; chunky 12–16px radii), **different values & names** (own palette, Nunito-family rounded font bundled locally).

## 6. Performance lessons → Ritualist budget

1. **Code-split by route** (chunk names prove it) → Flutter: heavy screens stay small; engine package has zero deps.
2. **Prefetch the next lesson** while user browses path (observed `prefetchedSessions`) → Ritualist: lesson JSON is asset-bundled & loaded on demand + cached in memory; prefetch next unit silently.
3. **Offline submission queue** (`submittableRequests`) → Ritualist: all progress writes are local-first (JSON store), no network in v1.
4. **Only animate what changes** (implicit animations vs Lottie) to keep the <150 MB target.
5. **Static content, tiny runtime** — engine is pure logic; UI uses Flutter SDK only (no animation/state/DB packages), fonts subset to 4 weights.

## 7. REA tooling notes (for future passes)

- `capture-browser-scenario` **blocks service workers by default** → `environment.service_workers: "allow"` required for SW-controlled origins (`target_not_allowed` otherwise).
- REA 6.5.0 bug: scenarios with `events: ["network"]` crash on responses with status `0` (`ZodError status>=100`); workaround: `["console","page-errors"]` + reconstruct network from DOM/resources.
- `analyze-web-bundle` only observes scripts **during** the window; on an already-loaded page expect only late inline scripts — navigate the target for a fresh load instead (scenario) or analyze extracted bundles.
- The 162 MB application graph was produced by the CLI; `inspect-analysis-view` projections (module pages) require the **same retained MCP session**, so projections were replaced by direct local mining (equivalent evidence, cited above). Re-run via MCP for canonical module pages if needed.
- Headless Edge must be launched detached from the agent shell's job (WMI `Win32_Process.Create`) or it is killed when the shell exits.
- Evidence files: `docs/rea/evidence/` (scenario JSON, DOM, bundles, css, reports) + helper scripts in `docs/rea/*.mjs` (reproducible pipeline).

## 8. Residual unknowns

- Authenticated path/lesson DOM & pixel states (login wall) — patterns above rely on bundle evidence + product behavior.
- Source maps: not fetched (`--fetch-source-maps` possible on a rerun with network); module names are webpack-minified.
- Exact numeric message-ID ↔ string tables not exhaustively decoded (samples only).
- Server-side session/completion APIs and their JSON shapes (only client field names observed).
