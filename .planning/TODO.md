# TODO

Offene Arbeit und technische Schuld. Bei jedem Sessionstart prüfen.

---

## Vor dem ersten Code (Architecture first) — erledigt 2026-08-25

- [x] `docs/architecture.md` ausgefüllt (Base Graphics + `plotOutput(click=)`,
  logisches 0–100-Koordinatensystem, festes Figur-Schema, zentraler `state`)
- [x] `docs/ui_screens.md` ausgefüllt (Zeichenfläche, Editor mit Modi Neu/Bearbeiten,
  Fehlertabelle)
- [x] Design vom User freigegeben (2026-08-25)

## Toolchain (User-Aktion bzw. erste Session)

- [ ] `C:\Program Files\R\R-4.2.1\bin` auf den Windows-`PATH` — ohne das findet
  keine Skill-Kommandozeile `Rscript`, und der Format-Hook bleibt stumm
- [ ] renv einrichten: `install.packages("renv")`, dann `renv::init()`; danach
  `renv::install(c("shiny", "testthat", "lintr", "styler", "covr", "withr"))` und
  `renv::snapshot()`. Die globale Library ist unvollständig (kein renv/lintr/covr;
  `styler` bricht mit fehlendem `R.oo` ab)
- [ ] Skill-Kommandos gegen die Toolchain verifizieren: `testthat::test_dir()` ist
  gegen R 4.2.1 geprüft (Exit 0/1 korrekt); `lintr::lint_dir()`,
  `styler::style_dir(dry = "fail")`, `covr::file_coverage()` und
  `renv::snapshot()` sind **blind geschrieben** (Pakete fehlten beim Scaffold)
- [ ] `.lintr` anlegen (Linters, Zeilenlänge) und `.Rprofile` von renv committen

## Scaffold (erste Implementierungs-Session, nach Freigabe des Designs)

- [ ] `app.R`, `R/`, `tests/testthat/helper-source.R` anlegen; erster Test per
  `tdd-cycle` (z. B. Fläche eines Kreises)
- [ ] `README.md` mit Start-Kommando (`Rscript -e 'shiny::runApp()'`)

## Ausserhalb des Repos (User-Aktion)

- [ ] Per-repo-Abschnitt `### Per-repo: figurenzeichner` in den globalen Auto-Mode-Block
  (`~/.claude/settings.json`) übernehmen — Entwurf lag am 2026-08-25 im Scratchpad
  des Template-Repos, `cp`-Kommando im Abschlussbericht
