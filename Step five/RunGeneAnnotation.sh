#!/usr/bin/env bash
#SBATCH --nodes=1
#SBATCH --ntasks=1 # 14 physical cores per task
#SBATCH --mem=80G   # 64GB of RAM
#SBATCH --qos=medium
#SBATCH --time=1-12:00:00
#SBATCH --output=%A_%a.Aq_genes.stdout

#This takes a while!                                             
ml anaconda3/2019.03
source activate /groups/nordborg/projects/suecica/005scripts/001Software/RobinCondaSCRATCH3/

out='/scratch-cbe/users/robin.burns/004Aquilegia/annotate'

ml genemark-et/4.57-gcccore-8.2.0
export AUGUSTUS_CONFIG_PATH='/groups/nordborg/projects/suecica/005scripts/001Software/RobinCondaSCRATCH3/config/'
export GENEMARK_PATH='/software/2020/software/genemark-et/4.57-gcccore-8.2.0:/software/2020/software/perl/5.28.1-gcccore-8.2.0/bin':$GENEMARK_PATH

####First — PROTEIN hints######
#Use proteins from Aq coerulea v3.1 
mkdir ${out}/DLF21
perl /groups/nordborg/projects/suecica/005scripts/001Software/RobinCondaSCRATCH3/bin/startAlign.pl --CPU=8 \
 --dir=${out}/DLF21 \
 --genome=${out}/DLF21.scaffolds_corrhic.masked.fasta \
 --prot=/groups/nordborg/projects/aquilegia/001.common.reference.files/018.Acoerulea_v3.1_annotation_20150930/Acoerulea_396_v3.1_candidate.protein.fa  \
 --ALIGNMENT_TOOL_PATH=/groups/nordborg/projects/suecica/005scripts/001Software/RobinCondaSCRATCH3/bin \
 --prg=exonerate \
 --prg=gth >> ${out}/DLF21/startAlign.stdout 2>>${out}/DLF21/startAlign.stderr
 
perl /groups/nordborg/projects/suecica/005scripts/001Software/RobinCondaSCRATCH3/bin/align2hints.pl \
 --in=${out}/DLF21/align_gth/gth.concat.aln \
 --out=${out}/DLF21/align_gth/hintsAcoerulea_prot.gff \
 --ALIGNMENT_TOOL_PATH=/groups/nordborg/projects/suecica/005scripts/001Software/RobinCondaSCRATCH3/bin \
 --prg=gth >> ${out}/startAlignAt.stdout 2>>${out}/startAlignAt.stderr
 
 
 ####################################################################################################
###TRANSCRIPTS hints
ml java/1.8.0_212
ml rsem/1.3.2-foss-2018b
ml samtools/1.9-foss-2018b
ml bamtools/2.5.1-foss-2018b
ml jellyfish/2.3.0-gcccore-7.3.0
ml bowtie/1.2.2-foss-2018b
#using the bam file we generated from RunStar.sh
cd /scratch-cbe/users/robin.burns/004Aquilegia


Trinity --genome_guided_bam /path/to/bamfile/fromStar \
         --genome_guided_max_intron 10000 --no_salmon \
         --max_memory 59G --CPU 10 --output DLF21_trinity

##map raw merged data and filter transcripts by coverage, tpm=0.5
#Use bowtie not bowtie2 as bowtie2 not an option as aligner

perl /groups/nordborg/projects/suecica/005scripts/001Software/RobinCondaSCRATCH3/bin/align_and_estimate_abundance.pl \
 --transcripts /scratch-cbe/users/robin.burns/004Aquilegia/DLF21_trinity/Trinity-GG.fasta \
 --left /path/to/RNAreads/${acc}.1.fastq.gz --right /path/to/RNAreads/${acc}.2.fastq.gz \
 --SS_lib_type FR  --seqType fq --thread_count 10 \
 --max_ins_size 500 --output_dir /scratch-cbe/users/robin.burns/004Aquilegia/DLF21_trinity/aln_merged_Trinity-GG \
 --trinity_mode --est_method RSEM --aln_method bowtie --prep_reference

perl /groups/nordborg/projects/suecica/005scripts/001Software/RobinCondaSCRATCH3/bin/filter_fasta_by_rsem_values.pl \
        --rsem_output=/scratch-cbe/users/robin.burns/004Aquilegia/DLF21_trinity/aln_merged_Trinity-GG/RSEM.isoforms.results \
         --fasta=/scratch-cbe/users/robin.burns/004Aquilegia/DLF21_trinity/Trinity-GG.fasta \
          --output=/scratch-cbe/users/robin.burns/004Aquilegia/DLF21_trinity/Trinity-GG_filt.fasta \
          --tpm_cutoff=0.5

##make proteins out of transcripts
ml emboss/6.6.0-foss-2018b

TransDecoder.LongOrfs -t /scratch-cbe/users/robin.burns/004Aquilegia/DLF21_trinity/Trinity-GG_filt.fasta

#Now align these proteins to the genome similar to how we aligned proteins from Aq_coerula to our genome
cd /scratch-cbe/users/robin.burns/004Aquilegia/DLF21_trinity/                        

mkdir -p DLF21_trinityproteins
perl /groups/nordborg/projects/suecica/005scripts/001Software/RobinCondaSCRATCH3/bin/startAlign.pl --CPU=16 \
        --dir=/scratch-cbe/users/robin.burns/004Aquilegia/DLF21_trinity/DLF21_trinityprotein \
         --genome=${out}/DLF21.scaffolds_corrhic.masked.fasta \
          --prot=/scratch-cbe/users/robin.burns/004Aquilegia/DLF21_trinity/Trinity-GG_filt.fasta.transdecoder_dir/longest_orfs.pep \
           --ALIGNMENT_TOOL_PATH=/groups/nordborg/projects/suecica/005scripts/001Software/RobinCondaSCRATCH3/bin \
            --prg=gth >> DLF21_trinityprotein/startAlign.stdout 2>> DLF21_trinityprotein/startAlign.stderr

perl /groups/nordborg/projects/suecica/005scripts/001Software/RobinCondaSCRATCH3/bin/align2hints.pl \
 --in=/scratch-cbe/users/robin.burns/004Aquilegia/DLF21_trinity/DLF21_trinityprotein/align_gth/gth.concat.aln \
 --out=/scratch-cbe/users/robin.burns/004Aquilegia/DLF21_trinity/DLF21_trinityprotein/align_gth/hintsDLF21_trinity.gff \
 --ALIGNMENT_TOOL_PATH=/groups/nordborg/projects/suecica/005scripts/001Software/RobinCondaSCRATCH3/bin \
 --prg=gth >> /scratch-cbe/users/robin.burns/004Aquilegia/DLF21_trinity/DLF21_trinityprotein/startAlignAt.stdout 2>> /scratch-cbe/users/robin.burns/004Aquilegia/DLF21_trinity/DLF21_trinityprotein/startAlignAt.stderr
 
 
 ###combine sources
 #source one is homology from reference
 #source two is protein from assembled transcripts aligned to the genome
 #source three is RNA bam file that tells us about exon intron structure of the gene
 
 #get introns from the RNA bam file
 bam2hints --in=/path/to/RNAbam/fromSTAR/ --out=RNAbam2hints.gff
 
cat  RNAbam2hints.gff \
${out}/DLF21/align_gth/hintsAcoerulea_prot.gff \
 /scratch-cbe/users/robin.burns/004Aquilegia/DLF21_trinity/DLF21_trinityprotein/align_gth/hintsDLF21_trinity.gff > ${out}/hints3sourcesDLF21.gff
 
cat ${out}/hints3sourcesDLF21.gff | sort -n -k 4,4 | sort -s -n -k 5,5 | sort -s -k 3,3 | sort -s -k 1,1 | /groups/nordborg/projects/suecica/005scripts/001Software/RobinCondaSCRATCH3/bin/join_mult_hints.pl  > ${out}/hints3sourcesDLF21.sorted.gff
 
#Ok now we have our 3 sources of hints for genes
#Need to make a GFF file from augustus using our hints to predict gene structure

#For this we need to get augustus parameters. This we can give a configuration file of parameters from running BUSCO on our genome
#we give the _parameters.cfg file that is in augustus_output/retraining_parameters/ from running BUSCO

cfg=/path/to/_parameters.cfg
fasta='DLF21.scaffolds_corrhic.fasta'

#augustus needs a species, unfortunately aquilegia is quite far away on species that have trained parameters and that is why we give the re-training file
#still add --species=arabidopsis as some other parameters are needed, and arabidopsis gene structure is well known, but will have to check results manually
#e.g. map the RNA reads to the genes and see if they are aligning correctly to the gene structure exons vs introns start and stop etc
augustus --species=arabidopsis --hintsfile=hints3sourcesDLF21.sort.gff \
 --extrinsicCfgFile=${cfg} ${fasta} > augustus_hints3sourcesDLF21.gff3 #our final file
 












