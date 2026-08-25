# Leere Zeichenfläche beim Start

**Betrifft:** Zeichenfläche, Figuren-Editor (Modus „Neu")
**Warum:** Der Nutzer muss beim Start sofort sehen, dass die Fläche leer ist und wo er
anfängt — ohne Fehlermeldung, ohne aktive Bearbeiten-Buttons.

## Vorbedingungen
- App frisch gestartet, Seite geladen

## Schritte
1. Seite öffnen
2. Editor und Fläche betrachten

## Erwartetes Ergebnis
- Fläche zeigt nur den Rahmen, keine Figur
- Unter der Fläche steht „Figuren: 0"
- Statuszeile zeigt „Neue Figur", kein Fehlerbereich sichtbar
- Formular vorbelegt: Typ Rechteck, x 50, y 50, Breite 20, Höhe 10, Farbe `#1F77B4`
- **Hinzufügen** aktiv; **Übernehmen**, **Löschen**, **Auswahl aufheben** deaktiviert

## Negativfall
- Seite neu laden nach dem Anlegen von Figuren -> Fläche ist wieder leer,
  „Figuren: 0" (keine Persistenz, gewollt)
