# Figurenzeichner — Architecture

> Design-Baseline. Änderungen am Design werden **zuerst hier** eingetragen, dann
> umgesetzt (Architecture first, siehe `CLAUDE.md`). Die Screens stehen in
> `ui_screens.md`, die Spec in `.planning/PROJECT.md`.

## Overview

Figurenzeichner ist eine lokal gestartete Shiny-App mit einer quadratischen
Zeichenfläche, auf der parametrische Figuren (Kreis, Rechteck, Dreieck, Linie)
angelegt, per Klick ausgewählt, im Editor verändert und wieder gelöscht werden.
Die gesamte Rechnung — Datenstruktur einer Figur, Validierung, Umriss, Trefferprüfung —
liegt in reinen R-Funktionen; Shiny hält nur den Session-Zustand und stellt ihn dar.
Es gibt keine Persistenz: Neuladen der Seite ist eine leere Zeichenfläche.

## Goals / Non-Goals

- Figuren anlegen, verändern, löschen — Typ, Position, Größe, Farbe
- Figur auf der Fläche per Klick auswählen
- Geometrie vollständig ohne Shiny testbar (testthat), reaktive Logik mit
  `shiny::testServer()` testbar, ohne Browser
- Minimale Abhängigkeiten: zur Laufzeit nur `shiny` und Base-Graphics
- **Non-Goal:** Persistenz, Export, Undo/Redo
- **Non-Goal:** Drag & Drop, Freihand, Rotation — Figuren werden über Formfelder verändert
- **Non-Goal:** Mehrbenutzer, Deployment, Authentifizierung

## High-Level Architecture

Drei Schichten, Abhängigkeiten nur von oben nach unten:

```text
┌──────────────────────────────────────────────────────────────────┐
│ app.R              shinyApp(ui, server)                          │
│                    server: state <- reactiveValues(drawing,      │
│                            selected, click)                      │
│   ┌────────────────────────┐     ┌────────────────────────────┐  │
│   │ mod_canvas             │     │ mod_editor                 │  │
│   │ plotOutput + click     │     │ Formular, Add/Update/      │  │
│   │ → state$selected/click │     │ Delete → state$drawing     │  │
│   └───────────┬────────────┘     └──────────────┬─────────────┘  │
│               │ liest state, ruft reine Funktionen               │
├───────────────┼─────────────────────────────────┼────────────────┤
│ R/render.R    ▼                                 ▼                │
│   draw_canvas(drawing, selected)      (kein Zustand, nur Grafik) │
├──────────────────────────────────────────────────────────────────┤
│ R/drawing.R   drawing_new/add/update/remove/get/hit              │
│ R/geometry.R  figure_outline, figure_bbox, figure_contains, area │
│ R/figure.R    figure(), validate_figure(), FIGURE_TYPES, CANVAS  │
│               reine Funktionen: plain R rein, plain R raus       │
└──────────────────────────────────────────────────────────────────┘
```

**Datenfluss einer Interaktion**

1. Nutzer klickt auf die Fläche → `input$canvas_click` liefert `x`/`y` bereits in
   Zeichenflächen-Koordinaten (Base-Graphics-`plotOutput` rechnet Pixel um).
2. `mod_canvas` ruft `drawing_hit(state$drawing, x, y)` → Id der obersten getroffenen
   Figur oder `NULL`; schreibt `state$selected` und `state$click`.
3. `mod_editor` beobachtet `state$selected` und füllt das Formular mit der Figur
   (`drawing_get`), bzw. übernimmt bei Klick ins Leere die Position aus `state$click`.
4. Nutzer ändert Felder, drückt „Übernehmen" → `mod_editor` baut mit `figure()` eine
   Figur, prüft sie mit `validate_figure()`; bei Fehlern werden die Meldungen
   angezeigt und der Zustand bleibt unverändert, sonst
   `state$drawing <- drawing_update(...)`.
5. `mod_canvas` rendert reaktiv `draw_canvas(state$drawing, state$selected)` neu.

Der Zustand lebt an genau einer Stelle (`state` in `app.R`), die Module bekommen
ihn als Referenz. Die reinen Funktionen sind zustandslos und kennen weder `input`
noch `session`.

## Repository Layout

```text
figurenzeichner/
├── .claude/              # skills, hooks, settings
├── .planning/            # PROJECT / TODO / STATE, e2e-tests/
├── docs/                 # dieses Dokument, ui_screens.md
├── app.R                 # Einstieg: ui + server, legt state an, bindet Module ein
├── R/
│   ├── figure.R          # Datenstruktur, Konstanten, Validierung
│   ├── geometry.R        # Umriss, Bounding Box, Trefferprüfung, Fläche
│   ├── drawing.R         # Sammlung von Figuren (Z-Reihenfolge, Ids)
│   ├── render.R          # Base-Graphics-Zeichnung (einziger Ort mit Grafikcode)
│   ├── mod_canvas.R      # Shiny-Modul Zeichenfläche
│   └── mod_editor.R      # Shiny-Modul Figuren-Editor
├── tests/testthat/
│   ├── helper-source.R   # sourced R/*.R
│   ├── test-figure.R, test-geometry.R, test-drawing.R, test-render.R
│   └── test-mod_canvas.R, test-mod_editor.R      # shiny::testServer()
├── renv.lock, .Rprofile  # renv-Projektlibrary (renv/library/ ist gitignored)
└── .lintr
```

Shiny lädt `R/` beim Start automatisch (`app.R`-Layout), daher kein `source()` in
`app.R`. Zur Laufzeit wird nur `shiny` geladen; `grDevices`/`graphics` sind Base R.

## Components

### Zeichenfläche und Koordinaten (Konstanten in `R/figure.R`)

Die Fläche ist ein logisches Quadrat `CANVAS = c(0, 100)` in beiden Achsen, Ursprung
**links unten** (Base-Graphics-Konvention), Seitenverhältnis 1:1 (`asp = 1`).
Alle Positionen und Größen der Figuren sind in diesen Einheiten; Pixel kommen
nirgends im Code vor. Damit sind Tests deterministisch und unabhängig von der
Plot-Größe im Browser.

### Figur (`R/figure.R`)

Eine Figur ist eine benannte Liste mit Klasse `"figure"` und **festem Schema**,
unabhängig vom Typ:

```r
structure(list(
  id     = 3L,          # NA_integer_ bis drawing_add() eine Id vergibt
  type   = "rect",      # eines von FIGURE_TYPES: "circle" | "rect" | "triangle" | "line"
  x = 40, y = 60,       # Ankerpunkt
  w = 20, h = 10,       # Ausdehnung
  colour = "#1F77B4"    # Füll-/Linienfarbe, jede von grDevices::col2rgb() akzeptierte Angabe
), class = "figure")
```

Bedeutung von Anker und Ausdehnung je Typ:

| Typ | `x`, `y` | `w` | `h` |
| --- | --- | --- | --- |
| `circle` | Mittelpunkt | Radius | ignoriert; Konstruktor setzt `h <- w` |
| `rect` | Mittelpunkt | Breite | Höhe |
| `triangle` | Mittelpunkt der Bounding Box | Basisbreite (Basis unten) | Höhe (gleichschenklig, Spitze oben) |
| `line` | Startpunkt | Δx zum Endpunkt | Δy zum Endpunkt (beide dürfen negativ sein) |

Schnittstelle:

- `figure(type, x, y, w, h = w, colour = "#1F77B4", id = NA_integer_)` — Konstruktor,
  wirft **nicht**, sondern liefert immer eine Figur; Prüfung ist Sache von
  `validate_figure()`, damit der Editor fehlerhafte Eingaben *anzeigen* kann.
- `validate_figure(fig)` — liefert `character(0)` bei gültiger Figur, sonst einen
  Vektor lesbarer Fehlermeldungen (deutsch, eine je Regel). Regeln:
  Typ bekannt; `x, y, w, h` endliche Zahlen; `w > 0` und `h > 0` für
  `circle`/`rect`/`triangle`; Linie mit Länge `> 0`; Farbe von `col2rgb()` akzeptiert;
  Bounding Box vollständig innerhalb `CANVAS`.
- `is_figure(x)`.

**Warum festes Schema statt typabhängiger Felder:** ein Validator, ein Formular
(nur die Feldbeschriftungen wechseln mit dem Typ), ein `drawing_update()` ohne
Fallunterscheidung. Der Preis ist die etwas unschöne Semantik `w = Radius` beim Kreis
— dokumentiert, lokal begrenzt.

### Geometrie (`R/geometry.R`)

Reine Funktionen über einer Figur; keine Grafik, kein Shiny.

- `figure_outline(fig, n = 64L)` — `data.frame(x, y)` der Umrisspunkte in
  Zeichenreihenfolge: Rechteck 4 Ecken, Dreieck 3, Kreis `n` Punkte, Linie 2 Punkte.
  Einziger Ort, der die Typ-Semantik aus der Tabelle oben in Koordinaten übersetzt;
  Renderer und Bounding Box bauen darauf auf.
- `figure_bbox(fig)` — `c(xmin, ymin, xmax, ymax)` aus dem Umriss (Kreis exakt aus
  Radius).
- `figure_contains(fig, px, py, tol = 2)` — Trefferprüfung: Kreis exakt über den
  Abstand zum Mittelpunkt, Rechteck/Dreieck per Punkt-in-Polygon über den Umriss,
  Linie über den Abstand zum Segment `<= tol` (in Flächeneinheiten).
- `figure_area(fig)` — Fläche (Linie: 0). Nicht vom UI gebraucht, aber der erste
  Test im `tdd-cycle` und die Vorlage für weitere reine Funktionen.

### Zeichnung (`R/drawing.R`)

Geordnete Sammlung von Figuren; die Reihenfolge ist die Z-Reihenfolge (zuletzt
hinzugefügt liegt oben). Immutable: jede Operation liefert eine neue Zeichnung.

```r
list(figures = list(<figure>, ...), next_id = 4L)   # Klasse "drawing"
```

- `drawing_new()`
- `drawing_add(drawing, fig)` — vergibt `next_id` als `id`, hängt hinten an
- `drawing_update(drawing, fig)` — ersetzt die Figur mit `fig$id` an ihrer Position
  (Z-Reihenfolge bleibt); unbekannte Id ist ein Fehler
- `drawing_remove(drawing, id)`
- `drawing_get(drawing, id)` — Figur oder `NULL`
- `drawing_ids(drawing)`
- `drawing_hit(drawing, px, py)` — Id der **obersten** Figur, die
  `figure_contains()` erfüllt, sonst `NULL`

Die Funktionen prüfen nicht erneut die Gültigkeit einer Figur; das ist vor dem
Aufruf Sache des Editors (`validate_figure()`).

### Rendering (`R/render.R`)

Einziger Ort mit Grafikcode. Base Graphics, kein ggplot2.

- `draw_canvas(drawing, selected = NULL)` — öffnet ein Koordinatensystem
  `plot.window(xlim = CANVAS, ylim = CANVAS, asp = 1)` ohne Ränder, zeichnet einen
  Rahmen und alle Figuren in Z-Reihenfolge; die ausgewählte Figur bekommt zusätzlich
  eine gestrichelte Bounding Box. Leere Zeichnung: nur der Rahmen.
- `draw_figure(fig)` — `polygon()` über `figure_outline()` für Flächenfiguren
  (Füllung in `colour`, dunklerer Rand), `segments()` für Linien.

Beide Funktionen sind nebenwirkungsfrei bis auf das aktive Grafikgerät und daher
unter einem Null-Device testbar (`pdf(NULL)`); die Tests prüfen, dass sie für jeden
Figurentyp, für leere Zeichnungen und mit `selected` fehlerfrei durchlaufen. Was
tatsächlich zu sehen ist, prüft `change-validation` im Browser.

### Session-Zustand (`app.R`)

```r
state <- reactiveValues(
  drawing  = drawing_new(),   # die Zeichnung
  selected = NULL,            # Id der ausgewählten Figur oder NULL
  click    = NULL             # letzte Klickposition c(x, y) oder NULL
)
```

`app.R` erzeugt `state`, ruft `canvas_server("canvas", state)` und
`editor_server("editor", state)` auf; sonst nichts. Das UI ist ein `fluidPage` mit
`sidebarLayout`: Editor links (Sidebar), Fläche rechts (Main). Details in
`ui_screens.md`.

**Warum `reactiveValues` als Referenz statt Modul-Rückgabewerte:** beide Module
lesen *und* schreiben denselben Zustand (Canvas setzt `selected`, Editor ändert
`drawing` und hebt die Auswahl nach dem Löschen auf). Ein gemeinsames
`reactiveValues`-Objekt ist dafür die einfachste Form ohne Rückkopplungs-Verdrahtung
und lässt sich in `testServer()` direkt inspizieren. Bei mehr als zwei Modulen wäre
das zu überdenken.

### Modul Zeichenfläche (`R/mod_canvas.R`)

- `canvas_ui(id)` — `plotOutput(ns("plot"), click = ns("click"), width/height =
  "600px")`, quadratisch, passend zu `asp = 1`; darunter `textOutput(ns("count"))`.
- `canvas_server(id, state)` —
  - `output$plot <- renderPlot(draw_canvas(state$drawing, state$selected))`
  - `output$count <- renderText(sprintf("Figuren: %d", length(drawing_ids(...))))`
  - `observeEvent(input$click, ...)`: `state$click <- c(x, y)`;
    `state$selected <- drawing_hit(state$drawing, x, y)` (Klick ins Leere → `NULL`,
    also Auswahl aufheben)

Gibt nichts zurück. Test mit `testServer()`: `session$setInputs(click = list(x =,
y =))` und Assertions auf `state$selected`/`state$click`.

### Modul Figuren-Editor (`R/mod_editor.R`)

- `editor_ui(id)` — `selectInput` Typ, `numericInput` `x`, `y`, `w`, `h`,
  `textInput` Farbe, Buttons **Hinzufügen**, **Übernehmen**, **Löschen**,
  **Auswahl aufheben**, `uiOutput` für Fehlermeldungen und die Info „Ausgewählt:
  #<id> (<Typ>)".
- `editor_server(id, state)` —
  - beobachtet `state$selected`: Figur geladen → Formular gefüllt, „Übernehmen"/
    „Löschen"/„Auswahl aufheben" aktiv; `NULL` → Formular behält seine Werte, nur
    diese drei Buttons werden deaktiviert; Fehlerbereich wird geleert
  - beobachtet `state$click`: ohne Auswahl werden `x`/`y` des Formulars auf die
    Klickposition gesetzt (schnelles Platzieren)
  - beobachtet `input$type`: Beschriftungen von `w`/`h` wechseln
    (Radius · Breite/Höhe · Δx/Δy), `h` beim Kreis ausgeblendet
  - **Hinzufügen:** `fig <- figure(...)`, `errs <- validate_figure(fig)`; bei Fehlern
    anzeigen, sonst `state$drawing <- drawing_add(...)` und die neue Figur auswählen
  - **Übernehmen:** wie Hinzufügen, aber mit `id = state$selected` und
    `drawing_update()`
  - **Löschen:** `drawing_remove()`, danach `state$selected <- NULL`
  - **Auswahl aufheben:** `state$selected <- NULL`

Der Editor ist der **einzige** Schreiber von `state$drawing`. Validierung findet
ausschließlich über `validate_figure()` statt; das Modul formatiert nur.

## Testing Strategy

| Schicht | Werkzeug | Was |
| --- | --- | --- |
| `figure.R`, `geometry.R`, `drawing.R` | testthat, reine Unit-Tests | Konstruktor, alle Validierungsregeln, Umrisse/Bounding Boxen mit bekannten Zahlen, Trefferprüfung innen/außen/Rand/Toleranz, Z-Reihenfolge bei `drawing_hit`, Id-Vergabe |
| `render.R` | testthat unter `pdf(NULL)` | läuft für jeden Typ, leer, mit Auswahl fehlerfrei durch |
| `mod_canvas.R`, `mod_editor.R` | `shiny::testServer()` | Klick setzt Auswahl/Position; Add/Update/Delete verändern `state$drawing` korrekt; ungültige Eingabe lässt `state` unverändert und liefert Meldungen |
| Sichtbares Verhalten | `change-validation` (Browser) | Szenarien aus `ui_screens.md`, abgelegt in `.planning/e2e-tests/` |

Coverage-Ziel 75 % über `R/`; `app.R` ist nicht im Nenner.

## Key Decisions

| Entscheidung | Gewählt | Warum | Datum |
| --- | --- | --- | --- |
| Darstellungstechnik | Base Graphics in `renderPlot()`, Klicks über `plotOutput(click=)` | Keine Zusatzabhängigkeit (kein ggplot2, kein JS/htmlwidgets); Klicks kommen bereits in Datenkoordinaten an, Trefferprüfung bleibt reines R und ist unit-testbar; Rendering unter `pdf(NULL)` testbar. Preis: Neuzeichnen bei jeder Änderung (bei einer Handvoll Figuren irrelevant), kein Drag & Drop (Non-Goal) | 2026-08-25 |
| Logisches Koordinatensystem | Quadrat 0–100, Ursprung links unten, `asp = 1` | Pixelunabhängig, deterministische Tests, Validierung „innerhalb der Fläche" ist eine Zahlenprüfung | 2026-08-25 |
| Figur mit festem Schema | `id, type, x, y, w, h, colour` für alle Typen | Ein Validator, ein Formular, kein typabhängiges Update; Semantik je Typ tabellarisch dokumentiert | 2026-08-25 |
| Validierung liefert Meldungen statt zu werfen | `validate_figure()` → `character(0)` oder Fehlertexte | Der Editor muss Fehler anzeigen, nicht abstürzen; Regeln einzeln testbar | 2026-08-25 |
| Zustand zentral in `reactiveValues` | `state` in `app.R`, Module bekommen die Referenz | Beide Module lesen und schreiben dieselben Werte; kein Rückgabewert-Geflecht, direkt in `testServer()` inspizierbar | 2026-08-25 |
| Zeichnung immutable | `drawing_*()` geben neue Objekte zurück | Reine Funktionen ohne versteckten Zustand; Reaktivität wird durch Zuweisung an `state$drawing` ausgelöst | 2026-08-25 |
| Auswahl nur per Klick, Bearbeitung nur per Formular | kein Drag & Drop | Hält Modul-Logik und E2E-Szenarien klein; Position lässt sich per Klick ins Leere vorbelegen | 2026-08-25 |
