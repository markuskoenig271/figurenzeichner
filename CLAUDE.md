# CLAUDE.md

Guidance für Claude Code in diesem Repository.

## Project Overview

**Figurenzeichner** — ein simples R-Shiny-UI, in dem man geometrische Figuren auf
einer Zeichenfläche anlegen, verändern und entfernen kann. Keine Persistenz, kein
Deployment: läuft lokal mit `shiny::runApp()`. Spec in `.planning/PROJECT.md`.

Das Repo ist **öffentlich** (`markuskoenig271/figurenzeichner`).

## Tech Stack

R 4.2.1 · Shiny · renv (Projekt-Library, `renv.lock` committet) · testthat +
`shiny::testServer()` · lintr · styler · covr

## Commands

Alle Kommandos aus dem Repo-Root, `Rscript` muss im `PATH` sein.

| Zweck | Kommando |
| --- | --- |
| App starten | `Rscript -e 'shiny::runApp(port = 3838)'` |
| Alle Tests | `Rscript -e 'testthat::test_dir("tests/testthat")'` |
| Eine Testdatei | `Rscript -e 'testthat::test_dir("tests/testthat", filter = "geometry")'` |
| Lint | `Rscript -e 'l <- lintr::lint_dir(); print(l); quit(status = length(l) > 0)'` |
| Format prüfen / anwenden | `Rscript -e 'styler::style_dir(dry = "fail")'` / `Rscript -e 'styler::style_dir()'` |
| Pakete wiederherstellen / einfrieren | `Rscript -e 'renv::restore()'` / `Rscript -e 'renv::snapshot()'` |

Coverage-Kommando und Details im `tdd-cycle` Skill; die vollständige Gate-Reihenfolge
im `pre-commit-check` Skill.

## Architecture

`docs/architecture.md` ist die Design-Baseline, `docs/ui_screens.md` beschreibt die
Screens. **Architecture first:** beide sind vor der ersten Implementierung ausgefüllt
und freigegeben; solange dort `<Komponente>`/`<Screen>` steht, wird kein Code
geschrieben. Änderungen am Design werden erst dort eingetragen, dann umgesetzt.

Layout: `app.R` (Einstieg) · `R/` (Geometrie als reine Funktionen, Shiny-Module —
von Shiny automatisch geladen) · `tests/testthat/`.

## Rules

- **TDD verpflichtend** — `tdd-cycle` Skill vor jeder neuen Funktion; Geometrie ohne
  Shiny testbar, reaktive Logik über `shiny::testServer()`
- **Architecture first** — siehe oben
- **E2E-Validierung** — `change-validation` Skill bei jeder sichtbaren Änderung;
  Szenarien landen in `.planning/e2e-tests/`
- **Planning-Dateien werden neu geschrieben, nie fremde übernommen**
- **NEVER commit secrets** — das Repo ist öffentlich. Keine `.Renviron`, keine
  Tokens, keine persönlichen Daten, auch nicht in Fixtures
- Kein `autoMode` in `.claude/settings.json` — wird nur aus
  `~/.claude/settings.json` gelesen

## Git

**Branch:** `feat/`, `fix/`, `refactor/`, `chore/`, `docs/` — nie direkt auf `main`

**Commits:** Conventional Commits (`feat(scope): message`)

**Author:** Identität aus `git config user.name` — kein Co-Authored-By, keine
Tool-Referenzen.

## Documentation Paths

| Path | Purpose |
| --- | --- |
| `.planning/PROJECT.md` | Spec, Scope, Non-Goals, Key Decisions |
| `.planning/TODO.md` | offene Arbeit |
| `.planning/STATE.md` | rollender Stand |
| `.planning/e2e-tests/` | Akzeptanzszenarien aus `change-validation` |
| `docs/architecture.md` | Design-Baseline |
| `docs/ui_screens.md` | Screens, Elemente, Übergänge, Fehlerzustände |

## Session Continuity

Sessionbeginn: der `SessionStart`-Hook injiziert `STATE.md` automatisch; für das volle
Bild den `session-start` Skill fahren. Stopping Point oder „save session":
`session-save` Skill — er schreibt `TODO.md` und `STATE.md` und prüft Doku-Drift.

## Skills

| Skill | Wann |
| --- | --- |
| `session-start` | Sessionbeginn, nach `/clear` |
| `session-save` | Stopping Point, „save session" |
| `tdd-cycle` | vor neuer Implementierung |
| `change-validation` | Änderungen an sichtbarem Verhalten |
| `pre-commit-check` | vor dem Commit |
| `new-project` | dieses Setup auf ein weiteres Repo übertragen |
