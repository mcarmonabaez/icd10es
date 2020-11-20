library('tidyverse')

catalogo <- readRDS('inst/extdata/inputs/catalogoJunio.RDS')
actas2 <- readRDS('temp/actas/todas.RDS')

auxiliar <- catalogo %>%
  mutate(category = str_sub(clave, 1, 3),
         subcategory = clave,
         disease = cleanString(nombre),
         term = 'Canonical') %>%
  select(category:term) %>%
  arrange(category)

head(auxiliar)

padecimientos <- actas2 %>%
  select(cause) %>%
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
                         lapply(subset$cause, ICDLookUp, useExternal = TRUE, externalCatalog = auxiliar)
                       }, error=function(e){
                         data.frame(category = 'error', subcategory = NA_character_, disease = NA_character_)
                       })
                     })

beepr::beep(2)
saveRDS(resultados, 'temp/actas/todasCatReducido.RDS')
# resultados <- readRDS('temp/actas/todasCatReducido.RDS')

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
  select(-n) %>%
  spread(year, p)

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
