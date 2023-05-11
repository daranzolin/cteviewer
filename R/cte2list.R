#' @title Assign tables from a CTE SQL query to a list
#'
#' @description
#'   Reads the currently open query from the RStudio API and returns
#'   a list of data frames for each CTE query.
#'
#' @return No return value, called for side effects
#'
#' @export
cte2list <- function() {
  variable_name <- rstudioapi::showPrompt("cteviewer", "Variable name for list output:")
  query_lines <- get_sql_contents()
  queries <- get_queries(query_lines)
  assign(variable_name, queries, envir = globalenv())
}
