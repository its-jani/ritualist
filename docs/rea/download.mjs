import fs from "node:fs";
import path from "node:path";

const listFile = process.argv[2];
const outDir = process.argv[3];
fs.mkdirSync(outDir, { recursive: true });

const urls = fs.readFileSync(listFile, "utf8").split(/\r?\n/).filter(Boolean);
const manifest = [];

for (const u of urls) {
  const name = new URL(u).pathname.split("/").pop();
  const dest = path.join(outDir, name);
  if (fs.existsSync(dest)) {
    console.log(`skip ${name} (exists)`);
    manifest.push({ url: u, file: name, bytes: fs.statSync(dest).size });
    continue;
  }
  try {
    const res = await fetch(u);
    if (!res.ok) {
      console.error(`FAIL ${res.status} ${u}`);
      continue;
    }
    const buf = Buffer.from(await res.arrayBuffer());
    fs.writeFileSync(dest, buf);
    manifest.push({ url: u, file: name, bytes: buf.length });
    console.log(`ok ${name} ${(buf.length / 1024).toFixed(0)} KB`);
  } catch (e) {
    console.error(`ERROR ${u}: ${e.message}`);
  }
}

fs.writeFileSync(path.join(outDir, "_manifest.json"), JSON.stringify(manifest, null, 2));
console.log(`\n${manifest.length} files -> ${outDir}`);
