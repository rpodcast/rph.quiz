#' The application server-side
#' 
#' @param input,output,session Internal parameters for {shiny}. 
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function( input, output, session, random_question_order = TRUE ) {

  whereami::cat_where(whereami::whereami())

  prod_mode <- getOption("golem.app.prod")

  mongo_port <- get_golem_config("mongodb_port")
  mongo_host <- get_golem_config("mongodb_host")
  mongo_db <- get_golem_config("mongodb_db")
  mongo_collection <- get_golem_config("mongodb_collection")
  mongo_questions_collection <- get_golem_config("mongodb_questions_collection")
  mongo_users_collection <- get_golem_config("mongodb_users_collection")
  mongo_user <- get_golem_config("mongodb_user")
  mongo_password <- get_golem_config("mongodb_pass")
  mongo_ca <- get_golem_config("mongodb_ca")
  mongo_repset <- get_golem_config("mongodb_repset")

  if ( golem::get_golem_options("with_mongo") ){
    message("I am going to connect to mongo")
    launch_mongo_shiny(
      session = session,
      prod = prod_mode,
      collection = mongo_collection, 
      db = mongo_db, 
      host = mongo_host, 
      port = mongo_port, 
      user = mongo_user, 
      pass = mongo_password,
      ca_path = mongo_ca,
      replicaset = mongo_repset
    )

    launch_mongo_users_shiny(
      session = session,
      prod = prod_mode,
      collection = mongo_users_collection, 
      db = mongo_db, 
      host = mongo_host, 
      port = mongo_port, 
      user = mongo_user, 
      pass = mongo_password,
      ca_path = mongo_ca,
      replicaset = mongo_repset
    )
    
    quiz_df <- get_quiz_data(
      quiz = 1,
      session = session,
      prod = prod_mode,
      collection = mongo_questions_collection, 
      db = mongo_db, 
      host = mongo_host, 
      port = mongo_port, 
      user = mongo_user, 
      pass = mongo_password,
      ca_path = mongo_ca,
      replicaset = mongo_repset
    )
  }

  # Your application server logic 
  
  # import questions collection

    # Disable shiny server timeout
  prevent_counter <- mod_prevent_timeout_server("prevent_timeout_ui_1")

  fire_obj_social <- FirebaseOauthProviders$new()
  fire_obj_email <- FirebaseEmailPassword$new()

  observeEvent(prevent_counter, {
    if (!is.null(prevent_counter())) {
      x <- prevent_counter()
      message(glue::glue("session prevent count is {x}"))
    }
  })

  n_questions <- nrow(quiz_df)
  question_vec <- 1:n_questions

  if (random_question_order) {
    quiz_df <- dplyr::slice_sample(quiz_df, n = n_questions, replace = FALSE)
  }
  
  # set up reactive values
  start_app <- reactiveVal(runif(1))
  start_time <- reactiveVal(Sys.time())

  observeEvent(input$account_management, {
    shiny::showModal(
      shiny::modalDialog(
        title = "Account Management",
        mod_authentication_ui("authentication_ui_1"),
        size = "xl"
      )
    )
  })

  observeEvent(input$account_login, {
    shiny::showModal(
      shiny::modalDialog(
        title = "Account Management",
        mod_login_ui("login_ui_1"),
        size = "xl"
      )
    )
  })

  auth_res <- mod_authentication_server("authentication_ui_1", fire_obj_social, fire_obj_email)

  observeEvent(start_app(), {
    purrr::walk(question_vec, ~{
      quiz_sub <- dplyr::slice(quiz_df, .x)
      
      insertTab(
      inputId = "tabs",
      tabPanel(
        glue::glue("Tab {.x}"),
        mod_question_ui(
          glue::glue("question_ui_{.x}"), 
          question_index = .x, 
          type = quiz_sub$type, 
          question_text = quiz_sub$question_text, 
          choices_value = purrr::as_vector(quiz_sub$choices_value), 
          choices_text = purrr::as_vector(quiz_sub$choices_text) 
        ),
        value = glue::glue("qtab{.x}")
      ))
    })
    
    insertTab(
      inputId = "tabs",
      tabPanel(
        "Conclusion",
        mod_complete_ui("complete_ui_1"),
        value = "conclusion"
      )
    )
  })

  output$no_account <- reactive({
    res1 <- fire_obj_social$is_signed_in()
    res2 <- fire_obj_email$is_signed_in()
    is.null(res1) && is.null(res2)
    
  })

  outputOptions(output, "no_account", suspendWhenHidden = FALSE)

  output$account_display <- renderUI({
    res1 <- fire_obj_social$is_signed_in()
    res2 <- fire_obj_email$is_signed_in()
    if (any(res1, res2)) {
      session$userData$fire_trigger <- 1
      firebase_id <- session$userData$firebase_id
      shiny::removeModal()
      p("Welcome back!")
    }
  })

  # execute server-side question module
  whereami::cat_where(whereami::whereami())
  answers_res <- purrr::map(question_vec, ~mod_question_server(glue::glue("question_ui_{.x}"), question_index = .x), start_time)
  mod_complete_server("complete_ui_1", answers_res, fire_obj_social, fire_obj_email)

  observeEvent(input$next_button, {
    # grab current tab
    current_tab <- input$tabs
    tab_number <- as.integer(stringr::str_extract(current_tab, "\\d+"))
    
    if (current_tab == "hello") {
      next_tab <- "qtab1"
      updateTabsetPanel(
          inputId = "tabs",
          selected = next_tab
        )
    } else {
      if (is.null(answers_res[[tab_number]]())) {
        shinyWidgets::show_alert(
          title = "Oops!",
          text = "Please select an answer before you continue.",
          type = "error"
        )
        return(NULL)
      }

      if (tab_number == n_questions) {
        next_tab <- "conclusion"
        updateTabsetPanel(
          inputId = "tabs",
          selected = next_tab
        )
      }

      if (tab_number < n_questions) {
        next_tab <- glue::glue("qtab{tab_number + 1}")
        updateTabsetPanel(
          inputId = "tabs",
          selected = next_tab
        )
      }
    }
    start_time(Sys.time())
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
      if (current_tab == "conclusion") {
        prev_tab <- glue::glue("qtab{n_questions - 1}")
        updateTabsetPanel(
          inputId = "tabs",
          selected = prev_tab
        )
      }

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
