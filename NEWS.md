

##version 1.3.0
  * Added a set of functions for fitting, evaluating and plotting a range of commonly 
    used piecewise SAR models (see help page and accompanying paper)

##version 1.2.3
  * return shape algorithm fail info to model summary table
  * added grid_start argument option to sar_average and sar_multi
  * edited grid_start to ensure very small starting par values are always included
  * edited how grid_start works and have added a grid_n argument
  * changed the negative exponential model fitting process so that the z parameter can
    be any number rather than constrained between 0 and 1.
  * changed the asymptotic model fitting process so that a negative z-value cannot be returned
  * bug corrections in the confidence interval function, and adapting it to work with
    grid_start
  * Changing model plotting to plot smooth curves by creating 1000 fitted values
    using fitted parameters

## Version 1.2.2
  * bug fix - no AICc option in confidence interval function
  * changed AIC, BIC and AICc equations to be calculated using
    the same approach as the nls and lm functions.

## Version 1.2.1
  * added a warning for when all richness values are identical
  * adding functionality to plot.multi for plotting the multimodel curve on top of the other model fits

## Version 1.2.0
  * bug fixes (bar plot of weight x-axis labels order was incorrect in some cases)
  * logT argument added to lin_pow function (can choose log-transformation function)

## Version 1.1.2
  * bug fixes
  * additional tests added
  * sar_pred() function added for SAR extrapolation
  * negative fitted value check (fit$neg_check) returned for each individual model fit
  * knitr error correction (for CRAN)
  
## Version 1.1.1
 * added vignette
 * bug fixes
 * internal updates
 * Version archived on Zenodo

## Version 1.1.0  
  * sar_multi() split into two functions: sar_multi() and sar_average()
  * New sar_multi() replaces fit_collection()
  * unit testing added
  * functions added to bring up a list of all models with information
  * bug fixes
  
  
## Version 1.0.0

  * Initial version on CRAN
  
