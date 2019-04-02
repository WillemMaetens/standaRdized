#' Get Reference Values for Aggregation Periods
#'
#' Function to get the reference values for aggregation periods
#'
#' @param date date for which the reference values from other years are determined 
#' @param ref.data an xts object containing daily reference data
#' @param agg.length length of the aggregation period in days
#' @param agg.fun function on x to apply to the aggregation data, default is 'sum'
#' @param ref.years years to be used as reference period, default (NULL) is to use all years in ref.data. If ref.years is set to NA, ref.length is used to determine the reference period.
#' @param ref.length if ref.years is null, the ref.length number of years (default = 30) preceding (but not including) the index.out timestamp are used as reference period
#' @param agg.na.thres threshold for the percentage of na values allowed in the aggregation period data, default = 10
#' @param agg.interpolation interpolation type for missing values in individual aggregation period data before applying agg.fun: 'none' (default, NA's are removed), 'linear', 'mean', or 'zeros'
#'
#' @details This function determines the dates in each of the aggregation periods for standardized index calculation, extracts the corresponding data from ref.data and
#' applies an aggregation function to the data of each individual aggregation period (default is 'sum', but any function on x can be passed). Reference periods are set
#' by using the ref.years argument to pass specific years to be used as reference period (e.g. for 1981 to 2010, pass seq(1981,2010)). When ref.years is set to NULL, all
#' possible years in ref.data are used. Alternatively, ref.years can be set to NA, in which case ref.length (default = 30) will determine the length of the reference period
#' preceding, but not including, the date for which the reference values are being determined. Warnings will be generated when the requested reference period falls
#' outside ref.data, or when expected aggregation period dates are not present in ref.data.
#' @return A named vector with reference period data.
#' @seealso \code{\link{standardized.index}}, code{\link{fit.distribution}}
#'
#' @examples
#' data(Ukkel_RR)
#' date <- as.Date('2018-07-01')
#' # get all reference values for the 30 day-period preceding date
#' get.reference.values(date = date, ref.data = Ukkel_RR, agg.length=30)
#' # get 1981-2010 reference values for the 30 day-period preceding date
#' get.reference.values(date = date, ref.data = Ukkel_RR, agg.length=30, ref.years=seq(1981,2010))
#' # get the previos 30 years' reference values for the 30 day-period preceding date
#' get.reference.values(date = date, ref.data = Ukkel_RR, agg.length=30, ref.years=NA, ref.length=30)
#' 
#' @import xts
#' @export

get.reference.values <- function(date,
                                 ref.data,
                                 agg.length,
                                 agg.fun = 'sum',
                                 ref.years = NULL,
                                 ref.length = 30,
                                 agg.na.thres = 10,
                                 agg.interpolation = c('none', 'linear','mean','zeros')){
  # match optional arguments
  agg.interpolation <- match.arg(agg.interpolation)
  
  # determine ref.years if needed
  if(is.null(ref.years)){
    ref.period.warn <- FALSE
    # get all possible ref.years from ref.data
    ref.years <- as.integer(unique(format(index(ref.data),'%Y')))
    # exclude the year corresponding to date
    if(as.integer(format(date,'%Y')) %in% ref.years){
      ref.years <- ref.years[-which(ref.years == as.integer(format(date,'%Y')))]
    }
  } else if (any(is.na(ref.years))){
    ref.period.warn <- TRUE
    # get ref.years based on ref.length
    ref.years <- seq(from=as.integer(format(date,'%Y'))-ref.length,as.integer(format(date,'%Y'))-1,by=1)
  } else {
    ref.period.warn <- TRUE
  }
  
  # determine end dates for all aggregation periods
  mon.date <- format(date, '%m-%d')
  ref.dates <- as.Date(paste0(ref.years, '-', mon.date),format = '%Y-%m-%d')
  # return 28 February for non-existing leap days
  if(mon.date == '02-29'){
    ref.dates[is.na(ref.dates)] <- as.Date(paste0(ref.years[is.na(ref.dates)], '-02-28'),format = '%Y-%m-%d')
  }
  
  # get aggregation period data for ref.dates
  ref.values <- lapply(X = ref.dates,
                       data = ref.data,
                       agg.length = agg.length,
                       agg.fun = agg.fun,
                       agg.na.thres = agg.na.thres,
                       agg.interpolation = agg.interpolation,
                       period.warn = ref.period.warn,
                       FUN = get.aggregated.value)
  which.null <- which(sapply(X=ref.values,FUN=is.null))
  if(length(which.null)>0){
    ref.values <- ref.values[-which.null]
    ref.values <- unlist(ref.values)
    names(ref.values) <- format(ref.dates[-which.null])
  } else {
    ref.values <- unlist(ref.values)
    names(ref.values) <- format(ref.dates)
  }
  return(ref.values)
}