#' The application server-side
#' 
#' @param input,output,session Internal parameters for {shiny}. 
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function( input, output, session ) {

  whereami::cat_where(whereami::whereami())

  prod_mode <- getOption("golem.app.prod")

  mongo_port <- get_golem_config("mongodb_port")
  mongo_host <- get_golem_config("mongodb_host")
  mongo_db <- get_golem_config("mongodb_db")
  mongo_collection <- get_golem_config("mongodb_collection")
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
  }

  # Your application server logic 
  
    # Disable shiny server timeout
  prevent_counter <- mod_prevent_timeout_server("prevent_timeout_ui_1")

  fire_obj_social <- FirebaseOauthProviders$new()
  fire_obj_email <- FirebaseEmailPassword$new()

  # fire_obj <- FirebaseUI$
  #   new("session")$
  #   set_providers(
  #     email = TRUE,
  #     google = TRUE,
  #     github = TRUE
  #   )$
  #   set_tos_url("https://www.privacypolicies.com/live/8c9023f9-2951-45a6-9a54-dcb2c90501bc")$
  #   set_privacy_policy_url("https://www.privacypolicies.com/live/16ca37a3-6ea5-43b5-b469-3987fd749d8a")
  # f_social <- FirebaseOauthProviders$new()
  # f_email <- FirebaseEmailPassword$new()

  #mod_authentication_server("authentication_ui_1", f_social, f_email)

  observeEvent(prevent_counter, {
    if (!is.null(prevent_counter())) {
      x <- prevent_counter()
      message(glue::glue("session prevent count is {x}"))
    }
  })

  n_questions <- 2
  question_vec <- 1:n_questions
  
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

  auth_res <- mod_authentication_server("authentication_ui_1", fire_obj_social, fire_obj_email)

  observeEvent(start_app(), {
    purrr::walk(1:2, ~insertTab(
      inputId = "tabs",
      tabPanel(
        glue::glue("Tab {.x}"),
        mod_question_ui(glue::glue("question_ui_{.x}"), question_index = .x),
        value = glue::glue("qtab{.x}")
      )))
    
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
      shiny::removeModal()
      p("Welcome!")
    }
  })

  # execute server-side question module
  whereami::cat_where(whereami::whereami())
  answers_res <- purrr::map(1:2, ~mod_question_server(glue::glue("question_ui_{.x}"), question_index = .x), start_time)
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
