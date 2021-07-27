#!/usr/bin/env bash                                                                                                                            
#SBATCH --nodes=1
#SBATCH --ntasks=16  # 14 physical cores per task
#SBATCH --mem=74GB   # 64GB of RAM
#SBATCH --qos=medium
#SBATCH --time=0-16:00:00
#SBATCH --output=%A_%a.ReMapPopte2.stdout


out='/scratch-cbe/users/robin.burns/004Aquilegia/PCRfree'
raw='path/to/pcr/free/fastq'
acc='DLF21' #accession name

#Make sure jellyfish is in your conda environment
ml anaconda3/2019.03
source activate /groups/nordborg/projects/suecica/005scripts/001Software/RobinCondaSCRATCH3/

cd $out
zcat ${raw}/${acc}.1.fastq.gz | jellyfish count /dev/fd/0 -C -o ${acc}_21mer -m 21 -t 16 -s 5G
jellyfish histo -h 3000000 -o ${acc}test_21merhisto ${acc}_21mer


