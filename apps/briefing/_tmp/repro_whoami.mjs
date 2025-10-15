import { writeFile } from "node:fs/promises";
import { join } from "node:path";
import { createTestMiniflare, createRequest } from "../tests/config/test-utils.mjs";
import { DEFAULT_EMAILS } from "../tests/config/miniflare-options.mjs";

const REPORT_DIR = process.argv[2];
if (!REPORT_DIR) {
  console.error("Usage: node repro_whoami.mjs <report_dir>");
  process.exit(1);
}

const TARGETS = [
  { label: "owner", email: DEFAULT_EMAILS.owner },
  { label: "team", email: DEFAULT_EMAILS.team },
  { label: "client_admin", email: DEFAULT_EMAILS.client_admin },
  { label: "client", email: DEFAULT_EMAILS.client },
];

const env = {
  RUNART_ENV: "preview2",
  ROLE_RESOLVER_SOURCE: "utils",
  ROLE_MIGRATION_LOG: "1",
};

const mf = await createTestMiniflare({ env });

for (const target of TARGETS) {
  const { url, init } = createRequest("/api/whoami", { email: target.email });
  const response = await mf.dispatchFetch(url, init);
  const body = await response.text();
  const headers = {};
  for (const [key, value] of response.headers) {
    headers[key] = value;
  }
  const record = {
    status: response.status,
    headers,
    body,
  };
  const filePath = join(REPORT_DIR, `whoami_${target.label}.json`);
  await writeFile(filePath, JSON.stringify(record, null, 2), "utf8");
  console.log(`Saved ${filePath}`);
}

await mf.dispose();
