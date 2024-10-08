#' Fit the linear model

#' @description Fit the linear model to SAR data.
#' @usage sar_linear(data, normaTest =  'none', homoTest = 'none', homoCor =
#'   'spearman', verb = TRUE)
#' @param data A dataset in the form of a dataframe with two columns: the
#'   first with island/site areas, and the second with the species richness
#'   of each island/site.
#' @param normaTest The test used to test the normality of the residuals of the
#'   model. Can be any of 'lillie' (Lilliefors Kolmogorov-Smirnov test),
#'   'shapiro' (Shapiro-Wilk test of normality), 'kolmo' (Kolmogorov-Smirnov
#'   test), or 'none' (no residuals normality test is undertaken; the default).
#' @param homoTest The test used to check for homogeneity of the residuals of
#'   the model. Can be any of 'cor.fitted' (a correlation of the residuals with
#'   the model fitted values), 'cor.area' (a correlation of the residuals with
#'   the area values), or 'none' (no residuals homogeneity test is undertaken;
#'   the default).
#' @param homoCor The correlation test to be used when \code{homoTest !=
#'   "none"}. Can be any of "spearman" (the default), "pearson", or "kendall".
#' @param verb Whether or not to print certain warnings (default = TRUE).

#' @details The model is fitted using linear regression and the
#'   \code{\link{lm}} function. Model validation can be undertaken by assessing
#'   the normality (\code{normaTest}) and homogeneity (\code{homoTest}) of
#'   the residuals and a warning is provided in \code{\link{summary.sars}} if
#'   either test is chosen and fails.
#'
#'   A selection of information criteria (e.g. AIC, BIC) are returned and can
#'   be used to compare models (see also \code{\link{sar_average}}).
#' @importFrom stats lm confint shapiro.test ks.test cor.test
#' @importFrom nortest lillie.test
#' @return A list of class 'sars' with the following components: 
#' \itemize{
#'   \item \strong{par}  The model parameters
#'   \item \strong{value}  Residual sum of squares
#'   \item \strong{verge}  Logical code indicating model convergence
#'   \item \strong{data}  Observed data
#'   \item \strong{model}  A list of model information (e.g. the model name and formula)
#'   \item \strong{calculated}   The fitted values of the model
#'   \item \strong{residuals}  The model residuals
#'   \item \strong{AIC} The AIC value of the model
#'   \item \strong{AICc}  The AICc value of the model
#'   \item \strong{BIC}  The BIC value of the model
#'   \item \strong{R2}  The R2 value of the model
#'   \item \strong{R2a} The adjusted R2 value of the model
#'   \item \strong{sigConf} The model coefficients table
#'   \item \strong{observed_shape}  The observed shape of the model fit
#'   \item \strong{asymptote}  A logical value indicating whether the observed fit is asymptotic
#'   \item \strong{normaTest}  The results of the residuals normality test 
#'   \item \strong{homoTest}  The results of the residuals homogeneity test
#'   \item \strong{neg_check}  A logical value indicating whether negative fitted values have been returned}

#'   The \code{\link{summary.sars}} function returns a more useful summary of
#'   the model fit results, and the \code{\link{plot.sars}} plots the model
#'   fit.
#' @examples
#' data(galap)
#' fit <- sar_linear(galap)
#' summary(fit)
#' plot(fit)
#' @export 

sar_linear <- function(data, normaTest =  "none", homoTest = "none",
                       homoCor = "spearman", verb = TRUE){
  if (!(is.matrix(data) | is.data.frame(data))) 
    stop('data must be a matrix or dataframe') 
  if (is.matrix(data)) data <- as.data.frame(data) 
  if (anyNA(data)) stop('NAs present in data') 
  if (!is.logical(verb)) stop('verb should be logical')
  data <- data[order(data[,1]),] 
  colnames(data) <- c('A','S') 
  #standard linear regression
  mod <- lm(S ~ A, data = data)
  fit <- list()
  fit$par <- mod$coefficients
  names(fit$par) <- c("c", "m")
  res <- as.vector(mod$residuals)
  squ_res <- res^2
  fit$value <- sum(res^2)#residual sum of squares
  fit$verge <- TRUE#should always converge
  fit$data <- data
  fit$model$name <- "Linear model"
  fit$model$formula <- "S == c + m*A"
  fit$model$parNames <- c("c", "m")
  fit$calculated <- as.vector(mod$fitted.values)
  fit$residuals <- res
  #AIC, R2 etc
  n <- dim(data)[1]
  value <- sum(mod$residuals^2)
  #A common mistake when calculating the number of parameters is failure to 
  #include error.
  #This is because it is not normally thought of as a parameter as, strictly 
  #speaking, 
  #you're not really predicting it. As a results the number of parameters 
  #in a standard linear 
  #equation (y=mx+c) is 3 (mx, c, and error) rather than 2.
  P <- 3
  val <-  -n * (log(2 * pi) + 1 - log(n) + log(value))/2
  fit$AIC <- (2 * P) - (2 * val)
  fit$AICc <- -2 * val + 2 * P * (n / (n - P - 1))
  fit$BIC <- (-2 * val) + (P * log(n))

  #R2 (Kvaleth, 1985, Am. Statistician)
  fit$R2 <-  1 - ( (value) /  sum((data$S - mean(data$S))^2) )
  #R2a (He & Legendre 1996, p724)
  fit$R2a <-  1 - ( ((n-1)*(value)) /  
                      ((n-P)*sum((data$S - mean(data$S))^2)))
  fit$sigConf <- cbind(summary(mod)$coefficients, confint(mod))
  #confidence intervals calculated using in built function
  fit$observed_shape <- "linear" 
  fit$asymptote <- FALSE
  #normality and homogeneity tests
  normaTest <- match.arg(normaTest, c("none", "shapiro", "kolmo", "lillie"))
  homoTest <- match.arg(homoTest, c("none","cor.area","cor.fitted"))
  if (homoTest != "none"){
    homoCor <- match.arg(homoCor, c("spearman","pearson",
                                    "kendall"))
  }
  #normality of residuals
  if (normaTest == "shapiro") {
    normaTest <- list("test" = "shapiro", 
                      tryCatch(shapiro.test(res), error = function(e)NA))
  } else if (normaTest == "lillie"){ 
    normaTest <- list("test" = "lillie", 
                      tryCatch(lillie.test(res), error = function(e)NA))
  } else if (normaTest == "kolmo"){ 
    normaTest <- list("test" = "kolmo", 
                      tryCatch(ks.test(res, "pnorm"), error = function(e)NA))
  } else{
    normaTest <- list("test" = "none", "none")
  }
  #Homogeneity of variance
  if (homoTest == "cor.area"){
    homoTest  <- list("test" = "cor.area", 
                      tryCatch(suppressWarnings(cor.test(squ_res,data$A, 
                                                         method = homoCor)), 
                          error = function(e)list(estimate=NA,p.value=NA)))
  } else if (homoTest == "cor.fitted"){
    homoTest  <- list("test" = "cor.fitted", 
                      tryCatch(suppressWarnings(cor.test(squ_res, 
                                                  as.vector(mod$fitted.values),
                                        method = homoCor)), 
                          error = function(e)list(estimate=NA,p.value=NA)))
  } else {
    homoTest <- list("test" = "none", "none")
  }

  fit$normaTest <- normaTest
  fit$homoTest <- homoTest
  #copying the non-linear models (for use in confint calculations)
  fit$model$exp <- expression(c + m*A)
  fit$model$mod.fun <- function(A = A, par = par, model = model) {
    eval(model$exp,list(A=A,c=par[1],m=par[2]))}
  #rss function (for use in confInts of sar_average)
  fit$model$rss.fun <- function(par,data, model, opt = TRUE){
    S <- data$S
    A <- data$A
    res <- sum((S - model$mod.fun(A,par, model = model))^2)
    res
  }
  fit$neg_check <- any(fit$calculated < 0)
  class(fit) <- 'sars' 
  attr(fit, 'type') <- 'fit' 
  return(fit) 
}#end of sar_linear











