# https://easystats.github.io/parameters/articles/efa_cfa.html


# 24 psychological tests given to 145 seventh and eight-grade children
Harman74 <- read.csv("Harman74.csv")
head(Harman74)

library(psych)
library(parameters)


# How many factors to retain in Factor Analysis (FA)? ---------------------

## Is the data suitable for FA? --------
round(cor(Harman74), 2) # hard to visually "see" structure in the data...

check_factorstructure(Harman74)


## Raw or scaled? --------
# Now we first need to decide:
# Are we conducting a FA on the raw scales? Or the standardized scales?




## Scree plot --------
screeplot(
  prcomp(Harman74, scale. = FALSE), # set scale. = TRUE for standardized scales
  npcs = 10, type = "lines"
)
# where is the elbow?



## Other methods --------
ns <- n_factors(
  Harman74, # for standardized scales, standardized the data first!
  algorithm = "pa", rotation = "oblimin"
)
# This function calls many methods, e.g., nFactors::nScree... Read the doc!

as.data.frame(ns) # look for Kaiser criterion of Scree







# Run Factor Analysis (FA) ------------------------------------------------







## Run FA
efa <- fa(Harman74, nfactors = 5,
          fm = "minres", # minimum residual method (default)
          rotate = "oblimin") # or rotate = "varimax"
efa <- fa(Harman74, nfactors = 5, 
          fm = "pa", # principal factor solution
          rotate = "oblimin") # or rotate = "varimax"

efa
model_parameters(efa, sort = TRUE, threshold = 0.45)
# These give the pattern matrix



## Visualize
biplot(efa, choose = c(1,4), pch = ".") # set `choose = NULL` for all





# We can now use the factor scores just as we would any variable:
data_scores <- efa$scores
colnames(data_scores) <- c("Verbal","Numeral","Visual","Math","XXX") # name the factors
head(data_scores)








# Reliability -------------------------------------------------------------

# Accepts the same arguments as `fa()`
efa_rel <- omega(Harman74, nfactors = 5, fm = "pa", rotate = "oblimin", 
                 plot = FALSE)
efa_rel$omega.group
# This give omega (look at omega total), which is similar to alpha, but doesn't
# assume equal weights (which we just estimated!).
# https://doi.org/10.1037/met0000144














# Exercise ----------------------------------------------------------------

# Select only the 25 first columns corresponding to the items
bfi <- na.omit(psychTools::bfi[, 1:25])
head(bfi)

# 1. Validate the big-5: look at a scree-plot to see if the data suggests 5
#   factors or more or less.
# 2. Conduct an EFA.
# 3. Look at the loadings - do they make sense?
# 4. Fit a second EFA with one more / less factor. Compare it to the previous
#   EFA; You can use `anova()` (`d.chiSq` is the test statistic with `d.df`
#   degrees of freedom. `PR` is the p-value.)
#   Note: Chi-squared corresponds to the variance unaccounted for in the
#   selected factors. And the difference (`d.chiSq`) is the *additional*
#   accounted variance by the EFA with more factors. If the results is
#   significant, this means that the model with more factors significantly
#   accounted for more variance!

