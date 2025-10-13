#!/usr/bin/env python3
"""Summarize LOG_EVENTS payloads for dashboards and anomaly checks.

Usage examples:
    curl .../api/logs/list?limit=200 | python tools/log_events_summary.py --bucket hourly
    python tools/log_events_summary.py --input path/to/events.jsonl --bucket daily

The script accepts JSON with the following shapes:
- Object containing an "events" array (API response).
- Plain array of events.
- Newline-delimited JSON objects (JSONL).

Outputs counts by action, role and time bucket plus simple anomaly flags.
"""
from __future__ import annotations

import argparse
import json
import sys
from collections import Counter, defaultdict
from datetime import datetime
from pathlib import Path
from typing import Dict, Iterable, List, Tuple

ISO_FORMATS = ["%Y-%m-%dT%H:%M:%S.%fZ", "%Y-%m-%dT%H:%M:%SZ", "%Y-%m-%dT%H:%M:%S.%f", "%Y-%m-%dT%H:%M:%S"]
KNOWN_ROLES = {"owner", "client_admin", "team", "client", "visitor", "admin", "equipo"}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--input",
        help="JSON/JSONL file with events. If omitted, reads from STDIN.",
    )
    parser.add_argument(
        "--bucket",
        choices=["none", "hourly", "daily"],
        default="none",
        help="Aggregate events by time bucket (UTC).",
    )
    return parser.parse_args()


def read_events_from_stream(stream: Iterable[str]) -> List[dict]:
    buffer = "".join(stream).strip()
    if not buffer:
        return []

    # Try JSON first
    try:
        data = json.loads(buffer)
    except json.JSONDecodeError:
        data = None

    if isinstance(data, dict) and "events" in data:
        events_field = data.get("events")
        if isinstance(events_field, list):
            return [evt for evt in events_field if isinstance(evt, dict)]
        return []
    if isinstance(data, list):
        return data

    # Fallback: treat as JSONL
    events: List[dict] = []
    for line in buffer.splitlines():
        line = line.strip()
        if not line:
            continue
        try:
            obj = json.loads(line)
            if isinstance(obj, dict):
                events.append(obj)
        except json.JSONDecodeError:
            continue
    return events


def parse_timestamp(ts: str) -> datetime | None:
    for fmt in ISO_FORMATS:
        try:
            return datetime.strptime(ts, fmt)
        except ValueError:
            continue
    return None


def summarize_events(events: Iterable[dict], bucket: str) -> Tuple[Counter, Counter, Dict[str, int], Dict[str, List[dict]]]:
    action_counter: Counter = Counter()
    role_counter: Counter = Counter()
    bucket_counter: Dict[str, int] = defaultdict(int)
    anomalies: Dict[str, List[dict]] = defaultdict(list)

    for event in events:
        if not isinstance(event, dict):
            continue
        action = str(event.get("action", "unknown")).strip() or "unknown"
        role = str(event.get("role", "unknown")).strip() or "unknown"
        ts_raw = str(event.get("ts", "")).strip()
        path = str(event.get("path", "")).strip()
        meta_raw = event.get("meta")
        meta = meta_raw if isinstance(meta_raw, dict) else {}

        action_counter[action] += 1
        role_counter[role] += 1

        if bucket != "none" and ts_raw:
            parsed = parse_timestamp(ts_raw)
            if parsed:
                if bucket == "hourly":
                    key = parsed.strftime("%Y-%m-%dT%H:00Z")
                else:
                    key = parsed.strftime("%Y-%m-%d")
                bucket_counter[key] += 1

        if role not in KNOWN_ROLES:
            anomalies["unknown_roles"].append(event)
        if not path:
            anomalies["missing_path"].append(event)

        status = meta.get("status")
        if isinstance(status, int) and status >= 400:
            anomalies["http_errors"].append(event)

    return action_counter, role_counter, dict(bucket_counter), anomalies


def print_summary(total: int, action_counter: Counter, role_counter: Counter, bucket_counter: Dict[str, int], anomalies: Dict[str, List[dict]]) -> None:
    print(f"Total eventos: {total}")

    print("Por acción:")
    for action, count in action_counter.most_common():
        print(f"  {action}: {count}")
    if not action_counter:
        print("  (sin datos)")

    print("Por rol:")
    for role, count in role_counter.most_common():
        print(f"  {role}: {count}")
    if not role_counter:
        print("  (sin datos)")

    if bucket_counter:
        print("Bucket:")
        for key in sorted(bucket_counter.keys()):
            print(f"  {key} -> {bucket_counter[key]}")

    print("Anomalías:")
    unknown_roles = [evt.get("role") for evt in anomalies.get("unknown_roles", [])]
    if unknown_roles:
        print(f"  Roles desconocidos: {sorted(set(str(r) for r in unknown_roles))}")
    else:
        print("  Roles desconocidos: []")

    missing_path = len(anomalies.get("missing_path", []))
    print(f"  Eventos sin ruta: {missing_path}")

    http_errors = anomalies.get("http_errors", [])
    print(f"  Eventos HTTP error: {len(http_errors)}")


def main() -> int:
    args = parse_args()
    if args.input:
        path = Path(args.input)
        if not path.exists():
            print(f"Archivo no encontrado: {path}", file=sys.stderr)
            return 1
        with path.open("r", encoding="utf-8") as handle:
            events = read_events_from_stream(handle)
    else:
        events = read_events_from_stream(sys.stdin)

    action_counter, role_counter, bucket_counter, anomalies = summarize_events(events, args.bucket)
    print_summary(len(events), action_counter, role_counter, bucket_counter, anomalies)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
