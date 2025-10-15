#!/usr/bin/env node
import process from 'process';

const fetchFn = globalThis.fetch;
if (typeof fetchFn !== 'function') {
  console.error('Entorno Node sin fetch global, actualiza a Node 18+ o instala node-fetch.');
  process.exit(2);
}

const { CLOUDFLARE_API_TOKEN, CLOUDFLARE_ACCOUNT_ID, TARGET_HOST, BASE_HOST } = process.env;
if (!CLOUDFLARE_API_TOKEN || !CLOUDFLARE_ACCOUNT_ID || !TARGET_HOST || !BASE_HOST) {
  console.error('Faltan variables de entorno necesarias.');
  process.exit(2);
}

const CF_API = `https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/access/apps`;
const headers = {
  'Authorization': `Bearer ${CLOUDFLARE_API_TOKEN}`,
  'Content-Type': 'application/json',
};

async function main() {
  // Listar apps
  const res = await fetchFn(CF_API, { headers });
  const data = await res.json();
  if (!data.success) {
    console.error('Error al consultar apps:', data.errors);
    process.exit(2);
  }
  const apps = data.result;
  const baseApp = apps.find(app => app.domain === BASE_HOST);
  if (!baseApp) {
    console.error('No se encontró la app base.');
    process.exit(2);
  }
  // Verificar si ya existe app para TARGET_HOST
  const branchApp = apps.find(app => app.domain === TARGET_HOST);
  if (branchApp) {
    console.log('App de rama ya existe, no se requiere acción.');
    process.exit(0);
  }
  // Clonar políticas mínimas
  const newApp = {
    name: `RUN Briefing (branch: ${TARGET_HOST})`,
    domain: TARGET_HOST,
    type: baseApp.type,
    policies: baseApp.policies,
    session_duration: baseApp.session_duration,
    auto_redirect_to_identity: baseApp.auto_redirect_to_identity,
  };
  // Crear app
  const createRes = await fetchFn(CF_API, {
    method: 'POST',
    headers,
    body: JSON.stringify(newApp),
  });
  const createData = await createRes.json();
  if (!createData.success) {
    console.error('Error al crear app:', createData.errors);
    process.exit(2);
  }
  console.log('App de rama creada exitosamente.');
  process.exit(0);
}

main().catch(e => { console.error(e); process.exit(2); });
