# 🔗 Integración WordPress Real — Documentación Fase 7

**Propósito:** Centralizar evidencia y decisiones sobre la conmutación de workflows `verify-*` de modo placeholder a WordPress real (runalfondry.com).

**Ubicación:** `apps/briefing/docs/internal/briefing_system/integrations/wp_real/`

---

## 📋 Índice de Documentos

### 1. **000_state_snapshot_checklist.md**
Documento central de verificación. Contiene:
- Resumen de fuentes de evidencia (repo, local, SSH, WP-REST)
- Matriz de accesos
- Checklist de verificación
- Hallazgos consolidados
- Acciones sugeridas
- Guía para aportar evidencias (sin secretos)

**Responsable:** Owner (aporta evidencias), Copilot (consolida hallazgos)

### 2. **010_repo_access_inventory.md**
Inventario del repositorio Git:
- Orígenes/Remotes
- Branches protegidas
- Workflows detectados (`verify-home`, `verify-settings`, `verify-menus`, `verify-media`)
- Variables/Secrets esperadas (placeholder vs real)
- Riesgos de exposición

**Entrada esperada:** Texto plano de `git remote -v`, rama actual, workflows activos.

### 3. **020_local_mirror_inventory.md**
Inventario local (descarga de contenido):
- Árbol de directorios (alto nivel)
- Qué se descargó: DB dump, `wp-content`, uploads, temas, plugins, etc.
- Checksums (si aplica)
- **NO versionar:** Lista de exclusiones y patrones

**Entrada esperada:** Árbol del directorio `mirror/` o descarga local, tamaños aproximados.

### 4. **030_ssh_connectivity_and_server_facts.md**
Información del servidor (sanitizada):
- Hostname / Proveedor
- SO / Kernel (ej: Linux 5.x)
- Stack: Nginx/Apache, PHP-FPM versión, MySQL/MariaDB versión
- Ubicación raíz de WordPress
- Permisos/Propietario de archivos
- Buenas prácticas pendientes

**Entrada esperada:** Salidas sanitizadas de `uname -a`, `php -v`, `nginx -v`/`apachectl -v` (SIN datos sensibles).

### 5. **040_wp_rest_and_authn_readiness.md**
Preparación REST y autenticación:
- Endpoint base (`.../wp-json/`)
- Disponibilidad (HTTP 200/401/403)
- Endpoints a validar: `users/me`, `settings`, `pages`, menus (plugin si existe)
- Compatibilidad con Application Passwords
- Notas de seguridad (caché, WAF)

**Entrada esperada:** Status HTTP de endpoints clave (SIN tokens).

### 6. **050_decision_record_styling_vs_preview.md**
Decisión de arquitectura (ADR) formato:

**Opciones evaluadas:**
- **O1 Styling primero:** Ajustes de tema/child-theme, hardening UI, luego verify-* a Auth=OK
- **O2 Preview primero:** Staging/subdominio espejo para validar verify-* con mínimo riesgo, luego replicar a prod
- **O3 Mixto:** Preview mínimo + ajustes críticos de styling simultáneamente

**Incluye:**
- Consecuencias de cada opción
- Riesgos asociados
- Criterios de aceptación
- Semáforo de riesgo (Rojo/Amarillo/Verde)
- Next Steps

**Responsable:** Copilot (propone opciones), Owner (valida).

### 7. **060_risk_register_fase7.md** ✅
Registro de riesgos en tabla con análisis profundo:
- **Matriz de riesgos completa:** 10 riesgos identificados (R1-R10)
- **Clasificación:** Altos, Medios, Bajos
- **Para cada riesgo:** Probabilidad, Impacto, Mitigación, Evidencia, Estado
- **Riesgos ALTOS:** R1 (Credenciales expuestas) — **YA MITIGADO** con GitHub Secrets
- **Riesgos MEDIOS:** R2-R7, R9 (REST API, App Passwords, staging, etc.)
- **Matriz de decisión:** Qué hacer si ocurre cada riesgo
- **Checklist pre/durante/post ejecución**

### 8. **README.md** (este archivo)
Índice y guía de uso de la carpeta.

### 9. **070_preview_staging_plan.md** ✅
Plan operativo para validación en staging:
- Setup de infraestructura (subdominio, BD, archivos, credenciales)
- Checklist de 3 fases (infraestructura, credenciales, GitHub)
- Validación secuencial de 4 workflows (verify-home → settings → menus → media)
- Transición a producción (cambio de variables, validación final)
- Rollback plan (revertir a staging o placeholder si falla)
- Timeline estimado: ~4-5 horas total

---

## 🎯 Flujo de Uso

### Fase 1: Recolección de Evidencias
1. Owner revisa cada archivo `00X_*.md` (excepto `050_decision_record...`)
2. Owner pega evidencias en **`_templates/evidencia_*.txt`** (texto plano)
3. Owner marca checkboxes en **Issue #50** → Bloque "Evidencias Fase 7"

### Fase 2: Análisis y Consolidación
1. Copilot revisa evidencias en `_templates/`
2. Copilot completa "Hallazgos" en `000_state_snapshot_checklist.md`
3. Copilot propone decisión en `050_decision_record_styling_vs_preview.md`

### Fase 3: Validación y Decisión
1. Owner valida hallazgos y propuesta de decisión
2. Decide: "Styling primero" / "Preview primero" / "Mixto"
3. Se ejecutan acciones acorde a la decisión

### Fase 4: Implementación
- Si **Styling primero:** Aplicar cambios de tema en staging, replicar a prod, luego verify-*
- Si **Preview primero:** Habilitar subdominio staging, ejecutar verify-* ahí, validar, promover a prod
- Si **Mixto:** Ambas en paralelo con coordinación

---

## ⚠️ Qué NO Subir (Exclusiones)

**Nunca versionar en Git:**
- `*.sql` (dumps de BD)
- `wp-config.php*` (credenciales)
- `*.key`, `*.pem`, `*.crt` (certificados/keys)
- `*.env` (variables de entorno)
- `secrets/` (carpetas de secretos)
- `wp-content/uploads/` (masivo, usar .gitkeep)
- `wp-content/plugins/*/` (versionar solo nombre/versión en texto)

**Patrón `.gitignore` local (si es necesario):**
```
_templates/*.sql
_templates/*.key
_templates/*.pem
_templates/wp-config*
_templates/.env*
_templates/secrets/
_templates/uploads/
```

---

## 🔐 Cómo Aportar Evidencias SIN Exponer Secretos

### Regla de Oro
**Nunca pegar tokens, contraseñas, claves, o credenciales en los archivos.**

### Por Tipo de Evidencia

#### 1. **Git Remotes** (`evidencia_repo_remotes.txt`)
```bash
# CORRECTO: Pegar salida de git remote -v
origin    git@github.com:RunArtFoundry/runart-foundry.git (fetch)
origin    git@github.com:RunArtFoundry/runart-foundry.git (push)
```

#### 2. **WP-CLI** (`evidencia_wp_cli_info.txt`)
```bash
# CORRECTO: Pegar nombre/versión de plugins y tema, no paths de credenciales
WordPress version: 6.4.1
PHP version: 8.2.0
Theme: RunArt Child Theme (activo)
Plugins:
  - Polylang (v3.5) - activo
  - WooCommerce (v8.0) - inactivo
```

#### 3. **Versiones del servidor** (`evidencia_server_versions.txt`)
```bash
# CORRECTO: Versiones, SO, stack (sin datos de configuración sensible)
PHP 8.2.0 (cli)
Nginx 1.24.0
MySQL 8.0.35
Linux 5.15.0-56-generic #62-Ubuntu
```

#### 4. **REST API** (`evidencia_rest_sample.txt`)
```
# CORRECTO: Status y headers, no tokens ni auth
GET https://runalfondry.com/wp-json/
HTTP/1.1 200 OK
Content-Type: application/json
Cache-Control: public, max-age=3600

GET https://runalfondry.com/wp-json/wp/v2/users/me
HTTP/1.1 401 Unauthorized
(Sin incluir credenciales ni Authorization header)
```

---

## 📌 Checklist de Completitud

### Documentación ✅
- [x] README.md (índice y guía de uso)
- [x] 000_state_snapshot_checklist.md (verificación central — consolidado con hallazgos e interpretación)
- [x] 010_repo_access_inventory.md (inventario Git)
- [x] 020_local_mirror_inventory.md (activos locales)
- [x] 030_ssh_connectivity_and_server_facts.md (servidor)
- [x] 040_wp_rest_and_authn_readiness.md (REST/Auth)
- [x] 050_decision_record_styling_vs_preview.md (ADR — 🟢 Opción 2 recomendada)
- [x] 060_risk_register_fase7.md (riesgos + matriz)
- [x] 070_preview_staging_plan.md (plan operativo staging — nuevo)
- [x] _templates/ con 4 archivos de ejemplo (sin secretos)
- [x] .gitignore (proteger carpeta de secretos)

### Consolidación de Evidencias ⏳
- [ ] Owner pega `git remote -v` en `_templates/evidencia_repo_remotes.txt`
- [ ] Owner pega árbol local en `_templates/evidencia_local_mirror.txt` (crear)
- [ ] Owner pega `uname -a`, `php -v`, `nginx -v` en `_templates/evidencia_server_versions.txt`
- [ ] Owner pega `curl -i /wp-json/` en `_templates/evidencia_rest_sample.txt`

### ADR & Decisión ⏳
- [ ] Owner revisar ADR (`050_decision_record_styling_vs_preview.md`)
- [ ] Owner confirmar decisión: Preview / Styling / Mixto en Issue #50
- [ ] Copilot recibe confirmación y procede con plan elegido

### Implementación (Si se elige Preview Primero) ⏳
- [ ] Owner prepara staging (hostname, BD, archivos)
- [ ] Owner crea credenciales en WP-staging
- [ ] Owner carga variables/secrets en GitHub (apuntando a staging)
- [ ] Copilot ejecuta verify-* en staging (4 workflows)
- [ ] Adjuntar artifacts staging en Issue #50
- [ ] Owner cambia variables a producción
- [ ] Copilot ejecuta verify-* en producción (4 workflows)
- [ ] Adjuntar artifacts producción en Issue #50
- [ ] ✅ Fase 7 COMPLETADA

---

## 🔗 Referencias

- **Issue #50:** `issues/Issue_50_Fase7_Conexion_WordPress_Real.md`
- **Guía rápida owner:** `_reports/GUIA_RAPIDA_OWNER_FASE7_20251020.md`
- **Reporte ejecución:** `_reports/FASE7_EJECUCION_CONEXION_WP_REAL_20251020.md`
- **README Fase 7:** `README.md` (raíz, sección "🔐 Integración WP Real")

---

**Última actualización:** 2025-10-20  
**Estado:** ✅ Documentación COMPLETA | 🟡 En espera de evidencias del owner  
**Próximo paso:** Owner aporta evidencias en `_templates/` y marca checkboxes en Issue #50

---

## 📊 Estadísticas de la Carpeta

| Ítem | Cantidad | Estado |
|------|----------|--------|
| Documentos Markdown | 9 | ✅ Completo (incl. 070_preview_staging_plan.md) |
| Templates de Evidencia | 4 | ⏳ Vacíos (esperando owner) |
| Secciones Documentadas | ~60 | ✅ Completo |
| Líneas de documentación | ~3,200 | ✅ Completo |
| Riesgos Identificados | 10 | ✅ Con matriz |
| Opciones de Decisión | 3 | ✅ Con análisis + recomendación |
| Ejemplos Incluidos | 35+ | ✅ Correcto/Incorrecto |
| Plan operativo (staging) | 1 | ✅ Detallado |
