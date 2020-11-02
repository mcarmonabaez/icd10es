#' Look up disease in ICD10 catalog
#'
#' @param pattern A string of the name of the disease to look up.
#' @param jwBound A real number between 0 and 1 that determines de lower bound for Jaro-Winkler distance.
#' @param tabular A string that can take values 'single', 'simple', or full'.
#' @param catalog A data frame containing the catalog where the search will be made.
#' @param searchVar A string containing the variable within the catalog where the search will be made.
#'
#' @return A data frame with the information about the matches found for the disease.
#'
#' @import stringr dplyr tidyr
#' @importFrom stringdist stringsim
#' @importFrom rlang quo_expr
#' @importFrom rlang !!

catalogLookUp <- function(pattern, jwBound = 0.9,
                          catalog, searchVar = 'disease') {

  if(!searchVar %in% names(catalog)) {
    stop('The variable name you entered does not exist within the catalog.')
  }

  if(searchVar != 'disease') {
    searchVar <- quo_expr(searchVar)
    catalog <- catalog %>%
      rename(disease = !!searchVar)
  }

  #Look up exact match in disease catalog
  diseaseToPattern <- suppressWarnings(str_match(pattern, catalog$disease))
  patternToDisease <- str_match(catalog$disease, pattern)
  flagMatch <- sum(diseaseToPattern == patternToDisease, na.rm = T)

  if(flagMatch == 1) {

    indCoincidence <- catalog[!is.na(patternToDisease),]

    if(nrow(indCoincidence) == 1)
      return(checkUnspecified(pattern, indCoincidence$subcategory, catalog))
    else {
      identical <- indCoincidence %>%
        filter(disease == pattern)
      if(nrow(identical) == 1)
        return(checkUnspecified(pattern, identical$subcategory, catalog))
      else
        flagMatch <- 0
    }


  }

  #Look up exact match in category catalog

  #number of coincidences where the pattern was longer than the disease
  residualPattern <- isTRUE(sum(!is.na(diseaseToPattern), na.rm = T) > 0)
  #number of coincidences where the disease was longer than the pattern
  residualDisease <- isTRUE(sum(!is.na(patternToDisease), na.rm = T) > 0)


  if(residualPattern == TRUE) {
    dfDisease <- data.frame(match = diseaseToPattern,
                            disease = catalog$disease,
                            subcategory = catalog$subcategory,
                            stringsAsFactors = FALSE)[!is.na(diseaseToPattern), ]
    if(nrow(dfDisease) == 1) return(dfDisease$subcategory) ## regresar la subcategoria 'no especificado'
    if(nrow(dfDisease) > 1 ) return(residualMatch(pattern, dfDisease, jwBound, tabular = tabular)) ## revisar si es una sola categoria o mas de una
  }

  if(residualDisease == TRUE) {
    dfDisease <- data.frame(match = unique(patternToDisease[!is.na(patternToDisease)]),
                            disease = catalog$disease,
                            subcategory = catalog$subcategory,
                            term = catalog$term,
                            stringsAsFactors = FALSE)[!is.na(patternToDisease), ]

    if(length(unique(dfDisease$subcategory)) == 1) return(unique(dfDisease$subcategory)) ## regresar la subcategoria
    if(length(unique(dfDisease$subcategory)) > 1) return(residualMatch(pattern, dfDisease, jwBound, tabular = tabular))
  }

  if(residualDisease + residualPattern == 0) {
    jwMatch <- catalog %>%
      mutate(metric = stringsim(catalog$disease,
                                pattern, method = 'jw', p = 0)) %>%
      filter(metric >= jwBound) %>%
      arrange(desc(metric))

    if(nrow(jwMatch) > 0) {
      return(jwMatch[1,]$subcategory)
    } else {
      return(NA_character_)
    }

  }
}

#' Look up unspecified and SAI entries in catalog.
#'
#' @param pattern A string of the name of the disease to look up.
#' @param dfDisease A data frame containing all the matched diseases.
#' @param jwBound A real number between 0 and 1 that determines de lower bound for Jaro-Winkler distance.
#' @param tabular A string that can take values 'single', 'simple', or full'.
#'
#' @return A data frame with the information about the matches found for the disease.
#'
#' @importFrom stringdist stringsim
#'
residualMatch <- function(pattern, dfDisease, jwBound, tabular) {
  #Check if there's more than one category
  nCat <- sort(table(substr(dfDisease$subcategory[which(dfDisease$term == 'Canonical')], 1, 3)))

  if(length(nCat) == 1) {
    indNotSpecified <- which(substr(dfDisease$subcategory, 4, 4) == '9')
    if(length(indNotSpecified) >= 1) {
      return(dfDisease$subcategory[indNotSpecified[1]])
    } else {
      indNotSpecified <- which(!is.na(str_match(dfDisease$disease, 'no especificad')))
      if(length(indNotSpecified) > 0)
        return(dfDisease$subcategory[indNotSpecified])
      else
        return(names(nCat))
    }
  } else {
    dfDisease$metric <- stringsim(dfDisease$disease, paste0(pattern, ' sai'),
                                  method = 'jw', p = 0)

    jwMatch <- dfDisease[dfDisease$metric > jwBound, ] %>%
      arrange(desc(metric))

    if(nrow(jwMatch) > 0) {
      return(jwMatch[1,]$subcategory)
    } else {

      dfDisease$metric <- stringsim(dfDisease$disease, paste0(pattern, ' no especific'),
                                    method = 'jw', p = 0)

      jwMatch <- dfDisease[dfDisease$metric > jwBound, ] %>%
        arrange(desc(metric))

      if(nrow(jwMatch) > 0) {
        return(jwMatch[1,]$subcategory)
      } else {
        return(NA_character_)
      }
    }

  }

}


#' Check category coincidence
#'
#' @param pattern A string of the name of the disease to look up.
#' @param cat A string indicating the category
#' @param catalog A data frame containing the catalog where the search will be made.
#'
#' @return A string with the category or subcategory to print
#'
#' @importFrom stringdist stringsim
#'
checkUnspecified <- function(pattern, cat, catalog) {

  subCatalog <-  catalog %>%
    filter(category == cat)

  if(sum(subCatalog$category == subCatalog$subcategory) == nrow(subCatalog))
    return(cat)

  vecUnspecified <- paste0(pattern, c(' sin especificacion', ' sai',
                                      ' sin otra especificacion', ' no especificad'), collapse = '|')
  subCatalog <- subCatalog %>%
    filter(str_detect(disease, vecUnspecified))

  subcat <- unique(subCatalog$subcategory)
  if(length(subcat) == 1) {
    return(subcat)
  } else {
    return(cat)
  }

}
