#' @name Ukkel_RR
#' @aliases Ukkel_RR
#' @docType data
#' @rdname Ukkel_RR
#' @title Ukkel Daily Precipitation
#' @description Daily precipitation (mm/day) for Ukkel from 1898 to 2002.
#' @format An xts object on 1880-01-01/2019-02-28 containing:
#' \tabular{llll}{
#' [,'value'] \tab num \tab Precipitation \tab (mm/day)\cr
#' }
#' With xts attributes:
#' \tabular{lll}{
#' $ name     : \tab chr \tab "Ukkel" \cr
#' $ country  : \tab chr \tab "Belgium" \cr
#' $ element  : \tab chr \tab "RR" \cr
#' $ unit     : \tab chr \tab "mm" \cr
#' $ longitude: \tab num \tab 4.36638889 \cr
#' $ latitude : \tab num \tab 50.8 \cr
#' $ elevation: \tab num \tab 100 \cr
#' $ source   : \tab chr \tab "ECA\&D (ecad.eu)" \cr
#' }
#' @details xts object containing daily rainfall at the Ukkel station in Belgium
#' @source Royal Meteorological Institute of Belgium (RMI) via \url{https://www.ecad.eu/}
#' @keywords datasets
#' @examples
#' data(Ukkel_RR)
#' str(Ukkel_RR)
#' fprint(Ukkel_RR)

NULL