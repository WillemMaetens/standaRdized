#' Goodness-of-fit Plot
#'
#' Function to generate a goodness-of-fit plot for output of the fit.distribution function.
#' 
#' @aliases fitplot
#'
#' @usage fitplot(x, date = NULL, main = NULL, xlab = 'data', filename = NULL)
#' 
#' @param x output object of the fit.distribution function
#' @param date reference date for the distribution parameters (optional)
#' @param main plot title (optional)
#' @param xlab X-axis label for plot (optional)
#' @param filename if provided, the plot is written to a .png file with this filename, otherwise console output is used
#'
#' @return A figure displaying goodness-of-fit information.
#' 
#' @seealso \code{\link{standardized.index}}, \code{\link{fitplot}}
#'
#' @examples
#' data(Ukkel_RR)
#' # calculate the total rainfall for all months June
#' monthly.precipitation <- apply.monthly(x=Ukkel_RR,FUN=sum)
#' data <- c(coredata(monthly.precipitation[format(index(monthly.precipitation),'%m')=='06']))
#' # fit gamma distribution to the data?pn
#' fit <- fit.distribution(data=data,distr='gamma',method='mle')
#' # goodness of fit plot
#' fitplot(x=fit,main='June precipitation',xlab='precipitation (mm)')
#' 
#' @importFrom stats rgamma rweibull ecdf
#' @importFrom FAdist rgamma3 rweibull3 rgev
#' @importFrom glogis rglogis
#' @importFrom grDevices png dev.off
#' @importFrom graphics box grid legend lines mtext par plot title 
#' @export fitplot

fitplot <- function(x,date=NULL,main=NULL,xlab='data',filename=NULL){
  data <- attributes(x)$data
  distr <- attributes(x)$distr
  method <- attributes(x)$method
  na.thres <- attributes(x)$na.thres
  
  # create data for the distribution
  params <- x[-which(names(x) %in% c('prob.zero','n.obs','n.na','pct.na','ks.pval','ad.pval'))]
  fit.props <- x[which(names(x) %in% c('prob.zero','n.obs','n.na','pct.na','ks.pval','ad.pval'))]
  
  # determine empirical cumulative density for data
  if(distr=='gamma' | distr=='weibull'){
    data <- data[data!=0]
  }
  data.ecdf <- ecdf(data)(data)
  
  # sample fitted distribution
  if (distr=='glogis' & method=='lmom'){
    distr <- 'glo'
  }
  if(any(is.na(params))){
    distr.data <- NULL
  } else {
    distr.data <- sort(do.call(paste('r',distr,sep=''),c(list(n=10000),as.list(params))))
    distr.ecdf <- ecdf(distr.data)(distr.data)
  }
  
  if(!is.null(filename)){
    if(!grepl(x=filename,pattern='.*\\.png$')){
      filename <- paste0(filename,'.png')
    }
    grDevices::png(filename=filename,width=920,height=920,res=150)
  }
  if(!is.null(main)){
    par(mar=c(5,5,4,2)+0.1)
  } else {
    par(mar=c(5,5,1,2)+0.1)
  }
  # plot empirical CDF
  plot(x=data,y=data.ecdf,xlab=xlab,ylab='CDF',cex.lab=1.5)
  # plot fitted CDF
  if(!is.null(distr.data)){
    lines(x=distr.data,y=distr.ecdf,col='red')
  } else {
    mtext('no distribution fitted',side=3,line=-5,col='red',font=2)
  }
  if(!is.null(main)){
    title(main=main)
  }
  grid()
  legend('topleft',legend=c(paste0('empirical CDF (n=',length(data),')'),'fitted CDF'),lty=c(NA,1),pch=c(1,NA),col=c('black','red'),bty='n')
  # add fit properties
  props <- c(paste('distribution: ',distr,sep=''),
             paste('fit method: ',method,sep=''),
             paste('na.thres: ',na.thres,sep=''),
             'parameters:',
             paste('   ',names(params),': ',round(params,3),sep=''),
             'goodness-of-fit:',
             paste('   ',names(fit.props),': ',round(fit.props,3),sep=''))
  if(!is.null(date)){
    props <- c(paste('date: ',format(date,'%d-%m-%Y'),sep=''),props)
  }
  legend('bottomright',legend=props,bty='n',cex=0.8)
  box()
  if(!is.null(filename)){
    dev.off()
  }
  return(invisible())
}