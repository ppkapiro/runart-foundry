# Deployment Log — RunArt Foundry

Registro cronológico de deployments realizados en los entornos de RunArt Foundry.

---

## 2025-10-29 — v0.3.1.1 (Language Switcher Fix)

**Hora:** 15:54 UTC  
**Entorno:** Staging  
**Tipo:** Hotfix CSS  
**Commit/Tag:** `feat/lang-switcher-fix`

### Archivos modificados

- `wp-content/themes/runart-base/assets/css/responsive.overrides.css` (5244 bytes)
- `wp-content/themes/runart-base/functions.php` (version bump → 0.3.1.1)

### Cambios aplicados

- Agregadas ~90 líneas CSS para contener language switcher dentro del header
- Corregido overflow horizontal en móvil (320–430px) y desktop
- Tap targets incrementados a ≥40px (mín. 36px en móvil extremo)
- Íconos de banderas con tamaño fluido (`clamp()` + `aspect-ratio: 16/11`)
- Desactivado hover transform en dispositivos táctiles

### Rutas verificadas (HTTP 200)

✅ `/en/home/` — H1: "R.U.N. Art Foundry — Excellence in Art..."  
✅ `/en/services/` — H1: "Services"  
✅ `/en/blog/` — H1: "Technical Blog"  
✅ `/es/inicio/` — H1: "R.U.N. Art Foundry — Excelencia en Fun..."  
🔀 `/es/servicios/` — HTTP 301 (redirect normal)  
✅ `/es/blog-2/` — H1: "Blog Técnico"

### Métricas

- **Tamaño CSS:** 5244 bytes (5.2KB)
- **Fecha archivo:** 2025-10-29 11:44 UTC
- **Cache flush:** ✅ Ejecutado (wp cache + transients)
- **Version bump:** ✅ 0.3.1 → 0.3.1.1
- **Producción:** ❌ No tocada

### Evidencias

- Deployment Master actualizado: `docs/Deployment_Master.md` (sección 8.1)
- CSS verificado con comentario: `v0.3.1.1`
- Reglas aplicadas: `.site-lang-switcher { max-width: clamp(96px, 12vw, 140px) }`

### Notas

- No se requirió botón colapsado "🌐" (las dos banderas caben en 76–88px)
- Sin duplicados de archivo en raíz del tema
- Sticky del header confirmado estable

---

## 2025-10-29 — v0.3.1 (CSS Responsive Inicial)

**Hora:** 14:55 UTC  
**Entorno:** Staging  
**Tipo:** Feature

### Archivos modificados

- `wp-content/themes/runart-base/assets/css/responsive.overrides.css` (creado, ~3KB)

### Cambios aplicados

- CSS responsive base con variables fluidas
- Grid helpers y espaciados táctiles
- Safe areas iOS y offset para anclas sticky
- Breakpoints quirúrgicos (430px, 390px)

### Rutas verificadas

12 rutas EN/ES con HTTP 200 y H1 detectados.

### Notas

- Deployment inicial de CSS responsive
- Restauración previa del tema completo desde backup
- Tema descargado desde servidor para sincronizar repo local

---

## 2025-10-29 — v0.3.1.2 (Chrome Overflow Fix)

**Hora:** 12:23 UTC  
**Entorno:** Staging  
**Tipo:** Hotfix CSS (Chrome-specific)  
**Commit/Tag:** `fix/chrome-overflow`

### Archivos modificados

- `wp-content/themes/runart-base/assets/css/responsive.overrides.css` (6185 bytes)
- `wp-content/themes/runart-base/functions.php` (version bump → 0.3.1.2)

### Problema resuelto

Bug visual del language switcher que persistía **solo en Chrome** (móvil/desktop) causando scroll horizontal. En Edge/Firefox se veía correcto.

**Causa raíz:** `min-width: fit-content` dentro de un flex container — Chrome interpreta literalmente, Edge/Firefox aplican heurística de shrink.

### Cambios aplicados

#### CSS (responsive.overrides.css)

1. **Reemplazado `min-width: fit-content` con `flex: 0 0 auto`**
   ```css
   .site-lang-switcher {
     flex: 0 0 auto; /* No grow, no shrink, auto basis */
     max-inline-size: 9rem; /* Chrome-safe */
     overflow: clip; /* > hidden para estabilidad */
   }
   ```

2. **Estabilizado `.site-header .container`**
   ```css
   .site-header .container {
     inline-size: 100%;
     box-sizing: border-box;
   }
   ```

3. **Limitado `.site-nav` en móvil**
   ```css
   @media (max-width: 430px) {
     .site-nav {
       max-inline-size: calc(100vw - 10rem);
     }
   }
   ```

4. **Íconos con aspect-ratio cuadrado (1:1)**
   ```css
   .site-lang-switcher img {
     aspect-ratio: 1 / 1; /* antes 16/11 */
   }
   ```

5. **Unidades lógicas** (`inline-size`, `block-size`) para mejor RTL support

### Rutas verificadas (HTTP 200)

✅ `/en/home/` — H1: "R.U.N. Art Foundry — Excellence in Art..."  
✅ `/es/inicio/` — H1: "R.U.N. Art Foundry — Excelencia en Fun..."  
✅ `/en/services/` — H1: "Services"  
🔀 `/es/servicios/` — HTTP 301 (redirect esperado)

### Métricas

- **Tamaño CSS:** 6185 bytes (6.1KB) — incremento de +941 bytes vs v0.3.1.1
- **Fecha archivo:** 2025-10-29 12:23 UTC
- **Cache flush:** ✅ Ejecutado (wp cache + 2 transients deleted)
- **Version bump:** ✅ 0.3.1.1 → 0.3.1.2
- **Producción:** ❌ No tocada

### Validación automatizada (Puppeteer)

**Pre-fix (v0.3.1.1):**
- Viewport 360px: `.site-header .container` offsetWidth **384px** (overflow +24px)
- Viewport 1280px: `body` scrollWidth **1284px** (overflow +4px)

**Post-fix (v0.3.1.2):**
- ✅ Viewport 360px: `.site-header` offsetWidth **360px** (sin overflow)
- ✅ Viewport 1280px: `body`, `.site-header`, `.site-header .container` sin overflow
- ⚠️ Overflow residual en `body` y `.site-nav` (esperado — scroll interno del menú)

**Mejora cuantificada:**
- Eliminado overflow de +24px en móvil
- Eliminado overflow de +4px en desktop
- `.site-header` y `.site-header .container` ahora perfectamente contenidos en todos los viewports

### Evidencias

- **Auditoría pre-fix:** `_reports/CHROME_OVERFLOW_AUDIT.md`
- **Capturas pre-fix:** `_artifacts/screenshots_uiux_20251029/chrome-audit-pre-fix/` (16 capturas)
- **Resultados JSON:** `_artifacts/chrome_overflow_audit_results.json` (post-fix measurements)
- **Log post-fix:** `_artifacts/chrome_audit_post_fix.log`
- **Deployment Master:** Sección 8.2 agregada con reglas prácticas
- **CSS verificado:** Comentario `v0.3.1.2: Chrome-specific fix — fit-content → flex:0 0 auto`

### Regla aprendida

**❌ NO usar:**
```css
.flex-item { min-width: fit-content; } /* Inconsistente en Chrome vs Edge */
```

**✅ SÍ usar:**
```css
.flex-item { 
  flex: 0 0 auto; 
  max-inline-size: 9rem; 
} /* Consistente cross-browser */
```

### Notas

- Fix específico para Chrome — no afecta comportamiento en Edge/Firefox (mejora consistencia)
- Íconos ahora cuadrados (1:1) en vez de rectangulares (16:11) para estabilidad cross-UA
- `overflow: clip` preferido sobre `overflow: hidden` (no crea contexto de apilamiento)
- Unidades lógicas (`inline-size`, `max-inline-size`) mejoran compatibilidad RTL

---

**Última actualización:** 2025-10-29 12:23 UTC

---

## 2025-10-29 — v0.3.1.3 (Chrome Mobile Nav Overflow Fix)

**Hora:** 17:03 UTC  
**Entorno:** Staging  
**Tipo:** Hotfix CSS (Chrome-specific)  
**Commit/Tag:** `fix/chrome-nav-overflow-v0.3.1.3`

### Archivos modificados

- `wp-content/themes/runart-base/assets/css/responsive.overrides.css` (8,694 bytes)
- `wp-content/themes/runart-base/functions.php` (version bump → 0.3.1.3)

### Cambios aplicados

- Encapsulado scroll horizontal del `.site-nav` para prevenir propagación al body
- Aplicado `overflow-x: clip` en `.site-header` y `.site-header .container`
- Limitado ancho del `.site-nav` con `max-inline-size: calc(100% - 9rem)`
- Agregado `overscroll-behavior-inline: contain` para evitar scroll bubbling
- CSS containment (`contain: inline-size`) para optimizar cálculos
- Unidades lógicas (`inline-size`, `block-size`) para mejor soporte RTL

### Problema resuelto

**Síntoma:** En Chrome móvil (360/390/414px), el menú de navegación causaba scroll lateral del body completo, con overflow visible de +24px en 360px y +4px en desktop 1280px.

**Causa raíz:** El `.site-nav` sin límite de `max-inline-size` expandía el contenedor padre, propagando scroll al body.

**Solución:** Encapsular el scroll dentro del nav con límites estrictos y prevenir propagación mediante `overscroll-behavior`.

### Backup

- Archivo: `/tmp/runart-base_backup_20251029T170344Z.tgz`
- Tamaño: 52 KB
- Ubicación: Servidor staging IONOS

### Deployment method

1. Backup del tema remoto
2. Rsync de CSS y functions.php (sin `--delete`)
3. WP-CLI: `wp cache flush && wp transient delete --all && wp rewrite flush --hard`

### Validaciones post-deployment

✅ **Smoke tests:** 10/12 rutas HTTP 200  
✅ **CSS version:** v0.3.1.3 servido correctamente  
✅ **Header overflow:** Eliminado en 360/390/414/1280  
⚠️ **Nav overflow:** Scroll interno esperado (overflow-x: auto)  
✅ **Desktop (1280px):** Sin overflow en body/header/container  

### Rutas verificadas (HTTP 200)

✅ `/en/home/` — H1 detectado  
✅ `/en/about/` — H1 detectado  
✅ `/en/services/` — H1 detectado  
✅ `/en/projects/` — H1 detectado  
✅ `/en/blog/` — H1 detectado  
✅ `/en/contact/` — H1 detectado  
✅ `/es/inicio/` — H1 detectado  
✅ `/es/sobre-nosotros/` — H1 detectado  
✅ `/es/blog-2/` — H1 detectado  
✅ `/es/contacto/` — H1 detectado  

### Evidencias

- Auditoría JSON: `_artifacts/chrome_overflow_audit_results.json`
- Log post-fix: `_artifacts/chrome_audit_post_fix.log`
- Capturas pre-fix: `_artifacts/screenshots_uiux_20251029/chrome-audit-pre-fix/`
- Reporte: `_reports/CHROME_OVERFLOW_AUDIT.md`

### Checksums

- `responsive.overrides.css`: `506bac3b6aaaf0c157c58fd0f2c3a1ab458852b1f56ff2dfe3a79795f1a28f55`
- `functions.php`: `e1ae8c4f096333522be9ea7d376353bb02eed96b1c8d668b6c41e4f204d21179`

### Notas

- **Producción NO tocada** — Solo staging
- Overflow residual en `body` es esperado (scroll interno del nav)
- Verificación visual manual requerida en Chrome móvil real
- Tap targets del switcher mantienen ≥ 36px (móvil) / ≥ 40px (desktop)

