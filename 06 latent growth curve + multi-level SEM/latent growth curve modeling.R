
# Latent growth curve modeling is a statistical technique used in the SEM
# framework to estimate growth trajectories.
# 
# This model allows the representing of change in repeated measures of a
# dependent variable as a function of:
#   1. Time
#   2. Other measures
# As well as estimate how changes over time are themselves a function of other
# measures.
# 
# To do this we will estimate two latent variables - one representing individual
# differences in the linear change over time (the "slope") and one representing
# the individual differences overall, regardless of time (the "intercept").

intimacy_depression <- read.csv("intimacy_depression.csv")
head(intimacy_depression)

# Lets see how depression changes over time, and how anxiety, verbal IQ, and
# relationship intimacy are related.

library(lavaan)
library(tidySEM)


# 1. Fit the latent growth curve ------------------------------------------

LGCM <- '
  # intercept and slope with ***fixed coefficients***
  intercept =~ 1*depression_t1 + 1*depression_t2 + 1*depression_t3 + 1*depression_t4
      slope =~ 0*depression_t1 + 1*depression_t2 + 2*depression_t3 + 3*depression_t4
'
# typically we would also add here all the covariances with all the variables of
# interest...

fit_LGC <- growth(LGCM, data = intimacy_depression,
                  std.lv = TRUE)

summary(fit_LGC, standardize = TRUE)
# Note: The intercept of slope is significant, suggesting that over all there is
# an effect for time.


lay <- get_layout(
  "depression_t1", "depression_t2", "depression_t3", "depression_t4",
  NA,              "intercept",     "slope",         NA,
  rows = 2
)


graph_sem(fit_LGC, 
          edges = get_edges(fit_LGC, label = "est_std"),
          layout = lay)



# The values in the variables are their mean (raw) values. We can change this by
# setting:
graph_sem(fit_LGC, 
          edges = get_edges(fit_LGC, label = "est_std"),
          nodes = get_nodes(fit_LGC, label = "name"),
          layout = lay)



# 2. Model the curve ------------------------------------------------------

LGCM_S <- '
  # intercept and slope with ***fixed coefficients***
  intercept =~ 1*depression_t1 + 1*depression_t2 + 1*depression_t3 + 1*depression_t4
      slope =~ 0*depression_t1 + 1*depression_t2 + 2*depression_t3 + 3*depression_t4


  # regressions: how are other measures related to the latent structure?
  intercept ~ anxiety + verbal_IQ
      slope ~ anxiety + verbal_IQ
      
      
  # time-varying covariates (at each time point)
  depression_t1 ~~ intimacy_t1
  depression_t2 ~~ intimacy_t2
  depression_t3 ~~ intimacy_t3
  depression_t4 ~~ intimacy_t4
'

fit_LGC_S <- growth(LGCM_S, data = intimacy_depression, 
                    std.lv = TRUE)

summary(fit_LGC_S, standardize = TRUE)




lay <- get_layout(
  "intimacy_t1",   "intimacy_t2",   "intimacy_t3",   "intimacy_t4",
  "depression_t1", "depression_t2", "depression_t3", "depression_t4",
  NA,              "intercept",     "slope",         NA,
  "anxiety",       NA,              NA,              "verbal_IQ",
  rows = 4
)


graph_sem(fit_LGC_S, 
          edges = get_edges(fit_LGC_S, label = "est_sig"),
          nodes = get_nodes(fit_LGC_S, label = "name"),
          layout = lay)

