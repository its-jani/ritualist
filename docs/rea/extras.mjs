import fs from "node:fs";
import path from "node:path";

// 1) CSS design tokens
const cssDir = process.argv[2];
const out = [];

out.push("# Duolingo CSS design tokens & metrics\n");
const cssFiles = fs.readdirSync(cssDir).filter((f) => f.endsWith(".css"));
const tokens = new Map();
for (const f of cssFiles) {
  const text = fs.readFileSync(path.join(cssDir, f), "utf8");
  for (const m of text.matchAll(/--([a-zA-Z0-9-_]+)\s*:\s*([^;}]+)[;}]/g)) {
    if (!tokens.has(m[1])) tokens.set(m[1], m[2].trim());
  }
}
out.push(`Custom properties found: ${tokens.size}`);
for (const [k, v] of [...tokens.entries()].slice(0, 120)) out.push(`- --${k}: ${v}`);

// 2) Manifest chunk names
const manifestFile = process.argv[3];
const manifest = fs.readFileSync(manifestFile, "utf8");
const chunkNames = new Map();
for (const m of manifest.matchAll(/"?([0-9]+)"?\s*:\s*"([a-zA-Z0-9_-]+)"/g)) {
  chunkNames.set(m[1], m[2]);
}
out.push(`\n# Webpack named chunks (from manifest): ${chunkNames.size}`);
for (const [id, name] of chunkNames) out.push(`- ${id}: ${name}`);

// 3) Fonts
const fontMatches = new Set();
for (const f of cssFiles) {
  const text = fs.readFileSync(path.join(cssDir, f), "utf8");
  for (const m of text.matchAll(/font-family:([^;}]+)[;}]/g)) fontMatches.add(m[1].trim().slice(0, 120));
}
out.push(`\n# Font families: ${fontMatches.size}`);
for (const f of [...fontMatches].slice(0, 30)) out.push(`- ${f}`);

fs.writeFileSync(process.argv[4], out.join("\n"), "utf8");
console.log(`tokens=${tokens.size} chunks=${chunkNames.size} fonts=${fontMatches.size} -> ${process.argv[4]}`);
