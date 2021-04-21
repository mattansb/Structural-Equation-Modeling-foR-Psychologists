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


g <- prepare_graph(fit, 
                   digits = 3, # if we want to change the digits
                   layout = lay, angle = 90)


# And as we did with the nodes, we can see and change edge data:
edges(g)


# as you can see, there are many things you can change here!
# You can also add color, size, linetype and alpha.


edges(g) <- edges(g) %>% 
  mutate(
    # set label:
    label = paste0(est_std, "\n", confint_std),
    # set color:
    color = case_when(
      to == from ~ "black",
      as.numeric(est_std) > 0 ~ "green",
      as.numeric(est_std) < 0 ~ "red",
      TRUE ~ "black"
    ),
    # set linetype
    linetype = case_when(
      as.numeric(pval_std) > 0.05 ~ "dashed",
      TRUE ~ "solid"
    )
  )

# (This will all be easier in future versions of the package.)


plot(g)

# There are many more options, you can read more here:
# https://cjvanlissa.github.io/tidySEM/articles/Plotting_graphs.html


# Making "plot1" ----------------------------------------------------------


mediation_model <- '
  neg_mood ~ anxiety
    income ~ anxiety + neg_mood
'

fit <- sem(mediation_model, data = income_psych)

lay <- get_layout(
  NA,        "neg_mood", NA,
  "anxiety", NA,         "income",
  rows = 2
)


g1 <- prepare_graph(fit, layout = lay, angle = 90)

nodes(g1) <- nodes(g1) %>% 
  mutate(label = c("Anxiety", "Income", "Negative\nMood")) # \n is a break line

edges(g1) <- edges(g1) %>% 
  filter(to != from) %>% 
  mutate(label = "")


plot(g1)
ggplot2::ggsave("plot1.png", height = 4, width = 6)


# Making "plot2" ----------------------------------------------------------


mediation_model <- '
  neg_mood ~ anxiety
   shyness ~ anxiety
    income ~ anxiety + neg_mood + shyness
'

fit <- sem(mediation_model, data = income_psych)


lay <- get_layout(
  NA,        "neg_mood", NA,
  "anxiety", NA,         "income",
  NA,        "shyness",  NA,
  rows = 3
)


g2 <- prepare_graph(fit, layout = lay, angle = 90)


nodes(g2) <- nodes(g2) %>% 
  mutate(label = c("Anxiety", "Income", "Negative\nMood", "Shyness")) # \n is a break line

edges(g2) <- edges(g2) %>% 
  filter(to != from) %>% 
  mutate(label = "")

plot(g2)
ggplot2::ggsave("plot2.png", height = 4, width = 6)
