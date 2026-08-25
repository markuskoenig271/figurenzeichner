# TODO

Offene Arbeit und technische Schuld. Bei jedem Sessionstart prüfen.

---

## Doku-Drift (kleine Nachträge zur freigegebenen Baseline, User entscheidet)

- [ ] `docs/architecture.md`: Repository-Layout um `tests/e2e/run_scenarios.R`
  ergänzen; im Editor-Abschnitt `form_position` (reactiveVal, spiegelt die vom
  Server ins Formular geschriebene Position — nur für Tests) und die Top-Level-Helfer
  `editor_fill_form()`, `editor_toggle_buttons()`, `editor_status()`,
  `editor_set_size_labels()` nachziehen; `validate_figure()` ist in
  `validate_size/colour/bounds()` aufgeteilt
- [ ] `docs/architecture.md`: „Auswahl-Rahmen mit `SELECTION_PADDING = 2`" wurde am
  2026-08-25 direkt eingetragen (Befund aus der E2E-Validierung) — vom User
  bestätigen lassen

## Manuelle Browser-Prüfung (ohne Chrome-Automation nicht ausführbar)

- [ ] `.planning/e2e-tests/`: die nur im Browser sichtbaren Punkte einmal von Hand
  prüfen — Höhe-Feld beim Kreis ausgeblendet (`conditionalPanel`), Übernehmen/
  Löschen/Auswahl aufheben werden mit der Auswahl aktiv/inaktiv, Formular zeigt nach
  Klick die Figurwerte bzw. die Klickposition, Beschriftungen Radius/Δx/Δy
- [ ] Optional: `shinytest2`/`chromote` evaluieren, um diese Punkte zu automatisieren
  (braucht Chrome; Binaries für R 4.2 prüfen)

## Toolchain

- [ ] `renv::install()` zieht Binaries für neuere R-Versionen (shiny 1.14 mit
  fehlendem `otel`) und rollt dann zurück; Pakete deshalb mit
  `install.packages(..., type = "binary")` aus den eingefrorenen CRAN-4.2-Binaries
  installieren und danach `renv::snapshot()`. In `tdd-cycle`/`pre-commit-check`
  vermerken oder R aktualisieren (R ≥ 4.4 würde aktuelle Pakete erlauben)
- [ ] `renv::restore()` auf einem frischen Clone einmal durchspielen (Lockfile enthält
  116 Pakete, Snapshot-Typ „all")

## Ausserhalb des Repos (User-Aktion)

- [ ] Per-repo-Abschnitt `### Per-repo: figurenzeichner` in den globalen Auto-Mode-Block
  (`~/.claude/settings.json`) übernehmen — Entwurf lag am 2026-08-25 im Scratchpad
  des Template-Repos, `cp`-Kommando im Abschlussbericht
- [ ] Neue Terminals öffnen: `C:\Program Files\R\R-4.2.1\bin` steht seit 2026-08-25 im
  User-PATH, laufende Shells sehen es noch nicht
