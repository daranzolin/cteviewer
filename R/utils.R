get_sql_contents <- function() {
  ctx <- rstudioapi::getSourceEditorContext()
  stopifnot(
    "Must be a SQL file." = grepl("\\.sql$", ctx$path, ignore.case = TRUE)
  )

  query_text <- ctx$contents
  return(query_text)
}

get_queries <- function(query_lines) {
  prev_conn <- "-- !preview conn="
  conn_string <- gsub(prev_conn, "", grep(prev_conn, query_lines, value = TRUE))
  conn <- eval(parse(text = conn_string))
  on.exit(DBI::dbDisconnect(conn))
  db_tables <- DBI::dbListTables(conn)

  q_names_inds <- grep("(WITH)?.*AS ?\\(", query_lines, ignore.case = TRUE)
  qnames <- gsub("(WITH | AS ?\\()", "", query_lines[q_names_inds], ignore.case = TRUE)
  stopifnot(
    "CTE table names exist as tables in database." = !any(qnames %in% db_tables)
  )

  q_starts <- q_names_inds + 1
  q_ends <- utils::tail(c(q_names_inds, grep("^\\)$", query_lines)), -1) - 1

  queries <- vector(mode = "list", length = length(qnames))
  names(queries) <- qnames

  for (i in seq_along(queries)) {
    query <- gsub("\\),$", "", paste(query_lines[q_starts[i]:q_ends[i]], collapse = "\n"))
    out <- DBI::dbGetQuery(conn, query)
    DBI::dbWriteTable(conn, names(queries)[i], out)
    queries[[i]] <- out
  }

  for (i in seq_along(qnames)) DBI::dbRemoveTable(conn, qnames[i])
  return(queries)
}
