import { readFile, rm, stat, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const runEnv = (process.env.RUNART_ENV || '').toLowerCase();
// Resolve project root (apps/briefing)
const __dirname = path.dirname(fileURLToPath(import.meta.url));
const projectRoot = path.resolve(__dirname, '..');
const apiDir = path.join(projectRoot, 'site', 'api');
const routesFile = path.join(projectRoot, 'site', '_routes.json');

async function removeApiStub() {
  if (runEnv === 'local' || runEnv === '') {
    return; // Preserve stub for local workflows that rely on MkDocs serving it.
  }
  try {
    await stat(apiDir);
  } catch (error) {
    if (error && error.code === 'ENOENT') {
      return; // Nothing to clean up.
    }
    throw error;
  }

  // Remove the entire api directory to avoid static stubs shadowing Functions.
  await rm(apiDir, { recursive: true, force: true });
  console.log(`Removed static API stubs from ${apiDir} for RUNART_ENV=${runEnv}`);
}

async function ensureRoutesConfig() {
  let data;
  try {
    const raw = await readFile(routesFile, 'utf-8');
    data = JSON.parse(raw);
  } catch (error) {
    if (error && error.code === 'ENOENT') {
      data = { version: 1 };
    } else {
      throw error;
    }
  }

  const desiredIncludes = new Set(['/api/*', '/dash/*', '/errors/*']);
  const desiredExcludes = new Set([]);

  for (const entry of data.include || []) desiredIncludes.add(entry);
  for (const entry of data.exclude || []) {
    if (entry !== '/*') desiredExcludes.add(entry);
  }

  const next = {
    version: 1,
    include: Array.from(desiredIncludes).sort(),
    exclude: Array.from(desiredExcludes).sort(),
  };

  const current = JSON.stringify(data);
  const updated = JSON.stringify(next);
  if (current !== updated) {
    await writeFile(routesFile, `${JSON.stringify(next, null, 2)}\n`, 'utf-8');
    console.log(`Normalized ${routesFile} for Functions routing`);
  }
}

async function main() {
  await removeApiStub();
  await ensureRoutesConfig();
}

main().catch((error) => {
  console.error('postbuild-cleanup failed:', error);
  process.exitCode = 1;
});
