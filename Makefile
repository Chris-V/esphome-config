ifneq (,)
.error This Makefile requires GNU Make.
endif

CURRENT_DIR       = $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

FILE_LINT_VERSION = 0.4
YAML_LINT_VERSION = 1.25
LINT_IGNORE_PATHS = .git,.venv,build,config/devices/.esphome

.PHONY: setup
setup:
	asdf plugin-update python || asdf plugin-add python
	asdf install
	python -m venv .venv
	. .venv/bin/activate && python -m pip install -r requirements.txt

.PHONY: open_dashboard
open_dashboard:
	. .venv/bin/activate && python -m esphome dashboard config/devices

.PHONY: compile
compile: SHELL:=/bin/bash
compile:
	. .venv/bin/activate && shopt -s extglob && python -m esphome compile $$(echo config/devices/!(secrets).yaml)

.PHONY: lint
lint: _lint-files _lint-yaml

.PHONY: _pull-file-lint
_pull-file-lint:
	docker pull cytopia/file-lint:$(FILE_LINT_VERSION)

.PHONY: _pull-yaml-lint
_pull-yaml-lint:
	docker pull cytopia/yamllint:$(YAML_LINT_VERSION)

.PHONY: _lint-files
_lint-files: _pull-file-lint
	@docker run --rm -v $(CURRENT_DIR):/data cytopia/file-lint:$(FILE_LINT_VERSION) file-cr --text --ignore '$(LINT_IGNORE_PATHS)' --path .
	@docker run --rm -v $(CURRENT_DIR):/data cytopia/file-lint:$(FILE_LINT_VERSION) file-crlf --text --ignore '$(LINT_IGNORE_PATHS)' --path .
	@docker run --rm -v $(CURRENT_DIR):/data cytopia/file-lint:$(FILE_LINT_VERSION) file-trailing-single-newline --text --ignore '$(LINT_IGNORE_PATHS)' --path .
	@docker run --rm -v $(CURRENT_DIR):/data cytopia/file-lint:$(FILE_LINT_VERSION) file-trailing-space --text --ignore '$(LINT_IGNORE_PATHS)' --path .
	@docker run --rm -v $(CURRENT_DIR):/data cytopia/file-lint:$(FILE_LINT_VERSION) file-utf8 --text --ignore '$(LINT_IGNORE_PATHS)' --path .
	@docker run --rm -v $(CURRENT_DIR):/data cytopia/file-lint:$(FILE_LINT_VERSION) file-utf8-bom --text --ignore '$(LINT_IGNORE_PATHS)' --path .

.PHONY: _lint-yaml
_lint-yaml: _pull-yaml-lint
	@docker run --rm $$(tty -s && echo "-it" || echo) -v $(CURRENT_DIR):/data cytopia/yamllint:$(YAML_LINT_VERSION) . --strict
