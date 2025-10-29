#!/usr/bin/env bash
#
# NOTA: Este script es de REFERENCIA. No se autoejecuta; requiere acción manual del OWNER.
# Propósito: actualizar el remoto `origin` al remoto canónico para evitar avisos de reubicación.
#
# Recomendaciones previas:
# - Revise los remotos actuales.
# - Asegure que no hay commits locales pendientes de push.
# - Valide el branch actual (debe ser "main" salvo política distinta).
#
# Comandos sugeridos (copiar/pegar en su terminal):
#
# Ver remotos actuales
# git remote -v
#
# Actualizar origin al canónico (RunArtFoundry)
# git remote set-url origin git@github.com:RunArtFoundry/runart-foundry.git
#
# Verificar cambio
# git remote -v
#
# (Opcional) Probar push en seco
# git push --dry-run origin main
#
# (Opcional) Si mantiene un remoto upstream, verifíquelo
# git remote get-url upstream
