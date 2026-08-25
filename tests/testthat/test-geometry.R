test_that("figure_area() rechnet je Typ", {
  expect_equal(figure_area(figure("circle", 50, 50, 10)), pi * 100)
  expect_equal(figure_area(figure("rect", 50, 50, 20, 10)), 200)
  expect_equal(figure_area(figure("triangle", 50, 50, 20, 10)), 100)
  expect_equal(figure_area(figure("line", 50, 50, 20, 10)), 0)
})

test_that("figure_outline() liefert die Eckpunkte in Zeichenreihenfolge", {
  rect <- figure_outline(figure("rect", 40, 60, 20, 10))
  expect_equal(rect$x, c(30, 50, 50, 30))
  expect_equal(rect$y, c(55, 55, 65, 65))

  tri <- figure_outline(figure("triangle", 50, 50, 20, 10))
  expect_equal(tri$x, c(40, 60, 50))
  expect_equal(tri$y, c(45, 45, 55))

  line <- figure_outline(figure("line", 10, 20, 5, -5))
  expect_equal(line$x, c(10, 15))
  expect_equal(line$y, c(20, 15))

  circle <- figure_outline(figure("circle", 50, 50, 10), n = 8L)
  expect_equal(nrow(circle), 8)
  expect_equal(circle$x[1], 60)
  expect_equal(circle$y[1], 50)
  expect_true(all(abs(sqrt((circle$x - 50)^2 + (circle$y - 50)^2) - 10) < 1e-9))
})

test_that("figure_outline() lehnt unbekannte Typen ab", {
  expect_error(figure_outline(figure("blob", 1, 1, 1)), "Unbekannter Figurentyp")
})

test_that("figure_bbox() liefert xmin, ymin, xmax, ymax", {
  expect_equal(figure_bbox(figure("circle", 50, 40, 10)), c(40, 30, 60, 50))
  expect_equal(figure_bbox(figure("rect", 40, 60, 20, 10)), c(30, 55, 50, 65))
  expect_equal(figure_bbox(figure("triangle", 50, 50, 20, 10)), c(40, 45, 60, 55))
  expect_equal(figure_bbox(figure("line", 10, 20, 5, -5)), c(10, 15, 15, 20))
})

test_that("figure_contains(): Kreis über den Abstand zum Mittelpunkt", {
  fig <- figure("circle", 50, 50, 10)
  expect_true(figure_contains(fig, 50, 50))
  expect_true(figure_contains(fig, 57, 57))
  expect_true(figure_contains(fig, 60, 50))
  expect_false(figure_contains(fig, 58, 58))
  expect_false(figure_contains(fig, 70, 50))
})

test_that("figure_contains(): Rechteck inklusive Rand", {
  fig <- figure("rect", 40, 60, 20, 10)
  expect_true(figure_contains(fig, 40, 60))
  expect_true(figure_contains(fig, 30, 55))
  expect_true(figure_contains(fig, 50, 65))
  expect_false(figure_contains(fig, 29.9, 60))
  expect_false(figure_contains(fig, 40, 65.1))
})

test_that("figure_contains(): Dreieck nur innerhalb der Spitze", {
  fig <- figure("triangle", 50, 50, 20, 10)
  expect_true(figure_contains(fig, 50, 50))
  expect_true(figure_contains(fig, 45, 46))
  expect_false(figure_contains(fig, 41, 54))
  expect_false(figure_contains(fig, 59, 54))
  expect_false(figure_contains(fig, 50, 56))
})

test_that("figure_contains(): Linie mit Toleranz", {
  fig <- figure("line", 10, 10, 40, 0)
  expect_true(figure_contains(fig, 30, 10))
  expect_true(figure_contains(fig, 30, 11.5))
  expect_false(figure_contains(fig, 30, 12.5))
  expect_false(figure_contains(fig, 55, 10))
  expect_true(figure_contains(fig, 51, 10))
  expect_true(figure_contains(fig, 30, 14, tol = 5))
  diag <- figure("line", 0, 0, 100, 100)
  expect_true(figure_contains(diag, 50, 51))
  expect_false(figure_contains(diag, 50, 60))
})
