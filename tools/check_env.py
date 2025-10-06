#!/usr/bin/env python3
"""Environment validation CLI for RUNART Briefing."""
from __future__ import annotations

import argparse
import json
import sys
import textwrap
from datetime import datetime, timezone
from pathlib import Path
from typing import Dict, List, Tuple, Optional, cast
from urllib.error import URLError, HTTPError
from urllib.parse import urljoin
from urllib.request import Request, urlopen

EXIT_CODES = {
    "ok": 0,
    "usage": 1,
    "config_fail": 2,
    "http_fail": 3,
    "env_mismatch": 4,
}

EXPECTED_ENVS = {"local", "preview", "prod"}
TIMEOUT_SECONDS = 5
LOG_RELATIVE_PATH = Path("audits/env_check.log")


def build_arg_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Validate RUNART Briefing environment configuration and HTTP responses.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=textwrap.dedent(
            """
                        Examples:
                            python tools/check_env.py --mode=config
                            python tools/check_env.py --mode=http --base-url http://127.0.0.1:8000 --expect-env local
            """
        ),
    )
    parser.add_argument(
        "--mode",
        required=True,
        choices=["config", "http"],
        help="Validation mode: config (static checks) or http (runtime checks).",
    )
    parser.add_argument(
        "--base-url",
        help="Base URL for HTTP checks (required in http mode). Example: http://127.0.0.1:8000",
    )
    parser.add_argument(
        "--expect-env",
        help="Expected environment value when using http mode (local|preview|prod).",
    )
    return parser


def repository_root() -> Path:
    return Path(__file__).resolve().parent.parent


def ensure_log_path(root: Path) -> Path:
    log_path = root / LOG_RELATIVE_PATH
    log_path.parent.mkdir(parents=True, exist_ok=True)
    return log_path


def write_log(log_path: Path, lines: List[str]) -> None:
    log_path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def config_checks(root: Path) -> Tuple[bool, List[str]]:
    lines: List[str] = ["[CONFIG]"]

    mkdocs_path = root / "apps" / "briefing" / "mkdocs.yml"
    extra_css_path = root / "apps" / "briefing" / "docs" / "assets" / "extra.css"

    checks: Dict[str, bool] = {}
    try:
        mkdocs_text = mkdocs_path.read_text(encoding="utf-8")
    except FileNotFoundError:
        mkdocs_text = ""
    checks["mkdocs: extra_javascript has assets/env-flag.js"] = (
        "extra_javascript" in mkdocs_text and "assets/env-flag.js" in mkdocs_text
    )
    checks["mkdocs: nav includes Operación → Entornos"] = (
        "Operación" in mkdocs_text
        and (
            "Entornos: internal/briefing_system/ops/environments.md" in mkdocs_text
            or "Entornos: ops/environments.md" in mkdocs_text
        )
    )

    try:
        extra_css_text = extra_css_path.read_text(encoding="utf-8")
    except FileNotFoundError:
        extra_css_text = ""
    checks["extra.css: contains /* runart:env-banner */"] = "/* runart:env-banner */" in extra_css_text

    all_ok = True
    for label, ok in checks.items():
        status = "PASS" if ok else "FAIL"
        lines.append(f"- {label}: {status}")
        if not ok:
            all_ok = False

    if not checks:
        all_ok = False
        lines.append("- No configuration checks executed (paths missing)")

    return all_ok, lines


def http_checks(base_url: str, expect_env: str) -> Tuple[bool, List[str], Optional[str], Optional[int], Optional[int]]:
    lines: List[str] = ["[HTTP]"]
    expect_env_norm = expect_env.lower().strip()
    base = base_url.rstrip("/") or base_url
    home_url = base or base_url
    api_url = urljoin(base + "/", "api/whoami")

    home_status: Optional[int] = None
    api_status: Optional[int] = None
    received_env: Optional[str] = None

    headers = {"User-Agent": "RunartEnvChecker/1.0"}

    # GET /
    try:
        with urlopen(Request(home_url, headers=headers), timeout=TIMEOUT_SECONDS) as response:
            home_status = response.status
            lines.append(f"- GET / -> HTTP {home_status}")
    except HTTPError as err:
        home_status = err.code
        lines.append(f"- GET / -> HTTP {home_status} (HTTP error)")
    except URLError as err:
        lines.append(f"- GET / -> ERROR ({err.reason})")
        return False, lines, None, home_status, api_status

    if home_status is None or home_status >= 400:
        return False, lines, None, home_status, api_status

    # GET /api/whoami
    try:
        with urlopen(Request(api_url, headers=headers), timeout=TIMEOUT_SECONDS) as response:
            api_status = response.status
            payload = response.read().decode("utf-8")
            lines.append(f"- GET /api/whoami -> HTTP {api_status}")
    except HTTPError as err:
        api_status = err.code
        lines.append(f"- GET /api/whoami -> HTTP {api_status} (HTTP error)")
        return False, lines, None, home_status, api_status
    except URLError as err:
        lines.append(f"- GET /api/whoami -> ERROR ({err.reason})")
        return False, lines, None, home_status, api_status

    if api_status is None or api_status >= 400:
        return False, lines, None, home_status, api_status

    try:
        data = json.loads(payload)
    except json.JSONDecodeError:
        lines.append("- JSON parse error: invalid response")
        return False, lines, None, home_status, api_status

    received_env = str(data.get("env", "")).strip().lower()
    env_display = received_env if received_env else '""'
    lines.append(f"- JSON env -> {env_display}")
    lines.append(f"- EXPECT_ENV -> {expect_env_norm}")

    if not received_env:
        return False, lines, received_env, home_status, api_status

    if received_env != expect_env_norm:
        return False, lines, received_env, home_status, api_status

    return True, lines, received_env, home_status, api_status


def build_log(mode: str, config_result: Tuple[bool, List[str]], http_result: Optional[Tuple[bool, List[str], Optional[str], Optional[int], Optional[int]]]) -> List[str]:
    timestamp = datetime.now(timezone.utc).isoformat()
    lines: List[str] = [f"{timestamp} mode={mode}"]

    # Config section
    lines.extend(config_result[1])

    # HTTP section
    if http_result is None:
        lines.append("[HTTP]")
        lines.append("- Skipped (mode=config)")
        overall_ok = config_result[0]
        failure_reason = None if overall_ok else "CONFIG_FAIL"
    else:
        lines.extend(http_result[1])
        overall_ok = config_result[0] and http_result[0]
        if not config_result[0]:
            failure_reason = "CONFIG_FAIL"
        elif not http_result[0]:
            failure_reason = "ENV_MISMATCH" if http_result[2] is not None else "HTTP_FAIL"
        else:
            failure_reason = None

    lines.append("[RESULT]")
    if overall_ok:
        lines.append("PASS")
    else:
        lines.append(f"FAIL ({failure_reason})" if failure_reason else "FAIL")

    return lines


def print_summary(mode: str, config_ok: bool, http_info: Optional[Tuple[bool, Optional[str], Optional[int], Optional[int]]], log_path: Path, expect_env: Optional[str], base_url: Optional[str]) -> None:
    summary_lines: List[str] = []
    summary_lines.append(f"Environment check mode={mode}")

    if config_ok:
        summary_lines.append("Config: PASS")
    else:
        summary_lines.append("Config: FAIL")

    if http_info is None:
        summary_lines.append("HTTP: skipped")
        summary_lines.append("Result: PASS" if config_ok else "Result: CONFIG_FAIL")
    else:
        http_ok, received_env, home_status, api_status = http_info
        status_parts: List[str] = []
        if home_status is not None:
            status_parts.append(f"/ -> {home_status}")
        if api_status is not None:
            status_parts.append(f"/api/whoami -> {api_status}")
        summary_lines.append("HTTP: " + (", ".join(status_parts) if status_parts else "no response"))
        if http_ok and received_env:
            summary_lines.append(f"Result: PASS ({received_env})")
        else:
            if received_env and expect_env:
                summary_lines.append(f"Result: ENV_MISMATCH (expected {expect_env}, got {received_env})")
            else:
                summary_lines.append("Result: HTTP_FAIL")
    summary_lines.append(f"Log: {log_path}")

    for line in summary_lines:
        print(line)


def main(argv: List[str]) -> int:
    parser = build_arg_parser()
    args = parser.parse_args(argv)

    mode = args.mode
    base_url = args.base_url
    expect_env = args.expect_env

    if mode == "http":
        if not base_url or not expect_env:
            parser.error("--base-url and --expect-env are required in http mode")
        base_url = base_url.strip()
        expect_env = expect_env.strip().lower()
        if expect_env not in EXPECTED_ENVS:
            parser.error("--expect-env must be one of: local, preview, prod")
    else:
        base_url = None
        expect_env = None

    root = repository_root()
    log_path = ensure_log_path(root)

    config_ok, config_lines = config_checks(root)
    http_result: Optional[Tuple[bool, List[str], Optional[str], Optional[int], Optional[int]]] = None
    http_summary: Optional[Tuple[bool, Optional[str], Optional[int], Optional[int]]] = None
    exit_code_key = "ok"

    if mode == "http":
        http_ok, http_lines, received_env, home_status, api_status = http_checks(
            cast(str, base_url), cast(str, expect_env)
        )
        http_result = (http_ok, http_lines, received_env, home_status, api_status)
        http_summary = (http_ok, received_env, home_status, api_status)
        if not config_ok:
            exit_code_key = "config_fail"
        elif not http_ok:
            exit_code_key = "env_mismatch" if received_env and expect_env and received_env != expect_env else "http_fail"
    else:
        if not config_ok:
            exit_code_key = "config_fail"

    log_lines = build_log(mode, (config_ok, config_lines), http_result)
    write_log(log_path, log_lines)

    print_summary(mode, config_ok, http_summary, log_path, expect_env, base_url)

    return EXIT_CODES[exit_code_key]


if __name__ == "__main__":
    try:
        sys.exit(main(sys.argv[1:]))
    except KeyboardInterrupt:
        print("Interrupted", file=sys.stderr)
        sys.exit(130)
