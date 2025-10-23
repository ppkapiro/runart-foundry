# DELTA PLAN: PEPECAPIRO → RUNART FOUNDRY i18n

**Fecha**: 2025-01-22  
**Scope**: Análisis de gaps entre implementación Pepe Capiro vs RunArt Foundry  
**Objetivo**: Identificar diferencias técnicas para planificación de portado  
**Status**: Ready for implementation  

---

## RESUMEN EJECUTIVO

**GAP PRINCIPAL**: RunArt Foundry carece completamente de sistema i18n  
**OPORTUNIDAD**: Pepecapiro blueprint permite implementación robusta desde cero  
**COMPLEJIDAD**: Media - requiere setup Polylang + adaptación texto domain  

---

## 1. ANÁLISIS COMPARATIVO

### PEPECAPIRO (Origen) ✅
```yaml
Motor i18n: Polylang Plugin
Text Domain: 'pepecapiro'  
Idiomas: ES (root), EN (/en/)
Strings: 17 localizados
SEO: hreflang completo
Navegación: Menús separados
Switcher: Header con flags
Templates: Específicos por idioma
```

### RUNART FOUNDRY (Destino) ❌
```yaml
Motor i18n: NINGUNO
Text Domain: N/A
Idiomas: Solo EN (asumido)
Strings: Hardcoded
SEO: Monolingüe
Navegación: Single menu
Switcher: NO existe
Templates: Inglés únicamente
```

---

## 2. GAPS IDENTIFICADOS

### 🔴 CRÍTICOS (Bloquean funcionamiento)

#### A. Plugin Dependencies
```diff
- RunArt: Sin Polylang
+ Pepecapiro: Polylang activo + configurado
```
**Impacto**: Sistema i18n no funcionará sin plugin

#### B. Text Domain
```diff
- RunArt: Sin text domain definido
+ Pepecapiro: 'pepecapiro' en todas las funciones
```
**Impacto**: Strings no se pueden traducir

#### C. Language Structure
```diff
- RunArt: URLs monolingües
+ Pepecapiro: ES (root) + EN (/en/)
```
**Impacto**: SEO y navegación rotos

### 🟡 IMPORTANTES (Degradan experiencia)

#### D. Navigation System
```diff
- RunArt: Single menu
+ Pepecapiro: Menús por idioma ('Principal ES', 'Main EN')
```

#### E. Language Switcher
```diff
- RunArt: No existe
+ Pepecapiro: Header con flags + nombres
```

#### F. SEO Multilingüe
```diff
- RunArt: Meta tags únicos
+ Pepecapiro: hreflang + canonical + meta por idioma
```

### 🟢 DESEABLES (Mejoran implementación)

#### G. Templates Específicos
```diff
- RunArt: Templates genéricos
+ Pepecapiro: page-contact.php + page-contacto.php
```

#### H. Content Strategy
```diff
- RunArt: Content hardcoded
+ Pepecapiro: Condicionales + traducciones inline
```

---

## 3. ANÁLISIS DE ESFUERZO

### ESFUERZO TOTAL ESTIMADO: **16-24 horas**

| Gap | Complejidad | Horas | Prioridad |
|-----|-------------|-------|-----------|
| **Plugin Setup** | Baja | 2h | P0 |
| **Text Domain** | Media | 4h | P0 |
| **URL Structure** | Alta | 6h | P0 |
| **Navigation** | Media | 3h | P1 |
| **Language Switcher** | Baja | 2h | P1 |
| **SEO Multilingüe** | Media | 4h | P1 |
| **Templates** | Baja | 3h | P2 |
| **Testing** | Media | 4h | P0 |

### ROADMAP POR FASES

**FASE 1 - Setup Básico (8h)**
- Polylang installation + configuration
- Text domain implementation
- URL structure setup

**FASE 2 - Navegación (5h)** 
- Menús bilingües
- Language switcher
- Header modifications

**FASE 3 - SEO + Optimization (7h)**
- hreflang implementation  
- Meta tags bilingües
- Canonical URLs
- Testing completo

**FASE 4 - Polish (4h)**
- Templates específicos
- Content optimization
- User testing

---

## 4. RIESGOS Y MITIGATION

### 🚨 RIESGOS TÉCNICOS

#### R1. Plugin Dependency
**Riesgo**: Polylang no disponible en staging  
**Mitigation**: Verificar compatibility antes de inicio  
**Impacto**: ALTO - Bloqueante total  

#### R2. URL Structure Changes  
**Riesgo**: Breaking existing links/SEO  
**Mitigation**: 301 redirects + sitemap update  
**Impacto**: MEDIO - SEO temporal impact  

#### R3. Content Duplication
**Riesgo**: Strings duplicados entre idiomas  
**Mitigation**: POT file generation + translation workflow  
**Impacto**: BAJO - Maintenance overhead  

### 🛡️ ESTRATEGIAS DE MITIGATION

1. **Staging First**: Implementar en WP Staging antes de live
2. **Backup Strategy**: Full backup antes de cambios URL
3. **Rollback Plan**: Keep monolingüe version como fallback
4. **Testing Protocol**: Cross-browser + device testing

---

## 5. DEPENDENCIES Y PREREQUISITES  

### TÉCNICAS
```yaml
WordPress: 5.0+ (RunArt compatible)
PHP: 7.4+ (current stack)  
Polylang: Latest stable
Staging Environment: WP Staging Lite (✅ ya instalado)
```

### CONTENIDO
```yaml
Translations: ES ↔ EN content needed
Menu Items: Bilingual navigation structure  
Media: Shared or language-specific assets
Forms: Contact forms en ambos idiomas
```

### RECURSOS
```yaml
Developer: 16-24h implementation time
Translator: Para strings no auto-traducibles  
Tester: QA cross-language functionality
Project Manager: Coordination + timeline
```

---

## 6. COMPATIBILITY MATRIX

| Componente | Pepecapiro | RunArt | Gap | Action |
|------------|------------|--------|-----|--------|
| **WordPress** | 6.0+ | 6.0+ | ✅ | No action |
| **Theme Base** | Custom | Custom | ✅ | Adapt patterns |
| **Plugins** | Polylang | None | ❌ | Install + config |
| **Text Domain** | pepecapiro | TBD | ❌ | Define new domain |
| **URL Strategy** | Prefix | Single | ❌ | Implement prefix |
| **SEO Plugin** | RankMath | ? | ⚠️ | Verify compatibility |

---

## 7. MIGRATION STRATEGY

### APPROACH: **Incremental Implementation**

#### Step 1: Foundation
```bash
# Install Polylang
# Define text domain: 'runart-foundry'  
# Configure basic ES/EN languages
```

#### Step 2: Content Structure
```bash
# Create bilingual menus
# Implement language switcher
# Setup URL prefixes  
```

#### Step 3: SEO Implementation
```bash
# hreflang tags
# Canonical URLs
# Meta tags por idioma
```

#### Step 4: Testing & Optimization
```bash
# Cross-language testing
# Performance validation  
# SEO verification
```

### DATA MIGRATION
- **Content**: Manual translation required
- **Menus**: Recreate per language
- **Media**: Shared library approach
- **Settings**: Export/import Polylang config

---

## 8. SUCCESS METRICS

### FUNCTIONAL REQUIREMENTS ✅
- [ ] Language switcher working
- [ ] URLs per language functional  
- [ ] Menus display correctly
- [ ] hreflang present in source
- [ ] Translations load properly

### PERFORMANCE BENCHMARKS 📊
- [ ] Page load < 2s (both languages)
- [ ] No 404s in language switching
- [ ] Sitemap includes all language URLs
- [ ] Search engines index both versions

### USER EXPERIENCE 🎯
- [ ] Intuitive language switching
- [ ] Consistent navigation across languages  
- [ ] Proper fallbacks if content missing
- [ ] Mobile responsive switcher

---

## 9. NEXT ACTIONS

1. **Review this delta plan** with team
2. **Generate implementation plan** → `i18n_implantacion_runart_plan.md`
3. **Create feature branch** → `feature/i18n-port`
4. **Schedule implementation** based on priority matrix

---

*Gap analysis completed as part of ORQUESTACIÓN COPAYLO*  
*Ready for technical implementation planning phase*