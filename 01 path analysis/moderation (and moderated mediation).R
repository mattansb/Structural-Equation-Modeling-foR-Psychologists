library(lavaan)

income_psych <- read.csv("income_psych.csv")


# Moderation --------------------------------------------------------------

# Note that you cannot use "*" for the interaction term!
# you must write out the whole thing!

moderation_model <- '
  # regressions
  income ~ b1*anxiety + b2*mood_neg + b3*anxiety:mood_neg
  
  # mean and var for moderator:
  mood_neg ~ mood_neg.mean*1
  mood_neg ~~ mood_neg.var*mood_neg
  
  # simple slopes for condition effect
  SD.below := b1 + b3*(mood_neg.mean - sqrt(mood_neg.var))
      mean := b1 + b3*(mood_neg.mean)
  SD.above := b1 + b3*(mood_neg.mean + sqrt(mood_neg.var))
  '

fit <- sem(moderation_model, data = income_psych,
           likelihood = "wishart")
summary(fit, standardize = TRUE)


# Moderated Mediation -----------------------------------------------------

# For first / second step mod-med:
#   https://psu-psychology.github.io/psy-597-SEM/11_mediation_moderation/mediation_moderation_demo.html
# For full mod-med:
#   https://ademos.people.uic.edu/Chapter15.html