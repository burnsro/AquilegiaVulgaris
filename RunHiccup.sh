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

#After running hiccup process sam file to visualize in juicer for rearrangements
#In juicer you can make rearrangments manually and it will output a text file of what regions to change 
#Can then run juicer script to make these changes to the fasta file
#other tools for visualization also available (but juicer more interactive)


cd $outdir
#here each assembled scaffold is called "chr" followed by number
sam=Aq.hiccup.sam
preinput=Aq.hiccup.txt

samtools view $sam | awk 'BEGIN {FS="\t"; OFS="\t"} {name1=substr($1,0,length($1)-2); str1=and($2,16); chr1=$3; pos1=$4; mapq1=$5; getline; name2=substr($1,0,length($1)-2); str2=and($2,16); chr2=$3; pos2=$4; mapq2=$5; if(name1==name2) { if (chr1>chr2){print name1, str2, "chr" chr2, pos2,1, str1, "chr" chr1, pos1, 0, mapq2, mapq1} else {print name1, str1, "chr" chr1, pos1, 0, str2, "chr" chr2, pos2 ,1, mapq1, mapq2}}}' | awk  '{gsub("\tchr\t","\thpv\t",$0); print;}' | sort -k3,3d -k7,7d > $preinput


cat $preinput | sort -k3,3d -k7,7d -k4,4n -k8,8n > ${preinput}.sort.txt


ml java/1.8.0_212

java -Xmx80g -jar ${juicerdir}/juicer_tools_1.13.02.jar pre ${preinput}.sort.txt -r 5000,10000,20000,25000,50000 ${preinput}.hic /path/to/text/file/with/sizes/of/chromosomes
#eg chr1 32000000
