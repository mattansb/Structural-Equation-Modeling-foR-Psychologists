
#' Today we will explore the relationship between ADHD, IQ, and anxiety
#' and their effects on sustained attention and inhibition

adhd_anx <- read.csv("adhd_anx.csv")
head(adhd_anx)

# 1. measurement model ----------------------------------------------------

library(lavaan)

mod_meas <- '
  ## latent variable definitions (CFA)
  ADHD =~ adhd1 + adhd2 + adhd3
    IQ =~ iq1 + iq2
   ANX =~ anx1 + anx2 + anx3 
  
  ## self-rgression
  sustained_attn ~ 1 * sustained_attn
      inhibition ~ 1 * inhibition
  # we need to define one of the observed variables (this is a silly bug) This does not affect the model fit!
  
  ## covariances
  sustained_attn ~~ inhibition + ADHD + IQ + ANX
      inhibition ~~ ADHD + IQ + ANX
'

fit_meas <- cfa(mod_meas, data = adhd_anx,
                likelihood = "wishart")

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
                likelihood = "wishart",
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

fit_lat_only <- cfa(mod_lat_only, data = adhd_anx,
                    likelihood = "wishart")

semTools::reliability(fit_lat_only) # see also semTools::reliabilityL2
# read about the indices here:
?semTools::reliability

# Modification Indices ----------------------------------------------------

# We can look at modification indices (mi):
modificationIndices(fit_meas, sort. = TRUE, maximum.number = 10)
# what should we do?



# Fit Measures ------------------------------------------------------------

fitMeasures(fit_meas,
            fit.measures = c("chisq", "df","pvalue",
                             "baseline.chisq","baseline.df","baseline.pvalue"))
# The "baseline" model is the null /"independence" model, which constraints
# all covariances to zero, AKA the worst model.


fitMeasures(fit_meas, output = "text",
            fit.measures = c("nfi","nnfi","tli", "cfi","rmsea"))
# What we want:
# Should Chi-sq be sig?
#        NFI > 0.9
# NNFI / TLI > 0.9
#        CFI > 0.9
#      RMSEA < 0.08

# 2. structural model -----------------------------------------------------

# When defining structural model, the important bits are
# the arrow you don't include / fix at 0!

mod_struct <- '
  ## latent variable definitions
  ADHD =~ adhd1 + adhd2 + adhd3
    IQ =~ iq1 + iq2
   ANX =~ anx1 + anx2 + anx3 
  
  ## regressions
      inhibition ~ ADHD + ANX + IQ
  sustained_attn ~ inhibition + ADHD
  
  ## covariances
  IQ ~~ ADHD
  IQ ~~ 0*ANX
'

fit_struct <- sem(mod_struct, data = adhd_anx,
                  likelihood = "wishart",
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


fitMeasures(fit_struct,
            fit.measures = c("chisq", "df","pvalue",
                             "baseline.chisq","baseline.df","baseline.pvalue"),
            baseline.model = fit_meas)
anova(fit_struct, fit_meas) # Is this good or bad?
bayestestR::bayesfactor_models(fit_struct, denominator = fit_meas)

fitMeasures(fit_struct, output = "text",
            fit.measures = c("nfi","nnfi","tli", "cfi","rmsea"), 
            baseline.model = fit_meas)


# Exercise ----------------------------------------------------------------

library(dplyr)
big5 <- psychTools::bfi %>% 
  select(A1:A5, C1:C5, E1:E5, N1:N5, O1:O5,
         gender, age) %>% 
  na.omit()

head(big5)

# 1. Create a measurment model with the big 5 latent variables, age, and gender.
#    - Explore the MIs. Is there anything you should add? Does it make sense?
# 2. Create at least 2 structural models of your choice with the big5, age and gender.
#    - Compare them (sig, BF).
#    - Compare their measures of fit.

