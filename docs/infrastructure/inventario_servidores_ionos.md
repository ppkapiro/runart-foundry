# Inventario de Servidores IONOS — RunArt Foundry

**Fecha de verificación:** 31 de octubre de 2025  
**Ejecutado por:** GitHub Copilot (alineación técnica)

---

## Servidor 1 (SSH Principal)

### Datos de Conexión
- **Host:** 157.173.214.43
- **Puerto:** 65002
- **Usuario:** u525829715
- **Método de autenticación:** Clave SSH (id_ed25519)
- **Alias SSH:** pepecapiro

### Estado de Conectividad
✅ **OPERATIVO** - Conexión SSH exitosa

### Información del Sistema
- **PHP:** 8.2.28 (cli) (NTS)
- **Disco:** 21 TB total, 11 TB usado (50% uso), 11 TB disponible
- **Grupo:** apache (indicador de servidor web)

### Estructura de Directorios
```
/home/u525829715/
├── domains/
│   ├── cubaverso.com/          # Dominio 1
│   └── pepecapiro.com/         # Dominio 2
├── cubaverso/                  # Proyecto Git (otro sitio)
├── backups_pepecapiro_theme/
├── .api_token                  # Token API (presente)
├── .bashrc
└── deploy_cubaverso.sh         # Script de deploy
```

### Sitios Web Identificados
1. **cubaverso.com** - Dominio configurado en `/domains/cubaverso.com/`
2. **pepecapiro.com** - Dominio configurado en `/domains/pepecapiro.com/`

**Observación:** No se detectó instalación de WordPress para RunArt Foundry en este servidor.

### Entorno Asignado
**❓ INDEFINIDO**

**Análisis:**
- Este servidor NO contiene el sitio RunArt Foundry
- Contiene proyectos "Cubaverso" y "Pepecapiro"
- NO es el servidor de staging ni producción de RunArt Foundry
- Posiblemente es un servidor de desarrollo personal o proyectos paralelos

**Conclusión:** Este servidor SSH (`u525829715@157.173.214.43`) **NO corresponde a RunArt Foundry**.

---

## Servidor 2 (SFTP/Mirror)

### Datos de Conexión
- **Host:** access958591985.webspace-data.io
- **Puerto:** 22
- **Usuario:** u111876951
- **Método de autenticación:** Requerido (no configurado)

### Estado de Conectividad
⚠️ **REQUIERE CONFIGURACIÓN**

**Error al conectar:**
```
u111876951@access958591985.webspace-data.io: Permission denied (publickey,password).
Connection closed.
```

### Diagnóstico
- La clave SSH actual (`id_ed25519`) NO está autorizada en este servidor
- Requiere:
  - Instalación de clave pública en el servidor, O
  - Autenticación con contraseña

### Entorno Asignado
**🔍 POSIBLEMENTE STAGING/PRODUCCIÓN RUNART FOUNDRY**

**Análisis:**
- Usuario `u111876951` mencionado en `.env` para conexión SFTP
- Variables `.env` asocian este host con sincronización de mirror/snapshots
- Probablemente es el servidor donde está alojado **runartfoundry.com**

**Acción requerida:**
1. Obtener contraseña del usuario `u111876951`, O
2. Instalar clave SSH pública en este servidor:
   ```bash
   ssh-copy-id -p 22 u111876951@access958591985.webspace-data.io
   ```

---

## Servidor 3 (Base de Datos)

### Datos de Conexión (desde .env)
- **Host:** db5012671937.hosting-data.io
- **Puerto:** 3306
- **Usuario:** dbu2309272
- **Base de datos:** dbs10646556

### Estado de Conectividad
⚠️ **NO VERIFICADO** (requiere credenciales)

### Entorno Asignado
**Asociado a Servidor 2 (SFTP)** - Probablemente staging/producción RunArt Foundry

---

## Resumen Ejecutivo

| Servidor | Usuario | Host | Estado | Proyecto | Entorno |
|----------|---------|------|--------|----------|---------|
| **SSH Principal** | u525829715 | 157.173.214.43:65002 | ✅ Conectado | Cubaverso/Pepecapiro | N/A (no RunArt) |
| **SFTP/Web** | u111876951 | access958591985... | ⚠️ Requiere config | **RunArt Foundry** | Staging/Prod |
| **Base de Datos** | dbu2309272 | db5012671937... | ⚠️ No verificado | **RunArt Foundry** | Staging/Prod |

### Hallazgos Críticos

1. **Servidor SSH detectado NO es RunArt Foundry:**
   - El servidor `u525829715@157.173.214.43` (alias "pepecapiro") contiene proyectos personales
   - **NO contiene** instalación de WordPress de RunArt Foundry

2. **Servidor real de RunArt Foundry:**
   - Probablemente es `u111876951@access958591985.webspace-data.io`
   - Actualmente **inaccesible** por falta de autenticación SSH

3. **Inconsistencia en documentación:**
   - La documentación del proyecto asume que el servidor SSH principal es para RunArt
   - En realidad, el servidor SSH principal es para otros proyectos

### Acciones Inmediatas Requeridas

1. **Configurar acceso SSH al servidor RunArt Foundry:**
   ```bash
   ssh-copy-id -p 22 u111876951@access958591985.webspace-data.io
   ```

2. **Actualizar ~/.ssh/config** con entrada para RunArt Foundry:
   ```
   Host runart-ionos
     HostName access958591985.webspace-data.io
     Port 22
     User u111876951
     IdentityFile ~/.ssh/id_ed25519
     IdentitiesOnly yes
     ServerAliveInterval 30
     ServerAliveCountMax 4
   ```

3. **Verificar instalación WordPress en servidor correcto:**
   ```bash
   ssh runart-ionos "find /home/u111876951 -maxdepth 3 -name 'wp-config.php'"
   ```

4. **Documentar staging vs. producción:**
   - Una vez conectado, identificar si `u111876951` es staging o producción
   - Buscar segundo servidor IONOS si existen entornos separados

---

## Notas Adicionales

**Variables de entorno actuales (.env):**
```bash
SFTP_HOST=access958591985.webspace-data.io
SFTP_PORT=22
SFTP_USER=u111876951
```

**Variables de DB (.env):**
```bash
DB_HOST=db5012671937.hosting-data.io
DB_PORT=3306
DB_USER=dbu2309272
DB_NAME=dbs10646556
```

**Conclusión:** La conexión SSH funcionando (`pepecapiro`) NO es el servidor objetivo de RunArt Foundry. Se requiere configuración adicional para acceder al servidor correcto.

---

_Documento generado automáticamente durante alineación técnica - 31 de octubre de 2025_
