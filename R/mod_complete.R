#' complete UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_complete_ui <- function(id){
  ns <- NS(id)
  tagList(
    fluidRow(
      col_12(
        h2("All done!"),
        # p("If you would like to see how you stack up against other players, you can opt-in to creating a free authentication to the application and have your score included in the leaderboard! If you don't want to be included and just want to see how you did, that's totally fine too."),
        # checkboxInput(
        #   inputId = ns("opt_in_account"),
        #   label = "Opt-in to create a free leaderboard account",
        #   width = "100%",
        #   value = FALSE
        # ),
        # conditionalPanel(
        #   condition = "input.opt_in_account",
        #   ns = ns,
        #   #p("H")
        #   mod_authentication_ui(ns("authentication_ui_1"))
        # ),
        actionButton(
          inputId = ns("qsubmit"),
          label = "Submit",
          icon = icon("check"),
          class = "btn-success"
        )
      )
    )
  )
}
    
#' complete Server Functions
#'
#' @noRd 
mod_complete_server <- function(id, answers_res, fire_obj_social, fire_obj_email){
  moduleServer( id, function(input, output, session){
    ns <- session$ns


    # observeEvent(click_trigger(), {
    #   if (shiny::isTruthy(auth_res()$firebase_id)) {
    #     if (auth_res()$firebase_id != current_firebase_id()) {
    #       whereami::cat_where(whereami::whereami(path_expand = TRUE))
    #       # assemble tidy data frame of each question and answer
    #       q_df <- purrr::map_df(answers_res, ~{ tmp <- .x()}) %>%
    #         dplyr::mutate(user_id_form = auth_res()$user_id_form, firebase_id = auth_res()$firebase_id, timestamp = Sys.time())
          
    #       # send to database
    #       qdb_res <- get_mongo()$insert(data = q_df)

    #       shinyWidgets::show_alert(
    #         title = "Yes!",
    #         text = glue::glue("Thank you, {auth_res()$user_id_form}! Your answers have been submitted"),
    #         type = "success"
    #       )

    #       current_firebase_id(auth_res()$firebase_id)
    #     }
    #   }
    # })

    observeEvent(input$qsubmit, {
      browser()
      if (fire_obj_social$is_signed_in()) {
        res <- fire_obj_social$get_signed_in()
      }

      if (fire_obj_email$is_signed_in()) {
        res <- fire_obj_email$get_signed_in()
      }

      if (shiny::isTruthy(res)) {
        #firebase_id <- auth_res()$firebase_id
        #user_id_form <- auth_res()$user_id_form
        # assemble tidy data frame of each question and answer
        q_df <- purrr::map_df(answers_res, ~{ tmp <- .x()}) %>%
          dplyr::mutate(user_id_form = session$userData$user_id_form, firebase_id = res$response$uid, timestamp = Sys.time())
        
        # send to database
        qdb_res <- get_mongo()$insert(data = q_df)

        shinyWidgets::show_alert(
          title = "Yes!",
          text = glue::glue("Thank you, {session$userData$user_id_form}! Your answers have been submitted"),
          type = "success"
        )
      } else {
        shinyWidgets::show_alert(
          title = "Yes!",
          text = glue::glue("Thank you! Your answers have been submitted"),
          type = "success"
        )
      }
    })
  })
}
    
## To be copied in the UI
# mod_complete_ui("complete_ui_1")
    
## To be copied in the server
# mod_complete_server("complete_ui_1")
