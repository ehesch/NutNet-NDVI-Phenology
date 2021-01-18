## purpose: download, raster and intersect CRU timeseries monthly weather data for NutNet

## script to interface with netcdf datasets
# useful background info here: http://www.image.ucar.edu/GSP/Software/Netcdf/

## first load needed packages
# install.packages(c('chron'))
require(ncdf4)
require(data.table)
require(lubridate)
require(chron)
require(raster)

## cru data from http://data.ceda.ac.uk/badc/cru/data/cru_ts/cru_ts_4.03/data/tmp
# and from http://data.ceda.ac.uk/badc/cru/data/cru_ts/cru_ts_4.03/data/pre
# list.files('../data/CRU')

ncfile <-
  paste0(localdir, '/cru_ts4.04.', timeframe, cruv, '.dat.nc')
nc <- nc_open(ncfile)

## adjust reference time to actual time using chron package
t <- ncvar_get(nc, 'time')
nt <- dim(t)
tunits <- ncatt_get(nc, 'time', 'units')$value
tustr <- strsplit(tunits, " ")
tdstr <- strsplit(unlist(tustr)[3], "-")
tmonth <- as.integer(unlist(tdstr)[2])
tday <- as.integer(unlist(tdstr)[3])
tyear <- as.integer(unlist(tdstr)[1])
realt <-
  chron(
    t,
    origin = c(tmonth, tday, tyear),
    format = c(dates = "m/d/yyyy", times = "h:m:s")
  )

# extract slice and plot with NutNet points for example
sp <- SpatialPoints(sites[, c('longitude', 'latitude')])
cru.rast <- raster(ncfile, band = 2)
plot(cru.rast)
points(sp, cex = 1.5, pch = 16)

# make brick of all layers
cru.brick <- brick(ncfile)
cru.brick
nlayers(cru.brick) == nt # should equal number of months in timeseries

# extract each layer with lat-long points
NutNet.dat <- raster::extract(cru.brick, sp)
dim(NutNet.dat) # sites=rows, times = cols
rownames(NutNet.dat) <- sites$site_code
colnames(NutNet.dat) <- as.character(realt)
# find any NAs
misng <- rownames(NutNet.dat[is.na(NutNet.dat[, 1]), ])
# if none, continue at rehspae

# create a vector holding buffer distances, set to >0 for NA sites
bufvec <- rep(0, length(sites$site_code))
bufvec[sites$site_code %in% misng] <- 40000
bufvec

# re-do intersection
# test with single raster layer
NutNet.dat2 <- raster::extract(cru.rast, sp, buffer = bufvec, fun = mean)
NutNet.dat2[sites$site_code %in% misng]
table(is.na(NutNet.dat2))
# test to see buffer=0 values match no buffer values from brick
plot(NutNet.dat[, 1], NutNet.dat2)
abline(a = 0, b = 1)

# re-do whole brick (may be slower with buffer vector)
# actually throws error with mean function included. https://stat.ethz.ch/pipermail/r-sig-geo/2014-July/021407.html
# no solution found for using mean function with na.rm=T....
NutNet.list <- raster::extract(cru.brick, sp, buffer = bufvec)
# now have list which is a mixture of vectors and matrices
# find non-vector elements
sel <- which(lapply(NutNet.list, is.vector) == FALSE)
# need to reduce two-dimensional list items to one dimension
NutNet.list[sel] <-
  lapply(NutNet.list[sel], function(x)
    apply(x, 2, mean, na.rm = T))
which(lapply(NutNet.list, is.vector) == FALSE)
# NutNet.dat <- do.call(rbind, NutNet.dat)

dim(NutNet.dat) # sites=rows, times = cols
rownames(NutNet.dat) <- sites$site_code
colnames(NutNet.dat) <- as.character(realt)
# find any NAs
which(is.na(NutNet.dat[, 1]))

# reshape the data
NutNet.dat.long <-
  data.table(melt(NutNet.dat, varnames = c('site_code', 'date')))
NutNet.dat.long
setnames(NutNet.dat.long, 3, gsub(' ', '_', paste0(
  cruv, '_', ncatt_get(nc, cruv, 'units')$value
)))
NutNet.dat.long[, plotdate := mdy(date)]
NutNet.dat.long[, month := month(plotdate, abbr = F, label = F)]
NutNet.dat.long[, year := year(plotdate)]
NutNet.dat.long

# # test plot
# require(ggplot2)
# sel <- which(NutNet.dat.long$site_code %in% c('cdcr.us','marc.ar','sereng.tz'))
# p <- ggplot(NutNet.dat.long[sel,], aes_string(x='plotdate',y=names(NutNet.dat.long)[3],col='site_code'))
# # names(NutNet.dat.long)[3]
# p + geom_line()
# #+ facet_wrap(~year)

# output the data
write.csv(
  NutNet.dat.long,
  paste0('./data/weather/CRU-monthly-', cruv, timeframe, 'csv'),
  row.names = F
)

# remove the expanded netcdf file from working directory
# system(paste0('rm ',ncfile))
