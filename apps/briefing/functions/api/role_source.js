// Endpoint diagnóstico temporal para canario de roles
export async function onRequest(context) {
  const SRC = (context.env.ROLE_RESOLVER_SOURCE || "lib").toLowerCase();
  return new Response(JSON.stringify({ role_resolver_source: SRC }), {
    status: 200,
    headers: { 'Content-Type': 'application/json' },
  });
}
