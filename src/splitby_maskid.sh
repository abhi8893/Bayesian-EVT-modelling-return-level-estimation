#!/bin/bash

# Read in the infile precipitation data
# read -p "Enter infile: `echo $'\n> '`" infile

# Specify the input precipitation data
infile="/home/abhi/Documents/data/OBSERVATION/IMD/precip/1901-2017_ll25.nc"

# Specify output directory
mkdir -p "../output"

# Make a junk directory containing intermediate region files,
mkdir -p "../junk/regions" "../junk/gridfile" "../junk/remapped"

# Specify state-wise mask file
mask_file="../maskfiles/IND_adm2_mask25.nc"

# Get mask file name from mask file path
IFS='/' read -ra mask_name <<< "${mask_file}"
IFS='.' read -ra mask_name <<< "${mask_name[-1]}"
mask_name=${mask_name[0]}

# Generate gridspec file for maskfile
cdo -s -griddes ${mask_file} > "../junk/gridfile/${mask_name}.txt"
grid_file="../junk/gridfile/${mask_name}.txt"

# Get infile name from infile path
IFS='/' read -ra file_name <<< "${infile}"
IFS='.' read -ra file_name <<< "${file_name[-1]}"
file_name=${file_name[0]}

# Remap the infile to maskfile grid if it doesn't already exist
fname="../junk/remapped/${file_name}_r.nc"
if [ ! -f $fname ]; then
	cdo -s -remapbil,${grid_file} ${infile} "../junk/remapped/${file_name}_r.nc"
fi
remapd_infile="../junk/remapped/${file_name}_r.nc"

mkdir -p "../junk/regions/${state}/"

# Make a fldmean time series of the region if it doesn't already exist
cdo -s -setctomiss,-999 -expr,"Band1=(Band1==${id})?0:-999" -selvar,Band1 ${mask_file} "../junk/regions/${state}/${district}mask.nc"
cdo -s -fldmean -add ${remapd_infile} "../junk/regions/${state}/${district}mask.nc" "../junk/regions/${state}/${district}.nc"
rm "../junk/regions/${state}/${district}mask.nc"
