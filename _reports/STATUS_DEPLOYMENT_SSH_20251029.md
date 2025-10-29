# Estado Deployment SSH — IONOS Staging

**Fecha:** 2025-10-29  
**Script Loader:** tools/staging_env_loader.sh  
**Archivo Config:** ~/.runart_staging_env

---

## Resumen

Validación de variables de entorno y capacidad de conexión SSH al servidor staging de IONOS.

**Estado:** ⚠ PARCIAL — Variables configuradas, conexión SSH bloqueada por autenticación.

---

## Validación de Variables

### Variables Configuradas ✅

| Variable | Estado | Valor (enmascarado) |
|----------|--------|---------------------|
| IONOS_SSH_HOST | ✅ OK | access958591985.webspace-data.io |
| IONOS_SSH_USER | ✅ OK | u11876951 |
| SSH_PORT | ✅ OK | 22 |
| STAGING_WP_PATH | ✅ OK | /html/staging |
| IONOS_SSH_PASS | ✅ Configurado | ********* (no funcional) |
| STAGING_URL | ✅ OK | https://staging.runartfoundry.com |
| WP_USER | ✅ OK | runart-admin |
| WP_APP_PASSWORD | ✅ OK | ****************** |
| WP_REST_URL | ✅ OK | https://staging.runartfoundry.com/wp-json |

### Variables Faltantes ⚠

| Variable | Requerido | Solución |
|----------|-----------|----------|
| IONOS_SSH_KEY | Recomendado | Generar y configurar SSH key |

---

## Prueba de Conexión SSH

### Intento 1: Password Auth

```bash
ssh -p 22 u11876951@access958591985.webspace-data.io "echo 'SSH OK'"
```

**Resultado:** ❌ Permission denied

**Diagnóstico:**
- Password configurado en ~/.runart_staging_env no válido
- Posibles causas:
  - Password cambió en servidor
  - Autenticación por password deshabilitada en IONOS
  - Requiere SSH key exclusivamente

### Intento 2: SSH Key (pendiente)

**Estado:** NO EJECUTADO — Key no configurada aún

**Comando requerido:**
```bash
ssh-keygen -t ed25519 -f ~/.ssh/ionos_runart -C "runart-staging-deploy"
ssh-copy-id -i ~/.ssh/ionos_runart.pub u11876951@access958591985.webspace-data.io
```

---

## Latencia y Conectividad

### Ping Test

```bash
ping -c 4 access958591985.webspace-data.io
```

**Resultado esperado:** ~50-150ms (Europa → América)

### DNS Resolution

```bash
nslookup access958591985.webspace-data.io
```

**Resultado esperado:** Resuelve a IP pública de IONOS data center

---

## Fingerprint SSH

**Estado:** Pendiente de primera conexión

**Formato esperado:**
```
ED25519 key fingerprint is SHA256:XXXX...XXXX
```

**Nota:** Fingerprint se registrará en ~/.ssh/known_hosts al primer ssh exitoso.

---

## Capacidades del Loader Script

### tools/staging_env_loader.sh

✅ Lee variables desde ~/.runart_staging_env  
✅ Valida presencia de variables requeridas  
✅ Verifica permisos del archivo config (600)  
✅ Valida permisos de SSH key (si existe)  
✅ Intenta conexión SSH de prueba  
✅ Muestra guía de setup si faltan variables  
✅ Retorna exit codes específicos (0=OK, 1=archivo no encontrado, 2=variables faltantes, 3=SSH falla)

### Uso

```bash
# Cargar variables en sesión actual
source tools/staging_env_loader.sh

# Variables disponibles tras carga exitosa:
echo $IONOS_SSH_HOST
echo $STAGING_WP_PATH
```

---

## Permisos y Seguridad

### Archivo de Configuración

```bash
$ ls -la ~/.runart_staging_env
-rw------- 1 pepe pepe 532 Oct 29 15:45 /home/pepe/.runart_staging_env
```

**Permisos:** 600 ✅  
**Owner:** pepe:pepe ✅

### SSH Key (pendiente)

**Ubicación:** ~/.ssh/ionos_runart  
**Permisos requeridos:** 600  
**Public key:** ~/.ssh/ionos_runart.pub (644)

---

## Checklist de Setup

- [x] Archivo ~/.runart_staging_env creado
- [x] Variables IONOS_SSH_HOST, IONOS_SSH_USER, SSH_PORT configuradas
- [x] Variable STAGING_WP_PATH configurada
- [x] Permisos 600 en archivo config
- [ ] SSH Key generada
- [ ] SSH Key copiada al servidor IONOS
- [ ] Variable IONOS_SSH_KEY configurada
- [ ] Variable IONOS_SSH_PASS removida (tras key funcional)
- [ ] Conexión SSH exitosa
- [ ] Verificación WP-CLI en servidor

---

## Logs de Ejecución

### 2025-10-29T15:52:00-04:00

```
ℹ Cargando configuración de Staging desde: /home/pepe/.runart_staging_env
ℹ Probando conexión SSH a u11876951@access958591985.webspace-data.io:22...
✗ ERROR: No se pudo establecer conexión SSH
ℹ Verifica: host, usuario, clave SSH, puerto y permisos
Exit code: 3
```

**Análisis:** Password auth falla; requiere SSH key.

---

## Próximos Pasos

### Inmediatos

1. **Generar SSH Key:**
   ```bash
   ssh-keygen -t ed25519 -f ~/.ssh/ionos_runart -C "runart-staging-deploy"
   chmod 600 ~/.ssh/ionos_runart
   ```

2. **Copiar Key al Servidor:**
   - Opción A (ssh-copy-id):
     ```bash
     ssh-copy-id -i ~/.ssh/ionos_runart.pub u11876951@access958591985.webspace-data.io
     ```
   - Opción B (manual vía panel IONOS):
     - Copiar contenido de ~/.ssh/ionos_runart.pub
     - Añadir en IONOS Panel → SSH Keys

3. **Actualizar Config:**
   ```bash
   # Añadir a ~/.runart_staging_env
   export IONOS_SSH_KEY="$HOME/.ssh/ionos_runart"
   
   # Comentar o remover:
   # export IONOS_SSH_PASS="..."
   ```

4. **Revalidar:**
   ```bash
   source tools/staging_env_loader.sh
   # Debe mostrar: ✓ Configuración de Staging validada correctamente
   ```

### Para Deploy

5. Ejecutar exploración completa con SSH funcional
6. Validar estructura de directorios remotos
7. Verificar WP-CLI availability
8. Ejecutar deploy de prueba (dry-run)

---

## Referencias

- Loader Script: tools/staging_env_loader.sh
- Exploración: _reports/IONOS_STAGING_EXPLORATION_20251029.md
- Deploy Guide: docs/Deployment_Master.md
- Reporte anterior: _reports/STATUS_DEPLOYMENT_SSH_20251028.md

---

**Conclusión:** Configuración de variables completa. Se requiere setup de SSH key para desbloquear acceso remoto y continuar con deployment pipeline.
