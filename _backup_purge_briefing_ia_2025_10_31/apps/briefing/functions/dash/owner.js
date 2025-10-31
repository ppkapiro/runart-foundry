import { renderLayout, navFor } from "../_utils/ui.js";
import { getEmailFromRequest, resolveRole } from "../_utils/roles.js";

export async function onRequestGet(context) {
  const { env, request } = context;
  const email = await getEmailFromRequest(request);
  const role = await resolveRole(email, env);

  const content = `
    <div class="kpi">
      <h2>Estado del sistema</h2>
      <p>KPIs altos nivel, últimos deploys y alertas operativas.</p>
    </div>
    <div class="kpi">
      <h2>Accesos rápidos</h2>
      <ul>
        <li><a href="/docs/logs/">Bitácora</a></li>
        <li><a href="/docs/reports/">Reports</a></li>
        <li><a href="/api/whoami">Diagnóstico (whoami)</a></li>
      </ul>
    </div>
  `;

  const html = renderLayout({
    title: "Dashboard — Owner",
    env,
    role,
    email,
    nav: navFor(role),
    content,
  });

  return new Response(html, {
    headers: { "content-type": "text/html; charset=utf-8" },
  });
}
