import json
import os
import time
import pathlib
import yaml

RULES = yaml.safe_load(open("rules/audit_rules.yml","r"))
LOG_DIR = pathlib.Path("_reports/audit_artifacts")
OUT_JSON = pathlib.Path("_reports/audit_artifacts/audit_latest.json")
OUT_SUM = pathlib.Path("_reports/audit_artifacts/audit_latest.txt")

# Ensure output directory exists
LOG_DIR.mkdir(parents=True, exist_ok=True)

def load_latest_summaries():
    # Busca los últimos *_summary.txt generados por verify-*
    items = {}
    for name in ["verify-home","verify-settings","verify-menus","verify-media"]:
        files = sorted(LOG_DIR.glob(f"{name}*summary*.txt"), key=os.path.getmtime, reverse=True)
        if files:
            items[name] = files[0].read_text(encoding="utf-8", errors="ignore")
        else:
            items[name] = ""
    return items

def parse_fields(text):
    # Extrae valores simples por etiquetas conocidas (modo robusto)
    fields = {
        "auth_status": "OK" if "Auth=OK" in text else ("KO" if "Auth=KO" in text else "UNKNOWN"),
        "rest_status": 200 if "REST=200" in text else (401 if "REST=401" in text else (500 if "REST=5" in text else None)),
        "menus_drift": "DRIFT" in text or "menus drift" in text.lower(),
        "media_missing_count": 0
    }
    # intento: buscar "MISSING=n"
    import re
    m = re.search(r"MISSING\s*=\s*(\d+)", text)
    if m: fields["media_missing_count"] = int(m.group(1))
    return fields

def match_rule(rule, fields):
    m = rule["match"]
    for k,v in m.items():
        if k not in fields: return False
        if isinstance(v, dict):
            # not used
            return False
        if isinstance(v, list):
            if fields[k] not in v: return False
        elif isinstance(v, bool):
            if bool(fields[k]) != v: return False
        elif isinstance(v, (int,str)):
            if fields[k] != v: return False
    return True

def score(findings):
    s = 0
    for fid in findings:
        sev = [r for r in RULES["rules"] if r["id"]==fid][0]["severity"]
        s += RULES["scoring"][sev]
    return s

def main():
    summaries = load_latest_summaries()
    merged = {}
    findings = set()
    for wf, text in summaries.items():
        f = parse_fields(text)
        merged[wf] = f
        for rule in RULES["rules"]:
            if match_rule(rule, f):
                findings.add(rule["id"])
    total = score(findings)
    level = "green"
    if total >= RULES["thresholds"]["red"]: level="red"
    elif total >= RULES["thresholds"]["yellow"]: level="yellow"
    OUT_JSON.write_text(json.dumps({
        "time": time.time(),
        "findings": sorted(list(findings)),
        "score": total,
        "level": level,
        "snap": merged
    }, indent=2))
    OUT_SUM.write_text(f"FINDINGS={sorted(list(findings))}\nSCORE={total}\nLEVEL={level}\n")
    print(f"[audit] LEVEL={level} SCORE={total} FINDINGS={sorted(list(findings))}")

if __name__=="__main__":
    main()
