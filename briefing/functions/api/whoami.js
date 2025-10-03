export async function onRequestGet(context) {
  const { request, env } = context;
  const email = request.headers.get('Cf-Access-Authenticated-User-Email') || '';
  const admins = (env.ACCESS_ADMINS || '')
    .split(',')
    .map((s) => s.trim().toLowerCase())
    .filter(Boolean);
  const equipoDomains = (env.ACCESS_EQUIPO_DOMAINS || '')
    .split(',')
    .map((s) => s.trim().toLowerCase())
    .filter(Boolean);

  let role = 'visitante';
  if (email) {
    const e = email.toLowerCase();
    const domain = e.includes('@') ? e.split('@').pop() : '';
    if (admins.includes(e)) role = 'admin';
    else if (equipoDomains.includes(domain)) role = 'equipo';
    else role = 'cliente';
  }

  return new Response(
    JSON.stringify({ email, role, ts: new Date().toISOString() }),
    {
      headers: { 'Content-Type': 'application/json' },
    },
  );
}
