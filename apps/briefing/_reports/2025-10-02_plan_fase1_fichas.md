# Plan Detallado — Fase 1 (Normalización de Fichas Técnicas)

**Fecha:** 2 de octubre de 2025  
**Proyecto:** RUN Art Foundry — Briefing Privado  
**Responsable:** Equipo de consultoría  

---

## 1. Propósito
Convertir el caos de información dispersa en documentación estandarizada y reutilizable.  
El objetivo es contar con 20–30 proyectos documentados en formato técnico, bilingüe y optimizado, que alimenten la nueva web, el press-kit y el dossier institucional.

---

## 2. Componentes principales
1. **Fichas técnicas de proyectos** en YAML/Markdown.  
2. **Biografía y portafolio de Uldis López** (bilingüe).  
3. **Narrativa corporativa RUN Art Foundry** (historia, servicios, testimonios).  
4. **Repositorio audiovisual optimizado** en `assets/`.  
5. **Press-kit institucional** generado automáticamente (PDF ES/EN).  

---

## 3. Estructura de archivos
- `docs/projects/` → fichas en `.yaml`.  
- `docs/projects/en/` → traducciones al inglés.  
- `docs/uldis/` → biografía y statement.  
- `docs/run/` → narrativa corporativa.  
- `assets/{year}/{project}/` → imágenes y videos optimizados.  
- `briefing/_reports/fase1_fichas.md` → checklist y control de avance.  

---

## 4. Flujo de trabajo

### 4.1 Fase inicial (3 proyectos piloto)
- Documentar *Mons. Román (2015)*, *Raider (2018)* y 1 colaboración internacional.  
- Completar campos obligatorios en YAML.  
- Añadir al menos 2 imágenes optimizadas por proyecto.  
- Incluir 1 testimonio o referencia externa.

### 4.2 Fase intermedia (10 proyectos)
- Ampliar a 10 fichas.  
- Estandarizar unidades y materiales.  
- Traducir campos clave al inglés.

### 4.3 Fase avanzada (20–30 proyectos)
- Completar hasta 30 fichas.  
- Cada ficha con:  
  - 3 imágenes optimizadas.  
  - 1 video de proceso o instalación.  
  - 1 testimonio o referencia externa.  
- Incluir links externos clicables (prensa, catálogos).

---

## 5. Checklist de inicio de Fase 1
- [ ] Crear plantilla `_template.yaml` en `docs/projects/`.  
- [ ] Documentar proyectos piloto (Mons. Román, Raider, colaboración internacional).  
- [ ] Migrar imágenes a `assets/{year}/{project}/` y optimizar.  
- [ ] Redactar biografía de Uldis (ya curada en Fase 0).  
- [ ] Redactar narrativa corporativa RUN Art Foundry.  
- [ ] Preparar primer press-kit (MkDocs → PDF).  
- [ ] Configurar CI/CD para generar PDFs automáticos.  

---

## 6. Entregables esperados
1. **20–30 fichas técnicas** completas en YAML.  
2. **Repositorio audiovisual optimizado** en `assets/`.  
3. **Biografía y narrativa corporativa bilingües** en `docs/`.  
4. **Press-kit institucional v1** (PDF bilingüe).  
5. **Reporte de control** en `briefing/_reports/fase1_fichas.md`.  

---

## 7. Criterios de éxito
- Todas las fichas con estructura YAML válida y coherente.  
- Al menos 20 proyectos documentados con imágenes y referencias.  
- Press-kit generado automáticamente (PDF ES/EN).  
- Cliente puede consultar fichas y documentos en la web (ES/EN).  

---
