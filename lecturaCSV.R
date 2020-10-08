library(tidyverse)

subcategories <- read.csv('inst/extdata/inputs/subcategory.csv',
                          stringsAsFactors = F, sep = ';') %>%
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
