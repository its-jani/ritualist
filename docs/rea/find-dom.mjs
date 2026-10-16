import fs from "node:fs";

const j = JSON.parse(fs.readFileSync(process.argv[2], "utf8"));

function walk(v, path) {
  if (v === null) return;
  if (typeof v === "string") {
    if (v.includes("</html>")) console.log(`HTML STRING at ${path} (${v.length} chars)`);
    return;
  }
  if (typeof v !== "object") return;
  if (Array.isArray(v)) {
    for (let i = 0; i < v.length; i++) walk(v[i], `${path}[${i}]`);
    return;
  }
  for (const [k, val] of Object.entries(v)) {
    const p = `${path}.${k}`;
    if (k === "dom" || k === "artifacts") {
      console.log(
        `${p} -> ${Array.isArray(val) ? `array(${val.length})` : typeof val}` +
          (val && !Array.isArray(val) && typeof val === "object"
            ? ` keys=${Object.keys(val).join(",")}`
            : ` value=${String(val).slice(0, 60)}`)
      );
    }
    walk(val, p);
  }
}

walk(j, "$");
