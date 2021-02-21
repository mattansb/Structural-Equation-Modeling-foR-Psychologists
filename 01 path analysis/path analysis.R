
# We will be using a simple mediation model to demonstrate the principals of
# path analysis.

income_psych <- read.csv("income_psych.csv")

head(income_psych)

# Our question:
# Does negative mood mediate the relationship between anxiety and income?
# Graphically, it looks like "plot1.png"





# Manual path analysis ----------------------------------------------------

m1 <- lm(income ~ anxiety + mood_neg, income_psych)
m2 <- lm(mood_neg ~ anxiety, income_psych)

# We can "build" the paths by multiplying the correct coefficiants:
(coef1 <- coef(m1))
(coef2 <- coef(m2))

direct <- unname(coef1['anxiety'])
indirect <- unname(coef1['mood_neg'] * coef2['anxiety'])

(mediation_by_hand <- c(direct = direct,
                        indirect = indirect,
                        total = direct + indirect))

# Is the total correct?
lm(income ~ anxiety, data = income_psych)





# With lavaan -------------------------------------------------------------

# lets do this with `lavaan`!

library(lavaan)

# model specification are written as a multi-line character:
mediation_model <- '
  mood_neg ~ anxiety
    income ~ anxiety + mood_neg
'

# fit the model to the data:
fit <- sem(mediation_model, data = income_psych)


## Model summary
summary(fit) # get estimates + tests statistics
# Note that by DEFAULT, lavaan estimates all residual errors.
# (why is the Test Statistic 0?)

summary(fit, standardize = TRUE) # look at Std.all for beta
summary(fit, rsquare = TRUE) # See regression R2



## Confidence intervals:
parameterestimates(fit, ci = TRUE, output = "text") # ci for the raw estimates
standardizedSolution(fit, ci = TRUE, output = "text") # ci for the std estimates
# Note that the tests from these 2 functions CAN BE DIFFERENT. Why?


## Bootstrap
fit_with_boot <- sem(mediation_model, data = income_psych,
                     se = "bootstrap", bootstrap = 200)
summary(fit_with_boot, standardize = TRUE)






## Modifiers! ------------

# - We can mark parameters with a "stand-ins" followed by "*" - these stand-ins
#   are called *modifiers*.
# - We can have lavaan compute different estimates with ":="
#
# This allows up to estimate paths in lavaan:

mediation_model <- '
  # regressions
  mood_neg ~ a * anxiety
    income ~ b * mood_neg + c * anxiety
  

  # effects
    direct := c
  indirect := a * b
     total := direct + indirect
'
fit <- sem(mediation_model, data = income_psych)


summary(fit, standardize = TRUE) # look at "Defined Parameters" 
mediation_by_hand
cor(income_psych$anxiety, income_psych$income)






## Compare paths --------

# With the ":=" operator, we can estimate many things!
# E.g., we can compare paths:


mediation_model <- '
  # regressions
  mood_neg ~ a * anxiety
    income ~ b * mood_neg + c * anxiety
  

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









## Plotting --------

library(tidySEM)

graph_sem(fit)
graph_sem(fit, label = "est")
graph_sem(fit, label = "est_std")


# See also advanced plotting.R





# Exercise ----------------------------------------------------------------

# 1. Look at the plot in "plot2.png". 
#   - Explain the causal relationship in this model (in words).
#   - Fit this model with `lavaan`.
# 2. Compute all the paths in this model from *anxiety* to *income*, and 
#    the total of these paths.
# 3. Why is the std total not *equal* exactly to the real correlation?
#   - Is it very different? What does this mean?
# 4. Compute the difference between the two indirect paths. 
#   - How big is it? Is it significant?

