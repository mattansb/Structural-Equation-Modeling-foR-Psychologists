# ==== Defining a Measurement Model with Latent Variables ====


# Today we will explore the relationship between ADHD and home-environment in
# children, in a cross lagged panel design.

adhd_home_env <- read.csv("adhd_home_env.csv")
head(adhd_home_env)

# We can see that we have 4 measures taken at two time points:

# -  accept: How accepting are the parents of the child.
# - variety: How much variety of experiences is the child exposed to.
# -  acStim: (academic stimulation) How much is learning encouraged?
# These 3 make up a scale of "home-environment".
# - adhd: number of adhd symptoms.

library(lavaan)
library(tidySEM)
library(magrittr) # for the %>% 



# Step 1. Measurement Model -----------------------------------------------

# I will assume equal loadings and errors at both time points - this is called
# measurement invariance. We will meet this assumption again in a later lesson.

mod_meas <- '
  ## latent variable definitions (CFA)
  HOME_t1 =~ b1 * accept_t1 + b2 * variety_t1 + b3 * acStim_t1
  HOME_t2 =~ b1 * accept_t2 + b2 * variety_t2 + b3 * acStim_t2
  
  ## covariances
  HOME_t1 ~~ HOME_t2 + adhd_t1 + adhd_t2
  HOME_t2 ~~ adhd_t1 + adhd_t2
  adhd_t1 ~~ adhd_t2
   
  ## errors / residuals / uniqueness
   accept_t1 ~~ e1 * accept_t1
   accept_t2 ~~ e1 * accept_t2
  variety_t1 ~~ e2 * variety_t1
  variety_t2 ~~ e2 * variety_t2
   acStim_t1 ~~ e3 * acStim_t1
   acStim_t2 ~~ e3 * acStim_t2
   
  ## autocorrelations
   accept_t1 ~~ accept_t2
  variety_t1 ~~ variety_t2
   acStim_t1 ~~ acStim_t2
  
  ## self-regression (do not forget!)
  adhd_t1 ~ 1 * adhd_t1
  adhd_t2 ~ 1 * adhd_t2
'

fit_meas <- cfa(mod_meas, data = adhd_home_env)



lay <- get_layout(
  "accept_t1", "variety_t1", "acStim_t1", NA, "accept_t2", "variety_t2", "acStim_t2",
  NA,          "HOME_t1",    NA,          NA, NA,          "HOME_t2",    NA,
  NA,          "adhd_t1",    NA,          NA, NA,          "adhd_t2",    NA,
  rows = 3
)

prepare_graph(fit_meas, layout = lay, angle = 90) %>%
  edit_edges({label = est_sig_std}) %>%
  plot()

summary(fit_meas, standardize = TRUE)

# Why are the loadings not equal??
# Because we fixed them on the raw scale, not on the standardized scale.






## Asses model fit ------------

# A. Deviation from true cov-matrix:
anova(fit_meas)
# What does this mean?

# B. Measures of fit:
fitMeasures(fit_meas, output = "text",
            fit.measures = c("nfi", "nnfi", "tli", "cfi", "gfi", "rmsea"))


# C. Reliability of factors













# Step 2. Structural Model ------------------------------------------------


# Finally! Let's estimate some causal effects!


mod_struct <- '
  ## latent variable definitions (CFA)
  HOME_t1 =~ b1 * accept_t1 + b2 * variety_t1 + b3 * acStim_t1
  HOME_t2 =~ b1 * accept_t2 + b2 * variety_t2 + b3 * acStim_t2
  
  ## regression
  HOME_t2 ~ HOME_t1 + adhd_t1
  adhd_t2 ~ adhd_t1 + HOME_t1
  
  ## covariances
  HOME_t1 ~~ adhd_t1
  HOME_t2 ~~ adhd_t2
  
  ## errors / residuals / uniqueness
   accept_t1 ~~ e1 * accept_t1
   accept_t2 ~~ e1 * accept_t2
  variety_t1 ~~ e2 * variety_t1
  variety_t2 ~~ e2 * variety_t2
   acStim_t1 ~~ e3 * acStim_t1
   acStim_t2 ~~ e3 * acStim_t2
  
  ## autocorrelations
   accept_t1 ~~ accept_t2
  variety_t1 ~~ variety_t2
   acStim_t1 ~~ acStim_t2
  
  ## self-regression
  adhd_t1 ~ 1 * adhd_t1
  adhd_t2 ~ 1 * adhd_t2
'
# What does this model imply?
# Remember, causality is always *implied*, never tested!
# https://threadreaderapp.com/thread/1073313224446009345.html


# We will use the `sem()` function now:
fit_struct <- sem(mod_struct, data = adhd_home_env)

prepare_graph(fit_struct, layout = lay, angle = 90) %>%
  edit_edges({label = est_sig_std}) %>%
  edit_edges({label_location = .2}) %>%
  plot()



# We can compare this to our measurment model - what do expect to find here?
anova(fit_struct, fit_meas)













# Step 2b. Constraining and Unconstraining --------------------------------

# This is where the magic happens!
# AKA hypothesis testing!


## Hypothesis 1: fix a parameter to 0 --------------------
# No covariance between HOME and adhd at time 2.


# We can test this hypothesis by removing the covariance from the model - but it
# is always better (and safer) to instead FIX it to 0.


mod_structH1 <- '
  ## latent variable definitions (CFA)
  HOME_t1 =~ b1 * accept_t1 + b2 * variety_t1 + b3 * acStim_t1
  HOME_t2 =~ b1 * accept_t2 + b2 * variety_t2 + b3 * acStim_t2
  
  ## regression
  HOME_t2 ~ HOME_t1 + adhd_t1
  adhd_t2 ~ adhd_t1 + HOME_t1
  
  ## covariances
  HOME_t1 ~~ adhd_t1
  HOME_t2 ~~ 0 * adhd_t2 # <<<<<<<<<<<<<
  
  ## errors / residuals / uniqueness
   accept_t1 ~~ e1 * accept_t1
   accept_t2 ~~ e1 * accept_t2
  variety_t1 ~~ e2 * variety_t1
  variety_t2 ~~ e2 * variety_t2
   acStim_t1 ~~ e3 * acStim_t1
   acStim_t2 ~~ e3 * acStim_t2
  
  ## autocorrelations
   accept_t1 ~~ accept_t2
  variety_t1 ~~ variety_t2
   acStim_t1 ~~ acStim_t2
  
  ## self-regression
  adhd_t1 ~ 1 * adhd_t1
  adhd_t2 ~ 1 * adhd_t2
'
# What does this model imply?


fit_structH1 <- sem(mod_structH1, data = adhd_home_env)

prepare_graph(fit_structH1, layout = lay, angle = 90) %>%
  edit_edges({label = est_sig_std}) %>%
  edit_edges({label_location = .2}) %>%
  plot()

summary(fit_structH1, standardize = TRUE)


fitMeasures(fit_structH1, output = "text",
            fit.measures = c("nfi", "nnfi", "tli", "cfi", "gfi", "rmsea"))


anova(fit_structH1, fit_struct)
# Significance here means that the more restricted model has a (significantly)
# worse fit than the less restricted model.
# So which model should we choose?
# The less restricted one (but see note in lesson about large samples). If the
# results were not significant, we should prefer the parsimonious model (the
# more restricted model).
#
# (Note that the when the models are nested, the model with more DF will always
# also have a larger Chisq.)

bayestestR::bayesfactor_models(fit_structH1, denominator = fit_struct)
# Bayes factors can also be used to compare non-nested models...
# (You can also fit a true Bayesian lavaan model with the `blavaan` package).











## Hypothesis 2: fix parameters to each other ------------
# Cross effects are equal



# We will be building on the H1 model:
mod_structH2 <- '
  ## latent variable definitions (CFA)
  HOME_t1 =~ b1 * accept_t1 + b2 * variety_t1 + b3 * acStim_t1
  HOME_t2 =~ b1 * accept_t2 + b2 * variety_t2 + b3 * acStim_t2
  
  ## regression
  HOME_t2 ~ HOME_t1 + cross * adhd_t1 # <<<<<<<<<<
  adhd_t2 ~ adhd_t1 + cross * HOME_t1 # <<<<<<<<<<
  
  ## covariances
  HOME_t1 ~~ adhd_t1
  HOME_t2 ~~ 0 * adhd_t2
  
  ## errors / residuals / uniqueness
   accept_t1 ~~ e1 * accept_t1
   accept_t2 ~~ e1 * accept_t2
  variety_t1 ~~ e2 * variety_t1
  variety_t2 ~~ e2 * variety_t2
   acStim_t1 ~~ e3 * acStim_t1
   acStim_t2 ~~ e3 * acStim_t2
  
  ## autocorrelations
   accept_t1 ~~ accept_t2
  variety_t1 ~~ variety_t2
   acStim_t1 ~~ acStim_t2
  
  ## self-regression
  adhd_t1 ~ 1 * adhd_t1
  adhd_t2 ~ 1 * adhd_t2
'
# What does this model imply?


fit_structH2 <- sem(mod_structH2, data = adhd_home_env)

prepare_graph(fit_structH2, layout = lay, angle = 90) %>%
  edit_edges({label = est_sig_std}) %>%
  edit_edges({label_location = .2}) %>%
  plot()



fitMeasures(fit_structH2, output = "text",
            fit.measures = c("nfi", "nnfi", "tli", "cfi", "gfi", "rmsea"))

# Which model is preferred? What do each of these mean?
anova(fit_structH2)
anova(fit_structH2, fit_structH1)
bayestestR::bayesfactor_models(fit_structH2, denominator = fit_structH1)











# Exercise ----------------------------------------------------------------

# The actor–partner interdependence model (APIM) has a similar technical setup
# to CLPM. 

partner_fatigue <- read.csv("partner_fatigue.csv")

head(partner_fatigue)
# fatigue: Emotional fatigue
# anxiety: State anxiety
# As measured in heterosexual partners (Males and Females)


# 1. Look at "partner_fatigue.png".
#   - What does the model imply, causally?
#   - Is the model saturated (aka. just identified)?
# 2. Prof. Geller hypothesizes that women do more emotional work, and so are
#   more fatigued by their partners anxiety compared to how men are affected.
#   A. Test this hypothesis by comparing the relevant paths.
#   B. Test this hypothesis by adding / removing a model constraint (what is the
#     opposite of Prof. Geller's hypothesis?)
#     - Asses model fit.
#     - Compare to an unconstrained model. Is the hypothesis supported?
# 3. Plot the model.
