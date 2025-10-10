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
    await writeReport("whoami", { cases: RESULTS, reportDir: T2_REPORT_DIR });
  } finally {
    await mf.dispose();
  }
});

const CASES = [
  {
    label: "owner",
    email: DEFAULT_EMAILS.owner,
    expectedRole: "owner",
    expectedAlias: "propietario",
  },
  {
    label: "client_admin",
    email: DEFAULT_EMAILS.client_admin,
    expectedRole: "client_admin",
    expectedAlias: "cliente_admin",
  },
  {
    label: "client",
    email: DEFAULT_EMAILS.client,
    expectedRole: "client",
    expectedAlias: "cliente",
  },
  {
    label: "team",
    email: DEFAULT_EMAILS.team,
    expectedRole: "team",
    expectedAlias: "equipo",
  },
  {
    label: "visitor",
    email: null,
    expectedRole: "visitor",
    expectedAlias: "visitante",
  },
];

for (const scenario of CASES) {
  test(
    `whoami returns role for ${scenario.label}`,
    { timeout: DEFAULT_TIMEOUT_MS },
    async () => {
      const request = createRequest("/api/whoami", {
        email: scenario.email,
      });
      const res = await withTimeout(
        mf.dispatchFetch(request.url, request.init),
        `whoami ${scenario.label}`
      );

      assert.equal(res.status, 200);
      const bodyText = await res.text();
      const json = JSON.parse(bodyText);

      assert.equal(json.ok, true);
      assert.equal(json.role, scenario.expectedRole);
      assert.equal(json.rol, scenario.expectedAlias);
      assert.equal(json.env, "preview");
      if (scenario.email) {
        assert.equal(json.email, scenario.email);
      } else {
        assert.equal(json.email, null);
      }
      assert.match(json.ts, /^\d{4}-\d{2}-\d{2}T/);

      RESULTS.push({
        case: scenario.label,
        status: res.status,
        response: json,
      });
    }
  );
}
