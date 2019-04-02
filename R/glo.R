#' Generalized Logistic Distribution
#'
#  Generalized Logistic Distribution CDF.
#'
#' @aliases glo pglo rglo
#'
#' @param q vector of quantiles
#' @param n number of observatins
#' @param xi distribution location parameter
#' @param alpha distribution scale parameter
#' @param kappa distribution shape parameter
#'
#' @details Generalized Logistic Distribution CDF definition as a wrapper for cdfglo analogous to other pdistr functions.
#' 
#' @return pglo gives the distribution function and rglo generates random deviates.
#' 
#' @seealso \code{\link{cdfglo}}, \code{\link{fit.distribution}}
#'
#' @examples
#' data(Ukkel_RR)
#' # calculate the total rainfall for all months June
#' monthly.precipitation <- xts::apply.monthly(x=Ukkel_RR,FUN=sum)
#' data <- c(coredata(monthly.precipitation[format(index(monthly.precipitation),'\%m')=='06']))
#' # fit generalized logistic distribution to the data
#' fit <- fit.distribution(data=data,distr='glo',method='lmom')
#' fit
#'
#' @name glo
#' @rdname glo
#' @importFrom stats runif
#' @importFrom lmomco cdfglo quaglo
#' @export

pglo <- function(q,xi,alpha,kappa){
  if(!is.na(q)){
    para=list(type='glo',para=c(xi=xi,alpha=alpha,kappa=kappa),source='parglo')
    res <- lmomco::cdfglo(x=q,para=para)
    return(res)
  } else {
    return(NA)
  }  
}

#' @rdname glo
#' @export

rglo <- function(n,xi,alpha,kappa){
  # generate random exceedance probabilities
  f <- runif(n=n,min=0,max=1)
  para=list(type='glo',para=c(xi=xi,alpha=alpha,kappa=kappa),source='parglo')
  res <- quaglo(f=f,para=para,paracheck=TRUE)
}