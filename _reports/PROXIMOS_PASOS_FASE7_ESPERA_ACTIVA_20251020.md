# 📋 Próximos Pasos — Fase 7 (Espera Activa)

**Fecha:** 2025-10-20  
**Rama:** `feat/fase7-verificacion-accesos-y-estado-real`  
**Status:** 🟡 Verificación de accesos documentada, esperando evidencias del owner

---

## 🎯 Objetivo de Esta Fase

Recopilar de forma **segura** (sin exponer secretos) todas las evidencias del estado actual del sistema:
- Acceso al repositorio (Git)
- Contenido local descargado
- Servidor (SSH, SO, stack)
- API REST de WordPress

Tras recopilar evidencias → **Proponer decisión informada** sobre cómo proceder (Styling vs Preview vs Mixto).

---

## 📥 Lo que Esperamos del Owner

### 1. Revisar Documentación (30-60 min)

**Start here:** `apps/briefing/docs/internal/briefing_system/integrations/wp_real/README.md`

Luego revisar en este orden:
1. `000_state_snapshot_checklist.md` (overview de lo que se necesita)
2. `010_repo_access_inventory.md` (si tienes curiosidad sobre Git)
3. `020_local_mirror_inventory.md` (si tienes local assets)
4. `030_ssh_connectivity_and_server_facts.md` (si accedes por SSH)
5. `040_wp_rest_and_authn_readiness.md` (validar REST sin credenciales)
6. `050_decision_record_styling_vs_preview.md` (decisión a tomar)

### 2. Capturar Evidencias (1-2 hours)

**Ubicación:** `apps/briefing/docs/internal/briefing_system/integrations/wp_real/_templates/`

Ejecuta comandos simples y pega outputs **sanitizados** (sin secretos):

#### Evidencia 1: Git Remotes
```bash
# Comando:
git remote -v

# Guardar en:
_templates/evidencia_repo_remotes.txt
```

#### Evidencia 2: WP-CLI Info
```bash
# Comandos (vía SSH al servidor):
wp --version
wp plugin list --format=table
wp theme list --format=table
wp user list --role=administrator --format=table

# Guardar en:
_templates/evidencia_wp_cli_info.txt
```

#### Evidencia 3: Server Versions
```bash
# Comandos (vía SSH):
uname -a
php -v | head -1
nginx -v 2>&1  (o: apachectl -v)
mysql --version

# Guardar en:
_templates/evidencia_server_versions.txt
```

#### Evidencia 4: REST API Status
```bash
# Comandos (desde tu máquina local):
curl -i https://runalfondry.com/wp-json/
curl -i https://runalfondry.com/wp-json/wp/v2/users/me
curl -i https://runalfondry.com/wp-json/wp/v2/pages | head -20

# Guardar en:
_templates/evidencia_rest_sample.txt
```

### 3. Marcar Checklist en Issue #50 (15 min)

**Ubicación:** `issues/Issue_50_Fase7_Conexion_WordPress_Real.md`

Sección: "🔍 Verificación de Accesos — Fase 7"

Marca cada evidencia conforme la completes:
- [ ] Repo Access
- [ ] Local Mirror
- [ ] SSH Connectivity
- [ ] WP REST Readiness
- [ ] REST API Accesibilidad

### 4. Elegir Decisión (30 min)

**Ubicación:** `apps/briefing/docs/internal/briefing_system/integrations/wp_real/050_decision_record_styling_vs_preview.md`

Lee las 3 opciones:
- **Opción 1:** Styling Primero (~1 semana, riesgo 🟡 MEDIO-ALTO)
- **Opción 2:** Preview Primero (~2 semanas, riesgo 🟢 **BAJO — RECOMENDADA**)
- **Opción 3:** Mixto (~1.5 semanas, riesgo 🟡 MEDIO)

Elige una y comenta en Issue #50 o aquí en la rama.

---

## 🔐 Seguridad — Qué NO Pegar

**❌ NUNCA:**
- Contraseñas, tokens, API keys
- WP_APP_PASSWORD
- Credenciales SSH
- Contenido de wp-config.php
- Database credentials
- Private SSH keys

**✅ SÍ:**
- Salida de `git remote -v` (sin tokens)
- Salida de versiones (`php -v`, `uname -a`)
- Status HTTP y headers de REST endpoints (sin Authorization)
- Nombres de plugins/temas (no paths privados)
- Información administrativa (pública)

Cada template incluye ejemplos de ✅ CORRECTO vs ❌ NO HAGAS.

---

## 📊 Lo que Copilot Hará (Después de recibir evidencias)

### 1. Revisar y Consolidar (30 min)
- Leer archivos en `_templates/`
- Validar que no hay secretos expuestos
- Consolidar hallazgos en `000_state_snapshot_checklist.md`

### 2. Analizar Riesgos (30 min)
- Revisar matriz en `060_risk_register_fase7.md`
- Actualizar status de riesgos basado en evidencias reales
- Identificar nuevos riesgos (si aplica)

### 3. Proponer Decisión (30 min)
- Revisar opción elegida por el owner
- Validar contra matriz de riesgos
- Proponer siguiente paso con semáforo 🔴/🟡/🟢

### 4. Generar Plan (1 hour)
- Plan detallado acorde a la decisión elegida
- Timeline estimado
- Checklist de ejecución

---

## ⏰ Timeline Estimado

| Fase | Responsable | Duración | Estado |
|------|-------------|----------|--------|
| Owner: Revisar docs | Owner | 30-60 min | ⏳ Pendiente |
| Owner: Capturar evidencias | Owner | 1-2 hours | ⏳ Pendiente |
| Owner: Marcar checklist | Owner | 15 min | ⏳ Pendiente |
| Owner: Elegir decisión | Owner | 30 min | ⏳ Pendiente |
| **Subtotal Owner** | | **~2.5-3 hours** | |
| Copilot: Revisar/consolidar | Copilot | 30 min | ⏳ Bloqueado |
| Copilot: Analizar riesgos | Copilot | 30 min | ⏳ Bloqueado |
| Copilot: Proponer decisión | Copilot | 30 min | ⏳ Bloqueado |
| Copilot: Plan | Copilot | 1 hour | ⏳ Bloqueado |
| **Subtotal Copilot** | | **~2.5 hours** | |
| **Fase 4: Implementación** | Owner+Copilot | **1-2 weeks** | ⏳ Bloqueado |

---

## 🚀 Flujo Resumido

```
Owner                      →  Copilot
────────────────────────────────────
Revisar docs    (1h)
Capturar evidencias (1-2h)
Marcar checklist (15m)
Elegir decisión  (30m)     →  Revisar evidencias (30m)
                           →  Consolidar hallazgos (30m)
                           →  Analizar riesgos (30m)
                           →  Proponer decisión (30m)
                           →  Generar plan (1h)
Validar propuesta (30m)    ←  Plan listo
Confirmar         (15m)
Proceder a Fase 4          →  Implementar plan
```

---

## 📝 Documentos Relevantes

**En esta rama:**
- `apps/briefing/docs/internal/briefing_system/integrations/wp_real/README.md`
- `apps/briefing/docs/internal/briefing_system/integrations/wp_real/000_state_snapshot_checklist.md`
- `apps/briefing/docs/internal/briefing_system/integrations/wp_real/050_decision_record_styling_vs_preview.md`
- `apps/briefing/docs/internal/briefing_system/integrations/wp_real/060_risk_register_fase7.md`
- `issues/Issue_50_Fase7_Conexion_WordPress_Real.md`

**Resumen ejecutivo:**
- `_reports/FASE7_VERIFICACION_ACCESOS_RESUMEN_EJECUTIVO_20251020.md`

---

## ⚡ Llamada a Acción

### Owner

1. **Ahora:**
   - [ ] Leer `README.md` (5 min)
   - [ ] Revisar `000_state_snapshot_checklist.md` (10 min)

2. **Hoy (si es posible):**
   - [ ] Capturar evidencias en `_templates/`
   - [ ] Marcar checkboxes en Issue #50

3. **Mañana:**
   - [ ] Revisar `050_decision_record_styling_vs_preview.md`
   - [ ] Elegir opción (Styling/Preview/Mixto)

### Copilot

- ⏳ **Espera:** Owner aporta evidencias
- 📊 **Cuando lleguen:** Consolidar, analizar, proponer
- 🎯 **Resultado:** Plan detallado de Fase 4

---

## 🎓 Filosofía de Esta Fase

**"Espera activa con documentación defensiva"**

- **Defensiva:** Cada paso está documentado con ejemplos, plantillas y guías de seguridad
- **Sin prisa:** No hay deadline; el owner aporta a su ritmo
- **Transparencia:** Todos los riesgos identificados y opciones evaluadas
- **Seguridad primero:** Nunca exponer secretos; verificar todo antes de cargar credenciales reales

---

## 🔗 Referencias Rápidas

- **Branch:** `feat/fase7-verificacion-accesos-y-estado-real`
- **Issue:** `issues/Issue_50_Fase7_Conexion_WordPress_Real.md`
- **Docs:** `apps/briefing/docs/internal/briefing_system/integrations/wp_real/`
- **Templates:** `apps/briefing/docs/internal/briefing_system/integrations/wp_real/_templates/`

---

**Próxima actualización:** Cuando owner aporte evidencias en `_templates/`

**Status:** 🟡 En espera activa del owner

**Filosofía:** "Sin prisa, con seguridad, documentado defensivamente"

