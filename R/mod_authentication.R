#' authentication UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
#' @import firebase
mod_authentication_ui <- function(id){
  ns <- NS(id)
  tagList(
    fluidRow(
      col_6(
        radioButtons(
          inputId = ns("auth_choice"),
          label = "Choose Authentication Creation Method",
          choices = c("Google", "GitHub", "Email"),
          selected = "Google",
          inline = TRUE
        )
      ),
      col_3(
        textInput(
          inputId = ns("user_id_form"),
          label = "Enter a unique user ID",
          value = ""
        )
      ),
      col_3(
        actionButton(ns("create_account"), label = "Create Account")
      )
      
      # actionButton(ns("google"), "Google", icon = icon("google"), class = "btn-danger"),
      # actionButton(ns("github"), "Github", icon = icon("github"), class = "btn-success"),
      # actionButton(ns("email_signin"), "Email Sign in", class = "btn-info"),
      # actionButton(ns("email_register"), "Email Register", class = "btn-info")
    )
  )
}
    
#' authentication Server Functions
#'
#' @noRd 
mod_authentication_server <- function(id, fire_obj_social = NULL, fire_obj_email = NULL){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    whereami::cat_where(whereami::whereami())
    # set up reactive values
    f_type <- reactiveVal(NULL)
    

    # modals
    register <- shiny::modalDialog(
      title = "Register",
      textInput(ns("email_create"), "Your email"),
      passwordInput(ns("password_create"), "Your password"),
      footer = actionButton(ns("create"), "Register")
    )

    sign_in <- shiny::modalDialog(
      title = "Sign in",
      textInput(ns("email_signin"), "Your email"),
      passwordInput(ns("password_signin"), "Your password"),
      actionButton(ns("signin"), "Sign in")
    )

    observeEvent(input$create_account, {
      req(input$auth_choice)

      if (!shiny::isTruthy(input$user_id_form)) {
        shinyWidgets::show_alert(
          title = "Oops!",
          text = "Please enter an ID.",
          type = "error"
        )
        return(NULL)
      }

      # check if any rows are present in the db
      n_rows <- get_mongo()$count()

      # if records exist, grab the unique names
      if (n_rows > 0) {
        # check if user ID exists
        all_ids <- get_mongo()$distinct(
          'user_id_form', query = '{}'
        )

        if (input$user_id_form %in% all_ids) {
          shinyWidgets::show_alert(
            title = "Oops!",
            text = glue::glue("ID {input$user_id_form} already exists! Please enter a different ID."),
            type = "error"
          )

          updateTextInput(inputId = "user_id_form", value = "")
          return(NULL)
        }
      }

      session$userData$user_id_form <- input$user_id_form

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
        shiny::showModal(register)
      } else {
        stop("Bad choice")
      }
    })

  
    # observeEvent(input$google, {
    #   f_type("social")
    #   f_social$set_provider("google.com")
    #   f_social$launch()
    # })

    # observeEvent(input$github, {
    #   f_type("social")
    #   f_social$set_provider("github.com")
    #   f_social$launch()
    # })

    # observeEvent(input$email_signin, {
    #   f_type("email")
    #   shiny::showModal(sign_in)
    # })

    # observeEvent(input$email_register, {
    #   f_type("email")
    #   shiny::showModal(register)
    # })

    # create the user
    observeEvent(input$create, {
      fire_obj_email$create(input$email_create, input$password_create)
    })

    # check if creation sucessful
    observeEvent(fire_obj_email$get_created(), {
      created <- fire_obj_email$get_created()
      
      if(created$success) {
        removeModal()
        showNotification("Account created!", type = "message")
      } else {
        showNotification("Error!", type = "error")
      }

      # print results to the console
      print(created)
    })

    # observeEvent(input$signin, {
    #   removeModal()
    #   f_email$sign_in(input$email_signin, input$password_signin)
    # })
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

    # output$auth_diag <- renderPrint({
    #   req(f_type())
    #   message(glue::glue("f_type() is {f_type()}"))
    #   if (f_type() == "social") {
    #     fire_obj_social$req_sign_in()
    #     res <- fire_obj_social$get_signed_in()
    #   } else if (f_type() == "email") {
    #     fire_obj_email$req_sign_in()
    #     res <- fire_obj_email$get_signed_in()
    #   } else {
    #     stop("f is null")
    #     #f <- NULL
    #   }
      
    #   print(res)
    # })

    res <- reactive({
      list(
        user_id_form = input$user_id_form,
        firebase_id = firebase_id(),
        create_click = input$create_account
      )
    })

    return(res)
  })
}

    
## To be copied in the UI
# mod_authentication_ui("authentication_ui_1")
    
## To be copied in the server
# mod_authentication_server("authentication_ui_1")
