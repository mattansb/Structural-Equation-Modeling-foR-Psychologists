
# Model Equivalence -------------------------------------------------------

library(lavaan)
library(tidySEM)
library(patchwork)

child_dev <- read.csv("child_dev.csv")
head(child_dev)

# We want to understand the common facotrs and effect of child development.
# Let's consider two models:


mod1 <- "
  DEVELOPMENT =~ inhibition + language + dexterity + walking

    dexterity ~~ walking
"
fit1 <- sem(mod1, data = child_dev)
# What does this model imply?
# 1. There is a single common factor to the 4 measures of development.
# 2. Additionally, there is unique covariance between dexterity & walking (both
#   motor).


mod2 <- "
  NEURAL_DEV =~ dexterity + walking
     BHV_DEV =~ inhibition + language
  
  BHV_DEV ~ NEURAL_DEV
"
fit2 <- sem(mod2, data = child_dev)
# What does this model imply?
# 1. There are two factors of development: neural and behavioral.
# 2. Neural development drives behavioral development.


p1 <- graph_sem(fit1, angle = 90, 
                edges = get_edges(fit1, label = "est_std"),
                layout = get_layout(
                  NA,           "DEVELOPMENT", NA,          NA,
                  "inhibition", "language",    "dexterity", "walking", rows = 2))
p2 <- graph_sem(fit2, angle = 90, 
                edges = get_edges(fit2, label = "est_std"),
                layout = get_layout(
                  NA,           "BHV_DEV",  "NEURAL_DEV", NA,
                  "inhibition", "language", "dexterity",  "walking", rows = 2))
p1 / p2


# These are different models with different meanings and implications.
#
# However...
# There are indistinguishable:
fit.measures <- c("nfi", "nnfi", "tli", "cfi",
                  "gfi", "rmsea", 
                  "chisq", "df","pvalue")
data.frame(
  fit1 = fitMeasures(fit1, fit.measures = fit.measures),
  fit2 = fitMeasures(fit2, fit.measures = fit.measures)
)

# They have the SAME EXACT FIT!
# These models are equivalent - the data fits them the same (same measures of
# fit, same Chisq and df)... There is not way to statistically determine which
# model is correct. In fact, it is impossible to statistically show that you
# causal model is correct (the best you can hope for is that it fits your data
# okay.)
#
# The more complex the model, the many more equivalent models can be
# constructed...
#
# - Read more about this here: http://sachaepskamp.com/files/SEM22017/SEM2Week2.pdf
# - Or listen to a podcast about it here: https://www.buzzsprout.com/639103/7983649-s2e24-the-equivalent-models-problem
