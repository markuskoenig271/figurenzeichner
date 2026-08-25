# Ungültige Eingaben werden gemeldet, die Zeichnung bleibt unverändert

**Betrifft:** Figuren-Editor (Fehlerbereich), Zeichenfläche
**Warum:** Der Nutzer muss verstehen, warum seine Figur nicht erscheint — mit allen
Gründen auf einmal, ohne dass etwas Halbes auf der Fläche landet.

## Vorbedingungen
- App gestartet, eine Figur vorhanden (#1 Rechteck), keine Auswahl

## Schritte
1. Typ Rechteck, Breite 0, Farbe `nope` → **Hinzufügen**
2. Breite 20, Farbe `#1F77B4`, x leer lassen → **Hinzufügen**
3. x 50, Typ Kreis, Radius 60 → **Hinzufügen**
4. Typ Linie, Δx 0, Δy 0 → **Hinzufügen**
5. Typ Rechteck, x 50, y 50, Breite 20, Höhe 10, Farbe `#1F77B4` → **Hinzufügen**

## Erwartetes Ergebnis
- Nach 1: zwei Meldungen gleichzeitig — „Breite muss größer als 0 sein" und „Farbe
  „nope“ ist keine gültige Farbe"; „Figuren: 1" unverändert
- Nach 2: „x muss eine Zahl sein"
- Nach 3: „Figur liegt nicht vollständig auf der Zeichenfläche (0–100)"
- Nach 4: „Linie muss eine Länge größer als 0 haben"
- Nach 5: Figur erscheint, Fehlerbereich ist leer, „Figuren: 2"
- Zu keinem Zeitpunkt erscheint eine halb gültige Figur auf der Fläche

## Negativfall
- Meldung steht, dann Klick auf eine Figur -> Fehlerbereich wird geleert
