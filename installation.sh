#!/usr/bin/env python

conda create --name popamaranth
conda activate popAmaranth
conda config --add channels bioconda
conda config --add channels conda-forge
#download & install htslib ver. 1.9 as instructed on biostars

conda install htslib=1.9=hc238db4_4

#install angsd
conda install angsd=0.921=h3ef6ad9_2
