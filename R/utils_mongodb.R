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

get_mongo <- function(session = getDefaultReactiveDomain()) {
  session$userData$mongo
}

get_mongo_stats <- function(session = getDefaultReactiveDomain()) {
  session$userData$mongo_stats
}
