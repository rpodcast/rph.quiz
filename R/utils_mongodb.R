launch_mongo <- function(
  prod = FALSE,
  collection = "quizanswers",
  db = "rphquiz",
  host = "127.0.0.1",
  port = 27017,
  user = Sys.getenv("MONGODB_USER"),
  pass = Sys.getenv("MONGODB_PASS"),
  ca_path = "",
  replicaset = Sys.getenv("MONGODB_REPLICASET")
) {
  if (prod) {
    message("entered prod of launch_mongo")
    
    url_string <- sprintf("mongodb+srv://%s:%s@%s/admin?authSource=admin&replicaSet=%s",
    user,
    pass,
    host,
    replicaset)

    mongolite::mongo(
      collection =  collection, 
      db = db, 
      url = url_string,
      options = mongolite::ssl_options(ca = ca_path, allow_invalid_hostname = TRUE)
    )
  } else {
    url_string <- sprintf("mongodb://%s:%s", host, port)

    mongolite::mongo(
      collection =  collection, 
      db = db, 
      url = url_string
    )
  }
}

launch_gridfs <- function(
  prod = FALSE,
  prefix = "fs",
  db = "rphquiz",
  host = "127.0.0.1",
  port = 27017,
  user = Sys.getenv("MONGODB_USER"),
  pass = Sys.getenv("MONGODB_PASS"),
  ca_path = "",
  replicaset = Sys.getenv("MONGODB_REPLICASET")) {

  if (prod) {
    message("entered prod of launch_gridfs")
    
    url_string <- sprintf("mongodb+srv://%s:%s@%s/admin?authSource=admin&replicaSet=%s",
    user,
    pass,
    host,
    replicaset)

    mongolite::gridfs(
      db = db, 
      prefix = prefix,
      url = url_string,
      options = mongolite::ssl_options(ca = ca_path, allow_invalid_hostname = TRUE)
    )
  } else {
    url_string <- sprintf("mongodb://%s:%s", host, port)

    mongolite::gridfs(
      db = db, 
      prefix = prefix,
      url = url_string
    )
  }
}


#' launch mongodb in shiny app
#'
#' @description Initialize mongodb connection
#'
#' @return nothing (side effect of adding to `session` object)
#'
#' @noRd
launch_mongo_shiny <- function(
  session = getDefaultReactiveDomain(),
  prod = FALSE,
  collection = "quizanswers",
  db = "rphquiz",
  host = "127.0.0.1",
  port = 27017,
  user = NULL,
  pass = NULL,
  ca_path = NULL,
  replicaset = NULL
){
  message("entered launch mongo shiny")
  
  session$userData$mongo <- launch_mongo(
    prod = prod,
    collection = collection,
    db = db,
    host = host,
    port = port,
    user = user,
    pass = pass,
    ca_path = ca_path,
    replicaset = replicaset
  )

  session$userData$mongo_stats <- list(
    collection = collection, 
    db = db, 
    url = url, 
    port = port
  )

  invisible(TRUE)
}

launch_mongo_users_shiny <- function(
  session = getDefaultReactiveDomain(),
  prod = FALSE,
  collection = "users",
  db = "rphquiz",
  host = "127.0.0.1",
  port = 27017,
  user = NULL,
  pass = NULL,
  ca_path = NULL,
  replicaset = NULL
){
  message("entered launch mongo shiny")
  
  session$userData$mongo_users <- launch_mongo(
    prod = prod,
    collection = collection,
    db = db,
    host = host,
    port = port,
    user = user,
    pass = pass,
    ca_path = ca_path,
    replicaset = replicaset
  )

  invisible(TRUE)
}

get_mongo_users <- function(session = getDefaultReactiveDomain()) {
  session$userData$mongo_users
}

get_mongo <- function(session = getDefaultReactiveDomain()) {
  session$userData$mongo
}

get_mongo_stats <- function(session = getDefaultReactiveDomain()) {
  session$userData$mongo_stats
}

get_quiz_data <- function(
  quiz = 1,
  session = getDefaultReactiveDomain(),
  prod = FALSE,
  collection = "questions",
  db = "rphquiz",
  host = "127.0.0.1",
  port = 27017,
  user = NULL,
  pass = NULL,
  ca_path = NULL,
  replicaset = NULL
) {
  m <- launch_mongo(
    prod = prod,
    collection = collection,
    db = db,
    host = host,
    port = port,
    user = user,
    pass = pass,
    ca_path = ca_path,
    replicaset = replicaset
  )

  res <- m$find() %>%
    dplyr::mutate(quiz = purrr::as_vector(quiz),
         qid = purrr::as_vector(qid),
         question_text = purrr::as_vector(question_text),
         answer_text = purrr::as_vector(answer_text),
         type = purrr::as_vector(type)) %>%
    dplyr::filter(quiz == quiz)

  return(res)
}