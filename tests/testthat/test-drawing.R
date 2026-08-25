test_that("drawing_new() ist leer", {
  d <- drawing_new()
  expect_s3_class(d, "drawing")
  expect_length(d$figures, 0)
  expect_identical(drawing_ids(d), integer(0))
})

test_that("drawing_add() vergibt fortlaufende Ids und hängt hinten an", {
  d <- drawing_new()
  d <- drawing_add(d, figure("circle", 50, 50, 10))
  d <- drawing_add(d, figure("rect", 20, 20, 10, 10))
  expect_identical(drawing_ids(d), c(1L, 2L))
  expect_equal(drawing_get(d, 2L)$type, "rect")
  expect_identical(drawing_get(d, 2L)$id, 2L)
})

test_that("drawing_* ist immutable", {
  d0 <- drawing_new()
  d1 <- drawing_add(d0, figure("circle", 50, 50, 10))
  expect_length(d0$figures, 0)
  d2 <- drawing_remove(d1, 1L)
  expect_length(d1$figures, 1)
  expect_length(d2$figures, 0)
})

test_that("drawing_remove() behält die Ids der übrigen Figuren, vergibt keine Id doppelt", {
  d <- drawing_new()
  d <- drawing_add(d, figure("circle", 50, 50, 10))
  d <- drawing_add(d, figure("rect", 20, 20, 10, 10))
  d <- drawing_remove(d, 1L)
  expect_identical(drawing_ids(d), 2L)
  d <- drawing_add(d, figure("line", 0, 0, 10, 10))
  expect_identical(drawing_ids(d), c(2L, 3L))
  expect_identical(drawing_remove(d, 99L), d)
})

test_that("drawing_update() ersetzt an Ort und Stelle", {
  d <- drawing_new()
  d <- drawing_add(d, figure("circle", 50, 50, 10))
  d <- drawing_add(d, figure("rect", 20, 20, 10, 10))
  d <- drawing_update(d, figure("triangle", 50, 50, 8, 8, id = 1L))
  expect_identical(drawing_ids(d), c(1L, 2L))
  expect_equal(drawing_get(d, 1L)$type, "triangle")
  expect_error(drawing_update(d, figure("rect", 1, 1, 1, 1, id = 7L)), "7")
})

test_that("drawing_get() liefert NULL für unbekannte Ids", {
  expect_null(drawing_get(drawing_new(), 1L))
  expect_null(drawing_get(drawing_new(), NULL))
})

test_that("drawing_hit() trifft die oberste Figur", {
  d <- drawing_new()
  d <- drawing_add(d, figure("rect", 50, 50, 40, 40))
  d <- drawing_add(d, figure("circle", 50, 50, 5))
  expect_identical(drawing_hit(d, 50, 50), 2L)
  expect_identical(drawing_hit(d, 35, 35), 1L)
  expect_null(drawing_hit(d, 5, 5))
  expect_null(drawing_hit(drawing_new(), 50, 50))
})
