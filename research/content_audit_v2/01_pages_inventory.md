# Inventario de Páginas — RunArt Foundry (Fase 1)

**Fecha:** 2025-10-29  
**Tema:** RunArt Base (runart-base)  
**Modo:** READ_ONLY=1  
**Entorno:** Staging (sin modificaciones)

---

## Propósito

Registrar todas las páginas detectadas en el sitio, clasificándolas por tipo, idioma, plantilla y estado de publicación. Este inventario servirá como base para:
- Identificar gaps de traducción (ES/EN)
- Validar estructura de contenido
- Detectar páginas legacy o sin uso
- Planificar optimización SEO

---

## Inventario Completo

| ID | Página | Idioma | Plantilla | URL (Staging) | Estado | Notas |
|----|---------|---------|------------|----------------|--------|-------|
| 1 | Home | ES | page-home.php | /es/ | ✅ Publicado | Landing principal |
| 2 | Home | EN | page-home.php | /en/ | ✅ Publicado | Landing principal (traducción) |
| - | - | - | - | - | - | *Añadir páginas durante auditoría* |

---

## Páginas por Tipo

### Landing Pages
- Home (ES/EN)
- *Añadir durante auditoría*

### Páginas de Servicio
- *Por identificar*

### Páginas Institucionales
- About / Acerca de
- Contact / Contacto
- *Por identificar*

### Blog Posts
- *Por identificar*

### Portafolio Items
- *Por identificar*

---

## Páginas sin Traducción

| Página | Idioma Disponible | Idioma Faltante | Prioridad |
|--------|-------------------|-----------------|-----------|
| *Por identificar* | - | - | - |

---

## Páginas Draft / No Publicadas

| Página | Estado | Razón | Acción Sugerida |
|--------|--------|-------|-----------------|
| *Por identificar* | - | - | - |

---

## Páginas Legacy (Candidatas a Deprecar)

| Página | Última Actualización | Uso | Recomendación |
|--------|---------------------|-----|---------------|
| *Por identificar* | - | - | - |

---

## Plantillas Utilizadas

| Plantilla | Páginas que la usan | Observaciones |
|-----------|---------------------|---------------|
| page-home.php | Home (ES/EN) | Landing principal |
| *Por identificar* | - | - |

---

## Resumen Estadístico

**Actualización:** Se completará durante la auditoría

- **Total páginas:** 2+ (en progreso)
- **Publicadas:** 2
- **Draft:** 0
- **Solo ES:** 0
- **Solo EN:** 0
- **Bilingües (ES/EN):** 2
- **Legacy:** 0

---

## Comandos Utilizados

```bash
# Listar todas las páginas (WordPress)
wp post list --post_type=page --format=csv --fields=ID,post_title,post_status,post_name

# Listar páginas por idioma (si plugin i18n instalado)
wp post list --post_type=page --lang=es --format=csv
wp post list --post_type=page --lang=en --format=csv

# Obtener detalles de página específica
wp post get <ID> --format=json
```

---

## Notas de Auditoría

- ✅ Canon confirmado: runart-base
- ✅ Modo READ_ONLY (sin modificaciones)
- ⏳ Inventario en progreso
- 📝 Actualizar conteos al finalizar cada sesión de auditoría

---

**Última actualización:** 2025-10-29  
**Próxima revisión:** Durante ejecución de WP-CLI queries  
**Estado:** ✅ PLANTILLA LISTA — Iniciar inventario
