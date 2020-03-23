message("The multivariate_qqplot() fucntion is based on the `mvn()` function from the `MVN` pkg.\n",
        "Bands are based on the worm-plot method to the Chi-square distribution (https://doi.org/10.1002/sim.746).")

multivariate_qqplot <- function(data, covariance = TRUE, bands = TRUE){
  stopifnot(requireNamespace("ggplot2"))
  
  n <- dim(data)[1]
  p <- dim(data)[2]
  
  S <- cov(data)
  if (covariance) {
    S <- ((n - 1) / n) * S
  }
  
  data_c <- scale(data, scale = FALSE)
  d <- diag(data_c %*% solve(S) %*% t(data_c))
  r <- rank(d)
  chi2q <- qchisq((r - 0.5) / n, p)
  
  ggp <- ggplot2::ggplot() +
    ggplot2::geom_point(ggplot2::aes(x = d, y = chi2q)) +
    ggplot2::geom_abline(slope = 1, intercept = 0) +
    ggplot2::labs(title = "Chi-Square Q-Q Plot",
                  x = "Squared Mahalanobis Distance",
                  y = "Chi-Square Quantile")
  
  if (bands) {
    worm_ci <- qnorm(0.975) *
      sqrt(pchisq(d, df = p) * (1 - pchisq(d, df = p)) / n) /
      dchisq(d, df = p)
    
    ggp <- ggp +
      ggplot2::geom_line(ggplot2::aes(x = d, y = worm_ci + d),
                         linetype = "dashed") +
      ggplot2::geom_line(ggplot2::aes(x = d, y = -worm_ci + d),
                         linetype = "dashed")
  }
  
  return(ggp)
}