# Inventario de Imágenes — RunArt Foundry

**Fecha:** 2025-10-29  
**Directorio base:** `/content/media/library/` (y `wp-content/uploads/`)  
**Theme assets:** `runart-base/assets/images/`  
**Modo:** READ_ONLY=1

---

## Propósito

Listar y analizar todos los activos visuales del sitio para:
- Identificar imágenes sin uso (eliminar)
- Detectar imágenes >1MB (optimizar)
- Validar presencia de alt text (accesibilidad)
- Clasificar por ubicación y propósito
- Evaluar formatos (migración a WebP)

---

## Media Library (wp-content/uploads/)

| Archivo | Tipo | Dimensiones | Tamaño | Uso (página/sección) | Alt Text | Licencia/Origen | Notas |
|----------|------|--------------|---------|----------------------|----------|-----------------|-------|
| *Por identificar* | - | - | - | - | - | - | *Iniciar con WP-CLI* |

---

## Theme Assets (runart-base/assets/images/)

### Iconos
| Archivo | Dimensiones | Tamaño | Uso | Notas |
|----------|-------------|---------|-----|-------|
| *Por identificar* | - | - | - | - |

### Backgrounds
| Archivo | Dimensiones | Tamaño | Uso | Notas |
|----------|-------------|---------|-----|-------|
| *Por identificar* | - | - | - | - |

### Logos
| Archivo | Dimensiones | Tamaño | Uso | Notas |
|----------|-------------|---------|-----|-------|
| *Por identificar* | - | - | - | - |

---

## Análisis por Formato

| Formato | Cantidad | Tamaño Promedio | Tamaño Total | % del Total |
|---------|----------|-----------------|--------------|-------------|
| WebP | - | - | - | - |
| JPG | - | - | - | - |
| PNG | - | - | - | - |
| GIF | - | - | - | - |
| SVG | - | - | - | - |
| **TOTAL** | - | - | - | 100% |

---

## Análisis por Tamaño

### Imágenes >1MB (Optimizar)
| Archivo | Tamaño | Dimensiones | Formato | Prioridad Optimización |
|----------|---------|-------------|---------|------------------------|
| *Por identificar* | - | - | - | - |

### Imágenes >500KB (Revisar)
| Archivo | Tamaño | Dimensiones | Formato | Notas |
|----------|---------|-------------|---------|-------|
| *Por identificar* | - | - | - | - |

---

## Imágenes Sin Uso (Candidatas a Eliminar)

| Archivo | Fecha Subida | Tamaño | Razón | Acción |
|----------|--------------|---------|-------|--------|
| *Por identificar* | - | - | No referenciada | Eliminar |

---

## Imágenes Sin Alt Text (Accesibilidad)

| Archivo | Página | Prioridad | Sugerencia Alt Text |
|----------|---------|-----------|---------------------|
| *Por identificar* | - | Alta/Media/Baja | - |

---

## Imágenes con Texto Hardcoded (Traducción)

| Archivo | Texto ES | Texto EN | Ubicación | Acción Requerida |
|----------|----------|----------|-----------|------------------|
| *Por identificar* | - | ❌ Falta | Home banner | Recrear imagen bilingüe |

---

## Análisis por Fecha de Subida

| Año/Mes | Cantidad | Tamaño Total | Notas |
|---------|----------|--------------|-------|
| 2025/10 | - | - | Fase UI/UX |
| 2025/09 | - | - | - |
| *Anteriores* | - | - | Legacy |

---

## Comandos Utilizados

```bash
# Listar todos los archivos de media library
wp media list --format=csv --fields=ID,file,title,alt,mime_type,width,height

# Obtener metadata de imagen específica
wp media get <ID> --format=json

# Listar archivos grandes (>1MB)
find wp-content/uploads/ -type f -size +1M -exec ls -lh {} \;

# Contar archivos por formato
find wp-content/uploads/ -name "*.webp" | wc -l
find wp-content/uploads/ -name "*.jpg" | wc -l
find wp-content/uploads/ -name "*.png" | wc -l

# Metadata con exiftool
exiftool wp-content/uploads/2025/10/*.jpg
```

---

## Resumen Estadístico

**Actualización:** Se completará durante la auditoría

- **Total archivos:** 0 (en progreso)
- **Tamaño total:** 0 MB
- **Formatos:**
  - WebP: 0% (target: 80%+)
  - JPG: 0%
  - PNG: 0%
  - Otros: 0%
- **Imágenes >1MB:** 0 (target: 0)
- **Sin alt text:** 0 (target: 0)
- **Sin uso:** 0 (candidatas a eliminar)

---

## Objetivos de Optimización

### Formatos
- [ ] Migrar 100% imágenes a WebP (excepto SVG)
- [ ] Comprimir JPG/PNG legacy antes de WebP conversion

### Tamaño
- [ ] Reducir imágenes >1MB a <500KB
- [ ] Tamaño promedio target: <200KB por imagen

### Accesibilidad
- [ ] 100% imágenes con alt text descriptivo
- [ ] Alt text bilingüe (ES/EN) donde aplique

### Limpieza
- [ ] Eliminar imágenes sin uso (liberar espacio)
- [ ] Consolidar duplicados

---

## Notas de Auditoría

- ✅ Canon confirmado: runart-base
- ✅ Modo READ_ONLY (sin modificaciones)
- ⏳ Inventario en progreso
- 📝 Priorizar imágenes de páginas principales (Home, About, Services)

---

**Última actualización:** 2025-10-29  
**Próxima revisión:** Durante ejecución de WP-CLI media queries  
**Estado:** ✅ PLANTILLA LISTA — Iniciar inventario de media library
