# Figurenzeichner — Project

Spec des Projekts. Ändert sich selten; der rollende Stand steht in `STATE.md`, offene
Arbeit in `TODO.md`.

---

## Definition

**Figurenzeichner** ist ein simples R-Shiny-UI, in dem man geometrische Figuren
(Kreis, Rechteck, Dreieck, Linie, …) auf einer Zeichenfläche platzieren, verändern
und wieder entfernen kann. Die Zeichnung lebt nur in der laufenden Session.

## Scope

- Eine Zeichenfläche im Browser, lokal gestartet mit `shiny::runApp()`
- Figuren anlegen (Typ, Position, Größe, Farbe), bearbeiten und löschen
- Die Geometrie (Punkte, Flächen, Transformationen, Datenstruktur einer Figur) als
  reine R-Funktionen in `R/`, unabhängig von Shiny testbar
- Reaktive Logik in Shiny-Modulen, testbar mit `shiny::testServer()`

## Non-Goals

- **Keine Persistenz** — kein Speichern/Laden, kein Export, keine Datenbank
- **Kein Deployment** — läuft nur lokal; kein shinyapps.io, kein Posit Connect
- Kein Mehrbenutzer-Betrieb, keine Authentifizierung
- Kein Freihand-Zeichnen; nur parametrische geometrische Figuren

## Stack

| Bereich | Wahl |
| --- | --- |
| Sprache | R (lokal installiert: 4.2.1) |
| UI | Shiny |
| Paketverwaltung | renv (Lockfile im Repo) |
| Tests | testthat (Unit), `shiny::testServer()` (reaktive Logik), `change-validation` (E2E über den Browser) |
| Qualität | lintr, styler, covr (Ziel 75 % über `R/`) |
| Deployment | keins — `shiny::runApp()` lokal |

## Key Decisions

| Entscheidung | Gewählt | Warum | Datum |
| --- | --- | --- | --- |
| Repo öffentlich | `markuskoenig271/figurenzeichner`, public | Vom User so entschieden; keine sensiblen Daten im Projekt. Konsequenz: nie Secrets, nie persönliche Daten committen | 2026-08-25 |
| Keine Persistenz | Zeichnung nur in der Session | Hält das Projekt simpel; Export wäre ein späterer, eigener Scope | 2026-08-25 |
| Shiny-App-Layout statt R-Package | `app.R` + `R/` (von Shiny automatisch geladen) + `tests/testthat/` | Simple App, kein Package-Overhead (kein `DESCRIPTION`, kein `devtools`); testthat/covr laufen über `test_dir()` / `file_coverage()`. Revidierbar, wenn Module wiederverwendet werden sollen | 2026-08-25 |
| Geometrie ohne Shiny | reine Funktionen in `R/`, Shiny nur als Darstellung | TDD-Regel: Rechnung muss ohne laufende Session testbar sein | 2026-08-25 |
| renv | Projekt-Library mit `renv.lock` | Reproduzierbar; globale R-Library ist unvollständig (`styler` ohne `R.oo`), Projekt-Library umgeht das | 2026-08-25 |
| Regeln aus dem Template | TDD verpflichtend, Architecture first, E2E-Validierung | „Best Practice" laut Interview — alle drei übernommen | 2026-08-25 |
