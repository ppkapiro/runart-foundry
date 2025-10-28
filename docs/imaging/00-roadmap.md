# Fase 2: Sistema de Gestión de Imágenes

**Estado:** Inicialización (NO IMPLEMENTAR aún)  
**Fecha creación:** 2025-10-28  
**Versión base:** v0.3.1-responsive-final (commit 05ba65e)

---

## 1. Objetivos

### Funcionales
- Centralizar gestión de imágenes del sitio (WordPress + Cloudflare Pages)
- Soporte bilingüe (alt_es, alt_en, longdesc opcional)
- Responsive con `<picture>` + srcset/sizes
- Lazy loading nativo (`loading="lazy"`)
- WebP/AVIF modernos con fallback JPEG/PNG

### No Funcionales
- Lighthouse Performance: mantener ≥95 móvil/desktop
- Lighthouse Accessibility: ≥93 (alt correctos, contraste imágenes decorativas)
- LCP objetivo: ≤2.0s (hero con priority fetch)
- Bundle size: +200KB máximo (imágenes críticas)

---

## 2. Alcance

### Incluido
- Manifest JSON/TS con metadata (id, path, w, h, alt_es, alt_en, copyright)
- Helper PHP `runart_picture()` para `<picture>` tag con srcset
- Hook/filter `runart_lazy_image` con lazy loading defaults
- Directorio `assets/img/` con estructura por módulo/idioma
- Script de validación: alt no vacíos, dimensiones correctas, formatos soportados

### Excluido (futuro)
- Optimización automática (Cloudflare Polish/Image Resizing)
- CDN local de imágenes (usar IONOS/Cloudflare)
- Galería dinámica (post MVP)
- Asset pipeline avanzado (minificación en CI/CD)

---

## 3. Estructura Propuesta

```
wp-content/themes/runart-base/
  assets/
    img/
      hero/
        hero-home-1200x600.webp
        hero-home-1200x600.jpg
        hero-about-1200x600.webp
        hero-about-1200x600.jpg
      icons/
        logo-runart.svg
        icon-menu.svg
      team/
        photo-john-doe-400x400.webp
        photo-john-doe-400x400.jpg
    assets.json (o assets.ts)
  inc/
    helpers/
      images.php (runart_picture, runart_lazy_image)
```

### Ejemplo `assets.json`
```json
{
  "version": "1.0.0",
  "images": [
    {
      "id": "hero-home",
      "path": "assets/img/hero/hero-home-1200x600",
      "formats": ["webp", "jpg"],
      "width": 1200,
      "height": 600,
      "alt_es": "Portada principal de RunArt Foundry",
      "alt_en": "RunArt Foundry main hero image",
      "copyright": "© RunArt Foundry 2025"
    }
  ]
}
```

---

## 4. Decisiones de Diseño

### A confirmar
- [ ] Manifest en JSON vs. TypeScript (PHP puede leer JSON, TS necesita build)
- [ ] Directorio `assets/img/` vs. `assets/images/` (convención WordPress)
- [ ] Helper `runart_picture()` vs. shortcode `[runart_img id="hero-home"]`
- [ ] Lazy loading: `loading="lazy"` nativo vs. IntersectionObserver custom
- [ ] Formato prioritario: WebP (soporte 95%+) vs. AVIF (mejor compresión, menor soporte)

### Recomendaciones iniciales
- **Manifest JSON** (más simple, menos tooling)
- **`assets/img/`** (consistente con `assets/css/`, `assets/js/`)
- **Helper PHP** (más flexible que shortcode, permite override en templates)
- **`loading="lazy"` nativo** (menor complejidad, bien soportado)
- **WebP prioritario** con fallback JPEG (balance compresión/soporte)

---

## 5. Criterios de Éxito

### Funcionales
- [ ] Todas las imágenes críticas (hero, logos) tienen alt bilingües no vacíos
- [ ] `<picture>` tags generados con srcset 1x, 2x, 3x para retina
- [ ] Lazy loading activo en imágenes below-the-fold (≥3 por página)
- [ ] Formatos WebP servidos a navegadores compatibles, fallback JPEG/PNG

### Lighthouse
- [ ] Performance Score ≥95 móvil/desktop (mantener o mejorar v0.3.1)
- [ ] Accessibility Score ≥93 (mantener v0.3.1)
- [ ] Best Practices ≥93 (mantener v0.3.1)
- [ ] LCP ≤2.0s en hero pages (home, about, services)

### Calidad de Código
- [ ] Script de validación pasa 100% (no alt vacíos, dimensiones correctas)
- [ ] Helper `runart_picture()` con tests unitarios (PHPUnit básico)
- [ ] Documentación inline en `images.php` (PHPDoc)

---

## 6. Plan de Implementación (NO EJECUTAR AÚN)

### Fase 2.1: Estructura base
1. Crear `assets/img/` con subdirectorios (hero, icons, team)
2. Crear `assets/assets.json` con schema inicial
3. Crear `inc/helpers/images.php` con stubs (funciones vacías)

### Fase 2.2: Helpers PHP
1. Implementar `runart_picture( $img_id, $sizes = '100vw', $class = '', $attrs = [] )`
2. Implementar `runart_lazy_image( $img_id, $threshold = 200 )`
3. Tests básicos con PHPUnit (mock assets.json)

### Fase 2.3: Integración templates
1. Reemplazar `<img>` hardcoded en `header.php` (logo)
2. Reemplazar hero en `front-page.php` con `runart_picture('hero-home')`
3. Smoke test: verificar `<picture>` renderizado con srcset

### Fase 2.4: Validación
1. Script bash `tools/validate_images.sh`: verificar alt no vacíos, formatos existentes
2. Lighthouse CI: verificar Performance/Accessibility mantienen ≥95/93
3. Update CHANGELOG con métricas Lighthouse post-imaging

---

## 7. Dependencias

### Bloqueantes
- v0.3.1-responsive-final merge completo (✅ done: commit 05ba65e)
- Staging deployment de v0.3.1 para baseline (⏳ pending: manual)
- Lighthouse audit post-deployment (⏳ pending: smoke tests)

### Opcionales
- Cloudflare Image Resizing (futuro optimization)
- WordPress plugin de optimización (e.g., Smush, EWWW) — evaluar post-MVP

---

## 8. Riesgos

| Riesgo | Impacto | Mitigación |
|--------|---------|------------|
| Degradación Performance (LCP +500ms) | Alto | Usar `fetchpriority="high"` en hero, lazy load resto |
| Alt texts incompletos (Accessibility penalty) | Medio | Script validación obligatorio en pre-commit |
| Formato WebP no soportado (navegadores legacy) | Bajo | Fallback JPEG/PNG en `<source>` tags |
| Directorio `assets/img/` demasiado grande (>5MB) | Bajo | Limit 200KB por imagen, comprimir con tinypng.com |

---

## 9. Referencias

- [MDN: Responsive Images](https://developer.mozilla.org/en-US/docs/Learn/HTML/Multimedia_and_embedding/Responsive_images)
- [WordPress: The Picture Element](https://make.wordpress.org/core/2023/07/13/responsive-images-in-wordpress-6-3/)
- [Web.dev: Optimize Cumulative Layout Shift](https://web.dev/optimize-cls/)
- [Lighthouse: Image best practices](https://developers.google.com/web/tools/lighthouse/audits/images)

---

## 10. Próximos Pasos (post-deployment v0.3.1)

1. Reunión de kick-off Fase 2 (stakeholders: dev, UX, content)
2. Definir inventario de imágenes prioritarias (hero, logos, team photos)
3. Crear assets.json con metadata bilingüe (requiere input de content team)
4. Implementar `runart_picture()` helper (dev sprint 1 semana)
5. Integrar en 3 templates críticos (home, about, services)
6. Lighthouse CI + smoke tests (validación pre-merge)
7. Merge feat/imaging-pipeline → develop → main (fast-forward preferido)
8. Deploy a staging, re-audit Lighthouse, documentar en CHANGELOG

---

**FIN ROADMAP**  
**Rama:** feat/imaging-pipeline  
**Estado:** Estructura inicializada, NO implementada  
**Merge:** NO mergear hasta completar deployment v0.3.1 + kick-off aprobado
