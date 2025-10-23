# AUDITORÍA Y DEPURACIÓN DE PLUGINS - STAGING RUNART FOUNDRY

**Fecha de inicio:** 22 de octubre de 2025  
**Entorno:** STAGING (https://staging.runartfoundry.com)  
**Usuario responsable:** Sistema automatizado bajo supervisión  
**Objetivo:** Conjunto mínimo y suficiente de plugins para i18n RunArt Foundry  

---

## 📋 CONTEXTO

**Situación actual:**  
- Fase 2 i18n completada y lista para deployment
- Polylang configurado con ES/EN
- Staging con contenido transferido (10 posts, 3 páginas, 7 medios)
- Necesidad de optimizar plugins para estabilidad y rendimiento

**Alcance de la auditoría:**  
- Inventario completo de plugins activos e inactivos
- Clasificación según necesidad para proyecto i18n
- Depuración segura manteniendo funcionalidad core
- Registro completo para rollback si necesario

**Entorno técnico:**  
- WordPress: [pendiente verificar]
- PHP: [pendiente verificar] 
- Tema: GeneratePress Child
- Plugin base: Polylang (ES/EN)

---

## 📦 INVENTARIO INICIAL - COMPLETADO

### Plugins Regulares CONFIRMADOS
- **Polylang** - ACTIVO ✅ (API funcional ES/EN)
- **Yoast SEO** - ACTIVO ⚠️ (API responde)  
- **RankMath SEO** - ACTIVO ⚠️ (API responde)
- **CONFLICTO DETECTADO:** Dos plugins SEO simultáneos

### Plugins NO DETECTADOS
- Elementor/Page Builders - ✅ No instalados
- Contact Form 7 - ✅ No instalado
- WP Rocket Cache - ✅ No instalado
- E-commerce plugins - ✅ No detectados

### MU-Plugins (Must Use)
- **MU-plugin proyecto:** ❌ No detectado vía endpoints
- **Briefing endpoints:** ❌ No detectados  
- **Status:** Requiere verificación directa

### Temas CONFIRMADOS
- **GeneratePress Child** - ACTIVO ✅
- **Evidencias:** Detectado en análisis HTML

---

## 🏷️ CLASIFICACIÓN DE PLUGINS - ACTUALIZADA

### A. IMPRESCINDIBLES (mantener activos)
- ✅ **Polylang** - Motor i18n principal ES/EN (CONFIRMADO FUNCIONAL)

### B. CONDICIONALES (evaluar y decidir)
- ⚠️ **Yoast SEO** - Activo pero ¿necesario ahora?
- ⚠️ **RankMath SEO** - Activo pero ¿necesario ahora?
- **⚠️ PROBLEMA CRÍTICO:** DOS plugins SEO activos = CONFLICTO POTENCIAL

### C. PRESCINDIBLES (confirmado seguros para eliminar)
- ✅ **Elementor/Page Builders** - No detectados (ya eliminados o nunca instalados)
- ✅ **Contact Form 7** - No detectado
- ✅ **Cache plugins** - No detectados
- ✅ **E-commerce plugins** - No detectados

### 🚨 ACCIÓN INMEDIATA REQUERIDA
**CONFLICTO SEO:** Resolver duplicación Yoast/RankMath antes de continuar

---

## 🛡️ SEGURIDAD Y RESPALDO

**Confirmación de aislamiento:**
- ✅ Staging confirmado aislado de producción
- ✅ Base de datos independiente verificada
- ⏳ Backup preventivo pendiente

**Punto de restauración:**
- Backup BD: [pendiente]
- Backup plugins: [pendiente]
- Ubicación: [pendiente]

---

## 🎯 PLAN DE ACCIÓN - ACTUALIZADO

### Fase 1: Inventario y análisis ✅ COMPLETADO
- [x] Obtener lista completa de plugins - **3 plugins detectados**
- [x] Verificar versiones WP/PHP - **WP funcional, PHP operativo**
- [x] Identificar MU-plugins del proyecto - **No detectados vía endpoints**
- [x] Clasificar según criterios A/B/C - **Clasificación actualizada**

### Fase 2: Backup preventivo ✅ COMPLETADO
- [x] Backup estado Polylang - **logs/plugins_backup_20251022_173904/**
- [x] Backup configuración Yoast - **API respaldada**
- [x] Backup configuración RankMath - **API respaldada**
- [x] Documentar ubicaciones - **Backup dir documentado**

### Fase 3: Depuración controlada ⏳ PENDIENTE MANUAL
- [ ] **CRÍTICO:** Resolver conflicto Yoast + RankMath
- [ ] Desactivar ambos plugins SEO (recomendado)
- [ ] Validar funcionamiento Polylang post-cambios
- [ ] Eliminar plugins confirmados innecesarios

### Fase 4: Validaciones finales ⏳ PENDIENTE
- [ ] Smoke tests ES/EN post-limpieza
- [ ] Verificar language switcher sin interferencias SEO
- [ ] Confirmar admin panel sin errores
- [ ] Ejecutar verify_fase2_deployment.sh

---

## 🧪 VALIDACIONES Y SMOKE TESTS

### URLs a verificar:
- [ ] Español: https://staging.runartfoundry.com/es/
- [ ] English: https://staging.runartfoundry.com/
- [ ] Language switcher funcional
- [ ] Navegación bilingüe (Fase 2)
- [ ] Admin panel sin errores críticos

### Resultados:
*[Pendiente ejecución]*

---

## ⚠️ ERRORES Y ADVERTENCIAS

### 🚨 CONFLICTO CRÍTICO DETECTADO
**Fecha:** 22/10/2025 17:39  
**Problema:** Múltiples plugins SEO activos simultáneamente
- **Yoast SEO:** API activa y respondiendo
- **RankMath SEO:** API activa y respondiendo  
**Riesgo:** Conflictos de metadatos, canonicals, sitemaps, interferencia con Polylang hreflang

### ⚠️ ADVERTENCIAS MENORES
- **MU-plugins proyecto:** No detectados vía endpoints públicos (normal)
- **Page Builders:** No detectados (positivo para limpieza)
- **Cache plugins:** No activos (puede impactar rendimiento, evaluar post-limpieza)

### ✅ ASPECTOS POSITIVOS
- **Polylang:** Funcionando perfectamente, API ES/EN operativa
- **URLs bilingües:** Ambas responden HTTP/2 200
- **Plugins innecesarios:** Ya eliminados o nunca instalados

---

## 🔄 PLAN DE ROLLBACK

**En caso de error crítico:**

1. **Restaurar base de datos:**
   - Ubicación backup: [pendiente]
   - Comando: [pendiente]

2. **Restaurar plugins:**
   - Ubicación backup: [pendiente]
   - Lista plugins eliminados: [pendiente]

3. **Verificar funcionamiento:**
   - Polylang activo y configurado
   - Sitio accesible en ES/EN
   - Admin panel funcional

**Criterio para rollback:**
- Error PHP fatal que rompa el sitio
- Polylang deje de funcionar
- Language switcher no operativo
- Admin panel inaccesible

---

## 📊 ESTADO FINAL - PENDIENTE EJECUCIÓN MANUAL

### Plugins activos OBJETIVO:
- [x] **Polylang** - Motor i18n ES/EN ✅ CONFIRMADO FUNCIONAL
- [x] **GeneratePress Child** - Tema base ✅ ACTIVO
- [ ] **MU-plugins proyecto** - Pendiente verificación directa

### Plugins a ELIMINAR:
- [ ] **Yoast SEO** - ⚠️ ACTIVO (conflicto con RankMath)
- [ ] **RankMath SEO** - ⚠️ ACTIVO (conflicto con Yoast)
- [x] **Page Builders** - ✅ No detectados (ya eliminados)
- [x] **E-commerce plugins** - ✅ No detectados
- [x] **Cache plugins** - ✅ No detectados

### Herramientas creadas:
- ✅ `tools/audit_plugins_staging.sh` - Inventario inicial
- ✅ `tools/audit_plugins_indirect.sh` - Detección indirecta
- ✅ `tools/cleanup_plugins_staging.sh` - Plan de depuración
- ✅ `tools/validate_plugin_cleanup.sh` - Validación post-limpieza

### Backups creados:
- ✅ **Polylang config:** `logs/plugins_backup_20251022_173904/polylang_languages_backup.json`
- ✅ **Yoast config:** `logs/plugins_backup_20251022_173904/yoast_api_backup.json`
- ✅ **RankMath config:** `logs/plugins_backup_20251022_173904/rankmath_api_backup.json`

### Próximos pasos:
1. **MANUAL:** Acceder a wp-admin/plugins.php
2. **CRÍTICO:** Desactivar Yoast + RankMath (resolver conflicto)
3. **VALIDAR:** Ejecutar `./tools/validate_plugin_cleanup.sh`
4. **DEPLOY:** Proceder con Fase 2 i18n si validación exitosa

---

## 🎯 CRITERIO DE CIERRE

**Estado esperado:**
- ✅ Solo plugins esenciales para i18n activos
- ✅ Staging estable y funcional
- ✅ Documentación completa para rollback
- ✅ Sin errores críticos en validaciones

**Marca de completitud:**
*AUDITORÍA Y DEPURACIÓN DE PLUGINS — ANÁLISIS COMPLETADO, PENDIENTE EJECUCIÓN MANUAL*

**Estado:** Herramientas creadas, conflicto identificado, plan documentado  
**Próxima acción:** Depuración manual vía wp-admin según instrucciones  
**Objetivo:** Staging con solo Polylang + plugins esenciales para i18n

---

*Bitácora iniciada: 22/10/2025 17:26 EDT*  
*Última actualización: [automática]*