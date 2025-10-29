# Informe de Brechas Bilingües — RunArt Foundry

**Fecha:** 2025-10-29  
**Idiomas:** ES (español, base) | EN (inglés, traducción)  
**Modo:** READ_ONLY=1

---

## Objetivo

Identificar y documentar gaps de traducción entre versiones español e inglés para:
- Detectar páginas sin traducción completa
- Validar coherencia de mensajes entre idiomas
- Priorizar trabajo de traducción pendiente
- Asegurar experiencia consistente ES/EN

**Target:** 100% contenido disponible en ambos idiomas

---

## Páginas con Gaps

### Solo ES (Falta traducción EN)

| Página | Slug ES | Palabras ES | Status | Prioridad | Estimación (horas) |
|--------|---------|-------------|--------|-----------|-------------------|
| *Por identificar* | - | - | ❌ Sin EN | Alta/Media/Baja | - |

**Criterios de prioridad:**
- **Alta:** Páginas principales (Home, About, Services, Contact)
- **Media:** Blog posts, portafolio
- **Baja:** Páginas legacy, FAQ, documentación interna

### Solo EN (Falta versión ES)

| Página | Slug EN | Palabras EN | Status | Prioridad | Estimación (horas) |
|--------|---------|-------------|--------|-----------|-------------------|
| *Por identificar* | - | - | ❌ Sin ES | Alta/Media/Baja | - |

**Nota:** Esta situación es menos común (ES es base), pero puede ocurrir en contenido traducido-primero.

---

## Traducciones Parciales

| Página | Palabras ES | Palabras EN | % Completitud EN | Gap (palabras) | Prioridad |
|--------|-------------|-------------|------------------|----------------|-----------|
| *Por identificar* | - | - | - | - | Alta/Media/Baja |

**Escala de completitud:**
- ✅ 90-100%: Traducción completa (OK)
- ⚠️ 70-89%: Traducción parcial (revisar)
- ❌ <70%: Traducción incompleta (urgente)

---

## Desalineaciones de Contenido

| Página | Problema | Descripción | Impacto | Acción Requerida |
|--------|----------|-------------|---------|------------------|
| *Por identificar* | Párrafos faltantes | ES tiene sección X, EN no | Alto/Medio/Bajo | Traducir sección X |
| *Por identificar* | Orden diferente | Secciones en orden distinto ES vs EN | Medio | Reestructurar EN |
| *Por identificar* | Mensaje diferente | Tono/enfoque divergente | Alto | Revisar y alinear |

---

## Imágenes con Texto Hardcoded

### Imágenes Solo en Español (Sin versión EN)

| Imagen | Texto ES | Página | Tipo | Prioridad | Acción |
|----------|----------|---------|------|-----------|--------|
| *Por identificar* | "Bienvenidos" | Home | Banner | Alta | Recrear bilingüe o usar texto overlay |

### Imágenes Solo en Inglés (Sin versión ES)

| Imagen | Texto EN | Página | Tipo | Prioridad | Acción |
|----------|----------|---------|------|-----------|--------|
| *Por identificar* | "Welcome" | Home | Banner | Alta | Recrear bilingüe o usar texto overlay |

**Alternativas:**
1. **Recrear imagen:** Versión ES y versión EN separadas
2. **Texto overlay:** Usar CSS text overlay (traducible dinámicamente)
3. **SVG:** Texto en SVG (más fácil de editar/traducir)

---

## Elementos de UI Sin Traducción

### Menús

| Menu | Elemento | ES | EN | Status |
|------|----------|----|----|--------|
| Main Navigation | "Inicio" | ✅ | ❌ "Inicio" (sin traducir) | ⚠️ Traducir a "Home" |
| *Por identificar* | - | - | - | - |

### Widgets

| Widget | Contenido ES | Contenido EN | Status |
|--------|--------------|--------------|--------|
| Footer | "Síguenos en redes" | ❌ "Síguenos en redes" | ⚠️ Traducir a "Follow us" |
| *Por identificar* | - | - | - |

### Formularios

| Formulario | Campo | Label ES | Label EN | Placeholder ES | Placeholder EN | Status |
|------------|-------|----------|----------|----------------|----------------|--------|
| Contact | Nombre | "Nombre" | ❌ "Nombre" | "Tu nombre" | ❌ "Tu nombre" | ⚠️ Traducir |
| *Por identificar* | - | - | - | - | - | - |

---

## Metadata y SEO

| Página | Meta Title ES | Meta Title EN | Meta Description ES | Meta Description EN | Status |
|--------|---------------|---------------|---------------------|---------------------|--------|
| Home | "RunArt Foundry - Inicio" | ❌ Falta | "Descripción ES..." | ❌ Falta | ⚠️ Añadir EN |
| *Por identificar* | - | - | - | - | - |

---

## Comandos Utilizados

```bash
# Listar páginas por idioma
wp post list --post_type=page --lang=es --format=csv --fields=ID,post_title,post_content
wp post list --post_type=page --lang=en --format=csv --fields=ID,post_title,post_content

# Comparar páginas ES vs EN (IDs)
comm -3 <(wp post list --lang=es --format=ids | tr ' ' '\n' | sort) \
        <(wp post list --lang=en --format=ids | tr ' ' '\n' | sort)

# Contar palabras por idioma
wp post get <ID> --lang=es --field=post_content | wc -w
wp post get <ID> --lang=en --field=post_content | wc -w

# Calcular % completitud
echo "scale=1; (480/500)*100" | bc  # Ejemplo: 480 palabras EN / 500 palabras ES = 96%
```

---

## Análisis de Coincidencia

### Escala de Coincidencia Textual

**Método:** Comparar longitud (palabras) ES vs EN como proxy de completitud.

| Rango | Interpretación | Acción |
|-------|---------------|--------|
| 90-110% | ✅ Traducción completa y equivalente | OK, solo review de calidad |
| 70-89% o 111-130% | ⚠️ Discrepancia aceptable | Revisar párrafos faltantes/extras |
| <70% o >130% | ❌ Discrepancia significativa | Revisar completitud y alineación |

**Nota:** Diferencias naturales entre idiomas pueden causar variación ±20% sin ser problema.

---

## Resumen Estadístico

**Actualización:** Se completará durante la auditoría

- **Total páginas:** 0
- **Páginas bilingües completas (ES+EN):** 0 (0%)
- **Solo ES (sin EN):** 0 (0%)
- **Solo EN (sin ES):** 0 (0%)
- **Traducciones parciales (<90%):** 0 (0%)
- **Imágenes con texto hardcoded:** 0
- **Elementos UI sin traducir:** 0

---

## Objetivos de Completitud

### Páginas Críticas (Target: 100% bilingüe)
- [ ] Home
- [ ] About / Acerca de
- [ ] Services / Servicios
- [ ] Contact / Contacto
- [ ] Portfolio / Portafolio (overview)

### Páginas Secundarias (Target: 90% bilingüe)
- [ ] Blog posts (últimos 10)
- [ ] Portfolio items (últimos 5)
- [ ] FAQ / Preguntas Frecuentes

### Elementos UI (Target: 100% bilingüe)
- [ ] Main navigation
- [ ] Footer
- [ ] Widgets
- [ ] Formularios
- [ ] Botones (CTAs)

---

## Plan de Traducción

### Fase 1: Crítico (1-2 semanas)
1. **Páginas principales sin EN:** Traducir 100%
2. **Imágenes con texto hardcoded críticas:** Recrear bilingües
3. **Menús y UI principal:** Traducir elementos faltantes

### Fase 2: Importante (2-3 semanas)
4. **Traducciones parciales:** Completar a 95%+
5. **Blog posts recientes:** Traducir últimos 10
6. **Meta descriptions:** Añadir versiones EN faltantes

### Fase 3: Complementario (1 mes)
7. **Contenido legacy:** Evaluar si traducir o deprecar
8. **Widgets secundarios:** Traducir todos
9. **Formularios avanzados:** Traducir placeholders y validaciones

---

## Recursos Necesarios

### Traducción Profesional
- **Páginas principales:** ~5,000 palabras (estimado)
- **Tarifa:** $0.10-0.15 USD/palabra
- **Costo estimado:** $500-750 USD
- **Tiempo:** 1-2 semanas

### Recreación de Imágenes
- **Imágenes con texto:** ~10 archivos (estimado)
- **Tarifa:** $50-100 USD/imagen
- **Costo estimado:** $500-1,000 USD
- **Tiempo:** 1 semana

### Implementación Técnica
- **Developer:** Implementar textos traducidos en templates
- **Tiempo estimado:** 20-30 horas
- **Costo:** Variable según tarifa

---

## Criterios de Calidad

### Traducción
- ✅ Equivalencia de mensaje (no literal, sino conceptual)
- ✅ Tono consistente con brand voice
- ✅ Términos técnicos correctos
- ✅ Localización cultural (no solo traducción)

### Completitud
- ✅ Mismo número de secciones ES vs EN
- ✅ Imágenes traducidas o neutras
- ✅ UI completamente bilingüe
- ✅ Meta tags y SEO bilingües

---

## Notas de Auditoría

- ✅ Español como idioma base
- ✅ Target: 100% contenido bilingüe ES/EN
- ⏳ Análisis en progreso
- 📝 Priorizar páginas críticas (Home, About, Services, Contact)

---

**Última actualización:** 2025-10-29  
**Dependencias:** 01_pages_inventory.md  
**Estado:** ✅ PLANTILLA LISTA — Iniciar análisis bilingüe tras inventario de páginas
