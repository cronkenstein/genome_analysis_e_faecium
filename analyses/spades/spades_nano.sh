#!/bin/bash

#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle --mem 32G
#SBATCH -n 4
#SBATCH -J spades_nano_cronk
#SBATCH -t 0:15:00

module load SPAdes/4.2.0-GCC-13.3.0

mkdir $SNIC_TMP/nano_reads
mkdir $SNIC_TMP/ill_reads
mkdir $SNIC_TMP/spades_nano

cp ./e_faecium_spades_nano.yaml $SNIC_TMP

cd $SNIC_TMP
cp -r /proj/uppmax2026-1-61/Genome_Analysis/1_Zhang_2017/genomics_data/Nanopore/* ./nano_reads
cp -r /proj/uppmax2026-1-61/Genome_Analysis/1_Zhang_2017/genomics_data/Illumina/* ./ill_reads

spades.py --isolate --dataset ./e_faecium_spades_nano.yaml -k 33 -o ./spades_nano

mkdir -p /proj/uppmax2026-1-61/nobackup/work/acronk/spades/nano
cp -r ./spades_nano /proj/uppmax2026-1-61/nobackup/work/acronk/spades/nano
