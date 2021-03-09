
# We will be using a simple mediation model to demonstrate the principals of
# path analysis.

income_psych <- read.csv("income_psych.csv")

head(income_psych)

# Our question:
# Does negative mood mediate the relationship between anxiety and income?
# Graphically, it looks like "plot1.png"





# Manual path analysis ----------------------------------------------------

m1 <- lm(income ~ anxiety + neg_mood, income_psych)
m2 <- lm(neg_mood ~ anxiety, income_psych)

# We can "build" the paths by multiplying the correct coefficiants:
(coef1 <- coef(m1))
(coef2 <- coef(m2))

direct <- unname(coef1['anxiety'])
indirect <- unname(coef1['neg_mood'] * coef2['anxiety'])

(mediation_by_hand <- c(direct = direct,
                        indirect = indirect,
                        total = direct + indirect))

# Is the total correct?
lm(income ~ anxiety, data = income_psych)






# Using lavaan ------------------------------------------------------------

# lets do this with `lavaan`!

library(lavaan)

# model specification are written as a multi-line character:
mediation_model <- '
  neg_mood ~ anxiety
    income ~ anxiety + neg_mood
'

# fit the model to the data:
fit <- sem(mediation_model, data = income_psych)


## Model summary ----
summary(fit) # get estimates + tests statistics
# Note that by DEFAULT, lavaan estimates all residual errors.



## Effect Sizes ----
summary(fit, standardize = TRUE) # look at Std.all for beta
lavInspect(fit, what = "rsquare") # See regression R2


## Confidence intervals ----
parameterEstimates(fit, ci = TRUE, output = "text") # ci for the raw estimates
standardizedSolution(fit, ci = TRUE, output = "text") # ci for the std estimates
# Note that the tests from these 2 functions CAN BE DIFFERENT (see the
# z-values). Why?


## Bootstrap ----
fit_with_boot <- sem(mediation_model, data = income_psych,
                     se = "bootstrap", bootstrap = 200)
summary(fit_with_boot, standardize = TRUE)







# Using Modifiers! --------------------------------------------------------

# - We can mark parameters with a "stand-ins" followed by "*" - these stand-ins
#   are called *modifiers*.
# - We can have lavaan compute different estimates with ":="
#
# This allows up to estimate paths in lavaan:

mediation_model <- '
  # regressions
  neg_mood ~ a * anxiety
    income ~ b * neg_mood + c * anxiety
  

  # effects
    direct := c
  indirect := a * b
     total := direct + indirect
'
fit <- sem(mediation_model, data = income_psych)


summary(fit, standardize = TRUE) # look at "Defined Parameters" 
mediation_by_hand
cor(income_psych$anxiety, income_psych$income)






## Comparing paths --------

# With the ":=" operator, we can estimate many things!
# E.g., we can compare paths:


mediation_model <- '
  # regressions
  neg_mood ~ a * anxiety
    income ~ b * neg_mood + c * anxiety
  

  # effects
     direct := c
   indirect := a * b
      total := direct + indirect
      
  path_diff := direct - indirect
'

fit <- sem(mediation_model, data = income_psych)

# look at "Defined Parameters" 
parameterEstimates(fit, output = "text") # summary gives these test values
standardizedSolution(fit, output = "text")





fit <- sem(mediation_model, data = income_psych,
           likelihood = "wishart")
# likelihood = "wishart" used an unbiased cov-matrix, and gives
# similar results to AMOS (SPSS).
# In large samples this hardly has any effects...
# Read more about the various likelihoods and estimators:
# http://lavaan.ugent.be/tutorial/est.html










# Plotting ----------------------------------------------------------------

library(tidySEM)

graph_sem(fit)
graph_sem(fit, edges = get_edges(fit, label = "est_std"))


# See also advanced plotting.R





# Exercise ----------------------------------------------------------------

# 1. Look at the plot in "plot2.png". 
#   - Explain the implied causal relationship in this model (in words).
#   - Fit this model with `lavaan` (one regression for each endogenous
#     variable).
#   - Plot the model.
# 2. Estimate:
#   - Each of the paths in this model from *anxiety* to *income*.
#   - The total of these paths.
#   - The difference between the two indirect paths.
#   Explain your findings.
# 3. Why is the std total NOT equal *exactly exactly* to the real correlation
#   (-0.072 vs -0.071)? 
#   - Is it very different? What does this mean?

