# Project State

Rollender „wo ich aufgehört habe"-Stand (committet). Wird jede Session überschrieben.
Zusammen mit `TODO.md` bei jedem Sessionstart lesen. Spec in `PROJECT.md`.

---

## Last updated: 2026-08-25 (Session 1 — Design, Toolchain und erste lauffähige App)

## Headline

Der Figurenzeichner läuft: Zeichenfläche und Editor gemäß `docs/ui_screens.md`, alle
vier Figurentypen, Auswahl per Klick, Bearbeiten/Löschen, Validierung mit Meldungen.
Toolchain steht (Rscript im User-PATH, renv-Library, `renv.lock`, `.lintr`). Alle
Gates grün: 155 Unit-Tests, Coverage 99,2 %, lintr, styler; E2E-Runner 48/48.

## What exists

- `app.R` + `R/` (`figure.R`, `geometry.R`, `drawing.R`, `render.R`, `mod_canvas.R`,
  `mod_editor.R`) — Aufbau wie in `docs/architecture.md`
- `tests/testthat/` — eine Testdatei je Quelldatei, Module per `shiny::testServer()`;
  `helper-source.R` sourct `R/` und hängt `shiny` an
- `tests/e2e/run_scenarios.R` — fährt die Szenarien aus `.planning/e2e-tests/` gegen
  die ganze App (`testServer` auf `app.R`), rendert Canvas-Zustände als PNG;
  `Rscript tests/e2e/run_scenarios.R`
- `.planning/e2e-tests/` — 7 Szenarien + README (was nur der Browser prüfen kann)
- `README.md` mit Start- und Entwicklungs-Kommandos
- E2E-Befund behoben: der gestrichelte Auswahlrahmen fiel beim Rechteck mit dessen Rand
  zusammen → `SELECTION_PADDING = 2` in `render.R`, in `architecture.md` nachgetragen
- Browser-Prüfung der clientseitigen Punkte (conditionalPanel, Button-Zustand,
  Formular-Updates) steht aus — Chrome-Automation war in dieser Session nicht
  verfügbar; siehe `TODO.md`

## Toolchain

- R 4.2.1; `C:\Program Files\R\R-4.2.1\bin` seit 2026-08-25 im User-PATH (neue
  Terminals nötig; in dieser Session per `export PATH=...` gesetzt)
- renv 1.2.4 (global), Projekt-Library mit den eingefrorenen CRAN-4.2-Binaries:
  shiny 1.8.1.1, testthat 3.2.1.1, lintr 3.1.2, styler 1.10.3, covr 3.6.4, withr 3.0.0;
  Snapshot-Typ „all", 116 Pakete im Lockfile
- Stolpersteine: `renv::install()` holt für 4.2 unbrauchbare Builds (→ TODO);
  `Rscript -e` bricht unter Windows bei `|` im Ausdruck (Filter einzeln fahren, im
  `tdd-cycle` Skill vermerkt); `covr::file_coverage()` braucht `library(testthat);
  library(shiny)` vorweg (Skill-Kommando angepasst)
- `.lintr`: Zeilenlänge 100, `SNAKE_CASE` für Konstanten erlaubt,
  `object_usage_linter` aus
- `post-tool-format.sh` (styler-Hook) ist jetzt lauffähig, da Rscript und styler da sind

## Next steps

1. Branch `feat/figurenzeichner` nach `main` mergen (Commit dieser Session liegt dort).
2. Manuelle Browser-Prüfung der vier clientseitigen Punkte (`TODO.md`, Block
   „Manuelle Browser-Prüfung"), dabei die App einmal wirklich bedienen.
3. Doku-Nachträge aus `TODO.md` („Doku-Drift") vom User bestätigen lassen und in
   `docs/architecture.md` eintragen.
