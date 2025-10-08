import { renderLayout, navFor } from "../_utils/ui.js";
import { getEmailFromRequest, resolveRole } from "../_utils/roles.js";

export async function onRequestGet(context) {
  const { env, request } = context;
  const email = await getEmailFromRequest(request);
  const role = await resolveRole(email, env);

  const content = `
    <div class="kpi">
      <h2>Acceso restringido</h2>
      <p>No tienes permisos para ver paneles avanzados. Contacta al owner para solicitar acceso.</p>
    </div>
    <div class="kpi">
      <h2>Recursos públicos</h2>
      <ul>
        <li><a href="/docs/">Documentación pública</a></li>
        <li><a href="mailto:info@runart.studio">Contacto</a></li>
      </ul>
    </div>
  `;

  const html = renderLayout({
    title: "Dashboard — Visitante",
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
