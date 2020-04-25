
dep_anx_CL <- read.csv("dep_anx_CL.csv")

# Depression (BDI) and anxiety (BAI) were measured at 2 times points. Does one
# predict the other over time?
# We will test this with a cross-lag model:

library(lavaan)
cl_model <- "
  # Regression
  BAI_t2 ~ BAI_t1 + cross1 * DBI_t1
  DBI_t2 ~ DBI_t1 + cross2 * BAI_t1

  # Covariances
  BAI_t1 ~~ t1cov * DBI_t1
"

fit <- sem(cl_model, dep_anx_CL)

summary(fit, standardize = TRUE)
# (Note that by default lavaan estimates covariance between residuals of
# endogenous variables.)



library(semPlot)
semPaths(fit, what = "std", whatLabels = "std", 
         residuals = TRUE, intercepts = FALSE,
         rotation = 2,
         # prettify
         fade = FALSE,
         style = "lisrel", normalize = TRUE, 
         sizeMan = 11, sizeMan2 = 7,
         sizeLat = 11, sizeLat2 = 7,
         nCharNodes = 50,
         edge.label.cex = 1,
         edge.label.bg = FALSE, edge.label.color = "black",
         edge.label.position = 0.45)


# The CL path from depression to anxiety is significantly different from 0, but
# the CL path from anxiety to depression is not. What can we infer from this?
# Are they different?
#
# The difference between significant and not significant, is not itself
# significant! Also, we cannot accept the null just because the reault is not
# significant...
# Let's look at two ways we can test this questions...



# Compare paths -----------------------------------------------------------

# We can test directly which cross-lagged effect is larger:

cl_model <- "
  # Regression
  BAI_t2 ~ BAI_t1 + cross1 * DBI_t1
  DBI_t2 ~ DBI_t1 + cross2 * BAI_t1

  # Covariances
  BAI_t1 ~~ t1cov * DBI_t1
  BAI_t2 ~~ t2cov * DBI_t2
  
  # Test
  CL_diff := cross1 - cross2
"

fit <- sem(cl_model, dep_anx_CL)

# look at "Defined Parameters" 
parameterEstimates(fit, output = "text") # for the raw diff
standardizedSolution(fit, output = "text") # for the std diff

# The CL paths ARE significantly different from each other!




# Fixing parameters -------------------------------------------------------

# the residual covariance at t2 looks weak. We can fix it to 0,
# and compare the models: 
#   M1 - t2cov is a free parameter
#   M2 - t2cov is 0

cl_model2 <- "
  # Regression
  BAI_t2 ~ BAI_t1 + cross1 * DBI_t1
  DBI_t2 ~ DBI_t1 + cross2 * BAI_t1

  # Covariances
  BAI_t1 ~~ t1cov * DBI_t1
  BAI_t2 ~~ t2cov * DBI_t2
  
  t2cov == 0 # fix it to 0
"

# or:

cl_model2 <- "
  # Regression
  BAI_t2 ~ BAI_t1 + cross1 * DBI_t1
  DBI_t2 ~ DBI_t1 + cross2 * BAI_t1

  # Covariances
  BAI_t1 ~~ t1cov * DBI_t1
  BAI_t2 ~~ 0 * DBI_t2 # fix to 0
"

fit2 <- sem(cl_model2, dep_anx_CL)
summary(fit2, standardize = TRUE)


anova(fit, fit2) # what does this mean?
bayestestR::bayesfactor_models(fit, fit2) # what does THIS mean?


anova(fit2)
anova(fit, fit2) # why are these the same??



# Advanced Parameter Fixing  ----------------------------------------------

## 1. We can also fix parameters to other values:
cl_model3 <- "
  # Regression
  BAI_t2 ~ BAI_t1 + cross1 * DBI_t1
  DBI_t2 ~ DBI_t1 + cross2 * BAI_t1

  # Covariances
  BAI_t1 ~~ t1cov * DBI_t1
  BAI_t2 ~~ 0.3 * DBI_t2 # fixed
"

fit3 <- sem(cl_model3, dep_anx_CL)

anova(fit, fit3) # surprising?
# Not that I fixed the value to 0.3 only because I saw that value on the plot.
# This is p-hacking and poct-hoc HARKing at the same time - DON'T DO THAT!





## 2. We can also fix parameters to each other:
cl_model4 <- "
  # Regression
  BAI_t2 ~ BAI_t1 + cross * DBI_t1
  DBI_t2 ~ DBI_t1 + cross * BAI_t1 # fixed

  # Covariances
  BAI_t1 ~~ t1cov * DBI_t1
  BAI_t2 ~~ t2cov * DBI_t2
"
# What do this ^ model imply?


fit4 <- sem(cl_model4, dep_anx_CL)

# Note that when fixing, we are fixing on the UNSTANDARDIZED (raw) scale!
# Compare:
parameterEstimates(fit4, output = "text")
standardizedSolution(fit4, output = "text")





# We can get close to fixing parameters on the standerdized sacles by setting
# `std.ov = TRUE`:
fit4_std <- sem(cl_model4, dep_anx_CL, std.ov = TRUE)
standardizedSolution(fit4_std, output = "text")
# this is imperfect (but pretty close!)




# Exercise ----------------------------------------------------------------

# 1. Build a model (fit5) where the BAI_t1 to DBI_t2 cross path is fixed to 0.
#    - How do you expect this model to compare to the unconstrined model?
#    - Test your (post-hoc) hypothesis.
# 2. Build a model (fit6) where BAI_t2 has no residual variance.
#    - What does this model imply?? Is this plausible?
#    - How does this compare to the unconstrined model?
