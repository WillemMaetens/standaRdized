# standaRdized

standaRdized is an R package for the calculation of Standardized Index values (SPI, SPEI, SSI,...) on a daily basis. The Standardized Precipitation Index (SPI) was developed by McKee et al (1993) as a monthly indicator for meteorological drought, and has since become one of the most widely used drought indicators. The procedure has also been applied to time series of precipitation balance (Standardized Precipitation Evapotranspiration Index, SPEI), or streamflow (Standardized Streamflow Index, SSI).

This package provides functions to calculate Standardized Index values on a daily basis in a generalized way: it allows the use of several distributions, aggregation periods, reference periods, and aggregation functions. This allows the calculation of Standardized Index values for a wide range of environmental data (e.g. groundwater levels, temperature,…).

Further details:
    • Standardized Index calculation
    • Function help
    • Applications

## Installation

standaRdized can be installed from [GitHub](https://github.com/WillemMaetens/standaRdized) with:

```r
# install.packages("devtools")
devtools::install_github("WillemMaetens/standaRdized")
```

## Getting started

standaRdized uses [xts (eXtensible Time Series)](https://cran.r-project.org/web/packages/xts/index.html) as input and output objects. Some tutorials for constructing xts objects for data input or working with the standardized  index output can be found [here](https://www.datacamp.com/community/blog/r-xts-cheat-sheet?utm_source=adwords_ppc&utm_campaignid=898687156&utm_adgroupid=48947256715&utm_device=c&utm_keyword=&utm_matchtype=b&utm_network=g&utm_adpostion=1t1&utm_creative=332602034349&utm_targetid=dsa-473406570475&utm_loc_interest_ms=&utm_loc_physical_ms=9040077&gclid=EAIaIQobChMI29a18uCz4QIV2OFRCh1ZxwefEAAYASAAEgLsgfD_BwE) or [here](http://rstudio-pubs-static.s3.amazonaws.com/288218_117e183e74964557a5da4fc5902fc671.html).

Load the package with:

```r
library(standaRdized)
```

The package includes example daily rainfall data for the Ukkel station in Belgium (source: ECA&D). This data can be loaded with:

```r
load(Ukkel_RR)
```

The function fprint() can be used to print xts objects or lists of xts objects in a formatter manner. It prints the xtsAttributes where the metadata for time series are stored, and the head and tail of xts objects.

```r
fprint(Ukkel_RR)
```
