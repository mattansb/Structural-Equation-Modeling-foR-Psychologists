
<img src='logo/BGUHex.png' align="right" height="139" />

# Structural Equation Modeling foR Psychologists

<sub>*Last updated 2020-03-17.*</sub>

This Github repo contains all lesson files used in the graduate-level
course: *Structural Equation Modeling foR Psychologists - Practical
Applications in R*, taught at Ben-Gurion University on the Negev (spring
2019 semester). This course assumes basic competence in R (importing,
regression modeling, plotting, etc.), a long the lines of the
prerequisite course, [*Advanced Research Methods foR
Psychologists*](https://github.com/mattansb/Advanced-Research-Methods-foR-Psychologists).

The goal is to impart students with the basic tools to construct,
evaluate and compare **Structural Equation Models (SEM; w/ plots), using
[`lavaan`](http://lavaan.ugent.be/)**.

**Notes:**

  - This repo contains only materials relating to *Practical
    Applications in R*, and does not contain any theoretical or
    introductory materials.  
  - Please note that some code does not work *on purpose*, to force
    students to learn to debug.

## Setup

You will need:

1.  A fresh installation of [**`R`**](https://cran.r-project.org/)
    (preferably version 3.6 or above).
2.  [RStudio](https://www.rstudio.com/products/rstudio/download/)
    (optional - but I recommend using an IDE).
3.  The following packages, listed by lesson:

| Lesson                                                                                              | Packages                                                                                                                                                                                                                                                                                                                                                                                                    |
| --------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [01 path analysis](/01%20path%20analysis)                                                           | [`lavaan`](https://CRAN.R-project.org/package=lavaan), [`semPlot`](https://CRAN.R-project.org/package=semPlot), [`lavaanPlot`](https://CRAN.R-project.org/package=lavaanPlot)                                                                                                                                                                                                                               |
| [02 CFA + latent variable structural model](/02%20CFA%20+%20latent%20variable%20structural%20model) | [`lavaan`](https://CRAN.R-project.org/package=lavaan), [`semPlot`](https://CRAN.R-project.org/package=semPlot), [`dplyr`](https://CRAN.R-project.org/package=dplyr), [`semTools`](https://CRAN.R-project.org/package=semTools), [`bayestestR`](https://CRAN.R-project.org/package=bayestestR), [`psychTools`](https://CRAN.R-project.org/package=psychTools)                                                |
| [03 cross-lagged panel model](/03%20cross-lagged%20panel%20model)                                   | [`lavaan`](https://CRAN.R-project.org/package=lavaan), [`semPlot`](https://CRAN.R-project.org/package=semPlot), [`bayestestR`](https://CRAN.R-project.org/package=bayestestR)                                                                                                                                                                                                                               |
| [04 multiple group analysis](/04%20multiple%20group%20analysis)                                     | [`lavaan`](https://CRAN.R-project.org/package=lavaan), [`semPlot`](https://CRAN.R-project.org/package=semPlot), [`bayestestR`](https://CRAN.R-project.org/package=bayestestR), [`semTools`](https://CRAN.R-project.org/package=semTools)                                                                                                                                                                    |
| [05 EFA](/05%20EFA)                                                                                 | [`parameters`](https://CRAN.R-project.org/package=parameters), [`psych`](https://CRAN.R-project.org/package=psych), [`lavaan`](https://CRAN.R-project.org/package=lavaan), [`semPlot`](https://CRAN.R-project.org/package=semPlot), [`dplyr`](https://CRAN.R-project.org/package=dplyr), [`tidyr`](https://CRAN.R-project.org/package=tidyr), [`psychTools`](https://CRAN.R-project.org/package=psychTools) |
| [06 latent growth curve modeling](/06%20latent%20growth%20curve%20modeling)                         | [`lavaan`](https://CRAN.R-project.org/package=lavaan), [`semPlot`](https://CRAN.R-project.org/package=semPlot)                                                                                                                                                                                                                                                                                              |

You can install all the packages used by running:

    # in alphabetical order:

    pkgs <- c(
      "bayestestR", "dplyr", "lavaan", "lavaanPlot", "parameters",
      "psych", "psychTools", "semPlot", "semTools", "tidyr"
    )

    install.packages(pkgs, dependencies = TRUE)

The package versions used here:

    ##  bayestestR       dplyr      lavaan  lavaanPlot  parameters       psych 
    ##     "0.5.2"     "0.8.5"     "0.6-5"     "0.5.1"   "0.5.0.1" "1.9.12.31" 
    ##  psychTools     semPlot    semTools       tidyr 
    ##    "1.9.12"     "1.1.2" "0.5-2.920"     "1.0.2"

## Other Useful Resources

  - [`lavaan` toutorials](http://lavaan.ugent.be/tutorial/index.html).  
  - Sacha Epskamp’s [online course](http://sachaepskamp.com/SEM2019).  
  - Michael Hallquist’s
    [course](https://psu-psychology.github.io/psy-597-SEM/).
