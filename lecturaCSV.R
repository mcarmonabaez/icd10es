library(tidyverse)

subcategories <- read.csv('inst/extdata/inputs/subcategory.csv',
                          stringsAsFactors = F, sep = '\t') %>%
  mutate(disease = cleanString(disease))
colSums(is.na(subcategories))

# subcategories <- subcategories %>%
#   mutate(category = ifelse(category == '', NA, category),
#          subcategory = ifelse(subcategory == '', NA, subcategory),
#          category = zoo::na.locf(category),
#          subcategory = zoo::na.locf(subcategory))

diabetes_subcategories <- read.csv('inst/extdata/inputs/diabetes_subcategories.csv',
                                   stringsAsFactors = F, sep = ';') %>%
  mutate(disease = cleanString(disease))

cancer_subcategories <- read.csv('inst/extdata/inputs/cancer_subcategories.csv',
                                 stringsAsFactors = F, sep = ';') %>%
  mutate(disease = cleanString(disease))

categories <- read.csv('inst/extdata/inputs/categories.csv', stringsAsFactors = F, sep = ';') %>%
  select(category:term) %>%
  mutate(categoryTitle = cleanString(categoryTitle))

stopwords_regex = paste(tm::stopwords('es')[- which(tm::stopwords('es') == 'no')], collapse = '\\b|\\b')

usethis::use_data(categories, subcategories, diabetes_subcategories, cancer_subcategories, stopwords_regex,
                  internal = TRUE, overwrite = TRUE)


roxygen2::roxygenise()


## tokenizar actas
library(tidyverse)
actas <- read.csv('temp/ejemplo_actas.csv', stringsAsFactors = FALSE, sep = ';')
auxiliar <- read.csv('temp/catalogo_covid_revKeo.csv') %>%
  mutate(category = str_sub(Clave, 1, 3),
         subcategory = Clave,
         disease = nombre_aux,
         term = 'Canonical') %>%
  select(category:term)

muestra <- tokenizeCertificates(actas[1:10,])

ICDLookUp('encefalopatia hepatica',
          useExternal = TRUE,
          externalCatalog = bind_rows(subcategories, auxiliar))


resultados <- lapply(unique(muestra$id),
                     function(x) {
                       print(x)
                       subset <- filter(muestra, id == x)
                       lapply(subset$cause, ICDLookUp,
                              useExternal = TRUE,
                              externalCatalog = bind_rows(subcategories, auxiliar))
                     })

resultados3 <- resultados %>%
  bind_rows(.id = 'id',) %>%
  mutate(id = as.numeric(id)) %>%
  arrange(id) %>%
  group_by(id) %>%
  mutate(order = row_number()) %>%
  ungroup()

muestra$res <- resultados2$disease


muestra %>%
  bind_cols(resultados2$disease) %>% View
  # unnest(res) %>%
  print(n=100)

