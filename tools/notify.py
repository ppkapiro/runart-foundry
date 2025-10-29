#!/usr/bin/env python3
"""
Unified Notification Tool for Slack/Discord
Sprint 3 - Hardening + Observabilidad

Envía notificaciones a Slack o Discord webhooks con manejo de errores robusto.
No falla el job si la notificación no se puede enviar.

Usage:
    python3 tools/notify.py --channel=slack --title="Build Failed" --message="..." --level=ERROR
    python3 tools/notify.py --channel=discord --title="Drift Detected" --message="..." --level=WARN

Exit codes:
- 0: Notificación enviada exitosamente
- 1: No hay webhook configurado (no es error crítico)
- 2: Error enviando notificación (no crítico, job continúa)
"""

import os
import sys
import json
import argparse
from urllib import request, error
from datetime import datetime, timezone
from typing import Optional


def log(message: str, level: str = "INFO") -> None:
    """Logger simple con timestamp UTC."""
    timestamp = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    prefix = {
        "INFO": "ℹ️",
        "WARN": "⚠️",
        "ERROR": "❌",
        "SUCCESS": "✅"
    }.get(level, "•")
    print(f"{prefix} [{timestamp}] {message}", file=sys.stderr)


def get_webhook_url(channel: str) -> Optional[str]:
    """Obtiene URL del webhook desde variables de entorno."""
    env_var = f"{channel.upper()}_WEBHOOK"
    url = os.getenv(env_var)
    
    if not url:
        log(f"Webhook no configurado: {env_var}", "WARN")
        return None
    
    log(f"Webhook encontrado: {env_var}", "INFO")
    return url


def format_slack_payload(title: str, message: str, level: str, repo: str, sha: str, job_url: str) -> dict:
    """Formatea payload para Slack webhook."""
    color_map = {
        "INFO": "#36a64f",      # Verde
        "WARN": "#ff9900",      # Naranja
        "ERROR": "#ff0000"      # Rojo
    }
    
    emoji_map = {
        "INFO": ":white_check_mark:",
        "WARN": ":warning:",
        "ERROR": ":x:"
    }
    
    return {
        "attachments": [
            {
                "color": color_map.get(level, "#cccccc"),
                "title": f"{emoji_map.get(level, ':bell:')} {title}",
                "text": message,
                "fields": [
                    {
                        "title": "Repository",
                        "value": repo,
                        "short": True
                    },
                    {
                        "title": "Commit",
                        "value": f"`{sha}`",
                        "short": True
                    }
                ],
                "actions": [
                    {
                        "type": "button",
                        "text": "View Logs",
                        "url": job_url
                    }
                ],
                "footer": "GitHub Actions",
                "ts": int(datetime.now(timezone.utc).timestamp())
            }
        ]
    }


def format_discord_payload(title: str, message: str, level: str, repo: str, sha: str, job_url: str) -> dict:
    """Formatea payload para Discord webhook."""
    color_map = {
        "INFO": 3066993,   # Verde (0x2ecc71)
        "WARN": 16750848,  # Naranja (0xffa500)
        "ERROR": 15158332  # Rojo (0xe74c3c)
    }
    
    emoji_map = {
        "INFO": "✅",
        "WARN": "⚠️",
        "ERROR": "❌"
    }
    
    return {
        "embeds": [
            {
                "title": f"{emoji_map.get(level, '🔔')} {title}",
                "description": message[:900],  # Discord tiene límite de 2000 chars
                "color": color_map.get(level, 9807270),
                "fields": [
                    {
                        "name": "Repository",
                        "value": repo,
                        "inline": True
                    },
                    {
                        "name": "Commit",
                        "value": f"`{sha}`",
                        "inline": True
                    }
                ],
                "footer": {
                    "text": "GitHub Actions"
                },
                "timestamp": datetime.now(timezone.utc).isoformat(),
                "url": job_url
            }
        ]
    }


def send_notification(
    channel: str,
    title: str,
    message: str,
    level: str,
    repo: str = "unknown/repo",
    sha: str = "unknown",
    job_url: str = "https://github.com"
) -> bool:
    """Envía notificación al canal especificado."""
    # Obtener webhook URL
    webhook_url = get_webhook_url(channel)
    if not webhook_url:
        log(f"Saltando notificación: webhook {channel} no configurado", "WARN")
        return False
    
    # Formatear payload
    if channel == "slack":
        payload = format_slack_payload(title, message, level, repo, sha, job_url)
    elif channel == "discord":
        payload = format_discord_payload(title, message, level, repo, sha, job_url)
    else:
        log(f"Canal no soportado: {channel}", "ERROR")
        return False
    
    # Enviar POST request
    try:
        data = json.dumps(payload).encode('utf-8')
        req = request.Request(
            webhook_url,
            data=data,
            headers={'Content-Type': 'application/json'}
        )
        
        with request.urlopen(req, timeout=10) as response:
            if response.status in (200, 204):
                log(f"✓ Notificación {channel} enviada exitosamente", "SUCCESS")
                return True
            else:
                log(f"Respuesta inesperada del webhook: {response.status}", "WARN")
                return False
    except error.URLError as e:
        log(f"Error enviando notificación {channel}: {e}", "ERROR")
        return False
    except Exception as e:
        log(f"Error inesperado: {e}", "ERROR")
        return False


def main() -> int:
    """Entry point."""
    parser = argparse.ArgumentParser(description="Enviar notificaciones a Slack/Discord")
    parser.add_argument(
        "--channel",
        required=True,
        choices=["slack", "discord"],
        help="Canal de notificación"
    )
    parser.add_argument(
        "--title",
        required=True,
        help="Título de la notificación"
    )
    parser.add_argument(
        "--message",
        required=True,
        help="Mensaje de la notificación"
    )
    parser.add_argument(
        "--level",
        default="INFO",
        choices=["INFO", "WARN", "ERROR"],
        help="Nivel de severidad"
    )
    parser.add_argument(
        "--repo",
        default=os.getenv("GITHUB_REPOSITORY", "unknown/repo"),
        help="Nombre del repositorio"
    )
    parser.add_argument(
        "--sha",
        default=os.getenv("GITHUB_SHA", "unknown")[:7],
        help="SHA del commit (corto)"
    )
    parser.add_argument(
        "--job-url",
        default=os.getenv(
            "GITHUB_SERVER_URL",
            "https://github.com"
        ) + "/" + os.getenv("GITHUB_REPOSITORY", "") + "/actions/runs/" + os.getenv("GITHUB_RUN_ID", ""),
        help="URL del job en GitHub Actions"
    )
    
    args = parser.parse_args()
    
    # Enviar notificación
    success = send_notification(
        channel=args.channel,
        title=args.title,
        message=args.message,
        level=args.level,
        repo=args.repo,
        sha=args.sha,
        job_url=args.job_url
    )
    
    # Exit codes: 0=success, 1=webhook no configurado, 2=error
    if success:
        return 0
    elif not get_webhook_url(args.channel):
        return 1
    else:
        return 2


if __name__ == "__main__":
    sys.exit(main())
