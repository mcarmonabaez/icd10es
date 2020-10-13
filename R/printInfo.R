#' Print information in ICD-10 associated with a specified entry.
#'
#' @param string A string containing the ICD-10  three or four-digit code from which to print info.
#' @param inclusionTerms A logical that tells whether to print inclusion terms or not.
#' @param exclusionTerms A logical that tells whether to print exclusion terms or not.
#' @param tabular A string that can take values 'single', 'simple', or full'.
#'
#' @return A data frame with the information about the matches found for the disease.
#'
#' @export
#' @import stringr
#' @importFrom pracma fprintf

printInfo <- function(string, inclusionTerms = TRUE, exclusionTerms = TRUE, tabular = 'single') {

  # print(string)

  if(is.na(string))
    return(data.frame(category = NA_character_, subcategory = NA_character_, disease = NA_character_))

  originalString <- string
  string <- str_remove(str_trim(string), '\\.')

  if(!str_detect(string, '^[A-Z]{1}[0-9]{2,3}$'))
    stop('Looks like you did\'t enter a valid category or subcategory code. Categories should have one upppercase letter followed by two digits, and subcategories should have one upppercase letter followed by three digits.')

  strLength <- str_length(string)
  if(!strLength %in% 3:4)
    stop('Looks like you did\'t enter a valid category or subcategory code. Categories should have one upppercase letter followed by two digits, and subcategories should have one upppercase letter followed by three digits.')

  if(strLength == 3) { # categoría
    query <- subcategories %>% filter(category == string & subcategory == string)
    flagQuery <- isTRUE(nrow(query) == 0)
    if(flagQuery){
      query <- data.frame(category = NA_character_,
                          subcategory = NA_character_, disease = NA_character_)
      warning('The query you entered was not found in the catalog')
      return(invisible(query))
    }

    if(tabular == 'single') {

      query <- query %>%
        filter(term == 'Canonical') %>%
        mutate(subcategory = NA) %>%
        select(category, subcategory, disease)

      return(query)
    }

    if(tabular == 'simple') return(query)

    else if(tabular == 'full') {

        ### Check if query includes inclusion or exclusion terms
        hasInclusion <- sum(grepl('Inclusion', query$term))
        hasExclusion <- sum(grepl('Exclusion', query$term))
        inclusions <- ''
        exclusions <- ''

        if(hasInclusion) inclusions <- query %>% filter(term == 'Inclusion') %>% pull(disease)
        if(hasInclusion) exclusions <- query %>% filter(term == 'Exclusion') %>% pull(disease)

        fprintf(paste('-----------------------------------------------------------------------------',
                      'Query entered: \t\t %s',
                      'Cateogry:\t\t %s \t %s',
                      # ¿Queremos imprimir la lista de subcategorías?
                      '-----------------------------------------------------------------------------',
                      ifelse(hasInclusion, 'The following inclusion terms were found:', 'No inclusion terms were found.'),
                      paste0(paste0('\t\t', inclusions), collapse = '\n'),
                      '-----------------------------------------------------------------------------',
                      # ifelse(hasExclusion, 'The following exclusion terms were found:', 'No exclusion terms were found.'),
                      # paste0(paste0('\t\t', exclusions), collapse = '\n'),
                      # '-----------------------------------------------------------------------------',
                      sep = '\n'),
                originalString,
                substr(string, 1, 3), # Código categoría
                filter(query, term == 'Canonical')$disease,
                string # Código subcategoría
        )


      return(invisible(query))
    } # left join con los datos que decía Keo

  } else { # subcategoría
    query <- subcategories %>% filter(subcategory == string)
    flagQuery <- isTRUE(nrow(query) == 0)
    if(flagQuery){
      query <- data.frame(category = NA_character_,
                          subcategory = NA_character_, disease = NA_character_)
      warning('The query you entered was not found in the catalog')
      return(invisible(query))
    }

    queryCategory <- subcategories %>%
      filter(category == str_sub(string, 1, 3) & subcategory == str_sub(string, 1, 3)) %>%
      filter(term == 'Canonical') %>% pull(disease)

    if(tabular == 'single') {
      if(nrow(query) == 0)
        query <- data.frame(category = NA_character_, subcategory = NA_character_, disease = NA_character_)
      return(query %>% filter(term == 'Canonical') %>% select(-term))
    }

    if(tabular == 'simple') return(query)
    else if(tabular == 'full') {
      ### Check if query includes inclusion or exclusion terms
      hasInclusion <- sum(grepl('Inclusion', query$term))
      hasExclusion <- sum(grepl('Exclusion', query$term))
      inclusions <- ''
      exclusions <- ''

      if(hasInclusion) inclusions <- query %>% filter(term == 'Inclusion') %>% pull(disease)
      if(hasInclusion) exclusions <- query %>% filter(term == 'Exclusion') %>% pull(disease)

      fprintf(paste('-----------------------------------------------------------------------------',
                    'Query entered: \t\t %s',
                    'Cateogry:\t %s \t %s',
                    'Subcateogry: \t %s \t %s',
                    '-----------------------------------------------------------------------------',
                    ifelse(hasInclusion, 'The following inclusion terms were found:', 'No inclusion terms were found.'),
                    paste0(paste0('\t\t', inclusions), collapse = '\n'),
                    '-----------------------------------------------------------------------------',
                    # ifelse(hasExclusion, 'The following exclusion terms were found:', 'No exclusion terms were found.'),
                    # paste0(paste0('\t\t', exclusions), collapse = '\n'),
                    # '-----------------------------------------------------------------------------',
                    sep = '\n'),
              originalString,
              substr(string, 1, 3), # Código categoría
              queryCategory,
              paste0(str_sub(string, 1, 3), '.', str_sub(string, 4, 4)), # Código subcategoría
              filter(query, term == 'Canonical')$disease)
      return(invisible(query)) # left join con los datos que decía Keo
    }

  }

}

