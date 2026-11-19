# Makefile and releases

Read when writing a Makefile, cutting a release or setting up a changelog.

## Makefile

```makefile
.DEFAULT_GOAL := help
.PHONY: help install lint test build ci clean

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

install: ## Install dependencies from the lock file
lint: ## Run linters and type checks
test: ## Run the test suite
build: ## Build the release artefact
ci: lint test build ## Everything CI runs, in CI order
clean: ## Remove build artefacts (never source files)
```

Rules:
- Every target has a `## comment`, so `make help` documents itself. `help` is the default goal.
- Declare `.PHONY` for every target that is not a file.
- Recipes are indented with tabs, not spaces.
- Use `$(MAKE)` for recursive calls, not bare `make`, so flags pass through.
- A `ci` target runs exactly what the pipeline runs. The workflow calls `make ci` and nothing else.
- `clean` removes only generated files. It never touches source or data the user created.

## Versioning

Semantic versioning, `MAJOR.MINOR.PATCH`:
- MAJOR for a breaking change to anything a user depends on (API, CLI flags, file formats, config).
- MINOR for new backwards-compatible features.
- PATCH for backwards-compatible fixes only.

Before 1.0.0, say in the README what stability users can expect.

## Tag-based releases

The tag is the source of truth for what was released. CI builds the release from the tag, never from a
branch head.

```bash
git tag -a v1.2.3 -m "v1.2.3: one-line summary"
git push origin v1.2.3
```

- Annotated tags only (`-a`), so the tag records who and when.
- Never move or delete a pushed release tag. Fix forward with a new patch version.
- The release workflow triggers on `push: tags: ['v*']`, builds, attaches artefacts and their checksums
  and generates provenance (see the `security-audit` skill's supply-chain checks).

## Changelog

Keep `CHANGELOG.md` with one section per version: version, date, then Added, Changed, Fixed, Removed and
Security groups. Write entries for users, not as a commit log. Tools such as `git-cliff` can draft it
from conventional commits (see the `git` skill). Review the draft: generated changelogs list
refactors users do not care about and miss the one behaviour change they do.
