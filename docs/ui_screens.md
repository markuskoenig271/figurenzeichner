# Figurenzeichner — UI Screens

> Beschreibt die Oberfläche als Vertrag: Elemente, Übergänge, Fehlerzustände.
> `change-validation` leitet seine Akzeptanzszenarien hieraus ab. Komponenten und
> Zustand stehen in `architecture.md`; Änderungen zuerst hier, dann im Code.

Die App hat **eine Seite** (`fluidPage` + `sidebarLayout`): links der Figuren-Editor
(Sidebar), rechts die Zeichenfläche (Main). Beide sind immer sichtbar; es gibt keine
Navigation. Die „Screens" unten sind die beiden Bereiche plus ihre Zustände.

```text
┌──────────────────────────┬─────────────────────────────────────────────┐
│ Figur                    │                                             │
│ ─────────────────────    │   ┌─────────────────────────────────────┐   │
│ Typ        [Rechteck ▾]  │   │                                     │   │
│ x          [ 40   ]      │   │        ┌───────┐                    │   │
│ y          [ 60   ]      │   │        │       │  ○                 │   │
│ Breite     [ 20   ]      │   │        └───────┘                    │   │
│ Höhe       [ 10   ]      │   │              ╲                      │   │
│ Farbe      [#1F77B4]     │   │               ╲   ▲                 │   │
│                          │   │                   ╱ ╲               │   │
│ [Hinzufügen]             │   │                  ╱───╲              │   │
│ [Übernehmen] [Löschen]   │   │                                     │   │
│ [Auswahl aufheben]       │   └─────────────────────────────────────┘   │
│                          │                                             │
│ Ausgewählt: #2 (Kreis)   │   Figuren: 4                                │
│ ⚠ Höhe muss > 0 sein     │                                             │
└──────────────────────────┴─────────────────────────────────────────────┘
```

## 1. Zeichenfläche

**Zweck:** Zeigt alle Figuren der Session; per Klick wählt der Nutzer eine Figur aus
oder legt die Position für eine neue fest.

**Elemente**
- Quadratischer Plot 600 × 600 px, logische Koordinaten 0–100 in beiden Achsen,
  Ursprung links unten; dünner Rahmen um die Fläche, kein Gitter, keine Achsen
- Figuren in Z-Reihenfolge (zuletzt hinzugefügt liegt oben); Flächenfiguren gefüllt
  in ihrer Farbe mit dunklerem Rand, Linien als Strich in ihrer Farbe
- Ausgewählte Figur: zusätzlich gestrichelte Bounding Box
- Zähler „Figuren: n" unter dem Plot

**Übergänge**
- Klick auf eine Figur → sie wird ausgewählt (Bounding Box erscheint, Editor lädt
  ihre Werte, Editor-Modus „Bearbeiten"). Bei überlappenden Figuren trifft der Klick
  die oberste; Linien haben eine Toleranz von 2 Einheiten
- Klick ins Leere → Auswahl aufgehoben (Bounding Box verschwindet, Editor-Modus
  „Neu"), `x`/`y` im Editor werden auf die Klickposition gesetzt
- Jede Änderung der Zeichnung (Hinzufügen/Übernehmen/Löschen) zeichnet die Fläche
  sofort neu

**Fehlerzustände**
- Leere Zeichnung: nur Rahmen und „Figuren: 0" — kein Platzhaltertext, kein Fehler
- Neuladen der Seite: leere Zeichnung (keine Persistenz, gewollt)
- Klick außerhalb des Rahmens (Randbereich des Plots) verhält sich wie Klick ins
  Leere

## 2. Figuren-Editor

**Zweck:** Eine Figur anlegen oder die ausgewählte Figur verändern bzw. löschen.

**Elemente**
- `Typ` — Auswahl: Kreis · Rechteck · Dreieck · Linie (Standard: Rechteck)
- `x`, `y` — numerisch; Bedeutung je Typ: Mittelpunkt (Kreis, Rechteck, Dreieck)
  bzw. Startpunkt (Linie). Standard 50 / 50
- `w`, `h` — numerisch; Beschriftung wechselt mit dem Typ:

  | Typ | Beschriftung `w` | Beschriftung `h` |
  | --- | --- | --- |
  | Kreis | Radius | *(ausgeblendet)* |
  | Rechteck | Breite | Höhe |
  | Dreieck | Basisbreite | Höhe |
  | Linie | Δx | Δy |

  Standard 20 / 10
- `Farbe` — Textfeld, Hex (`#1F77B4`) oder R-Farbname (`steelblue`); Standard
  `#1F77B4`
- **Hinzufügen** — immer aktiv
- **Übernehmen**, **Löschen** — nur aktiv, wenn eine Figur ausgewählt ist
- **Auswahl aufheben** — nur aktiv, wenn eine Figur ausgewählt ist
- Statuszeile: „Neue Figur" oder „Ausgewählt: #<id> (<Typ>)"
- Fehlerbereich: Liste der Validierungsmeldungen, leer wenn alles gültig

**Modi**

| Modus | Bedingung | Formular | Buttons |
| --- | --- | --- | --- |
| Neu | keine Auswahl | behält letzte Werte; `x`/`y` folgen dem Klick ins Leere | Hinzufügen |
| Bearbeiten | Figur ausgewählt | zeigt die Werte der Figur | Hinzufügen, Übernehmen, Löschen, Auswahl aufheben |

**Übergänge**
- **Hinzufügen** (gültig) → Figur erscheint auf der Fläche, wird sofort ausgewählt
  (Modus „Bearbeiten"), Zähler +1, Fehlerbereich leer
- **Übernehmen** (gültig) → Figur wird an ihrer Position in der Z-Reihenfolge
  ersetzt, bleibt ausgewählt, Fläche neu gezeichnet. Der Typ darf dabei wechseln
- **Löschen** → Figur verschwindet, Auswahl aufgehoben (Modus „Neu"), Zähler −1,
  Formular behält die Werte der gelöschten Figur
- **Auswahl aufheben** → Modus „Neu", Formular behält die Werte
- Typwechsel → Beschriftungen von `w`/`h` wechseln sofort; Werte bleiben stehen
- Auswahl auf der Fläche (siehe Screen 1) → Modus „Bearbeiten", Formular geladen

**Fehlerzustände** — geprüft bei *Hinzufügen* und *Übernehmen*; im Fehlerfall bleibt
die Zeichnung unverändert, die Auswahl bleibt, und alle zutreffenden Meldungen
werden gleichzeitig angezeigt:

| Eingabe | Meldung |
| --- | --- |
| `x`, `y`, `w` oder `h` leer / keine Zahl | „x muss eine Zahl sein" (Feldname jeweils eingesetzt) |
| `w ≤ 0` bei Kreis / Rechteck / Dreieck | „Radius muss größer als 0 sein" bzw. „Breite …" / „Basisbreite …" |
| `h ≤ 0` bei Rechteck / Dreieck | „Höhe muss größer als 0 sein" |
| Linie mit `Δx = 0` und `Δy = 0` | „Linie muss eine Länge größer als 0 haben" |
| Farbe unbekannt (`col2rgb()` scheitert) | „Farbe ‚xyz' ist keine gültige Farbe" |
| Figur ragt über die Fläche hinaus (Bounding Box nicht in 0–100) | „Figur liegt nicht vollständig auf der Zeichenfläche (0–100)" |

Weitere Fälle:
- **Übernehmen** / **Löschen** ohne Auswahl: Buttons sind deaktiviert, kein Effekt
- Ausgewählte Figur existiert nicht mehr (kann nur durch einen Programmfehler
  passieren): Editor fällt in Modus „Neu" zurück, keine Meldung
- Ein Fehlerbereich wird beim nächsten erfolgreichen Hinzufügen/Übernehmen, beim
  Wechsel der Auswahl und bei „Auswahl aufheben" geleert

## Nicht vorhanden (absichtlich)

Kein Speichern/Laden, kein Export, kein Undo, kein Drag & Drop, keine Rotation,
keine Mehrfachauswahl, kein „Alles löschen" (Neuladen der Seite tut das).
