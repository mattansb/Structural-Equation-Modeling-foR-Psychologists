
Harman74 <- read.csv("Harman74.csv")

library(lavaan)



# EFA in lavaan -----------------------------------------------------------

# If you MUST do EFA in lavaan - it is possible...

efa_model <- "
  efa('block1')*F1 +
  efa('block1')*F2 +
  efa('block1')*F3 +
  efa('block1')*F4 +
  efa('block1')*F5 =~ VisualPerception + WordMeaning + ObjectNumber +
                      Cubes + Addition + NumberFigure + 
                      PaperFormBoard + Code + FigureWord + 
                      Flags + CountingDots + Deduction + 
                      GeneralInformation + StraightCurvedCapitals + NumericalPuzzles + 
                      PargraphComprehension + WordRecognition + ProblemReasoning + 
                      SentenceCompletion + NumberRecognition + SeriesCompletion + 
                      WordClassification + FigureRecognition + ArithmeticProblems
"

efa_fit <- lavaan(efa_model, data = Harman74,  
                  auto.var = TRUE, auto.efa = TRUE)

summary(efa_fit, standardize = TRUE)
# We can see that these results are very similar to those from psych::fa.

