# Control de Avance — Fase 1 (Fichas Técnicas)

### Fase ARQ — Arquitectura del Briefing

* [x] Documento de arquitectura publicado
* [x] Verificar briefing_arquitectura.md en navegación
* [x] Definir roles/visibilidad de menús (ARQ-01)
* [x] Prototipo de editor guiado YAML (ARQ-02)
* [x] Endurecer seguridad de formularios (ARQ-06)
* [ ] Configurar próximo “corte ARQ” (validaciones y métricas del sistema)

> ARQ-0 cerrado — baseline validado.

> Nota ARQ-1: Implementación inicial con flags en `main.html` y `roles.js`.
> Nota ARQ-2: Editor v1 genera YAML, envía JSON al inbox, marca `token_origen = editor_v1` y QA v1.1 ejecutado (build ok, validador local listo).
> Nota ARQ-3: Fortificación v1.1 aplicada — UI del editor e inbox reforzadas, trail de moderación activo y smoke tests `smoke_arq3.sh` listos.

### Fase ARQ — Sistema Briefing (Visualización)
- [x] Plan publicado en `reports/`
- [x] ARQ-1 · Roles/visibilidad implementado
- [x] ARQ-2 · Editor guiado (v1) operativo
	- QA v1.1 ejecutado, build ok, validación de esquema local lista
- [x] ARQ-3 · Seguridad de formularios (token/captcha)
- [ ] ARQ-4 · Dashboard KPIs (modo cliente)
- [x] ARQ-5 · Exportaciones (MF) — JSONL/CSV por rango (accepted)
- [ ] ARQ-5 · Export ZIP por lote
- [x] ARQ-6 · QA & Corte ARQ (MF) publicado

> Notas ARQ recientes:
> - ARQ-2 QA v1.1 completado (build ok; editor/inbox listos).
> - ARQ-3 MF: token + honeypot + pending/accept/reject con UI mínima.
> - ARQ-6 MF: Corte ARQ documentado (`reports/corte_arq.md`), navegación con "Corte Fase ARQ" y "Mapa de interfaces" publicada, QA `qa_arq6.sh` listo y advertencias de navegación aceptadas hasta refactor.

### ARQ+ v1 — cierre de etapa
- [x] Export ZIP (v1.1) operativo.
- [x] Warnings residuales neutralizados (recursos internos no publicados).
> Nota: Cuando se decida publicar audits/scripts/assets, se revertirá la neutralización.

## Pilotos (0–30 días)
- [ ] Mons. Román (2015) — YAML válido + 2 imágenes optimizadas
	- [x] YAML ES validado
	- [x] Stub EN creado
	- [ ] Imágenes optimizadas (2) — dummy cargado, pendientes archivos finales (`assets/2015/mons-roman-2015/`)
- [ ] Raider (2018) — YAML válido + 2 imágenes optimizadas
	- [x] YAML ES validado
	- [x] Stub EN creado
	- [ ] Imágenes optimizadas (2) — dummy cargado, pendientes archivos finales (`assets/2018/raider-2018/`)
- [ ] Colaboración internacional — YAML válido + 2 imágenes optimizadas
	- [x] YAML ES validado
	- [x] Stub EN creado
	- [ ] Imágenes optimizadas (2) — dummy cargado, pendientes archivos finales (`assets/2018/colaboracion-internacional-01/`)

## Ampliación
- [x] 10 fichas completas (intermedia — placeholders dummy, pendiente material final)
- [ ] 20–30 fichas completas (avanzada)

### Intermedios — Seguimiento individual
- [ ] Carole A. Feuerman (2019)
	- [x] YAML ES placeholder creado (`docs/projects/carole-feuerman-2019.yaml`)
	- [x] Stub EN creado (`docs/projects/en/carole-feuerman-2019.yaml`)
	- [x] Carpeta assets scaffold (`assets/2019/carole-feuerman-2019/`)
- [ ] Roberto Fabelo (2016)
	- [x] YAML ES placeholder creado (`docs/projects/roberto-fabelo-2016.yaml`)
	- [x] Stub EN creado (`docs/projects/en/roberto-fabelo-2016.yaml`)
	- [x] Carpeta assets scaffold (`assets/2016/roberto-fabelo-2016/`)
- [ ] Pedro Pablo Oliva (2017)
	- [x] YAML ES placeholder creado (`docs/projects/pedro-pablo-oliva-2017.yaml`)
	- [x] Stub EN creado (`docs/projects/en/pedro-pablo-oliva-2017.yaml`)
	- [x] Carpeta assets scaffold (`assets/2017/pedro-pablo-oliva-2017/`)
- [ ] Williams Carmona (2019)
	- [x] YAML ES placeholder creado (`docs/projects/williams-carmona-2019.yaml`)
	- [x] Stub EN creado (`docs/projects/en/williams-carmona-2019.yaml`)
	- [x] Carpeta assets scaffold (`assets/2019/williams-carmona-2019/`)
- [ ] The-Merger (2020)
	- [x] YAML ES placeholder creado (`docs/projects/the-merger-2020.yaml`)
	- [x] Stub EN creado (`docs/projects/en/the-merger-2020.yaml`)
	- [x] Carpeta assets scaffold (`assets/2020/the-merger-2020/`)
- [ ] Lawrence Holofcener (2015)
	- [x] YAML ES placeholder creado (`docs/projects/lawrence-holofcener-2015.yaml`)
	- [x] Stub EN creado (`docs/projects/en/lawrence-holofcener-2015.yaml`)
	- [x] Carpeta assets scaffold (`assets/2015/lawrence-holofcener-2015/`)
- [ ] Proyecto Messi (2024)
	- [x] YAML ES placeholder creado (`docs/projects/proyecto-messi-2024.yaml`)
	- [x] Stub EN creado (`docs/projects/en/proyecto-messi-2024.yaml`)
	- [x] Carpeta assets scaffold (`assets/2024/proyecto-messi-2024/`)

## Soportes
- [ ] Biografía Uldis ES/EN (v0)
- [ ] Narrativa RUN ES/EN (v0)
- [ ] Press-kit v0 (generación manual desde MkDocs)
- [x] Navegación ES/EN actualizada para pilotos en MkDocs
- [ ] Tablero OSINT (datos iniciales)

Fase ARQ cerrada (MF). Corte publicado, mapa enlazado, QA re-ejecutado y tag de cierre.

## Press-kit v0
- [ ] Generar PDF (manual)
- [x] Documento base creado (`reports/presskit_v0.md`)
- [x] Pipeline integrado (dummy)
- [x] PDFs publicados en /site/presskit (dummy)
- Nota: Los PDFs ya se copian al micrositio briefing; accesibles públicamente desde el menú.

## Press-kit v1
- [x] Biografía Uldis (borrador real)
- [x] Narrativa corporativa (borrador real)
- [x] Imágenes dummy enlazadas
- [x] Testimonios dummy cargados
- [ ] Sustituir dummy por material final (pendiente)
- [x] Esqueleto PDF integrado en CI/CD (dummy con placeholders)

## Formularios cliente
- [x] Formulario de ficha creado en docs/decisiones/
- [ ] Validar envío real hacia inbox
- [ ] Revisar fichas recibidas y migrar a YAML
- [ ] Ejecutar "Promote Inbox → YAML (preview)" y revisar ZIP
- [ ] Ejecutar "Promote Inbox → YAML" (commit) cuando pase revisión
