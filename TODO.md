TO DO:

- Tener catalogo al pedo
    - Juntar categorias y subcategorias
    - Catalogo para impresion
    - Eliminar cancer y diabetes de subcategorias
    - Terminar catalogo
    - Agregar categorias a catalogo de cancer
- ~~Si se hace match con categoria, revisar si + SAI está presente antes de asignarle categoria (ejemplo: I21)~~
- ~~Primer build~~
- ~~Analizar bien qué sucede con "no especificado" y "SAI"~~
- ~~Unir catálogo subcategorías~~
- ~~Corregir printInfo~~
- ~~Subcategorías con puntito~~

- Casos especiales:
   * diabetes: revisar detalles
   * diabetes: :
      ° Si sólo hay una categoría, devolver ésa
    * cancer:
      ° ~~revisar vejiga urinaria (print cuando solo hay un match)~~
      ° revisar en catalogo C119, C180, C942, C433, C260
      ° tumores benignos y melanomas in situ
      ° tumores secundarios/metastasis **aun no
   * COVID
   * NAC
- Tokenizar actas / Mantener orden de los padecimientos
- Probar quitando stopwords desde el inicio

- Hacer la _roxygenización_
- Reportes (+ viñeta(s))
- Shiny

  * Input del usuario para agrandar el catálogo
  * terminar catálogo
  * flags del catálogo del IMSS
  * términos de exclusión
  * Viñetas


Estructura del reporte

- Intro: Contexto, describir la organización
- Problemática (en el dominio)
- ¿Qué existe actualemente?
- Describir baseline (lo que hicimos en junio) --> Lo que se hacía antes de que le entráramos?
- Problemática (desde Ciencia de Datos)
- Metas y objetivos (tener una herramienta estandarizada)
  - Clasificación de padecimientos usando el CIE-10
  - Utilizar las funciones básicas del paquete para desarrollar una herramienta
    de consulta (shiny / R console)

- Flujo de trabajo (catálogo, web scraping, metodología, SAI, casos especiales)
  * Justificar que no se pudo hacer web scraping porque es un desmadre (ej: S13.5)
- Resultados
- Recomendaciones, conclusiones, trabajo futuro


Preguntas:
- Cetoacidosis diabética / pie diabético
- Cáncer cervicouterino

