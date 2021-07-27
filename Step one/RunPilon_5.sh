#!/usr/bin/env bash                                                             
#SBATCH --nodes=1
#SBATCH --ntasks=16  # 14 physical cores per task
#SBATCH --mem=90G   # 64GB of RAM
#SBATCH --qos=medium
#SBATCH --time=1-05:00:00
#SBATCH --output=%A_%a.Pilon.stdout

#Pilon is a jar file you need to download and run using Java
#Download from BroadInstitute https://github.com/broadinstitute/pilon/wiki

source activate /groups/nordborg/projects/suecica/005scripts/001Software/RobinCondaSCRATCH/
ml samtools/1.9-foss-2018b
ml bwa/0.7.17-foss-2018b 
ml java/11.0.2

illumina_reads='/path/to/PCR_free/fastq'
out='/scratch-cbe/users/robin.burns/004Aquilegia'

acc='DLF21'
ref=$out'/DLF21_racon.fasta' #corrected contigs using long reads with racon


bwa index $out/$ref
bwa mem -t 16 -M -U 15 -R '@RG\tID:'$acc'\tSM:'$acc'\tPL:Illumina\tLB:'$acc $ref ${illumina_reads}/${acc}.1.fastq.gz ${illumina_reads}/${acc}.2.fastq.gz > $out/$acc.sam
samtools faidx $ref
samtools view -@ 16  -bh -t $ref.fai -o  $out/${acc}.bam  $out/${acc}.sam
samtools sort -@ 16 -o ${out}/${acc}.sort.bam ${out}/${acc}.bam
samtools index ${out}/${acc}.sort.bam
samtools stats $out/${acc}.bam > $out/${acc}.stats
cd $out
java -Xmx70g -Djava.io.tmpdir=/scratch-cbe/users/robin.burns/tmp/ -jar /groups/nordborg/projects/suecica/005scripts/001Software/pilon-1.23.jar \
--genome ${ref} \
--frags ${out}/$acc.sort.bam \
--output DLF21.contigs_raconpilon.dir \ #finished corrected assembly
--outdir ${out} --threads 16 --K 73  

#you can re run pilon for another round, but no more than twice. Once is arguably enough. 
