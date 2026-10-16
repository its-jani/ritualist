// One-time asset fetcher (zero dependencies).
//
// Ritualist bundles the Nunito typeface (SIL Open Font License) so the app
// never needs network access at runtime. Run from the repo root:
//
//   node tools/fonts/fetch.mjs
//
// Idempotent: skips files that already exist and are non-empty.
import fs from 'node:fs';
import path from 'node:path';

const repoRoot = path.resolve(path.dirname(new URL(import.meta.url).pathname.replace(/^\/([A-Za-z]:)/, '$1')), '..', '..');
const outDir = path.join(repoRoot, 'app', 'assets', 'fonts');

const BASE = 'https://raw.githubusercontent.com/google/fonts/main/ofl/nunito';
const FILES = [
  { url: `${BASE}/Nunito%5Bwght%5D.ttf`, name: 'Nunito-VariableFont_wght.ttf' },
  { url: `${BASE}/Nunito-Italic%5Bwght%5D.ttf`, name: 'Nunito-Italic-VariableFont_wght.ttf' },
  { url: `${BASE}/OFL.txt`, name: 'OFL.txt' },
];

fs.mkdirSync(outDir, { recursive: true });

for (const f of FILES) {
  const dest = path.join(outDir, f.name);
  if (fs.existsSync(dest) && fs.statSync(dest).size > 0) {
    console.log(`skip  ${f.name} (exists)`);
    continue;
  }
  const res = await fetch(f.url);
  if (!res.ok) {
    console.error(`FAIL  ${f.name}: HTTP ${res.status}`);
    process.exitCode = 1;
    continue;
  }
  const buf = Buffer.from(await res.arrayBuffer());
  if (buf.length < 512) {
    console.error(`FAIL  ${f.name}: suspiciously small (${buf.length} bytes)`);
    process.exitCode = 1;
    continue;
  }
  fs.writeFileSync(dest, buf);
  console.log(`ok    ${f.name} (${buf.length} bytes)`);
}
console.log('fonts ready in', outDir);
