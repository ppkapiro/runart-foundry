import { test } from "node:test";
import { DEFAULT_TIMEOUT_MS } from "../config/test-utils.mjs";

import "../../functions/_middleware.js";
import "../../functions/api/whoami.js";
import "../../functions/api/inbox.js";
import "../../functions/api/decisiones.js";

test("handlers importan correctamente", { timeout: DEFAULT_TIMEOUT_MS }, () => {
  // Si los imports fallan, la ejecución lanzará antes de llegar aquí.
  console.log("[smoke-imports] OK");
});
