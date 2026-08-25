# E2E-Szenarien

Akzeptanzszenarien aus `change-validation`, abgeleitet aus `docs/ui_screens.md`.
Eine Datei je Szenario.

## Ausführung

Ohne Browser-Automation werden die Abläufe gegen die ganze App (`app.R`, beide
Module) per `shiny::testServer()` gefahren; die Canvas-Zustände werden als PNG
gerendert und gesichtet:

```bash
Rscript tests/e2e/run_scenarios.R
```

Nicht abgedeckt (nur im Browser prüfbar): Ausblenden des Höhe-Felds beim Kreis
(`conditionalPanel`), Aktiv/Inaktiv der Buttons nach `updateActionButton`, die vom
Server ins Formular geschriebenen Werte (`updateNumericInput`). Diese Punkte
manuell im Browser prüfen: `Rscript -e 'shiny::runApp(port = 3838)'`.
