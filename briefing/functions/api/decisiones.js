export const onRequestPost = async (context) => {
  try {
    const { request, env } = context;
    const user = request.headers.get('Cf-Access-Authenticated-User-Email') || 'uldis@local';
    const body = await request.json();

    const ts = new Date().toISOString();
    const key = `decision:${body.decision_id}:${ts}`;
    const value = JSON.stringify({ ...body, usuario: user, ts });

    await env.DECISIONES.put(key, value);
    return new Response(JSON.stringify({ ok: true }), {
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
