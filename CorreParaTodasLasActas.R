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

# actas <- actas[1:300,]

actas2 <- actas %>%
  tokenizeCertificates() %>%
  filter(cause != '') %>%
  rownames_to_column('folio') %>%
  mutate(folio = as.numeric(folio))

# saveRDS(actas2, 'temp/actas/todas.RDS')


# auxiliar <- read.csv('temp/catalogo_covid_revKeo.csv') %>%
#   mutate(category = str_sub(Clave, 1, 3),
#          subcategory = Clave,
#          disease = nombre_aux,
#          term = 'Auxiliar') %>%
#   select(category:term)

padecimientos <- actas2 %>% select(cause) %>%
  unique %>%
  arrange(cause) %>%
  rownames_to_column('id') %>%
  mutate(id = as.numeric(id))

# resultados <- lapply(unique(padecimientos$id),
#                      function(x) {
#                        if(x %% 100 == 0)
#                          print(x)
#                        subset <- filter(padecimientos, id == x)
#                        tryCatch({
#                          lapply(subset$cause, ICDLookUp)
#                        }, error=function(e){
#                          data.frame(category = 'error', subcategory = NA_character_, disease = NA_character_)
#                        })
#                      })
#
# beepr::beep(2)
#
# saveRDS(resultados, 'temp/actas/todasResultados.RDS')

resultados <- readRDS('temp/actas/todasResultados.RDS')

resultados3 <- resultados %>%
  bind_rows(.id = 'idRun') %>%
  filter(!duplicated(idRun)) %>%
  mutate(idRun = as.numeric(idRun)) %>%
  arrange(idRun) %>%
  group_by(idRun) %>%
  mutate(order = row_number()) %>%
  ungroup() %>%
  select(-idRun)

padecimientos$disease <- resultados3$disease

total <- actas2 %>%
  left_join(select(padecimientos, -id)) %>%
  separate(id, c('num', 'year'), sep = '_', remove = FALSE)

### Todos los años
total %>%
  group_by(id) %>%
  summarise(numPadecimientos = n(),
            completos = sum(!is.na(disease), na.rm = T),
            logrado = ifelse(numPadecimientos == completos, 'completo',
                             ifelse(completos == 0, 'vacio',
                                    'parcial'))) %>%
  ungroup() %>%
  count(logrado) %>%
  mutate(p = n / sum(n))

### Por año
total %>%
  group_by(id, year) %>%
  summarise(numPadecimientos = n(),
            completos = sum(!is.na(disease), na.rm = T),
            logrado = ifelse(numPadecimientos == completos, 'completo',
                             ifelse(completos == 0, 'vacio',
                                    'parcial'))) %>%
  group_by(year) %>%
  count(year, logrado) %>%
  mutate(p = n / sum(n)) %>%
  ungroup() %>%
  select(-p) %>%
  spread(year, n)

total %>%
  group_by(year) %>%
  count(year, is.na(disease)) %>%
  mutate(p = n / sum(n)) %>%
  ungroup() %>%
  select(-n) %>%
  spread(year, p)

actas %>%
  separate(id, c('num', 'year'), sep = '_', remove = FALSE) %>%
  count(year)
  head


# Análisis sobrantes ------------------------------------------------------

### Sólo vacíos
vacios <- total %>%
  group_by(id) %>%
  filter(sum(is.na(disease)) == max(row_number())) %>%
  ungroup()

vacios %>%
  count(cause) %>%
  arrange(-n) %>%
  mutate(p = n/sum(n)) %>% View

vacios$id %>% unique %>% length
actas$id %>% unique %>% length

### Sólo parciales
parciales <- total %>%
  group_by(id) %>%
  filter(sum(is.na(disease)) < max(row_number()),
         sum(is.na(disease)) > 0) %>%
  ungroup()

parciales %>%
  filter(is.na(disease)) %>%
  count(cause) %>%
  arrange(-n) %>%
  mutate(p = n/sum(n))

parciales$id %>% unique %>% length
actas$id %>% unique %>% length

### Juntos
faltantes <- bind_rows(vacios, parciales) %>%
  filter(is.na(disease)) %>%
  count(cause) %>%
  arrange(-n) %>%
  mutate(p = n/sum(n)) %>%
  mutate(cum = cumsum(p))

faltantes %>%
  filter(p >= 0.001) %>%
  pull(p) %>%
  sum()

faltantes %>%
  filter(grepl('coronav|cov', cause)) %>%
  pull(p) %>%
  sum()

faltantes %>%
  filter(p >= 0.001) %>%
  clipr::write_clip()

# Resultados viejos -------------------------------------------------------

files <- list.files('temp/resultadosJunio/', pattern = 'csv')
years <- readr::parse_number(str_remove(files, '_C[0-9]+'))

leer <- function(path, year) {
  read.csv(paste0('temp/resultadosJunio/', path),
           stringsAsFactors = FALSE) %>%
    rename(id = id_acta) %>%
    add_column(year = year, .before = 2) %>%
    tibble
}

viejos <- map2_df(files, years, ~leer(.x, .y)) %>%
  unite(id, c('id', 'year'), sep = '_', remove = FALSE)

viejos %>% head

# viejo <- read.csv('temp/tot_orden_2020.csv') %>%
#   filter(id_acta <= 300)

conteoViejo <- viejos %>%
  select(id, original, match, sin_match) %>%
  group_by(id) %>%
  summarise(numPadecimientos = n(),
            numHuerfanos = sum(original == 'huerfano'),
            completos = sum(sin_match != '', na.rm = T),
            logrado = ifelse(numPadecimientos == completos, 'completo', 'parcial')) %>%
  ungroup() %>%
  count(logrado, numHuerfanos = numHuerfanos == 0) %>%
  tibble::add_row(logrado = 'vacio', numHuerfanos = FALSE, n = n_distinct(actas$id) - sum(conteoViejo$n)) %>%
  mutate(p = n / sum(n))

conteoViejo

conteoViejo2 <- viejos %>%
  select(id, year, original, match, sin_match) %>%
  group_by(id, year) %>%
  summarise(numPadecimientos = n(),
            numHuerfanos = sum(original == 'huerfano'),
            completos = sum(sin_match != '', na.rm = T),
            logrado = ifelse(numPadecimientos == completos, 'completo', 'parcial')) %>%
  ungroup() %>%
  count(year, logrado, numHuerfanos = numHuerfanos == 0) %>%
  # group_by(year) %>%
  # mutate(n = n / sum(n)) %>%
  spread(year, n)

conteoViejo2 %>% clipr::write_clip()

viejos %>% count(year, id) %>% select(-n) %>% count(year)

viejos %>% count(year)



viejos %>% count(id) %>% pull(n) %>% sum()
viejos %>% count(id) %>% pull(n) %>% sum()

# ejemplos de matches malos: 2 (2017), 272 (2020)
viejos %>% filter(id == '2_2017')
total %>% filter(id == '2_2017')




