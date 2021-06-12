## ---- echo = FALSE, message = FALSE-------------------------------------------
knitr::opts_chunk$set(collapse = T, comment = "#>")
options(tibble.print_min = 4, tibble.print_max = 4)
library('magrittr')

## -----------------------------------------------------------------------------
library(icd10es)

printInfo('S72.1', tabular = 'single')

printInfo('S72.1', tabular = 'simple')

printInfo('S72.1', tabular = 'full')


## -----------------------------------------------------------------------------
ICDLookUp('cancer de colon', tabular = 'simple')


## -----------------------------------------------------------------------------
ICDLookUp('sindrome dandie-waker', jwBound = 0.9, tabular = 'simple')

ICDLookUp('sindrome dandie-waker', jwBound = 0.8, tabular = 'simple')

## -----------------------------------------------------------------------------
auxCatalog <- read.csv('https://raw.githubusercontent.com/mcarmonabaez/icd10es/master/inst/extdata/inputs/diabetes_subcategories.csv',
                       sep = '\t')
ICDLookUp('Diabetes tipo i con coma', tabular = 'simple',
          useExternal = TRUE, externalCatalog = auxCatalog)


## -----------------------------------------------------------------------------
exampleCerificates <-
  tibble::tribble(~id, ~cause,
                  1, 'HEMORRAGIA SUBARACNOIDEA. HIPERTENSION ARTERIAL SISTEMICA. DISLIPIDEMIA.',
                  2, 'INFARTO CEREBRAL, HIPERTENSION ARTERIAL SISTEMICA, TRIGLICERIDEMIA.',
                  3, 'HERIDA PRODUCIDA POR PROYECTIL DE ARMA DE FUEGO PENETRANTE DE TORAX.',
                  4, 'CHOQUE HIPOVOLEMICO, DIARREA CRONICA, INFECCION POR VIRUS DE INMUNODEFICIENCIA HUMANA.',
                  5, 'EVENTO VASCULAR CEREBRAL, ENFERMEDAD RENAL TERMINAL, DIABETES MELLITUS TIPO 2.',
                  6, 'ANEURISMA CEREBRAL, ENCEFALOPATIA HEPATICA.',
                  7, 'INFARTO AGUDO AL MIOCARDIO, CARDIOPATIA HIPERTENSIVA, HIPERTENSION ARTERIAL SISTEMICA',
                  8, 'MENINGIOMA, HIPERTENSION ARTERIAL SISTEMICA.',
                  9, 'ENCEFALOPATIA HEPATICA, CIRROSIS HEPATICA, ALCOHOLISMO CRONICO',
                  10, 'INFARTO AGUDO AL MIOCARDIO, DIABETES MELLITUS TIPO II.'
  )

exampleCerificates

## -----------------------------------------------------------------------------
tokenizedCerificates <- tokenizeCertificates(exampleCerificates)
print(tokenizedCerificates, n = Inf)


## ----message=FALSE, warning=FALSE, results='hide'-----------------------------
results <- lapply(unique(tokenizedCerificates$id),
                     function(x) {
                       print(x)
                       subset <- dplyr::filter(tokenizedCerificates, id == x)
                       lapply(subset$cause, ICDLookUp)
                     }) %>%
  dplyr::bind_rows(.id = 'id',) %>%
  dplyr::mutate(id = as.numeric(id)) %>%
  dplyr::arrange(id) %>%
  dplyr::group_by(id) %>%
  dplyr::mutate(order = dplyr::row_number()) %>%
  dplyr::ungroup() 

## -----------------------------------------------------------------------------
tokenizedCerificates$result <- results$disease
print(tokenizedCerificates, n = Inf)

