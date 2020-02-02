
dep_anx_CL <- read.csv("dep_anx_CL.csv")

# Depression (BDI) and anxiety (BAI) were measured at 2 times points.
# Does one predict the other over time?
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
# Note that by default lavaan estimates covariance between residuals of endogenous variables.

library(semPlot)
semPaths(fit, whatLabels = "std", style = "lisrel", 
         # what = "std", fade = F,
         edge.label.cex = 1.5, sizeMan = 15, 
         edge.label.position = 0.45, rotation = 2)


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
standardizedSolution(fit, output = "text") # foe the std diff

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

# Exercise ----------------------------------------------------------------

# Fix the BAI_1 to DBI_2 cross path to 0.
#  - How does this compare to the unconstrined model?
# Fix the DBI_1 to BAI_2 cross path to 0.
#  - How does this compare to the unconstrined model?
