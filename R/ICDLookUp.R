#' Main function for looking up a given pattern.
#'
#' @param pattern A string of the name of the disease to look up.
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
ICDLookUp <- function(pattern, jwBound = 0.9, tabular = 'single',
                      useExternal = FALSE, externalCatalog = NULL, searchVar = 'disease') {

  pattern <- cleanString(pattern)

  if(useExternal) {
    return(printInfo(catalogLookUp(pattern, jwBound, externalCatalog, searchVar), tabular = tabular))
  }

  #Look for particular diseases
  specialCases <- tribble(~pattern, ~group,
                          'diabetes', 'diabetes',
                          'diabetic', 'diabetes',
                          'cetoacidosis', 'diabetes',
                          'cancer', 'cancer',
                          'tumor maligno', 'cancer',
                          'tumores malignos', 'cancer',
                          'leucemia', 'cancer',
                          'melanoma', 'cancer'
                          )

  # TODO: store special cases as internal data

  dfSpecialCase <- specialCases[!is.na(str_match(pattern, specialCases$pattern)),]
  flagSpecialCase <- unique(dfSpecialCase$group)

  # if(length(flagSpecialCase) > 1) stop('Looks like your query has more than one disease listed. \nTry refining your query.')
  if(length(flagSpecialCase) > 1) return(data.frame(category = NA_character_,
                                                    subcategory = NA_character_, disease = NA_character_))

  if(length(flagSpecialCase) == 1) {
    matchICD <- switch(flagSpecialCase,
                       diabetes = catalogLookUp(pattern, jwBound, diabetes_subcategories),
                       cancer = catalogLookUp(cleanCancer(pattern), jwBound, cancer_subcategories))

    return(printInfo(matchICD, tabular = tabular))
  }

  if(length(flagSpecialCase) == 0) subCoincidence <- catalogLookUp(pattern, jwBound, subcategories)

  return(printInfo(subCoincidence, tabular = tabular))

}
