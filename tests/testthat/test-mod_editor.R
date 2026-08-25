editor_state <- function(drawing = drawing_new()) {
  reactiveValues(drawing = drawing, selected = NULL, click = NULL)
}

set_form <- function(session, type = "rect", x = 50, y = 50, w = 20, h = 10, colour = "#1F77B4") {
  session$setInputs(type = type, x = x, y = y, w = w, h = h, colour = colour)
}

test_that("editor_ui() enthält Formular und Buttons", {
  html <- as.character(editor_ui("e"))
  for (id in c("type", "x", "y", "w", "h", "colour", "add", "update", "delete", "deselect")) {
    expect_match(html, sprintf('id="e-%s"', id))
  }
  expect_match(html, "Kreis")
  expect_match(html, "Linie")
})

test_that("Hinzufügen legt eine gültige Figur an und wählt sie aus", {
  state <- editor_state()
  testServer(editor_server, args = list(state = state), {
    set_form(session, type = "circle", w = 10)
    session$setInputs(add = 1)
    expect_identical(drawing_ids(state$drawing), 1L)
    expect_equal(drawing_get(state$drawing, 1L)$type, "circle")
    expect_equal(drawing_get(state$drawing, 1L)$h, 10)
    expect_identical(state$selected, 1L)
    expect_null(output$errors$html)
    expect_match(output$status, "Ausgewählt: #1 \\(Kreis\\)")
  })
})

test_that("Hinzufügen mit ungültiger Eingabe lässt den Zustand unverändert und meldet", {
  state <- editor_state()
  testServer(editor_server, args = list(state = state), {
    set_form(session, type = "rect", w = 0, colour = "nope")
    session$setInputs(add = 1)
    expect_length(state$drawing$figures, 0)
    expect_null(state$selected)
    expect_match(output$errors$html, "Breite muss größer als 0 sein")
    expect_match(output$errors$html, "nope")
    expect_equal(output$status, "Neue Figur")
  })
})

test_that("Leere Zahlenfelder werden gemeldet", {
  state <- editor_state()
  testServer(editor_server, args = list(state = state), {
    set_form(session, x = NA, y = NA)
    session$setInputs(add = 1)
    expect_match(output$errors$html, "x muss eine Zahl sein")
    expect_match(output$errors$html, "y muss eine Zahl sein")
    expect_length(state$drawing$figures, 0)
  })
})

test_that("Auswahl lädt die Figur und Übernehmen ersetzt sie", {
  d <- drawing_add(drawing_new(), figure("rect", 40, 60, 20, 10))
  d <- drawing_add(d, figure("circle", 20, 20, 5))
  state <- editor_state(d)
  testServer(editor_server, args = list(state = state), {
    set_form(session)
    state$selected <- 1L
    session$flushReact()
    expect_match(output$status, "Ausgewählt: #1 \\(Rechteck\\)")
    set_form(session, type = "triangle", x = 40, y = 60, w = 30, h = 12, colour = "tomato")
    session$setInputs(update = 1)
    fig <- drawing_get(state$drawing, 1L)
    expect_equal(fig$type, "triangle")
    expect_equal(fig$w, 30)
    expect_equal(fig$colour, "tomato")
    expect_identical(drawing_ids(state$drawing), c(1L, 2L))
    expect_identical(state$selected, 1L)
  })
})

test_that("Übernehmen mit ungültiger Eingabe ändert nichts", {
  d <- drawing_add(drawing_new(), figure("rect", 40, 60, 20, 10))
  state <- editor_state(d)
  state$selected <- 1L
  testServer(editor_server, args = list(state = state), {
    set_form(session, x = 95, y = 60, w = 20, h = 10)
    session$setInputs(update = 1)
    expect_equal(drawing_get(state$drawing, 1L)$x, 40)
    expect_match(output$errors$html, "nicht vollständig")
    expect_identical(state$selected, 1L)
  })
})

test_that("Löschen entfernt die Auswahl, Auswahl aufheben behält die Figur", {
  d <- drawing_add(drawing_new(), figure("rect", 40, 60, 20, 10))
  d <- drawing_add(d, figure("circle", 20, 20, 5))
  state <- editor_state(d)
  testServer(editor_server, args = list(state = state), {
    set_form(session)
    state$selected <- 2L
    session$flushReact()
    session$setInputs(deselect = 1)
    expect_null(state$selected)
    expect_identical(drawing_ids(state$drawing), c(1L, 2L))

    state$selected <- 1L
    session$flushReact()
    session$setInputs(delete = 1)
    expect_null(state$selected)
    expect_identical(drawing_ids(state$drawing), 2L)
    expect_equal(output$status, "Neue Figur")
  })
})

test_that("Übernehmen und Löschen ohne Auswahl haben keinen Effekt", {
  d <- drawing_add(drawing_new(), figure("rect", 40, 60, 20, 10))
  state <- editor_state(d)
  testServer(editor_server, args = list(state = state), {
    set_form(session, x = 10, y = 10, w = 5, h = 5)
    session$setInputs(update = 1)
    session$setInputs(delete = 1)
    expect_equal(drawing_get(state$drawing, 1L)$x, 40)
    expect_identical(drawing_ids(state$drawing), 1L)
  })
})

test_that("Klick ins Leere übernimmt die Position ins Formular, nicht bei Auswahl", {
  d <- drawing_add(drawing_new(), figure("rect", 40, 60, 20, 10))
  state <- editor_state(d)
  testServer(editor_server, args = list(state = state), {
    set_form(session)
    state$click <- c(12.34, 56.78)
    session$flushReact()
    expect_equal(form_position(), c(12.3, 56.8))

    state$selected <- 1L
    state$click <- c(1, 2)
    session$flushReact()
    expect_equal(form_position(), c(40, 60))
  })
})

test_that("Fehlermeldungen verschwinden beim Wechsel der Auswahl", {
  d <- drawing_add(drawing_new(), figure("rect", 40, 60, 20, 10))
  state <- editor_state(d)
  testServer(editor_server, args = list(state = state), {
    set_form(session, w = 0)
    session$setInputs(add = 1)
    expect_false(is.null(output$errors$html))
    state$selected <- 1L
    session$flushReact()
    expect_null(output$errors$html)
  })
})
