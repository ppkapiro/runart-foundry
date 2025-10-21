# Especificación “View-as” (Admin)

- Selector en header: Admin | Cliente | Owner | Equipo | Técnico
- Banner visible: “Simulando: <rol>” (color distintivo, p. ej., ámbar)
- Query param: ?viewAs=cliente (permite deep-link y reproducibilidad)
- Seguridad: solo Admin puede activar el override; no se modifican permisos backend (solo presentación/UI)
- Trazabilidad: registrar activación/desactivación con ruta y timestamp (log mínimo)
- Tiempo de vida: persistencia en sesión/tab con opción “Reset” visible
- Accesibilidad: banner con rol anunciado para lectores de pantalla


## Estado: implementable en docs UI (2025-10-21 17:32:25)
- Soporte de parámetro ?viewAs=cliente en navegación/documentos.
- Banner “Simulando: Cliente” con i18n y nota de accesibilidad.
- Reglas: solo Admin puede activar; no modifica permisos backend.

## Escenarios View-as Owner/Equipo (2025-10-21 17:42:34)
- ?viewAs=owner — Banner “Simulando: Owner”, persistencia por sesión, botón Reset, lector de pantalla.
- ?viewAs=equipo — Banner “Simulando: Equipo”, persistencia por sesión, botón Reset, lector de pantalla.
- Deep-links ejemplo: /briefing?viewAs=owner, /briefing?viewAs=equipo
- Seguridad: no altera permisos backend; solo presentación.

## Endurecimiento View-as — Fase 7 (2025-10-21 17:52:17)

### Política de activación
- **Solo Admin** puede activar override; si rol real ≠ admin, ignorar/neutralizar ?viewAs.
- Lista blanca: {admin, cliente, owner, equipo, tecnico}; rechazar otros valores.
- Normalizar mayúsculas/minúsculas (viewAs=CLIENTE → cliente).

### Persistencia y TTL
- TTL de sesión: 30 minutos (documental).
- Botón Reset visible y accesible.

### Seguridad
- No modifica permisos backend; solo presentación UI.
- Logging mínimo: (timestamp ISO, rol real, rol simulado, ruta, referrer opcional).

### Accesibilidad
- Banner con aria-live='polite' y texto 'Simulando: <rol>'.
- Lector de pantalla anuncia cambio de rol.

### Deep-links
- Ejemplos: /briefing?viewAs=cliente, /briefing?viewAs=owner
- Reproducibilidad: útil para QA; advertir de no compartir fuera del equipo Admin.

### Casos de prueba
- Activar/desactivar View-as.
- Cambio de ruta con persistencia.
- Expiración por TTL.
- Reset manual.
- Intentos de roles no permitidos (debe rechazar).

## Escenarios View-as Técnico (2025-10-21 18:00:45)
- ?viewAs=tecnico — Banner 'Simulando: Técnico', persistencia por sesión, botón Reset, lector de pantalla.
- Deep-links ejemplo: /briefing?viewAs=tecnico
- Seguridad: solo Admin puede activar override; no altera permisos backend.
