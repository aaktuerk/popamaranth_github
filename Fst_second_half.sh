#!/bin/bash -l
#SBATCH --mem=300gb
#SBATCH --time=72:00:00
#SBATCH --account=UniKoeln
#SBATCH --mail-user=user@mail
#SBATCH --error /path/to/errors/dir/%j
#SBATCH -D /path/to/Fst/output/dir
#SBATCH -o /path/to/logs/dir/%j
#SBATCH --array=0-9

module load miniconda
conda activate /home/aaktuer1/miniconda3/envs/popamaranth

#start indexing from 1 instead of 0
(($SLURM_ARRAY_TASK_ID++))

#assign pairs to variables pop1 and pop2 from text files containing pairs
pop1=$(awk -v v=$SLURM_ARRAY_TASK_ID 'NR==v {print $1}' /path/to/population_pairs.txt)
pop2=$(awk -v v=$SLURM_ARRAY_TASK_ID 'NR==v {print $2}' /path/to/population_pairs.txt)

#calculate the 2dsfs prior
realSFS /path/to/Fst/output/dir/$pop1.saf.idx /path/to/Fst/output/dir/$pop2.saf.idx >$pop1.$pop2.ml

#prepare the fst
realSFS fst index /path/to/Fst/output/dir/$pop1.saf.idx \
                  /path/to/Fst/output/dir/$pop2.saf.idx \
                  -sfs /path/to/Fst/output/dir/$pop1.$pop2.ml -fstout $pop1.$pop2 #no need to add extensions here
#get the global estimate
realSFS fst stats /path/to/Fst/output/dir/$pop1.$pop2.fst.idx

# get the window calculation
realSFS fst stats2 /path/to/Fst/output/dir/$pop1.$pop2.fst.idx -win 50000 -step 10000 > $pop1.$pop2.fast_slidingwindow
