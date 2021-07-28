#!/usr/bin/env bash
#SBATCH --nodes=1
#SBATCH --ntasks=16  # 14 physical cores per task
#SBATCH --mem=64G   # 64GB of RAM
#SBATCH --qos=medium
#SBATCH --time=1-12:00:00
#SBATCH --output=%A_%a.AthRepeatModeler.stdout

#make sure pre-requisites are installed from https://github.com/Dfam-consortium/RepeatModeler
#use conda to help install some pre-requisites 
#We are using RepeatModeler2 which annotates LTRs better
ml anaconda3/2019.03
source activate /groups/nordborg/projects/suecica/005scripts/001Software/RobinCondaSCRATCH/

out='/scratch-cbe/users/robin.burns/004Aquilegia'

#First build database
BuildDatabase -engine ncbi -name Aq_database Aq.ragoo_scaffolds.fasta

perl /groups/nordborg/projects/suecica/005scripts/001Software/RepeatModeler-2.0.1/RepeatModeler -database Aq_database -pa 16 -LTRStruct \
-rmblast_dir /software/2020/software/rmblast/2.10.0-foss-2018b/bin/ \
-repeatmasker_dir /groups/nordborg/projects/suecica/005scripts/001Software/RepeatMasker/ 


#Classify the repeat sequences to TE families
cd /path/to/RepeatModeler/output
perl /groups/nordborg/projects/suecica/005scripts/001Software/RepeatModeler-2.0.1/RepeatClassifier -consensi consensi.fa \
-stockholm families.stk -engine ncbi -repeatmasker_dir /groups/nordborg/projects/suecica/005scripts/001Software/RepeatMasker/

#Blast consensus TE sequences that are from the Unkown families to genes from available reference genomes and 
#to centromere repeats and rDNA repeats to classify repeats a bit better
#RepeatModeler is giving back all repetative sequences in the genome but they are not always TEs though they may also be mobile.
