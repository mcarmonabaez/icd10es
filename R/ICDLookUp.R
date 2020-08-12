
ICDLookUp <- function(pattern, nMatches = 1, jwBound = 0.9) {

  huerfanos <- c('exogeno') ## esto se va a ir a global variables
  pattern <- CleanString(gsub(paste(huerfanos, collapse = '|'),
                              replacement = '', x = CleanString(pattern)))

  #Look for particular diseases
  specialCases <- c('neumonia', 'diabetes', 'cancer', 'tumor',
                    'sepsis', 'sindrome') ## esto se va a ir a global variables
  flagSpecialCase <- str_match(pattern, specialCases)
  flagSpecialCase <- flagSpecialCase[!is.na(flagSpecialCase)]

  if(length(flagSpecialCase) > 1) stop('Looks like your query has more than one disease listed. \n
                                            Try refining your query.')
  if(length(flagSpecialCase) == 1) {
    matchICD <- switch(flagSpecialCase,
                       neumonia = 'holi',
                       diabetes = 'diabetis',
                       cancer = 'bai')

    return(matchICD)
  }

  if(flagSpecialCase == 0) {
    subCoincidence <- catalogLookUp(pattern, nMatches, jwBound, subcategories)
    if(!is.null(subCoincidence)) {
      return(subCoincidence)
    } else {
      mainCoincidence <- catalogLookUp(pattern, nMatches, jwBound, categories)
      return(mainCoincidence)
    }

  }

}
