# Permisos finos por rol

La Etapa 3 introduce un modelo de control granular basado en los roles emitidos por Cloudflare Access. Esta guía resume cómo se resuelve el rol, cómo se valida en los Workers y cómo marcar contenido interno en la documentación.

## Resolución de rol (Workers)

La librería `functions/_lib/roles.js` {.interno} centraliza la lógica para determinar el rol efectivo a partir del email autenticado:

- **admin** → el correo aparece en `ACCESS_ADMINS`.
- **equipo** → el correo está en `ACCESS_EQUIPO_EMAILS` o comparte dominio con `ACCESS_EQUIPO_DOMAINS`.
- **cliente** → cualquier otro correo autenticado (o declarado en `ACCESS_CLIENT_EMAILS`).
- **visitante** → no hay sesión.

La utilidad `resolveRole(email, env)` evita duplicar esta lógica en cada Worker y respeta overrides opcionales (listas por correo o dominio).

## Guardias reutilizables

`functions/_lib/guard.js` {.interno} expone `guardRequest(context, allowedRoles)` junto con atajos `requireTeam` y `requireAdmin`. Estas funciones devuelven el email/rol válido o un `Response` 403 cuando no se cumple el acceso.

```javascript
import { requireTeam } from '../_lib/guard';

export const onRequestGet = async (context) => {
  const { email, role, error } = requireTeam(context);
  if (error) return error;

  // ... lógica sólo para admin/equipo ...
};
```

Cuando la variable `ACCESS_DEV_OVERRIDE=1`, se acepta el encabezado `X-Runart-Dev-Role` para pruebas locales.

## Front-matter `access` en la documentación

Las páginas de MkDocs pueden declarar el campo `access` en el front-matter:

```yaml
---
title: Exportaciones (MF)
access:
  - admin
  - equipo
---
```

El script `scripts/mark_internal.py` verifica, antes de cada `make build`/`make serve`, que todas las páginas con `access` restringido incluyan la clase `.interno` en su contenido y genera `docs/assets/access_map.json` con el mapeo resultante.

Si falta la clase `.interno`, el build se detiene con un error:

```text
[mark_internal] Archivos sin marca .interno pese a requerir acceso interno:
  - exports/index.md
```

## Clase `.interno` en la UI

La hoja `assets/extra.css` oculta cualquier elemento `.interno` cuando el rol activo (o el modo “Ver como”) es cliente. Gracias al mapa generado por `mark_internal.py`, los componentes del sitio pueden reaccionar según el nivel de acceso disponible.

## Checklist para nuevas páginas

1. Añade `access:` en el front-matter (`admin`, `equipo`, `cliente` o `public`).
2. Marca la sección principal con `.interno` si no es visible para clientes.
3. Ejecuta `make build` para validar.
4. Documenta el cambio en esta página si introduces un nuevo patrón.
