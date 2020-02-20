
adhd_anx_gender <- read.csv("adhd_anx_gender.csv")
head(adhd_anx_gender)


# Unconstrained model -----------------------------------------------------

# Our groups:
levels(adhd_anx_gender$gender)

library(lavaan)

mod <- '
  ## latent variable definitions (CFA)
  ADHD =~ adhd1 + adhd2 + adhd3
    IQ =~ iq1 + iq2
   ANX =~ anx1 + anx2 + anx3 
   
   ADHD ~ IQ + ANX
   
   IQ ~~ ANX
'

fit_groups <- cfa(mod, data = adhd_anx_gender, 
                  likelihood = "wishart",
                  std.lv = TRUE,
                  group = "gender")
summary(fit_groups, standardize = TRUE)

library(semPlot)
# panelGroups = TRUE
semPaths(fit_groups, what = "std", whatLabels = "std", 
         residuals = TRUE, intercepts = FALSE,
         panelGroups = TRUE,
         # prettify
         fade = FALSE,
         style = "lisrel", normalize = TRUE, 
         sizeMan = 11, sizeMan2 = 7,
         sizeLat = 11, sizeLat2 = 7,
         nCharNodes = 7,
         edge.label.cex = 1.5,
         edge.label.bg = FALSE, edge.label.color = "black",
         edge.label.position = 0.45)

# Constraints -------------------------------------------------------------

# We can constraint parameters using modefiers:
mod_const <- '
  ## latent variable definitions (CFA)
  ADHD =~ adhd1 + adhd2 + adhd3
    IQ =~ iq1 + iq2
   ANX =~ anx1 + anx2 + anx3 
   
   ADHD ~ c(v1, v1) * IQ + ANX # <<<<<<<
   
   IQ ~~ ANX
'

fit_groups_const <- cfa(mod_const, data = adhd_anx_gender,
                        likelihood = "wishart",
                        std.lv = TRUE,
                        group = "gender")
summary(fit_groups_const, standardize = TRUE)


# comapre models
anova(fit_groups, fit_groups_const)
bayestestR::bayesfactor_models(fit_groups, fit_groups_const)


# we can also test differences:
mod_const2 <- '
  ## latent variable definitions (CFA)
  ADHD =~ adhd1 + adhd2 + adhd3
    IQ =~ iq1 + iq2
   ANX =~ anx1 + anx2 + anx3 
   
   ADHD ~ c(v1, v1) * IQ + ANX
   
   IQ ~  ~ c(c1, c2) * ANX  # <<<<<<<
   
   cv_diff := c1 - c2
'

fit_groups_const2 <- cfa(mod_const2, data = adhd_anx_gender,
                         likelihood = "wishart",
                         std.lv = TRUE, 
                         group = "gender")
summary(fit_groups_const2, standardize = TRUE)



# Measurement Invariance --------------------------------------------------
# https://dx.doi.org/10.1097%2F01.mlr.0000245454.12228.8f

#' Measurement invariance is a statistical property of measurement that
#' indicates that the same construct is being measured across some specified groups.
#' Often just assume this - but we can also test this directly.


cat(mod)

fit_groups_measi <- cfa(mod, data = adhd_anx_gender, 
                        likelihood = "wishart",
                        std.lv = TRUE,
                        group = "gender", group.equal = "loadings")
summary(fit_groups_measi, standardize = TRUE)


anova(fit_groups_measi, fit_groups)
bayestestR::bayesfactor_models(fit_groups, fit_groups_measi)

# We saw that we can set group equality for the indicator loadings, but we can also
# set other group equality constraints with the group.equal argument:
# -          "regressions": all regression coefficients in the model
# -            "residuals": the residual variances of the observed variables
# - "residual.covariances": the residual covariances of the observed variables
# -         "lv.variances": the (residual) variances of the latent variables
# -       "lv.covariances": the (residual) covariances of the latent varibles
# -           "intercepts": the intercepts of the observed variables
# -                "means": the intercepts/means of the latent variables
?semTools::measEq.syntax
# ^ Can also be used to build and test equallity constraints.

# Exercise ----------------------------------------------------------------

# 1. Test for a group equality on the means. What do you make of the results?
# 2. For the effect of ANX on ADHD:
#    - Compute the difference in slopes between the groups.
#    - Fit a model with an equality on this parameter. Compare to the unrestricted model.
