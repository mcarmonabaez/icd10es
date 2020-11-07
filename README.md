
<!-- README.md is generated from README.Rmd. Please edit that file -->

# icd10es - A user-friendly R package for disease clasification in Spanish 🇲🇽

-----

## Table of Contents

  - [Package description](#description)
  - [Installing icd10es](#installing)
  - [Features at a glance](#features-at-a-glance)
      - [Printing information of a CIE-10 entry](#printing-info)
      - [Looking up a string in the catalog](#icdlookup)
      - [Using an external catalog](#external)
      - [Looking up entries within death
        certificates](#death-certificates)
  - [License](#license)
  - [Credits](#credits)
  - [Thanks](#thanks)

## Package description 😷

`icd10es` is an R package created for Spanish-speaking Bioinformatics
specialists 👩‍⚕️ who have to deal with classifying written descriptions
of diseases, symptoms, and injuries, among other health-related issues,
in the 10th edition of the International Statistical Classification of
Diseases and Related Health Problems (ICD-10 for short), referred to as
CIE-10 in Spanish. ⚕️

## Installing icd10es

``` r
devtools::install_github("mcarmonabaez/icd10es")
```

*Congratulations\!* Now you can use this package\! 🎉

## Features at a glance

### Printing information of a CIE-10 entry

Let’s start with a simple task: say you wish to know what the entry
‘A00.0’ in the catalog contains. The function `printInfo` can help
with that. Changing the value of the parameter `tabular` you can decide
whether you want to

  - get only the canonical term in table form,

  - get the canonical and all inclusion terms (if they exist) also in
    table form,

  - print in all associated information in the console for quick
    inquiries.

<!-- end list -->

``` r
library(icd10es)
printInfo('S72.1', tabular = 'single')
#>   category subcategory                   disease
#> 1      S72        S721 fractura pertrocanteriana
printInfo('S72.1', tabular = 'simple')
#>   category subcategory                     disease      term
#> 1      S72        S721   fractura pertrocanteriana Canonical
#> 2      S72        S721 fractura intertrocanteriana Inclusion
#> 3      S72        S721      fractura trocanteriana Inclusion
printInfo('S72.1', tabular = 'full')
#> -----------------------------------------------------------------------------
#> Query entered:        S72.1
#> Cateogry:     S72     fractura del femur
#> Subcateogry:      S72.1   fractura pertrocanteriana
#> -----------------------------------------------------------------------------
#> The following inclusion terms were found:
#>      fractura intertrocanteriana
#>      fractura trocanteriana
#> -----------------------------------------------------------------------------
```

### Looking up a string in the catalog 🔎

The main function of `icd10es` consists in entering a string which is
expected to match some entry in the CIE-10 and finding said entry, all
via the `ICDLookUp` function. The string does not have to be identical
to the entry: herein lies the usefulness of the package.

The function first tries to find an **exact** match in the catalog, but
often it occurs that the string either has a typo of some kind
(e.g. writing ‘pnuemonia’ instead of ‘pneumonia) or uses a more
colloquial way of referring to the disease or symptom and is not its
’full name’. When this happens, the function tries fuzzy matching
using the Jaro-Winkler similarity metric.

For example, in the CIE-10, all cancers are referred to in a more formal
way, such as ‘tumor maligno del colon’ instead of ‘cancer de colon’ (in
English: ‘malignant neoplasm of colon’ instead of ‘colon cancer’).
`ICDLookUp` would give the following output:

``` r
ICDLookUp('cancer de colon', tabular = 'simple')
#>   category subcategory                                       disease      term
#> 1      C18        C189 tumor maligno del colon parte no especificada Canonical
#> 2      C18        C189        tumor maligno del intestino grueso sai Inclusion
```

Note how the `tabular` parameter is inherited to `printInfo`.

When doing fuzzy matching, one can be more or less strict. This is
reflected in the `jwBound` parameter of `ICDLookUp`: the Jaro-Winkler
similarity goes from 0 (no similarity) to 1 (exact match), and the
default value of `jwBound` is 0.9. That is, only entries with a
similarity to the entered string equal or higher than 0.9 will be
considered. But if one finds that the function didn’t find a result, one
can try lowering the bound:

``` r
ICDLookUp('sindrome dandie-waker', jwBound = 0.9, tabular = 'simple')
#>   category subcategory disease
#> 1     <NA>        <NA>    <NA>
ICDLookUp('sindrome dandie-waker', jwBound = 0.8, tabular = 'simple')
#>   category subcategory                                          disease
#> 1      Q03        Q031 atresia de los agujeros de magendie y de luschka
#> 2      Q03        Q031                          sindrome de dandywalker
#>        term
#> 1 Canonical
#> 2 Inclusion
```

### Using an external catalog

It can happen that the user wants to look up strings in a different,
specialized catalog. This could be for example when using an auxiliary
catalog which has alternative names of some diseases due to regional
variations (like when a country or a country’s province historically
calls a disease in a special way).

This can be done by making the `ICDLookUp` parameter `useExternal =
TRUE`, and by giving a `dataframe` to `externalCatalog`:

``` r
auxCatalog <- read.delim('https://raw.githubusercontent.com/mcarmonabaez/icd10es/master/inst/extdata/inputs/diabetes_subcategories.csv')
ICDLookUp('Diabetes tipo i con coma', tabular = 'simple',
          useExternal = TRUE, externalCatalog = auxCatalog)
#>   category subcategory
#> 1      E10        E100
#> 2      E10        E100
#> 3      E10        E100
#> 4      E10        E100
#> 5      E10        E100
#> 6      E10        E100
#>                                                                           disease
#> 1                                  diabetes mellitus insulinodependiente con coma
#> 2                        diabetes mellitus insulinodependiente con coma diabetico
#> 3 diabetes mellitus insulinodependiente con coma diabetico con o sin cetoacidosis
#> 4           diabetes mellitus insulinodependiente con coma diabetico hiperosmolar
#> 5          diabetes mellitus insulinodependiente con coma diabetico hipoglicemico
#> 6     diabetes mellitus insulinodependiente con coma diabetico hiperglicemico sai
#>        term
#> 1 Canonical
#> 2 Inclusion
#> 3 Inclusion
#> 4 Inclusion
#> 5 Inclusion
#> 6 Inclusion
```

### Looking up entries within death certificates 🧪

It is very common to be in possession of longer texts that describe a
series of diseases and symptoms which could be matched to the CIE-10.
Some examples include death certificates or medical records. There, a
physician may list some or all comorbidities a person presents when
having a medical checkup or when passing away. One may then wish to
match all listed health-related problems with the CIE-10.

``` r
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
#> # A tibble: 10 x 2
#>       id cause                                                                  
#>    <dbl> <chr>                                                                  
#>  1     1 HEMORRAGIA SUBARACNOIDEA. HIPERTENSION ARTERIAL SISTEMICA. DISLIPIDEMI…
#>  2     2 INFARTO CEREBRAL, HIPERTENSION ARTERIAL SISTEMICA, TRIGLICERIDEMIA.    
#>  3     3 HERIDA PRODUCIDA POR PROYECTIL DE ARMA DE FUEGO PENETRANTE DE TORAX.   
#>  4     4 CHOQUE HIPOVOLEMICO, DIARREA CRONICA, INFECCION POR VIRUS DE INMUNODEF…
#>  5     5 EVENTO VASCULAR CEREBRAL, ENFERMEDAD RENAL TERMINAL, DIABETES MELLITUS…
#>  6     6 ANEURISMA CEREBRAL, ENCEFALOPATIA HEPATICA.                            
#>  7     7 INFARTO AGUDO AL MIOCARDIO, CARDIOPATIA HIPERTENSIVA, HIPERTENSION ART…
#>  8     8 MENINGIOMA, HIPERTENSION ARTERIAL SISTEMICA.                           
#>  9     9 ENCEFALOPATIA HEPATICA, CIRROSIS HEPATICA, ALCOHOLISMO CRONICO         
#> 10    10 INFARTO AGUDO AL MIOCARDIO, DIABETES MELLITUS TIPO II.
```

First, one would have to *tokenize* each entry in the certificate,
creating a long `dataframe` in the following way using
`tokenizeCertificates`:

``` r
tokenizedCerificates <- tokenizeCertificates(exampleCerificates)
print(tokenizedCerificates, n = Inf)
#> # A tibble: 25 x 3
#>       id cause                                                             order
#>    <dbl> <chr>                                                             <int>
#>  1     1 hemorragia subaracnoidea                                              1
#>  2     1 hipertension arterial sistemica                                       2
#>  3     1 dislipidemia                                                          3
#>  4     2 infarto cerebral                                                      1
#>  5     2 hipertension arterial sistemica                                       2
#>  6     2 trigliceridemia                                                       3
#>  7     3 herida producida por proyectil de arma de fuego penetrante de to…     1
#>  8     4 choque hipovolemico                                                   1
#>  9     4 diarrea cronica                                                       2
#> 10     4 infeccion por virus de inmunodeficiencia humana                       3
#> 11     5 evento vascular cerebral                                              1
#> 12     5 enfermedad renal terminal                                             2
#> 13     5 diabetes mellitus tipo 2                                              3
#> 14     6 aneurisma cerebral                                                    1
#> 15     6 encefalopatia hepatica                                                2
#> 16     7 infarto agudo al miocardio                                            1
#> 17     7 cardiopatia hipertensiva                                              2
#> 18     7 hipertension arterial sistemica                                       3
#> 19     8 meningioma                                                            1
#> 20     8 hipertension arterial sistemica                                       2
#> 21     9 encefalopatia hepatica                                                1
#> 22     9 cirrosis hepatica                                                     2
#> 23     9 alcoholismo cronico                                                   3
#> 24    10 infarto agudo al miocardio                                            1
#> 25    10 diabetes mellitus tipo ii                                             2
```

One can then proceed to use `ICDLookUp` to try to find an entry in the
catalog for each of the entries in the certificate:

``` r
results <- lapply(unique(tokenizedCerificates$id),
                     function(x) {
                       print(x)
                       subset <- dplyr::filter(tokenizedCerificates, id == x)
                       lapply(subset$cause, ICDLookUp)
                     }) %>%
  bind_rows(.id = 'id',) %>%
  mutate(id = as.numeric(id)) %>%
  arrange(id) %>%
  group_by(id) %>%
  mutate(order = row_number()) %>%
  ungroup() 
```

``` r
tokenizedCerificates$result <- results$disease
print(tokenizedCerificates, n = Inf)
#> # A tibble: 25 x 4
#>       id cause                          order result                            
#>    <dbl> <chr>                          <int> <chr>                             
#>  1     1 hemorragia subaracnoidea           1 hemorragia subaracnoidea no espec…
#>  2     1 hipertension arterial sistemi…     2 hipertension esencial             
#>  3     1 dislipidemia                       3 trastornos del metabolismo de las…
#>  4     2 infarto cerebral                   1 infarto cerebral no especificado  
#>  5     2 hipertension arterial sistemi…     2 hipertension esencial             
#>  6     2 trigliceridemia                    3 trastornos del metabolismo de las…
#>  7     3 herida producida por proyecti…     1 <NA>                              
#>  8     4 choque hipovolemico                1 choque hipovolemico               
#>  9     4 diarrea cronica                    2 <NA>                              
#> 10     4 infeccion por virus de inmuno…     3 enfermedad por virus de la inmuno…
#> 11     5 evento vascular cerebral           1 infarto cerebral no especificado  
#> 12     5 enfermedad renal terminal          2 <NA>                              
#> 13     5 diabetes mellitus tipo 2           3 diabetes mellitus no insulinodepe…
#> 14     6 aneurisma cerebral                 1 hemorragia subaracnoidea no espec…
#> 15     6 encefalopatia hepatica             2 insuficiencia hepatica no clasifi…
#> 16     7 infarto agudo al miocardio         1 infarto agudo del miocardio       
#> 17     7 cardiopatia hipertensiva           2 enfermedad cardiaca hipertensiva  
#> 18     7 hipertension arterial sistemi…     3 hipertension esencial             
#> 19     8 meningioma                         1 tumor benigno de las meninges par…
#> 20     8 hipertension arterial sistemi…     2 hipertension esencial             
#> 21     9 encefalopatia hepatica             1 insuficiencia hepatica no clasifi…
#> 22     9 cirrosis hepatica                  2 cirrosis hepatica alcoholica      
#> 23     9 alcoholismo cronico                3 sindrome de dependencia al alcohol
#> 24    10 infarto agudo al miocardio         1 infarto agudo del miocardio       
#> 25    10 diabetes mellitus tipo ii          2 diabetes mellitus no insulinodepe…
```

## License

This package is made available under the MIT License.

## Credits

This package is created and maintained by Mariana Carmona-Baez and Juan
Bernardo Martínez Parente-Castañeda. 🐞

*We’re open to suggestions, feel free to message us on
<mcarmonabaez@gmail.com> and <jbmpc@outlook.com>.* *Pull requests are
also welcome\!* 🔀

## Thanks

Thanks to Christopher Ormsby for his input and for letting us be part of
this awesome project :hospital:

Thanks to [Teresa Ortiz](https://github.com/tereom) for her invaluable
guidance :crystal\_ball:
