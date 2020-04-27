

dep_anx_CL <- read.csv("dep_anx_CL.csv")
head(dep_anx_CL)

library(lavaan)

cl_model <- "
  # Regression
  BAI_t2 ~ BAI_t1 + cross1 * DBI_t1
  DBI_t2 ~ DBI_t1 + cross2 * BAI_t1

  # Covariances
  BAI_t1 ~~ t1cov * DBI_t1
"

fit <- sem(cl_model, dep_anx_CL)

# Exercise ----------------------------------------------------------------

# Build a model (fit5) where the BAI_t1 to DBI_t2 cross path is fixed to 0.
cl_model5 <- "
  # Regression
  BAI_t2 ~ BAI_t1 + cross1 * DBI_t1
  DBI_t2 ~ DBI_t1 + 0 * BAI_t1

  # Covariances
  BAI_t1 ~~ t1cov * DBI_t1
"

fit5 <- sem(cl_model5, dep_anx_CL)



# 1. How do you expect this model to compare to the unconstrined model?
# We saw that this cross path is weak and non-significant - we would expect
# setting it 0 to not hurn the model fit.
#
# 2. Test your (post-hoc) hypothesis.
anova(fit, fit5)
# We were right! (Post hoc!)
