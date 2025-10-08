import { renderLayout, navFor } from "../_utils/ui.js";
import { getEmailFromRequest, resolveRole } from "../_utils/roles.js";

export async function onRequestGet(context) {
  const { env, request } = context;
  const email = await getEmailFromRequest(request);
  const role = await resolveRole(email, env);

  const content = `
    <div class="kpi">
      <h2>Proyecto</h2>
      <p>Resumen de hitos, entregables recientes y enlaces clave para el cliente.</p>
    </div>
    <div class="kpi">
      <h2>Soporte</h2>
      <ul>
        <li><a href="/docs/proyecto/cronograma/">Cronograma</a></li>
        <li><a href="/docs/proyecto/entregables/">Entregables</a></li>
        <li><a href="mailto:ops@runart.studio">Contacto directo</a></li>
      </ul>
    </div>
  `;

  const html = renderLayout({
    title: "Dashboard — Cliente",
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
