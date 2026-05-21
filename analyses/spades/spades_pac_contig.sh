#!/bin/bash

#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle --mem 32G
#SBATCH -n 4
#SBATCH -J spades_pac_cronk
#SBATCH -t 0:15:00

module load SPAdes/4.2.0-GCC-13.3.0

mkdir $SNIC_TMP/pac_contigs
mkdir $SNIC_TMP/ill_reads
mkdir $SNIC_TMP/spades_pac

cd $SNIC_TMP
cp /proj/uppmax2026-1-61/nobackup/work/acronk/canu_pac/pac_e_faecium.contigs.fasta $SNIC_TMP/pac_contigs
cp -r /proj/uppmax2026-1-61/Genome_Analysis/1_Zhang_2017/genomics_data/Illumina/* ./ill_reads

spades.py --isolate -1 $SNIC_TMP/ill_reads/E745-1.L500_SZAXPI015146-56_1_clean.fq.gz -2 $SNIC_TMP/ill_reads/E745-1.L500_SZAXPI015146-56_2_clean.fq.gz --untrusted-contigs $SNIC_TMP/pac_contigs/pac_e_faecium.contigs.fasta  -k 33 -o ./spades_pac

mkdir -p /proj/uppmax2026-1-61/nobackup/work/acronk/spades/pac
cp -r ./spades_pac /proj/uppmax2026-1-61/nobackup/work/acronk/spades/pac
