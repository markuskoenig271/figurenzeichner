# Figur per Klick auswählen und bearbeiten

**Betrifft:** Zeichenfläche (Klick) → Figuren-Editor (Modus „Bearbeiten")
**Warum:** Der Nutzer will eine vorhandene Figur anfassen und ihre Werte ändern,
ohne sie neu anlegen zu müssen.

## Vorbedingungen
- Zwei Figuren vorhanden: #1 Rechteck (40, 60, 20×10), #2 Kreis (70, 30, r 10)
- Keine Auswahl (z. B. nach **Auswahl aufheben**)

## Schritte
1. Auf das Rechteck klicken (Bildmitte des Rechtecks)
2. Formular prüfen
3. Breite auf 30, Farbe auf `steelblue` ändern → **Übernehmen**
4. Auf den Kreis klicken

## Erwartetes Ergebnis
- Nach 1: gestrichelte Bounding Box um das Rechteck, Status „Ausgewählt: #1
  (Rechteck)"; **Übernehmen**, **Löschen**, **Auswahl aufheben** aktiv
- Nach 2: Formular zeigt Typ Rechteck, x 40, y 60, Breite 20, Höhe 10, Farbe `#1F77B4`
- Nach 3: Rechteck ist breiter und stahlblau, bleibt ausgewählt, „Figuren: 2"
  unverändert
- Nach 4: Bounding Box wandert zum Kreis, Status „#2 (Kreis)", Formular zeigt die
  Kreiswerte, Größenfeld heißt „Radius"

## Negativfall
- Übernehmen mit x 95 (Rechteck ragt rechts hinaus) -> Meldung „Figur liegt nicht
  vollständig auf der Zeichenfläche (0–100)", Figur unverändert, Auswahl bleibt
