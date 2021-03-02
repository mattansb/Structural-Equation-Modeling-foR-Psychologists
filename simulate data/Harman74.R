library(psych)
library(dplyr)
library(effectsize)


set.seed(8)
d <-
  MASS::mvrnorm(
    Harman74.cor$n.obs,
    mu = Harman74.cor$center,
    Sigma = Harman74.cor$cov,
    empirical = TRUE
  )

head(d)

d <- d %>% 
  data.frame() %>% 
  mutate(across(.fns = ~round(change_scale(.x, to = sort(runif(2, 50, 150))))))

multi.hist(d)


write.csv(d, "../08 EFA/Harman74.csv", row.names = FALSE)
