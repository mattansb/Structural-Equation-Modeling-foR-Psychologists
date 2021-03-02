library(lavaan)
library(tidySEM)
library(dplyr)

income_psych <- read.csv("income_psych.csv")

mediation_model <- '
  neg_mood ~ anxiety
    income ~ anxiety + neg_mood
'
fit <- sem(mediation_model, data = income_psych)

## See below for how "plot1.png" and "plot2.png" were made.


# Changing Layout ---------------------------------------------------------

lay <- get_layout(
  NA,        "neg_mood", NA,
  "anxiety", NA,         "income",
  rows = 2
)

graph_sem(fit, 
          layout = lay, angle = 90)



# Changing Nodes (Vars) ---------------------------------------------------

# Instead of directly plotting, we will use `prepare_graph()` as an intermediary
# step.

g <- prepare_graph(fit, 
                   layout = lay, angle = 90)

# we can now see and change node data:
nodes(g)
# as you can see, there are many things you can change here!
# You can also add color, fill, size, linetype and alpha.


nodes(g) <- nodes(g) %>% 
  mutate(label = c("Anxiety", "Income", "Negative\nMood")) # \n is a break line

plot(g)


# Changing Edges (Paths) --------------------------------------------------

# For edges, we first need to ask for some extra columns that have info about
# the paths, with `get_edges()`:

(edgs <- get_edges(fit,
                   columns = c("est_std", "confint_std", "pval_std"),
                   digits = 3))


# we can now use this with prepare_graph:
g <- prepare_graph(fit, 
                   layout = lay, angle = 90,
                   edges = edgs)



# And as we did with the nodes, we can see and change edge data:

edges(g)
# as you can see, there are many things you can change here!
# You can also add color, size, linetype and alpha.

edges(g) <- edges(g) %>% 
  mutate(
    label = paste0(est_std, "\n", confint_std),
    color = "black",
    color = replace(color, as.numeric(est_std) > 0 & to!=from, "green"),
    color = replace(color, as.numeric(est_std) < 0, "red"),
    linetype = "solid",
    linetype = replace(linetype, as.numeric(pval_std) > 0.05, "dashed")
  )

plot(g)

# There are many more options, you can read more here:
# https://cjvanlissa.github.io/tidySEM/articles/Plotting_graphs.html


# Making "plot1" ----------------------------------------------------------

mediation_model <- '
  neg_mood ~ anxiety
    income ~ anxiety + neg_mood
'

fit <- sem(mediation_model, data = income_psych)




nods <- get_nodes(fit) %>% 
  mutate(label = c("Negative\nMood", "Income", "Anxiety")) # \n is a break line

lay <- get_layout(
  NA,        "neg_mood", NA,
  "anxiety", NA,         "income",
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
  neg_mood ~ anxiety
   shyness ~ anxiety
    income ~ anxiety + neg_mood + shyness
'

fit <- sem(mediation_model, data = income_psych)

nods <- get_nodes(fit) %>% 
  mutate(label = c("Negative\nMood", "Shyness", "Income", "Anxiety")) # \n is a break line

lay <- get_layout(
  NA,        "neg_mood", NA,
  "anxiety", NA,         "income",
  NA,        "shyness",  NA,
  rows = 3
)

edgs <- get_edges(fit) %>% 
  filter(to != from) %>% 
  mutate(label = "")

graph_sem(fit,
          nodes = nods, edges = edgs,
          layout = lay, angle = 90)

ggplot2::ggsave("plot2.png", height = 3, width = 6)
