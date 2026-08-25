# Geometrie über einer Figur: Umriss, Bounding Box, Trefferprüfung, Fläche.
# Reine Funktionen, keine Grafik, kein Shiny.

figure_area <- function(fig) {
  switch(fig$type,
    circle = pi * fig$w^2,
    rect = fig$w * fig$h,
    triangle = fig$w * fig$h / 2,
    line = 0,
    stop("Unbekannter Figurentyp: ", fig$type)
  )
}

# data.frame(x, y) der Umrisspunkte in Zeichenreihenfolge. Einziger Ort, der die
# Typ-Semantik von x, y, w, h in Koordinaten übersetzt.
figure_outline <- function(fig, n = 64L) {
  switch(fig$type,
    circle = {
      t <- seq(0, 2 * pi, length.out = n + 1)[seq_len(n)]
      data.frame(x = fig$x + fig$w * cos(t), y = fig$y + fig$w * sin(t))
    },
    rect = data.frame(
      x = fig$x + c(-1, 1, 1, -1) * fig$w / 2,
      y = fig$y + c(-1, -1, 1, 1) * fig$h / 2
    ),
    triangle = data.frame(
      x = fig$x + c(-1, 1, 0) * fig$w / 2,
      y = fig$y + c(-1, -1, 1) * fig$h / 2
    ),
    line = data.frame(x = c(fig$x, fig$x + fig$w), y = c(fig$y, fig$y + fig$h)),
    stop("Unbekannter Figurentyp: ", fig$type)
  )
}

figure_bbox <- function(fig) {
  if (fig$type == "circle") {
    return(c(fig$x - fig$w, fig$y - fig$w, fig$x + fig$w, fig$y + fig$w))
  }
  o <- figure_outline(fig)
  c(min(o$x), min(o$y), max(o$x), max(o$y))
}

# Trefferprüfung eines Punkts (px, py); tol nur für Linien, in Flächeneinheiten.
figure_contains <- function(fig, px, py, tol = 2) {
  switch(fig$type,
    circle = (px - fig$x)^2 + (py - fig$y)^2 <= fig$w^2,
    rect = {
      bb <- figure_bbox(fig)
      px >= bb[1] && px <= bb[3] && py >= bb[2] && py <= bb[4]
    },
    triangle = {
      o <- figure_outline(fig)
      point_in_polygon(px, py, o$x, o$y)
    },
    line = {
      o <- figure_outline(fig)
      point_segment_distance(px, py, o$x[1], o$y[1], o$x[2], o$y[2]) <= tol
    },
    stop("Unbekannter Figurentyp: ", fig$type)
  )
}

# Ray casting (even-odd). Punkte exakt auf einer Kante sind nicht definiert.
point_in_polygon <- function(px, py, vx, vy) {
  n <- length(vx)
  inside <- FALSE
  j <- n
  for (i in seq_len(n)) {
    crosses <- (vy[i] > py) != (vy[j] > py)
    if (crosses) {
      x_at <- vx[i] + (py - vy[i]) * (vx[j] - vx[i]) / (vy[j] - vy[i])
      if (px < x_at) inside <- !inside
    }
    j <- i
  }
  inside
}

point_segment_distance <- function(px, py, x1, y1, x2, y2) {
  dx <- x2 - x1
  dy <- y2 - y1
  len2 <- dx^2 + dy^2
  t <- if (len2 == 0) 0 else max(0, min(1, ((px - x1) * dx + (py - y1) * dy) / len2))
  sqrt((px - (x1 + t * dx))^2 + (py - (y1 + t * dy))^2)
}
