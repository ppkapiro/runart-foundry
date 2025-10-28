# Parche hero.improve (opcional)

**Estado:** NO aplicado por defecto  
**Objetivo:** Optimizar LCP y CLS del hero si se requiere Performance > 95 o LCP < 1.8s constante  
**Uso:** Activar añadiendo clase `.hero-improve` al `<body>` o contenedor del hero

## Contenido del parche

Ver `hero_improve.css` para:
- Reserva de altura del hero (`aspect-ratio: 16/9` o `min-height` fluida)
- Documentación de preload de imagen principal del hero
- Sugerencias de `font-display: swap` en fuentes

## Cuándo aplicar

- Si Lighthouse Performance < 80 (actualmente 96.5 – 100, no requerido)
- Si LCP > 3.0s (actualmente 1.50 – 2.05s, no requerido)
- Si CLS > 0.10 (actualmente 0.000, no requerido)

## Aplicación

1. Añadir clase `hero-improve` en `front-page.php` o similar:
   ```php
   <body <?php body_class('hero-improve'); ?>>
   ```

2. Opcional: Añadir preload en `<head>`:
   ```html
   <link rel="preload" as="image" href="<?php echo get_template_directory_uri(); ?>/assets/images/hero.jpg">
   ```

3. Verificar en Lighthouse que no hay regresiones en otras métricas.

## Estado actual

✅ Todas las páginas ya pasan los gates sin necesidad de este parche.  
Este parche queda como reserva para optimizaciones futuras si se detectan regresiones o se aumentan los thresholds.
