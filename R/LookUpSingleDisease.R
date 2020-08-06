

ICDLookUp <- function(pattern, nMatches = 1){

  pattern <- CleanString(pattern)

  #Look for particular diseases
  specialCases <- c('neumonia', 'diabetes', 'cancer', 'tumor',
                    'sepsis', 'sindrome')
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

  #Look up exact match in disease catalog
  diseaseToPattern <- str_match(pattern, categories$padecimiento)
  patternToDisease <- str_match(categories$padecimiento, pattern)
  flagMatch <- sum(diseaseToPattern == patternToDisease, na.rm = T)

  if(flagMatch == 1) {
    #devolver subcategoria y clave y si es principal o alternativo
  }

  #Look up exact match in category catalog
  if(flagMatch == 0) {
    #buscar en el catalogo de categorias
    # Hay categoria entonces regresamos el X009, si tiene subcategorias, sino regresar categoria (A09)
  }

}

CleanString <- function(pattern) {
  #Remove noise from string
  pattern <- tolower(pattern)
  pattern <- stringi::stri_trans_general(pattern, "Latin-ASCII")
  pattern <- str_remove_all(pattern, "[^a-z0-9 ]")
  pattern <- gsub(' +',' ', pattern)
  pattern <- str_trim(pattern)

  return(pattern)
}
