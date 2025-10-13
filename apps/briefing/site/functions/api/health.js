export async function onRequest(context) {
  return new Response(JSON.stringify({ ok: true, env: "preview" }), {
    headers: { "content-type": "application/json; charset=utf-8", "cache-control": "no-store" }
  });
}
