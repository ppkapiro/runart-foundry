import { renderLayout, navFor } from "../_utils/ui.js";
import { getEmailFromRequest, resolveRole } from "../_utils/roles.js";

export async function onRequestGet(context) {
  const { env, request } = context;
  const email = await getEmailFromRequest(request);
  const role = await resolveRole(email, env);

  const content = `
    <div class="kpi">
      <h2>Tareas y flujo</h2>
      <p>Acceso a checklists, playbooks y herramientas internas.</p>
    </div>
    <div class="kpi">
      <h2>Recursos rápidos</h2>
      <ul>
        <li><a href="/docs/work/board/">Tablero operativo</a></li>
        <li><a href="/docs/work/playbooks/">Playbooks</a></li>
        <li><a href="/docs/work/tools/">Herramientas</a></li>
      </ul>
    </div>
  `;

  const html = renderLayout({
    title: "Dashboard — Equipo",
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
