#Canu submits scripts to the queue by itself to run simpy type bash RunCanu.sh
ml java/11.0.2                                                                                                                                 
ml gnuplot/5.2.5-foss-2018b
ml canu/1.8-foss-2018b-perl-5.28.0

canu -assemble \
        gridOptions="--nodes=1 --mem-per-cpu=4g --cpus-per-task=12 --time=7-00:00:00 --qos=long" \
        -p "DLF21" \ #name of the accession being assembled
        -d /scratch-cbe/users/robin.burns/004Aquilegia \
        genomeSize=Xm \ #use the PCR free reads and the software findGSE to estimate genome size and replace "X" 
        -nanopore-raw  /path/to/fastqfiles/*fastq
