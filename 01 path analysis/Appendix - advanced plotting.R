library(lavaan)
library(tidySEM)
library(dplyr)

income_psych <- read.csv("income_psych.csv")

mediation_model <- '
  mood_neg ~ anxiety
    income ~ anxiety + mood_neg
'
fit <- sem(mediation_model, data = income_psych)

## See below for how "plot1.png" and "plot2.png" were made.



# Changing Nodes (Vars) ---------------------------------------------------

(nods <- get_nodes(fit))

nods <- nods %>% 
  mutate(label = c("Negative\nMood", "Income", "Anxiety")) # \n is a break line

graph_sem(fit,
          nodes = nods)


# Changing Layout ---------------------------------------------------------

lay <- get_layout(
  NA,        "mood_neg", NA,
  "anxiety", NA,         "income",
  rows = 2
)

graph_sem(fit,
          nodes = nods, 
          layout = lay, angle = 90)



# Changing Edges (Paths) --------------------------------------------------


(edgs <- get_edges(fit,
                   columns = c("est_std", "confint_std", "pval_std"),
                   digits = 3))

edgs <- edgs %>% 
  mutate(
    label = paste0(est_std, "\n", confint_std),
    color = "black",
    color = replace(color, as.numeric(est_std) > 0 & to!=from, "green"),
    color = replace(color, as.numeric(est_std) < 0, "red"),
    linetype = "solid",
    linetype = replace(linetype, as.numeric(pval_std) > 0.05, "dashed")
  )

graph_sem(fit,
          nodes = nods, 
          layout = lay, angle = 90,
          edges = edgs)


# Making "plot1" ----------------------------------------------------------

mediation_model <- '
  mood_neg ~ anxiety
    income ~ anxiety + mood_neg
'

fit <- sem(mediation_model, data = income_psych)




nods <- get_nodes(fit) %>% 
  mutate(label = c("Negative\nMood", "Income", "Anxiety")) # \n is a break line

lay <- get_layout(
  NA,         "mood_neg", NA,
  "anxiety", NA,        "income",
  rows = 2
)

edgs <- get_edges(fit) %>% 
  filter(to != from) %>% 
  mutate(label = "")

graph_sem(fit,
          nodes = nods, edges = edgs,
          layout = lay, angle = 90)

ggplot2::ggsave("plot1.png", height = 3, width = 6)





# Making "plot2" ----------------------------------------------------------


mediation_model <- '
  mood_neg ~ a * anxiety
   anxiety ~ b * shyness
    income ~ c * anxiety + d * mood_neg + e * shyness
'

fit <- sem(mediation_model, data = income_psych)

nods <- get_nodes(fit) %>% 
  mutate(label = c("Negative\nMood", "Anxiety", "Income", "Shyness")) # \n is a break line

lay <- get_layout(
  NA,        NA,         "mood_neg", NA,
  NA,        "anxiety", NA,          "income",
  "shyness", NA,        NA,          NA,
  rows = 3
)

edgs <- get_edges(fit) %>% 
  filter(to != from) %>% 
  mutate(label = "")

graph_sem(fit,
          nodes = nods, edges = edgs,
          layout = lay, angle = 90)

ggplot2::ggsave("plot2.png", height = 3, width = 6)
