#' question UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_question_ui <- function(id, question_index = 1){
  ns <- NS(id)
  tagList(
    fluidRow(
      col_12(
        radioButtons(
          inputId = ns("qinput"),
          label = glue::glue("Question {question_index}"),
          choices = c("a", "b", "c", "d"),
        ),
        # shinyWidgets::prettyRadioButtons(
        #   inputId = ns("qinput"),
        #   label = "My Question",
        #   choices = c("a", "b", "c", "d"),
        #   icon = icon("check"),
        #   bigger = TRUE,
        #   status = "info",
        #   animation = "jelly"
        # ),
        fluidRow(
          shinyWidgets::actionBttn(
            inputId = ns("qsubmit"),
            label = "Submit",
            icon = icon("check"),
            color = "success",
            size = "sm",
            style = "jelly"
          ),
          shinyWidgets::actionBttn(
            inputId = ns("qreset"),
            label = "Reset",
            icon = icon("eraser"),
            color = "danger",
            size = "sm",
            style = "jelly"
          )
        )
      )
    )
  )
}
    
#' question Server Functions
#'
#' @noRd 
mod_question_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    observeEvent(input$qsubmit, {
      message("qsubmit clicked")
      #shinyjs::delay(100, shinyjs::toggle("qinput"))
      shinyjs::disable(selector = "[type=radio][value=b]")
      shinyjs::disable(selector = "[type=radio][value=c]")
      shinyjs::disable(selector = "[type=radio][value=d]")
    })

  })
}
    
## To be copied in the UI
# mod_question_ui("question_ui_1")
    
## To be copied in the server
# mod_question_server("question_ui_1")
