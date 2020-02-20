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


# Back to CFA in lavaan ---------------------------------------------------

library(lavaan)

structure_big5 <- efa_to_cfa(efa, threshold = 0.55)
structure_big5

fit5 <- cfa(structure_big5, data = data,
            likelihood = "wishart",
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


# EFA in lavaan -----------------------------------------------------------

# If you MUST do EFA in lavaan - it is possible...

efa5_model <- "
  efa('block1')*F1 +
  efa('block1')*F2 +
  efa('block1')*F3 +
  efa('block1')*F4 +
  efa('block1')*F5 =~ A1 + A2 + A3 + A4 + A5 + C1 + C2 + C3 + C4 + C5 + E1 + E2 + E3 + E4 + E5 + N1 + N2 + N3 + N4 + N5 + O1 + O2 + O3 + O4 + O5
"
efa_fit <- lavaan(efa5_model, data = data,  
                  likelihood = "wishart",
                  auto.var = TRUE, auto.efa = TRUE)
standardizedSolution(efa_fit, output = "text")

# tidy that output:
library(dplyr)
library(tidyr)

# compare:
standardizedSolution(efa_fit, output = "text") %>% 
  filter(op == "=~") %>% 
  select(factor   = lhs,
         item     = rhs,
         loadings = est.std) %>% 
  pivot_wider(names_from  = factor,
              values_from = loadings)

# with:
model_parameters(efa) # results from psych::fa

# Exercise ----------------------------------------------------------------

# - Compare a 5 and 6 factor models for the big5 (big6??).
# - Compare different cuttoffs for the big6 - what would you do?
