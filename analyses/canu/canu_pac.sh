#!/bin/bash

#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle --mem 32G
#SBATCH -n 4
#SBATCH -J canu_pac_cronk
#SBATCH -t 3:00:00

module load canu/2.3-GCCcore-13.3.0-Java-17
module load SAMtools/1.22.1-GCC-13.3.0 

mkdir $SNIC_TMP/pac_canu
cd $SNIC_TMP/pac_canu
canu -d /proj/uppmax2026-1-61/nobackup/work/acronk/canu_pac/new_run -p Efacium genomeSize=3.2m useGrid=false bamOutput=false -pacbio-raw /proj/uppmax2026-1-61/Genome_Analysis/1_Zhang_2017/genomics_data/PacBio/*.fastq.gz
