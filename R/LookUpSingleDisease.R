#' Look up disease in ICD10 catalog
#'
#' @param pattern A string of the name of the disease to look up.
#' @param nMatches A number indicating the number of matches to return in case of more than one coincidence.
#' @param jwBound A real number between 0 and 1 that determines de lower bound for Jaro-Winkler distance.
#' @param catalog A data frame containing the catalog where the search will be made.
#'
#' @return A data frame with the information about the matches found for the disease.
#'
#' @import stringr dplyr tidyr
#' @importFrom stringdist stringsim

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
    dfDisease <- data.frame(match = unique(patternToDisease[!is.na(patternToDisease)]),
                            disease = catalog$padecimiento,
                            subcategory = catalog$subcategoria,
                            term = catalog$term,
                            stringsAsFactors = FALSE)[!is.na(patternToDisease), ]
    if(nrow(dfDisease) == 1) return(patternToDisease) ## regresar la subcategoria
    if(nrow(dfDisease) > 1 ) return(residualMatch(pattern, dfDisease))
  }

  if(residualDisease + residualPattern == 0) {
    jwMatch <- data.frame(padecimiento = catalog$padecimiento,
                          metric = stringsim(catalog$padecimiento,
                                     pattern, method = 'jw', p = 0)) %>%
      filter(metric >= 0.9) %>%
      arrange(desc(metric))
    if(nrow(jwMatch) > 0) {
      return(print(jwMatch))
    } else {
      return(NULL)
    }
  }
}

#' Look up unspecified and SAI entries in catalog.
#'
#' @param pattern A string of the name of the disease to look up.
#' @param dfDisease A data frame containing all the matched diseases.
#' @param jwBound A real number between 0 and 1 that determines de lower bound for Jaro-Winkler distance.
#'
#' @return A data frame with the information about the matches found for the disease.
#'
#' @importFrom stringdist stringsim
#'
residualMatch <- function(pattern, dfDisease, jwBound = 0.9) {
  #Check if there's more than one category
  nCat <- sort(table(substr(dfDisease$subcategory[which(dfDisease$term == 'Canonical')], 1, 3)))

  if(length(nCat) == 1) {
    indNotSpecified <- which(substr(dfDisease$subcategory, 4, 4) == '9')
    if(length(indNotSpecified) == 1) {
      return(printInfo(dfDisease$subcategory[indNotSpecified]))
    } else {
      indNotSpecified <- which(!is.na(str_match(dfDisease$disease, 'no especificad')))
      return(printInfo(dfDisease$subcategory[indNotSpecified]))
    }
  } else {
    dfDisease$probs <- stringsim(dfDisease$disease, paste0(pattern, ' no especificad'),
                                   method = 'jw', p = 0)

    dfMatches <- dfDisease[dfDisease$probs > jwBound, ]
    if(nrow(dfMatches) > 0) {
      print(dfMatches)
    } else {
      dfDisease$probs <- stringsim(dfDisease$disease, paste0(pattern, ' sai'),
                                               method = 'jw', p = 0)
      dfMatches <- dfDisease[dfDisease$probs > jwBound, ]
      if(nrow(dfMatches) > 0) {
        print(dfMatches)
      } else {
        print('pues bai')
      }
    }


  }

}
