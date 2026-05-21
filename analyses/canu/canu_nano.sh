#!/bin/bash

#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle --mem 32G
#SBATCH -n 4
#SBATCH -J canu_nano_cronk
#SBATCH -t 3:00:00

module load canu/2.3-GCCcore-13.3.0-Java-17
module load SAMtools/1.22.1-GCC-13.3.0

mkdir $SNIC_TMP/nano_reads
mkdir $SNIC_TMP/nano_canu

cp -r /proj/uppmax2026-1-61/Genome_Analysis/1_Zhang_2017/genomics_data/Nanopore/* $SNIC_TMP/nano_reads
cd $SNIC_TMP/nano_canu
canu -d $SNIC_TMP/nano_canu -p nano_e_faecium useGrid=false stopOnLowCoverage=1 genomeSize=3.2m -nanopore $SNIC_TMP/nano_reads/*.fasta.gz

cp -r $SNIC_TMP/nano_canu/* /proj/uppmax2026-1-61/nobackup/work/acronk/canu_nano
