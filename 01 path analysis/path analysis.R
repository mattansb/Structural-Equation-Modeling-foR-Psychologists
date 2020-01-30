
income_psych <- read.csv("income_psych.csv")
head(income_psych)

# Testing mediation:
# Does negative mood mediate the relationship between anxiety and income?

# Manual path analysis ----------------------------------------------------

m1 <- lm(income ~ anxiety + mood_neg, income_psych)
m2 <- lm(mood_neg ~ anxiety, income_psych)

(coef1 <- parameters::model_parameters(m1, standardize = "basic"))
(coef2 <- parameters::model_parameters(m2, standardize = "basic"))

direct <- coef1$Std_Coefficient[2]
indirect <- coef1$Std_Coefficient[3] * coef2$Std_Coefficient[2]

mediation_by_hand <- c(direct = direct,
                       indirect = indirect,
                       total = direct + indirect)
mediation_by_hand
cor(income_psych$anxiety, income_psych$income)



# With lavaan -------------------------------------------------------------

# lets do this with `lavaan`!

library(lavaan)

# modelss are written as a multi-line charachter object:
mediation_model <- '
    income ~ anxiety + mood_neg
  mood_neg ~ anxiety
'

# fit the model to the data:
fit <- sem(mediation_model, data = income_psych)

summary(fit)
summary(fit, standardize = TRUE) # look at Std.all for beta
# Note that by default, lavaan estimates all residual errors.


# Modifiers! --------------------------------------------------------------

# how to compute the paths? With *modifiers*!
# - We can mark parameters with a "stand-ins" followed by "*"
# - We can have lavaan compute effects with ":="
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

summary(fit, standardize = TRUE)
mediation_by_hand

## Confidence intervals:
summary(fit, standardize = TRUE, ci = TRUE) # ci for the raw estimates
standardizedSolution(fit, ci = TRUE) # ci for the std estimates

## Bootstrap
fit_with_boot <- sem(mediation_model, data = income_psych,
                     se = "bootstrap", bootstrap = 200)
summary(fit_with_boot, standardize = TRUE)


# Plotting ----------------------------------------------------------------

library(semPlot)
# very (too?) customisable:
semPaths(fit, whatLabels = "est", normalize = FALSE)
semPaths(fit, whatLabels = "std", normalize = FALSE)
semPaths(fit, whatLabels = "std", normalize = FALSE, style = "lisrel")


library(lavaanPlot)
# pretty out of the box, but very BUGGY!
lavaanPlot(model = fit)
lavaanPlot(model = fit, coefs = TRUE)


# other solutions: https://github.com/mattansb/tidylavaan


# Exercise ----------------------------------------------------------------

# 1. Look at the plot in "path_model.png". Fit this model with `lavaan`.
# 2. Compute all the paths in this model from anxiety to income, and 
#    the total of these paths.
#    - Why is the std total not equal exactly to the real correlation?
#    - is it very different?

