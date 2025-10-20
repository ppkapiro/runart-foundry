PYTHON ?= python3
ROOT := ../..
VENV := .venv
RUN_PY := $(VENV)/bin/python
MKDOCS := $(RUN_PY) -m mkdocs
CHECK_ENV := $(PYTHON) $(ROOT)/tools/check_env.py

.PHONY: build serve preview clean lint lint-docs lint-app test test-env test-env-preview test-env-prod test-smoke-prod test-smoke-wrapper venv install-deps test-logs test-logs-strict

venv:
	$(PYTHON) -m venv $(VENV)
	$(RUN_PY) -m pip install --upgrade pip
	$(RUN_PY) -m pip install -r requirements.txt

build: venv
	$(RUN_PY) scripts/mark_internal.py
	$(MKDOCS) build

serve: venv
	$(RUN_PY) scripts/mark_internal.py
	$(MKDOCS) serve

preview:
	@echo "Preview se documenta en docs/architecture/065_switch_pages.md (no despliega automáticamente)."

clean:
	rm -rf site/

lint: lint-app lint-docs

lint-app:
	@echo "No hay lint adicional aún; agrega cuando existan assets o código adicional."

lint-docs:
	@$(MAKE) -C $(ROOT) lint-docs

test: test-env

test-env:
	@$(CHECK_ENV) --mode=config
	@$(CHECK_ENV) --mode=http --base-url http://127.0.0.1:8000 --expect-env local
	@echo "ENV LOCAL OK"

test-env-preview:
	@if [ -z "$$PREVIEW_URL" ]; then \
		echo "Set PREVIEW_URL=https://<preview>.pages.dev before running make test-env-preview"; \
		exit 1; \
	fi
	@$(CHECK_ENV) --mode=config
	@$(CHECK_ENV) --mode=http --base-url "$$PREVIEW_URL" --expect-env preview
	@echo "ENV PREVIEW OK"

test-env-prod:
	@if [ -z "$$PROD_URL" ]; then \
		echo "Set PROD_URL=https://<production-domain> before running make test-env-prod"; \
		exit 1; \
	fi
	@$(CHECK_ENV) --mode=config
	@$(CHECK_ENV) --mode=http --base-url "$$PROD_URL" --expect-env prod
	@echo "ENV PROD OK"

test-smoke-prod:
	@if [ -z "$$PROD_URL" ]; then \
		echo "Set PROD_URL=https://<production-domain> before running make test-smoke-prod"; \
		exit 1; \
	fi
	@echo "Ejecutando smoke tests para producción (reconoce Access redirects como PASS)"
	@PAGES_URL="$$PROD_URL" RUN_TOKEN="$${RUN_TOKEN:-dev-token}" bash scripts/smoke_production.sh

test-smoke-wrapper:
	@if [ -z "$$PROD_URL" ]; then \
		echo "Set PROD_URL=https://<production-domain> before running make test-smoke-wrapper"; \
		exit 1; \
	fi
	@echo "Ejecutando smoke tests avanzados vía Node.js (manejo automático de Access)"
	@bash scripts/smoke_wrapper.sh "$$PROD_URL"

smokes-prod:
	@if [ -z "$$PROD_BASE_URL" ]; then \
		echo "Set PROD_BASE_URL=https://<production-domain> before running make smokes-prod"; \
		exit 1; \
	fi
	npm run --silent --prefix . smokes:prod

smokes-prod-auth:
	@if [ -z "$$PROD_BASE_URL" ]; then \
		echo "Set PROD_BASE_URL=https://<production-domain> before running make smokes-prod-auth"; \
		exit 1; \
	fi
	RUN_AUTH_SMOKES=1 npm run --silent --prefix . smokes:prod

test-logs:
	@if [ -f scripts/test_logs.mjs ]; then \
		node scripts/test_logs.mjs; \
	else \
		node scripts/test_logs_strict.mjs; \
	fi

test-logs-strict:
	node scripts/test_logs_strict.mjs
