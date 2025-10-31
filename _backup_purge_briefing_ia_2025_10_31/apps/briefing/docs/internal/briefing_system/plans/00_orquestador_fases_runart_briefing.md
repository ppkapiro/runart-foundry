# 🚦 Orquestador de Fases — RunArt Briefing
**Versión:** v1.2 — 2025-10-08  
**AUTO_CONTINUE:** true  
**Convención de estados:** pending | running | done

## Índice de fases
| Fase | Nombre | Documento | Estado | Última actualización |
|-----:|--------|-----------|--------|----------------------|
| F1 | Consolidación documental | ../reports/2025-10-08_fase1_consolidacion_documental.md | done | 2025-10-08T23:59Z |
| F2 | Corrección técnica y normalización | ../reports/2025-10-09_fase2_correccion_tecnica_y_normalizacion.md | done | 2025-10-09T23:59Z |
| F3 | Administración de roles y delegaciones | ../reports/2025-10-09_fase3_administracion_roles_y_delegaciones.md | done | 2025-10-09T21:30Z |
| F4 | Consolidación y cierre operativo | ../reports/2025-10-10_fase4_consolidacion_y_cierre.md | done | 2025-10-10T21:30Z |
| F5 | UI contextual y experiencias por rol | ../reports/2025-10-11_fase5_ui_contextual_y_experiencias_por_rol.md | done | 2025-10-08T23:00Z |
| F6 | Datos reales y operación continua | — | pending | — |

### Reglas de orquestación
1. Leer esta tabla de arriba hacia abajo; la **primera** fase con `state ∈ {running, pending}` es la fase actual.  
2. Si el documento de fase contiene `DONE: true`, marcarla como `done` aquí con timestamp y pasar a la siguiente.  
3. Si `AUTO_CONTINUE` == `true`, **no preguntar** al usuario: avanzar automáticamente. Si `false`, al cerrar una fase emitir la pregunta “¿Continuar con la siguiente fase?” y esperar confirmación.  
4. Todas las actualizaciones de estado deben sincronizarse también en la Bitácora 082.  
5. Este orquestador debe mantenerse idempotente: ejecutar múltiples veces no debe duplicar cierres ni reabrir fases finalizadas.  
6. Los sellos de cierre de cada fase son la fuente de verdad para `DONE`, `CLOSED_AT`, `SUMMARY` y `NEXT`.  
