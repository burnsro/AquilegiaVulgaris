#!/usr/bin/env bash                                                                                                                            
#SBATCH --nodes=1
#SBATCH --ntasks=16  # 14 physical cores per task
#SBATCH --mem=64G   # 64GB of RAM
#SBATCH --qos=short
#SBATCH --time=0-06:00:00
#SBATCH --output=%A_%a.STAR.stdout
#SBATCH --array=1-20

CONDA_ENVS_PATH='/groups/nordborg/projects/suecica/005scripts/001Software'
CONDA_PKGS_DIRS=/opt/anaconda/pkgs='/groups/nordborg/projects/suecica/005scripts/001Software'
cd /groups/nordborg/projects/suecica/005scripts/001Software
ml anaconda3/2019.03
source activate RobinCondaSCRATCH/
ml bamtools/2.5.1-foss-2018b

#For mapping RNA reads in order to generate transcriptome to annotate genes

raw='path/to/rnareads/fastq'
out='/scratch-cbe/users/robin.burns/004Aquilegia/RNA'
temp='/scratch-cbe/users/robin.burns/tmp'
samples=$raw'/mysamples'
acc=$(awk "NR==$SLURM_ARRAY_TASK_ID" $samples)
echo $acc

ref=DLF21.scaffolds_corrHiC.fasta #assembly after manual correction with HiC

#index genome
mkdir -p $out/myAqgenome
STAR --runThreadN 8 \
  --runMode genomeGenerate \
  --genomeDir $out/myAqgenome \
  --genomeFastaFiles ${out}/${ref}  \
  --sjdbFileChrStartEnd $out/DLF21.chromosomes.StartEnd.txt \ #need to make
  --genomeSAindexNbases 3

#Map reads
STAR --runThreadN 16 \
        --genomeDir $out/myAqgenome \
        --readFilesIn $raw/$acc.1.fastq.gz $raw/$acc.2.fastq.gz \
        --readFilesCommand zcat \
        --outFilterMultimapNmax 1 \
        --outSAMtype BAM SortedByCoordinate \
         --outFileNamePrefix ${acc}_STARPaired1hitSorted \
        --outReadsUnmapped Fastx \
        --outSAMorder Paired 



