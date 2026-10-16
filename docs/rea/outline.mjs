import fs from "node:fs";

const file = process.argv[2];
const j = JSON.parse(fs.readFileSync(file, "utf8"));

function typeName(v) {
  if (Array.isArray(v)) return `array(${v.length})`;
  if (v === null) return "null";
  return typeof v;
}

function outline(v, path = "$", depth = 0, maxDepth = 4) {
  const t = typeName(v);
  console.log(`${"  ".repeat(depth)}${path}: ${t}`);
  if (depth >= maxDepth) return;
  if (Array.isArray(v)) {
    if (v.length > 0) outline(v[0], `${path}[0]`, depth + 1, maxDepth);
  } else if (v && typeof v === "object") {
    for (const k of Object.keys(v)) outline(v[k], `${path}.${k}`, depth + 1, maxDepth);
  } else if (typeof v === "string" && v.length > 120) {
    console.log(`${"  ".repeat(depth + 1)}${path} [string ${v.length} chars] ${v.slice(0, 100)}...`);
  }
}

outline(j, "$", 0, 3);
