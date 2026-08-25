# Lädt alle Quelldateien aus R/ in die Testumgebung. Shiny wird angehängt, weil
# die Module (wie unter shiny::runApp()) unqualifizierte Shiny-Funktionen nutzen.
# Testdateien dürfen selbst nichts sourcen (siehe tdd-cycle Skill).
library(shiny)

for (f in list.files(testthat::test_path("..", "..", "R"), pattern = "\\.R$", full.names = TRUE)) {
  source(f, encoding = "UTF-8")
}
