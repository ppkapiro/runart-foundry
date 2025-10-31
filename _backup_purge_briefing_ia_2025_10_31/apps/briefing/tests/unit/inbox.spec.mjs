import { test, after } from "node:test";
import assert from "node:assert/strict";
import {
  createTestMiniflare,
  createRequest,
  writeReport,
  T2_REPORT_DIR,
  DEFAULT_TIMEOUT_MS,
  withTimeout,
} from "../config/test-utils.mjs";
import { DEFAULT_EMAILS } from "../config/miniflare-options.mjs";

const RESULTS = [];
const mf = await createTestMiniflare({ env: { RUNART_ENV: "preview" } });

after(async () => {
  try {
    await writeReport("inbox", { cases: RESULTS, reportDir: T2_REPORT_DIR });
  } finally {
    await mf.dispose();
  }
});

test("inbox allows owner", { timeout: DEFAULT_TIMEOUT_MS }, async () => {
  const request = createRequest("/api/inbox", { email: DEFAULT_EMAILS.owner });
  const res = await withTimeout(
    mf.dispatchFetch(request.url, request.init),
    "inbox owner"
  );
  const body = await res.json();
  assert.equal(res.status, 200);
  assert.equal(body.ok, true);
  assert.equal(body.role, "owner");
  RESULTS.push({ actor: "owner", status: res.status, body });
});

test("inbox allows team", { timeout: DEFAULT_TIMEOUT_MS }, async () => {
  const request = createRequest("/api/inbox", { email: DEFAULT_EMAILS.team });
  const res = await withTimeout(
    mf.dispatchFetch(request.url, request.init),
    "inbox team"
  );
  const body = await res.json();
  assert.equal(res.status, 200);
  assert.equal(body.ok, true);
  assert.equal(body.role, "team");
  RESULTS.push({ actor: "team", status: res.status, body });
});

test("inbox allows client_admin", { timeout: DEFAULT_TIMEOUT_MS }, async () => {
  const request = createRequest("/api/inbox", { email: DEFAULT_EMAILS.client_admin });
  const res = await withTimeout(
    mf.dispatchFetch(request.url, request.init),
    "inbox client_admin"
  );
  const body = await res.json();
  assert.equal(res.status, 200);
  assert.equal(body.ok, true);
  assert.equal(body.role, "client_admin");
  RESULTS.push({ actor: "client_admin", status: res.status, body });
});

test("inbox blocks client", { timeout: DEFAULT_TIMEOUT_MS }, async () => {
  const request = createRequest("/api/inbox", { email: DEFAULT_EMAILS.client });
  const res = await withTimeout(
    mf.dispatchFetch(request.url, request.init),
    "inbox client"
  );
  const body = await res.json();
  assert.equal(res.status, 403);
  assert.equal(body.ok, false);
  assert.equal(body.status, 403);
  RESULTS.push({ actor: "client", status: res.status, body });
});

test("inbox blocks visitor", { timeout: DEFAULT_TIMEOUT_MS }, async () => {
  const request = createRequest("/api/inbox");
  const res = await withTimeout(
    mf.dispatchFetch(request.url, request.init),
    "inbox visitor"
  );
  const body = await res.json();
  assert.equal(res.status, 403);
  assert.equal(body.ok, false);
  assert.equal(body.status, 403);
  RESULTS.push({ actor: "visitor", status: res.status, body });
});
