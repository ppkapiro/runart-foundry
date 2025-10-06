// Endpoint de diagnóstico para inspeccionar headers de Cloudflare Access
export const onRequestGet = async ({ request }) => {
  try {
    const headers = {};

    // Extraer todos los headers relevantes
    for (const [key, value] of request.headers.entries()) {
      if (
        key.toLowerCase().startsWith('cf-') ||
        key.toLowerCase() === 'user-agent' ||
        key.toLowerCase() === 'x-forwarded-for' ||
        key.toLowerCase() === 'cookie'
      ) {
        headers[key] = value;
      }
    }

    const accessInfo = {
      authenticated: !!request.headers.get('Cf-Access-Authenticated-User-Email'),
      email: request.headers.get('Cf-Access-Authenticated-User-Email') || null,
      jwtPresent: !!request.headers.get('Cf-Access-Jwt-Assertion'),
      country: request.headers.get('Cf-Ipcountry') || null,
      connectingIP: request.headers.get('Cf-Connecting-Ip') || null,
    };

    return new Response(
      JSON.stringify(
        {
          timestamp: new Date().toISOString(),
          access: accessInfo,
          headers,
          url: request.url,
          method: request.method,
        },
        null,
        2,
      ),
      {
        status: 200,
        headers: {
          'Content-Type': 'application/json',
          'Cache-Control': 'no-store, no-cache, must-revalidate',
        },
      },
    );
  } catch (err) {
    return new Response(
      JSON.stringify(
        {
          error: String(err),
          timestamp: new Date().toISOString(),
        },
        null,
        2,
      ),
      {
        status: 500,
        headers: { 'Content-Type': 'application/json' },
      },
    );
  }
};
