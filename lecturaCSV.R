library('tidyverse')

catJuan <- readxl::read_excel('inst/extdata/cie10_completo JUAN.xlsx', sheet = 2) %>%
  mutate(category = ifelse(category == '', NA, category),
         subcategory = ifelse(subcategory == '', NA, subcategory),
         category = zoo::na.locf(category),
         subcategory = zoo::na.locf(subcategory),
         disease = cleanString(disease)) %>%
  filter(!grepl('uso emergente', disease))

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

covid_subcategories <- read.csv('inst/extdata/inputs/covid_subcategories.csv',
                                   stringsAsFactors = F, sep = '\t') %>%
  mutate(disease = cleanString(disease))

categories <- read.csv('inst/extdata/inputs/categories.csv', stringsAsFactors = F, sep = ';') %>%
  select(category:term) %>%
  mutate(categoryTitle = cleanString(categoryTitle),
         subcategory = category) %>%
  rename(disease = categoryTitle)

stopwords_regex = paste(tm::stopwords('es')[- which(tm::stopwords('es') == 'no')], collapse = '\\b|\\b')

auxiliar <- read.csv('inst/extdata/inputs/catalogo_covid_revKeo.csv') %>%
  mutate(category = str_sub(Clave, 1, 3),
         subcategory = Clave,
         disease = nombre_aux,
         term = 'Inclusion',
         disease = cleanString(disease)) %>%
  select(category:term) %>%
  bind_rows(covid_subcategories)

subcategories <- bind_rows(subcategory, categories, auxiliar, catJuan) %>%
  unique() %>% arrange(subcategory) %>%

listos <- subcategories %>%
  filter(term == 'Canonical') %>%
  pull(subcategory) %>%
  unique()

length(listos)
listos[grepl('K72', listos)]

imss <- read.csv('inst/extdata/inputs/IMSS.csv',
                 stringsAsFactors = F, sep = '\t') %>%
  mutate(subcategory = str_remove_all(subcategory, 'X$'),
         disease = cleanString(disease)) %>%
  filter(!subcategory %in% listos)

imss

subcategories <- bind_rows(subcategories, imss) %>%
  unique() %>%
  arrange(subcategory) %>%
  mutate(subcategory = str_remove_all(subcategory, 'X$')) %>%
  unique()

subcategories %>%
  count(subcategory, term) %>%
  spread(term, n, fill = 0) %>%
  filter(Canonical != 1)

subcategories %>%
  mutate(temp = stringr::str_sub(subcategory,1,3) == category) %>%
  filter(!temp)


usethis::use_data(categories, subcategories, diabetes_subcategories, cancer_subcategories, stopwords_regex,
                  internal = TRUE, overwrite = TRUE)


roxygen2::roxygenise()


## tokenizar actas

