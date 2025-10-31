# Runbook Operativo — Control de Accesos y Roles

## Control de Accesos y Roles

### Taxonomía unificada
| nombre_canónico | alias_UI | claim_access | descripción | hereda_de |
|-----------------|----------|--------------|-------------|-----------|
| owner | admin | `runart:admin` | Dirección con control total de delegaciones, métricas y configuración. | admin_delegate, team, client |
| client_admin | admin_delegate | `runart:admin_delegate` | Delegados del cliente con permisos extendidos sobre dashboards y gestión de roles. | team, client |
| team | team | `runart:team` | Operaciones internas (producción, soporte, moderación). | client |
| client | client | `runart:client` | Clientes finales con acceso a información de proyecto. | visitor |
| visitor | visitor | `runart:visitor` | Sesiones sin privilegios (incluye no autenticados). | — |

### Flujo de resolución (5 pasos)
1. **Autenticación Access:** Cloudflare Access valida correo y emite headers (`Cf-Access-Authenticated-User-Email`, claims).  
2. **Resolver único:** Middleware invoca `resolveRole` compartido (overrides `ACCESS_*` + KV `RUNART_ROLES`).  
3. **Propagación:** Middleware inserta `X-RunArt-Email`, `X-RunArt-Role`, `X-RunArt-Role-Alias` y elimina bypass no autorizado.  
4. **Guardas y ACL:** `requireTeam`, `requireAdmin` y ACL `/dash/*` consumen el mismo resolver; se aplica fallback `visitor`.  
5. **Handlers/UI:** Endpoints y UI presentan funcionalidades según alias (`admin`, `admin_delegate`, `team`, `client`, `visitor`) y registran eventos en `LOG_EVENTS`.

### Checklist de sincronización
- [ ] KV `RUNART_ROLES` actualizado (owners, admin_delegate, team, client, domains).  
- [ ] Variables `ACCESS_*` (admins, domains, overrides) alineadas con la tabla.  
- [ ] Policies de Cloudflare Access (`runart:*`) reflejan nombres y herencias definidas.  
- [ ] UI (`userbar`, `env-flag`, dashboards `/dash/*`) muestra alias y rutas correctas.  
- [ ] Smokes T3 (preview y prod) ejecutados con PASS, evidencias archivadas.  
- [ ] Bitácora 082 registra cambios y enlaces a `_reports/roles_canary_*`.

### Verificación rápida
1. **Preparar tokens:** obtener Service Tokens para `admin`, `admin_delegate`, `team`, `client`.  
2. **`whoami` por rol:**  
   ```bash
   curl -s https://runart-foundry.pages.dev/api/whoami \
     -H "CF-Access-Client-Id: $ADMIN_ID" \
     -H "CF-Access-Client-Secret: $ADMIN_SECRET" | jq '{email,role,rol,env}'
   ```  
   Repetir con tokens de admin_delegate, team y client.  
3. **`inbox` y `log_event`:** garantizar 200 para admin/admin_delegate/team y 403 para client/visitor.  
4. **Dashboards:** abrir `/dash/admin`, `/dash/admin_delegate`, `/dash/team`, `/dash/client`, `/dash/visitor` según rol impersonado y verificar contenido esperado.  
5. **Eventos:** consultar KV `LOG_EVENTS` para confirmar registros con alias correcto (`roles.update`, `page_view`).

### Indicadores de salud (post release)
- **Smokes T3:** PASS contínuo en preview y producción (público + autenticado).  
- **`LOG_EVENTS`:** entradas recientes por rol sin fallback inesperado; tasa de errores < 1%.  
- **`/api/whoami`:** latencia estable (<300 ms) y alias coherente.  
- **Dashboards `/dash/*`:** sin errores 4xx/5xx en reportes de usuarios.  
- **Incidentes:** `INCIDENTS.md` sin nuevos registros relacionados con Access tras 48 h.
