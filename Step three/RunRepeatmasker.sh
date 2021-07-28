#!/usr/bin/env bash                                                                                                                            
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16  # 14 physical cores per task
#SBATCH --mem=34G   # 64GB of RAM
#SBATCH --qos=medium
#SBATCH --time=0-12:00:00
#SBATCH --output=%A_%a.RM.stdout

ml anaconda3/2019.03
source activate /groups/nordborg/projects/suecica/005scripts/001Software/RobCondaSCRATCH

out='/scratch-cbe/users/robin.burns/004Aquilegia'
ref='Aq.scaffolds_ragtag.fasta'
telib='Aq.classifiedTEs.fasta' #renamed TE fasta file after running RepeatModeler and then RepeatClassifier

cd $out
RepeatMasker -e ncbi -pa 16 -lib $out/$telib -a -dir ${out} ${out}/${ref}
