
group_data <- read.csv("group_data.csv")
head(group_data)

# Our groups:
unique(group_data$gender)
# here we have 2, but was can have more...
# Note that the order or the groups is not determined as the order of the factor
# levels, but as the order in which they appear in the data frame.



# The question we want to ask - how are women and men different in the
# structural relationship between psychopathology, sleep, and trauma.



library(lavaan)

## 1. Build the model, as usual
mod <- '
  ## latent variable definitions (CFA)
  Psypath =~  BAI + BDI
    Sleep =~  sleep1 + sleep2 + sleep3

  ## Regressions
  Psypath ~ Sleep + trauma

  ## Covariances (this is with the residuals of BAI - why?)
  trauma ~~ BAI
'

## 2. Fit the model with the `group` argument.
fit_groups <- sem(mod, data = group_data, 
                  group = "gender") # tell lavaan what the grouping var is

# By default, lavaan lets ALL THE PARAMETER varry by group.

summary(fit_groups, standardize = TRUE)


library(tidySEM)

lay <- get_layout(
  NA,    NA,        NA,       "sleep1",
  NA,    NA,        "Sleep",  "sleep2",
  "BDI", NA,        NA,       "sleep3",
  NA,    "Psypath", NA,       NA,
  "BAI", NA,        NA,       NA,
  NA,    NA,        "trauma", NA,
  rows = 6
)

graph_sem(fit_groups, 
          edges = get_edges(fit_groups, label = "est_std"),
          layout = lay)

# The values in the variables are their mean (raw) values. We can change this by
# setting:
graph_sem(fit_groups, 
          edges = get_edges(fit_groups, label = "est_std"),
          nodes = get_nodes(fit_groups, label = "name"),
          layout = lay)



# Constraining with Modifiers ---------------------------------------------

# Lets focus on the cov between (residual) BAI and trauma: Do men and woman
# differ on the `.BAI ~~ trauma` parameter?
#
# We have two ways of testing this:
# 1. Computed the estimate (:=).
# 2. Comparing a constrained model.





## Modifiers are vectors ------------

# When working with a multi-group model, modifiers must be specified as VECTORS.
# For example, to estimate the difference in the covariance between men and
# woman, we can:


mod <- '
  ## latent variable definitions (CFA)
  Psypath =~  BAI + BDI
    Sleep =~  sleep1 + sleep2 + sleep3

  ## Regressions
  Psypath ~ Sleep + trauma

  ## Covariances (this is with the residuals of BAI - why?)
  trauma ~~ c(cvW, cvM) * BAI
  
  ## Computed estimates
  cv_diff := cvM - cvW
'

fit_groups <- sem(mod, data = group_data, 
                  group = "gender")
summary(fit_groups, standardize = TRUE)

# we can see the that difference in cov is 0.39 (or the difference in
# correlation is 0.25), and is significant.






## Constrain parameters across groups ------------

# We can also use modifiers to CONSTRAIN a model:
mod_eq_cov <- '
  ## latent variable definitions (CFA)
  Psypath =~  BAI + BDI
    Sleep =~  sleep1 + sleep2 + sleep3

  ## Regressions
  Psypath ~ Sleep + trauma

  ## Covariances (this is with the residuals of BAI - why?)
  trauma ~~ c(cv, cv) * BAI
'
# What is implied by this model?


fit_groups_eq_cov <- sem(mod_eq_cov, data = group_data, 
                         group = "gender")

parameterEstimates(fit_groups_eq_cov, output = "text")



# Compare the models
anova(fit_groups, fit_groups_eq_cov)
bayestestR::bayesfactor_models(fit_groups_eq_cov, denominator = fit_groups)
# What do these mean?










# Constrain by parameter type ---------------------------------------------

# We can also tell lavaan to set all parameters of one (or more) types to be
# equall ACROSS GROUPS. For example, if we want all residuals (observed and
# latent) to be equal across groups, we would specify 
# `group.equal = c("residuals", "lv.variances")`

fit_groups_equires <- sem(mod, data = group_data, 
                          group = "gender", 
                          group.equal = c("residuals", "lv.variances"))
summary(fit_groups_equires)


anova(fit_groups_equires, fit_groups)
bayestestR::bayesfactor_models(fit_groups, denominator = fit_groups_equires)



# We saw that we can set group equality for residuals (observed and latent) but
# we can also set other group equality constraints with the group.equal
# argument:
# -             "loadings": all latent factor loadings
# -          "regressions": all regression coefficients
# - "residual.covariances": the (residual?) covariances of the observed vars
# -       "lv.covariances": the (residual?) covariances of the latent vars
# -            "residuals": the (residual?) variances of the observed vars
# -         "lv.variances": the (residual?) variances of the latent vars
# -           "intercepts": the intercepts of the observed variables
# -                "means": the intercepts/means of the latent variables


# What if you want to constrain all the parameter of a type, but 1 or 2?
# More options are covered hare: http://lavaan.ugent.be/tutorial/groups.html










# Measurement Invariance --------------------------------------------------


# https://dx.doi.org/10.1097%2F01.mlr.0000245454.12228.8f

# Measurement invariance is a statistical property of measurement that indicates
# that the same construct is being measured across some specified groups / time.
# Often we just assume this - but with sem we can also test this directly.
# 
# These tests are done on the measurement model.

meas_mod <- "
  ## latent variable definitions (CFA)
  Psypath =~  BAI + BDI
    Sleep =~  sleep1 + sleep2 + sleep3
    
  ## Remeber this?
  trauma ~ 1 * trauma

  ## Covariances (this is with the residuals of BAI - why?)
  Psypath ~~ Sleep + trauma
   trauma ~~ BAI
"

fit_meas <- cfa(meas_mod, data = group_data, 
                group = "gender")

# Measurement Invariance can be tested by constraining types of parameters.
# Specifically, we want to look at loadings, intercepts, and means (but
# sometimes also residuals):

fit_meas.loadings <- cfa(meas_mod, data = group_data, 
                         group.equal = c("loadings"),
                         group = "gender")

fit_meas.intercepts <- cfa(meas_mod, data = group_data, 
                           group.equal = c("loadings", "intercepts"), 
                           group = "gender")


fit_meas.means <- cfa(meas_mod, data = group_data,
                      group.equal = c("loadings", "intercepts", "means"), 
                      group = "gender")
# here the only means that are estimated are those of the latent variables.



anova(fit_meas, fit_meas.loadings, fit_meas.intercepts, fit_meas.means)
bayestestR::bayesfactor_models(fit_meas.loadings, fit_meas.intercepts, fit_meas.means,
                               denominator = fit_meas)
# What does this mean?







# For more advances modeling and testing of Measurement Invariance, take a look
# at:
?semTools::measEq.syntax





# Exercise ----------------------------------------------------------------

# Going back to the STRUCTURAL model:
# 1. Fit a model constraining a group equality on the intercepts. 
#    - Compare it (test) to the unconstrained model.
#    What do you make of the results?
#
# 2. For the effect of Sleep on Psypath:
#    - Compute the difference in slopes between the groups.
#    - Fit a model with an equality on this parameter. Compare to the
#      unrestricted model.
#    What do you make of the results?
