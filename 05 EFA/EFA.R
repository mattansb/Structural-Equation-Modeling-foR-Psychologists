# https://easystats.github.io/parameters/articles/efa_cfa.html

data <- na.omit(psychTools::bfi[, 1:25])  # Select only the 25 first columns corresponding to the items

library(parameters)
library(psych)

cor(data)
check_factorstructure(data)


efa <- fa(data, nfactors = 5, rotate = "varimax") # or rotate = "oblimin"

summary(efa) # or
model_parameters(efa, threshold = 0.55)

# We can now use the factor scores just as we would any variable:
data_scores <- efa$scores
colnames(data_scores) <- c("N","E","C","A","O") # name the factors
head(data_scores)

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

semPaths(fit5, what = "std", whatLabels = "std", 
         residuals = TRUE, intercepts = FALSE,
         # prettify
         fade = FALSE,
         style = "lisrel", normalize = TRUE, 
         nCharNodes = 50,
         edge.label.cex = 1,
         edge.label.bg = TRUE, edge.label.color = "black",
         edge.label.position = 0.55)

# Exercise ----------------------------------------------------------------

# - Compare a 5 and 6 factor models for the big5 (big6??).
# - Compare different cuttoffs for the big6 - what would you do?
