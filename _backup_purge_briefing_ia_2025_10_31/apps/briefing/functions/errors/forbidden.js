export async function onRequestGet() {
  const body = `<!doctype html><meta charset="utf-8">
<title>403 — Acceso denegado</title>
<style>body{font-family:system-ui;padding:24px}a{color:#06c}</style>
<h1>403 — Acceso denegado</h1>
<p>No tienes permisos para ver esta sección.</p>
<p><a href="/dash/visitor">Ir al dashboard</a></p>`;
  return new Response(body, {
    status: 403,
    headers: { "content-type": "text/html; charset=utf-8" },
  });
}
