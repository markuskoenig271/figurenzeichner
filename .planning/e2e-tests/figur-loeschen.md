# Figur löschen

**Betrifft:** Figuren-Editor (Löschen) → Zeichenfläche
**Warum:** Der Nutzer will eine Figur wieder loswerden, ohne die anderen zu verlieren.

## Vorbedingungen
- Zwei Figuren vorhanden: #1 Rechteck, #2 Kreis

## Schritte
1. Auf den Kreis klicken
2. **Löschen**

## Erwartetes Ergebnis
- Kreis verschwindet, Rechteck bleibt
- „Figuren: 1", Status „Neue Figur", keine Bounding Box
- **Übernehmen**, **Löschen**, **Auswahl aufheben** deaktiviert
- Formular behält die Werte des gelöschten Kreises

## Negativfall
- **Löschen** ohne Auswahl -> Button ist deaktiviert, nichts passiert
