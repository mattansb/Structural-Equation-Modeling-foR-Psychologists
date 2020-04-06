# Exercise ----------------------------------------------------------------

adhd_anx <- read.csv("adhd_anx.csv")

library(lavaan)

## 1. Set equal loadings to `ANX`'s indicators.
mod_meas <- '
  ## latent variable definitions (CFA)
  # The "=~" can be read as "is identified by"
  ADHD =~ adhd1 + adhd2 + adhd3
    IQ =~ iq1 + iq2
   ANX =~ b * anx1 + b * anx2 + b * anx3 
  
  ## covariances
  sustained_attn ~~ inhibition + ADHD + IQ + ANX
      inhibition ~~ ADHD + IQ + ANX
      
  
  ## self-regression
  # We need to define one of the observed vars (this is a silly bug).
  # This does not affect the model fit!
  sustained_attn ~ 1 * sustained_attn
      inhibition ~ 1 * inhibition
'

fit_meas <- cfa(mod_meas, data = adhd_anx,
                std.lv = TRUE)

##      - Do you think this is a good idea?
##        TIP: look at the un-equal loadings.
# No - looks like anx2 and anx3 have similar (low) loadings, but anx1 has
# different (high) loading, so forcing them all to be similar



## 2. Compute the reliability for equal loadings `ANX` and equal loadings
##    `ADHD`
mod_rel <- '
  ## latent variable definitions (CFA)
  # The "=~" can be read as "is identified by"
  ADHD =~ adhd1 + adhd2 + adhd3
    IQ =~ iq1 + iq2
   ANX =~ b * anx1 + b * anx2 + b * anx3 
'

fit_rel <- cfa(mod_rel, data = adhd_anx,
               std.lv = TRUE)
semTools::reliability(fit_rel)

##      - How is the meaning of Omega changed? What is Omega now that it
##        wasn't before?
# Now, that the loadings are equal, Omega is functionally the same as 
# Cronbach's alpha!


