# BUG — resolveRoleUnified devuelve admin para todos (preview2)

- **Contexto:** canario `RUNART_ROLES_MODE=unified`, resolver desde `_utils/roles.js`, entorno `preview2`.
- **Síntoma:** `/api/whoami` devuelve `role: "admin"` y `rol: "propietario"` para correos owner, admin_delegate, team, client y visitor.
- **Impacto:** Escalamiento de privilegios, rompe gobernanza y invalida pruebas de segregación de roles.
- **Acciones ejecutadas:** rollback inmediato al resolver legacy (`_lib/roles.js`), activación de logs comparativos, preparación de pruebas unitarias específicas.
- **Próximos pasos:** corregir `resolveRoleUnified` garantizando fallback `visitor`, normalizar correos (trim + lowercase), respetar orden de fuentes (overrides → KV → dominios → default). Evidencia completa y seguimiento en esta carpeta.
