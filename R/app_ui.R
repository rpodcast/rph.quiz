#' The application User-Interface
#' 
#' @param request Internal parameter for `{shiny}`. 
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  n_questions <- 1:2
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # Your application UI logic 
    fluidPage(
      h1("rph.quiz"),
      fluidRow(
        col_12(
          tabsetPanel(
            id = "tabs",
            type = "hidden",
            tabPanel(
              "Hello",
              "This is the hello tab",
              value = "hello"
            )
          )
        )
      ),
      fluidRow(
        col_2(
          actionButton(
            inputId = "prev_button",
            "Back"
          )
        ),
        col_2(
          actionButton(
            inputId = "next_button",
            "Next"
          )
        )
      )
      #mod_question_ui("question_ui_1")
    )
  )
}

#' Add external Resources to the Application
#' 
#' This function is internally used to add external 
#' resources inside the Shiny application. 
#' 
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function(){
  
  add_resource_path(
    'www', app_sys('app/www')
  )
 
  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys('app/www'),
      app_title = 'rph.quiz'
    ),
    shinyjs::useShinyjs()
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert() 
  )
}

