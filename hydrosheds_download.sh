#!/bin/bash

# Author: Simon Moulds, sm510@ic.ac.uk
# Date: 27/05/2014
# Version: 1.0
# Licence: GPL v3

###############################################################################

# This script downloads hydrosheds data using the GNU Wget package. You will
# need to adjust some variables to suit your application. See the README
# for further guidance.

# Notes:
# (1) if your study area includes more than one continent and/or more than one 
#     hemisphere you will need to run the script more than once
# (2) it is recommended that you run the script in safe mode initially 
#     (safemode=TRUE) to check that the variables you provide work
# (2) before downloading any data check the data server to see whether the 
#     product has already been downloaded by someone else

###############################################################################
# modify these variables as required

product=sa_con_3s_grid
continent=AS 
lon_hemisphere=e
lat_hemisphere=n
lon0=75
lon1=80
lat0=20
lat1=20
safemode=FALSE
path=~/data/india/upperganga

###############################################################################

# url of hydrosheds product
url=http://earlywarning.usgs.gov/hydrodata/${product}/${continent}

for (( lon=${lon0}; lon<=${lon1}; lon+=5 )); do
    for (( lat=${lat0}; lat<=${lat1}; lat+=5 )); do
        basename=$(echo ${lat_hemisphere}$(printf "%02d" $lat)${lon_hemisphere}$(printf "%03d" $lon))       
        filename=${basename}_con_grid.zip       
        exist=$(wget --spider --quiet ${url}/${filename} && echo TRUE || echo FALSE)
        if [ $exist = TRUE ]; then
            if [ $safemode = TRUE ]; then
                echo $filename exists
            else
                wget --directory-prefix=$path ${url}/${filename}
                unzip ${path}/${filename} -d $path
                rm ${path}/HydroSHEDS_TechDoc_v10.pdf
                # convert file to geotiff
                gdal_translate ${path}/${basename}_con/${basename}_con -of GTiff \
                    ${path}/${basename}_con.tif
            fi
        else 
            echo $filename does not exist
        fi
    done
done
