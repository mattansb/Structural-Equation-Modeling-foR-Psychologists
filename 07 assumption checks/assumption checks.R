
# The assumptions of SEM are similar to those OLS regression:
# 1. Your model is correct.
#    For SEM this means:
#    A) Linearity (the relationship between variables is linear).
#    B) No specification error (all relationships are
#       accounted for, and exogenous variables are actually exogenous).
#    C) Sequence (the causal relationship modeled is true).
# 2. Independence of errors
# 3. Multivariate normal distribution (Normality of errors)
# 4. Homoscedasticity of errors
# 
# I suggest reading Chapter 5 in Kaplan, D. (2008). Structural equation
# modeling: Foundations and extensions (2nd ed.)





# 1) Your model is correct ------------------------------------------------

# No simple way to verify this other than thinking, although plotting can be
# useful to examine linearity.

#' TODO maybe ggeffects?



# 2) Independence of errors -----------------------------------------------

# We have two major sources of dependency of errors:
# 1. Structure of data: 
#    1.1. Is the data multilevel? Have we accounted for that?
#         Read more: http://lavaan.ugent.be/tutorial/multilevel.html
#    1.2. Is there a temporal nature to the data (repeated measures)? 
#         Have we accounted for that? (Using latent growth curve / cross-lagged
#         panel modeling)
# 2. Errors are correlated (e.g. autocorrelations)

# While the 1st requires us to think, the second can be tested
# with `lavaan::modificationIndices()`.

library(lavaan)

model <- ' 
  # latent variable definitions
     dem60 =~ y1 + a*y2 + b*y3 + c*y4
     dem65 =~ y5 + a*y6 + b*y7 + c*y8

  # regressions
    dem65 ~ dem60

  # residual correlations
    y1 ~~ y5
    y2 ~~ y4
    y3 ~~ y7
    y4 ~~ y8
    y6 ~~ y8
'

fit <- sem(model, data = PoliticalDemocracy)

modificationIndices(fit, sort. = TRUE, minimum.value = 10)
#>    lhs op rhs     mi   epc sepc.lv sepc.all sepc.nox
#> 94  y2 ~~  y6 11.094 2.189   2.189    0.364    0.364


# Looks like the errors of y2 and y6 are correlated, 
# and we can consider adding this correlation to our model.






# 3) Multivariate normal distribution -------------------------------------

# Like the assumption of normalicy in OLS regression, this assumption is
# concerned with the normalicy of the residuals, but here these residuals are
# multivariate.
# We can do this with the following function(s):

# To test these, we must supply the original data the model was fit with, so we
# first make a data.frame with ONLY the variables of interest:
model_data <- PoliticalDemocracy[, c("y1", "y2", "y3", "y4", "y5", "y6", "y7", "y8")]
# NOTE: only use the subset of the data that was used!




## Henze-Zirkler Test of Multivariate Normality --------

test_mvn <- MVN::mvn(model_data, mvnTest = "hz")
test_mvn$multivariateNormality
#>            Test       HZ      p value MVN
#> 1 Henze-Zirkler 1.194575 1.110223e-16  NO

# Looks like a deviation from normalicy - however...






## Multivariate (Chi-Squared) QQ-Plot --------

# We can (and should) also look at a multivariate (chisq-)qqplot:
distances <- mahalanobis(model_data, 
                         center = colMeans(model_data), 
                         cov = cov(model_data))

car::qqPlot(distances, ylab = "Mahalanobis distances (Squared)",
            distribution = "chisq", df = mean(distances))
            

# Looks good!




## Multivariate Skewness & Kurtosis --------

# We can also look at multivariate Kurtosis and Skewness if we want: 

library(semTools)


mardiaKurtosis(model_data)
#>        b2d          z          p 
#> 76.0448884 -1.3539399  0.1757556

mardiaSkew(model_data)
#>          b1d          chi           df            p 
#> 1.477098e+01 1.846372e+02 1.200000e+02 1.378703e-04


# We can see that multivariate Skewness does not hold...





# What to if we violate multivariate normalicy?
# Use a robut estimator!
# http://lavaan.ugent.be/tutorial/est.html




# 4) Homoscedasticity of errors -------------------------------------------

# I could not find a way to test this.

