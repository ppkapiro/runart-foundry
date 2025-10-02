export const onRequestGet = async ({ env }) => {
  try {
    const list = await env.DECISIONES.list({ prefix: 'decision:' });
    const items = [];
    for (const { name } of list.keys) {
      const v = await env.DECISIONES.get(name);
      if (v) items.push(JSON.parse(v));
    }
    items.sort((a, b) => (a.ts < b.ts ? 1 : -1));
    return new Response(JSON.stringify(items), {
      status: 200,
      headers: { 'Content-Type': 'application/json' }
    });
  } catch (err) {
    return new Response(JSON.stringify({ ok: false, error: String(err) }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    });
  }
};
