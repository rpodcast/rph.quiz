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

    observeEvent(input$qsubmit, {
      
      if (is.null(session$userData$fire_trigger)) {
        res <- NULL
      } else {
        if (fire_obj_social$is_signed_in()) {
          res <- fire_obj_social$get_signed_in()
        }

        if (fire_obj_email$is_signed_in()) {
          res <- fire_obj_email$get_signed_in()
        }
      }

      if (shiny::isTruthy(res)) {
        

        # grab contents of current users collection
        n_rows <- get_mongo_users()$count()

        # if records exist, grab the unique names
        if (n_rows > 0) {
          # check if user ID exists
          all_ids <- get_mongo_users()$distinct(
            'user_id', query = '{}'
          )

          if (!session$userData$user_id_form %in% all_ids) {
            # add to mongodb database
            user_df <- tibble::tibble(
              firebase_id = res$response$uid,
              user_id = session$userData$user_id_form
            )

            user_res <- get_mongo_users()$insert(data = user_df)
          }
        } else {
          # add to mongodb database
          user_df <- tibble::tibble(
            firebase_id = res$response$uid,
            user_id = session$userData$user_id_form
          )

          user_res <- get_mongo_users()$insert(data = user_df)
        }

        answers_res1 <- purrr::map(answers_res, ~{ tmp <- .x()})
        
        q_res <- purrr::map(answers_res1, function(x) {
          tmp <- x
          tmp[["user_id"]] <- session$userData$user_id_form
          tmp[["firebase_id"]] <- res$response$uid
          tmp[["timestamp"]] <- Sys.time()

          return(tmp)
        })
        
        # send to database
        qdb_res <- purrr::walk(q_res, ~get_mongo()$insert(data = .x))

        shinyWidgets::show_alert(
          title = "Yes!",
          text = glue::glue("Thank you! Your answers have been submitted"),
          type = "success"
        )
      } else {

        answers_res1 <- purrr::map(answers_res, ~{ tmp <- .x()})

        q_res <- purrr::map(answers_res1, function(x) {
          tmp <- x
          tmp[["user_id"]] <- "anonymous"
          tmp[["firebase_id"]] <- "anonymous"
          tmp[["timestamp"]] <- Sys.time()

          return(tmp)
        })
        # send to database
        qdb_res <- purrr::walk(q_res, ~get_mongo()$insert(data = .x))

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
