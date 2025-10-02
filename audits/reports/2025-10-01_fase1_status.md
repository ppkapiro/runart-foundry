# Fase 1 — Chequeos iniciales (sin descargas)
Fecha: 2025-10-01

## Entorno
- Ruta proyecto: /home/pepe/work/runartfoundry
- SNAP_ROOT: /home/pepe/work/runartfoundry/mirror/raw/2025-10-01
- Herramientas: lftp, mariadb-client, wget, tree (instaladas)

## SFTP
- Host: access958591985.webspace-data.io  User: u111876951  Port: 22
- Log: /home/pepe/work/runartfoundry/audits/2025-10-01_sftp_check.log
- Observación: Si el batch falló, probar sftp interactivo y/o configurar clave SSH.

## DB
- Host: db5012671937.hosting-data.io:3306  User: dbu2309272  DB: dbs10646556
- Log: /home/pepe/work/runartfoundry/audits/2025-10-01_db_check.log
- Observación: La verificación no usa password; en el siguiente paso se pedirá de forma segura si hace falta.

## Próximo paso sugerido
- Configurar acceso por clave SSH (ssh-agent) y realizar el primer snapshot de archivos (wp-content) hacia: /home/pepe/work/runartfoundry/mirror/raw/2025-10-01/wp-content/
- Decidir método de export DB: mysqldump por TCP o export desde phpMyAdmin.
