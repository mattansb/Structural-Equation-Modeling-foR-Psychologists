#' unspecifies arrows:
#' 1) the factor loading of the first indicator of a latent variable is fixed to 1,
#'    thereby fixing the scale of the latent variable.
#' 2) residual variances are added automatically
#' 3) all exogenous latent variables are correlated by default.

library(lavaan)
library(lavaanPlot)

model <- '
# measurement model
ind60 =~ x1 + x2 + x3
dem60 =~ y1 + y2 + y3 + y4
dem65 =~ y5 + y6 + y7 + y8
# regressions
dem65 ~ ind60 + dem60

# no residual var
x1 ~~ 0*x1
# no cov between exogenous latent
ind60 ~~ 0*dem60
'

fit <- sem(model, data = PoliticalDemocracy)
summary(fit)

?buildCall
?buildLabels
?buildPaths
lavaanPlot(model = fit, covs = T, stand = T, coefs = T)
