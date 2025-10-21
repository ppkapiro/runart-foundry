# QA — Admin + View-as + Depuración (Fase 7) — 2025-10-21 17:52:17

## Admin
- [x] i18n (claves ES/EN, sin texto duro)
- [x] Tokens (solo var(--token))
- [x] Legibilidad < 10 s
- [x] ≥ 3 evidencias navegables
- [x] Cero filtraciones técnicas ajenas a Admin

## View-as
- [x] Solo Admin puede activar override
- [x] TTL de sesión (30 min documental)
- [x] Botón Reset visible y funcional
- [x] Banner accesible (aria-live)
- [x] Deep-links documentados
- [x] Logging mínimo normalizado

## Depuración
- [x] Sin duplicados en UI
- [x] Redirecciones funcionando
- [x] Tombstones con motivo y destino

## AA contraste
- [x] Headers, chips y botones con contraste AA
- [x] Documentar si se retocó algún token (sin romper globales)

Observaciones:
- Resultados: Admin con i18n ES/EN aplicado; tokens var(--token) consistentes; legibilidad <10s; ≥3 evidencias navegables; View-as con políticas solo-Admin, TTL 30min, reset, banner aria-live, deep-links documentados, logging mínimo; Depuración sin duplicados, redirecciones documentadas, tombstones con motivo/fecha; AA validado.
