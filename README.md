# icd10es - A user-friendly R package for disease clasification in Spanish

---

## Table of Contents

- [Package description](#description)
- [Installing icd10es](#installing)
- [Features at a glance](#features-at-a-glance)
  - [Printing information of a CIE-10 entry](#printing-info)
  - [Looking up a string in the catalog](#icdlookup)
  - [Using an external catalog](#external)
  - [Looking up entries within death certificates](#death-certificates)
- [License](#license)
- [Credits](#credits)
- [Thanks](#thanks)

## Package description

`icd10es` is an R package created for :es: Spanish-speaking Bioinformatics specialist who have to deal with classifying written descriptions of diseases, symptoms, and injuries, among other health-related issues, in the 10th edition of the International Statistical Classification of Diseases and Related Health Problems (ICD-10 for short), referred to as CIE-10 in Spanish.

## Installing icd10es 

:octocat:
```{r}
devtools::install_github("mcarmonabaez/icd10es")
```

*Congratulations!* Now you can use this package! 🎉

## Features at a glance

### Printing information of a CIE-10 entry

## Printing information of a CIE-10 entry
Let's start with a simple task: say you wish to know what the entry 'A00.0' in the catalog contains.
The function `printInfo` can help with that. Changing the value of the parameter `tabular` you
can decide whether you want to 

- get only the canonical term in table form, 

- get the canonical and all inclusion terms (if they exist) also in table form, 

- print in all associated information in the console for quick inquiries.

```{r}
library(icd10es)
printInfo('S72.1', tabular = 'single')
printInfo('S72.1', tabular = 'simple')
printInfo('S72.1', tabular = 'full')
```




### Looking up a string in the catalog

😷

### Using an external catalog



### Looking up entries within death certificates



## License

This package is made available under the MIT License.

## Credits

This package is created and maintained by Mariana Carmona-Baez  and Juan Bernardo Martínez Parente-Castañeda. 🐞

*We're open to suggestions, feel free to message us on mcarmonabaez@gmail.com and jbmpc@outlook.com.*
*Pull requests are also welcome!* 🔀


## Thanks

Thanks to Christopher Ormsby for his input and for letting us be part of this awesome project :hospital:

Thanks to [Teresa Ortiz](https://github.com/tereom) for her invaluable guidance :crystal_ball:




