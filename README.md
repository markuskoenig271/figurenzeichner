# Figurenzeichner

Ein simples R-Shiny-UI, in dem man geometrische Figuren (Kreis, Rechteck, Dreieck,
Linie) auf einer Zeichenfläche anlegen, per Klick auswählen, verändern und löschen
kann. Die Zeichnung lebt nur in der laufenden Session — kein Speichern, kein Export.

## Schritt für Schritt aus RStudio starten

Voraussetzung: R 4.2.x und RStudio sind installiert.

1. **Repo holen** — in einem Terminal (oder in RStudio unter *File › New Project ›
   Version Control › Git*, Repository-URL eintragen):

   ```bash
   git clone https://github.com/markuskoenig271/figurenzeichner.git
   ```

2. **Als Projekt öffnen** — in RStudio *File › New Project › Existing Directory*,
   den Ordner `figurenzeichner` wählen, *Create Project*. RStudio legt dabei eine
   `.Rproj`-Datei an (ist per `.gitignore` ausgeschlossen, das ist gewollt).
   Beim nächsten Mal reicht *File › Open Project*.

3. **Pakete herstellen** — beim Öffnen liest RStudio die `.Rprofile`, `renv`
   aktiviert sich selbst und meldet in der Konsole, dass die Projekt-Library noch
   nicht zum Lockfile passt. Einmal in der Konsole ausführen:

   ```r
   renv::restore()
   ```

   Nachfrage mit `y` bestätigen. Das installiert `shiny` und die Entwicklungspakete
   in `renv/library/` (dauert beim ersten Mal ein paar Minuten, danach nie wieder).

4. **App starten** — `app.R` im Editor öffnen und oben rechts auf **Run App**
   klicken, oder in der Konsole:

   ```r
   shiny::runApp()
   ```

   RStudio öffnet die App im Viewer bzw. im Browser. Mit dem Stop-Symbol in der
   Konsole (oder `Esc`) wird sie beendet.

5. **Prüfen, dass alles läuft** (optional) — in der Konsole:

   ```r
   testthat::test_dir("tests/testthat")
   ```

   Erwartet: `FAIL 0`.

Falls in Schritt 3 keine renv-Meldung erscheint, ist das Projekt nicht als Projekt
geöffnet (Working Directory prüfen mit `getwd()`, es muss der Repo-Ordner sein);
dann `source("renv/activate.R")` ausführen und mit `renv::restore()` fortfahren.

## Starten von der Kommandozeile

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
