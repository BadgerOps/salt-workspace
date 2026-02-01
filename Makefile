SHELL := /bin/bash
GIT_SHA = $(shell git log --pretty=oneline | head -n1 | cut -c1-8)
PACKAGE = "salt_config-$(GIT_SHA).tgz"
SHASUM = $(shell test `uname` == 'Darwin' && echo shasum -a 256 || echo sha256sum)

.PHONY: all lint docker test package clean coverage help

.DEFAULT_GOAL := all

all: formulas
	@mkdir -p dist 
	@rsync -a ./salt/ ./dist/salt/ --delete
	@rsync -a ./formulas/ ./dist/formulas/ --delete
	@rsync -a ./pillar/ ./dist/pillar/ --delete
	@echo $(GIT_SHA) > ./dist/SHA
	@find ./dist -type f | sort | xargs $(SHASUM) | sed "s;./dist;/srv;" > MANIFEST
	@$(SHASUM) MANIFEST | cut -d\  -f1 > MANIFEST.sha256
	@mv MANIFEST* ./dist/
	@echo "Salt is ready in ./dist. Enjoy!"

lint:
	@tests/lint.sh

docker:
	@tests/docker.sh

test: clean all lint
	@true

package: clean all
	@tar czf $(PACKAGE) ./dist/
	@mv -f $(PACKAGE) ./dist
	@echo "Package ./dist/$(PACKAGE) is ready."

clean::
	@echo -n "Removing ./dist directory..."
	@rm -rf dist
	@echo "DONE"

coverage:
	@tests/coverage.sh

help:
	@echo "Salt Workspace - Available Commands"
	@echo "===================================="
	@echo ""
	@echo "  make          Build the dist/ directory (default)"
	@echo "  make test     Run full test suite (clean, build, lint)"
	@echo "  make lint     Run linting checks only"
	@echo "  make docker   Run Docker-based formula tests"
	@echo "  make coverage Show test coverage report"
	@echo "  make package  Create distributable tarball"
	@echo "  make clean    Remove dist/ directory"
	@echo "  make help     Show this help message"
	@echo ""
	@echo "Quick Start:"
	@echo "  1. make        # Build the project"
	@echo "  2. make test   # Run tests"
	@echo "  3. vagrant up  # Start VMs"
	@echo ""
	@echo "See QUICKSTART.md for detailed instructions."
