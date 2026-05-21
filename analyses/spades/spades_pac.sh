#!/bin/bash

#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle --mem 32G
#SBATCH -n 4
#SBATCH -J spades_pac_cronk
#SBATCH -t 0:15:00

module load SPAdes/4.2.0-GCC-13.3.0

mkdir $SNIC_TMP/pac_reads
mkdir $SNIC_TMP/ill_reads
mkdir $SNIC_TMP/spades_pac

cp ./e_faecium_spades_pac.yaml $SNIC_TMP

cd $SNIC_TMP
cp -r /proj/uppmax2026-1-61/Genome_Analysis/1_Zhang_2017/genomics_data/PacBio/* ./pac_reads
cp -r /proj/uppmax2026-1-61/Genome_Analysis/1_Zhang_2017/genomics_data/Illumina/* ./ill_reads

spades.py --dataset ./e_faecium_spades_pac.yaml -k 33 -o ./spades_pac

mkdir -p /proj/uppmax2026-1-61/nobackup/work/acronk/spades/pac
cp -r ./spades_pac /proj/uppmax2026-1-61/nobackup/work/acronk/spades/pac
