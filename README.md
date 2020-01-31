
<img src='logo/BGUHex.png' align="right" height="139" />

# Structural Equation Modeling foR Psychologists

<sub>*Last updated 2020-01-31.*</sub>

This Github repo contains all lesson files used in the graduate-level
course: *Structural Equation Modeling foR Psychologists - Practical
Applications in R*, taught at Ben-Gurion University on the Negev (spring
2019 semester).

The goal is to impart students with the basic tools to construct,
evaluate and compare structural equation models (SEM; w/ plots), using
[`lavaan`](http://lavaan.ugent.be/).

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

| Lesson                                                            | Packages                          |
| ----------------------------------------------------------------- | --------------------------------- |
| [01 path analysis](/01%20path%20analysis)                         | `lavaan`, `semPlot`, `lavaanPlot` |
| [02 cross-lagged panel model](/02%20cross-lagged%20panel%20model) | `lavaan`, `semPlot`, `bayestestR` |
| [03 CFA](/03%20CFA)                                               | `lavaan`, `lavaanPlot`            |

You can install all the packages used by running:

    # in alphabetical order:

    pkgs <- c("bayestestR", "lavaan", "lavaanPlot", "semPlot")

``` r
install.packages(pkgs, dependencies = TRUE)
```

The package versions used here:

    ## bayestestR     lavaan lavaanPlot    semPlot 
    ##    "0.5.1"    "0.6-5"    "0.5.1"    "1.1.2"
