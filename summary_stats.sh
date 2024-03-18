#!/bin/bash -l
#SBATCH --mem=300gb
#SBATCH --time=16:00:00
#SBATCH --account=UniKoeln
#SBATCH --mail-user=user@mail
#SBATCH --error /errors/dir/%j
#SBATCH -D /output/dir
#SBATCH -o /logs/dir/%j
#SBATCH --array=0-4

module load miniconda
conda activate /path/to/conda/env



populations=("caudatus" "hybridus" "hypochondriacus" "quitensis" "cruentus")

#iterate over populations list
population=${populations[${SLURM_ARRAY_TASK_ID}]}

NIND=3 # minimum number of individuals with data to be included in the analysis (recommended at least 1/3 of the total number of samples)


### Calculate summary statistics
## Substep 1. site allele frequency calculation

 angsd -out $population \
-bam /path/to/$population.txt \ #this is a file consisting of the full paths to BAM files (e.g path/to/file1.bam)
-doSaf 1 \                                                                           #         path/to/file2.bam
-GL 2 \
-P 24 \
-anc /path/to/reference_genome.fasta \
-remove_bads 1 \
-minMapQ 30 \
-minQ 20 \
-minInd $NIND

## Substep 2. calculate SFS, use fold in case of not knowing the ancestral state

  realSFS  $population.saf.idx \
 -P 4 \
 -fold 1 > $population.sfs

## calculation of theta per site

 realSFS \
 saf2theta $population.saf.idx \
 -sfs $population.sfs \
 -outname $population.thetas.idx  \
 -fold 1 \
 -P 4


## Substep 3. calculation of statistics from theta estimations. (If folded site frequency spectrum was used, only tD, tP and Tajima are correctly estimated)

 thetaStat \
 do_stat $population.thetas.idx \
 -win 5000 \
 -step 5000 \
 -outnames $population.thetasWindow.gz
