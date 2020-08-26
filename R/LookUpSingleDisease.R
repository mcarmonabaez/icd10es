#' Look up disease in ICD10 catalog
#'
#' @param pattern A string of the name of the disease to look up.
#' @param nMatches A number indicating the number of matches to return in case of more than one coincidence.
#'
#' @return A data frame with the information about the matches found for the disease.

catalogLookUp <- function(pattern, nMatches = 1, jwBound = 0.9, catalog) {

  #Look up exact match in disease catalog
  diseaseToPattern <- str_match(pattern, catalog$padecimiento)
  patternToDisease <- str_match(catalog$padecimiento, pattern)
  flagMatch <- sum(diseaseToPattern == patternToDisease, na.rm = T)

  if(flagMatch == 1) {
    indCoincidence <- catalog$subcategoria[!is.na(diseaseToPattern)]
    return(printInfo(indCoincidence))
  }

  #Look up exact match in category catalog

  #number of coincidences where the pattern was longer than the disease
  residualPattern <- isTRUE(sum(!is.na(diseaseToPattern), na.rm = T) > 0)
  #number of coincidences where the disease was longer than the pattern
  residualDisease <- isTRUE(sum(!is.na(patternToDisease), na.rm = T) > 0)


  if(residualPattern == TRUE) {
    dfDisease <- data.frame(match = diseaseToPattern,
                            disease = catalog$padecimiento,
                            subcategory = catalog$subcategoria,
                            stringsAsFactors = FALSE)[!is.na(diseaseToPattern), ]
    if(nrow(dfDisease) == 1) return(printInfo(dfDisease$subcategory)) ## regresar la subcategoria 'no especificado'
    if(nrow(dfDisease) > 0 ) return(diseaseToPattern) ## revisar si es una sola categoria o mas de una
  }

  if(residualDisease == TRUE) {
    dfDisease <- data.frame(match = patternToDisease,
                            disease = catalog$padecimiento,
                            subcategory = catalog$subcategoria,
                            stringsAsFactors = FALSE)[!is.na(patternToDisease), ]
    if(nrow(dfDisease) == 1) return(patternToDisease) ## regresar la subcategoria
    if(nrow(dfDisease) > 0 ) return(residualMatch(dfDisease))
  }

  if(residualDisease + residualPattern == 0) {
    jwMatch <- data.frame(padecimiento = catalog$padecimiento,
                          metric = stringdist::stringsim(catalog$padecimiento,
                                     pattern, method = 'jw', p = 0)) %>%
      filter(metric >= jwBound)
    if(nrow(jwMatch) >= 0) {
      ## revisar si es una sola categoria o mas de una... como arribita
    } else {
      return(NULL)
    }
  }
}

residualMatch <- function(dfDisease) {
  #Check if there's more than one category
  nCat <- sort(table(substr(dfDisease$subcategory, 1, 1)))
  if(length(nCat) == 1) {
    indNotSpecified <- which(substr(dfDisease$subcategory, 4, 4) == '9')
    if(length(indNotSpecified) == 1) {
      return(print(dfDisease$subcategory[indNotSpecified]))
    } else {
      indNotSpecified <- which(!is.na(str_match(dfDisease$disease, 'no especificad')))
      return(printInfo(dfDisease$subcategory[indNotSpecified]))
    }
  } else {

  }

}
