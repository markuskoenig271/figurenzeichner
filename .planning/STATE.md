# Project State

Rollender „wo ich aufgehört habe"-Stand (committet). Wird jede Session überschrieben.
Zusammen mit `TODO.md` bei jedem Sessionstart lesen. Spec in `PROJECT.md`.

---

## Last updated: 2026-08-25 (Session 1 — Design, Toolchain, erste lauffähige App, Testregeln gestrafft)

## Headline

Der Figurenzeichner läuft und ist vollständig auf `feat/figurenzeichner` committet
(noch nicht nach `main` gemergt). Nach dem Bau wurden die Testregeln gestrafft:
„eine Ebene pro Verhalten" und „Gates einmal" stehen jetzt in `CLAUDE.md` und den
Skills; der vorhandene Code ist davon noch nicht bereinigt (Block „Test-Redundanz
abbauen" in `TODO.md`). README hat eine Schritt-für-Schritt-Anleitung für RStudio.

## What exists

- `app.R` + `R/` (`figure.R`, `geometry.R`, `drawing.R`, `render.R`, `mod_canvas.R`,
  `mod_editor.R`) — Aufbau wie in `docs/architecture.md`; alle vier Figurentypen,
  Auswahl per Klick, Bearbeiten/Löschen, Validierung mit Meldungen
- `tests/testthat/` — eine Testdatei je Quelldatei, Module per `shiny::testServer()`;
  155 Tests grün, Coverage 99,2 %, lintr und styler sauber (Stand letzter Code-Commit
  `eb6f063`)
- `tests/e2e/run_scenarios.R` — E2E-Runner (`testServer` auf `app.R` + PNG-Snapshots),
  48/48 grün; enthält bewusst noch Redundanz zu den Modul-Tests (→ TODO)
- `.planning/e2e-tests/` — 7 Szenarien + README; vier Browser-only-Punkte stehen als
  manuelle Prüfung in `TODO.md`
- `README.md` — RStudio-Anleitung (Clone → Existing Directory → `renv::restore()` →
  Run App → Tests) und Kommandozeilen-Start
- Commits auf `feat/figurenzeichner` seit `main`: `fa0f5e2` chore(toolchain),
  `eb6f063` feat(app), `550d7bc` docs(skills), `25151a9` docs(readme)

## Testregeln (seit 2026-08-25, in CLAUDE.md und Skills)

- Reine Logik nur in Unit-Tests; `testServer()` prüft nur die Verdrahtung (ein Fall
  je Pfad); E2E nur, was Unit/`testServer` nicht sehen können
- Gefilterte Testdatei im Zyklus; ganze Suite, Lint, Styler, Coverage einmal vor der
  Übergabe; `pre-commit-check` wiederholt grüne Läufe nicht
- `change-validation`: 3–6 Szenarien, ein Negativfall pro Screen; der Runner hält
  nur modulübergreifende Checks und Rendering

## Toolchain

- R 4.2.1; `C:\Program Files\R\R-4.2.1\bin` im User-PATH (neue Terminals nötig)
- renv 1.2.4 (global), Projekt-Library mit den eingefrorenen CRAN-4.2-Binaries
  (shiny 1.8.1.1, testthat 3.2.1.1, lintr 3.1.2, styler 1.10.3, covr 3.6.4,
  withr 3.0.0); Snapshot-Typ „all", 116 Pakete
- Stolpersteine: `renv::install()` holt für 4.2 unbrauchbare Builds → mit
  `install.packages(type = "binary")` installieren, dann `renv::snapshot()`;
  `Rscript -e` bricht unter Windows bei `|` im Ausdruck; `covr::file_coverage()`
  braucht `library(testthat); library(shiny)` vorweg; App aus dieser Umgebung per
  PowerShell `Start-Process` mit Log-Umleitung starten (Bash-Hintergrundtask hing),
  beenden mit `taskkill //F //IM Rterm.exe //T` in Git Bash
- Chrome-Automation wurde in dieser Session abgelehnt; Browser-Prüfungen sind manuell

## Next steps

1. `feat/figurenzeichner` nach `main` mergen (User-Entscheidung).
2. App einmal in RStudio/Browser bedienen und die vier Browser-only-Punkte aus
   `TODO.md` abhaken; dabei die README-Schritte gegenprüfen.
3. Block „Test-Redundanz abbauen" in `TODO.md` umsetzen (Runner eindampfen,
   Modul-Test-Fälle kürzen, ein Negativ-Szenario) — nach Freigabe.
4. Doku-Nachträge („Doku-Drift" in `TODO.md`) vom User bestätigen lassen.
