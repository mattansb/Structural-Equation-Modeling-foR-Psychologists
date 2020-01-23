head(iris)

fit <- lm(Petal.Length ~ Petal.Width * Species, iris)
summary(fit)

mm <- model.matrix( ~ Petal.Width * Species, iris)
head(mm)

fit2 <- lm(Petal.Length ~ 0 + mm, iris)
summary(fit2)

library(emmeans)
ref_grid(fit)
ref_grid(fit2) #    :(
