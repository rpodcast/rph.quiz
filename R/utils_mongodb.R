launch_mongo <- function(
  collection = "quizanswers",
  db = "rphquiz",
  host = "127.0.0.1",
  port = 27017,
  user = "",
  pass = "",
  ca_path = "",
  replicaset = ""
) {
  if (user != "") {
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


#' launch mongodb in shiny app
#'
#' @description Initialize mongodb connection
#'
#' @return nothing (side effect of adding to `session` object)
#'
#' @noRd
launch_mongo_shiny <- function(
  session = getDefaultReactiveDomain(),
  collection = "quizanswers",
  db = "rphquiz",
  host = "127.0.0.1",
  port = 27017,
  user = NULL,
  pass = NULL,
  ca_path = NULL,
  replicaset = NULL
){

  session$userData$mongo <- launch_mongo(
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

get_mongo <- function(session = getDefaultReactiveDomain()) {
  session$userData$mongo
}

get_mongo_stats <- function(session = getDefaultReactiveDomain()) {
  session$userData$mongo_stats
}
