library(lavaan)
library(semPlot)

income_psych <- read.csv("income_psych.csv")

mediation_model <- '
    income ~ anxiety + mood_neg
  mood_neg ~ anxiety
'
fit <- sem(mediation_model, data = income_psych)


# Adding var labels -------------------------------------------------------

#' We can add labels to our variables with the `nodeLabels` argument.
#' However, for this we need to know the order in which `semPaths()`
#' "reads" the variables. We can do that like so:

semPlotModel(fit)@Vars

semPaths(fit,
         nodeLabels = c("Negative Mood", "Income", "Anxiety"))


# Other attributes --------------------------------------------------------

#' You can play with other attributes of the plot by:
#' 1. Saving the plot into an object
#' 2. Changing the attributes `graphAttributes`

# Example of chaning the width and hight of nodes:
p <- semPaths(fit,
              nodeLabels = c("Negative Mood", "Income", "Anxiety"))

p$graphAttributes$Nodes$width <- c(10,10,20)
p$graphAttributes$Nodes$height <- c(20,5,5)

plot(p)

# Example of nodes changing colors:
p$graphAttributes$Nodes$border.color <- c("black", "green", "red")

plot(p)


# Manual Layout -----------------------------------------------------------

#' Make a matrix with a row for each node,
#' and 2 columns
m <- matrix(NA, nrow = 3, ncol = 2)

# For each "row" (node), set the (x,y) coordinates.
# The order of rows is again taken from:
semPlotModel(fit)@Vars

# (x,y)=(0,0) is the bottom left
m[1, ] <- c(2,0)
m[2, ] <- c(1,1)
m[3, ] <- c(0,0)
m

semPaths(fit,
         layout = m)

# For a shiny app that can help, see
# https://mattansb.github.io/MSBMisc/reference/node_layout_maker.html


# Final product -----------------------------------------------------------

m <- matrix(NA, nrow = 3, ncol = 2)
m[1, ] <- c(2,0)
m[2, ] <- c(1,1)
m[3, ] <- c(0,0)

p <- semPaths(fit, what = "std", whatLabels = "std", 
              residuals = TRUE, intercepts = FALSE,
              # prettify
              style = "lisrel", normalize = TRUE, fade = FALSE,
              sizeMan = 11, sizeMan2 = 7,
              sizeLat = 11, sizeLat2 = 7,
              nCharNodes = 50,
              edge.label.cex = 1,
              # even more
              layout = m,
              nodeLabels = c("Negative Mood", "Income", "Anxiety"))

p$graphAttributes$Nodes$width <- c(20, 10, 10)
p$graphAttributes$Nodes$border.color <- c("black", "green", "red")

plot(p)
