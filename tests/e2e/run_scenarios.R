# E2E-Runner: führt die Szenarien aus .planning/e2e-tests/ gegen die ganze App aus
# (shiny::testServer auf app.R) und rendert die Canvas-Zustände als PNG nach `out`.
# Aufruf aus dem Repo-Root:  Rscript tests/e2e/run_scenarios.R
# Was nur der Browser zeigt (conditionalPanel, Button-Zustand, Formular-Updates)
# prüft dieser Runner nicht — siehe .planning/e2e-tests/README.md.
library(shiny)
library(testthat)

out <- Sys.getenv("E2E_OUT", file.path(tempdir(), "figurenzeichner-e2e"))
dir.create(out, showWarnings = FALSE, recursive = TRUE)
app_dir <- normalizePath(".")
for (f in list.files(file.path(app_dir, "R"), full.names = TRUE)) source(f, encoding = "UTF-8")

results <- list()
check <- function(scenario, what, ok, observed = "") {
  observed <- if (is.null(observed)) "NULL" else paste(as.character(observed), collapse = "/")
  results[[length(results) + 1]] <<- data.frame(scenario, what, ok = isTRUE(ok), observed)
}

snapshot <- function(drawing, selected, file) {
  grDevices::png(file.path(out, file), width = 600, height = 600)
  on.exit(grDevices::dev.off())
  draw_canvas(drawing, selected)
}

# Editor-Inputs mit Namespace setzen
form <- function(session, type = "rect", x = 50, y = 50, w = 20, h = 10, colour = "#1F77B4") {
  session$setInputs(
    `editor-type` = type, `editor-x` = x, `editor-y` = y,
    `editor-w` = w, `editor-h` = h, `editor-colour` = colour
  )
}
click <- function(session, x, y) session$setInputs(`canvas-click` = list(x = x, y = y))
btn <- local({
  n <- 0
  function(session, id) {
    n <<- n + 1
    args <- list(n)
    names(args) <- paste0("editor-", id)
    do.call(session$setInputs, args)
  }
})

testServer(app_dir, {
  # Kurzformen, die output/state der laufenden Session lesen
  out_is <- function(scenario, what, id, expected) {
    check(scenario, what, identical(output[[id]], expected), output[[id]])
  }
  sel_is <- function(scenario, what, expected) {
    check(scenario, what, identical(state$selected, expected), state$selected)
  }
  err_has <- function(scenario, what, pattern) {
    html <- output$`editor-errors`$html
    check(scenario, what, !is.null(html) && grepl(pattern, html), html)
  }
  no_err <- function(scenario, what) {
    check(scenario, what, is.null(output$`editor-errors`$html))
  }

  # ---- leere-zeichenflaeche
  s <- "leere-zeichenflaeche"
  out_is(s, "Zähler", "canvas-count", "Figuren: 0")
  out_is(s, "Status", "editor-status", "Neue Figur")
  no_err(s, "kein Fehlerbereich")
  check(s, "Plot rendert", grepl("^data:image/png", output$`canvas-plot`$src))
  snapshot(state$drawing, state$selected, "01-leer.png")

  # ---- figur-anlegen
  s <- "figur-anlegen"
  form(session, "rect", 40, 60, 20, 10)
  btn(session, "add")
  out_is(s, "Rechteck: Status", "editor-status", "Ausgewählt: #1 (Rechteck)")
  out_is(s, "Rechteck: Zähler", "canvas-count", "Figuren: 1")
  form(session, "circle", 70, 30, 10, 10, "tomato")
  btn(session, "add")
  out_is(s, "Kreis: Status", "editor-status", "Ausgewählt: #2 (Kreis)")
  form(session, "triangle", 20, 20, 20, 15)
  btn(session, "add")
  out_is(s, "Dreieck: Zähler", "canvas-count", "Figuren: 3")
  form(session, "line", 10, 90, 80, -30)
  btn(session, "add")
  out_is(s, "Linie: Zähler", "canvas-count", "Figuren: 4")
  sel_is(s, "Linie ausgewählt", 4L)
  no_err(s, "kein Fehler")
  snapshot(state$drawing, state$selected, "02-vier-figuren.png")

  # ---- figur-auswaehlen-und-bearbeiten (#1 Rechteck, #2 Kreis)
  s <- "auswaehlen-bearbeiten"
  btn(session, "deselect")
  out_is(s, "nach Aufheben: Status", "editor-status", "Neue Figur")
  click(session, 40, 60)
  sel_is(s, "Klick auf Rechteck wählt #1", 1L)
  out_is(s, "Status", "editor-status", "Ausgewählt: #1 (Rechteck)")
  form(session, "rect", 40, 60, 30, 10, "steelblue")
  btn(session, "update")
  fig <- drawing_get(state$drawing, 1L)
  check(s, "Übernehmen: Breite 30", fig$w == 30, fig$w)
  check(s, "Übernehmen: Farbe", fig$colour == "steelblue", fig$colour)
  sel_is(s, "bleibt ausgewählt", 1L)
  out_is(s, "Zähler unverändert", "canvas-count", "Figuren: 4")
  snapshot(state$drawing, state$selected, "03-rechteck-bearbeitet.png")
  click(session, 70, 30)
  sel_is(s, "Klick auf Kreis wählt #2", 2L)
  form(session, "circle", 95, 30, 10, 10, "tomato")
  btn(session, "update")
  err_has(s, "Negativ: Meldung", "nicht vollständig")
  check(s, "Negativ: Figur unverändert", drawing_get(state$drawing, 2L)$x == 70)
  sel_is(s, "Negativ: Auswahl bleibt", 2L)

  # ---- ungueltige-eingaben: Fehler verschwinden beim Wechsel der Auswahl
  click(session, 40, 60)
  no_err("ungueltige-eingaben", "Fehler weg nach Auswahlwechsel")

  # ---- figur-loeschen (#2 Kreis)
  s <- "figur-loeschen"
  click(session, 70, 30)
  btn(session, "delete")
  check(s, "Kreis weg", !2L %in% drawing_ids(state$drawing), drawing_ids(state$drawing))
  out_is(s, "Zähler", "canvas-count", "Figuren: 3")
  out_is(s, "Status Neu", "editor-status", "Neue Figur")
  sel_is(s, "keine Auswahl", NULL)
  snapshot(state$drawing, state$selected, "04-kreis-geloescht.png")
  btn(session, "delete")
  out_is(s, "Negativ: Löschen ohne Auswahl ohne Effekt", "canvas-count", "Figuren: 3")

  # ---- klick-ins-leere
  s <- "klick-ins-leere"
  click(session, 40, 60)
  sel_is(s, "Vorbedingung: #1 ausgewählt", 1L)
  click(session, 80.04, 20.06)
  sel_is(s, "Auswahl aufgehoben", NULL)
  out_is(s, "Status Neu", "editor-status", "Neue Figur")
  check(s, "Klickposition gemerkt", isTRUE(all.equal(state$click, c(80.04, 20.06))), state$click)
  form(session, "rect", 80, 20.1, 20, 10)
  btn(session, "add")
  check(s, "Figur an Klickposition", drawing_get(state$drawing, 5L)$x == 80)
  snapshot(state$drawing, state$selected, "05-klick-ins-leere.png")
  click(session, -3, 104)
  sel_is(s, "Negativ: Klick außerhalb -> keine Auswahl", NULL)

  # ---- ungueltige-eingaben
  s <- "ungueltige-eingaben"
  n0 <- length(state$drawing$figures)
  form(session, "rect", 50, 50, 0, 10, "nope")
  btn(session, "add")
  err_has(s, "Breite 0: Meldung", "Breite muss größer als 0 sein")
  err_has(s, "Farbe nope: Meldung gleichzeitig", "nope")
  check(s, "Zähler unverändert", length(state$drawing$figures) == n0)
  form(session, "rect", NA, 50, 20, 10)
  btn(session, "add")
  err_has(s, "x leer", "x muss eine Zahl sein")
  form(session, "circle", 50, 50, 60, 60)
  btn(session, "add")
  err_has(s, "Kreis zu groß", "nicht vollständig")
  form(session, "line", 50, 50, 0, 0)
  btn(session, "add")
  err_has(s, "Linie ohne Länge", "Länge größer als 0")
  form(session, "rect", 50, 50, 20, 10)
  btn(session, "add")
  no_err(s, "gültig danach: kein Fehler")
  check(s, "gültig danach: Zähler +1", length(state$drawing$figures) == n0 + 1)
  snapshot(state$drawing, state$selected, "06-nach-fehlern.png")
})

# ---- ueberlappende-figuren (frische Session)
testServer(app_dir, {
  s <- "ueberlappende-figuren"
  form(session, "rect", 50, 50, 40, 40)
  btn(session, "add")
  form(session, "circle", 50, 50, 8, 8, "tomato")
  btn(session, "add")
  btn(session, "deselect")
  click(session, 50, 50)
  check(s, "Mitte trifft Kreis (#2)", identical(state$selected, 2L), state$selected)
  check(s, "Status", output$`editor-status` == "Ausgewählt: #2 (Kreis)", output$`editor-status`)
  snapshot(state$drawing, state$selected, "07-ueberlappung-kreis.png")
  click(session, 35, 35)
  check(s, "Ecke trifft Rechteck (#1)", identical(state$selected, 1L), state$selected)
  snapshot(state$drawing, state$selected, "08-ueberlappung-rechteck.png")
  form(session, "line", 10, 90, 80, 0)
  btn(session, "add")
  click(session, 50, 87)
  check(s, "3 Einheiten neben Linie: keine Auswahl", is.null(state$selected), state$selected)
  click(session, 50, 88.5)
  check(s, "1.5 Einheiten neben Linie: Linie", identical(state$selected, 3L), state$selected)
})

# ---- leere-zeichenflaeche, Negativfall: neue Session ist leer
testServer(app_dir, {
  check(
    "leere-zeichenflaeche", "Negativ: neue Session leer",
    output$`canvas-count` == "Figuren: 0", output$`canvas-count`
  )
})

res <- do.call(rbind, results)
res$ok <- ifelse(res$ok, "OK", "FAIL")
print(res, right = FALSE, row.names = FALSE)
cat(sprintf("\n%d checks, %d failed; snapshots in %s\n", nrow(res), sum(res$ok == "FAIL"), out))
quit(status = as.integer(any(res$ok == "FAIL")))
