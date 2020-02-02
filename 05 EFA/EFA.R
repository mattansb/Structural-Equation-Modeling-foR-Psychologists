# https://easystats.github.io/parameters/articles/efa_cfa.html

data <- na.omit(psychTools::bfi[, 1:25])  # Select only the 25 first columns corresponding to the items

library(parameters)
library(psych)

cor(data)
check_factorstructure(data)


efa <- fa(data, nfactors = 5, rotate = "varimax") # or rotate = "oblimin"

summary(efa) # or
model_parameters(efa, threshold = 0.55)

# How many factors to retain in Factor Analysis (FA)? ---------------------

# But what if we're not sure how many factors?

# Scree plot - where is the elbow?
screeplot(prcomp(data), type = "lines") # use `prcomp` to run a PCA

# other methods:
ns <- n_factors(data)
as.data.frame(ns) # look for Kaiser criterion of Scree - seems to suggest 6.


# Back to CFA -------------------------------------------------------------

library(lavaan)

structure_big5 <- efa_to_cfa(efa, threshold = 0.55)
structure_big5

fit5 <- cfa(structure_big5, data = data,
            std.lv = TRUE)

library(semPlot)
semPaths(fit5)

# Exercise ----------------------------------------------------------------

# - Compare a 5 and 6 factor models for the big5 (big6??).
# - Compare different cuttoffs for the big6 - what would you do?
