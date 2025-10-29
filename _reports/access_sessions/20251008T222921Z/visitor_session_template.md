# Sesión "Ver como" — Rol Visitor

**Fecha y hora (UTC):** `YYYY-MM-DDThh:mm:ssZ`
**Entorno:** `preview` | `prod`
**Participantes:** `Visitante / QA`

## Checklist
- [ ] Navegar al dominio público y confirmar redirección a Cloudflare Access.
- [ ] Intentar acceder a `/dash/visitor` y verificar mensaje informativo.
- [ ] Ejecutar `curl` a `/api/inbox` sin credenciales → esperar 403.
- [ ] Revisar `/api/whoami` sin sesión → rol `visitante`, env correcto.
- [ ] Registrar mensajes de error, tiempos de respuesta, capturas.

## Capturas requeridas
1. `captures/visitor/access_screen_<timestamp>.png`
2. `captures/visitor/forbidden_<timestamp>.png`

## Observaciones
- **Redirección Access:** `OK/FAIL` — notas.
- **Mensajes de restricción:** `OK/FAIL` — notas.
- **API responses:** Adjuntar salida de `curl`.

## Seguimiento
- Issues creados / referencias:
- Próxima sesión o reintento:
