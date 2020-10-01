#' Clean noise from string
#'
#' @param pattern The string whose noise will be removed (special characters, double spaces, etc.).
#'
#' @return A new version of the string in lowercase without noise.
#' @importFrom stringi stri_trans_general
#' @import stringr
#'
#' @export

cleanString <- function(pattern) {
  #Remove noise from string
  pattern <- tolower(pattern)
  pattern <- stri_trans_general(pattern, "Latin-ASCII")
  pattern <- str_remove_all(pattern, "[^a-z0-9 ]")
  pattern <- gsub(' +',' ', pattern)
  pattern <- str_trim(pattern)

  return(pattern)
}

#' Clean cancer pattern
#'
#' @param pattern The string whose stopwords and cancer stuff will be removed
#'
#' @return A new version of the string in lowercase without noise.
#' @importFrom stringi stri_trans_general
#' @import stringr
#'
#' @export

cleanCancer <- function(pattern) {

  pattern <- str_remove(pattern, 'tumor maligno |tumores malignos |cancer ')
  pattern <- str_replace_all(pattern, stopwords_regex, '')
  pattern <- cleanString(pattern)

  return(pattern)
}
