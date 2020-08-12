#' Clean noise from string
#'
#' @param pattern The string whose noise will be removed (special characters, double spaces, etc.).
#'
#' @return A new version of the string in lowercase without noise.

CleanString <- function(pattern) {
  #Remove noise from string
  pattern <- tolower(pattern)
  pattern <- stringi::stri_trans_general(pattern, "Latin-ASCII")
  pattern <- str_remove_all(pattern, "[^a-z0-9 ]")
  pattern <- gsub(' +',' ', pattern)
  pattern <- str_trim(pattern)

  return(pattern)
}
