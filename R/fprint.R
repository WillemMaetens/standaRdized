#' Formatted xts Printing
#'
#' Print the xts attributes, data head and data tail of xts objects or xts objects in lists in a formatted manner.
#'
#' @param x an xts object to be printed
#' @param nlines approximate number of object rows to print (divided over head and tail of object) with a minimum of 4, if negative, the entire object is printed
#'
#' @seealso \code{\link{xts}}
#'
#' @examples
#' data(Ukkel_RR)
#' fprint(Ukkel_RR)
#'
#' @importFrom utils head
#' @importFrom utils capture.output str
#' @export

fprint <- function(x, nlines = 10) {
  # function to traverse a list emulating list printing behaviour
  listcrawler <- function(iter = NULL,
                          x,
                          name = '',
                          nlines = nlines) {
    if (is.null(iter)) {
      iter <- ''
    }
    if (inherits(x, 'xts')) {
      cat(iter, name, '\n')
      .fprintfun(x = x, nlines = nlines)
      cat('\n')
    } else if (inherits(x, 'list')) {
      cat(iter, '\n')
      iter <- paste(iter, '[[', c(1:length(x)), ']]', sep = '')
      if (!is.null(names(x))) {
        names <- names(x)
      } else {
        names <- rep('', length(x))
      }
      mapply(
        FUN = listcrawler,
        iter = iter,
        x = x,
        name = names,
        nlines = nlines)
    } else {
      warning('non-xts or list object at ', iter, ':')
      cat(iter)
      print(x)
    }
    return(invisible())
  }
  # print
  if (inherits(x, 'list')) {
    if (length(x) == 0) {
      print(x)
    } else {
      listcrawler(x = x, nlines = nlines)
    }
  } else {
    listcrawler(x = x, nlines = nlines)
  }
  return(invisible())
}

.fprintfun <- function(x, nlines = 10) {
  if (inherits(x, 'xts')) {
    cat(paste('Attributes:', sep = ''))
    if (!is.null(xts::xtsAttributes(x))) {
      attributes <- t(data.frame(lapply(X = xts::xtsAttributes(x), FUN = .format.attr), row.names = ''))
      attributes[nchar(attributes[, 1]) > 75] <- paste(substr(attributes[nchar(attributes[, 1]) > 50], 1, 50), '... [truncated]', sep = '')
      print(attributes, quote = 'FALSE')
    } else {
      cat('\nNULL\n')
    }
    cat('\nData:\n')
    if (!is.null(dim(x))) {
      if (dim(x)[1] != 0) {
        if (nlines >= 0 & dim(x)[1] > nlines) {
          if (nlines < 4) {
            warning('minimum for nlines is 4')
            nlines <- 4
          }
          print(utils::head(x, nlines / 2))
          options(warn = -1)
          cat('...')
          tail <- tail(x, floor(nlines / 2))
          colnames(tail) <-
            gsub(
              x = colnames(tail),
              pattern = '.?',
              replacement = ' '
            )
          print(tail)
          options(warn = 0)
        } else {
          print(x)
        }
        return(invisible())
      } else {
        print(x)
      }
    } else {
      print(numeric(0))
    }
  } else {
    stop('x is not an xts object')
  }
}

.format.attr <- function(x){
 if (xts::is.timeBased(x)) {
    x <- format(x)
    x <- paste(x, collapse = ', ')
  } else if (inherits(x,c('integer','numeric','logical',"character"))){
    x <- paste(x, collapse = ', ')
  } else {
    x <- paste(gsub(x=capture.output(str(x)),pattern='\\s+',replacement=' '), collapse = '')
  }
  return(paste(': ',x))
}