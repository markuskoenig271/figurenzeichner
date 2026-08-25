# Figur anlegen (jeder Typ)

**Betrifft:** Figuren-Editor → Zeichenfläche
**Warum:** Kernfunktion — der Nutzer will eine Figur mit Typ, Position, Größe und
Farbe auf der Fläche sehen.

## Vorbedingungen
- App gestartet, leere Fläche

## Schritte
1. Typ „Rechteck", x 40, y 60, Breite 20, Höhe 10, Farbe `#1F77B4` → **Hinzufügen**
2. Typ „Kreis" wählen; Beschriftung des Größenfelds prüfen; x 70, y 30, Radius 10,
   Farbe `tomato` → **Hinzufügen**
3. Typ „Dreieck", x 20, y 20, Basisbreite 20, Höhe 15 → **Hinzufügen**
4. Typ „Linie", x 10, y 90, Δx 80, Δy −30 → **Hinzufügen**

## Erwartetes Ergebnis
- Nach Schritt 1: blaues Rechteck oben links der Mitte, gestrichelte Bounding Box
  darum (ausgewählt), Status „Ausgewählt: #1 (Rechteck)", „Figuren: 1"
- Bei Schritt 2: Größenfeld heißt „Radius", das Höhe-Feld ist ausgeblendet; danach
  roter Kreis rechts unten, Status „#2 (Kreis)", „Figuren: 2"
- Schritt 3: Dreieck mit Basis unten, Spitze oben, links unten; „Figuren: 3"
- Schritt 4: Linie von oben links nach rechts fallend; „Figuren: 4"
- Kein Fehlerbereich sichtbar; jede neue Figur ist sofort ausgewählt

## Negativfall
- Siehe `ungueltige-eingaben.md`
