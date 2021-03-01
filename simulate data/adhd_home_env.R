library(lavaan)
library(effectsize)
library(dplyr)

m <- "
HOME_t1 =~ 0.7 * accept_t1 + 0.9 * variety_t1 + 0.6 * acStim_t1
HOME_t2 =~ 0.7 * accept_t2 + 0.9 * variety_t2 + 0.6 * acStim_t2

adhd_t2 ~ (-0.8) * HOME_t1 + 0.5 * adhd_t1
HOME_t2 ~ (-0.4) * adhd_t1 + 0.8 * HOME_t1


adhd_t1 ~~ (-0.3) * HOME_t1
adhd_t2 ~~ (-0.1) * HOME_t2

accept_t1 ~~ 0.8 * accept_t2
variety_t1 ~~ 0.8 * variety_t2
acStim_t1 ~~ 0.8 * acStim_t2
"

lavaanify(m, fixed.x = FALSE)

set.seed(2)
d <- simulateData(m, model.type = "sem",
                  fixed.x = FALSE, 
                  skewness = c(rep(0, 6), -0.5, -0.4),
                  kurtosis = c(rep(0, 6), 0, 0),
                  sample.nobs = 314,
                  empirical = TRUE,
                  standardized = FALSE,
                  return.type = "data.frame")

d <- d %>% 
  mutate(
    across(-starts_with("adhd"), ~ round(change_scale(.x, to = c(1, 7)))),
    across(starts_with("adhd"), ~ round(change_scale(.x, to = c(0, 6))))
  )

cor(d)

psych::multi.hist(d)

write.csv(d, "../02 CFA/adhd_home_env.csv", row.names = FALSE)
write.csv(d, "../03 SEM with CLPM/adhd_home_env.csv", row.names = FALSE)
