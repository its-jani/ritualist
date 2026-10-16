import fs from "node:fs";
import path from "node:path";

const cssDir = process.argv[2];
const cssFiles = fs.readdirSync(cssDir).filter((f) => f.endsWith(".css"));

const colors = new Map();
const fonts = new Set();
for (const f of cssFiles) {
  const text = fs.readFileSync(path.join(cssDir, f), "utf8");
  for (const m of text.matchAll(/--color-([a-zA-Z0-9_-]+)\s*:\s*([^;}]+)[;}]/g)) {
    if (!colors.has(m[1])) colors.set(m[1], m[2].trim());
  }
  for (const m of text.matchAll(/@font-face\{[^}]*font-family:([^;}]+)[;}]/g)) fonts.add(m[1].trim().replace(/["']/g, ""));
}

console.log(`color tokens: ${colors.size}`);
for (const [k, v] of colors) console.log(`--color-${k}: ${v}`);
console.log(`\nfont-faces: ${fonts.size}`);
for (const f of fonts) console.log(`- ${f}`);
