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
    await writeReport("decisiones", { cases: RESULTS, reportDir: T2_REPORT_DIR });
  } finally {
    await mf.dispose();
  }
});

test("decisiones rejects unauthenticated POST", { timeout: DEFAULT_TIMEOUT_MS }, async () => {
  const request = createRequest("/api/decisiones", { method: "POST", body: {} });
  const res = await withTimeout(
    mf.dispatchFetch(request.url, request.init),
    "decisiones unauth"
  );
  const body = await res.json();
  assert.equal(res.status, 401);
  assert.equal(body.ok, false);
  assert.equal(body.role, "visitor");
  RESULTS.push({ scenario: "without_email", status: res.status, body });
});

test("decisiones accepts authenticated POST", { timeout: DEFAULT_TIMEOUT_MS }, async () => {
  const request = createRequest("/api/decisiones", {
    method: "POST",
    email: DEFAULT_EMAILS.owner,
    body: { tipos: ["reunion"], notas: "ok" },
  });
  const res = await withTimeout(
    mf.dispatchFetch(request.url, request.init),
    "decisiones auth"
  );
  const body = await res.json();
  assert.equal(res.status, 200);
  assert.equal(body.ok, true);
  assert.equal(body.role, "owner");
  RESULTS.push({ scenario: "with_email", status: res.status, body });
});
