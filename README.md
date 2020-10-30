
<img src='logo/Hex.png' align="right" height="139" />

# Structural Equation Modeling foR Psychologists

[![](https://img.shields.io/badge/Open%20Educational%20Resources-Compatable-brightgreen)](https://creativecommons.org/about/program-areas/education-oer/)
[![](https://img.shields.io/badge/CC-BY--NC%204.0-lightgray)](http://creativecommons.org/licenses/by-nc/4.0/)  
[![](https://img.shields.io/badge/Language-R-blue)](http://cran.r-project.org/)

<sub>*Last updated 2020-10-30.*</sub>

This Github repo contains all lesson files for *SEM - Practical
Applications in R*. The goal is to impart students with the basic tools
to construct, evaluate and compare **Structural Equation Models (SEM; w/
plots), using [`lavaan`](http://lavaan.ugent.be/)**.

These topics were taught in the graduate-level course ***Structural
Equation Modeling*** (Psych Dep., Ben-Gurion University of the Negev,
*Spring, 2019*). This course assumes basic competence in R (importing,
regression modeling, plotting, etc.), along the lines of [*Practical
Applications in R for
Psychologists*](https://github.com/mattansb/Practical-Applications-in-R-for-Psychologists).

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
2.  [RStudio IDE](https://www.rstudio.com/products/rstudio/download/)
    (optional, but recommended).
3.  The following packages, listed by lesson:

| Lesson                                                                                              | Packages                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| --------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [01 path analysis](/01%20path%20analysis)                                                           | [`lavaan`](https://CRAN.R-project.org/package=lavaan), [`tidySEM`](https://CRAN.R-project.org/package=tidySEM), [`dplyr`](https://CRAN.R-project.org/package=dplyr), [`ggplot2`](https://CRAN.R-project.org/package=ggplot2), [`semPlot`](https://CRAN.R-project.org/package=semPlot)                                                                                                                                                                                  |
| [02 latent variables and hypothesis testing](/02%20latent%20variables%20and%20hypothesis%20testing) | [`lavaan`](https://CRAN.R-project.org/package=lavaan), [`semTools`](https://CRAN.R-project.org/package=semTools), [`dplyr`](https://CRAN.R-project.org/package=dplyr), [`semPlot`](https://CRAN.R-project.org/package=semPlot), [`psychTools`](https://CRAN.R-project.org/package=psychTools), [`bayestestR`](https://CRAN.R-project.org/package=bayestestR)                                                                                                           |
| [03 cross-lagged panel model](/03%20cross-lagged%20panel%20model)                                   | [`lavaan`](https://CRAN.R-project.org/package=lavaan), [`semPlot`](https://CRAN.R-project.org/package=semPlot), [`bayestestR`](https://CRAN.R-project.org/package=bayestestR)                                                                                                                                                                                                                                                                                          |
| [04 multiple group analysis](/04%20multiple%20group%20analysis)                                     | [`lavaan`](https://CRAN.R-project.org/package=lavaan), [`bayestestR`](https://CRAN.R-project.org/package=bayestestR), [`semPlot`](https://CRAN.R-project.org/package=semPlot), [`semTools`](https://CRAN.R-project.org/package=semTools)                                                                                                                                                                                                                               |
| [05 latent growth curve modeling](/05%20latent%20growth%20curve%20modeling)                         | [`lavaan`](https://CRAN.R-project.org/package=lavaan), [`semPlot`](https://CRAN.R-project.org/package=semPlot)                                                                                                                                                                                                                                                                                                                                                         |
| [06 assumption checks](/06%20assumption%20checks)                                                   | [`lavaan`](https://CRAN.R-project.org/package=lavaan), [`semTools`](https://CRAN.R-project.org/package=semTools), [`car`](https://CRAN.R-project.org/package=car)                                                                                                                                                                                                                                                                                                      |
| [07 moderation in lavaan](/07%20moderation%20in%20lavaan)                                           | [`lavaan`](https://CRAN.R-project.org/package=lavaan), [`semTools`](https://CRAN.R-project.org/package=semTools)                                                                                                                                                                                                                                                                                                                                                       |
| [08 EFA](/08%20EFA)                                                                                 | [`parameters`](https://CRAN.R-project.org/package=parameters), [`psych`](https://CRAN.R-project.org/package=psych), [`lavaan`](https://CRAN.R-project.org/package=lavaan), [`semPlot`](https://CRAN.R-project.org/package=semPlot), [`dplyr`](https://CRAN.R-project.org/package=dplyr), [`tidyr`](https://CRAN.R-project.org/package=tidyr), [`psychTools`](https://CRAN.R-project.org/package=psychTools), [`nFactors`](https://CRAN.R-project.org/package=nFactors) |

You can install all the packages used by running:

    # in alphabetical order:

    pkgs <- c(
      "bayestestR", "car", "dplyr", "ggplot2", "lavaan", "nFactors",
      "parameters", "psych", "psychTools", "semPlot", "semTools", "tidyr",
      "tidySEM"
    )

    install.packages(pkgs, dependencies = TRUE)

<details>

<summary><i>Package Versions</i></summary> The package versions used
here:

  - `bayestestR` 0.7.5 (*CRAN*)
  - `car` 3.0-10 (*CRAN*)
  - `dplyr` 1.0.2 (*CRAN*)
  - `ggplot2` 3.3.2 (*CRAN*)
  - `lavaan` 0.6-7 (*CRAN*)
  - `nFactors` 2.4.1 (*CRAN*)
  - `parameters` 0.9.0 (*CRAN*)
  - `psych` 2.0.9 (*CRAN*)
  - `psychTools` 2.0.8 (*CRAN*)
  - `semPlot` 1.1.2 (*CRAN*)
  - `semTools` 0.5-3 (*CRAN*)
  - `tidyr` 1.1.2 (*CRAN*)
  - `tidySEM` 0.1.3 (*CRAN*)

</details>

## Other Useful Resources

  - [`lavaan` toutorials](http://lavaan.ugent.be/tutorial/index.html).  
  - Sacha Epskamp’s [online course](http://sachaepskamp.com/SEM2020) and
    [YouTube
    lectures](https://www.youtube.com/playlist?list=PLliBbGBc5nn3m8bXQ4CmOep3UmQ_5tVlC).  
  - Michael Hallquist’s
    [course](https://psu-psychology.github.io/psy-597-SEM/).
