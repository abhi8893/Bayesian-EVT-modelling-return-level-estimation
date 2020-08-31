#!/bin/bash
nline=`echo $'\n.'`
nline=${cr%.}

read -p "Enter shapefile path: $nline" shp_file
read -p "Enter FID: $nline" FID
read -p "out_dir: $nline" out_dir

IFS='/' read -ra shp_name <<< "${shp_file}"
IFS='.' read -ra shp_name <<< "${shp_name[-1]}"
shp_name=${shp_name[0]}

#gdal_rasterize -te 66.375, 6.375, 100.125, 38.625 -tr 0.25 0.25 -burn 0 0 -init -999 ${shp_file} ${out_dir}/${shp_name}.tif
gdal_rasterize -tr 0.01 0.01 -burn 0 0 -init -999 ${shp_file} ${out_dir}/${shp_name}.tif
gdal_rasterize -a ${FID} -sql "select ${FID}, * from ${shp_name}" ${shp_file} ${out_dir}/${shp_name}.tif
gdal_translate -of netCDF -co "FORMAT=NC4" ${out_dir}/${shp_name}.tif ${out_dir}/${shp_name}.nc
cdo -setctomiss,-999 ${out_dir}/${shp_name}.nc ${out_dir}/${shp_name}_mask25.nc

rm ${out_dir}/${shp_name}.nc ${out_dir}/${shp_name}.tif
