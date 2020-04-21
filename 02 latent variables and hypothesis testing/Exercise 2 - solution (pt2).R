library(dplyr)
big5 <- psychTools::bfi %>%
  select(A1:A5, C1:C5, E1:E5, N1:N5, O1:O5,
         gender, age) %>%
  na.omit()

head(big5)



# 1. Create a measurment model --------------------------------------------
# with the big 5 (latent), age, and gender

library(lavaan)

meas_mod <- "
  ## latent variable definitions
           Openness =~ O1 + O2 + O3 + O4 + O5
  Conscientiousness =~ C1 + C2 + C3 + C4 + C5
       Extroversion =~ E1 + E2 + E3 + E4 + E5
      Agreeableness =~ A1 + A2 + A3 + A4 + A5
        Neuroticism =~ N1 + N2 + N3 + N4 + N5
        
  ## covariances
     age ~~ gender + Openness + Conscientiousness + Extroversion + Agreeableness + Neuroticism
  gender ~~ Openness + Conscientiousness + Extroversion + Agreeableness + Neuroticism
  
  ## Self regression (bug)
     age ~ 1 * age
  gender ~ 1 * gender
"
fit_meas <- cfa(meas_mod, data = big5, 
                std.lv = TRUE)



#    - Explore the MIs. Is there anything you should add?
#      Does it make sense?
modificationIndices(fit_meas, sort. = TRUE,
                    minimum.value = 10,
                    maximum.number = 5)
# Maybe N1 ~~ N2 and N3 ~~ N4 have some additional shared variance on top of the
# variance in the latent variable of Neuroticism?


# 2. Create 2 structural models (your choice) -----------------------------
# with the big5, age and gender.


struct_mod1 <- "
  ## latent variable definitions
           Openness =~ O1 + O2 + O3 + O4 + O5
  Conscientiousness =~ C1 + C2 + C3 + C4 + C5
       Extroversion =~ E1 + E2 + E3 + E4 + E5
      Agreeableness =~ A1 + A2 + A3 + A4 + A5
        Neuroticism =~ N1 + N2 + N3 + N4 + N5
        
  ## covariances
  Openness ~~ Agreeableness
  
  ## regression
      Agreeableness ~ gender
       Extroversion ~ gender + Neuroticism
  Conscientiousness ~ age
"
fit_struct1 <- sem(struct_mod1, data = big5, 
                   std.lv = TRUE)



struct_mod2 <- "
  ## latent variable definitions
           Openness =~ O1 + O2 + O3 + O4 + O5
  Conscientiousness =~ C1 + C2 + C3 + C4 + C5
       Extroversion =~ E1 + E2 + E3 + E4 + E5
      Agreeableness =~ A1 + A2 + A3 + A4 + A5
        Neuroticism =~ N1 + N2 + N3 + N4 + N5
        
  ## covariances
  Openness ~~ Agreeableness
  
  ## regression
      Agreeableness ~ gender
       Extroversion ~ Neuroticism
  Conscientiousness ~ age
"
# removed the arrow from gender to Extroversion
fit_struct2 <- sem(struct_mod2, data = big5, 
                   std.lv = TRUE)



#    - Compare them (sig [make sure they are nested], BF).
anova(fit_struct2, fit_struct1)
bayestestR::bayesfactor_models(fit_struct2, denominator = fit_struct1)
# both results suggest that the removal of gender as a predictor of Extroversion
# has worsened the model fit.


#    - Compare their measures of fit.
fitMeasures(fit_struct1, output = "matrix",
            fit.measures = "rmsea")
fitMeasures(fit_struct2, output = "matrix",
            fit.measures = "rmsea")
# both look good

fitMeasures(fit_struct1, output = "matrix",
            fit.measures = c("nfi","nnfi","tli", "cfi"))
fitMeasures(fit_struct2, output = "matrix",
            fit.measures = c("nfi","nnfi","tli", "cfi"))
# neither are amazing - both are not different enough from the independance
# model :/

fitMeasures(fit_struct1, output = "matrix",
            fit.measures = c("nfi","nnfi","tli", "cfi","rmsea"),
            baseline.model = fit_struct2) # the more restricted one!
# When comparing the model directly, both models seem very similar... That is -
# the less restricted model is not a lot better (if at all) from the more
# restricted model.
# And yet... above we got a significant resault. How can this be?
# Because of our large sample size - 2,436 observations!



# 3. Plot one of the 3 models from 1-2. -----------------------------------

library(semPlot)
semPaths(fit_struct1, what = "std", whatLabels = "std", 
         residuals = TRUE, intercepts = FALSE,
         # prettify
         fade = FALSE,
         style = "lisrel", normalize = TRUE, 
         sizeLat = 7, sizeLat2 = 5,
         nCharNodes = 7,
         edge.label.cex = 1,
         edge.label.position = 0.45,
         edge.label.bg = TRUE, edge.label.color = "black")


