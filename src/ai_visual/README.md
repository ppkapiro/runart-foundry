# IA-Visual Implementation — RunArt Foundry

**Rama:** `feat/ai-visual-implementation`  
**Fase:** F7 — Arquitectura IA-Visual  
**Fecha de inicio:** 2025-10-30  
**Duración estimada:** 10 días (hasta 2025-11-15)

---

## 📋 Propósito

Esta rama contiene la implementación del sistema de correlación semántica texto↔imagen mediante IA para RunArt Foundry, según lo especificado en el **Plan Maestro IA-Visual (F7–F10)**.

### Objetivos de F7 (Arquitectura IA-Visual)

1. ✅ Establecer estructura de almacenamiento en `data/embeddings/`
2. ⏳ Implementar 3 módulos Python en `apps/runmedia/runmedia/`:
   - `vision_analyzer.py` — Generación de embeddings visuales con CLIP
   - `text_encoder.py` — Generación de embeddings textuales con Sentence-Transformers
   - `correlator.py` — Cálculo de similitud coseno y recomendaciones
3. ⏳ Crear 2 endpoints REST en `tools/wpcli-bridge-plugin/runart-wpcli-bridge.php`:
   - `GET /wp-json/runart/correlations/suggest-images`
   - `POST /wp-json/runart/embeddings/update`
4. ⏳ Documentar arquitectura en `docs/ai/architecture_overview.md`
5. ⏳ Configurar dependencias en `requirements.txt`

---

## 🏗️ Estructura de Directorios

```
src/ai_visual/
├── README.md                          # Este archivo
├── modules/                           # Módulos Python de IA-Visual
│   ├── __init__.py
│   ├── vision_analyzer.py            # (Pendiente implementación)
│   ├── text_encoder.py               # (Pendiente implementación)
│   └── correlator.py                 # (Pendiente implementación)
└── tests/                            # Tests unitarios
    └── test_vision_analyzer.py       # (Pendiente)

data/embeddings/
├── images/                           # Embeddings visuales (CLIP 512D)
│   └── README.md                     # (Pendiente)
├── texts/                            # Embeddings textuales (768D)
│   └── README.md                     # (Pendiente)
└── correlations/                     # Matrices de similitud
    └── README.md                     # (Pendiente)

reports/ai_visual_progress/
└── f7_architecture_log.md            # Log de progreso F7 (Pendiente)
```

---

## 🛠️ Stack Tecnológico

### Dependencias Principales

- **sentence-transformers** 2.7.0 — CLIP + multilingual text embeddings
- **torch** 2.3.1+cpu — Motor de inferencia para modelos
- **pillow** 10.3.0 — Procesamiento de imágenes
- **scikit-learn** 1.4.2 — Cálculo de similitud coseno
- **opencv-python** 4.9.0.80 (opcional) — Análisis avanzado de imágenes

### Modelos de IA

1. **Visual:** `clip-vit-base-patch32` → Embeddings de 512 dimensiones
2. **Textual:** `paraphrase-multilingual-mpnet-base-v2` → Embeddings de 768 dimensiones (ES/EN)

---

## 🚀 Próximos Pasos (F7)

### Semana 1 (Nov 4-8, 2025)

- [ ] Implementar `vision_analyzer.py` con método `generate_visual_embedding()`
- [ ] Crear tests unitarios para CLIP
- [ ] Documentar formato JSON de embeddings visuales

### Semana 2 (Nov 11-15, 2025)

- [ ] Implementar `text_encoder.py` con método `generate_text_embedding()`
- [ ] Implementar `correlator.py` con método `recommend_images_for_page()`
- [ ] Crear endpoints REST en plugin WordPress
- [ ] Documentar arquitectura completa en `docs/ai/`
- [ ] Configurar CI/CD workflow `.github/workflows/visual-analysis.yml`

---

## 📊 Métricas de Éxito F7

| Métrica | Objetivo |
|---------|----------|
| Módulos Python implementados | 3/3 |
| Endpoints REST funcionando | 2/2 |
| Tests unitarios aprobados | ≥90% coverage |
| Documentación arquitectura | Completa |
| Estructura `data/embeddings/` | Creada y validada |

---

## 📖 Referencias

- **Plan Maestro:** `/PLAN_MAESTRO_IA_VISUAL_RUNART.md`
- **Documentación técnica:** `/docs/ai/` (pendiente)
- **Investigación previa:** `/research/ai_visual_tools_summary.md`
- **Bitácora:** `/_reports/BITACORA_AUDITORIA_V2.md`

---

## 🔗 Enlaces Relacionados

- **PR de aprobación:** #77 (feat/content-audit-v2-phase1)
- **Log de validación QA:** `_reports/PLAN_MASTER_QA_VALIDATION_20251030.md`
- **Branch principal:** `develop`

---

**Estado actual:** 🟢 Entorno de implementación inicializado — Listo para desarrollo F7
