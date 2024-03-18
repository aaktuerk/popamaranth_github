#!/bin/bash -l
#generate size file

faSize -detailed path/to/reference_genome.fasta > reference_genome.fasta.sizes

#convert bedGraph files to BigWig

for bedGraph_file in /path/to/.thetasWindow.gz/files/*
do

#retrieve name
temp=$(basename "$bedGraph_file")

#skip the first line
tail -n +2 "$bedGraph_file" > $temp

#convert from bedgraph to bigwig
bedGraphToBigWig ${temp} reference_genome.fasta.sizes /path/to/.thetasWindow.gz/files/${temp%.bedgraph}.bw

done
