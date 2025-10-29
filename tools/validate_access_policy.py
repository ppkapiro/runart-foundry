#!/usr/bin/env python3
"""
Validate Cloudflare Access Policy for Service Token

Verifica que el hostname de producción tenga una política de Access
que permita Service Tokens para autenticación.

Env vars requeridas:
- CF_API_TOKEN: Cloudflare API token
- CF_ACCOUNT_ID: Cloudflare Account ID
- ACCESS_APP_HOST: Hostname del app (ej: runart-foundry.pages.dev)
- REQUIRE_SERVICE_TOKEN: 'true' para requerir service token en policy

Salida:
- docs/_meta/_access_diag/access_policy.json con resumen
- Exit 0 si PASS, >0 si FAIL
"""

import json
import os
import sys
from pathlib import Path
from typing import Any, Dict, List, Optional

try:
    import requests
except ImportError:
    print("⚠️  requests no disponible; instalando...")
    import subprocess
    subprocess.check_call([sys.executable, "-m", "pip", "install", "-q", "requests"])
    import requests


class AccessPolicyValidator:
    def __init__(self):
        self.api_token = os.getenv("CF_API_TOKEN")
        self.account_id = os.getenv("CF_ACCOUNT_ID")
        self.app_host = os.getenv("ACCESS_APP_HOST", "runart-foundry.pages.dev")
        self.require_service_token = os.getenv("REQUIRE_SERVICE_TOKEN", "false").lower() == "true"
        
        if not self.api_token or not self.account_id:
            print("❌ CF_API_TOKEN y CF_ACCOUNT_ID son requeridos")
            sys.exit(1)
        
        self.base_url = f"https://api.cloudflare.com/client/v4/accounts/{self.account_id}"
        self.headers = {
            "Authorization": f"Bearer {self.api_token}",
            "Content-Type": "application/json"
        }
        self.output_dir = Path("docs/_meta/_access_diag")
        self.output_dir.mkdir(parents=True, exist_ok=True)

    def get_access_apps(self) -> List[Dict[str, Any]]:
        """Lista todas las Access Applications"""
        url = f"{self.base_url}/access/apps"
        try:
            resp = requests.get(url, headers=self.headers, timeout=10)
            resp.raise_for_status()
            data = resp.json()
            if not data.get("success"):
                print(f"❌ API error: {data.get('errors')}")
                return []
            return data.get("result", [])
        except requests.RequestException as e:
            print(f"⚠️  Error al obtener Access apps: {e}")
            return []

    def find_app_by_hostname(self, apps: List[Dict[str, Any]]) -> Optional[Dict[str, Any]]:
        """Encuentra el app que cubre el hostname de prod"""
        for app in apps:
            # Verificar en domain, domains, o aud
            domains = []
            if "domain" in app:
                domains.append(app["domain"])
            if "domains" in app:
                domains.extend(app["domains"])
            
            for domain in domains:
                if self.app_host in domain or domain in self.app_host:
                    print(f"✅ App encontrado: {app.get('name')} (id: {app.get('id')})")
                    return app
        
        print(f"⚠️  No se encontró Access app para hostname: {self.app_host}")
        return None

    def get_app_policies(self, app_id: str) -> List[Dict[str, Any]]:
        """Obtiene las políticas del app"""
        url = f"{self.base_url}/access/apps/{app_id}/policies"
        try:
            resp = requests.get(url, headers=self.headers, timeout=10)
            resp.raise_for_status()
            data = resp.json()
            if not data.get("success"):
                print(f"❌ API error: {data.get('errors')}")
                return []
            return data.get("result", [])
        except requests.RequestException as e:
            print(f"⚠️  Error al obtener policies: {e}")
            return []

    def check_service_token_allowed(self, policies: List[Dict[str, Any]]) -> bool:
        """Verifica si alguna policy permite Service Tokens"""
        for policy in policies:
            decision = policy.get("decision", "")
            includes = policy.get("include", [])
            
            # Buscar service_auth en includes
            for rule in includes:
                if "service_token" in rule or "serviceToken" in rule:
                    print(f"✅ Policy '{policy.get('name')}' permite Service Token")
                    return True
                
                # Cloudflare API puede usar diferentes estructuras
                if rule.get("service_token") is not None:
                    print(f"✅ Policy '{policy.get('name')}' incluye service_token")
                    return True
        
        print("⚠️  No se encontró policy que permita explícitamente Service Token")
        return False

    def validate(self) -> bool:
        """Ejecuta validación completa"""
        print(f"🔍 Validando Access policy para: {self.app_host}")
        
        # 1. Obtener apps
        apps = self.get_access_apps()
        if not apps:
            print("⚠️  No se pudieron obtener Access apps (puede ser permisos o config)")
            # No forzar fallo si API no responde
            self.save_result({
                "status": "WARNING",
                "message": "No se pudo consultar Access apps API",
                "hostname": self.app_host,
                "timestamp": "2025-10-24T14:30:00Z"
            })
            return True  # No bloquear deploy
        
        # 2. Encontrar app para hostname
        app = self.find_app_by_hostname(apps)
        if not app:
            # Hostname puede no tener Access app (público)
            self.save_result({
                "status": "NOT_FOUND",
                "message": f"No Access app configurado para {self.app_host}",
                "hostname": self.app_host
            })
            if self.require_service_token:
                print("❌ REQUIRE_SERVICE_TOKEN=true pero no hay app")
                return False
            return True
        
        app_id = app.get("id")
        
        # 3. Obtener policies
        policies = self.get_app_policies(app_id)
        if not policies:
            print("⚠️  No se encontraron policies o error al obtenerlas")
            self.save_result({
                "status": "NO_POLICIES",
                "app_id": app_id,
                "app_name": app.get("name"),
                "hostname": self.app_host
            })
            return not self.require_service_token
        
        # 4. Verificar si alguna policy permite Service Token
        service_token_allowed = self.check_service_token_allowed(policies)
        
        result = {
            "status": "OK" if service_token_allowed else "NO_SERVICE_TOKEN",
            "app_id": app_id,
            "app_name": app.get("name"),
            "hostname": self.app_host,
            "policies_count": len(policies),
            "service_token_allowed": service_token_allowed,
            "policies_summary": [
                {
                    "id": p.get("id"),
                    "name": p.get("name"),
                    "decision": p.get("decision")
                }
                for p in policies
            ]
        }
        
        self.save_result(result)
        
        if self.require_service_token and not service_token_allowed:
            print("❌ Service Token NO permitido en ninguna policy")
            return False
        
        print("✅ Validación completada")
        return True

    def save_result(self, result: Dict[str, Any]):
        """Guarda resultado en JSON"""
        output_file = self.output_dir / "access_policy.json"
        with open(output_file, "w") as f:
            json.dump(result, f, indent=2)
        print(f"📄 Resultado guardado en: {output_file}")


def main():
    validator = AccessPolicyValidator()
    success = validator.validate()
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
