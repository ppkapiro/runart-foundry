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
    <p style="font-size:12px;color:#666">Sesión: ${email || "anónimo"} • Rol: ${role}</p>
    ${content}
  </main>
</body></html>`;
}

export function navFor(role) {
  const common = [{ label: "whoami", href: "/api/whoami" }];
  if (role === "owner") {
    return [
      { label: "Dashboard", href: "/dash/owner" },
      { label: "Bitácora", href: "/docs/logs/" },
      { label: "Reports", href: "/docs/reports/" },
      ...common,
    ];
  }
  if (role === "equipo") {
    return [
      { label: "Dashboard", href: "/dash/equipo" },
      { label: "Tareas", href: "/docs/work/" },
      ...common,
    ];
  }
  if (role === "cliente") {
    return [
      { label: "Dashboard", href: "/dash/cliente" },
      { label: "Proyecto", href: "/docs/proyecto/" },
      ...common,
    ];
  }
  return [{ label: "Dashboard", href: "/dash/visitante" }, ...common];
}
