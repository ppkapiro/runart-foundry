import { readdirSync, readFileSync } from "node:fs";
import { dirname, join, relative } from "node:path";

function toFilePath(relativePath) {
  const url = new URL(relativePath, import.meta.url);
  let pathname = url.pathname;
  if (process.platform === "win32" && pathname.startsWith("/")) {
    pathname = pathname.slice(1);
  }
  return decodeURIComponent(pathname);
}

const projectRoot = toFilePath("../../");
const functionsPath = toFilePath("../../functions/");
const reportsRoot = toFilePath("../../_reports/tests/");
const testWorkerPath = toFilePath("./test-worker.mjs");
const TEST_WORKER_NAME = "./test-worker.mjs";
const testWorkerDir = dirname(testWorkerPath);
const bootstrapModulePath = join(testWorkerDir, "__bootstrap.mjs");
const functionsDir = toFilePath("../../functions/");
const functionsUrlRoot = new URL("../../functions/", import.meta.url);
const accessRolesPath = toFilePath("../../access/roles.json");
const accessRolesJson = readFileSync(accessRolesPath, "utf8");

const BOOTSTRAP_MODULE = {
  type: "ESModule",
  name: "bootstrap",
  path: bootstrapModulePath,
  contents: `import worker from "${TEST_WORKER_NAME}";

export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    if (url.pathname === "/__bootstrap__") {
      return new Response("bootstrap-ok", { status: 200 });
    }

    if (worker && typeof worker.fetch === "function") {
      return worker.fetch(request, env, ctx);
    }

    return new Response("worker-missing", { status: 500 });
  },
};`,
};

const TEST_WORKER_MODULE = {
  type: "ESModule",
  name: TEST_WORKER_NAME,
  path: testWorkerPath,
};

function collectFunctionModules() {
  const modules = [];

  function walk(dir) {
    const entries = readdirSync(dir, { withFileTypes: true });
    for (const entry of entries) {
      if (entry.name.startsWith(".")) continue;
      if (entry.isDirectory()) {
        if (entry.name === "node_modules" || entry.name === "dist") continue;
        walk(join(dir, entry.name));
      } else {
        const ext = entry.name.split(".").pop();
        if (!ext) continue;

        const absolutePath = join(dir, entry.name);
        const relPath = relative(functionsDir, absolutePath).replace(/\\/g, "/");
        const moduleName = new URL(relPath, functionsUrlRoot).href;

        if (ext === "js" || ext === "mjs") {
          if (relPath === "_utils/roles.js") {
            const source = readFileSync(absolutePath, "utf8");
            const patched = source.replace(
              /import\s+staticRoles\s+from\s+"..\/..\/access\/roles\.json"\s+with\s+\{\s*type:\s*"json"\s*\};?/,
              `const staticRoles = ${accessRolesJson};`
            );
            modules.push({
              type: "ESModule",
              name: moduleName,
              contents: patched,
              path: absolutePath,
            });
          } else {
            modules.push({
              type: "ESModule",
              name: moduleName,
              path: absolutePath,
            });
          }
        } else if (ext === "json") {
          const raw = readFileSync(absolutePath, "utf8");
          modules.push({
            type: "ESModule",
            name: moduleName,
            contents: `export default ${raw};`,
            path: absolutePath,
          });
        }
      }
    }
  }

  walk(functionsDir);
  return modules;
}

const defaultFunctionModules = collectFunctionModules();

function sanitizeModules(input = []) {
  if (!Array.isArray(input)) {
    throw new Error("[mf-options] overrides.modules debe ser un arreglo de módulos");
  }

  return input
    .filter((module, index) => {
      if (!module || typeof module !== "object") {
        console.warn(`[mf-options] módulo inválido en overrides.modules[${index}] → descartado`);
        return false;
      }

      const hasPath = typeof module.path === "string" && module.path.length > 0;
      const hasContents = typeof module.contents === "string" && module.contents.length > 0;

      if (!hasPath && !hasContents) {
        console.warn(
          `[mf-options] módulo sin path ni contents en overrides.modules[${index}] → descartado`
        );
        return false;
      }

      if (module.type && module.type !== "ESModule") {
        console.warn(
          `[mf-options] módulo overrides.modules[${index}] con type=${module.type}; se forzará a ESModule`
        );
      }

      return true;
    })
    .map((module) => ({
      ...module,
      type: "ESModule",
    }));
}

function buildModules(overrides) {
  const sanitizedOverrides = overrides?.modules ? sanitizeModules(overrides.modules) : [];
  const modules = [BOOTSTRAP_MODULE, TEST_WORKER_MODULE, ...defaultFunctionModules, ...sanitizedOverrides];

  if (modules.length === 0) {
    throw new Error("[mf-options] No hay módulos válidos disponibles para Miniflare");
  }

  if (modules.some((module) => !module.path && !module.contents)) {
    throw new Error("[mf-options] modules contiene entradas sin path/contents tras saneo");
  }

  return modules;
}

export const DEFAULT_EMAILS = {
  owner: "ppcapiro@gmail.com",
  client_admin: "runartfoundry@gmail.com",
  client: "musicmanagercuba@gmail.com",
  team: "infonetwokmedia@gmail.com",
  visitor: "",
};

export function createMiniflareOptions(overrides = {}) {
  const sanitizedModules = buildModules(overrides);
  const {
    modules: _ignoredModules,
    bindings: overrideBindings = {},
    compatibilityDate = "2025-10-01",
    compatibilityFlags = ["nodejs_compat"],
    kvNamespaces = ["RUNART_ROLES", "LOG_EVENTS", "DECISIONES"],
    durableObjects = {},
    watch = false,
    liveReload = false,
    main = TEST_WORKER_NAME,
    env = "preview",
    ...rest
  } = overrides;

  const options = {
    modules: sanitizedModules,
    main,
    compatibilityDate,
    kvNamespaces,
    durableObjects,
    watch,
    liveReload,
    compatibilityFlags,
    bindings: {
      RUNART_ENV: env,
      ...overrideBindings,
    },
    ...rest,
  };

  if (!options.modules || options.modules.length === 0) {
    throw new Error("[mf-options] Config final sin módulos válidos");
  }

  return options;
}

export function getProjectPaths() {
  return {
    projectRoot,
    functionsPath,
    reportsRoot,
    testWorkerPath,
  };
}
