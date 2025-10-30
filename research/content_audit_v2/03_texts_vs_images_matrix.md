# Matriz Texto ↔ Imagen — RunArt Foundry

**Fecha:** 2025-10-29  
**Propósito:** Correlacionar contenido textual con imágenes asociadas  
**Modo:** READ_ONLY=1

---

## Objetivo

Analizar el balance entre texto e imágenes en cada página para:
- Identificar páginas con exceso de texto (necesitan más imágenes)
- Identificar páginas con exceso de imágenes (necesitan más contexto)
- Validar coherencia entre mensaje textual y visual
- Optimizar experiencia de lectura (ratio palabras/imagen)

**Ratio ideal:** 50-200 palabras por imagen

---

## Matriz por Página

| Página | Texto ES (palabras) | Texto EN (palabras) | Imágenes | Ratio ES | Ratio EN | Estado | Observaciones |
|---------|---------------------|---------------------|----------|----------|----------|--------|---------------|
| Home | *Por medir* | *Por medir* | 0 | - | - | ⏳ Pending | Ejemplo inicial |
| *Añadir durante auditoría* | - | - | - | - | - | - | - |

---

## Páginas con Desbalance

### Exceso de Texto (>200 palabras por imagen)

| Página | Palabras ES | Palabras EN | Imágenes | Ratio | Recomendación |
|---------|-------------|-------------|----------|-------|---------------|
| *Por identificar* | - | - | - | >200:1 | Añadir N imágenes |

**Criterios:**
- Ratio >200:1 → Añadir imágenes ilustrativas
- Ratio >500:1 → Urgente (página muy densa)

### Exceso de Imágenes (>10 imágenes, <500 palabras)

| Página | Palabras ES | Palabras EN | Imágenes | Ratio | Recomendación |
|---------|-------------|-------------|----------|-------|---------------|
| *Por identificar* | - | - | - | <50:1 | Expandir texto o reducir imágenes |

**Criterios:**
- Ratio <50:1 → Añadir contexto textual
- Ratio <20:1 → Urgente (demasiado visual, poco informativo)

---

## Páginas sin Imágenes

| Página | Palabras ES | Palabras EN | Prioridad | Tipo de Imagen Sugerida |
|---------|-------------|-------------|-----------|-------------------------|
| *Por identificar* | - | - | Alta/Media/Baja | Hero image, iconos, ilustraciones |

---

## Imágenes sin Contexto Textual

| Imagen | Página | Contexto Actual | Problema | Recomendación |
|----------|---------|-----------------|----------|---------------|
| *Por identificar* | - | Solo visual, sin caption | Falta descripción | Añadir caption o párrafo explicativo |

---

## Análisis de Coherencia Texto-Imagen

| Página | Mensaje Textual | Mensaje Visual | Coherencia | Notas |
|---------|----------------|----------------|------------|-------|
| Home | "Innovación y creatividad" | Imágenes abstractas | ✅ Coherente | - |
| *Añadir durante auditoría* | - | - | ✅/⚠️/❌ | - |

**Escala:**
- ✅ Coherente: Texto e imagen refuerzan el mismo mensaje
- ⚠️ Parcial: Relación débil o genérica
- ❌ Incoherente: Mensaje visual contradice o no apoya el texto

---

## Comandos Utilizados

```bash
# Contar palabras en página (ES)
wp post get <ID> --field=post_content | wc -w

# Contar imágenes en content
wp post get <ID> --field=post_content | grep -o '<img' | wc -l

# Calcular ratio (ejemplo: 800 palabras / 4 imágenes = 200:1)
echo "scale=1; 800/4" | bc

# Extraer alt text de imágenes
wp post get <ID> --field=post_content | grep -oP 'alt="[^"]*"'
```

---

## Resumen Estadístico

**Actualización:** Se completará durante la auditoría

- **Total páginas analizadas:** 0
- **Ratio promedio:** 0 palabras/imagen
- **Páginas balanceadas (50-200:1):** 0 (0%)
- **Exceso texto (>200:1):** 0 (0%)
- **Exceso imágenes (<50:1):** 0 (0%)
- **Sin imágenes:** 0 (0%)

---

## Objetivos de Balance

### Páginas Principales (Home, About, Services)
- **Target ratio:** 80-150 palabras por imagen
- **Mínimo imágenes:** 3-5 por página
- **Coherencia:** 100% páginas ✅ coherentes

### Páginas de Blog
- **Target ratio:** 100-200 palabras por imagen
- **Mínimo imágenes:** 1-2 por post (featured + en-text)

### Páginas de Portafolio
- **Target ratio:** 50-100 palabras por imagen (más visual)
- **Mínimo imágenes:** 5-10 por proyecto

---

## Recomendaciones de Optimización

### Para Páginas con Exceso de Texto
1. **Dividir en secciones:** Insertar imágenes cada 200-300 palabras
2. **Tipos de imagen a añadir:**
   - Iconos ilustrativos (conceptos abstractos)
   - Screenshots (ejemplos prácticos)
   - Diagramas (procesos, flujos)
   - Fotos (personas, productos, espacios)

### Para Páginas con Exceso de Imágenes
1. **Añadir contexto:** Caption o párrafo explicativo para cada imagen
2. **Consolidar:** Agrupar imágenes similares en galería
3. **Eliminar:** Imágenes decorativas sin valor informativo

### Para Mejorar Coherencia
1. **Review editorial:** Validar que cada imagen apoye el mensaje
2. **Alt text descriptivo:** Reforzar relación texto-imagen
3. **Captions:** Explicitar conexión cuando no sea obvia

---

## Ejemplos de Buenas Prácticas

### Ejemplo 1: Página "About"
- **Texto:** 600 palabras (historia, misión, equipo)
- **Imágenes:** 4 (logo, foto equipo, oficina, valores)
- **Ratio:** 150:1 ✅
- **Coherencia:** ✅ Cada imagen ilustra una sección específica

### Ejemplo 2: Blog Post
- **Texto:** 800 palabras
- **Imágenes:** 5 (featured + 4 en-text)
- **Ratio:** 160:1 ✅
- **Coherencia:** ✅ Imágenes en puntos clave del artículo

---

## Notas de Auditoría

- ✅ Ratio ideal: 50-200 palabras/imagen
- ✅ Priorizar páginas principales
- ⏳ Análisis en progreso
- 📝 Actualizar matriz tras completar inventarios de páginas e imágenes

---

**Última actualización:** 2025-10-29  
**Dependencias:** 01_pages_inventory.md, 02_images_inventory.md  
**Estado:** ✅ PLANTILLA LISTA — Iniciar análisis tras inventarios base
