// Middleware de Access: clasifica correo y fija cabeceras internas para el resto de Functions.
import rolesConfig from '../access/roles.json' assert { type: 'json' };

const normalize = (value) => (value || '').trim().toLowerCase();

const OWNERS = new Set((rolesConfig.owners || []).map(normalize));
const TEAM_DOMAINS = new Set((rolesConfig.team_domains || []).map(normalize));
const CLIENTS = new Set((rolesConfig.clients || []).map(normalize));

const STATIC_EXTENSIONS = new Set([
  '.css',
  '.js',
  '.mjs',
  '.json',
  '.png',
  '.jpg',
  '.jpeg',
  '.gif',
  '.svg',
  '.ico',
  '.woff',
  '.woff2',
  '.ttf',
  '.map'
]);

const isBypassPath = (pathname) => {
  if (pathname.startsWith('/api/')) return true;
  if (pathname === '/' || pathname === '') return false;
  const lastDot = pathname.lastIndexOf('.');
  if (lastDot === -1) return false;
  const extension = pathname.slice(lastDot).toLowerCase();
  return STATIC_EXTENSIONS.has(extension);
};

export const classifyRole = (email) => {
  const normalizedEmail = normalize(email);
  if (!normalizedEmail) return 'visitor';
  if (OWNERS.has(normalizedEmail)) return 'owner';

  const domain = normalizedEmail.split('@').pop();
  if (domain && TEAM_DOMAINS.has(domain)) return 'team';

  if (CLIENTS.has(normalizedEmail)) return 'client';
  return 'visitor';
};

export const onRequest = async (context) => {
  const { request } = context;
  const url = new URL(request.url);

  const rawEmail = request.headers.get('Cf-Access-Authenticated-User-Email') || '';
  const role = classifyRole(rawEmail);

  const headers = new Headers(request.headers);
  headers.set('X-RunArt-Email', rawEmail);
  headers.set('X-RunArt-Role', role);

  const updatedRequest = new Request(request, { headers });

  if (isBypassPath(url.pathname)) {
    return await context.next(updatedRequest);
  }

  // Por ahora no realizamos redirecciones; solo propagamos correo/rol hacia los handlers.
  return await context.next(updatedRequest);
};
