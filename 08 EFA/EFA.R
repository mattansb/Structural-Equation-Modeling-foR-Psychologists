# https://easystats.github.io/parameters/articles/efa_cfa.html

library(tidyverse)
library(recipes)

library(psych)
library(parameters)
library(factoextra) # https://rpkgs.datanovia.com/factoextra/index.html
library(performance)


# Data --------------------------------------------------------------------

# 24 psychological tests given to 145 seventh and eight-grade children
Harman74 <- read.csv("Harman74.csv")
head(Harman74)


# PCA ---------------------------------------------------------------------

PCA_params <- principal_components(Harman74, n = "max")

PCA_model <- attr(PCA_params, "model")


## How many components? ---------------------
n <- n_factors(Harman74)
# This function calls many methods, e.g., nFactors::nScree... Read the doc!

as.data.frame(n) # Different methods...

### Scree plot --------------------
# Visually:
scree(Harman74, factors = FALSE, pc = TRUE)
# 2/5 seems to be supported by the elbow method,
# and 5 by the Kaiser criterion.

### %Variance accounted for --------------------

get_eigenvalue(PCA_model) |>
  ggplot(aes(
    seq_along(cumulative.variance.percent),
    cumulative.variance.percent
  )) +
  geom_col() +
  geom_hline(yintercept = 90)
# Or 16....

## Extract component scores ----------------------

### With recipe() ---------------------

rec <- recipe(~., data = Harman74) |>
  # We need to do this - all PCA methods we've shown so far do this by default.
  step_normalize(all_numeric_predictors()) |>
  step_pca(all_numeric_predictors(), threshold = 0.9)

rec <- recipe(~., data = Harman74) |>
  step_pca(
    all_numeric_predictors(),
    options = list(center = TRUE, scale. = TRUE),
    num_comp = 5
  )

PCs <- bake(prep(rec), new_data = Harman74)


### With parameters ---------------------

PCs <- predict(PCA_model, newdata = Harman74) # returns all PCs
head(PCs[, 1:5])


## Plots -----------------

fviz_pca_biplot(PCA_model, axes = 1:2)


# FA ----------------------------------------------------------------------
#Is the data suitable for FA?
round(cor(Harman74), 2) # hard to visually "see" structure in the data...

check_sphericity_bartlett(Harman74)


# We will be using pa method with oblimin rotation.

## How many factors? -------------------------

### Scree plot --------

scree(Harman74, factors = TRUE, pc = FALSE)
# 2 / 5 seem to be supported by the elbow
# 2 seem to be supported by the Kaiser criterion.

### Parallel analysis --------------------
# This is considered one of the best methods for determining the number of
# components to retain.

fa.parallel(Harman74, fa = "fa", fm = "pa", error.bars = TRUE)
# Looks like 4 components are supported by the parallel analysis...

### Other methods --------

n <- n_factors(Harman74, algorithm = "pa", rotation = "oblimin")
# This function calls many methods, e.g., nFactors::nScree... Read the doc!

as.data.frame(n)


## Run Factor Analysis (FA) ------------------------------------------------

## Run FA
EFA <- fa(
  Harman74,
  nfactors = 5,
  fm = "pa", # (principal factor solution), or use gm = "minres" (minimum residual method)
  rotate = "oblimin" # or rotate = "varimax"
)
# You can see a full list of rotation types here:
?GPArotation::rotations


EFA # Read about the outputs here: https://m-clark.github.io/posts/2020-04-10-psych-explained/
model_performance(EFA) # Check the model fit
model_parameters(EFA, sort = TRUE, threshold = 0.45)
# These give the pattern matrix

# fa.diagram(EFA, cut = 0.45)
# biplot(EFA, choose = c(1,2,5), pch = ".", cuts = 0.45)  # choose = NULL to look at all of them

## Extract factor scores ----------------------

# We can now use the factor scores just as we would any variable:
data_scores <- predict(EFA, data = Harman74)
colnames(data_scores) <-
  # name the factors
  c(
    "Verbal",
    "Numeral",
    "Visual",
    "Math",
    "Je Ne Sais Quoi"
  )
head(data_scores)


## Reliability -------------------------------------------------------------

# We need a little function here...
# install.packages(
#   'MSBMisc',
#   repos = c('https://mattansb.r-universe.dev', 'https://cloud.r-project.org')
# )
MSBMisc::fa_reliability(
  EFA,
  threshold = 0.45, # What loadings should be used to compute reliability?
  labels = c("Verbal", "Numeral", "Visual", "Math", "Je Ne Sais Quoi")
)
# These are interpretable similarly to Cronbach's alpha

# Exercise ----------------------------------------------------------------

# Select only the 25 first columns corresponding to the items
bfi <- subset(psychTools::bfi, select = 1:25)
bfi <- na.omit(bfi) # Note, there are ways to do EFA with missing data...
head(bfi)

## A. PCA
# What is the minimal number of components that can be used to represent 85% of
# the variance in the bfi scale?

## B. EFA
# 1. Validate the big-5: look at a scree-plot to see if the data suggests 5
#   factors or more or less.
# 2. Conduct an EFA.
# 3. Look at the loadings - do they make sense?
# 4. Are the factors reliable?
