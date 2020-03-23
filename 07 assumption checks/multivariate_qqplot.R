message("The multivariate_qqplot() fucntion stolen from `mvn()` from the `MVN` pkg.")

multivariate_qqplot <- function(data, covariance = TRUE){
  stopifnot(requireNamespace("ggplot2"))
  
  n <- dim(data)[1]
  p <- dim(data)[2]
  
  S <- cov(data)
  if (covariance) {
    S <- ((n - 1)/n) * S
  }
  
  dif <- scale(data, scale = FALSE)
  d <- diag(dif %*% solve(S) %*% t(dif))
  r <- rank(d)
  chi2q <- qchisq((r - 0.5)/n, p)
  
  ggplot2::ggplot() + 
    ggplot2::geom_point(ggplot2::aes(x = d, y = chi2q)) + 
    ggplot2::geom_abline(slope = 1, intercept = 0) + 
    ggplot2::labs(title = "Chi-Square Q-Q Plot",
                  x = "Squared Mahalanobis Distance",
                  y = "Chi-Square Quantile")
}