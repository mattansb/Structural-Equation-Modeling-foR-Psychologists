
# Latent growth curve modeling is a statistical technique used in the SEM
# framework to estimate growth trajectories.
# 
# This model allows the represention of change in repeated measures of a
# dependent variable as a function of:
#   1. Time
#   2. Other measures
# As well as estimate how changes over time are themselves a function of other
# measures.
# 
# To do this we will estimate two latent variables - one representing indevidual
# differences in the linear change over time (the "slope") and one representing
# the indevidual differences overall, regardless of time (the "intercept").

intimacy_depression <- read.csv("intimacy_depression.csv")

# Lets see how depression changes over time, and how anxiety, verbal IQ, and
# relationship intimacy are related.


# 1. Fit the latent growth curve ------------------------------------------

library(lavaan)

LGCM <- '
  # intercept and slope with ***fixed coefficients***
  intercept =~ 1*depression_t1 + 1*depression_t2 + 1*depression_t3 + 1*depression_t4
      slope =~ 0*depression_t1 + 1*depression_t2 + 2*depression_t3 + 3*depression_t4
'
# typically we would also add here all the covariances with all the variables of
# intrest...

fit_LGC <- growth(LGCM, data = intimacy_depression,
                  std.lv = TRUE)

summary(fit_LGC, standardize = TRUE)
# Note: The intercept of slope is significant, suggesting that over all there is
# an effect for time.

library(semPlot)

semPaths(fit_LGC, what = "std", whatLabels = "std", 
         residuals = TRUE, intercepts = FALSE,
         # prettify
         fade = FALSE,
         style = "lisrel", normalize = TRUE, 
         sizeMan = 15, sizeMan2 = 7,
         sizeLat = 15, sizeLat2 = 7,
         nCharNodes = 50,
         edge.label.cex = 1.3,
         edge.label.bg = FALSE, edge.label.color = "black",
         edge.label.position = 0.45)





# 2. Model the curve ------------------------------------------------------

LGCM_S <- '
  # intercept and slope with ***fixed coefficients***
  intercept =~ 1*depression_t1 + 1*depression_t2 + 1*depression_t3 + 1*depression_t4
      slope =~ 0*depression_t1 + 1*depression_t2 + 2*depression_t3 + 3*depression_t4


  # regressions: how are other measures related to the latent structure?
  intercept ~ anxiety + verbal_IQ
      slope ~ anxiety + verbal_IQ
      
      
  # time-varying covariates (at each time point)
  depression_t1 ~ intimacy_t1
  depression_t2 ~ intimacy_t2
  depression_t3 ~ intimacy_t3
  depression_t4 ~ intimacy_t4
'

fit_LGC_S <- growth(LGCM_S, data = intimacy_depression, 
                    std.lv = TRUE)

summary(fit_LGC_S, standardize = TRUE)

semPaths(fit_LGC_S, whatLabels = "std", 
         residuals = TRUE, intercepts = FALSE, exoCov = FALSE,
         # prettify
         fade = FALSE,
         style = "lisrel", normalize = TRUE, 
         sizeMan = 13, sizeMan2 = 7,
         sizeLat = 11, sizeLat2 = 7,
         nCharNodes = 50,
         edge.label.cex = 1,
         edge.label.bg = FALSE, edge.label.color = "black",
         edge.label.position = 0.45)



# Multi-level models ------------------------------------------------------

# Of intrest are also multi-level models (MLM, aka HLM / LMM). This are 
# quite dificult and have only limited support:
# http://lavaan.ugent.be/tutorial/multilevel.html
