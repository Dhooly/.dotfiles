SHELL := /bin/bash

SHELL_FILES := bootstrap.sh bin/dotfiles-copy scripts/doctor.sh $(wildcard tests/*.sh) $(wildcard scripts/lib/*.sh)

.PHONY: check test lint

check: test lint

test:
	@bash -n $(SHELL_FILES)
	@for test_file in tests/*_test.sh; do bash "$$test_file"; done
	@./bootstrap.sh --dry-run --yes --skip-oh-my-zsh --skip-tmux-plugins --skip-shell-change >/dev/null 2>&1

lint:
	@if command -v shellcheck >/dev/null 2>&1; then \
		shellcheck $(SHELL_FILES); \
	else \
		printf 'shellcheck is not installed; skipping lint.\n'; \
	fi

