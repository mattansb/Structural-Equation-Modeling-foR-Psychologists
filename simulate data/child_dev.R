library(lavaan)
library(effectsize)
library(dplyr)

m <- "
DEV =~ 0.6 * inhibition + 0.8 * language + 0.7 * dexterity + 0.7 * walking

dexterity ~~ 0.4 * walking
"

lavaanify(m)

set.seed(4)
d <- simulateData(m, model.type = "sem",
                  sample.nobs = 197,
                  empirical = TRUE,
                  standardized = FALSE,
                  return.type = "data.frame")

d <- d %>% 
  mutate(across(.fns = ~round(change_scale(.x, to = c(1, 10)))))

cor(d)

psych::multi.hist(d)

write.csv(d, "../02 CFA/child_dev.csv", row.names = FALSE)
