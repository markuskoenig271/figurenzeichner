# Shiny-Modul Zeichenfläche: rendert die Zeichnung, setzt bei Klick Auswahl und
# Klickposition in den gemeinsamen Zustand (state = reactiveValues, siehe app.R).

canvas_ui <- function(id) {
  ns <- NS(id)
  tagList(
    plotOutput(ns("plot"), click = ns("click"), width = "600px", height = "600px"),
    textOutput(ns("count"))
  )
}

canvas_server <- function(id, state) {
  moduleServer(id, function(input, output, session) {
    output$plot <- renderPlot(draw_canvas(state$drawing, state$selected))

    output$count <- renderText(sprintf("Figuren: %d", length(drawing_ids(state$drawing))))

    observeEvent(input$click, {
      state$click <- c(input$click$x, input$click$y)
      state$selected <- drawing_hit(state$drawing, input$click$x, input$click$y)
    })
  })
}
