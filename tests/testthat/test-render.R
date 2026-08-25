with_null_device <- function(code) {
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off())
  force(code)
}

test_that("draw_canvas() zeichnet eine leere Zeichnung ohne Fehler", {
  expect_silent(with_null_device(draw_canvas(drawing_new())))
})

test_that("draw_canvas() zeichnet jeden Figurentyp, auch mit Auswahl", {
  d <- drawing_new()
  d <- drawing_add(d, figure("circle", 30, 30, 10))
  d <- drawing_add(d, figure("rect", 60, 60, 20, 10, colour = "steelblue"))
  d <- drawing_add(d, figure("triangle", 70, 30, 20, 10))
  d <- drawing_add(d, figure("line", 10, 90, 80, -30))
  expect_silent(with_null_device(draw_canvas(d)))
  expect_silent(with_null_device(draw_canvas(d, selected = 2L)))
  expect_silent(with_null_device(draw_canvas(d, selected = 99L)))
})

test_that("draw_figure() lehnt unbekannte Typen ab", {
  expect_error(with_null_device({
    plot.new()
    draw_figure(figure("blob", 1, 1, 1))
  }), "Unbekannter Figurentyp")
})

test_that("darken() liefert eine dunklere gültige Farbe", {
  dark <- darken("#FFFFFF")
  expect_match(dark, "^#[0-9A-Fa-f]{6}$")
  expect_true(all(grDevices::col2rgb(dark) < 255))
  expect_equal(darken("black"), "#000000")
})
