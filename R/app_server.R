#' The application server-side
#' 
#' @param input,output,session Internal parameters for {shiny}. 
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function( input, output, session ) {

  whereami::cat_where(whereami::whereami())

  mongo_port <- get_golem_config("mongoport")
  mongo_host <- get_golem_config("mongohost")
  mongo_db <- get_golem_config("mongodb")
  mongo_collection <- get_golem_config("mongocollection")
  mongo_user <- get_golem_config("mongouser")
  mongo_password <- get_golem_config("mongopass")
  mongo_ca <- get_golem_config("mongoca")
  mongo_repset <- get_golem_config("mongorepset")

  if ( golem::get_golem_options("with_mongo") ){
    launch_mongo_shiny(
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
  #mod_question_server("question_ui_1")
  n_questions <- 2
  question_vec <- 1:n_questions
  
  # set up reactive values
  start_app <- reactiveVal(runif(1))
  start_time <- reactiveVal(Sys.time())

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

  # execute server-side question module
  answers_res <- purrr::map(1:2, ~mod_question_server(glue::glue("question_ui_{.x}"), question_index = .x), start_time)
  mod_complete_server("complete_ui_1", answers_res)

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
