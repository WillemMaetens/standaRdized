#' Standardized Index Calculation
#'
#' Function to calculate a Standardized Index (SPI, SPEI, SSI,...) for a time series.
#'
#' @param data an xts object containing observed daily data
#' @param index.out vector of dates for which the standardized index is to be calculated
#' @param agg.length length of the aggregation period in days
#' @param agg.fun function on x to apply to the aggregation data, default is 'sum'
#' @param ref.data an xts object containing daily reference data, default is data itself
#' @param distr name of the distribution to be fitted, see details
#' @param method distribution fitting method, 'mle' (default) for maximum likelihood estimation, 'lmom' for L-moments
#' @param params xts containing the reference distribution parameters for each index.out, if not specified (NULL) or missing for specific dates, they are calculated, in which case ref.data should be specified
#' @param ks.thres threshold p-value for the Kolmogrov-Smirnov test, if rejected, the value is set to NA, default= NULL (test not applied)
#' @param ad.thres threshold p-value for the Anderson-Darling test, if rejected, the value is set to NA, default= NULL (test not applied)
#' @param ref.years years to be used as reference period, default is to use all years in ref.data. If NULL, ref.length is used
#' @param ref.length if ref.years is null, the ref.length number of years (default = 30) preceding (but not including) the index.out timestamp are used as reference period
#' @param ref.na.thres threshold for the percentage of NA values allowed in reference period data, default = 10\%
#' @param agg.na.thres threshold for the percentage of na values allowed in the aggregation period data, default = ref.na.thres
#' @param agg.interpolation interpolation type for missing values in aggregation data for an individual reference period element: 'none' (default, NA's are removed), 'linear', 'mean', or 'zeros'
#' @param digits number of digits for rounding the resulting standardized index values, default = 2
#' @param output.attrs determines what is attached as xtsAttributes: 'some' (default) adds function settings, and 'all' adds function settings, data and ref.data attributes and the reference values for index.out, aggregation values for index.out, and an xts object containing the fitted parameters
#'
#' @details The argument distr can be either: 'gamma' for the gamma distribution, 'gamma3' for the 3-parameter gamma distribution, 'weibull' for the 'weibull distribution,
#' 'weibull3' for the 'weibull distribution, 'gev' for the Generalized Extreme Value distribution, or 'glo' for the shifted log-logistic distribution.
#' The \link{fit.distribution} function is used internally to calculate distribution fits, alternatively the parameters for the reference distribution can be supplied via the params argument.
#'
#' @return An xts object containing the standardized index values.
#' @seealso \code{\link{fit.distribution}}, \code{\link{get.reference.values}}, \code{\link{fprint}}
#'
#' @examples
#' data(Ukkel_RR)
#' # since this is rainfall data, we are calculating the SPI
#' # calculate SPI-1 for July 2011, which is approximated by setting agg.length to 30 days
#' SPI_1 <- standardized.index(data=Ukkel_RR,agg.length=30,index.out=index(Ukkel_RR['2011-07']))
#' fprint(SPI_1)
#' # calculate SPI-3 for July 2011, which is approximated by setting agg.length to 90 days
#' SPI_3 <- standardized.index(data=Ukkel_RR,agg.length=90,index.out=index(Ukkel_RR['2011-07']))
#' fprint(SPI_3)
#' 
#' @import xts
#' @importFrom stats qnorm pgamma pweibull
#' @importFrom FAdist pgamma3 pweibull3 pgev
#' @export

standardized.index <- function(data,
                               index.out,
                               agg.length,
                               agg.fun = 'sum',
                               ref.data = data,
                               distr = c('gamma', 'gamma3', 'weibull', 'weibull3', 'gev', 'glogis'),
                               method = c('mle', 'lmom'),
                               params = NULL,
                               ks.thres = NULL,
                               ad.thres = NULL,
                               ref.years = NULL,
                               ref.length = 30,
                               ref.na.thres = 10,
                               agg.na.thres = ref.na.thres,
                               agg.interpolation = c('none', 'linear','mean','zeros'),
                               digits = 2,
                               output.attrs = c('some','all')){
  # make sure indexes are Date objects
  index.out <- as.Date(index.out)
  index(data) <- as.Date(index(data))
  index(ref.data) <- as.Date(index(ref.data))
  
  # match optional arguments
  distr <- match.arg(distr)
  method <- match.arg(method)
  agg.interpolation <- match.arg(agg.interpolation)
  output.attrs <- match.arg(output.attrs)
  
  # determine dates for params calculation
  if (is.null(params)) {
    index.params.calc <- index.out
  } else {
    index(params) <- as.Date(index(params))
    index.params.calc <- index.out[!(index.out %in% index(params))]
  }
  
  # get distribution data for index.params.calc
  if (length(index.params.calc) > 0) {
    # get reference period data for all index.params.calc
    ref.values <- lapply(X = index.params.calc,
                         ref.data = ref.data,
                         agg.length = agg.length,
                         agg.fun = agg.fun,
                         ref.years = ref.years,
                         ref.length = ref.length,
                         agg.na.thres = agg.na.thres,
                         agg.interpolation = agg.interpolation,
                         FUN = get.reference.values)
    names(ref.values) <- format(index.params.calc)
    # fit distribution to ref data
    suppressWarnings(params.calc <- lapply(X = ref.values,
                                           distr = distr,
                                           method = method,
                                           na.thres = ref.na.thres,
                                           FUN = fit.distribution))
    params.calc <- xts(do.call(rbind, params.calc), order.by = index.params.calc)
  }
  
  # merge params and params.calc if needed
  if (is.null(params)) {
    params <- params.calc
  } else if (length(index.params.calc) > 0) {
    params <- rbind(params[which(index(params) %in% index.out)], params.calc)
  } else {
    params <- params[which(index(params) %in% index.out)]
  }
  
  # get aggregation period values for index.out
  agg.values <- lapply(X = index.out,
                       data = data,
                       agg.length = agg.length,
                       agg.fun = agg.fun,
                       agg.na.thres = agg.na.thres,
                       agg.interpolation = agg.interpolation,
                       period.warn = TRUE,
                       FUN = get.aggregated.value)
  which.null <- which(sapply(X=agg.values,FUN=is.null))
  if(length(which.null)>0){
    agg.values[-which.null] <- NA
  }
  agg.values <- xts(unlist(agg.values),order.by = index.out)
  colnames(agg.values) <- 'value'
  
  # set distr to 'glo' for distr='glogis' and method='lmom' (see fit.distribution function)
  if (distr == 'glogis' & method == 'lmom') {
    distr <- 'glo'
  }
  
  # calculate values for standardized index
  SI.values <- apply(X = coredata(cbind(agg.values, params)),
                     MARGIN = 1,
                     distr = distr,
                     ks.thres = ks.thres,
                     ad.thres = ad.thres,
                     FUN = function(x, distr, ks.thres, ad.thres) {
                       # check for rejected distrbutions according to ks.thres and ad.thres if needed
                       if (!is.null(ks.thres)) {
                         if(!is.na(x['ks.pval'])){
                           if (x['ks.pval'] < ks.thres) {
                             return(NA)
                           }
                         } else {
                           return(NA)
                         }
                       }
                       if (!is.null(ad.thres)) {
                         if(!is.na(x['ks.pval'])){
                           if (x['ad.pval'] < ad.thres) {
                             return(NA)
                           }
                         } else {
                           return(NA)
                         }
                       }
                       # get distribution percentile for agg.values (agg.p)
                       args <- as.list(x[-which(names(x) %in% c('prob.zero','n.obs','n.na','pct.na','ks.pval','ad.pval'))])
                       names(args)[which(names(args) == 'value')] <- 'q'
                       agg.p <- do.call(what = paste('p', distr, sep = ''), args = args)
                       # calculate qnorm for agg.p
                       if (!is.null(agg.p)) {
                         if (distr %in% c('gamma', 'weibull')) {
                           # gamma and weibull distribution require special treatment of zero values
                           value <- qnorm(x['prob.zero'] + ((1 - x['prob.zero']) * agg.p))
                         } else {
                           value <- qnorm(agg.p)
                         }
                         if (is.finite(value)) {
                           return(value)
                         } else {
                           return(NA)
                         }
                       } else {
                         return(NA)
                       }
                     })
  
  # construct standardized.index xts object
  SI <- xts(round(SI.values, digits), order.by = index.out)
  colnames(SI) <- 'value'
  
  # assign xts attributes to SI
  xtsAttributes(SI)$agg.length <- agg.length
  xtsAttributes(SI)$agg.fun <- agg.fun
  xtsAttributes(SI)$distr <- distr
  xtsAttributes(SI)$method <- method
  xtsAttributes(SI)$ks.thres <- ks.thres
  xtsAttributes(SI)$ad.thres <- ad.thres
  xtsAttributes(SI)$ref.years <- ref.years
  xtsAttributes(SI)$ref.length <- ref.length
  xtsAttributes(SI)$ref.na.thres <- ref.na.thres
  xtsAttributes(SI)$agg.na.thres <- agg.na.thres
  xtsAttributes(SI)$agg.interpolation <- agg.interpolation
  if (output.attrs=='all'){
    xtsAttributes(SI)$data.attrs <- xtsAttributes(data)
    xtsAttributes(SI)$ref.data.attrs <- xtsAttributes(ref.data)
    xtsAttributes(SI)$ref.values <- ref.values
    xtsAttributes(SI)$agg.values <- agg.values
    xtsAttributes(SI)$params <- params
  }
  
  # output
  return(SI)
}