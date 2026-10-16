// Tiny authoring helpers shared by the curriculum seed datasets.
//
// `s(collection, reference, grading, text)` builds a SourceRef-shaped object:
//   { collection, reference, grading, text }
// `grading` and `text` may be omitted when not applicable.
//
// `q(prompt, correct, distractors, explanation, source)` builds an authored
// multiple-choice item. The CORRECT option is always listed first in the seed
// file; build.mjs shuffles options deterministically and computes
// `correctIndex`, so seeds can never drift out of sync with an index.

export const s = (collection, reference, grading, text) => {
  const out = { collection, reference };
  if (grading != null) out.grading = grading;
  if (text != null) out.text = text;
  return out;
};

export const q = (prompt, correct, distractors, explanation, source) => ({
  prompt,
  correct,
  distractors,
  explanation,
  source,
});
