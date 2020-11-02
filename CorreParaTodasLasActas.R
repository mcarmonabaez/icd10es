library('tidyverse')

files <- list.files('temp/actas/', pattern = 'csv')
years <- readr::parse_number(str_remove(files, '_C[0-9]+'))

leer <- function(path, year) {
  read.csv(paste0('temp/actas/', path),
           stringsAsFactors = FALSE) %>%
    select(id = NO, cause = CAUSA.DE.MUERTE) %>%
    add_column(year = year, .before = 2) %>%
    tibble
}

actas <- map2_df(files, years, ~leer(.x, .y)) %>%
  filter(!grepl('NOMBRE', cause, useBytes = T)) %>%
  unite(id, c('id', 'year'), sep = '_')

actas2 <- actas %>%
  tokenizeCertificates() %>%
  filter(cause != '') %>%
  rownames_to_column('folio') %>%
  mutate(folio = as.numeric(folio))

saveRDS(actas2, 'temp/actas/todas.RDS')


# auxiliar <- read.csv('temp/catalogo_covid_revKeo.csv') %>%
#   mutate(category = str_sub(Clave, 1, 3),
#          subcategory = Clave,
#          disease = nombre_aux,
#          term = 'Auxiliar') %>%
#   select(category:term)

# resultados <- lapply(unique(actas3$folio),
#                      function(x) {
#                        if(x %% 100 == 0)
#                          print(x)
#                        subset <- filter(actas3, folio == x)
#                        lapply(subset$cause, ICDLookUp)
#                      })

resultados <- lapply(unique(actas2$folio),
                     function(x) {
                       if(x %% 100 == 0)
                         print(x)
                       subset <- filter(actas2, folio == x)
                       tryCatch({
                         lapply(subset$cause, ICDLookUp)
                         # lapply('hola', printInfo)
                       }, error=function(e){
                         data.frame(category = 'error', subcategory = NA_character_, disease = NA_character_)
                       })
                     })

padecimientos <- actas2 %>% select(cause) %>%
  unique %>%
  arrange(cause) %>%
  rownames_to_column('id') %>%
  mutate(id = as.numeric(id))

resultados <- lapply(unique(padecimientos$id),
                     function(x) {
                       if(x %% 100 == 0)
                         print(x)
                       subset <- filter(padecimientos, id == x)
                       tryCatch({
                         lapply(subset$cause, ICDLookUp)
                       }, error=function(e){
                         data.frame(category = 'error', subcategory = NA_character_, disease = NA_character_)
                       })
                     })

beepr::beep(2)

saveRDS(resultados, 'temp/actas/todasResultados.RDS')

resultados3 <- resultados %>%
  bind_rows(.id = 'id') %>%
  # filter(duplicated(id)) %>%
  mutate(id = as.numeric(id)) %>%
  arrange(id) %>%
  group_by(id) %>%
  mutate(order = row_number()) %>%
  ungroup()

actas2$res <- resultados3$disease

# 1-sum(is.na(actas$res))/nrow(actas)
# actas %>% count(is.na(res))


actas %>%
  group_by(id) %>%
  summarise(numPadecimientos = n(),
            completos = sum(!is.na(res), na.rm = T),
            logrado = ifelse(numPadecimientos == completos, 'completo',
                             ifelse(completos == 0, 'vacio',
                                    'parcial'))) %>%
  ungroup() %>%
  count(logrado) %>%
  mutate(p = n / sum(n))


viejo <- read.csv('temp/tot_orden_2020.csv') %>%
  filter(id_acta <= 300)


conteoViejo <- viejo %>%
  select(id_acta, original, match, sin_match) %>%
  group_by(id_acta) %>%
  summarise(numPadecimientos = n(),
            numHuerfanos = sum(original == 'huerfano'),
            completos = sum(sin_match != '', na.rm = T),
            logrado = ifelse(numPadecimientos == completos, 'completo', 'parcial')) %>%
  ungroup() %>%
  count(logrado, numHuerfanos = numHuerfanos == 0)

conteoViejo %>%
  tibble::add_row(logrado = 'vacio', numHuerfanos = FALSE, n = n_distinct(actas$id) - sum(conteoViejo$n)) %>%
  mutate(p = n / sum(n))

# ejemplos de matches malos: 72, 272
