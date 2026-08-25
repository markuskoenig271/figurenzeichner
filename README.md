# Figurenzeichner

Ein simples R-Shiny-UI, in dem man geometrische Figuren (Kreis, Rechteck, Dreieck,
Linie) auf einer Zeichenfläche anlegen, per Klick auswählen, verändern und löschen
kann. Die Zeichnung lebt nur in der laufenden Session — kein Speichern, kein Export.

## Starten

Voraussetzung: R 4.2.x, `Rscript` im `PATH`. Beim ersten Start die Projekt-Library
herstellen:

```bash
Rscript -e 'renv::restore()'
```

Dann aus dem Repo-Root:

```bash
Rscript -e 'shiny::runApp(port = 3838)'
```

und im Browser <http://127.0.0.1:3838> öffnen.

## Bedienung

- Links im Editor Typ, Position (`x`, `y`), Größe und Farbe eingeben, **Hinzufügen**
- Klick auf eine Figur wählt sie aus; **Übernehmen** schreibt die Formularwerte
  zurück, **Löschen** entfernt sie
- Klick ins Leere hebt die Auswahl auf und setzt `x`/`y` auf die Klickposition
- Die Fläche ist 0–100 × 0–100, Ursprung links unten; Figuren müssen vollständig
  darauf liegen

## Entwicklung

```bash
Rscript -e 'testthat::test_dir("tests/testthat")'
Rscript -e 'l <- lintr::lint_dir(); print(l); quit(status = length(l) > 0)'
Rscript -e 'styler::style_dir(dry = "fail")'
```

Design in `docs/architecture.md` und `docs/ui_screens.md`, Arbeitsregeln in
`CLAUDE.md`.
