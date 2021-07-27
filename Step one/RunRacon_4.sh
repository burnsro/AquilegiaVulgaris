#!/usr/bin/env bash
#SBATCH --nodes=1
#SBATCH --ntasks=16  # 14 physical cores per task
#SBATCH --mem=40G   # 64GB of RAM
#SBATCH --qos=short
#SBATCH --time=0-04:00:00
#SBATCH --output=%A_%a.AqRagon.stdout
#SBATCH --array=1-N 

#### N in the batch job is how many fastq files was generated from Nanopore, change accordingly

#have nglmr in your conda env
ml anaconda3/2019.03
source activate /groups/nordborg/projects/suecica/005scripts/001Software/RobinCondaSCRATCH/
ml samtools/1.9-foss-2018b


out='/scratch-cbe/users/robin.burns/001Alyrata/longreads'

raw_reads='/path/to/longreads/fastq' #minion puts fastq in fastq_pass folder
ref=$out'/DLF21_Canu_contigs.fasta' #contigs, make sure it is indexed with samtools faidx

samples=$raw_reads'/allmyfastq' #each fastq on a seperate line
acc=$(awk "NR==$SLURM_ARRAY_TASK_ID" $samples)
echo $acc


ngmlr -t 16 -r $ref -q $raw_reads/$acc -o $out/${acc}.sam -x ont
samtools view -@ 16  -bh -t $ref.fai -o  $out/${acc}.bam  $out/${acc}.sam
samtools sort -@ 16 -o ${out}/${acc}.sort.bam ${out}/${acc}.bam
samtools index ${out}/${acc}.sort.bam

#####################Do next steps outside of batch job###########
ml bamtools/2.5.1-foss-2018b

ls ${out}/*sort.bam > mybams
bamtools merge -list mybams -out DLF21.bamtoolsmerged.bam

samtools sort -@ 16 -o DLF21.bamtoolsmerged.sort.bam DLF21.bamtoolsmerged.bam
samtools index DLF21.bamtoolsmerged.sort.bam 

cat ${raw_reads}/*fastq > $out/DLF21_all.fastq #put all fastq together 
samtools view -h -o ${out}/DLF21.bamtoolsmerged.sort.bam ${out}/DLF21.bamtoolsmerged.sort.sam
racon -t 16 ${raw_reads}/DLF21_all.fastq ${out}/DLF21.bamtoolsmerged.sort.sam ${ref} > $out/${ref}_racon.fasta #corrected contigs 
rm $out/DLF21_all.fastq

