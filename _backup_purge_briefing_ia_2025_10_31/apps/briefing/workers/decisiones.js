export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    if (request.method === 'POST' && url.pathname === '/api/decisiones') {
      const user = request.headers.get('Cf-Access-Authenticated-User-Email') || 'uldis@local';
      const body = await request.json();
      const ts = new Date().toISOString();
      const key = `decision:${body.decision_id}:${ts}`;
      const value = JSON.stringify({ ...body, usuario: user, ts });
      await env.DECISIONES.put(key, value);
      return new Response(JSON.stringify({ ok: true }), { status: 200, headers: { 'Content-Type': 'application/json' } });
    }
    if (request.method === 'GET' && url.pathname === '/api/inbox') {
      const list = await env.DECISIONES.list({ prefix: 'decision:' });
      const items = [];
      for (const { name } of list.keys) {
        const v = await env.DECISIONES.get(name);
        if (v) items.push(JSON.parse(v));
      }
      items.sort((a, b) => (a.ts < b.ts ? 1 : -1));
      return new Response(JSON.stringify(items), { status: 200, headers: { 'Content-Type': 'application/json' } });
    }
    return new Response('Not found', { status: 404 });
  }
}
