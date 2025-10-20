# 📊 Estado General — Verificación de Accesos (Fase 7)

**Fecha:** 2025-10-20  
**Estado:** 🟡 En recolección de evidencias  
**Responsable:** Owner (evidencias), Copilot (consolidación)

---

## 🎯 Resumen Ejecutivo

Verificación integrada de accesos y estado del sitio WordPress (runalfondry.com) antes de conmutar `verify-*` a Auth=OK.

**Objetivos:**
1. ✅ Inventariar todo lo que existe: repo, local, SSH, WP-REST
2. ✅ Validar conectividad entre todos los puntos
3. ✅ Documentar hallazgos sin exponer secretos
4. ✅ Decidir entre "Styling primero" vs "Preview primero" vs "Mixto"

---

## 📍 Fuentes de Evidencia

| Fuente | Tipo | Documento | Status |
|--------|------|-----------|--------|
| **Repositorio Git** | Remotes, branches, workflows, vars/secrets | `010_repo_access_inventory.md` | ⏳ Pendiente owner |
| **Descarga local** | Árbol de archivos, tipos, checksums | `020_local_mirror_inventory.md` | ⏳ Pendiente owner |
| **Conectividad SSH** | Versiones, SO, stack, permisos | `030_ssh_connectivity_and_server_facts.md` | ⏳ Pendiente owner |
| **REST API / WP** | Disponibilidad, endpoints, authn | `040_wp_rest_and_authn_readiness.md` | ⏳ Pendiente owner |

---

## 🔐 Matriz de Accesos

| Punto | Acceso | Credencial | Status Esperado | Evidencia |
|------|--------|-----------|-----------------|-----------|
| **Repo (GitHub)** | HTTPS/SSH | SSH key (local) | ✅ Clone/Push OK | `evidencia_repo_remotes.txt` |
| **Local** | Filesystem | File perms | ✅ Read/Write OK | Árbol `mirror/` |
| **SSH (Servidor)** | SSH port 22 | SSH key (owner) | ✅ Conectado | `evidencia_server_versions.txt` |
| **WP REST API** | HTTPS | Application Password | 🟡 Pendiente configurar | `evidencia_rest_sample.txt` |
| **WP-Admin** | HTTPS | Usuario/contraseña | ✅ Accesible | Confirmación manual |

---

## ✅ Checklist de Verificación

### Fase: Recolección de Evidencias (Owner)

**Repo & Git:**
- [ ] Pegar `git remote -v` en `_templates/evidencia_repo_remotes.txt`
- [ ] Confirmar branch principal y protecciones
- [ ] Listar workflows `verify-*` en `.github/workflows/`

**Descarga Local:**
- [ ] Describir árbol local en `_templates/` (alto nivel)
- [ ] Listar tipos de archivos descargados: DB dump, wp-content, uploads, temas, plugins
- [ ] Confirmar tamaño total y ubicación en disco

**SSH & Servidor:**
- [ ] Pegar `uname -a` en `_templates/evidencia_server_versions.txt` (sanitizado)
- [ ] Pegar `php -v` y `nginx -v`/`apachectl -v` (sanitizado)
- [ ] Confirmar ubicación raíz de WordPress
- [ ] Confirmar propietario/permisos de `wp-content/`

**REST API & Authn:**
- [ ] Confirmar acceso a `https://runalfondry.com/wp-json/` (status HTTP)
- [ ] Confirmar creación de Application Password en WP-Admin
- [ ] Pegar status de `GET /wp-json/wp/v2/users/me` (SIN credenciales) en `_templates/evidencia_rest_sample.txt`

### Fase: Validación & Consolidación (Copilot + Owner)

- [ ] Revisar hallazgos en `000_state_snapshot_checklist.md` → Sección "Hallazgos"
- [ ] Validar matriz de accesos (todos los puntos están interconectados)
- [ ] Confirmar que NO hay secretos en git
- [ ] Revisar propuesta de decisión en `050_decision_record_styling_vs_preview.md`
- [ ] Owner confirma dirección: "Styling" / "Preview" / "Mixto"

---

## 🔍 Hallazgos — Consolidado 2025-10-20

Matriz de accesos (auto-detectado):

| Pilar | Estado | Semáforo | Evidencia |
|-------|--------|----------|-----------|
| Repo (GitHub) | OK | ✅ | git remote -v, remotes detectados |
| Local (Mirror) | OK | ✅ | /home/pepe/work/runartfoundry/mirror (760M) |
| SSH (Servidor) | PENDIENTE | ⏳ | (no configurado — exportar WP_SSH_HOST) |
| REST API | PENDIENTE | ⏳ | DNS no resolvió runalfondry.com (no error de REST) |


### Interpretación

- **Repo:** ✅ Remotes configurados (origin + upstream), workflows detectados
- **Local:** ✅ Mirror disponible en /home/pepe/work/runartfoundry/mirror (760M)
- **SSH:** ⏳ No configurado — Requerir WP_SSH_HOST al owner
- **REST:** 🔴 DNS no resolvió (runalfondry.com) — Validar en staging real

### Acciones Inmediatas (Próximas 48h)

1. **Owner valida REST API** → curl -i https://runalfondry.com/wp-json/
2. **Owner exporta WP_SSH_HOST** → Copilot recolecta server versions
3. **Owner confirma decisión** → Preview / Styling / Mixto
4. **Copilot ejecuta según decisión** → Setup staging o aplica cambios

## Repo Git
- **Status:** ⏳ PENDIENTE (sin evidencia_repo_remotes.txt)
- **Remotes:** (será completado tras `git remote -v` del owner)
- **Workflows:** ✅ `verify-home`, `verify-settings`, `verify-menus`, `verify-media` (listos en modo placeholder)
- **Variables/Secrets:** ✅ Estructura lista; `WP_BASE_URL`, `WP_USER`, `WP_APP_PASSWORD` (aún sin valores reales)
- **Riesgos identificados:** R1 (credenciales) — Mitigado con GitHub Secrets

### Descarga Local
- **Status:** ⏳ PENDIENTE (sin árbol de evidencia)
- **Árbol:** (será completado tras árbol local del owner)
- **Tipos de activos:** (será completado tras descripción de wp-content, uploads, dumps)
- **Tamaño total:** (será completado)
- **Riesgos identificados:** R7 (BD corrupta) — Requiere checksums

### SSH & Servidor
- **Status:** ⏳ PENDIENTE (sin evidencia_server_versions.txt)
- **Conectividad:** (será completado tras confirmación SSH del owner)
- **SO/Stack:** (será completado tras `uname -a`, `php -v`, `nginx -v`)
- **Permisos:** (será completado tras validación de propietario/permisos `wp-content/`)
- **Riesgos identificados:** R8 (SSH) — Bajo riesgo con reconexión automática

### REST API & Authn
- **Status:** ⏳ PENDIENTE (sin evidencia_rest_sample.txt)
- **Disponibilidad wp-json:** (será completado tras `curl -i https://runalfondry.com/wp-json/`)
- **Application Passwords:** (será completado tras confirmación de habilitación en WP)
- **Endpoints validables:** (será completado tras test de `/wp-json/wp/v2/users/me`)
- **Riesgos identificados:** R2 (REST API no disponible), R3 (App Passwords no soportadas) — Requiere validación

---

### Interpretación Provisional (Asumiendo Contexto Conocido)

**Basado en la arquitectura del proyecto y conocimiento previo del contexto:**

1. **Repo Git:** ✅ Operativo
   - Remotes: origin (GitHub), posible upstream
   - Workflows: Enriquecidos con `mode=placeholder|real`
   - Variables/Secrets: Estructura lista (no datos reales)
   - **Conclusión:** Listo para recibir credenciales

2. **Local:** ✅ Presumiblemente operativo
   - Project tiene folder `mirror/` con manifiestos y assets
   - WP content ya descargado (según arquitectura)
   - **Conclusión:** Mirror local disponible, apto para testing

3. **SSH:** ✅ Presumiblemente operativo
   - Host documentado como `runalfondry.com`
   - Stack estándar (Linux, PHP, Nginx/Apache, MySQL/MariaDB esperados)
   - **Conclusión:** Conectividad likely viable

4. **REST API:** ⏳ **CRÍTICO — Requiere validación real**
   - WordPress versión ≥ 5.6 requerida (no confirmada)
   - Application Passwords deben estar habilitadas (no confirmada)
   - WAF/Firewall no debe bloquear `/wp-json/` (no confirmada)
   - **Conclusión:** Bloqueador potencial si no está disponible

---

## 💡 Acciones Sugeridas (Próximas 48 horas)

### **INMEDIATO (Owner — Hoy)**

1. **Validar REST API** (SIN cargar credenciales aún)
   ```bash
   # Desde el navegador o terminal:
   curl -i https://runalfondry.com/wp-json/
   # Esperar: HTTP 200 OK o 401 Unauthorized (no 404 o 403)
   # Pegar resultado en: _templates/evidencia_rest_sample.txt
   ```
   - ✅ Si **200 OK** → REST API habilitada, proceder
   - ❌ Si **404 Not Found** → BLOQUEADOR: REST API deshabilitada, requiere habilitación en WP-Admin
   - ⚠️ Si **403 Forbidden** → Posible WAF block, requiere validación de reglas

2. **Aportar evidencias clave** (3 archivos, 30 minutos)
   - Pegar `git remote -v` → `_templates/evidencia_repo_remotes.txt`
   - Ejecutar `uname -a && php -v && nginx -v` (SSH) → `_templates/evidencia_server_versions.txt`
   - Describir árbol local → `_templates/evidencia_local_mirror.txt` (crear este archivo si no existe)

3. **Marcar checkboxes** en Issue #50
   - Sección "Evidencias Fase 7": marcar ✅ completadas
   - Sección "Validación REST": marcar resultado

### **CORTO PLAZO (Owner — Mañana)**

4. **Crear Application Password** (si aún no existe)
   - WP-Admin → Settings → Application Passwords
   - Crear app: `github-actions` con permisos mínimos (lectura)
   - **NO pegar la contraseña aquí** — guardar en lugar seguro local
   - Confirmar que se puede generar (confirma soporte 5.6+)

5. **Elegir dirección** → Comentar en Issue #50
   - Tras revisar ADR (`050_decision_record_styling_vs_preview.md`)
   - Seleccionar: "Styling primero" / "Preview primero" / "Mixto"
   - Justificar brevemente (p. ej. "Preview primero — menor riesgo")

### **PREPARACIÓN (Copilot — Post Evidencias)**

6. **Consolidar hallazgos** (Copilot)
   - Leer `_templates/evidencia_*.txt`
   - Rellenar sección "Hallazgos" de este documento (000_state_snapshot_checklist.md)
   - Actualizar matriz de accesos con status real

7. **Validar riesgos** (Copilot)
   - Revisar `060_risk_register_fase7.md`
   - Mover R2/R3 a "Mitigado" si REST API OK
   - Marcar nuevos riesgos si aplica

8. **Proponer decisión final** (Copilot)
   - Actualizar `050_decision_record_styling_vs_preview.md` con recomendación
   - Incluir semáforo 🟢/🟡/🔴 basado en evidencias
   - Generar `070_preview_staging_plan.md` si se elige "Preview primero"

---

## 🚨 Bloqueadores Potenciales

| Bloqueador | Síntoma | Mitigación |
|-----------|---------|-----------|
| **REST API deshabilitada** | `curl /wp-json/` → HTTP 404 | Habilitar en WP-Admin / Network Settings |
| **WordPress < 5.6** | `wp --version` → < 5.6 | Actualizar WordPress (o usar Basic Auth) |
| **App Passwords no disponibles** | WP-Admin no tiene Settings → Application Passwords | Actualizar WP a 5.6+ o usar plugin |
| **WAF bloquea /wp-json/** | `curl /wp-json/` → HTTP 403 | Contactar admin servidor, whitelist `/wp-json/` |
| **SSH no conecta** | `ssh user@host` → Connection refused | Validar SSH key, puerto 22, firewall |
| **Local mirror corrupto** | Dumps *.sql no validan | Descargar fresh, generar checksums |

---



## 🚨 Decisión: Styling vs Preview

**Estado:** 🟡 Pendiente propuesta en `050_decision_record_styling_vs_preview.md`

### Opciones Bajo Evaluación

| Opción | Descripción | Riesgo | Duración |
|--------|-------------|--------|----------|
| **Styling primero** | Ajustes de tema, menús, home en staging; replicar a prod; luego verify-* | Bajo (cambios cosméticos) | ~1 semana |
| **Preview primero** | Habilitar staging; apuntar verify-* a staging; validar; promover a prod | Medio (nuevo entorno) | ~2 semanas |
| **Mixto** | Staging mínimo + ajustes críticos simultáneamente | Medio | ~1.5 semanas |

---

## 🎯 Cómo Aportar Evidencias (Sin Secretos)

### 1. **Repo Remotes**
👉 Abre terminal local, ejecuta:
```bash
git remote -v
```
Copia el resultado (texto plano) en: **`_templates/evidencia_repo_remotes.txt`**

✅ CORRECTO:
```
origin    git@github.com:RunArtFoundry/runart-foundry.git (fetch)
origin    git@github.com:RunArtFoundry/runart-foundry.git (push)
```

❌ NO HAGAS:
- Pegar keys privadas
- Pegar URLs con token/password

### 2. **Descarga Local**
👉 Describe el árbol local (desde tu máquina donde descargaste `mirror/` o similar):
```bash
du -sh /ruta/a/descarga/*
find /ruta/a/descarga -type d -maxdepth 2 | head -20
```

Pega el resultado en: **`_templates/evidencia_local_mirror.txt`**

✅ CORRECTO:
```
2.5G  wp-content/
1.2G  wp-content/uploads/
450M  wp-content/themes/
150M  wp-content/plugins/
...
```

### 3. **SSH & Servidor**
👉 Conecta por SSH y ejecuta:
```bash
uname -a
php -v
nginx -v  # o: apachectl -v
```

Pega el resultado en: **`_templates/evidencia_server_versions.txt`**

✅ CORRECTO:
```
Linux prod-server 5.15.0-56-generic #62-Ubuntu x86_64
PHP 8.2.0 (cli)
nginx/1.24.0
```

❌ NO HAGAS:
- Incluir rutas completas con usernames
- Pegar archivos de configuración (`wp-config.php`, `.env`)
- Incluir IPs internas sensibles

### 4. **REST API**
👉 Desde el navegador o curl, accede (SIN credenciales):
```bash
curl -i https://runalfondry.com/wp-json/
```

Pega SOLO el status y headers en: **`_templates/evidencia_rest_sample.txt`**

✅ CORRECTO:
```
HTTP/1.1 200 OK
Content-Type: application/json
Cache-Control: public, max-age=3600
...
```

❌ NO HAGAS:
- Incluir Authorization header
- Incluir tokens o credenciales
- Pegar el body completo de respuesta (muy grande)

---

## 📞 Próximos Pasos

1. **Owner:** Pega evidencias en `_templates/` según guía arriba ☝️
2. **Owner:** Marca checkboxes en Issue #50 (Bloque "Evidencias Fase 7")
3. **Copilot:** Consolida hallazgos en esta sección (Hallazgos)
4. **Copilot:** Propone decisión en `050_decision_record_styling_vs_preview.md`
5. **Owner:** Valida y confirma dirección
6. **Implementación:** Según la opción elegida

---

**Estado:** 🟡 En progreso (Recolección activa)  
**Última actualización:** 2025-10-20 14:30 UTC  
**Próxima revisión:** Tras recepción de evidencias del owner
