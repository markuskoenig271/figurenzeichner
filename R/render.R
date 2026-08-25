# Base-Graphics-Zeichnung. Einziger Ort mit Grafikcode; kein Zustand, kein Shiny.

SELECTION_PADDING <- 2

draw_canvas <- function(drawing, selected = NULL) {
  op <- graphics::par(mar = c(0, 0, 0, 0))
  on.exit(graphics::par(op))
  graphics::plot.new()
  graphics::plot.window(xlim = CANVAS, ylim = CANVAS, asp = 1, xaxs = "i", yaxs = "i")
  graphics::rect(CANVAS[1], CANVAS[1], CANVAS[2], CANVAS[2], border = "grey40")
  for (fig in drawing$figures) draw_figure(fig)
  sel <- drawing_get(drawing, selected)
  if (!is.null(sel)) {
    # Abstand, damit der Rahmen auch bei einem Rechteck vom Rand der Figur absetzt.
    bb <- figure_bbox(sel) + c(-1, -1, 1, 1) * SELECTION_PADDING
    graphics::rect(bb[1], bb[2], bb[3], bb[4], border = "grey20", lty = "dashed", lwd = 1.5)
  }
  invisible(NULL)
}

draw_figure <- function(fig) {
  o <- figure_outline(fig)
  if (fig$type == "line") {
    graphics::segments(o$x[1], o$y[1], o$x[2], o$y[2], col = fig$colour, lwd = 3)
  } else {
    graphics::polygon(o$x, o$y, col = fig$colour, border = darken(fig$colour), lwd = 1.5)
  }
  invisible(NULL)
}

darken <- function(colour, factor = 0.6) {
  rgb <- grDevices::col2rgb(colour)[, 1] / 255 * factor
  grDevices::rgb(rgb[1], rgb[2], rgb[3])
}
