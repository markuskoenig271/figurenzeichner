# Project State

Rollender „wo ich aufgehört habe"-Stand (committet). Wird jede Session überschrieben.
Zusammen mit `TODO.md` bei jedem Sessionstart lesen. Spec in `PROJECT.md`.

---

## Last updated: 2026-08-25 (Session 0 — Scaffold aus dem Template)

## Headline

Neues Repo, noch kein Code. Struktur aus `AA_Sample_Claude_Repo` per `/new-project`
übertragen: Skills, Hooks, Settings, `.gitignore`, Planning-Dateien und die
Doku-Skelette. Kein `app.R`, kein `R/`, keine Tests, kein `renv`.

## Architecture first — NICHT erfüllt

`docs/architecture.md` und `docs/ui_screens.md` sind Skelette mit
`<Komponente>`/`<Screen>`-Platzhaltern. Das Design ist nicht geschrieben und nicht
freigegeben. **Vor der ersten Implementierung** müssen beide Dokumente ausgefüllt und
vom User abgenommen sein (erster Block in `TODO.md`).

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

## Next steps

1. `Rscript` auf den PATH, `renv::init()`, Pakete installieren, `renv::snapshot()`
   (siehe `TODO.md`, Block „Toolchain").
2. `docs/architecture.md` und `docs/ui_screens.md` schreiben und freigeben lassen.
3. Erst danach: `app.R`/`R/`/`tests/` per `tdd-cycle` anlegen.
