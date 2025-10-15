#!/usr/bin/env node
/**
 * Verificador de Service Token de Cloudflare Access (Preview)
 * 
 * PROPÓSITO:
 * Valida que el Service Token configurado en CI puede acceder a /api/whoami
 * en el entorno preview y que los headers de canary (X-RunArt-Canary y 
 * X-RunArt-Resolver) están presentes.
 * 
 * REQUISITOS:
 * - Node.js 18+ (usa fetch nativo)
 * - Variables de entorno:
 *   • ACCESS_CLIENT_ID_PREVIEW
 *   • ACCESS_CLIENT_SECRET_PREVIEW
 * 
 * USO:
 *   # Bash/Linux
 *   export ACCESS_CLIENT_ID_PREVIEW="tu_client_id"
 *   export ACCESS_CLIENT_SECRET_PREVIEW="tu_client_secret"
 *   node tools/diagnostics/verify_access_service_token.mjs
 * 
 *   # PowerShell
 *   $env:ACCESS_CLIENT_ID_PREVIEW="tu_client_id"
 *   $env:ACCESS_CLIENT_SECRET_PREVIEW="tu_client_secret"
 *   node tools/diagnostics/verify_access_service_token.mjs
 * 
 *   # Con npm script
 *   npm run verify:access:preview
 * 
 * SALIDA:
 * - Código 0: Éxito (HTTP 200 + ambos headers presentes)
 * - Código 1: Fallo (credenciales ausentes, HTTP ≠ 200, o headers faltantes)
 */

import { exit } from 'process';

const TARGET_HOST = process.env.PREVIEW_HOST || 'https://runart-foundry.pages.dev';
const ENDPOINT = '/api/whoami';
const FULL_URL = `${TARGET_HOST}${ENDPOINT}`;

const CLIENT_ID = process.env.ACCESS_CLIENT_ID_PREVIEW;
const CLIENT_SECRET = process.env.ACCESS_CLIENT_SECRET_PREVIEW;

console.log('═══════════════════════════════════════════════════════════════════');
console.log('  RUNART | Verificación de Service Token de Access (Preview)');
console.log('═══════════════════════════════════════════════════════════════════');
console.log();

// 1. Validar presencia de credenciales
if (!CLIENT_ID || !CLIENT_SECRET) {
  console.error('❌ ERROR: Faltan credenciales de Access');
  console.error('   Asegúrate de exportar:');
  console.error('   - ACCESS_CLIENT_ID_PREVIEW');
  console.error('   - ACCESS_CLIENT_SECRET_PREVIEW');
  console.error();
  exit(1);
}

console.log('✅ Credenciales presentes');
console.log(`   Client ID: ${CLIENT_ID.substring(0, 8)}...${CLIENT_ID.substring(CLIENT_ID.length - 4)}`);
console.log(`   Secret: ${CLIENT_SECRET.substring(0, 8)}...(oculto)`);
console.log();

// 2. Hacer request a /api/whoami
console.log(`🌐 Target: ${FULL_URL}`);
console.log('📡 Enviando request con headers de Service Token...');
console.log();

try {
  const response = await fetch(FULL_URL, {
    method: 'GET',
    headers: {
      'CF-Access-Client-Id': CLIENT_ID,
      'CF-Access-Client-Secret': CLIENT_SECRET,
      'User-Agent': 'runart-ci/access-verification'
    },
    redirect: 'manual' // No seguir redirects (302 = Access bloqueando)
  });

  const status = response.status;
  const statusText = response.statusText;
  
  console.log(`📊 Status: ${status} ${statusText}`);
  
  // 3. Extraer headers relevantes
  const canaryHeader = response.headers.get('X-RunArt-Canary');
  const resolverHeader = response.headers.get('X-RunArt-Resolver');
  
  console.log();
  console.log('🔍 Headers de Canary:');
  console.log(`   X-RunArt-Canary: ${canaryHeader || '(ausente)'}`);
  console.log(`   X-RunArt-Resolver: ${resolverHeader || '(ausente)'}`);
  console.log();

  // 4. Leer body (limitado)
  let body = '';
  try {
    const text = await response.text();
    body = text.length > 512 ? text.substring(0, 512) + '...(truncado)' : text;
  } catch (e) {
    body = '(no se pudo leer body)';
  }

  console.log('📄 Body (primeros 512 chars):');
  console.log(body);
  console.log();

  // 5. Verificar criterios de éxito
  if (status !== 200) {
    console.error(`❌ FALLO: Status esperado 200, obtenido ${status}`);
    if (status === 302) {
      console.error('   → Access redirige a login (Service Token NO autorizado en policy)');
      console.error('   → Verificar que el token esté incluido en la policy de RUN Briefing');
    }
    console.error();
    exit(1);
  }

  if (!canaryHeader) {
    console.error('❌ FALLO: Header X-RunArt-Canary ausente');
    console.error('   → La aplicación no está devolviendo el header de canary');
    console.error();
    exit(1);
  }

  if (!resolverHeader) {
    console.error('❌ FALLO: Header X-RunArt-Resolver ausente');
    console.error('   → La aplicación no está devolviendo el header de resolver');
    console.error();
    exit(1);
  }

  // 6. Éxito total
  console.log('═══════════════════════════════════════════════════════════════════');
  console.log('✅ VERIFICACIÓN EXITOSA');
  console.log('   • HTTP 200 OK');
  console.log(`   • X-RunArt-Canary: ${canaryHeader}`);
  console.log(`   • X-RunArt-Resolver: ${resolverHeader}`);
  console.log('   • Service Token funciona correctamente en preview');
  console.log('═══════════════════════════════════════════════════════════════════');
  console.log();
  exit(0);

} catch (error) {
  console.error('❌ ERROR de red o excepción:');
  console.error(error.message);
  console.error();
  exit(1);
}
