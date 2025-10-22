# Acceptance Test Plan - Staging Environment

## Objetivo
Validar la integración WP Staging Lite en el entorno de staging real de RunArt Foundry antes del deployment a producción.

## Pre-requisitos
- Acceso al entorno de staging de RunArt Foundry
- Permisos de administrador en WordPress
- Acceso a GitHub Actions del repositorio
- WP-CLI disponible (opcional pero recomendado)

## Paquete de deployment
- **ZIP**: `WP_Staging_Lite_RunArt_v1.0.zip` (≈25KB)
- **Checksum**: `fd75524f84fac4afff01283b5404344fa9a7b80495022cec8af50c59e5b39f6f`
- **Ubicación**: `docs/integration_wp_staging_lite/ENTREGA_RUNART/`

## Fases de testing

### Fase 1: Deployment del MU-plugin

#### 1.1 Instalación desde ZIP
```bash
# Descargar ZIP del repositorio
cd /tmp
wget https://github.com/RunArtFoundry/runart-foundry/raw/feature/wp-staging-lite-integration/docs/integration_wp_staging_lite/ENTREGA_RUNART/WP_Staging_Lite_RunArt_v1.0.zip

# Verificar integridad
echo "fd75524f84fac4afff01283b5404344fa9a7b80495022cec8af50c59e5b39f6f  WP_Staging_Lite_RunArt_v1.0.zip" | sha256sum -c

# Extraer y copiar
unzip WP_Staging_Lite_RunArt_v1.0.zip
cp -r wp-content/mu-plugins/wp-staging-lite /path/to/staging/wp-content/mu-plugins/
cp wp-content/mu-plugins/wp-staging-lite.php /path/to/staging/wp-content/mu-plugins/
```

#### 1.2 Verificación inicial
- [ ] Plugin aparece en `/wp-admin/plugins.php?plugin_status=mustuse`
- [ ] Descripción: "WP Staging Lite — Endpoints REST para briefing hub"
- [ ] No hay errores PHP en logs
- [ ] Sitio carga normalmente

### Fase 2: Testing de endpoints REST

#### 2.1 Endpoint Status (GET)
```bash
# Test básico
curl -X GET https://staging.runartfoundry.com/wp-json/briefing/v1/status

# Test con headers
curl -H "Accept: application/json" https://staging.runartfoundry.com/wp-json/briefing/v1/status
```

**Resultado esperado**:
```json
{
  "version": "staging",
  "last_update": "2025-10-22T...",
  "health": "OK",
  "services": [{"name": "web", "state": "OK"}]
}
```

#### 2.2 Endpoint Trigger (POST) - Deshabilitado
```bash
curl -X POST https://staging.runartfoundry.com/wp-json/briefing/v1/trigger \
  -H "Content-Type: application/json" \
  -d '{}'
```

**Resultado esperado**: 
- HTTP 501 Not Implemented
- JSON: `{"ok":false,"message":"Trigger deshabilitado..."}`

#### 2.3 Endpoint técnico (para bypass de canonical redirect)
```bash
curl https://staging.runartfoundry.com/briefing-hub-test
```

**Resultado esperado**: Página básica sin redirecciones

### Fase 3: Testing de shortcode

#### 3.1 Crear página de prueba
1. Ir a `/wp-admin/post-new.php?post_type=page`
2. Título: "Test Hub Status"
3. Contenido: `[briefing_hub]`
4. Publicar y obtener URL

#### 3.2 Validar renderizado
- [ ] Shortcode muestra estado actual del sistema
- [ ] URL status es configurable por filtro
- [ ] No hay errores de renderizado
- [ ] Responsive design funciona
- [ ] Contenido se actualiza al cambiar `status.json`

### Fase 4: Testing de workflows

#### 4.1 Instalar workflows desde ZIP
```bash
# Los workflows están incluidos en el ZIP
cp .github/workflows/receive_repository_dispatch.yml .github/workflows/
cp .github/workflows/post_build_status.yml .github/workflows/
git add .github/workflows/
git commit -m "feat: add WP Staging Lite workflows"
git push
```

#### 4.2 Configurar secrets
Según `SECRETS_REFERENCE.md`:
- [ ] `WORKFLOW_SECRET` configurado (si se usa)
- [ ] Permisos de token GitHub Actions verificados
- [ ] Variables de entorno establecidas

#### 4.3 Ejecutar workflow de prueba
```bash
# Trigger repository_dispatch
curl -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: token YOUR_TOKEN" \
  https://api.github.com/repos/RunArtFoundry/runart-foundry/dispatches \
  -d '{"event_type":"staging_test","client_payload":{"test":"acceptance"}}'
```

#### 4.4 Verificar generación de status.json
- [ ] Archivo `docs/status.json` se genera/actualiza
- [ ] Contiene timestamp reciente
- [ ] Endpoint `/status` refleja nuevo contenido

### Fase 5: Testing E2E

#### 5.1 Flujo completo
1. **Repository dispatch** → log en `docs/ops/logs/`
2. **Build workflow** → `docs/status.json` actualizado  
3. **Endpoint GET** → refleja nuevo estado
4. **Shortcode** → muestra estado actualizado en página

#### 5.2 Testing de rollback
- [ ] Seguir `ROLLBACK_PLAN.md` paso a paso
- [ ] Verificar eliminación completa de archivos
- [ ] Confirmar que endpoints devuelven 404
- [ ] Validar que shortcode muestra error graceful

### Fase 6: Testing de seguridad

#### 6.1 Verificación de secrets
- [ ] No hay tokens reales en código
- [ ] Variables de entorno usan placeholders
- [ ] Logs no exponen información sensible

#### 6.2 Testing de permisos
- [ ] Endpoint `/status` es público (sin autenticación)
- [ ] Endpoint `/trigger` rechaza requests (501)
- [ ] Workflows solo ejecutan con permisos correctos

## Criterios de aceptación

### Funcionales
- [ ] Endpoint `/status` responde JSON válido < 500ms
- [ ] Endpoint `/trigger` está deshabilitado (HTTP 501)
- [ ] Shortcode renderiza estado sin errores
- [ ] Workflows ejecutan y generan `status.json` actualizado
- [ ] Sin errores PHP en logs de WordPress
- [ ] Logs de repository_dispatch se generan correctamente

### No funcionales  
- [ ] Performance: endpoints responden < 500ms promedio
- [ ] Seguridad: sin secrets reales en código fuente
- [ ] Compatibilidad: funciona con tema/plugins actuales
- [ ] Observabilidad: eventos registrados en logs estructurados
- [ ] Rollback: reversión completa en < 5 minutos

### Documentación
- [ ] Todos los archivos de documentación accesibles
- [ ] Enlaces en PR funcionan correctamente
- [ ] Troubleshooting guide cubre casos encontrados

## Entregables de testing

### Documentos a generar (ubicación: `docs/staging_tests/`)
1. **execution_log.md**: resultados paso a paso con timestamps
2. **performance_metrics.json**: tiempos de respuesta y latencias
3. **error_review.md**: análisis de logs y errores encontrados
4. **screenshots/**: evidencia visual de admin, shortcode y endpoints
5. **rollback_validation.md**: evidencia de reversión exitosa
6. **security_checklist.md**: verificación de no-secrets y permisos

### Métricas clave a documentar
- Tiempo de instalación completa
- Latencia promedio de endpoints
- Tamaño de logs generados
- Tiempo de rollback completo

## Sign-off checklist

### Pre-producción
- [ ] Todos los tests pasan sin errores críticos
- [ ] Performance dentro de límites aceptables
- [ ] Rollback validado y documentado
- [ ] Equipo entrenado en operación y troubleshooting

### Aprobaciones requeridas
- [ ] **Technical lead**: funcionalidad y arquitectura
- [ ] **DevOps**: workflows y deployment
- [ ] **Security**: revisión de secrets y permisos
- [ ] **Product**: acceptance criteria cumplidos

## Contacto y escalación

### Durante testing
- **Blocker crítico**: Ejecutar rollback inmediato según `ROLLBACK_PLAN.md`
- **Dudas técnicas**: Consultar `TROUBLESHOOTING.md`
- **Issues menores**: Documentar en execution log para review

### Post-testing
- **Feedback**: Actualizar `LESSONS_LEARNED.md`
- **Mejoras**: Crear issues para iteraciones futuras
- **Documentación**: Actualizar acceptance plan con hallazgos

---

**Versión**: 2.0 (actualizada por Copaylo)  
**Fecha**: 2025-10-22  
**Estimación**: 3-5 horas de ejecución completa  
**Próxima revisión**: Post-deployment a producción
