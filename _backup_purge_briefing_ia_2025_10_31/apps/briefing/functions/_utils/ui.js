import { roleToAlias } from "./roles.js";

const ROLE_SEGMENTS = {
  owner: "/dash/owner",
  client_admin: "/dash/client",
  client: "/dash/client",
  team: "/dash/team",
  visitor: "/dash/visitor",
};

const ROLE_LABELS = {
  owner: "Owner",
  client_admin: "Client admin",
  client: "Client",
  team: "Team",
  visitor: "Visitor",
};

const LEGACY_ROLE_MAP = {
  owner: "owner",
  admin: "owner",
  client_admin: "client_admin",
  client: "client",
  cliente: "client",
  team: "team",
  equipo: "team",
  visitor: "visitor",
  visitante: "visitor",
};

const DASHBOARD_LABELS = {
  owner: "Dashboard — Owner",
  client_admin: "Dashboard — Client admin",
  client: "Dashboard — Client",
  team: "Dashboard — Team",
  visitor: "Dashboard — Visitor",
};

export function renderLayout({ title, env, role, email, nav = [], content = "" }) {
  const tag = env?.RUNART_ENV || "env";
  const links = nav
    .map((item) => `<a href="${item.href}" aria-label="${item.label}">${item.label}</a>`)
    .join(" | ");

  return `<!doctype html>
<html lang="es"><head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>${title} | RunArt Foundry</title>
  <style>
    body{font-family:system-ui,Segoe UI,Roboto,Arial,sans-serif;margin:0}
    header{display:flex;justify-content:space-between;align-items:center;padding:14px 18px;border-bottom:1px solid #eee}
    main{padding:18px}
    .tag{font-size:12px;padding:4px 8px;border-radius:12px;background:#eef;margin-left:8px}
    nav a{margin-right:12px;text-decoration:none}
    .kpi{border:1px solid #eee;border-radius:12px;padding:14px;margin:8px 0}
  </style>
</head>
<body>
  <header>
    <div><strong>${title}</strong><span class="tag">${tag}</span></div>
    <nav>${links}</nav>
  </header>
  <main>
    <p style="font-size:12px;color:#666">Sesión: ${email || "anónimo"} • Rol: ${roleToAlias(role)} (${ROLE_LABELS[role] || role})</p>
    ${content}
  </main>
</body></html>`;
}

export function navFor(role) {
  const normalized = LEGACY_ROLE_MAP[role] || "visitor";
  const dashboardHref = ROLE_SEGMENTS[normalized] || ROLE_SEGMENTS.visitor;
  const dashboardLabel = DASHBOARD_LABELS[normalized] || DASHBOARD_LABELS.visitor;
  const common = [{ label: "whoami", href: "/api/whoami" }];

  if (normalized === "owner") {
    return [
      { label: dashboardLabel, href: dashboardHref },
      { label: "Bitácora 082", href: "/docs/internal/briefing_system/ci/082_reestructuracion_local/" },
      { label: "Fase 3", href: "/docs/internal/briefing_system/reports/2025-10-09_fase3_administracion_roles_y_delegaciones/" },
      ...common,
    ];
  }
  if (normalized === "team") {
    return [
      { label: dashboardLabel, href: dashboardHref },
      { label: "Operaciones", href: "/docs/internal/briefing_system/ops/status/" },
      ...common,
    ];
  }
  if (normalized === "client" || normalized === "client_admin") {
    return [
      { label: dashboardLabel, href: dashboardHref },
      { label: "Proyecto", href: "/docs/client_projects/runart_foundry/" },
      ...common,
    ];
  }
  return [{ label: dashboardLabel, href: dashboardHref }, ...common];
}
