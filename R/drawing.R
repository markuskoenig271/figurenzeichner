# Geordnete Sammlung von Figuren. Reihenfolge = Z-Reihenfolge (zuletzt hinzugefügt
# liegt oben). Immutable: jede Operation liefert eine neue Zeichnung.

drawing_new <- function() {
  structure(list(figures = list(), next_id = 1L), class = "drawing")
}

drawing_ids <- function(drawing) {
  vapply(drawing$figures, function(f) f$id, integer(1))
}

drawing_index <- function(drawing, id) {
  if (is.null(id)) {
    return(integer(0))
  }
  which(drawing_ids(drawing) == id)
}

drawing_get <- function(drawing, id) {
  i <- drawing_index(drawing, id)
  if (length(i) == 0) NULL else drawing$figures[[i]]
}

drawing_add <- function(drawing, fig) {
  fig$id <- drawing$next_id
  drawing$figures[[length(drawing$figures) + 1]] <- fig
  drawing$next_id <- drawing$next_id + 1L
  drawing
}

drawing_update <- function(drawing, fig) {
  i <- drawing_index(drawing, fig$id)
  if (length(i) == 0) {
    stop("Keine Figur mit Id ", fig$id)
  }
  drawing$figures[[i]] <- fig
  drawing
}

drawing_remove <- function(drawing, id) {
  i <- drawing_index(drawing, id)
  if (length(i) > 0) drawing$figures[[i]] <- NULL
  drawing
}

# Id der obersten Figur unter (px, py), sonst NULL.
drawing_hit <- function(drawing, px, py) {
  for (fig in rev(drawing$figures)) {
    if (figure_contains(fig, px, py)) {
      return(fig$id)
    }
  }
  NULL
}
