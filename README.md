
<!-- README.md is generated from README.Rmd. Please edit that file -->

# icd10es - A user-friendly R package for disease clasification in Spanish

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

## Package description

`icd10es` is an R package created for :es: Spanish-speaking
Bioinformatics specialist who have to deal with classifying written
descriptions of diseases, symptoms, and injuries, among other
health-related issues, in the 10th edition of the International
Statistical Classification of Diseases and Related Health Problems
(ICD-10 for short), referred to as CIE-10 in Spanish.

## Installing icd10es

``` r
devtools::install_github("mcarmonabaez/icd10es")
```

*Congratulations\!* Now you can use this package\! 🎉

## Features at a glance

### Printing information of a CIE-10 entry

:female-doctor:

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

### Looking up a string in the catalog

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

😷

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

### Looking up entries within death certificates

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
