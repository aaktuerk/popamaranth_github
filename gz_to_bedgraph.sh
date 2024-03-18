#!/bin/bash -l
#This is to convert files to .bedgraph format

POPULATION=("caudatus" "hybridus" "hypochondriacus" "quitensis" "cruentus")

for population in "${POPULATION[@]}"
do

awk '{print $1, $2, $4, $5, $9, $14}' "/path/to/.thetasWindow.gz/files/${population}.thetasWindow.gz.pestPG" |  sed '1d;$d' | sed 's/(/\t/g' | sed 's/)/\t/g' | sed 's/,/\t/g' | awk '{print $7, $5, $6, $8, $9, $10, $11}' | sed 's/ /\t/g' | sort -k1,1 -k2,2n > "/path/to/.thetasWindow.gz/files/${population}_tests.bedgraph"

done
