# Entornos (Local / Preview / Producción)

## Flujo de despliegue
1. **Local** → `make serve` levanta MkDocs con `RUNART_ENV` implícito en `local`. El banner muestra **LOCAL**.
2. **Preview** → Cada Pull Request dispara un deploy en Cloudflare Pages. El banner muestra **PREVIEW** y `data-env="preview"`.
3. **Producción** → Merge a `main` publica en el dominio principal con `RUNART_ENV=prod`. No se muestra banner y solo queda `data-env="prod"`.

## Access
- **Producción:** acceso autorizado para cliente, equipo y administradores vía Cloudflare Access.
- **Preview:** restringido a administradores y equipo para QA previo a producción.
- **Local:** uso individual del equipo; no requiere Access.

## Variables de entorno
- `RUNART_ENV=prod` → Deploys de producción.
- `RUNART_ENV=preview` → Deploys automáticos de Pull Request.
- Sin definir (`make serve`, `wrangler dev`) → se toma `local` como valor por defecto.

Configura la variable en **Cloudflare Pages → Settings → Environment variables** tanto para Production como para Preview. Replica el mismo valor en **Functions → Settings** cuando uses bindings.

## Identificación visual
- El `<html>` recibe `data-env` con el valor resuelto.
- El script `assets/env-flag.js` pinta un banner inferior amarillo (LOCAL) o coral (PREVIEW).
- Si `data-env="prod"`, el banner se elimina automáticamente para no interferir con el sitio público.

## API `/api/whoami`
El endpoint responde un objeto `{ email, role, env, ts }`. El campo `env` refleja el valor actual de `RUNART_ENV` (o `local` si no está configurado). Úsalo para depurar integraciones o mostrar el entorno en otras capas.

- En **local**, MkDocs expone un stub estático en `docs/api/whoami` que devuelve `env: "local"` para permitir `make test-env` sin Workers.

## Checklist
- [ ] `make serve` → Verifica banner LOCAL y `data-env="local"`.
- [ ] Pull Request → Abre la URL de preview, confirma banner PREVIEW y `data-env="preview"`.
- [ ] Producción → Tras el merge, comprueba que no hay banner y que `data-env="prod"` siga presente.
- [ ] `/api/whoami` → En cada entorno comprueba que el JSON incluye el campo `env` esperado.

## Validación automatizada
1. Arranca el servidor local en una terminal:
	```bash
	make serve
	```
2. En otra terminal ejecuta la validación local:
	```bash
	make test-env
	```
3. Para una preview de Cloudflare Pages (requiere URL previa):
	```bash
	PREVIEW_URL=https://<preview>.pages.dev make test-env-preview
	```
4. Para producción:
	```bash
	PROD_URL=https://<dominio>.com make test-env-prod
	```

El detalle de cada ejecución se guarda en `audits/env_check.log`, sobrescribiéndose en cada corrida.
