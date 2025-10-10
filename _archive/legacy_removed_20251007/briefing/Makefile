venv:
	python3 -m venv .venv && \
		.venv/bin/pip install --upgrade pip && \
		.venv/bin/pip install -r requirements.txt

build:
	.venv/bin/python scripts/mark_internal.py
	.venv/bin/mkdocs build

serve:
	.venv/bin/python scripts/mark_internal.py
	.venv/bin/mkdocs serve

clean:
	rm -rf site/

test-logs:
	@if [ -f scripts/test_logs.mjs ]; then \
		node scripts/test_logs.mjs; \
	else \
		node scripts/test_logs_strict.mjs; \
	fi

test-logs-strict:
	node scripts/test_logs_strict.mjs
