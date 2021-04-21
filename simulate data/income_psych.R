library(lavaan)
library(effectsize)

m <- "
income ~ (-0.4) * neg_mood + (-0.7) *shyness + 0.3 * anxiety
neg_mood ~ 0.6 * anxiety + 0.15 * shyness
shyness ~ 0.3 * anxiety
"

lavaanify(m)

set.seed(1)
d <- simulateData(m, model.type = "sem",
                  skewness = c(-1, 1, 2, 1)/2,
                  kurtosis = rep(0, 4),
                  sample.nobs = 431,
                  empirical = FALSE,
                  standardized = TRUE,
                  return.type = "data.frame")

d$income <- standardize(d$income)
d$neg_mood <- round(change_scale(d$neg_mood, to = c(1, 7)))
d$shyness <- round(change_scale(d$shyness, to = c(1, 7)))
d$anxiety <- round(change_scale(d$anxiety, to = c(1, 7)))

cor(d)

psych::multi.hist(d)

write.csv(d, "../01 path analysis/income_psych.csv", row.names = FALSE)
