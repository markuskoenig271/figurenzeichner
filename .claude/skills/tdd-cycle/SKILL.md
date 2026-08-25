---
name: tdd-cycle
description: Enforce the repo's test-first rule — write the failing testthat test, watch it fail for the right reason, implement the minimum to pass, then check coverage against the 75% target. Use before implementing any new function, module, or behaviour, and when the user asks for a feature, a bugfix, or says "TDD".
---

# TDD Cycle

CLAUDE.md makes tests-before-implementation mandatory. The step that gets skipped is
**watching the test fail** — without it you have no evidence the test tests anything.

All commands assume `Rscript` is on `PATH` and the project library is active
(`renv`, loaded via `.Rprofile`). Run them from the repo root.

## The cycle

### 1. Red — write the test first

Write the test against the interface you *want*, before the implementation exists.
Tests live in `tests/testthat/test-<topic>.R`; one file per source file in `R/`
(`R/geometry.R` ↔ `tests/testthat/test-geometry.R`).

Keep pure computation testable without Shiny: the geometry (points, transformations,
area, bounding boxes, the data structure that describes a drawn figure) lives in
`R/` as plain functions that take and return plain R values. If a test needs a
running Shiny session to check a calculation, the calculation is in the wrong place.

Reactive logic gets its own layer of tests with `shiny::testServer()` — for a server
function or a module, driving inputs with `session$setInputs()` and asserting on
reactive values. Do not test what the browser renders here; that is
`change-validation`'s job.

**One level per behaviour.** A rule lives in exactly one test file:

- Pure logic — every validation rule, every message text, every geometry case —
  is tested in the unit test of the function that implements it, and only there.
- A `testServer()` test proves the *wiring*: one case per observer or path
  ("invalid input → state unchanged and an error is shown", "delete → selection
  cleared"). It does not walk the message catalogue again; one representative
  invalid input is enough. If a module test starts enumerating rules, move those
  assertions to the unit test.
- UI builders (`*_ui()`) get at most one test that the expected ids are present.

Before writing an assertion, ask which existing test already covers it. A second
test for a covered rule adds runtime and maintenance, not confidence.

`tests/testthat/helper-source.R` sources every file in `R/` before the tests run.
Test files must not `source()` anything themselves — under `covr` the sources are
already loaded, and re-sourcing them would silently discard the coverage traces.
For anything touching the filesystem use `withr::local_tempdir()` /
`withr::local_tempfile()` — never a shared file.

### 2. Watch it fail — and read the failure

```bash
Rscript -e 'testthat::test_dir("tests/testthat", filter = "geometry")'
```

`filter` is a regex on the file name without the `test-` prefix and `.R` suffix.
On Windows, `Rscript -e` breaks on a `|` inside the expression (`filter =
"figure|geometry"` fails with "Pfad nicht gefunden") — run one filter at a time or
the whole suite.

The test must fail **for the reason you intend**. An `could not find function`
error or a typo in a helper name is not a red test — it is a broken test that will
go green for the wrong reason. Confirm the `expect_*` assertion itself is what
failed before writing any implementation.

### 3. Green — minimum implementation

Write the least code that makes the test pass. Resist implementing the next three
things you can already see; they get their own red test first.

```bash
Rscript -e 'testthat::test_dir("tests/testthat", filter = "geometry")'
```

### 4. Refactor — with the test as the net

Clean up only once green. Re-run the **filtered** file after each change. The whole
suite runs once, when the feature is done and before handing over — not after every
edit, and not again in `pre-commit-check` if nothing changed since:

```bash
Rscript -e 'testthat::test_dir("tests/testthat")'
```

`test_dir` exits non-zero on any failure, so the shell exit code is trustworthy.

### 5. Coverage — once per feature

Measure once, at the end of the feature, together with the full suite. Do not run
it per cycle; the number only means something for finished work.

```bash
Rscript -e 'library(testthat); library(shiny); cov <- covr::file_coverage(list.files("R", full.names = TRUE), list.files("tests/testthat", "^test-", full.names = TRUE)); print(cov); cat(sprintf("Total: %.1f%%\n", covr::percent_coverage(cov)))'
```

Target is 75% over `R/`. Treat it as a floor for meaningful lines, not a number to
game — report the actual figure and name what is genuinely untested. Do not add
assertion-free tests to move the number. `app.R` (the `shinyApp()` entry point)
is not in the denominator on purpose; the UI definition is covered by
`change-validation`, not by unit coverage.

## For bugfixes

Same cycle, one addition: the first test must **reproduce the bug**. A bugfix without
a test that failed before the fix is not a bugfix — it is an untested change that
happens to work today.
