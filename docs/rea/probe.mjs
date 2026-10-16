import fs from "node:fs";

const j = JSON.parse(fs.readFileSync(process.argv[2], "utf8"));
const nr = j.normalized_result;

console.log("=== STEPS (shallow) ===");
for (const s of nr.steps) {
  console.log(`step ${s.step_index} id=${s.step_id} action=${s.action} status=${s.status}`);
  console.log(`  after_url=${JSON.stringify(s.after_url)}`);
  console.log(`  artifacts=${JSON.stringify(s.artifacts, null, 2)}`);
  if (s.completeness) console.log(`  completeness=${JSON.stringify(s.completeness)}`);
  if (s.error) console.log(`  error=${JSON.stringify(s.error)}`);
}

console.log("=== COMPLETENESS ===");
console.log(JSON.stringify(nr.completeness, null, 2));

console.log("=== LIMITATIONS ===");
for (const l of nr.limitations) console.log("-", l);

console.log("=== EVENTS ===");
for (const e of nr.events.items) {
  const line = [e.family, e.kind, e.url?.url ?? "", (e.text ?? e.message ?? "").slice(0, 160)].join(" | ");
  console.log(line);
}
