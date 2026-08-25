test_that("figure() liefert eine Figur mit festem Schema", {
  fig <- figure("rect", x = 40, y = 60, w = 20, h = 10)
  expect_true(is_figure(fig))
  expect_named(fig, c("id", "type", "x", "y", "w", "h", "colour"))
  expect_identical(fig$id, NA_integer_)
  expect_equal(fig$colour, "#1F77B4")
  expect_false(is_figure(list(type = "rect")))
})

test_that("figure() setzt beim Kreis h auf den Radius", {
  fig <- figure("circle", x = 50, y = 50, w = 10, h = 99)
  expect_equal(fig$h, 10)
})

test_that("figure() wirft bei Unsinn nicht, validate_figure() meldet", {
  fig <- figure("rect", x = "a", y = NA, w = 0, h = -1)
  expect_true(is_figure(fig))
  errs <- validate_figure(fig)
  expect_true(length(errs) >= 2)
})

test_that("gültige Figuren liefern keine Meldungen", {
  expect_identical(validate_figure(figure("circle", 50, 50, 10)), character(0))
  expect_identical(validate_figure(figure("rect", 50, 50, 20, 10)), character(0))
  expect_identical(validate_figure(figure("triangle", 50, 50, 20, 10)), character(0))
  expect_identical(validate_figure(figure("line", 10, 10, -5, 30)), character(0))
  expect_identical(validate_figure(figure("rect", 50, 50, 100, 100)), character(0))
  named <- figure("rect", 50, 50, 10, 10, colour = "steelblue")
  expect_identical(validate_figure(named), character(0))
})

test_that("Nicht-Zahlen werden je Feld gemeldet", {
  errs <- validate_figure(figure("rect", x = NA, y = "b", w = 20, h = 10))
  expect_setequal(errs, c("x muss eine Zahl sein", "y muss eine Zahl sein"))
  errs <- validate_figure(figure("circle", x = 50, y = 50, w = NULL))
  expect_setequal(errs, "Radius muss eine Zahl sein")
})

test_that("Größen müssen positiv sein, Beschriftung je Typ", {
  expect_equal(validate_figure(figure("circle", 50, 50, 0)), "Radius muss größer als 0 sein")
  expect_setequal(
    validate_figure(figure("rect", 50, 50, -1, 0)),
    c("Breite muss größer als 0 sein", "Höhe muss größer als 0 sein")
  )
  expect_equal(
    validate_figure(figure("triangle", 50, 50, 0, 5)),
    "Basisbreite muss größer als 0 sein"
  )
  expect_equal(
    validate_figure(figure("line", 50, 50, 0, 0)),
    "Linie muss eine Länge größer als 0 haben"
  )
})

test_that("ungültige Farbe wird gemeldet", {
  expect_equal(
    validate_figure(figure("rect", 50, 50, 10, 10, colour = "xyz")),
    "Farbe „xyz“ ist keine gültige Farbe"
  )
  expect_length(validate_figure(figure("rect", 50, 50, 10, 10, colour = "")), 1)
})

test_that("Figur muss vollständig auf der Fläche liegen", {
  msg <- "Figur liegt nicht vollständig auf der Zeichenfläche (0–100)"
  expect_equal(validate_figure(figure("circle", 5, 50, 10)), msg)
  expect_equal(validate_figure(figure("rect", 95, 50, 20, 10)), msg)
  expect_equal(validate_figure(figure("line", 90, 90, 20, 5)), msg)
  expect_equal(validate_figure(figure("rect", 50, -1, 10, 10)), msg)
})

test_that("unbekannter Typ wird gemeldet", {
  expect_equal(validate_figure(figure("hexagon", 50, 50, 10)), "Unbekannter Figurentyp")
  expect_equal(validate_figure(list()), "Keine Figur")
})

test_that("mehrere Fehler werden gleichzeitig gemeldet", {
  errs <- validate_figure(figure("rect", 50, 50, 0, 10, colour = "nope"))
  expect_length(errs, 2)
})
