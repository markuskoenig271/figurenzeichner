# Shiny-Modul Figuren-Editor: Formular zum Anlegen, Ändern und Löschen einer Figur.
# Einziger Schreiber von state$drawing. Validierung nur über validate_figure().

editor_ui <- function(id) {
  ns <- NS(id)
  tagList(
    selectInput(
      ns("type"), "Typ",
      choices = setNames(FIGURE_TYPES, FIGURE_TYPE_LABELS), selected = "rect"
    ),
    fluidRow(
      column(6, numericInput(ns("x"), "x", value = 50, step = 1)),
      column(6, numericInput(ns("y"), "y", value = 50, step = 1))
    ),
    fluidRow(
      column(6, numericInput(ns("w"), "Breite", value = 20, step = 1)),
      column(
        6,
        conditionalPanel(
          condition = "input.type != 'circle'", ns = ns,
          numericInput(ns("h"), "Höhe", value = 10, step = 1)
        )
      )
    ),
    textInput(ns("colour"), "Farbe", value = "#1F77B4"),
    div(
      class = "mb-2",
      actionButton(ns("add"), "Hinzufügen", class = "btn-primary")
    ),
    div(
      class = "mb-2",
      actionButton(ns("update"), "Übernehmen", disabled = TRUE),
      actionButton(ns("delete"), "Löschen", class = "btn-danger", disabled = TRUE)
    ),
    actionButton(ns("deselect"), "Auswahl aufheben", disabled = TRUE),
    hr(),
    strong(textOutput(ns("status"))),
    uiOutput(ns("errors"))
  )
}

editor_server <- function(id, state) {
  moduleServer(id, function(input, output, session) {
    errors <- reactiveVal(character(0))
    # Spiegelt die zuletzt ins Formular geschriebene Position (Klick oder Auswahl);
    # die Inputs selbst lassen sich vom Server nicht zurücklesen.
    form_position <- reactiveVal(c(50, 50))

    selected_figure <- reactive({
      if (is.null(state$selected)) NULL else drawing_get(state$drawing, state$selected)
    })

    form_figure <- function(id = NA_integer_) {
      figure(
        type = input$type, x = input$x, y = input$y, w = input$w, h = input$h,
        colour = input$colour, id = id
      )
    }

    # Validiert und wendet bei Erfolg `apply` an; Meldungen landen im Fehlerbereich.
    commit <- function(fig, apply) {
      errs <- validate_figure(fig)
      errors(errs)
      if (length(errs) == 0) apply(fig)
    }

    observeEvent(input$type, editor_set_size_labels(session, input$type))

    observeEvent(state$selected, ignoreNULL = FALSE, {
      errors(character(0))
      fig <- selected_figure()
      if (!is.null(fig)) {
        form_position(c(fig$x, fig$y))
        editor_fill_form(session, fig)
      }
      editor_toggle_buttons(session, !is.null(fig))
    })

    observeEvent(state$click, {
      req(is.null(state$selected))
      pos <- round(state$click, 1)
      form_position(pos)
      updateNumericInput(session, "x", value = pos[1])
      updateNumericInput(session, "y", value = pos[2])
    })

    observeEvent(input$add, {
      commit(form_figure(), function(fig) {
        state$drawing <- drawing_add(state$drawing, fig)
        ids <- drawing_ids(state$drawing)
        state$selected <- ids[length(ids)]
      })
    })

    observeEvent(input$update, {
      req(selected_figure())
      commit(form_figure(id = state$selected), function(fig) {
        state$drawing <- drawing_update(state$drawing, fig)
      })
    })

    observeEvent(input$delete, {
      req(selected_figure())
      state$drawing <- drawing_remove(state$drawing, state$selected)
      state$selected <- NULL
    })

    observeEvent(input$deselect, {
      state$selected <- NULL
    })

    output$status <- renderText(editor_status(selected_figure()))

    output$errors <- renderUI({
      errs <- errors()
      if (length(errs) == 0) {
        return(NULL)
      }
      tags$ul(class = "text-danger", lapply(errs, tags$li))
    })
  })
}

editor_set_size_labels <- function(session, type) {
  labels <- FIGURE_SIZE_LABELS[[type]]
  updateNumericInput(session, "w", label = labels[["w"]])
  if (!is.na(labels[["h"]])) updateNumericInput(session, "h", label = labels[["h"]])
}

editor_fill_form <- function(session, fig) {
  updateSelectInput(session, "type", selected = fig$type)
  updateNumericInput(session, "x", value = fig$x)
  updateNumericInput(session, "y", value = fig$y)
  updateNumericInput(session, "w", value = fig$w)
  updateNumericInput(session, "h", value = fig$h)
  updateTextInput(session, "colour", value = fig$colour)
}

editor_toggle_buttons <- function(session, enabled) {
  for (button in c("update", "delete", "deselect")) {
    updateActionButton(session, button, disabled = !enabled)
  }
}

editor_status <- function(fig) {
  if (is.null(fig)) {
    return("Neue Figur")
  }
  sprintf("Ausgewählt: #%d (%s)", fig$id, FIGURE_TYPE_LABELS[[fig$type]])
}
