#' @title Creates a View() output for each expression in a CTE SQL query
#'
#' @description
#'   Reads the currently open query from the RStudio API and creates
#'   a View() tab for each expression in a CTE SQL query.
#'
#' @return No return value, called for side effects
#'
#' @export
cte2views <- function() {
  query_lines <- get_sql_contents()
  queries <- get_queries(query_lines)
  for (i in seq_along(queries)) View(queries[[i]], title = names(queries)[i])
}
