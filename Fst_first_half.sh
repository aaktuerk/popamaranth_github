#!/bin/bash -l
#SBATCH --mem=300gb
#SBATCH --time=24:00:00
#SBATCH --account=UniKoeln
#SBATCH --mail-user=user@mail
#SBATCH -D /path/to/Fst/output/dir
#SBATCH -o /path/to/logs/dir/%j
#SBATCH -o /scratch/aaktuer1/logs/%j
#SBATCH --array=0-4

module load miniconda
conda activate /home/aaktuer1/miniconda3/envs/popamaranth


populations=("caudatus" "hybridus" "hypochondriacus" "quitensis" "cruentus") # populations that match directories containing BAM files
population=${populations[${SLURM_ARRAY_TASK_ID}]}

angsd -b /path/to/"$population".txt \ #this is the same file consisting of the full paths to BAM files (e.g path/to/file1.bam)
                                                                                                  #         path/to/file2.bam
      -anc /path/to/reference_genome.fasta \
      -out $population -dosaf 1 -gl 1
