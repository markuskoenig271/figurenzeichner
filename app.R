# Einstieg: shiny::runApp() lädt R/ automatisch. Legt den gemeinsamen Zustand an
# und bindet die beiden Module ein — sonst nichts (siehe docs/architecture.md).
library(shiny)

ui <- fluidPage(
  titlePanel("Figurenzeichner"),
  sidebarLayout(
    sidebarPanel(editor_ui("editor"), width = 3),
    mainPanel(canvas_ui("canvas"), width = 9)
  )
)

server <- function(input, output, session) {
  state <- reactiveValues(drawing = drawing_new(), selected = NULL, click = NULL)
  canvas_server("canvas", state)
  editor_server("editor", state)
}

shinyApp(ui, server)
