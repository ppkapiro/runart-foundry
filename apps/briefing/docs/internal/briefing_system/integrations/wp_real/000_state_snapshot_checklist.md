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

## 🔍 Hallazgos

**Estado:** 🟡 Pendiente evidencias del owner

### Repo Git
- **Status:**
- **Remotes:** (será completado tras evidencia)
- **Workflows:** `verify-home`, `verify-settings`, `verify-menus`, `verify-media` (listos en modo placeholder)
- **Variables/Secrets:** Esperado `WP_BASE_URL`, `WP_USER`, `WP_APP_PASSWORD` (aún vacíos)
- **Riesgos identificados:** (será completado)

### Descarga Local
- **Status:**
- **Árbol:** (será completado)
- **Tipos de activos:** (será completado)
- **Tamaño total:** (será completado)
- **Riesgos identificados:** (será completado)

### SSH & Servidor
- **Status:**
- **Conectividad:** (será completado)
- **SO/Stack:** (será completado)
- **Permisos:** (será completado)
- **Riesgos identificados:** (será completado)

### REST API & Authn
- **Status:**
- **Disponibilidad wp-json:** (será completado)
- **Application Passwords:** (será completado)
- **Endpoints validables:** (será completado)
- **Riesgos identificados:** (será completado)

---

## 💡 Acciones Sugeridas

### Corto Plazo (Antes de Auth=OK)
1. Owner pega evidencias en `_templates/evidencia_*.txt`
2. Owner marca checkboxes en Issue #50 (Bloque "Evidencias Fase 7")
3. Copilot consolida hallazgos en este documento
4. Copilot propone decisión en `050_decision_record_styling_vs_preview.md`

### Mediano Plazo (Tras decisión)
- **Si "Styling primero":** Listar cambios mínimos de tema, aplicar en staging, replicar a prod
- **Si "Preview primero":** Habilitar subdominio, ejecutar verify-* en staging, validar
- **Si "Mixto":** Ambas en paralelo

### Largo Plazo (Post Fase 7)
- Ejecutar `verify-*` con Auth=OK en entorno determinado (staging o prod)
- Capturar artifacts reales
- Adjuntar en Issue #50
- Proceder a Fase 8

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
