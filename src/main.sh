#!/bin/bash

oldpwd=$(pwd)
for id in {1..10..1}; do
	export id

	# Get district names and state names from the region_list file
	region_list="../output/region_list/region_list.csv"
	IFS=','
	readarray -t state_names < <(cut -d, -f 2 ${region_list})
	readarray -t district_names < <(cut -d, -f 4 ${region_list})

	state=${state_names[id]}
	district=${district_names[id]}

	echo $state
	echo $district
	export state
	export district

	# Create a field mean region file if it doesn't exist
	fname="../junk/regions/${state}/${district}.nc"
	if [ ! -f $fname ]; then
		bash splitby_maskid.sh
	fi

	mkdir -p "../output/plots/${state}/"

	cd EXtreme
	Rscript "main.R" $state $district

	cd $oldpwd
done
