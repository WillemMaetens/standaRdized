#' Get Aggregated Value
#'
#' Function to get the aggregated value for a single aggregation period
#'
#' @param date date for which the aggregated value is determined 
#' @param data an xts object containing daily data
#' @param agg.length length of the aggregation period in days
#' @param agg.fun function on x to apply to the aggregation data, default is 'sum'
#' @param agg.na.thres threshold for the percentage of na values allowed in the aggregation period data, default = 10
#' @param agg.interpolation interpolation type for missing values in individual aggregation period data before applying agg.fun: 'none' (default, NA's are removed), 'linear', 'mean', or 'zeros'
#' @param period.warn if TRUE, a warning is when the requested aggregation period contains dates not included in data
#'
#' @details This function determines the dates in an aggregation period for standardized index calculation, extracts the corresponding data and
#' applies an aggregation function to the data (default is 'sum', but any function on x can be passed).
#' @return A numeric value giving the aggregated value for the aggregation period
#' @seealso \code{\link{standardized.index}}, \code{\link{get.reference.values}}
#'
#' @examples
#' data(Ukkel_RR)
#' date <- as.Date('2018-07-01')
#' # get the aggregated value values for the 30 day-period preceding date
#' get.aggregated.value(date = date, data = Ukkel_RR, agg.length=30)
#' 
#' @import xts
#' @importFrom stats approx
#' @export

get.aggregated.value <- function(date,
                                 data,
                                 agg.length,
                                 agg.fun = 'sum',
                                 agg.na.thres = 10,
                                 agg.interpolation = c('none', 'linear','mean','zeros'),
                                 period.warn=TRUE){
  # match optional arguments
  agg.interpolation <- match.arg(agg.interpolation)
  
  # determine aggregation period
  from <- date - as.difftime(agg.length - 1, units = 'days')
  to <- date
  if (from < index(data)[1] | to > index(data)[dim(data)[1]]) {
    if(period.warn){
      # allow data outside reference period to be treated as NA, but give a warning
      warning('part of reference period outside data')
    } else {
      # treat this reference period as invalid
      return(NULL)
    }
  }
  # get data
  data <- data[paste(from,to, sep = '/')]
  dates <- seq(from=from,to=to,by = as.difftime(1, units = 'days'))
  if(!all(dates %in% index(data))){
    warning(paste0('some reference period dates are not in data: ',paste(format(dates[!(dates %in% index(data))]),collapse=', ')))
  }
  x <- c(coredata(merge(xts(order.by = dates), data, join = 'left')))
  if (length(x) != 0) {
    pct.na <- (length(which(is.na(x))) / length(x)) * 100
    if (pct.na <= agg.na.thres) {
      if (any(is.na(x))) {
        if(!all(is.na(x))){
          if (agg.interpolation == 'none') {
            # remove NA values
            x <- x[!is.na(x)]
          } else if (agg.interpolation == 'linear') {
            # linear interpolation of missing values
            x[which(is.na(x))] <- approx(x=x,xout=which(is.na(x)),rule=2)$y
          } else if (agg.interpolation == 'mean') {
            # replace missing values by the mean of the observed values
            x[which(is.na(x))] <- mean(x = x, na.rm = TRUE)
          } else if (agg.interpolation == 'zeros') {
            # replace missing values by zero
            x[which(is.na(x))] <- 0
          }
        } else {
          return(as.numeric(NA))
        }
      }
    }
    # apply aggregation function
    x <- do.call(what=agg.fun,args=list(x=x))
    return(x)
  } else {
    return(as.numeric(NA))
  }
}