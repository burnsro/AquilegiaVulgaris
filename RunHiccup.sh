#!/usr/bin/env bash                                                             
#SBATCH --nodes=1
#SBATCH --ntasks=8  # 14 physical cores per task
#SBATCH --mem=84G   # 64GB of RAM
#SBATCH --qos=short
#SBATCH --time=0-06:00:00
#SBATCH --output=%A_%a.Hiccup_synthetic.stdout


ml hicup/0.6.1
ml bowtie2/2.3.5.1-foss-2018b
ml samtools/1.4-foss-2018b
ml r/3.5.1-foss-2018b

myconf='aquilegia_configuration.conf'


#first make digested file of the genome using the restriction enzyme used in the hic library
#here dpnii as it is not altered by methylation 
#Make sure the genome is repeat masked first and the genome has been indexed with bowtie2

hicup_digester --genome Aq_maskedDisgested --re1 ^GATC,DpnII ${Aqgenome}

#Check configuration file and change paths accordingly of digestion file and index file and where the raw reads and the output will go
hicup --config ${myconf} --threads 8
