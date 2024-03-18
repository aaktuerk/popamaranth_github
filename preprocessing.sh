#!/bin/bash -l

#retrieve the species data from github
wget -O path/to/download/samples_AGDB_withcoordinates.txt replace_with_github_download_link

#modify table identifiers to match the names of the bam files
## remove everything up to "_"
{ head -n 1 path/to/samples_AGDB_withcoordinates.txt && tail -n +2 path/to/samples_AGDB_withcoordinates.txt | cut -d'_' -f2; } > samples_AGDB_modified.txt

##remove spaces in column 4
sed -i -E 's/(.*\t.*\t.*\t)(PI|Ames|AMA) ([0-9]+)/\1\2\3/' /path/to/samples_AGDB_modified.txt


#Retrieve bam files
{
read
IFS=$'\t '
while read -r accession col2 species col4 pop rest; do

#make directory for each species
species_dir=/create/path/to/"$pop"
    mkdir -p "$species_dir"

#collect bam files in corresponding directories
cp /path/to/"$accession".bam "$species_dir"
done
} < samples_AGDB_modified.txt
