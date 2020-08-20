library(tidyr)
library(dplyr)
string <- 'A000'

printInfo <- function(string, inclusionTerms = TRUE, exclusionTerms = TRUE, tabular = TRUE) {

  if(stringr::str_detect(string, '^[A-Z]{1}[1-9]{2,3}$'))
    stop('Looks like you did\'t enter a valid category or subcategory code. Categories should have one upppercase letter followed by two digits, and subcategories should have one upppercase letter followed by three digits.')

  strLength <- stringr::str_length(string)
  if(!strLength %in% 3:4)
    stop('Looks like you did\'t enter a valid category or subcategory code. Categories should have one upppercase letter followed by two digits, and subcategories should have one upppercase letter followed by three digits.')

  if(strLength == 3) { # categoría

  } else { # subcategoría
    query <- subcategories %>%
      dplyr::filter(subcategoria == string,
                    principal %in% c(!inclusionTerms, 1))

    if(tabular) return(query)

    hasInclusion <- ifelse(nrow(query) == 1,
                        'No inclusion terms found.',
                        'The following inclusion terms were found:')

    inclusions <- query %>% filter(principal == 0) %>% pull(padecimiento)

    pracma::fprintf(paste('-----------------------------------------------------------------------------',
                          'Cateogry:\t %s \t Nombre de la categoría',
                          'Subcateogry: \t %s \t %s',
                          '-----------------------------------------------------------------------------',
                          hasInclusion,
                          paste0(paste0('\t\t', inclusions), collapse = '\n'),
                          '-----------------------------------------------------------------------------',
                          sep = '\n'),
                    substr(string, 1, 3), # Código categoría
                    # Nombre categoría
                    string, # Código subcategoría
                    filter(query, principal == 1)$padecimiento)
    return(invisible(query))

    if(exclusionTerms) {
      # TODO: Imprimir info sobre términos de exclusión
    }
  }

}

results <- printInfo('A000', tabular = FALSE)
results



