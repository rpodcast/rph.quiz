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
        p("Enter a unique ID in the field below and click submit to see how well you did"),
        textInput(
          inputId = ns("user_id"),
          "ID",
          value = ""
        ),
        shinyWidgets::actionBttn(
          inputId = ns("qsubmit"),
          label = "Submit",
          icon = icon("check"),
          color = "success",
          size = "sm",
          style = "jelly"
        )
      )
    )
  )
}
    
#' complete Server Functions
#'
#' @noRd 
mod_complete_server <- function(id, answers_res){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    # reactive values
    

    observeEvent(input$qsubmit, {
      if (!shiny::isTruthy(input$user_id)) {
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
          'name', query = '{}'
        )

        # TODO: Finish checking
        if (input$user_id %in% all_ids) {
          shinyWidgets::show_alert(
            title = "Oops!",
            text = glue::glue("ID {input$user_id} already exists! Please enter a different ID."),
            type = "error"
          )

          updateTextInput(inputId = ns("user_id"), value = "")

          return(NULL)
        }
      }

      # assemble tidy data frame of each question and answer
      q_df <- purrr::map_df(answers_res, ~{ tmp <- .x()}) %>%
        dplyr::mutate(name = input$user_id, timestamp = Sys.time())
      
      # send to database
      qdb_res <- get_mongo()$insert(data = q_df)

      shinyWidgets::show_alert(
          title = "Yes!",
          text = glue::glue("Thank you, {input$user_id}! Your answers have been submitted"),
          type = "success"
      )

      updateTextInput(inputId = ns("user_id"), value = "")
    })
  })
}
    
## To be copied in the UI
# mod_complete_ui("complete_ui_1")
    
## To be copied in the server
# mod_complete_server("complete_ui_1")
