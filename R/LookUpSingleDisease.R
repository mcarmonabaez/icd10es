#' Look up disease in ICD10 catalog
#'
#' @param pattern A string of the name of the disease to look up.
#' @param nMatches A number indicating the number of matches to return in case of more than one coincidence.
#'
#' @return A data frame with the information about the matches found for the disease.

catalogLookUp <- function(pattern, nMatches = 1, jwBound = 0.9, catalog) {

  #Look up exact match in disease catalog
  diseaseToPattern <- str_match(pattern, categories$padecimiento)
  patternToDisease <- str_match(categories$padecimiento, pattern)
  flagMatch <- sum(diseaseToPattern == patternToDisease, na.rm = T)

  if(flagMatch == 1) {
    #devolver subcategoria y clave y si es principal o alternativo
  }

  #Look up exact match in category catalog

  #number of coincidences where the pattern was longer than the disease
  residualPattern <- isTRUE(sum(!is.na(diseaseToPattern), na.rm = T) > 0)
  #number of coincidences where the disease was longer than the pattern
  residualDisease <- isTRUE(sum(!is.na(patternToDisease), na.rm = T) > 0)


  if(residualPattern == TRUE) {
    diseaseToPattern <- diseaseToPattern[!is.na(diseaseToPattern)]
    if(length(diseaseToPattern) == 1) return(diseaseToPattern) ## regresar la subcategoria
    if(length(diseaseToPattern) > 0 ) return(diseaseToPattern) ## revisar si es una sola categoria o mas de una
  }

  if(residualDisease == TRUE) {
    patternToDisease <- patternToDisease[!is.na(patternToDisease)]
    if(length(patternToDisease) == 1) return(patternToDisease) ## regresar la subcategoria
    if(length(patternToDisease) > 0 ) return(patternToDisease)
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
