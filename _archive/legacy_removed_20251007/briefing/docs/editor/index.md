# Editor de Fichas (beta)

Este módulo permite capturar fichas de proyecto sin escribir YAML manualmente. Completa el formulario, genera una vista previa y envía la ficha al inbox para moderación.

<!-- interno:start -->
<div class="interno">

- **Vista previa YAML**: valida la estructura antes de promoverla.
- **Envío a inbox**: crea una entrada en `/api/decisiones` lista para revisión.
- **Siguiente paso**: tras la moderación, el flujo `Promote Inbox → YAML` generará la ficha definitiva.

> ℹ️ Al enviar, la ficha queda marcada como **Pending** hasta que el equipo la apruebe en la bandeja. Los clientes externos solo verán fichas aceptadas.
>
> � El formulario solo carga con una sesión válida de Cloudflare Access; sin ella el backend devuelve 302.
>
> �🔒 El editor añade automáticamente el token secreto configurado en `RUN_EDITOR_TOKEN`, un campo honeypot `website` y una pista de origen (`origin_hint`). No elimines estas protecciones: son necesarias para la moderación y los smoke tests de ARQ-3.
>
> ♿️ Accesibilidad: los mensajes de confirmación se anuncian en un contenedor con `role="status"` y `aria-live="polite"`, y los errores usan `aria-live="assertive"` para lectores de pantalla.

## Cómo completar los campos

- **Slug**: debe coincidir con la convención `aaaa-nombre-artista` en minúsculas.
- **URLs**: solo se admiten direcciones `https://`.
- **Dimensiones**: ingresa números y selecciona la unidad. El editor convertirá los valores a centímetros.
- **Listas (imágenes, video, enlaces)**: escribe una línea por elemento usando el formato `<valor> | <detalle>`, por ejemplo `https://cdn/runart.jpg | Detalle frontal`.
- **Token de origen**: el envío incluye automáticamente `token_origen: "editor_v1"` para trazabilidad.
- **Protección anti-bots**: existe un campo oculto `website` (honeypot). Si ves un error sobre "Solicitud rechazada", asegúrate de no completarlo ni autocompletarlo.

## Cómo validar

1. Genera la vista previa YAML con el botón correspondiente.
2. Copia el contenido y guárdalo como archivo local (por ejemplo, `/tmp/demo.yaml`).
3. Ejecuta `python scripts/validate_projects.py /ruta/al/archivo.yaml` desde la raíz del briefing.
4. Confirma que la salida sea `exit 0`; si devuelve `exit 1`, revisa los mensajes de error y corrige la ficha.

[Ir al editor](editor.md)

---

## Flujo resumido
1. Completar formulario → Vista previa YAML.
2. Ajustar y validar si es necesario.
3. Enviar al inbox (JSON) para revisión.
4. Moderación → Promoción a YAML → Commit.

Consulta también la [bandeja de inbox](../inbox/index.md) para revisar envíos pendientes.

</div>
<!-- interno:end -->
