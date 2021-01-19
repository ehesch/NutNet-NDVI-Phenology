NutNet Phenology with NDVI
================
Ellen Esch
18 January 2021

# Overview

## This document walks through the steps necessary to:

  - 
Please change `process_raw` equal to `TRUE` if you need to download and
process raw data. In most cases, this will likely remain as `FALSE`,
becuase intermediate (processed) files *are* stored on GitHub.

You’ll need to read in the location of the sites being used in this
analysis. You’ll also need to store some files on your local machine, so
set a path to your desired
location.

``` r
sites <- read_csv('./data/NutNetGreening_2019.10.15_ee.csv', col_types = cols())
localdir <- "/Users/ellen/Desktop/Ellen/Guelph/Project_Andrew phenology/pheno_localdata"

process_raw <- FALSE #TRUE
```

And just for fun, here is a map of the sites in this analysis

![](Processing-Data_files/figure-gfm/sitemap-1.png)<!-- -->

## Process weather & climate data

**Skip to step 5 if not needing to re-create data. Steps 1-4 walk
through raw data downloads.**

1)  Download montly [precipitation
    data](http://data.ceda.ac.uk/badc/cru/data/cru_ts/cru_ts_4.04/data/pre)
    onto your local machine (large files). You will have to either
    create an account or log in. Download 4 time periods (you want the
    files with the ‘nc’ in the name):

<!-- end list -->

  - 1981-1990
  - 1991-2000
  - 2001-2010
  - 2011-2019

<!-- end list -->

    ## [1] "not processing raw data"

2)  Repeat with montly [temperature
    data](http://data.ceda.ac.uk/badc/cru/data/cru_ts/cru_ts_4.04/data/tmp).

<!-- end list -->

    ## [1] "not processing raw data"

3)  Write a dataframe with merged monthly temperature and precipitation
    data

<!-- end list -->

    ## [1] "not processing raw data"

4)  Download [30 year averages from
    WorldClim](https://www.worldclim.org/data/worldclim21.html) onto
    your local machine. Download the most detailed spatial level (30
    seconds) for:

<!-- end list -->

  - average temperature (tavg\_30s)
  - precipitaiton (preci\_30s)

<!-- end list -->

    ## [1] "not processing raw data"

5)  Look at the monthly deviations from the long term average.

A plot illustrate a problem here (with an easy solution). At Cowichan
there are no consistent longitudinal trends, but it is obvious that
worldclim (long term average) and ceda (montly) data don’t always
necessarily align (expected becuase they have differnt methods,
resolutions, etc.). This suggests that ceda should be used to calculate
averages (1981-2019, 39 years) as well as anomolies.

![](Processing-Data_files/figure-gfm/weatherdev-1.png)<!-- -->

Indeed, using CEDA data to calculate averages as well as anomolies
proves to be a much more logical metric. Cowichan data seems *much* more
logical now.

![](Processing-Data_files/figure-gfm/ceda_avg-1.png)<!-- -->

## Nitrogen deposition data

Download data onto local machine. **NOTE: this is not currently working;
projections issue not registering….**
