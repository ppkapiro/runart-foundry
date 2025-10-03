venv:
	python3 -m venv .venv && \
		.venv/bin/pip install --upgrade pip && \
		.venv/bin/pip install -r requirements.txt

build:
	.venv/bin/mkdocs build

serve:
	.venv/bin/mkdocs serve

clean:
	rm -rf site/
