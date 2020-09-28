#' Print information in ICD-10 associated with a specified entry.
#'
#' @param string A string containing the ICD-10  three or four-digit code from which to print info.
#' @param inclusionTerms A logical that tells whether to print inclusion terms or not
#' @param exclusionTerms A logical that tells whether to print exclusion terms or not
#' @param tabular A string that can take values 'full' or 'simple'.
#'
#' @return A data frame with the information about the matches found for the disease.
#'
#' @export
#' @import stringr
#' @importFrom pracma fprintf

printInfo <- function(string, inclusionTerms = TRUE, exclusionTerms = TRUE, tabular = 'full') {

  if(!str_detect(string, '^[A-Z]{1}[0-9]{2,3}$'))
    stop('a Looks like you did\'t enter a valid category or subcategory code. Categories should have one upppercase letter followed by two digits, and subcategories should have one upppercase letter followed by three digits.')

  strLength <- str_length(string)
  if(!strLength %in% 3:4)
    stop('b Looks like you did\'t enter a valid category or subcategory code. Categories should have one upppercase letter followed by two digits, and subcategories should have one upppercase letter followed by three digits.')

  if(strLength == 3) { # categoría
    query <- categories %>% filter(categoria == string)

    ### Check if query includes inclusion or exclusion terms
    hasInclusion <- sum(grepl('Inclusion', query$term))
    hasExclusion <- sum(grepl('Exclusion', query$term))
    inclusions <- ''
    exclusions <- ''

    if(hasInclusion) inclusions <- query %>% filter(term == 'Inclusion') %>% pull(titulo_categoria)
    if(hasInclusion) exclusions <- query %>% filter(term == 'Exclusion') %>% pull(titulo_categoria)

    fprintf(paste('-----------------------------------------------------------------------------',
                          'Query entered: \t\t %s',
                          'Cateogry:\t\t %s \t %s',
                          # ¿Queremos imprimir la lista de subcategorías?
                          '-----------------------------------------------------------------------------',
                          ifelse(hasInclusion, 'The following inclusion terms were found:', 'No inclusion terms were found.'),
                          paste0(paste0('\t\t', inclusions), collapse = '\n'),
                          '-----------------------------------------------------------------------------',
                          ifelse(hasExclusion, 'The following exclusion terms were found:', 'No exclusion terms were found.'),
                          paste0(paste0('\t\t', exclusions), collapse = '\n'),
                          '-----------------------------------------------------------------------------',
                          sep = '\n'),
                    string,
                    substr(string, 1, 3), # Código categoría
                    filter(query, term == 'Canonical')$titulo_categoria,
                    string # Código subcategoría
    )
    return(invisible(query))

    if(tabular == 'simple') return(query)
    else if(tabular == 'full') return(query) # left join con los datos que decía Keo

  } else { # subcategoría
    query <- subcategories %>% filter(subcategoria == string)

    ### Check if query includes inclusion or exclusion terms
    hasInclusion <- sum(grepl('Inclusion', query$term))
    hasExclusion <- sum(grepl('Exclusion', query$term))
    inclusions <- ''
    exclusions <- ''

    if(hasInclusion) inclusions <- query %>% filter(term == 'Inclusion') %>% pull(padecimiento)
    if(hasInclusion) exclusions <- query %>% filter(term == 'Exclusion') %>% pull(padecimiento)

    fprintf(paste('-----------------------------------------------------------------------------',
                          'Query entered: \t\t %s',
                          'Cateogry:\t %s \t Nombre de la categoría',
                          'Subcateogry: \t %s \t %s',
                          '-----------------------------------------------------------------------------',
                          ifelse(hasInclusion, 'The following inclusion terms were found:', 'No inclusion terms were found.'),
                          paste0(paste0('\t\t', inclusions), collapse = '\n'),
                          '-----------------------------------------------------------------------------',
                          ifelse(hasExclusion, 'The following exclusion terms were found:', 'No exclusion terms were found.'),
                          paste0(paste0('\t\t', exclusions), collapse = '\n'),
                          '-----------------------------------------------------------------------------',
                          sep = '\n'),
                    string,
                    substr(string, 1, 3), # Código categoría
                    # Nombre categoría
                    string, # Código subcategoría
                    filter(query, term == 'Canonical')$padecimiento)
    return(invisible(query))

    if(tabular == 'simple') return(query)
    else if(tabular == 'full') return(query) # left join con los datos que decía Keo

  }

}

