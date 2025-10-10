import { test } from "node:test";
import assert from "node:assert/strict";
import { createMiniflareOptions } from "../config/miniflare-options.mjs";

function ensureModuleHasSource(module) {
  assert.ok(
    typeof module.path === "string" && module.path.length > 0 ||
      typeof module.contents === "string" && module.contents.length > 0,
    `El módulo ${module.name ?? "<sin nombre>"} debe tener path o contents`
  );
}

test("createMiniflareOptions incluye bootstrap y worker por defecto", () => {
  const options = createMiniflareOptions();
  assert.ok(Array.isArray(options.modules));
  assert.ok(options.modules.length >= 2, "Se esperan al menos bootstrap y worker");

  const [bootstrap, worker] = options.modules;
  assert.equal(bootstrap.name, "bootstrap");
  assert.ok(
    typeof bootstrap.path === "string" && bootstrap.path.endsWith("__bootstrap.mjs"),
    "Bootstrap debe apuntar al archivo auxiliar"
  );
  ensureModuleHasSource(bootstrap);

  assert.equal(worker.name, "./test-worker.mjs");
  assert.ok(
    typeof worker.path === "string" && worker.path.endsWith("test-worker.mjs"),
    "El worker de pruebas debe resolverse a su archivo"
  );
  ensureModuleHasSource(worker);

  for (const module of options.modules) {
    ensureModuleHasSource(module);
    assert.equal(module.type, "ESModule");
  }

  assert.equal(options.main, "./test-worker.mjs");
  assert.equal(options.bindings.RUNART_ENV, "preview");
  assert.ok(options.compatibilityFlags.includes("nodejs_compat"));
});

test("createMiniflareOptions sanea overrides inválidos y conserva módulos válidos", () => {
  const baseModules = createMiniflareOptions().modules.length;

  const override = createMiniflareOptions({
    env: "staging",
    modules: [
      null,
      {},
      { name: "virtual:ok", contents: "export const ok = 42;", type: "Data" },
    ],
  });

  assert.equal(override.bindings.RUNART_ENV, "staging");
  assert.equal(override.modules.length, baseModules + 1);

  const extra = override.modules.at(-1);
  assert.equal(extra.name, "virtual:ok");
  assert.equal(extra.type, "ESModule");
  assert.ok(extra.contents.includes("ok = 42"));
  ensureModuleHasSource(extra);
});

test("createMiniflareOptions rechaza overrides.modules que no sean arreglos", () => {
  assert.throws(
    () => createMiniflareOptions({ modules: "no" }),
    /debe ser un arreglo/
  );
});
