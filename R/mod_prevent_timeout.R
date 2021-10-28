#' prevent_timeout UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList
mod_prevent_timeout_ui <- function(id) {
  ns <- NS(id)
  tagList(
    verbatimTextOutput(ns("counter_print"))
  )
}

#' prevent_timeout Server Functions
#'
#' @noRd 
#' @importFrom shiny getDefaultReactiveDomain observe reactive renderPrint
mod_prevent_timeout_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    # Conduct input$revive_count
    revive_count <- reactive({
      input$revive_count
    })
    
    # Handle revive
    observeEvent(
      eventExpr = revive_count(),
      handlerExpr = {
        req(revive_count() > 0)
        message(paste("Session revived. Revive count:", revive_count()))
      }
    )

    output$counter_print <- renderPrint({
      if (is.null(revive_count())) {
        x <- "nothing yet"
      } else {
        x <- revive_count()
      }

      x
    })

    revive_count
  })
}
    
## To be copied in the UI
# mod_prevent_timeout_ui("prevent_timeout_ui_1")
    
## To be copied in the server
# mod_prevent_timeout_server("prevent_timeout_ui_1")
