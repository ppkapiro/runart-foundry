# Rollback canario — Evidencia 2025-10-14T16:26Z

| Paso | Resultado | Notas |
| --- | --- | --- |
| ROLE_RESOLVER_SOURCE=lib aplicado en wrangler.toml | ✅ | Valor anterior (`"utils"`) documentado en comentario |
| Despliegue overlay preview2 | ⚠️ | `wrangler pages deploy` rechaza `--env preview2`; requiere flujo manual con `wrangler.preview2.toml` o Actions |
| Smokes preview2 (lib) | ❌ | `/api/whoami` sigue devolviendo `admin`; rollback aún no desplegado |

Archivo `smokes.txt` contiene la salida íntegra de la corrida fallida.
