library(lavaan)
library(effectsize)
library(tidySEM)
library(dplyr)

m <- "
fatigue_F ~ 0.6 * anxiety_F + 0.6 * anxiety_M
fatigue_M ~ 0.4 * anxiety_M + 0.3 * anxiety_F

fatigue_M ~~ 0.3 * fatigue_F
anxiety_M ~~ 0.6 * anxiety_F
"

lavaanify(m)

set.seed(4)
d <- simulateData(m, model.type = "sem",
                  sample.nobs = 197,
                  empirical = TRUE,
                  standardized = FALSE,
                  return.type = "data.frame")

d <- d %>% 
  mutate(across(.fns = ~round(change_scale(.x, to = c(-3, 3)))))

cor(d)

psych::multi.hist(d)



write.csv(d, "../03 SEM with CLPM/partner_fatigue.csv", row.names = FALSE)

# plot
fit <- sem(m, data = d)
lay <- get_layout("anxiety_M", "fatigue_M",
                  "anxiety_F", "fatigue_F", rows = 2)

g <- prepare_graph(fit, layout = lay, angle = 90)

edges(g) <- edges(g) %>% 
  mutate(label = NA,
         curvature = replace(curvature, curvature == 60 & to == "fatigue_M", -60)) %>% 
  filter(from != to)

plot(g)

ggplot2::ggsave("../03 SEM with CLPM/partner_fatigue.png", width = 4, height = 3)


