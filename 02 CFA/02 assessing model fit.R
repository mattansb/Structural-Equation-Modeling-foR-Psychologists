

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

mod_meas <- '
  ## latent variable definitions (CFA)
  HOME_t1 =~ accept_t1 + variety_t1 + acStim_t1
  HOME_t2 =~ accept_t2 + variety_t2 + acStim_t2
  
  ## covariances
  HOME_t1 ~~ HOME_t2 + adhd_t1 + adhd_t2
  HOME_t2 ~~ adhd_t1 + adhd_t2
  adhd_t1 ~~ adhd_t2
  
  ## self-regression
  # Do not forget these! Or you WILL HAVE A BAD TIME!
  adhd_t1 ~ 1 * adhd_t1
  adhd_t2 ~ 1 * adhd_t2
'

fit_meas <- cfa(mod_meas, data = adhd_home_env)






# Measures of Fit ---------------------------------------------------------



## Measures of fit
fitMeasures(fit_meas, output = "text",
            fit.measures = c("nfi", "nnfi", "tli", "cfi", 
                             "gfi", "rmsea"))
# What we want:
# Relative to the worst possible model:
#     NFI > 0.9
#    NNFI > 0.9
#     TLI > 0.9
#     CFI > 0.9
# Absolute measures of fit:
#     GFI > 0.95
#   RMSEA < 0.08
#
# But also some suggest no using these strict rules of thumb... See:
# https://dynamicfit.app/cfa/ from https://doi.org/10.31234/osf.io/v8yru


# The model isn't looking too great...


fitMeasures(fit_meas, output = "text",
            fit.measures = c(
              "chisq", "df","pvalue",
              "baseline.chisq","baseline.df","baseline.pvalue"
            ))

# We can also just use the anova() function:
anova(fit_meas)



# - The "baseline" model is the null /"independence" model, which constraints
#   all parameters / covariances to zero, AKA the worst possible model!
# - The "Saturated" model is the model where none of the parameters /
#   covariances to 0, AKA the best possible model!





#      ======================== REMEMBER =============================
#    ||                                                               ||
#    ||               Good fit != model is correct!                   ||
#    ||                                                               ||
#    || In fact, many different models can have the same (good) fit!  ||
#    || See "Appendix - model equivalence" for an example.            ||
#      ===============================================================







# Modification Indices ----------------------------------------------------




# We can look at modification indices (mi):
modificationIndices(fit_meas, sort. = TRUE, maximum.number = 5)
modificationIndices(fit_meas, sort. = TRUE, minimum.value = 10)
# What should we do? What did we forget??









# Exercise ----------------------------------------------------------------


# 1. Refit the model with the missing auto-correlations.
# 2. How has the factor definition improved ?
#   - Are the loadings better?
#   - How about the reliability?
#   - How about the measures of fit?
