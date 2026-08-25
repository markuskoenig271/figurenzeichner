# Klick ins Leere: Auswahl aufheben und Position vorbelegen

**Betrifft:** Zeichenfläche (Klick) → Figuren-Editor (Modus „Neu")
**Warum:** Der Nutzer will schnell eine Figur dort platzieren, wo er hinklickt, und
eine Auswahl ohne Umweg loswerden.

## Vorbedingungen
- Eine Figur vorhanden und ausgewählt: #1 Rechteck (40, 60, 20×10)

## Schritte
1. Auf eine leere Stelle der Fläche klicken (z. B. rechts unten, ca. 80/20)
2. Formular prüfen
3. **Hinzufügen** mit den vorbelegten Werten

## Erwartetes Ergebnis
- Nach 1: Bounding Box verschwindet, Status „Neue Figur"; Bearbeiten-Buttons
  deaktiviert
- Nach 2: `x`/`y` zeigen die Klickposition (auf eine Nachkommastelle gerundet, ca.
  80/20); Typ, Größe und Farbe unverändert
- Nach 3: neue Figur erscheint an der Klickposition, „Figuren: 2"

## Negativfall
- Klick auf eine Figur (statt ins Leere) -> `x`/`y` zeigen den Anker der Figur,
  nicht die Klickposition
- Klick in den Randbereich außerhalb des Rahmens -> wie Klick ins Leere, kein Fehler
