#' Tokenize file containing death certificates
#'
#' @param df A data fram with the information from the death certificates
#'
#' @return A tokenized version of the causes of death.
#' @export
#'
#' @importFrom tidytext unnest_tokens

tokenizeCertificates <- function(df) {

  # casos <- c('no espec', 'severa', 'severo', 'grave', 'aguda')
  # paste0(', ', casos, collapse = '|')
  # str_remove_all(paste0(', ', casos, collapse = '|'), ',')

  df %>%
    mutate(cause = str_replace_all(tolower(cause), ', no espec', ' no espec'),
           cause = str_replace_all(cause, '\\.', ',')) %>%
    unnest_tokens(cause, cause, token = 'regex', pattern = ",") %>%
    group_by(id) %>%
    mutate(order = row_number(),
           cause = cleanString(cause)) %>%
    ungroup()

}

