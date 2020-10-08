library(tidyverse)
actas <- read.csv('temp/ejemplo_actas.csv', stringsAsFactors = FALSE, sep = ';')
# df <- actas
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

muestra <- tokenizeCertificates(actas[1:10,])

resultados <- lapply(unique(muestra$id),
                     function(x) {
                       print(x)
                       subset <- filter(muestra, id == x)
                       lapply(subset$cause, ICDLookUp)
                     })

resultados2 <- resultados %>%
  bind_rows(.id = 'id') %>%
  mutate(id = as.numeric(id)) %>%
  arrange(id) %>%
  group_by(id) %>%
  mutate(order = row_number()) %>%
  ungroup()

muestra$res <- resultados2$disease


muestra %>%
  # unnest(res) %>%
  print(n=100)
