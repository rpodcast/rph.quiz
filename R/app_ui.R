#' The application User-Interface
#' 
#' @param request Internal parameter for `{shiny}`. 
#'     DO NOT REMOVE.
#' @import shiny bslib firebase
#' @noRd
app_ui <- function(request) {
  n_questions <- 1:2
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # Your application UI logic 
    fluidPage(
      theme = bs_theme(
        bootswatch = "sketchy",
        base_font = font_google("Klee One"),
        heading_font = font_google("Klee One"),
        font_scale = 2
      ),
      useFirebaseUI(),
      #reqSignin(
        fluidRow(
          col_12(
            tabsetPanel(
              id = "tabs",
              type = "hidden",
              tabPanel(
                "Hello",
                mod_welcome_ui("welcome_ui_1"),
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
        ),
        conditionalPanel(
          condition = "output.no_account",
          fluidRow(
            col_12(
              p("If you would like to see how you stack up to others in your R knowledge, you can opt-in to authenticating with your existing Google or GitHub accounts (or set up a custom email login) to be included in the leaderboard!"),
              actionButton("account_management", "Account Management")
            )
          )
        ),
        uiOutput("account_display")
        
      #)
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
    shinyjs::useShinyjs(),
    firebase::useFirebase()
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert() 
  )
}

