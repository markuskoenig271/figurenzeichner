# Überlappende Figuren: Klick trifft die oberste

**Betrifft:** Zeichenfläche (Klick, Z-Reihenfolge)
**Warum:** Bei übereinanderliegenden Figuren erwartet der Nutzer, dass er die sichtbare
(obere) Figur anfasst, nicht die verdeckte.

## Vorbedingungen
- Leere Fläche

## Schritte
1. Rechteck x 50, y 50, Breite 40, Höhe 40 → **Hinzufügen** (#1)
2. Kreis x 50, y 50, Radius 8, Farbe `tomato` → **Hinzufügen** (#2)
3. **Auswahl aufheben**
4. In die Mitte der Fläche klicken (auf den Kreis)
5. In eine Ecke des Rechtecks klicken, außerhalb des Kreises (ca. 35/35)

## Erwartetes Ergebnis
- Der Kreis liegt sichtbar über dem Rechteck
- Nach 4: Status „Ausgewählt: #2 (Kreis)", Bounding Box um den Kreis
- Nach 5: Status „Ausgewählt: #1 (Rechteck)", Bounding Box um das Rechteck

## Negativfall
- Klick knapp neben einer dünnen Linie (mehr als 2 Einheiten entfernt) -> keine
  Auswahl; Klick innerhalb von 2 Einheiten -> Linie wird ausgewählt
