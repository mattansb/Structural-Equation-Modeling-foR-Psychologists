
#' Today we will explore the relationship between ADHD, IQ, and anxiety
#' and their effects on sustained attention and inhibition

adhd_anx <- read.csv("adhd_anx.csv")
head(adhd_anx)




# 1. measurement model ----------------------------------------------------

library(lavaan)

mod_meas <- '
  ## latent variable definitions (CFA)
  # The "=~" can be read as "is identified by"
  ADHD =~ adhd1 + adhd2 + adhd3
    IQ =~ iq1 + iq2
   ANX =~ anx1 + anx2 + anx3 
  
  ## covariances
  sustained_attn ~~ inhibition + ADHD + IQ + ANX
      inhibition ~~ ADHD + IQ + ANX
      
  
  ## self-regression
  # We need to define one of the observed vars (this is a silly bug).
  # This does not affect the model fit!
  sustained_attn ~ 1 * sustained_attn
      inhibition ~ 1 * inhibition
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
         edge.label.position = 0.6)


summary(fit_meas, standardize = TRUE)
# why is there no test for ADHD =~ adhd1?

parameterEstimates(fit_meas, output = "text")
standardizedSolution(fit_meas, output = "text")
# By DEFAULT (1) the cov between latent vars is estimated!
# By DEFAULT (2) the factor loading of the first indicator of a latent
# variable is fixed to 1, thereby fixing the scale of the latent
# variable... Fixed parameters are not tested.





# We can also set `std.lv = TRUE` to set the scale of latent vars to 1:
fit_meas <- cfa(mod_meas, data = adhd_anx, 
                std.lv = TRUE)
summary(fit_meas, standardize = TRUE)




# we can also extract the scores of the latent variables,
# but note that these mostly only make sense WITHIN a SEM model.
# (set `append.data = TRUE` to also get the original data)
cfa_scores <- data.frame(lavPredict(fit_meas, append.data = FALSE))

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
# equal weights / loadings (which we just estimated!).
# It can be thought of as representing the variance explained across the
# indicators of each factor.
# https://doi.org/10.1037/met0000144
# read about the other indices here, and when you'd like to use them:
?semTools::reliability








# Equal loadings ----------------------------------------------------------



# If we have some prior knowlage about the structure of latent variables,
# we might consider using equal factor loading.
# To do this, we simply give all the indicators the same *modifier label*:


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
# We will learn next time how to deal with that...)








# Exercise ----------------------------------------------------------------

# 1. Set equal loadings to `ANX`'s indicators.
#      - Do you think this is a good idea?
#        TIP: look at the un-equal loadings.
# 2. Compute the reliability for equal loadings `ANX` and equal loadings
#    `ADHD`
#      - What is the Omega index conceptually equal to now? Why?
