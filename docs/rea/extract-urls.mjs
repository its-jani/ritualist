import fs from "node:fs";

const j = JSON.parse(fs.readFileSync(process.argv[2], "utf8"));
const outDir = process.argv[3] ?? ".";
const nr = j.normalized_result;

// Locate the captured DOM html defensively (steps[].artifacts.dom.value.text)
let html = null;
for (const s of nr.steps ?? []) {
  const dom = s?.artifacts?.dom;
  if (dom?.state === "captured" && typeof dom?.value?.text === "string") {
    html = dom.value.text;
  }
}
if (!html) {
  console.error("NO DOM FOUND");
  process.exit(1);
}

fs.writeFileSync(`${outDir}/home-dom.html`, html, "utf8");
console.log(`DOM html: ${html.length} chars -> home-dom.html`);

const uniq = (arr) => [...new Set(arr)];

// script srcs
const scriptSrcs = uniq([...html.matchAll(/<script[^>]+src=["']([^"']+)["']/gi)].map((m) => m[1]));
// stylesheets & preloads
const linkHrefs = uniq(
  [...html.matchAll(/<link[^>]+href=["']([^"']+)["'][^>]*>/gi)].map((m) => m[1])
);
// any duolingo CDN references anywhere (JSON in scripts etc.)
const cdnRefs = uniq(
  [...html.matchAll(/https:\/\/[a-z0-9.-]*duolingo[a-z0-9.-]*\/[A-Za-z0-9._/-]+\.(?:js|css)/gi)].map((m) => m[0])
);
const cloudfrontRefs = uniq(
  [...html.matchAll(/https:\/\/d35aaqx5ub95lt\.cloudfront\.net\/[A-Za-z0-9._/-]+/gi)].map((m) => m[0])
);

console.log("\n=== SCRIPT SRCS ===");
for (const s of scriptSrcs) console.log(s);
console.log("\n=== LINK HREFS (js/css only) ===");
for (const h of linkHrefs) if (/\.(js|css)$/i.test(h)) console.log(h);
console.log("\n=== CDN REFS (duolingo hosts, js/css) ===");
for (const c of cdnRefs) console.log(c);
console.log("\n=== CLOUDFRONT REFS ===");
for (const c of cloudfrontRefs) console.log(c);

// Write download list: duolingo-owned js only
const duolingoJs = uniq(
  [...scriptSrcs, ...linkHrefs, ...cdnRefs, ...cloudfrontRefs].filter(
    (u) =>
      /^https:\/\//.test(u) &&
      /(duolingo\.com|cloudfront\.net)/.test(u) &&
      /\.js($|\?)/.test(u)
  )
);
fs.writeFileSync(`${outDir}/download-list.txt`, duolingoJs.join("\n"), "utf8");
console.log(`\nDownload list: ${duolingoJs.length} JS URLs -> download-list.txt`);
