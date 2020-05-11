# https://easystats.github.io/parameters/articles/efa_cfa.html

# Select only the 25 first columns corresponding to the items
data <- na.omit(psychTools::bfi[, 1:25])

head(data)



# Factor Analysis (FA) ----------------------------------------------------

library(parameters)
library(psych)

## Is the data suitable for FA?
round(cor(data), 2)
check_factorstructure(data)



## Run FA
efa <- fa(data, nfactors = 5, 
          rotate = "oblimin",
          fm = "minres") # minimum residual method (default)
efa <- fa(data, nfactors = 5, 
          rotate = "oblimin",
          fm = "pa") # principal factor solution
# or rotate = "varimax"

efa
model_parameters(efa, sort = TRUE, threshold = 0.55)
# These give the pattern matrix



## Visualize
biplot(efa, choose = c(1,2), pch = ".") # set `choose = NULL` for all
# We see here that PA2 is aligned with "N" cols, and that PA3 is aligned 
# with "C" cols - same as we saw in the table above.





# We can now use the factor scores just as we would any variable:
data_scores <- efa$scores
colnames(data_scores) <- c("N","E","C","A","O") # name the factors
head(data_scores)




# Reliability -------------------------------------------------------------

# Accepts the same arguments as `fa()`
efa_rel <- omega(data, nfactors = 5, fm = "pa", rotate = "oblimin", 
                 plot = FALSE)
efa_rel$omega.group
# This give omega (look at omega total), which is similar to alpha, but doesn't
# assume equal weights (which we just estimated!).
# https://doi.org/10.1037/met0000144




# How many factors to retain in Factor Analysis (FA)? ---------------------

# But what if we're not sure how many factors?



# Scree plot - where is the elbow?
screeplot(prcomp(data), npcs = 10, type = "lines") # run PCA with `prcomp`



# other methods:
ns <- n_factors(data, algorithm = "pa", rotation = "oblimin")
# This function calls many methods, e.g., nFactors::nScree... Read the doc!
as.data.frame(ns) # look for Kaiser criterion of Scree - seems to suggest 6




# Back to CFA in lavaan ---------------------------------------------------

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


# EFA in lavaan -----------------------------------------------------------

# If you MUST do EFA in lavaan - it is possible...

efa5_model <- "
  efa('block1')*F1 +
  efa('block1')*F2 +
  efa('block1')*F3 +
  efa('block1')*F4 +
  efa('block1')*F5 =~ A1 + A2 + A3 + A4 + A5 + 
                      C1 + C2 + C3 + C4 + C5 + 
                      E1 + E2 + E3 + E4 + E5 + 
                      N1 + N2 + N3 + N4 + N5 +
                      O1 + O2 + O3 + O4 + O5
"
efa_fit <- lavaan(efa5_model, data = data,  
                  auto.var = TRUE, auto.efa = TRUE)
standardizedSolution(efa_fit, output = "text")

# tidy that output:
library(dplyr)
library(tidyr)

# compare:
standardizedSolution(efa_fit, output = "data.frame") %>% 
  as.data.frame() %>% 
  filter(op == "=~") %>% 
  select(factor   = lhs,
         item     = rhs,
         loadings = est.std) %>%
  pivot_wider(names_from  = factor,
              values_from = loadings)

# with:
model_parameters(efa) # results from psych::fa





# Exercise ----------------------------------------------------------------

# Kaiser criterion of Scree suggests that the best number of factors is not 5,
# but 6. Conduct an EFA for 6 factors (big6?).
# - Which items are assosiated with which factor? What do you make of the
#   factors?
# - Compare different cuttoffs for the big6 - what would you do?
# - Compare the EFA on 5 factors and the EFA on 6 factors. You can use `anova()`
#   to compare the models: `d.chiSq` is the test statistic with `d.df` degrees
#   of freedom. `PR` is the p-value.
#   Note: Chi-squared corresponds to the variance unaccounted for in the
#   selected factors. And the difference (`d.chiSq`) is the additional accounted
#   variance by the EFA with more factors. If the results is significant, this
#   means that the model with more factors significantly accounted for more
#   vatiance!

