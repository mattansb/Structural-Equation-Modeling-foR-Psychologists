library(lavaan)

# There are several issues with performing a moderation analysis inside SEM.
# This tutorial will demonstrate how to conduct 3 types of moderation analyses
# in `lavaan`:
# 1. Observed by observed
# 2. Observed by latent
# 3. Latent by latent


# 1. Observed by observed -------------------------------------------------

head(PoliticalDemocracy)

# Let's look at the following model:
#     y1 ~ x1 * x2
# The first problem is that we cannot use the `*` operator, as it is reserved in
# `lavaan` for modifiers. Instead we must write out the full formula:
#     y1 ~ x1 + x2 + x1:x2

mod1 <- "
  ## regressions
  y1 ~ b1*x1 + b2*x2 + b3*x1:x2
"
# Note that I use the b1, b2 and b3 modefiers here.

fit1 <- sem(mod1, data = PoliticalDemocracy)
summary(fit1)
#> Regressions:
#>                    Estimate  Std.Err  z-value  P(>|z|)
#>   y1 ~                                                
#>     x1        (b1)   -0.222    1.830   -0.121    0.903
#>     x2        (b2)   -1.485    1.181   -1.257    0.209
#>     x1:x2     (b3)    0.303    0.257    1.180    0.238

# The moderation effect (b3) is not significant. How sad.
# Let's imagine that it is anyway...


## Simple slopes (Method 1) ====

# For this simple slopes we need the mean and variance of the moderator (here:
# x2). We can get these with the standard `lavaan` syntax and modefiers.

mod1 <- "
  ## regressions
  y1 ~ b1*x1 + b2*x2 + b3*x1:x2
  
  ## mean and var for moderator:
  x2 ~  M_mod*1
  x2 ~~ V_mod*x2
"

# We can then use there to compute the simple slopes at mean+-sd:

mod1 <- "
  ## regressions
  y1 ~ b1*x1 + b2*x2 + b3*x1:x2
  
  ## mean and var for moderator:
  x2 ~  M_mod*1
  x2 ~~ V_mod*x2
  
  ## simple slopes
  slope_below := b1 + b3*(M_mod - sqrt(V_mod))
  slope_mean  := b1 + b3*(M_mod)
  slope_above := b1 + b3*(M_mod + sqrt(V_mod))
"

fit1 <- sem(mod1, data = PoliticalDemocracy)
summary(fit1)
#> Regressions:
#>                    Estimate  Std.Err  z-value  P(>|z|)
#>   y1 ~                                                
#>     x1        (b1)   -0.222    1.327   -0.167    0.867
#>     x2        (b2)   -1.485    0.183   -8.098    0.000
#>     x1:x2     (b3)    0.303    0.089    3.401    0.001
#> 
#> Defined Parameters:
#>                    Estimate  Std.Err  z-value  P(>|z|)
#>     slope_below       0.775    1.051    0.737    0.461
#>     slope_mean        1.230    0.927    1.326    0.185
#>     slope_above       1.685    0.808    2.085    0.037

# The slope of x1 is only significant for high values of x2.




# 2. Observed by latent ---------------------------------------------------

# Problem 2 - we can't use the solution above if the moderator (or moderatee) is
# a latent variable. Instead we need to make a nother latent variable that is
# the interaction term! There are a few methods to do this - we will use the
# residual centering method. 
# Read more: http://doi.org/10.4256/mio.2010.0030

# Our model will have 1 latent variable with indicators y1, y2, y3 and y4 that
# will interact with y5 to predict x1.


# Step 1: Make indicators for the interaction term:

PoliticalDemocracy_with_ind <- semTools::indProd(
  data = PoliticalDemocracy,
  var1 = c("y1", "y2", "y3", "y4"), # indicators
  var2 = "y5",
  # read about these more in the docs:
  match = FALSE,
  meanC = FALSE,
  residualC = TRUE,
  doubleMC = FALSE
)

head(PoliticalDemocracy_with_ind)
# note the new variables we have!


# Specify the model (with simple slopes):
mod2 <- "
  ## latent variable definitions
     dem60 =~ y1 + y2 + y3 + y4
  dem60.y5 =~ y1.y5 + y2.y5 + y3.y5 + y4.y5
  
  ## regressions
  x1 ~ b1*y5 + b2*dem60 + b3*dem60.y5

  ## var for moderator:
  # (Mean is 0)
  dem60 ~~ V_mod*dem60
  
  ## simple slopes
  slope_below := b1 + b3*(0 - sqrt(V_mod))
  slope_mean  := b1 + b3*(0)
  slope_above := b1 + b3*(0 + sqrt(V_mod))
"

fit2 <- sem(mod2, data = PoliticalDemocracy_with_ind)
summary(fit2)
#> Regressions:
#>                    Estimate  Std.Err  z-value  P(>|z|)
#>   x1 ~                                                
#>     y5        (b1)    0.063    0.026    2.430    0.015
#>     dem60     (b2)    0.213    0.073    2.934    0.003
#>     dem60.y5  (b3)    0.219    0.070    3.117    0.002
#> 
#> Defined Parameters:
#>                    Estimate  Std.Err  z-value  P(>|z|)
#>     slope_below      -0.156    0.075   -2.087    0.037
#>     slope_mean        0.063    0.026    2.430    0.015
#>     slope_above       0.281    0.075    3.764    0.000

# Significant interaction - the slope for y5 is negative for low levels of
# dem60, and gets positive for medium and high levels of dem60.


# 3. latent by latent -----------------------------------------------------

# Same as (2)...
# Our model will have 1 latent variable with indicators y1, y2, y3 and y4 that
# will interact with another latent variable indicated by y5, y6, y7 and y8, to
# predict x1.


PoliticalDemocracy_with_ind2 <- semTools::indProd(
  data = PoliticalDemocracy,
  var1 = c("y1", "y2", "y3", "y4"), # indicators
  var2 = c("y5", "y6", "y7", "y8"),
  # read about these more in the docs:
  match = FALSE,
  meanC = FALSE,
  residualC = TRUE,
  doubleMC = FALSE
)

head(PoliticalDemocracy_with_ind2)
# note the new variables we have!


# Specify the model (with simple slopes):
mod3 <- "
  ## latent variable definitions
        dem60 =~ y1 + y2 + y3 + y4
        dem65 =~ y5 + y6 + y7 + y8
  dem60.dem65 =~ y1.y5 + y1.y6 + y1.y7 + y1.y8 + 
                 y2.y5 + y2.y6 + y2.y7 + y2.y8 + 
                 y3.y5 + y3.y6 + y3.y7 + y3.y8 + 
                 y4.y5 + y4.y6 + y4.y7 + y4.y8
  
  ## regressions
  x1 ~ b1*dem60 + b2*dem65 + b3*dem60.dem65
  
  ## mean and var for moderator:  
  # mean is 0, var is 1 because of std.lv = TRUE (and latent are exogenous)

  ## simple slopes 
  slope_below := b1 + b3*(0 - 1)
  slope_mean  := b1 + b3*(0)
  slope_above := b1 + b3*(0 + 1)
"

fit3 <- sem(mod3, data = PoliticalDemocracy_with_ind2, std.lv = TRUE)
summary(fit3)
#> Regressions:
#>                    Estimate  Std.Err  z-value  P(>|z|)
#>   x1 ~                                                
#>     dem60     (b1)   -1.229    1.696   -0.725    0.469
#>     dem65     (b2)    1.598    1.696    0.942    0.346
#>     dm60.dm65 (b3)    0.106    0.108    0.982    0.326
#> 
#> Defined Parameters:
#>                    Estimate  Std.Err  z-value  P(>|z|)
#>     slope_below      -1.335    1.700   -0.785    0.432
#>     slope_mean       -1.229    1.696   -0.725    0.469
#>     slope_above      -1.124    1.699   -0.661    0.509

# No interaction - dem60 has no significant slope for any level of dem65.





# Other solutions... ------------------------------------------------------

# You can also extract latent scores from a CFA model (with `predict()`), and
# then use these scores in a moderation analysis in a regression model.

