#' Main function for looking up a given pattern.
#'
#' @param pattern A string of the name of the disease to look up.
#' @param nMatches A number indicating the number of matches to return in case of more than one coincidence.
#' @param jwBound A real number between 0 and 1 that determines de lower bound for Jaro-Winkler distance.
#' @param tabular A string that can take values 'single', 'simple', or full'.
#' @param useExternal A logical that is TRUE when the user inputs their own catalog to search in.
#' @param externalCatalog An optional data frame containing the external catalog where the search will be made.
#' @param searchVar A string containing the variable within the catalog where the search will be made.
#'
#' @return A data frame with the information about the matches found for the disease.
#' @export
#'
#' @import stringr
#' @import tibble
#'
ICDLookUp <- function(pattern, nMatches = 1, jwBound = 0.9, tabular = 'single',
                      useExternal = FALSE, externalCatalog = NULL, searchVar = 'disease') {

  pattern <- cleanString(pattern)

  if(useExternal) {
    return(catalogLookUp(pattern, nMatches, jwBound, tabular, externalCatalog, searchVar))
  }

  #Look for particular diseases
  specialCases <- tribble(~pattern, ~group,
                          'neumonia', 'neumonia',
                          'diabetes', 'diabetes',
                          'diabetic', 'diabetes',
                          'cetoacidosis', 'diabetes',
                          'cancer', 'cancer',
                          'tumor maligno', 'cancer',
                          'tumores malignos', 'cancer',
                          'leucemia', 'cancer',
                          'melanoma', 'cancer',
                          'sepsis', 'sepsis',
                          'sindrome', 'sindrome')## esto se va a ir a data interna

  dfSpecialCase <- specialCases[!is.na(str_match(pattern, specialCases$pattern)),]
  flagSpecialCase <- unique(dfSpecialCase$group)

  if(length(flagSpecialCase) > 1) stop('Looks like your query has more than one disease listed. \nTry refining your query.')
  if(length(flagSpecialCase) == 1) {
    matchICD <- switch(flagSpecialCase,
                       neumonia = 'holi',
                       diabetes = catalogLookUp(pattern, nMatches, jwBound, diabetes_subcategories),
                       cancer = catalogLookUp(cleanCancer(pattern), nMatches, jwBound, tabular, cancer_subcategories))

    return(matchICD)
  }

  if(length(flagSpecialCase) == 0) subCoincidence <- catalogLookUp(pattern, nMatches, jwBound, tabular, subcategories)

  return(subCoincidence)

}
