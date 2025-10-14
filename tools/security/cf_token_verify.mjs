#!/usr/bin/env node
/**
 * Verificador de scopes de tokens Cloudflare
 * Uso: node cf_token_verify.mjs [token]
 * 
 * Env: CF_API_TOKEN (si no se pasa token como argumento)
 * Salida: JSON con scopes actuales vs requeridos
 */

import https from 'https';

// Scopes mínimos requeridos para el proyecto
const REQUIRED_SCOPES = [
  'com.cloudflare.api.account.zone:read',
  'com.cloudflare.edge.worker.script:read', 
  'com.cloudflare.edge.worker.kv:edit',
  'com.cloudflare.api.account.zone.page:edit'
];

// Mapeo de recursos esperados
const EXPECTED_RESOURCES = {
  'com.cloudflare.api.account': '*',
  'com.cloudflare.edge.worker.script': '*', 
  'com.cloudflare.edge.worker.kv': '*',
  'com.cloudflare.api.account.zone.page': '*'
};

/**
 * Realizar petición HTTP a Cloudflare API
 */
function httpsRequest(options, postData = null) {
  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          const parsed = JSON.parse(data);
          resolve({ status: res.statusCode, data: parsed });
        } catch (e) {
          resolve({ status: res.statusCode, data: { raw: data } });
        }
      });
    });

    req.on('error', reject);
    
    if (postData) {
      req.write(postData);
    }
    
    req.end();
  });
}

/**
 * Verificar token contra API de Cloudflare
 */
async function verifyToken(token) {
  const options = {
    hostname: 'api.cloudflare.com',
    port: 443,
    path: '/client/v4/user/tokens/verify',
    method: 'GET',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json',
      'User-Agent': 'RunArt-CF-Token-Verifier/1.0'
    }
  };

  try {
    const response = await httpsRequest(options);
    
    if (response.status !== 200) {
      return {
        valid: false,
        error: `HTTP ${response.status}`,
        details: response.data
      };
    }

    if (!response.data.success) {
      return {
        valid: false,
        error: 'API Error',
        details: response.data.errors || response.data
      };
    }

    return {
      valid: true,
      data: response.data.result
    };
  } catch (error) {
    return {
      valid: false,
      error: 'Network Error',
      details: error.message
    };
  }
}

/**
 * Analizar permisos del token
 */
function analyzePermissions(tokenData) {
  const permissions = tokenData.permissions || {};
  const actualScopes = [];
  const missingScopes = [];
  const extraScopes = [];

  // Extraer scopes actuales
  for (const [resource, actions] of Object.entries(permissions)) {
    if (Array.isArray(actions)) {
      for (const action of actions) {
        actualScopes.push(`${resource}:${action}`);
      }
    }
  }

  // Verificar scopes requeridos
  for (const requiredScope of REQUIRED_SCOPES) {
    if (!actualScopes.includes(requiredScope)) {
      missingScopes.push(requiredScope);
    }
  }

  // Identificar scopes extra
  for (const actualScope of actualScopes) {
    if (!REQUIRED_SCOPES.includes(actualScope)) {
      extraScopes.push(actualScope);
    }
  }

  return {
    actualScopes,
    missingScopes,
    extraScopes,
    hasAllRequired: missingScopes.length === 0,
    scopeCount: {
      actual: actualScopes.length,
      required: REQUIRED_SCOPES.length,
      missing: missingScopes.length,
      extra: extraScopes.length
    }
  };
}

/**
 * Generar reporte de verificación
 */
function generateReport(verificationResult, analysisResult) {
  const timestamp = new Date().toISOString();
  
  return {
    timestamp,
    token: {
      valid: verificationResult.valid,
      error: verificationResult.error || null,
      id: verificationResult.valid ? verificationResult.data.id : null,
      status: verificationResult.valid ? verificationResult.data.status : null
    },
    scopes: analysisResult ? {
      compliance: analysisResult.hasAllRequired ? 'COMPLIANT' : 'NON_COMPLIANT',
      summary: analysisResult.scopeCount,
      required: REQUIRED_SCOPES,
      actual: analysisResult.actualScopes,
      missing: analysisResult.missingScopes,
      extra: analysisResult.extraScopes
    } : null,
    recommendations: analysisResult && !analysisResult.hasAllRequired ? [
      'Token carece de permisos requeridos',
      'Crear nuevo token con scopes mínimos', 
      'Verificar configuración en Cloudflare Dashboard'
    ] : analysisResult ? [
      'Token cumple requisitos mínimos',
      'Considerar remover scopes extra si no se usan'
    ] : []
  };
}

/**
 * Función principal
 */
async function main() {
  const token = process.argv[2] || process.env.CF_API_TOKEN;
  
  if (!token) {
    console.error('❌ No se proporcionó token');
    console.error('Uso: node cf_token_verify.mjs [token]');
    console.error('   o: CF_API_TOKEN=... node cf_token_verify.mjs');
    process.exit(1);
  }

  // Verificar token
  console.error('🔍 Verificando token Cloudflare...');
  const verificationResult = await verifyToken(token);
  
  let analysisResult = null;
  
  if (verificationResult.valid) {
    console.error('✅ Token válido, analizando permisos...');
    analysisResult = analyzePermissions(verificationResult.data);
  } else {
    console.error('❌ Token inválido o error de API');
  }

  // Generar reporte
  const report = generateReport(verificationResult, analysisResult);
  
  // Salida JSON para procesamiento automatizado
  console.log(JSON.stringify(report, null, 2));
  
  // Código de salida
  if (!verificationResult.valid) {
    process.exit(2); // Token inválido
  } else if (analysisResult && !analysisResult.hasAllRequired) {
    process.exit(3); // Scopes insuficientes  
  } else {
    process.exit(0); // Todo OK
  }
}

// Ejecutar si es llamado directamente
if (import.meta.url === `file://${process.argv[1]}`) {
  main().catch(error => {
    console.error('💥 Error inesperado:', error.message);
    process.exit(1);
  });
}