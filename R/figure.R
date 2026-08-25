# Datenstruktur einer Figur, Konstanten und Validierung. Reine Funktionen, kein Shiny.
# Semantik von x, y, w, h je Typ: siehe docs/architecture.md, Abschnitt "Figur".

CANVAS <- c(0, 100)
FIGURE_TYPES <- c("circle", "rect", "triangle", "line")
FIGURE_TYPE_LABELS <- c(circle = "Kreis", rect = "Rechteck", triangle = "Dreieck", line = "Linie")
FIGURE_SIZE_LABELS <- list(
  circle = c(w = "Radius", h = NA_character_),
  rect = c(w = "Breite", h = "Höhe"),
  triangle = c(w = "Basisbreite", h = "Höhe"),
  line = c(w = "Δx", h = "Δy")
)

figure <- function(type, x, y, w, h = w, colour = "#1F77B4", id = NA_integer_) {
  if (identical(type, "circle")) h <- w
  structure(
    list(id = id, type = type, x = x, y = y, w = w, h = h, colour = colour),
    class = "figure"
  )
}

is_figure <- function(x) inherits(x, "figure")

is_number <- function(v) is.numeric(v) && length(v) == 1 && is.finite(v)

is_string <- function(v) is.character(v) && length(v) == 1 && !is.na(v)

is_colour <- function(colour) {
  if (!is_string(colour) || !nzchar(colour)) {
    return(FALSE)
  }
  !inherits(try(grDevices::col2rgb(colour), silent = TRUE), "try-error")
}

# character(0) bei gültiger Figur, sonst ein Vektor lesbarer Meldungen (eine je Regel).
validate_figure <- function(fig) {
  if (!is_figure(fig)) {
    return("Keine Figur")
  }
  if (!is_string(fig$type) || !fig$type %in% FIGURE_TYPES) {
    return("Unbekannter Figurentyp")
  }
  labels <- c(x = "x", y = "y", FIGURE_SIZE_LABELS[[fig$type]])
  labels <- labels[!is.na(labels)]
  numeric_ok <- vapply(names(labels), function(f) is_number(fig[[f]]), logical(1))
  size_errs <- validate_size(fig, labels, numeric_ok)
  errs <- c(
    sprintf("%s muss eine Zahl sein", labels[!numeric_ok]),
    size_errs,
    validate_colour(fig$colour),
    if (all(numeric_ok) && length(size_errs) == 0) validate_bounds(fig)
  )
  unname(errs)
}

validate_size <- function(fig, labels, numeric_ok) {
  if (fig$type == "line") {
    zero <- numeric_ok[["w"]] && numeric_ok[["h"]] && fig$w == 0 && fig$h == 0
    return(if (zero) "Linie muss eine Länge größer als 0 haben" else character(0))
  }
  fields <- intersect(c("w", "h"), names(labels))
  bad <- fields[vapply(fields, function(f) numeric_ok[[f]] && fig[[f]] <= 0, logical(1))]
  sprintf("%s muss größer als 0 sein", labels[bad])
}

validate_colour <- function(colour) {
  if (is_colour(colour)) {
    return(character(0))
  }
  sprintf("Farbe „%s“ ist keine gültige Farbe", if (is_string(colour)) colour else "")
}

validate_bounds <- function(fig) {
  bb <- figure_bbox(fig)
  inside <- all(bb[1:2] >= CANVAS[1]) && all(bb[3:4] <= CANVAS[2])
  if (inside) character(0) else "Figur liegt nicht vollständig auf der Zeichenfläche (0–100)"
}
