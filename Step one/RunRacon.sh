#!/usr/bin/env bash
#SBATCH --nodes=1
#SBATCH --ntasks=16  # 14 physical cores per task
#SBATCH --mem=40G   # 64GB of RAM
#SBATCH --qos=short
#SBATCH --time=0-04:00:00
#SBATCH --output=%A_%a.11B02Ragon.stdout
# SBATCH --array=1-167

CONDA_ENVS_PATH='/groups/nordborg/projects/suecica/005scripts/001Software'
CONDA_PKGS_DIRS=/opt/anaconda/pkgs='/groups/nordborg/projects/suecica/005scripts/001Software'
#ml anaconda3/2019.03
#conda create -p /groups/nordborg/projects/suecica/005scripts/001Software/RobinCondaSCRATCH python=2.7 #or 3.6 just run this command once then source it
cd /groups/nordborg/projects/suecica/005scripts/001Software
ml anaconda3/2019.03
source activate RobinCondaSCRATCH/
ml samtools/1.9-foss-2018b

#out='/scratch-cbe/users/robin.burns/011Alyrata/11BO2_Assembly'
#out='/scratch-cbe/users/robin.burns/007pbreads'
#ref=$out'/11B02.contigs.fasta'
#ref=$out/'Asue_genome.HiCGeneticMap.270919.fasta'
#ref='/groups/nordborg/projects/suecica/001Assembly/004Asuecica/Asue_genome.HiCGeneticMap.270919.Popte2.fasta'
#raw_reads='/groups/nordborg/projects/nordborg_rawdata/Alyrata/001Minion/11B02/20191009_0859_MN25531_FAL00802_39713699/fastq_pass'
#mkdir /scratch-cbe/users/robin.burns/01011B02/pbreads_ref
out='/scratch-cbe/users/robin.burns/001Alyrata/longreads'
out2='/scratch-cbe/users/robin.burns/001Alyrata/longreads/11B02'
raw_reads='/groups/nordborg/projects/nordborg_rawdata/Alyrata/001Minion/11B02/20191009_0859_MN25531_FAL00802_39713699/fastq_pass'
ref=$out'/11B02_240920.fasta'

samples=$raw_reads'/myfastq'
acc=$(awk "NR==$SLURM_ARRAY_TASK_ID" $samples)
echo $acc


ngmlr -t 16 -r $ref -q $raw_reads/$acc -o $out/${acc}.sam -x ont
#mv $out/${acc}.sam $out2/.
#samtools view -@ 16  -bh -t $ref.fai -o  $out2/${acc}.bam  $out2/${acc}.sam
#samtools sort -@ 16 -o ${out2}/${acc}.sort.bam ${out2}/${acc}.bam
#samtools index ${out2}/${acc}.sort.bam

#ml bamtools/2.5.1-foss-2018b
#cd $out2
#ls *sort.bam > mybams
#bamtools merge -list mybams -out 11B02.bamtoolsmerged.bam
#cd $out
#rm *.tmp*
#samtools sort -@ 16 -o 11B02.bamtoolsmerged.sort.bam 11B02.bamtoolsmerged.bam
#samtools index 11B02.bamtoolsmerged.sort.bam 
#ASS3.bamtoolsmerged.bam
#variantCaller --algorithm=arrow -j8 ${out}/arrow/11B02.bamtoolsmerged.sort.bam \
# -r $out/11B02.contigs.fasta -o ${out}/11B02.contigs_arrow.gff    \
# -o ${out}/11B02.contigs_arrow.fasta -o ${out}/11B02.contigs_arrow.fastq


sniffles -m 11B02.bamtoolsmerged.sort.bam -v  11B02.sniffles.vcf --max_num_splits 2 -l 50 -t 8 -f 1.0

sniffles -m 11B02.bamtoolsmerged.sort.bam -b 11B02.sniffles.bed --max_num_splits 2 -l 50 -t 8 -n 10 

#samtools view -h -o ${out}/arrow/11B02.bamtoolsmerged.sort.sam ${out}/arrow/11B02.bamtoolsmerged.sort.bam
#racon -t 8 ${raw_reads}/11B02_all.fastq ${out}/arrow/11B02.bamtoolsmerged.sort.sam $out/11B02.contigs.fasta > $out/11B02.contigs_racon.fasta 
