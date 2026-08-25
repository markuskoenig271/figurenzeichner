---
name: pre-commit-check
description: Run the repo's full quality gate before committing — lintr, styler (check only), testthat — then commit with a Conventional Commit message and the correct authorship. Use when the user asks to commit, says "commit das", or when a piece of work is finished and ready to land.
---

# Pre-Commit Check

Everything runs before the commit, in this order. Cheap checks first so a style
error does not cost a full test run. All commands assume `Rscript` on `PATH` and
the `renv` project library (activated by `.Rprofile`); run them from the repo root.

## 1. Gate

```bash
Rscript -e 'l <- lintr::lint_dir(); print(l); quit(status = length(l) > 0)'
Rscript -e 'styler::style_dir(dry = "fail")'
Rscript -e 'testthat::test_dir("tests/testthat")'
```

Each step runs **once**. If a step already ran green in this session *after the
last change to any tracked file*, do not repeat it — cite that run in the report
("Suite: 155 grün, Lauf nach dem letzten Edit"). Coverage and the E2E runner are
not part of this gate: coverage belongs to `tdd-cycle` (once per feature), the
runner to `change-validation` (only when the change is user-visible).

`lint_dir` and `style_dir` skip `renv/` by default. `dry = "fail"` errors if any
file *would* be reformatted; it does **not** error if styler itself cannot process
a file (a missing dependency shows up as `Styling threw an error` with exit 0) —
read the summary line, do not trust the exit code alone.

Auto-fixable problems:

```bash
Rscript -e 'styler::style_dir()'
```

`lintr` has no auto-fix; each lint is fixed by hand or, if the rule is genuinely
wrong for this project, discussed with the user and changed in `.lintr`.

**Do not commit past a failure.** A failing lint or test is the finding — report it
and stop. Never use `--no-verify` and never weaken a check to make it pass; if a
rule is genuinely wrong, that is a separate conversation with the user.

If a dependency changed (`install.packages()` / `renv::install()` this session),
run `Rscript -e 'renv::snapshot()'` and commit `renv.lock` with the change —
an out-of-date lockfile is a gate failure for the next clone.

## 2. Review what actually lands

```bash
git status --porcelain
git diff --staged
```

Look for what should not be there: `.Renviron`, `.env` or any local secrets file,
`.Rhistory` / `.RData`, `renv/library/`, `rsconnect/`, coverage output
(`*.html` from `covr::report()`), stray `browser()` / `print()` debugging, a
hard-coded absolute path. The repo is **public**: anything that lands is visible to
everyone, and history is not un-published by a later delete.

## 3. Branch

Never commit directly to `main`. Branch prefixes: `feat/`, `fix/`, `refactor/`,
`chore/`, `docs/`.

```bash
git rev-parse --abbrev-ref HEAD
```

If you are on `main`, create the branch first.

## 4. Commit

Conventional Commits: `feat(scope): message`, imperative mood, lower case, no
trailing period.

Authorship comes from `git config user.name`. **No `Co-Authored-By` line, no
"Generated with Claude Code" footer, no other tool references** — this repo's
CLAUDE.md rules that out explicitly.

## Report back

The result of each gate step, the branch, and the commit subject. If you skipped a
step because the scaffold does not have it yet (no `R/`, no `tests/testthat/` —
`test_dir` aborts with `No test files found` on an empty directory), say which and
why — do not report an unrun check as passed.
