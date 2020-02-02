# https://www.theanalysisfactor.com/four-types-sem/

{
  library(lavaan)
  dat <- within(HolzingerSwineford1939,{
    BA_grade <- -scale(x1) + scale(x2) + -scale(x3) + scale(x4) + -scale(x5) + scale(x7)
    BA_grade <- BA_grade + rt(length(BA_grade), df = 4)*sd(BA_grade)
    
    BA_grade2 <- -scale(x1) + scale(x5) + scale(x7) + scale(x9)
    BA_grade2 <- BA_grade2 + rt(length(BA_grade), df = 4)*sd(BA_grade2)
    
    x2 <- x2 + rnorm(length(x2), sd = sd(x2)/2)
  })
  
  colnames(dat)
  dat <- dat[,7:17]
  colnames(dat)
  colnames(dat) <- c("adhd1","adhd2","adhd3","iq1","iq2","anx1","anx2","anx3",
                     "sustained_attn", "inhibition")
  
  adhd_anx <- dat
  write.csv(adhd_anx, "adhd_anx.csv", row.names = F)
}


#' Today we will explore the relationship between ADHD, IQ, and anxiety
#' and their effects on sustained attention and inhibition

adhd_anx <- read.csv("adhd_anx.csv")
head(adhd_anx)

# 1. measurement model ----------------------------------------------------

library(lavaan)

mod_meas <- '
  ## latent variable definitions (CFA)
  ADHD =~ adhd1 + adhd2 + adhd3
    IQ =~ iq1 + iq2
   ANX =~ anx1 + anx2 + anx3 
  
  ## self-rgression
  sustained_attn ~ 1 * sustained_attn
      inhibition ~ 1 * inhibition
  # we need to define one of the observed variables (this is a silly bug) This does not affect the model fit!
  
  ## covariances
  sustained_attn ~~ inhibition + ADHD + IQ + ANX
      inhibition ~~ ADHD + IQ + ANX
'

fit_meas <- cfa(mod_meas, data = dat)

library(semPlot)
semPaths(fit_meas, what = "std", fade = F, whatLabels = "std", style = "lisrel", layout = "tree")


summary(fit_meas, standardize = TRUE)
# why is there no test for ADHD =~ adhd1?

parameterEstimates(fit_meas, output = "text")
standardizedSolution(fit_meas, output = "text")
# By default the factor loading of the first indicator of a latent variable is fixed to 1,
# thereby fixing the scale of the latent variable... Fixed parameters are not tested.



# Modification Indices ----------------------------------------------------

# We can look at modification indices (mi):
modificationIndices(fit_meas, sort. = TRUE, maximum.number = 10)
# what should we do?



# Fit Measures ------------------------------------------------------------

fitMeasures(fit_meas,
            fit.measures = c("chisq", "df","pvalue",
                             "baseline.chisq","baseline.df","baseline.pvalue"))
# The "baseline" model is the null /"independence" model, which constraints
# all covariances to zero, AKA the worst model.


fitMeasures(fit_meas, output = "text",
            fit.measures = c("nfi","nnfi","tli", "cfi","rmsea"))
# What we want:
# Should Chi-sq be sig?
#        NFI > 0.9
# NNFI / TLI > 0.9
#        CFI > 0.9
#      RMSEA < 0.08

# 2. structural model -----------------------------------------------------

# When defining structural model, the important bits are
# the arrow you don't include / fix at 0!

mod_struct <- '
  ## latent variable definitions
  ADHD =~ adhd1 + adhd2 + adhd3
    IQ =~ iq1 + iq2
   ANX =~ anx1 + anx2 + anx3 
  
  ## regressions
      inhibition ~ ADHD + ANX + IQ
  sustained_attn ~ inhibition + ADHD
  
  ## covariances
  IQ ~~ ADHD
  IQ ~~ 0*ANX
'

fit_struct <- sem(mod_struct, data = dat)

library(semPlot)
semPaths(fit_struct, what = "std", fade = F, whatLabels = "std", style = "lisrel", layout = "tree")


summary(fit_struct, standardize = TRUE)


fitMeasures(fit_struct,
            fit.measures = c("chisq", "df","pvalue",
                             "baseline.chisq","baseline.df","baseline.pvalue"),
            baseline.model = fit_meas)
anova(fit_struct, fit_meas)
bayestestR::bayesfactor_models(fit_struct, denominator = fit_meas)

fitMeasures(fit_struct, output = "text",
            fit.measures = c("nfi","nnfi","tli", "cfi","rmsea"), 
            baseline.model = fit_meas)


# Exercise ----------------------------------------------------------------

library(dplyr)
big5 <- psychTools::bfi %>% 
  select(A1:A5, C1:C5, E1:E5, N1:N5, O1:O5,
         gender, age) %>% 
  filter_all(~!is.na(.x))

head(big5)

# 1. Create a measurment model with the big 5 latent variables, age, and gender.
#    - Explore the MIs. Is there anything you should add? Does it make sense?
# 2. Create at least 2 structural models of your choice with the big5, age and gender.
#    - Compare them (sig, BF).
#    - Compare their measures of fit.

