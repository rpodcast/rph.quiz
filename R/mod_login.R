#' login UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_login_ui <- function(id){
  ns <- NS(id)
  tagList(
    fluidRow(
      col_6(
        selectInput(
          inputId = ns("auth_choice"),
          label = "Choose Login Method",
          choices = c("Google", "GitHub", "Email"),
          selected = "Google"
        )
      ),
      col_3(
        actionButton(ns("login_start"), label = "Login")
      )
      
      # actionButton(ns("google"), "Google", icon = icon("google"), class = "btn-danger"),
      # actionButton(ns("github"), "Github", icon = icon("github"), class = "btn-success"),
      # actionButton(ns("email_signin"), "Email Sign in", class = "btn-info"),
      # actionButton(ns("email_register"), "Email Register", class = "btn-info")
    )
  )
}
    
#' login Server Functions
#'
#' @noRd 
mod_login_server <- function(id, fire_obj_social = NULL, fire_obj_email = NULL){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    whereami::cat_where(whereami::whereami())
    # set up reactive values
    f_type <- reactiveVal(NULL)
  
    # modals
    sign_in <- shiny::modalDialog(
      title = "Sign in",
      textInput(ns("email_signin"), "Your email"),
      passwordInput(ns("password_signin"), "Your password"),
      footer = tagList(actionButton(ns("signin"), "Sign in"), shiny::modalButton(label = "Cancel"))
    )

    observeEvent(input$login_start, {
      req(input$auth_choice)

      if (input$auth_choice == "Google"){
        f_type("social")
        fire_obj_social$set_provider("google.com")
        fire_obj_social$launch()
      } else if (input$auth_choice == "GitHub"){
        f_type("social")
        fire_obj_social$set_provider("github.com")
        fire_obj_social$launch()
      } else if (input$auth_choice == "Email"){
        f_type("email")
        shiny::showModal(sign_in)
      } else {
        stop("Bad choice")
      }
    })

    observeEvent(input$signin, {
      removeModal()
      f_email$sign_in(input$email_signin, input$password_signin)
    })

    firebase_id <- reactive({
      req(f_type())
      message(glue::glue("f_type() is {f_type()}"))
      if (f_type() == "social") {
        fire_obj_social$req_sign_in()
        res <- fire_obj_social$get_signed_in()
      } else if (f_type() == "email") {
        fire_obj_email$req_sign_in()
        res <- fire_obj_email$get_signed_in()
      } else {
        stop("f is null")
        #f <- NULL
      }
      res$response$uid
    })

    res <- reactive({
      list(
        user_id_form = input$user_id_form,
        firebase_id = firebase_id(),
        create_click = input$login_start
      )
    })


  })
}
    
## To be copied in the UI
# mod_login_ui("login_ui_1")
    
## To be copied in the server
# mod_login_server("login_ui_1")
