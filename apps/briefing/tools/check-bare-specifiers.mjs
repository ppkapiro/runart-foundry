#!/usr/bin/env node
import { readdir, readFile } from "node:fs/promises";
import { extname, dirname, join } from "node:path";
import process from "node:process";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const testsRoot = join(__dirname, "../tests");
const VALID_EXTENSIONS = new Set([".mjs", ".js"]);

async function collectFiles(dir) {
  const entries = await readdir(dir, { withFileTypes: true });
  const files = [];
  for (const entry of entries) {
    const fullPath = join(dir, entry.name);
    if (entry.isDirectory()) {
      files.push(...(await collectFiles(fullPath)));
    } else if (VALID_EXTENSIONS.has(extname(entry.name))) {
      files.push(fullPath);
    }
  }
  return files;
}

async function main() {
  const files = await collectFiles(testsRoot);
  const offenders = [];

  for (const file of files) {
    const content = await readFile(file, "utf8");
    const matches = findBareSpecifiers(content);
    if (matches.length > 0) {
      offenders.push({ file, matches });
    }
  }

  if (offenders.length > 0) {
    console.error("[check-bare-specifiers] Imports bare detectados:");
    for (const { file, matches } of offenders) {
      for (const { line, context } of matches) {
        console.error(` - ${file}:${line} → ${context}`);
      }
    }
    console.error("Reemplaza todos los imports por rutas relativas ESM con extensión .js.");
    process.exit(1);
  }

  console.log("[check-bare-specifiers] Sin imports bare. ✔");
}

main().catch((error) => {
  console.error("[check-bare-specifiers] Error al analizar imports", error);
  process.exit(1);
});

function findBareSpecifiers(source) {
  const hits = [];
  const regex = /functions\//g;
  let match;
  while ((match = regex.exec(source)) !== null) {
    if (isBareSpecifier(source, match.index)) {
      const line = source.slice(0, match.index).split("\n").length;
      const context = source
        .split("\n")[line - 1]
        ?.trim()
        ?.slice(0, 200);
      hits.push({ line, context: context ?? "(sin contexto)" });
    }
  }
  return hits;
}

function isBareSpecifier(source, index) {
  for (let i = index - 1; i >= 0; i--) {
    const char = source[i];
    if (char === "'" || char === '"' || char === "`") {
      if (source[i - 1] === "\\") {
        i -= 1;
        continue;
      }
      const first = source[i + 1];
      if (first === ".") return false;
      if (first === "/") {
        const next = source[i + 2];
        if (next === ".") return false;
      }
      return true;
    }
    if (char === "\n") break;
  }
  return true;
}
