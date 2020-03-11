
#' Today we will explore the relationship between ADHD, IQ, and anxiety
#' and their effects on sustained attention and inhibition

adhd_anx <- read.csv("adhd_anx.csv")
head(adhd_anx)

# 1. measurement model ----------------------------------------------------

library(lavaan)

mod_meas <- '
  ## latent variable definitions (CFA)
  ## The "=~" can be read as "is identified by"
  ADHD =~ adhd1 + adhd2 + adhd3
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

fit_meas <- cfa(mod_meas, data = adhd_anx)

library(semPlot)
semPaths(fit_meas, what = "std", whatLabels = "std", 
         residuals = TRUE, intercepts = FALSE,
         # prettify
         fade = FALSE,
         style = "lisrel", normalize = TRUE, 
         edge.label.cex = 1,
         edge.label.bg = TRUE, edge.label.color = "black",
         edge.label.position = 0.45)


summary(fit_meas, standardize = TRUE)
# why is there no test for ADHD =~ adhd1?

parameterEstimates(fit_meas, output = "text")
standardizedSolution(fit_meas, output = "text")
# By default the factor loading of the first indicator of a latent variable is fixed to 1,
# thereby fixing the scale of the latent variable... Fixed parameters are not tested.
fit_meas <- cfa(mod_meas, data = adhd_anx, 
                std.lv = TRUE)
summary(fit_meas, standardize = TRUE)

# we can also extract the scores of the latent variables,
# but note that these mostly only make sense WITHIN a SEM model.
cfa_scores <- data.frame(lavPredict(fit_meas, append.data = FALSE)) # set append.data = TRUE to also get the original data.
head(cfa_scores)

# Reliability -------------------------------------------------------------

mod_lat_only <- '
  ## latent variable definitions (CFA)
  ADHD =~ adhd1 + adhd2 + adhd3
    IQ =~ iq1 + iq2
   ANX =~ anx1 + anx2 + anx3
'

fit_lat_only <- cfa(mod_lat_only, data = adhd_anx)

semTools::reliability(fit_lat_only) # see also semTools::reliabilityL2
# We will look at `omega`, which is similar to alpha, but doesn't assume
# equal weights / loadings (which we just estimated!). It can be thought of
# as representing the variance explained across the indicators of each factor.
# https://doi.org/10.1037/met0000144
# read about the other indices here, and when you'd like to use them:
?semTools::reliability

# 2. structural model -----------------------------------------------------

# When defining structural model, the important bits are
# the arrow you don't include (=fix at 0)!!

mod_struct <- '
  ## latent variable definitions
  ADHD =~ adhd1 + adhd2 + adhd3
    IQ =~ iq1 + iq2
   ANX =~ anx1 + anx2 + anx3 
  
  ## regressions
      inhibition ~ ADHD + ANX + IQ
  sustained_attn ~ inhibition + ADHD
  
  ## covariances
  IQ ~~ ADHD      # we dont need this, because the of defaults...
  IQ ~~ 0 * ANX
'

fit_struct <- sem(mod_struct, data = adhd_anx,
                  std.lv = TRUE)

semPaths(fit_struct, what = "std", whatLabels = "std", 
         residuals = TRUE, intercepts = FALSE,
         # prettify
         fade = FALSE,
         style = "lisrel", normalize = TRUE, 
         sizeLat = 7, sizeLat2 = 5,
         nCharNodes = 7,
         edge.label.cex = 1,
         edge.label.position = 0.45,
         edge.label.bg = TRUE, edge.label.color = "black")

summary(fit_struct, standardize = TRUE)



# Measures of Fit ---------------------------------------------------------
# and model comparisons

fitMeasures(fit_struct, output = "matrix",
            fit.measures = c(
              "chisq", "df","pvalue",
              "baseline.chisq","baseline.df","baseline.pvalue"
            ))
# The "baseline" model is the null /"independence" model, which constraints
# all covariances to zero, AKA the worst model.

# But we can give another baseline model
fitMeasures(fit_struct, output = "matrix",
            fit.measures = c(
              "chisq", "df","pvalue",
              "baseline.chisq","baseline.df","baseline.pvalue"
            ),
            baseline.model = fit_meas)

# To actually compare twho (nested!) models:
anova(fit_struct, fit_meas) # Is this good or bad?

bayestestR::bayesfactor_models(fit_struct, denominator = fit_meas)
# Bayes factors can also be used to compare non-nested models...
# (You can also fit a true Bayesian lavaan model with `blavaan`)





fitMeasures(fit_struct, output = "matrix",
            fit.measures = c("nfi","nnfi","tli", "cfi","rmsea"))
# What we want:
#        NFI > 0.9
# NNFI / TLI > 0.9
#        CFI > 0.9
#      RMSEA < 0.08

# But (except for rmsea) these are RELATIVE measures - by default
# they are relative to the null /"independence" model,
# But we can give another baseline model:
fitMeasures(fit_struct, output = "matrix",
            fit.measures = c("nfi","nnfi","tli", "cfi","rmsea"), 
            baseline.model = fit_meas) # note we added a NEW baseline!










# 3. Constraining and Unconstraining --------------------------------------

# This is where the magic happens!
# AKA hypothesis testing!


# Constraining ------------------------------------------------------------

## Example 1) equal loadings on a factor:

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
summary(fit_meas_eq_load, standardize = TRUE)
# (Note that the standardized loadings are NOT equal!
# We will learn next time how to deal with that..)



## Example 2) set a path to 0:
# We did this! That is what the structural model is!
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
# (we can constrain to any value we'd like!)

fit_struct_eq_load <- sem(mod_struct_eq_load, data = adhd_anx,
                          std.lv = TRUE)

# Measures of Fit ---------------------------------------------------------
# and model comparisons

anova(fit_meas, fit_meas_eq_load, fit_struct_eq_load)
bayestestR::bayesfactor_models(fit_meas_eq_load, fit_struct_eq_load,
                               denominator = fit_meas)
# Good? Bad?

fitMeasures(fit_meas_eq_load, output = "matrix",
            fit.measures = c("nfi","nnfi","tli", "cfi","rmsea"), 
            baseline.model = fit_meas)

fitMeasures(fit_struct_eq_load, output = "matrix",
            fit.measures = c("nfi","nnfi","tli", "cfi","rmsea"), 
            baseline.model = fit_meas_eq_load)

# Modification Indices ----------------------------------------------------


# We can look at modification indices (mi):
modificationIndices(fit_meas, sort. = TRUE, maximum.number = 5)
modificationIndices(fit_meas, sort. = TRUE, minimum.value = 10)
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

# 1. Create a measurment model with the big 5 latent variables, age, and gender.
#    - Explore the MIs. Is there anything you should add? Does it make sense?
# 2. Create 2 structural models of your choice with the big5, age and gender.
#    - Compare them (sig [make sure they are nested], BF).
#    - Compare their measures of fit.
# 3. Plot one of the 3 models from 1-2.
