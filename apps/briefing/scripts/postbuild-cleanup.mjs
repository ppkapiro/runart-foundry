import { rm, stat } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const runEnv = (process.env.RUNART_ENV || '').toLowerCase();
// Resolve project root (apps/briefing)
const __dirname = path.dirname(fileURLToPath(import.meta.url));
const projectRoot = path.resolve(__dirname, '..');
const apiDir = path.join(projectRoot, 'site', 'api');

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

removeApiStub().catch((error) => {
  console.error('postbuild-cleanup failed:', error);
  process.exitCode = 1;
});
