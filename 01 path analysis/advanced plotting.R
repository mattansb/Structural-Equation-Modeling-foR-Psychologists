library(lavaan)
library(tidySEM)
library(dplyr)

income_psych <- read.csv("income_psych.csv")

mediation_model <- '
    income ~ anxiety + mood_neg
  mood_neg ~ anxiety
'
fit <- sem(mediation_model, data = income_psych)

## See below for how "plot1.png" and "plot2.png" were made.

## Based on:
## https://cjvanlissa.github.io/tidySEM/articles/Plotting_graphs.html


# Changing the layout -----------------------------------------------------

lay <- get_layout(NA, "mood_neg", NA,
                  NA, NA, NA,
                  "anxiety", NA, "income",
                  rows = 3)




graph_data <- prepare_graph(fit, layout = lay, label = "est_std")

plot(graph_data)




# Adding var labels -------------------------------------------------------

# We can add labels to our variables (our "nodes") by chaging the "label" column
# in the "nodes" part of the plot:

(N <- nodes(graph_data))

nodes(graph_data) <- N %>% 
  mutate(label = c("Anxiety", "Income", "Negative Mood"))

plot(graph_data)



# Adding / changing arrow labels ------------------------------------------


(tab <- table_results(fit, columns = c("label", "est_std", "confint_std", "pval"), digits = 2))

(E <- edges(graph_data))

edges(graph_data) <- E %>% 
  mutate(est_std = tab$est_std,
         label = paste0(round(est_std, 2), " ",tab$confint))

plot(graph_data)





# Even more ---------------------------------------------------------------

E <- edges(graph_data)

edges(graph_data) <- E %>% 
  mutate(
    # color lines by sign:
    colour = case_when(
      arrow == "both" ~ "black",
      est_std < 0 ~ "red",
      est_std > 0 ~ "green"
    ),
    # mark which is sig
    linetype = c("dashed","dashed","solid", "dashed", "solid", "solid")
  )


N <- nodes(graph_data)

nodes(graph_data) <- N %>% 
  mutate(size = c(1,3,1))

plot(graph_data)





# Making "plot1" ----------------------------------------------------------

mediation_model <- '
    income ~ anxiety + mood_neg
  mood_neg ~ anxiety
'

fit <- sem(mediation_model, data = income_psych)



lay <- get_layout(NA, "mood_neg", NA,
                  "anxiety", NA, "income",
                  rows = 2)

graph_data <- prepare_graph(fit, layout = lay)

E <- edges(graph_data)
E$label <- ""
E$connect_from[3] <- "top"
E$connect_to[3] <- "left"
E$connect_from[2] <- "right"
E <- E[1:3,]
edges(graph_data) <- E



(N <- nodes(graph_data))
N$label <- c("Anxiety", "Income", "Negative Mood")
nodes(graph_data) <- N





(p1 <- plot(graph_data))

# because the result it a ggplot, we will use ggsave to save it
ggplot2::ggsave(p1, filename = "plot1.png", width = 6, height = 3)





# Making "plot2" ----------------------------------------------------------


mediation_model <- '
    income ~ anxiety + mood_neg + shyness
  mood_neg ~ anxiety
   anxiety ~ shyness
'

fit <- sem(mediation_model, data = income_psych)






lay <- get_layout(NA, NA, "mood_neg", NA,
                  NA, "anxiety", NA, "income",
                  "shyness", NA, NA, NA,
                  rows = 3)

graph_data <- prepare_graph(fit, layout = lay)

E <- edges(graph_data)
E$label <- ""
E$connect_from[5] <- "top"
E$connect_to[5] <- "left"
E$connect_from[4] <- "top"
E$connect_to[4] <- "left"
E$connect_to[3] <- "bottom"
E <- E[1:5,]
edges(graph_data) <- E

plot(graph_data)

(N <- nodes(graph_data))
N$label <- c("Anxiety", "Income", "Negative Mood", "Shyness")
N$node_xmin[3] <- N$node_xmin[3]-0.5
N$node_xmax[3] <- N$node_xmax[3]+0.5
nodes(graph_data) <- N


(p2 <- plot(graph_data))

# because the result it a ggplot, we will use ggsave to save it
ggplot2::ggsave(p2, filename = "plot2.png", width = 6, height = 3)
