import fs from "node:fs";
import path from "node:path";

const dir = process.argv[2];
const outFile = process.argv[3];
const keywords = [
  "challenge",
  "exercise",
  "streak",
  "hearts",
  "crown",
  "crowns",
  "leaderboard",
  "league",
  "dailyGoal",
  "daily_goal",
  "combo",
  "queue",
  "lottie",
  "session",
  "correctSolution",
  "correct_solution",
  "choices",
  "pairs",
  "tokens",
  "word_bank",
  "tapComplete",
  "definition",
  "xpSummary",
  "xpGain",
  "totalXp",
  "siteData",
  "2023-",
  "wss://",
  "websocket",
  "api/",
  "audioURL",
  "tts",
  "hint",
  "grammar",
  "mistake",
];

const files = fs
  .readdirSync(dir)
  .filter((f) => f.endsWith(".js"))
  .sort();

const report = [];
report.push(`# Keyword mining report`);
report.push(`Bundles dir: ${dir}`);
report.push(`Files: ${files.join(", ")}`);
report.push("");

for (const f of files) {
  const text = fs.readFileSync(path.join(dir, f), "utf8");
  for (const kw of keywords) {
    let count = 0;
    let j = -1;
    while ((j = text.indexOf(kw, j + 1)) !== -1) count++;
    if (count === 0) continue;
    const samples = [];
    let i = -1;
    while (samples.length < 6 && (i = text.indexOf(kw, i + 1)) !== -1) {
      samples.push(
        text.slice(Math.max(0, i - 70), Math.min(text.length, i + 70)).replace(/\s+/g, " ")
      );
    }
    report.push(`## "${kw}" in ${f} — ${count} occurrence(s)`);
    for (const s of samples) report.push(`- …${s}…`);
    report.push("");
  }
}

fs.writeFileSync(outFile, report.join("\n"), "utf8");
console.log(`report -> ${outFile} (${report.length} lines)`);
