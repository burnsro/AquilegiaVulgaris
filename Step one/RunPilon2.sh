#!/usr/bin/env bash                                                             
#SBATCH --nodes=1
#SBATCH --ntasks=16  # 14 physical cores per task
#SBATCH --mem=110G   # 64GB of RAM
#SBATCH --qos=medium
#SBATCH --time=1-05:00:00
#SBATCH --output=%A_%a.11B21.stdout

CONDA_ENVS_PATH='/groups/nordborg/projects/suecica/005scripts/001Software'
CONDA_PKGS_DIRS=/opt/anaconda/pkgs='/groups/nordborg/projects/suecica/005scripts/001Software'
#ml anaconda3/2019.03
#conda create -p /groups/nordborg/projects/suecica/005scripts/001Software/RobinCondaSCRATCH python=2.7 #or 3.6 just run this command once then source it
cd /groups/nordborg/projects/suecica/005scripts/001Software
ml anaconda3/2019.03
source activate RobinCondaSCRATCH/
ml samtools/1.9-foss-2018b
ml bwa/0.7.17-foss-2018b 
ml java/11.0.2

illumina_reads='/groups/nordborg/projects/nordborg_rawdata/Alyrata/PCR_free'
out='/scratch-cbe/users/robin.burns/01111B21/pilon'
mkdir -p $out
acc='11B21_merged'
ref=$out'/11B21.contigs_raconpilon2.fasta'
#ref='/groups/nordborg/projects/nordborg_rawdata/Alyrata/11B21.contigs_racon.fasta'
cd /groups/nordborg/projects/nordborg_rawdata/Alyrata/
bwa index $ref
bwa mem -t 16 -M -U 15 -R '@RG\tID:'$acc'\tSM:'$acc'\tPL:Illumina\tLB:'$acc $ref ${illumina_reads}/${acc}.1.fastq.gz ${illumina_reads}/${acc}.2.fastq.gz > $out/$acc.sam
samtools faidx $ref
samtools view -@ 16  -bh -t $ref.fai -o  $out/${acc}.bam  $out/${acc}.sam
#samtools sort -@ 16 -o ${out}/${acc}.sort.bam ${out}/${acc}.bam
#samtools index ${out}/${acc}.sort.bam
samtools stats $out/${acc}.bam > $out/${acc}.stats
#cd $out
#java -Xmx70g -Djava.io.tmpdir=/scratch-cbe/users/robin.burns/tmp/ -jar /groups/nordborg/projects/suecica/005scripts/001Software/pilon-1.23.jar --genome ${ref} --frags ${out}/$acc.sort.bam --output 11B21.contigs_raconpilon2 --outdir ${out} --threads 16 --K 73  
