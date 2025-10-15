#!/usr/bin/env node

/**
 * Deep Check de Cloudflare Access - Diagnóstico Avanzado
 * 
 * Valida configuración de policies, service tokens y realiza pruebas HTTP
 * para diagnosticar por qué /api/whoami devuelve 302 en lugar de 200.
 * 
 * Variables de entorno requeridas:
 * - CLOUDFLARE_API_TOKEN
 * - CLOUDFLARE_ACCOUNT_ID
 * - ACCESS_CLIENT_ID_PREVIEW
 * - ACCESS_CLIENT_SECRET_PREVIEW
 * - TARGET_HOST (opcional, default: runart-foundry.pages.dev)
 */

import crypto from 'crypto';

const TARGET_HOST = process.env.TARGET_HOST || 'runart-foundry.pages.dev';
const API_TOKEN = process.env.CLOUDFLARE_API_TOKEN;
const ACCOUNT_ID = process.env.CLOUDFLARE_ACCOUNT_ID;
const CLIENT_ID = process.env.ACCESS_CLIENT_ID_PREVIEW;
const CLIENT_SECRET = process.env.ACCESS_CLIENT_SECRET_PREVIEW;

const colors = {
  reset: '\x1b[0m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  cyan: '\x1b[36m',
  bold: '\x1b[1m'
};

function log(msg, color = 'reset') {
  console.log(`${colors[color]}${msg}${colors.reset}`);
}

function sanitize(value) {
  if (!value) return null;
  return value.trim().replace(/[\r\n\t]/g, '');
}

function hashShort(value) {
  if (!value) return 'N/A';
  return crypto.createHash('sha1').update(value).digest('hex').slice(0, 8);
}

function validateEnv() {
  const missing = [];
  if (!API_TOKEN) missing.push('CLOUDFLARE_API_TOKEN');
  if (!ACCOUNT_ID) missing.push('CLOUDFLARE_ACCOUNT_ID');
  if (!CLIENT_ID) missing.push('ACCESS_CLIENT_ID_PREVIEW');
  if (!CLIENT_SECRET) missing.push('ACCESS_CLIENT_SECRET_PREVIEW');
  
  if (missing.length > 0) {
    log('\n❌ ERROR: Variables de entorno faltantes:', 'red');
    missing.forEach(v => log(`   - ${v}`, 'yellow'));
    log('\nEjecuta: npm run access:export-envs', 'cyan');
    process.exit(1);
  }
}

async function cfApiCall(endpoint) {
  const url = `https://api.cloudflare.com/client/v4${endpoint}`;
  const response = await fetch(url, {
    headers: {
      'Authorization': `Bearer ${API_TOKEN}`,
      'Content-Type': 'application/json'
    }
  });
  
  if (!response.ok) {
    throw new Error(`CF API Error: ${response.status} ${response.statusText}`);
  }
  
  return await response.json();
}

async function getAccessApps() {
  log('\n🔍 Obteniendo aplicaciones de Access...', 'yellow');
  const data = await cfApiCall(`/accounts/${ACCOUNT_ID}/access/apps`);
  
  if (!data.success) {
    throw new Error('Failed to fetch Access apps');
  }
  
  log(`   Total de apps: ${data.result.length}`, 'cyan');
  
  // Buscar app que coincida con TARGET_HOST
  const matchingApps = data.result.filter(app => {
    const domain = app.domain || '';
    const appLauncher = app.app_launcher_url || '';
    return domain.includes(TARGET_HOST) || appLauncher.includes(TARGET_HOST);
  });
  
  if (matchingApps.length === 0) {
    log(`   ⚠️  No se encontró app para host: ${TARGET_HOST}`, 'yellow');
    log('   Apps disponibles:', 'cyan');
    data.result.forEach(app => {
      log(`      - ${app.name}: ${app.domain || app.app_launcher_url || 'N/A'}`, 'cyan');
    });
    return null;
  }
  
  const app = matchingApps[0];
  log(`   ✅ App encontrada: ${app.name}`, 'green');
  log(`      ID: ${app.id}`, 'cyan');
  log(`      Domain: ${app.domain}`, 'cyan');
  log(`      AUD: ${app.aud}`, 'cyan');
  
  return app;
}

async function getAppPolicies(appId) {
  log('\n🔍 Obteniendo policies de la app...', 'yellow');
  const data = await cfApiCall(`/accounts/${ACCOUNT_ID}/access/apps/${appId}/policies`);
  
  if (!data.success) {
    throw new Error('Failed to fetch policies');
  }
  
  log(`   Total de policies: ${data.result.length}`, 'cyan');
  
  const issues = [];
  
  data.result.forEach((policy, idx) => {
    log(`\n   📋 Policy #${idx + 1}: ${policy.name}`, 'bold');
    log(`      ID: ${policy.id}`, 'cyan');
    log(`      Decision: ${policy.decision}`, 'cyan');
    log(`      Precedence: ${policy.precedence}`, 'cyan');
    
    // Analizar Include
    if (policy.include && policy.include.length > 0) {
      log('      Include:', 'cyan');
      policy.include.forEach(rule => {
        const type = Object.keys(rule)[0];
        log(`         - ${type}`, 'cyan');
        
        if (type === 'service_token') {
          log('            ✅ Service Token incluido', 'green');
        }
      });
    }
    
    // Analizar Require
    if (policy.require && policy.require.length > 0) {
      log('      Require:', 'cyan');
      policy.require.forEach(rule => {
        const type = Object.keys(rule)[0];
        log(`         - ${type}`, 'yellow');
        
        if (policy.include && policy.include.some(r => r.service_token)) {
          issues.push({
            policy: policy.name,
            issue: 'Policy tiene Include Service Token pero también tiene Require',
            severity: 'HIGH'
          });
          log('            ⚠️  CONFLICTO: Require presente con Service Token en Include', 'red');
        }
      });
    }
    
    // Analizar Exclude
    if (policy.exclude && policy.exclude.length > 0) {
      log('      Exclude:', 'cyan');
      policy.exclude.forEach(rule => {
        const type = Object.keys(rule)[0];
        log(`         - ${type}`, 'cyan');
      });
    }
    
    // Analizar additional_settings
    if (policy.purpose_justification_required !== undefined) {
      log(`      Purpose Justification: ${policy.purpose_justification_required ? 'ON' : 'OFF'}`, 
          policy.purpose_justification_required ? 'red' : 'green');
      
      if (policy.purpose_justification_required && policy.include && policy.include.some(r => r.service_token)) {
        issues.push({
          policy: policy.name,
          issue: 'Purpose Justification ON con Service Token en Include',
          severity: 'CRITICAL'
        });
        log('            ❌ ROOT CAUSE: Purpose Justification bloqueando Service Token', 'red');
      }
    }
    
    if (policy.approval_required !== undefined) {
      log(`      Approval Required: ${policy.approval_required ? 'ON' : 'OFF'}`, 
          policy.approval_required ? 'red' : 'green');
    }
  });
  
  return { policies: data.result, issues };
}

async function getServiceTokens() {
  log('\n🔍 Obteniendo Service Tokens...', 'yellow');
  try {
    const data = await cfApiCall(`/accounts/${ACCOUNT_ID}/access/service_tokens`);
    
    if (!data.success) {
      throw new Error('Failed to fetch service tokens');
    }
    
    log(`   Total de tokens: ${data.result.length}`, 'cyan');
    
    const relevantTokens = data.result.filter(token => 
      token.name.includes('runart') || 
      token.name.includes('ci') ||
      token.name.includes('diagnostics')
    );
    
    relevantTokens.forEach(token => {
      log(`   - ${token.name}`, 'cyan');
      log(`     ID: ${token.id}`, 'cyan');
      log(`     Client ID: ${token.client_id}`, 'cyan');
      log(`     Created: ${token.created_at}`, 'cyan');
      log(`     Expires: ${token.expires_at || 'Never'}`, 'cyan');
      
      if (token.client_id === CLIENT_ID.split('.')[0]) {
        log('     ✅ MATCH con ACCESS_CLIENT_ID_PREVIEW', 'green');
      }
    });
    
    return relevantTokens;
  } catch (error) {
    log(`   ⚠️  Error obteniendo tokens: ${error.message}`, 'yellow');
    return [];
  }
}

async function httpTest(url, headers, testName) {
  log(`\n   🧪 ${testName}`, 'yellow');
  log(`      URL: ${url}`, 'cyan');
  
  try {
    const response = await fetch(url, {
      method: 'GET',
      headers,
      redirect: 'manual'
    });
    
    const status = response.status;
    const statusText = response.statusText;
    const location = response.headers.get('location');
    const canary = response.headers.get('x-runart-canary');
    const resolver = response.headers.get('x-runart-resolver');
    
    let body = '';
    try {
      const text = await response.text();
      body = text.slice(0, 200);
    } catch (e) {
      body = '(no body)';
    }
    
    log(`      Status: ${status} ${statusText}`, status === 200 ? 'green' : 'red');
    
    if (location) {
      log(`      Location: ${location}`, 'yellow');
      
      if (location.includes('/cdn-cgi/access/login')) {
        log('         ❌ Access bloqueando → redirigiendo a login', 'red');
        
        if (location.includes('auth_status=NONE')) {
          log('         ❌ auth_status=NONE → Token NO aceptado por policy', 'red');
        }
        
        if (location.includes('service_token_status=true')) {
          log('         ℹ️  service_token_status=true → Token detectado pero bloqueado', 'cyan');
        }
      }
    }
    
    log(`      X-RunArt-Canary: ${canary || '(ausente)'}`, canary ? 'green' : 'red');
    log(`      X-RunArt-Resolver: ${resolver || '(ausente)'}`, resolver ? 'green' : 'red');
    log(`      Body preview: ${body}`, 'cyan');
    
    return { status, location, canary, resolver, body };
  } catch (error) {
    log(`      ❌ Error: ${error.message}`, 'red');
    return { status: 0, error: error.message };
  }
}

async function runHttpTests() {
  log('\n🧪 Ejecutando pruebas HTTP...', 'yellow');
  
  const headers = {
    'CF-Access-Client-Id': CLIENT_ID,
    'CF-Access-Client-Secret': CLIENT_SECRET,
    'User-Agent': 'RunArt-DeepCheck/1.0'
  };
  
  const results = {
    p1: await httpTest(`https://${TARGET_HOST}/api/whoami`, headers, 'P1: /api/whoami'),
    p2: await httpTest(`https://${TARGET_HOST}/`, headers, 'P2: Root /'),
    p3: await httpTest(`https://${TARGET_HOST}/health`, headers, 'P3: /health')
  };
  
  return results;
}

function generateDiagnosis(app, policiesData, tokens, httpResults) {
  log('\n═══════════════════════════════════════════════════════════════════', 'cyan');
  log('📊 DIAGNÓSTICO Y ROOT CAUSE ANALYSIS', 'bold');
  log('═══════════════════════════════════════════════════════════════════', 'cyan');
  
  const rootCauses = [];
  const fixes = [];
  
  // Análisis 1: App encontrada
  if (!app) {
    rootCauses.push('❌ [C] MISMATCH DE HOST: App no encontrada para ' + TARGET_HOST);
    fixes.push('Verificar que el dominio de la app de Access coincida con ' + TARGET_HOST);
  } else {
    log(`✅ App encontrada: ${app.name}`, 'green');
  }
  
  // Análisis 2: Issues de policies
  if (policiesData.issues.length > 0) {
    log('\n⚠️  Issues detectados en policies:', 'yellow');
    policiesData.issues.forEach(issue => {
      log(`   [${issue.severity}] ${issue.policy}: ${issue.issue}`, 'red');
      
      if (issue.severity === 'CRITICAL') {
        rootCauses.push(`❌ [A] ${issue.issue} en policy "${issue.policy}"`);
        fixes.push(`Desactivar Purpose Justification en la policy "${issue.policy}"`);
      }
      
      if (issue.issue.includes('Require')) {
        rootCauses.push(`❌ [B] Conflicto Require/Include en policy "${issue.policy}"`);
        fixes.push(`Remover Require de la policy "${issue.policy}" o crear policy separada para Service Tokens`);
      }
    });
  }
  
  // Análisis 3: Resultados HTTP
  log('\n📊 Resultados de pruebas HTTP:', 'cyan');
  const allFailed = Object.values(httpResults).every(r => r.status === 302 || r.status === 0);
  
  if (allFailed) {
    log('   ❌ Todas las pruebas fallaron con 302/error', 'red');
    
    const hasAuthStatusNone = Object.values(httpResults).some(r => 
      r.location && r.location.includes('auth_status=NONE')
    );
    
    if (hasAuthStatusNone) {
      rootCauses.push('❌ [A/B] Policy no acepta el Service Token (auth_status=NONE)');
      fixes.push('Verificar que la policy tenga Include Service Token sin Require ni Purpose Justification');
    }
  }
  
  // Análisis 4: Sanitización de credentials
  const sanitizedId = sanitize(CLIENT_ID);
  const sanitizedSecret = sanitize(CLIENT_SECRET);
  
  log('\n🔐 Validación de credenciales:', 'cyan');
  log(`   Client ID length: ${CLIENT_ID.length} → sanitized: ${sanitizedId.length}`, 
      CLIENT_ID.length === sanitizedId.length ? 'green' : 'yellow');
  log(`   Client Secret length: ${CLIENT_SECRET.length} → sanitized: ${sanitizedSecret.length}`, 
      CLIENT_SECRET.length === sanitizedSecret.length ? 'green' : 'yellow');
  log(`   Client ID hash: ${hashShort(CLIENT_ID)}`, 'cyan');
  log(`   Client Secret hash: ${hashShort(CLIENT_SECRET)}`, 'cyan');
  
  if (CLIENT_ID.length !== sanitizedId.length || CLIENT_SECRET.length !== sanitizedSecret.length) {
    rootCauses.push('❌ [D] Headers malformados: whitespace detectado en credenciales');
    fixes.push('Sanitizar ACCESS_CLIENT_ID_PREVIEW y ACCESS_CLIENT_SECRET_PREVIEW (trim + remover \\r\\n\\t)');
  }
  
  // Análisis 5: Token existe
  const tokenFound = tokens.some(t => t.client_id === CLIENT_ID.split('.')[0]);
  if (!tokenFound) {
    rootCauses.push('❌ [E] Token no encontrado en la cuenta o Client ID incorrecto');
    fixes.push('Verificar que el Service Token exista y pertenezca a la cuenta correcta');
  }
  
  // Resumen final
  log('\n═══════════════════════════════════════════════════════════════════', 'cyan');
  log('🎯 ROOT CAUSES IDENTIFICADOS:', 'bold');
  log('═══════════════════════════════════════════════════════════════════', 'cyan');
  
  if (rootCauses.length === 0) {
    log('   ℹ️  No se identificaron root causes claros', 'yellow');
    log('   Posibles causas no detectadas automáticamente:', 'yellow');
    log('   - Policy order incorrecta (humana antes de token)', 'yellow');
    log('   - Additional settings no visibles en API', 'yellow');
  } else {
    rootCauses.forEach(rc => log(`   ${rc}`, 'red'));
  }
  
  log('\n🔧 FIXES SUGERIDOS:', 'bold');
  if (fixes.length === 0) {
    log('   - Verificar manualmente el orden de policies en dashboard', 'cyan');
    log('   - Confirmar que Purpose Justification está OFF', 'cyan');
    log('   - Validar que Include tiene Service Token y Exclude excluye tokens en policy humana', 'cyan');
  } else {
    fixes.forEach(fix => log(`   - ${fix}`, 'green'));
  }
  
  log('═══════════════════════════════════════════════════════════════════\n', 'cyan');
  
  return { rootCauses, fixes };
}

async function main() {
  log('\n═══════════════════════════════════════════════════════════════════', 'cyan');
  log('🔬 RUNART | Deep Check de Cloudflare Access', 'bold');
  log('═══════════════════════════════════════════════════════════════════', 'cyan');
  
  validateEnv();
  
  log(`\n🎯 Target: ${TARGET_HOST}`, 'cyan');
  log(`📦 Account: ${ACCOUNT_ID}`, 'cyan');
  
  try {
    // 1. Obtener app
    const app = await getAccessApps();
    
    let policiesData = { policies: [], issues: [] };
    let tokens = [];
    
    if (app) {
      // 2. Obtener policies
      policiesData = await getAppPolicies(app.id);
      
      // 3. Obtener service tokens
      tokens = await getServiceTokens();
    }
    
    // 4. Pruebas HTTP
    const httpResults = await runHttpTests();
    
    // 5. Diagnóstico
    const diagnosis = generateDiagnosis(app, policiesData, tokens, httpResults);
    
    // Retornar datos para el summary
    return {
      app,
      policies: policiesData.policies,
      issues: policiesData.issues,
      tokens,
      httpResults,
      diagnosis
    };
    
  } catch (error) {
    log(`\n❌ ERROR FATAL: ${error.message}`, 'red');
    log(error.stack, 'red');
    process.exit(1);
  }
}

// Ejecutar
main().then(result => {
  if (result.diagnosis.rootCauses.length > 0) {
    process.exit(1); // Salir con error si hay root causes
  }
}).catch(error => {
  log(`\n❌ Error inesperado: ${error.message}`, 'red');
  process.exit(1);
});
