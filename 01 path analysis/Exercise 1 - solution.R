# Exercise ----------------------------------------------------------------

income_psych <- read.csv("income_psych.csv")
library(lavaan)

## 1. Look at the plot in "plot2.png". Fit this model with `lavaan`.

model <- "
# We need to build a regression equation for each endogenous variable:
 anxiety ~ shyness
mood_neg ~ anxiety
  income ~ anxiety + mood_neg + shyness
"

fit <- sem(model, data = income_psych)
summary(fit, standardize = TRUE)


library(semPlot)
semPaths(fit)
# See `advanced plotting` for making "plot2.png"






## 2. Compute all the paths in this model from *anxiety* to *income*, and 
##    the total of these paths.
model <- "
 anxiety ~ a * shyness
mood_neg ~ b * anxiety
  income ~ c * anxiety + d * mood_neg + e * shyness
  
  # Define paths:
       direct := c
  ind_shyness := a * e
     ind_mood := b * d
        total := direct + ind_shyness + ind_mood
"

fit <- sem(model, data = income_psych)
summary(fit, standardize = TRUE)
# Seems like the total path is not significant.
# Looks like a case of supression... Some paths are +, some are -...
# They LOOK like they cancel each other out!

# However...
# The total is significant in the standerdized solution!!
standardizedsolution(fit, output = "text")

## - Why is the std total not equal exactly to the real correlation?
cor(income_psych$anxiety, income_psych$income)
# Theres a diff of (-0.001). Because the model isn't *just-identified*.
# We are missing the arrow from `shyness` to `mood_neg`.


## - is it very different?
# The diff is of (-0.001). Is this a lot? Is it significant?
# We will see next time how to answer these questions!
