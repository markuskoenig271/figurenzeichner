new_state <- function(drawing = drawing_new()) {
  reactiveValues(drawing = drawing, selected = NULL, click = NULL)
}

test_that("canvas_ui() enthält Plot mit Klick und den Zähler", {
  html <- as.character(canvas_ui("c"))
  expect_match(html, 'id="c-plot"')
  expect_match(html, 'data-click-id="c-click"')
  expect_match(html, 'id="c-count"')
})

test_that("Klick auf eine Figur wählt sie aus und merkt die Position", {
  d <- drawing_add(drawing_new(), figure("rect", 50, 50, 20, 20))
  state <- new_state(d)
  testServer(canvas_server, args = list(state = state), {
    session$setInputs(click = list(x = 50, y = 50))
    expect_identical(state$selected, 1L)
    expect_equal(state$click, c(50, 50))
  })
})

test_that("Klick ins Leere hebt die Auswahl auf", {
  d <- drawing_add(drawing_new(), figure("rect", 50, 50, 20, 20))
  state <- new_state(d)
  state$selected <- 1L
  testServer(canvas_server, args = list(state = state), {
    session$setInputs(click = list(x = 5, y = 5))
    expect_null(state$selected)
    expect_equal(state$click, c(5, 5))
  })
})

test_that("Zähler zeigt die Anzahl der Figuren", {
  state <- new_state()
  testServer(canvas_server, args = list(state = state), {
    expect_equal(output$count, "Figuren: 0")
    state$drawing <- drawing_add(state$drawing, figure("circle", 50, 50, 5))
    session$flushReact()
    expect_equal(output$count, "Figuren: 1")
  })
})
