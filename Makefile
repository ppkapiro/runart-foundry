.RECIPEPREFIX := >
PYTHON ?= python3
DEFAULT_MODULE ?= apps/briefing
MODULE ?= $(DEFAULT_MODULE)
APPS := apps/briefing

.PHONY: build serve preview test lint lint-docs status clean

build:
>if [ "$(ALL)" = "1" ]; then \
>  for module in $(APPS); do \
>    $(MAKE) -C $$module build || exit 1; \
>  done; \
>else \
>  $(MAKE) -C $(MODULE) build; \
>fi

serve:
>$(MAKE) -C $(MODULE) serve

preview:
>@echo "Preview controlado (documentado en docs/architecture/065_switch_pages.md)."

test:
>$(MAKE) -C $(MODULE) test

lint:
>$(MAKE) lint-docs
>$(MAKE) -C $(MODULE) lint

lint-docs:
>$(PYTHON) tools/lint_docs.py

status:
>@echo "STATUS.md → $(abspath STATUS.md)"
>@$(PYTHON) - <<'PY'
>from pathlib import Path
>from itertools import takewhile
>
>path = Path("STATUS.md")
>if not path.exists():
>    print("STATUS.md no encontrado")
>    raise SystemExit(1)
>lines = path.read_text(encoding="utf-8").splitlines()
>try:
>    start = next(i for i, line in enumerate(lines) if line.strip().lower() == "## resumen ejecutivo") + 1
>except StopIteration:
>    print("No se halló la sección 'Resumen Ejecutivo'")
>    raise SystemExit(1)
>segment = list(takewhile(lambda line: not line.startswith("## "), lines[start:]))
>print("\n".join(segment).strip() or "(Sección vacía)")
>PY

clean:
>if [ "$(ALL)" = "1" ]; then \
>  for module in $(APPS); do \
>    $(MAKE) -C $$module clean || exit 1; \
>  done; \
>else \
>  $(MAKE) -C $(MODULE) clean; \
>fi
