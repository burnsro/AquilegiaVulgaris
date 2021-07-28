#!/usr/bin/env bash                                                                                                                            
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16  # 14 physical cores per task
#SBATCH --mem=34G   # 64GB of RAM
#SBATCH --qos=medium
#SBATCH --time=0-12:00:00
#SBATCH --output=%A_%a.Ragtag.stdout

#install ragtag with conda
ml anaconda3/2019.03
source activate /groups/nordborg/projects/suecica/005scripts/001Software/RobCondaSCRATCH

ref1=Aqc.fasta 
ref2=Aqo.fasta
query=Aqv.contigs_corrected.fasta

out='/scratch-cbe/users/robin.burns/004Aquilegia/Scaffolds'

# scaffold with multiple references/maps
ragtag.py scaffold -o out_1 ${ref1} ${query}
ragtag.py scaffold -o out_1 ${ref2} ${query}
ragtag.py merge ${query} out_*/*.agp other.map.agp

# Optional use Hi-C to resolve conflicts
ragtag.py merge -b Aqv.hic.sort.bam query.fasta out_*/*.agp other.map.agp
