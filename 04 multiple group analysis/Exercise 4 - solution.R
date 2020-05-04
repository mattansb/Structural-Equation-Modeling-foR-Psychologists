
group_data <- read.csv("group_data.csv")

library(lavaan)

# Going back to the STRUCTURAL model...

mod <- '
  ## latent variable definitions (CFA)
  Psypath =~  BAI + BDI
    Sleep =~  sleep1 + sleep2 + sleep3

  ## Regressions
  Psypath ~ Sleep + trauma

  ## Covariances (this is with the residuals of BAI)
  trauma ~~ BAI
'

fit_groups <- sem(mod, data = group_data, 
                  std.lv = TRUE,
                  group = "gender")


# 1. Fit a model constraining a group equality on the intercepts ----------

fit_groups.intercepts <- sem(mod, data = group_data, 
                             std.lv = TRUE,
                             group = "gender",
                             group.equal = "intercepts")

#    - Compare it (test) to the unconstrained model.
anova(fit_groups, fit_groups.intercepts)
bayestestR::bayesfactor_models(fit_groups, fit_groups.intercepts)
#    - What do you make of the results?
# No significant difference (and BF supports the fixed intercepts) - seems like
# there is no difference between the groups in the various intercepts in the
# model.




# 2. For the effect of Sleep on Psypath -----------------------------------
#    - Compute the difference in slopes between the groups.
mod <- '
  ## latent variable definitions (CFA)
  Psypath =~  BAI + BDI
    Sleep =~  sleep1 + sleep2 + sleep3

  ## Regressions
  Psypath ~ c(b_slpW, b_slpM) * Sleep + trauma

  ## Covariances (this is with the residuals of BAI)
  trauma ~~ BAI
  
  ## Estimate diff
  diff := b_slpW - b_slpM
'

fit_groups <- sem(mod, data = group_data, 
                  std.lv = TRUE,
                  group = "gender")
summary(fit_groups)
#> Defined Parameters:
#>                    Estimate  Std.Err  z-value  P(>|z|)
#>     diff             -0.243    0.093   -2.596    0.009


#    - Fit a model with an equality on this parameter. Compare to the
#      unrestricted model.
mod_eq_sleep <- '
  ## latent variable definitions (CFA)
  Psypath =~  BAI + BDI
    Sleep =~  sleep1 + sleep2 + sleep3

  ## Regressions
  Psypath ~ c(b_slpX, b_slpX) * Sleep + trauma

  ## Covariances (this is with the residuals of BAI)
  trauma ~~ BAI
'

fit_groups_eq_sleep <- sem(mod_eq_sleep, data = group_data, 
                           std.lv = TRUE,
                           group = "gender")
anova(fit_groups, fit_groups_eq_sleep)
#   - What do you make of the results?
# Looks like there is a difference between the groups in the effect of Sleep on
# Psypath - this is a moderation result!
