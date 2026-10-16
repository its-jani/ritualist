import fs from "node:fs";

const html = fs.readFileSync(process.argv[2], "utf8");
const colors = new Map();
for (const m of html.matchAll(/--color-([a-zA-Z0-9_-]+)\s*:\s*([^;}"]+)[;}]/g)) {
  if (!colors.has(m[1])) colors.set(m[1], m[2].trim());
}
console.log(`color tokens in HTML: ${colors.size}`);
for (const [k, v] of [...colors.entries()].slice(0, 80)) console.log(`--color-${k}: ${v}`);

// font-face urls in html
const fonts = new Set();
for (const m of html.matchAll(/@font-face\s*\{[^}]*\}/g)) {
  const fam = /font-family:\s*([^;}]+)/.exec(m[0]);
  const url = /url\(([^)]+)\)/.exec(m[0]);
  if (fam) fonts.add(`${fam[1].trim()} <- ${url ? url[1].slice(0, 90) : "no url"}`);
}
console.log(`\nfont-faces in HTML: ${fonts.size}`);
for (const f of [...fonts].slice(0, 20)) console.log(`- ${f}`);
