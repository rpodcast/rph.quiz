#' The application server-side
#' 
#' @param input,output,session Internal parameters for {shiny}. 
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function( input, output, session ) {
  # Your application server logic 
  #mod_question_server("question_ui_1")
  n_questions <- 2
  question_vec <- 1:n_questions
  
  # set up reactive values
  start_app <- reactiveVal(runif(1))

  observeEvent(start_app(), {
    purrr::walk(1:2, ~insertTab(
      inputId = "tabs",
      tabPanel(
        glue::glue("Tab {.x}"),
        mod_question_ui(glue::glue("question_ui_{.x}"), question_index = .x),
        value = glue::glue("qtab{.x}")
      )))
  })

  purrr::walk(1:2, ~mod_question_server(glue::glue("question_ui_{.x}")))

  observeEvent(input$next_button, {
    # grab current tab
    current_tab <- input$tabs

    if (current_tab == "hello") {
      next_tab <- "qtab1"
      updateTabsetPanel(
          inputId = "tabs",
          selected = next_tab
        )
    } else {
      # extract number from tab name
      tab_number <- as.integer(stringr::str_extract(current_tab, "\\d+"))

      if (tab_number < n_questions) {
        next_tab <- glue::glue("qtab{tab_number + 1}")
        updateTabsetPanel(
          inputId = "tabs",
          selected = next_tab
        )
      }
    }
  })

  observeEvent(input$prev_button, {
    # grab current tab
    current_tab <- input$tabs

    if (current_tab == "qtab1") {
      next_tab <- "hello"
      updateTabsetPanel(
          inputId = "tabs",
          selected = next_tab
      )
    } else {
      # extract number from tab name
      if (current_tab != "hello") {
        tab_number <- as.integer(stringr::str_extract(current_tab, "\\d+"))
        prev_tab <- glue::glue("qtab{tab_number - 1}")
        updateTabsetPanel(
          inputId = "tabs",
          selected = prev_tab
        )
      }
    }
  })
}
