library(tidyr)
library(dplyr)
string <- 'A000'

printInfo <- function(string, inclusionTerms = TRUE, exclusionTerms = TRUE, tabular = 'full') {

  if(stringr::str_detect(string, '^[A-Z]{1}[1-9]{2,3}$'))
    stop('Looks like you did\'t enter a valid category or subcategory code. Categories should have one upppercase letter followed by two digits, and subcategories should have one upppercase letter followed by three digits.')

  strLength <- stringr::str_length(string)
  if(!strLength %in% 3:4)
    stop('Looks like you did\'t enter a valid category or subcategory code. Categories should have one upppercase letter followed by two digits, and subcategories should have one upppercase letter followed by three digits.')

  if(strLength == 3) { # categoría
    query <- categories %>% dplyr::filter(categoria == string)

    ### Check if query includes inclusion or exclusion terms
    hasInclusion <- sum(grepl('Inclusion', query$term))
    hasExclusion <- sum(grepl('Exclusion', query$term))
    inclusions <- ''
    exclusions <- ''

    if(hasInclusion) inclusions <- query %>% filter(term == 'Inclusion') %>% pull(titulo_categoria)
    if(hasInclusion) exclusions <- query %>% filter(term == 'Exclusion') %>% pull(titulo_categoria)

    pracma::sprintf(paste('-----------------------------------------------------------------------------',
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
                    filter(query, term == 'Formal')$titulo_categoria,
                    string # Código subcategoría
    )
    return(invisible(query))

    if(tabular == 'simple') return(query)
    else if(tabular == 'full') return(query) # left join con los datos que decía Keo

  } else { # subcategoría
    query <- subcategories %>% dplyr::filter(subcategoria == string)

    ### Check if query includes inclusion or exclusion terms
    hasInclusion <- sum(grepl('Inclusion', query$term))
    hasExclusion <- sum(grepl('Exclusion', query$term))
    inclusions <- ''
    exclusions <- ''

    if(hasInclusion) inclusions <- query %>% filter(term == 'Inclusion') %>% pull(padecimiento)
    if(hasInclusion) exclusions <- query %>% filter(term == 'Exclusion') %>% pull(padecimiento)

    pracma::fprintf(paste('-----------------------------------------------------------------------------',
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
                    filter(query, term == 'Formal')$padecimiento)
    return(invisible(query))

    if(tabular == 'simple') return(query)
    else if(tabular == 'full') return(query) # left join con los datos que decía Keo

  }

}

results <- printInfo('A000')
results

results <- printInfo('A001')
results

results <- printInfo('A011')
results

results <- printInfo('P00')
results

results <- printInfo('P04')
results

results <- printInfo('P0423')


