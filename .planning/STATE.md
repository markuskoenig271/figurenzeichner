# Project State

Rollender „wo ich aufgehört habe"-Stand (committet). Wird jede Session überschrieben.
Zusammen mit `TODO.md` bei jedem Sessionstart lesen. Spec in `PROJECT.md`.

---

## Last updated: 2026-08-25 (Session 1 — Design geschrieben und freigegeben)

## Headline

Design steht: `docs/architecture.md` und `docs/ui_screens.md` sind ausgefüllt und
vom User freigegeben. Noch kein Code — kein `app.R`, kein `R/`, keine Tests, kein
`renv`. Nächste Session beginnt mit der Toolchain, dann der erste `tdd-cycle`.

## Architecture first — erfüllt (2026-08-25)

Kernentscheidungen (Details und Begründung in `docs/architecture.md`):

- Darstellung: Base Graphics in `renderPlot()`, Klicks über `plotOutput(click=)`
  — kein ggplot2, kein JS
- Logisches Koordinatensystem 0–100 × 0–100, Ursprung links unten, `asp = 1`
- Figur mit festem Schema `id, type, x, y, w, h, colour` für alle vier Typen
  (Kreis: `w` = Radius)
- `validate_figure()` liefert Meldungen statt zu werfen
- Ein zentrales `reactiveValues(drawing, selected, click)` in `app.R`, beide Module
  bekommen die Referenz; Editor ist einziger Schreiber von `drawing`
- Dateien: `R/figure.R`, `geometry.R`, `drawing.R`, `render.R`, `mod_canvas.R`,
  `mod_editor.R` — je eine Testdatei

Screens: eine Seite, Editor links (Modi Neu/Bearbeiten), Zeichenfläche rechts;
Fehlertabelle mit konkreten Meldungstexten in `docs/ui_screens.md`.

## Toolchain

- R 4.2.1 unter `C:\Program Files\R\R-4.2.1`, **nicht im PATH**
- Global installiert: `shiny` 1.10.0, `testthat` 3.2.3, `styler` 1.10.3 (defekt:
  Abhängigkeit `R.oo` fehlt); nicht installiert: `renv`, `lintr`, `covr`, `withr`
- Geprüft: `testthat::test_dir()` liefert Exit 0 bei grün, 1 bei rot, 1 bei leerem
  Test-Verzeichnis. Ungeprüft: lintr-, styler-, covr- und renv-Kommandos in
  `pre-commit-check` und `tdd-cycle`
- `post-tool-format.sh` ist in `settings.json` verdrahtet (`styler::style_file` für
  `*.R`); wirkt erst, wenn `Rscript` im PATH ist und `styler` in der renv-Library
  vollständig installiert ist
- Docs-Commit dieser Session lief **ohne** lintr/styler/testthat-Gate: es gab noch
  keinen R-Code zu prüfen

## Next steps

1. `Rscript` auf den PATH, `renv::init()`, Pakete installieren, `renv::snapshot()`,
   `.lintr` anlegen (siehe `TODO.md`, Block „Toolchain").
2. Erster `tdd-cycle`: `tests/testthat/helper-source.R`, `test-figure.R` mit
   `figure()`/`validate_figure()`, dann `test-geometry.R` (`figure_area()` als
   Einstieg) — in der Reihenfolge `figure.R` → `geometry.R` → `drawing.R` →
   `render.R` → Module → `app.R`.
3. Nach der ersten sichtbaren Version: `change-validation` mit den Szenarien aus
   `docs/ui_screens.md`.
