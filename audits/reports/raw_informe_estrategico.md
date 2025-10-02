# Informe Estratégico – RUN Art Foundry (raw)

## Índice
1. Diagnóstico Resumido
2. Opciones de Decisión
3. Recomendación Inicial
4. Plan de Acción (Fases 4–5)
5. KPIs de Éxito

---
## 1) Diagnóstico Resumido
- **Peso repo/snapshot**: ver tamaños en el Informe Técnico.
- **Imágenes**: volumen alto y sin compresión (ver inventario).
- **SEO**: meta descriptions ausentes; Yoast sin configurar.
- **Accesibilidad**: hallazgos no críticos (axe).
- **Seguridad**: sin webshell evidente; permisos a revisar.
- **GA/GTM/GSC**: no detectados en snapshot.

## 2) Opciones de Decisión
### Opción A: Mantener + Optimizar
- Pros: rápido, menor costo, mejora inmediata.
- Contras: arrastra herencias históricas.
### Opción B: Resetear + Reutilizar contenido
- Pros: limpieza profunda, base nueva estable.
- Contras: requiere migración ordenada (tiempo).
### Opción C: Rehacer desde cero
- Pros: diseño/arquitectura 100% a medida.
- Contras: mayor costo/tiempo, dependencia de contenido.

## 3) Recomendación Inicial
- **Recomiendo A (Mantener + Optimizar)**, en paralelo con un **staging limpio** que nos permita medir el impacto y tener plan B hacia B/ C si hiciera falta.

## 4) Plan de Acción (Fases 4–5)
### Fase 4 – Optimización
1) **Imágenes**: conversión masiva a WebP/AVIF + resize; lazy-load.
2) **SEO**: meta descriptions + sitemap.xml + robots.txt; configurar Yoast.
3) **Performance**: cache (WP Fastest Cache/Optimize), minify CSS/JS.
### Fase 5 – Observabilidad & Hardening
4) **GA4/GTM/GSC**: alta, verificación dominio, envío sitemap.
5) **Seguridad**: actualizar plugins/temas; permisos 755/644; hardening wp-config.
6) **Monitoreo**: logs, uptime, errores 4xx/5xx.

## 5) KPIs de Éxito
- **LCP móvil** < 2.0s; **CLS** < 0.1; **INP** < 200ms.
- **Imágenes (uploads)**: -80% de peso total.
- **SEO**: 100% páginas con meta + sitemap indexado en GSC.
- **Seguridad**: 0 elementos desactualizados; permisos saneados.
