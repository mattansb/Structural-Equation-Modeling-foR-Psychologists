#' Today we will continue to explore the relationship between ADHD, IQ,
#' and anxiety and their effects on sustained attention and inhibition

adhd_anx <- read.csv("adhd_anx.csv")
head(adhd_anx)



library(lavaan)




# 2. Constraining and Unconstraining --------------------------------------

# This is where the magic happens!
# AKA hypothesis testing!


## Example 1) equal loadings on a factor:
# We saw how to do this last time. Now we know that we can test the
# equal-loading hypothesis!

mod_meas_eq_load <- '
  ## latent variable definitions (CFA)
  ## The "=~" can be read as "is identified by"
  ADHD =~ a * adhd1 + a * adhd2 + a * adhd3
    IQ =~ iq1 + iq2
   ANX =~ anx1 + anx2 + anx3 
  
  ## self-regression
  sustained_attn ~ 1 * sustained_attn
      inhibition ~ 1 * inhibition
  # We need to define one of the observed variables (this is a silly bug).
  # This does not affect the model fit!
  
  ## covariances
  sustained_attn ~~ inhibition + ADHD + IQ + ANX
      inhibition ~~ ADHD + IQ + ANX
'

fit_meas_eq_load <- cfa(mod_meas_eq_load, data = adhd_anx, 
                        std.lv = TRUE)



## Example 2) set a path to 0: That is what the structural model is!
# When defining structural model, the important bits are the arrow you
# don't include ( = fix at 0)!!


mod_struct_eq_load <- '
  ## latent variable definitions
  ADHD =~ a * adhd1 + a * adhd2 + a * adhd3
    IQ =~ iq1 + iq2
   ANX =~ anx1 + anx2 + anx3 
  
  ## regressions
      inhibition ~ ADHD + ANX + IQ
  sustained_attn ~ inhibition + ADHD
  
  ## covariances
  IQ ~~ ADHD      # we dont need this, because the of defaults...
  IQ ~~ 0 * ANX
'

# Which paths have been constrained to 0?

fit_struct_eq_load <- sem(mod_struct_eq_load, data = adhd_anx,
                          std.lv = TRUE)




library(semPlot)
semPaths(fit_struct_eq_load, what = "std", whatLabels = "std", 
         residuals = TRUE, intercepts = FALSE,
         # prettify
         fade = FALSE,
         style = "lisrel", normalize = TRUE, 
         sizeLat = 7, sizeLat2 = 5,
         nCharNodes = 7,
         edge.label.cex = 1,
         edge.label.position = 0.45,
         edge.label.bg = TRUE, edge.label.color = "black")











# 3. Measures of Fit ---------------------------------------------------------
# and model comparisons



# Let's compare equal loading structure model to the equal loading measurment
# model:


## Measures of fit

fitMeasures(fit_struct_eq_load, output = "matrix",
            fit.measures = c("nfi","nnfi","tli", "cfi","rmsea"))
# What we want:
#        NFI > 0.9
# NNFI / TLI > 0.9
#        CFI > 0.9
#      RMSEA < 0.08

# BUT (except for rmsea) these are RELATIVE measures - by default
# they are relative to the null /"independence" model,
# But we can give another baseline model:
fitMeasures(fit_struct_eq_load, output = "matrix",
            fit.measures = c("nfi","nnfi","tli", "cfi","rmsea"), 
            baseline.model = fit_meas_eq_load) # we added a NEW baseline!







## Comparing Models

fitMeasures(fit_struct_eq_load, output = "matrix",
            fit.measures = c(
              "chisq", "df","pvalue",
              "baseline.chisq","baseline.df","baseline.pvalue"
            ))
# The "baseline" model is the null /"independence" model, which
# constraintsall covariances to zero, AKA the worst model.

# But we can give another baseline model
fitMeasures(fit_struct_eq_load, output = "matrix",
            fit.measures = c(
              "chisq", "df","pvalue",
              "baseline.chisq","baseline.df","baseline.pvalue"
            ),
            baseline.model = fit_meas_eq_load)




# To actually compare two (nested!) models:
anova(fit_struct_eq_load, fit_meas_eq_load) # Is this good or bad?

bayestestR::bayesfactor_models(fit_struct_eq_load,
                               denominator = fit_meas_eq_load)
# Bayes factors can also be used to compare non-nested models...
# (You can also fit a true Bayesian lavaan model with `blavaan`)










# Modification Indices ----------------------------------------------------



# We can look at modification indices (mi):
modificationIndices(fit_meas_eq_load, sort. = TRUE, maximum.number = 5)
modificationIndices(fit_meas_eq_load, sort. = TRUE, minimum.value = 10)
# what should we do?

#' why `iq2 ~~ anx1`?

# What would our next steps be?






# Exercise ----------------------------------------------------------------

library(dplyr)
big5 <- psychTools::bfi %>%
  select(A1:A5, C1:C5, E1:E5, N1:N5, O1:O5,
         gender, age) %>%
  na.omit()

head(big5)

# 1. Create a measurment model with the big 5 (latent), age, and gender.
#    - Explore the MIs. Is there anything you should add?
#      Does it make sense?
# 2. Create 2 structural models (your choice) with the big5, age and gender.
#    - Compare them (sig [make sure they are nested], BF).
#    - Compare their measures of fit.
# 3. Plot one of the 3 models from 1-2.