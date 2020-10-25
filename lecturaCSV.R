library('tidyverse')

catJuan <- readxl::read_excel('inst/extdata/cie10_completo JUAN.xlsx', sheet = 2) %>%
  mutate(category = ifelse(category == '', NA, category),
         subcategory = ifelse(subcategory == '', NA, subcategory),
         category = zoo::na.locf(category),
         subcategory = zoo::na.locf(subcategory),
         disease = cleanString(disease))

subcategory <- read.csv('inst/extdata/inputs/subcategory.csv',
                          stringsAsFactors = F, sep = '\t') %>%
  mutate(disease = cleanString(disease)) %>%
  filter(!category %in% unique(catJuan$category))

# subcategories <- bind_rows(subcategories, catJuan) %>% unique() %>% arrange(category, subcategory)

# subcategories <- subcategories %>%
#   mutate(category = ifelse(category == '', NA, category),
#          subcategory = ifelse(subcategory == '', NA, subcategory),
#          category = zoo::na.locf(category),
#          subcategory = zoo::na.locf(subcategory))

diabetes_subcategories <- read.csv('inst/extdata/inputs/diabetes_subcategories.csv',
                                   stringsAsFactors = F, sep = '\t') %>%
  mutate(disease = cleanString(disease))

cancer_subcategories <- read.csv('inst/extdata/inputs/cancer_subcategories.csv',
                                 stringsAsFactors = F, sep = ';') %>%
  mutate(disease = cleanString(disease))

categories <- read.csv('inst/extdata/inputs/categories.csv', stringsAsFactors = F, sep = ';') %>%
  select(category:term) %>%
  mutate(categoryTitle = cleanString(categoryTitle),
         subcategory = category) %>%
  rename(disease = categoryTitle)

stopwords_regex = paste(tm::stopwords('es')[- which(tm::stopwords('es') == 'no')], collapse = '\\b|\\b')

auxiliar <- read.csv('temp/catalogo_covid_revKeo.csv') %>%
  mutate(category = str_sub(Clave, 1, 3),
         subcategory = Clave,
         disease = nombre_aux,
         term = 'Auxiliar') %>%
  select(category:term)

subcategories <- bind_rows(subcategory, categories, auxiliar, catJuan) %>%
  unique() %>% arrange(subcategory)

listos <- subcategories %>%
  filter(term != 'Canonical') %>%
  pull(subcategory) %>%
  unique()

imss <- read.csv('inst/extdata/inputs/IMSS.csv',
                 stringsAsFactors = F, sep = '\t') %>%
  # filter(!subcategory %in% listos) %>%
  mutate(subcategory = str_remove_all(subcategory, 'X'),
         disease = cleanString(disease))

subcategories <- bind_rows(subcategories, imss) %>% unique() %>% arrange(subcategory)

subcategories %>%
  count(subcategory, term) %>%
  spread(term, n, 0) %>%
  filter(Canonical != 1)

subcategories %>%
  mutate(temp = stringr::str_sub(subcategory,1,3) == category) %>%
  filter(!temp)


usethis::use_data(categories, subcategories, diabetes_subcategories, cancer_subcategories, stopwords_regex,
                  internal = TRUE, overwrite = TRUE)


roxygen2::roxygenise()


## tokenizar actas
actas <- read.csv('temp/ejemplo_actas.csv', stringsAsFactors = FALSE, sep = ';')
auxiliar <- read.csv('temp/catalogo_covid_revKeo.csv') %>%
  mutate(category = str_sub(Clave, 1, 3),
         subcategory = Clave,
         disease = nombre_aux,
         term = 'Auxiliar') %>%
  select(category:term)

muestra <- tokenizeCertificates(actas) %>%
  filter(cause != '', !id %in% c(45,283,298), id <= 302)

ICDLookUp('fibrilacion auricular')
ICDLookUp('pancreatitis cronica')
ICDLookUp('cancer hepatico')


resultados <- lapply(unique(muestra$id),
                     function(x) {
                       print(x)
                       subset <- filter(muestra, id == x)
                       lapply(subset$cause, ICDLookUp)
                              # useExternal = TRUE,
                              # externalCatalog = bind_rows(subcategories, auxiliar))
                     })

resultados3 <- resultados %>%
  bind_rows(.id = 'id',) %>%
  filter(!duplicated(id)) %>%
  mutate(id = as.numeric(id)) %>%
  arrange(id) %>%
  group_by(id) %>%
  mutate(order = row_number()) %>%
  ungroup()

muestra$res <- resultados3$disease

1-sum(is.na(muestra$res))/nrow(muestra)
muestra %>% count(is.na(res))

viejo <- read.csv('temp/tot_orden_2020.csv') %>%
  filter(!id_acta %in% c(45,283,298), id_acta <= 302)

1-sum(viejo$sin_match == '')/nrow(viejo)
viejo %>% count(sin_match == '')
