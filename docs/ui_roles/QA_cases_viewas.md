# Casos de Prueba — View-as (Fase 7) — 2025-10-21 17:52:17

| Caso | Descripción | Paso | Resultado esperado | Estado |
|---|---|---|---|---|
| TC-VA-01 | Activación por Admin | Admin accede a /briefing?viewAs=cliente | Banner "Simulando: Cliente" visible; persistencia en sesión | Pendiente |
| TC-VA-02 | Activación por No-Admin | Usuario cliente intenta ?viewAs=owner | Ignorado; permanece en rol real | Pendiente |
| TC-VA-03 | Cambio de ruta | Admin activa ?viewAs=equipo y navega a /otra-ruta | Banner persiste; rol simulado se mantiene | Pendiente |
| TC-VA-04 | Expiración TTL | Admin activa View-as; espera 30 min | Sesión expira; vuelve a rol real | Pendiente |
| TC-VA-05 | Reset manual | Admin activa View-as; pulsa botón Reset | Vuelve a rol real; banner desaparece | Pendiente |
| TC-VA-06 | Rol no permitido | Admin intenta ?viewAs=inventado | Rechazado; mensaje de error/neutralizado | Pendiente |
| TC-VA-07 | Accesibilidad | Admin activa View-as con lector de pantalla | Anuncio 'Simulando: <rol>' escuchado | Pendiente |
| TC-VA-08 | Logging | Admin activa/desactiva View-as | Log registra timestamp, rol real, rol simulado, ruta | Pendiente |

Observaciones:
- Ejecutar todos los casos antes de GO Fase 7.
- Registrar estado (Paso/Falla) y evidencias en QA_checklist_admin_viewas_dep.md.
