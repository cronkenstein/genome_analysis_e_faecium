#!/bin/bash

#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle --mem 32G
#SBATCH -n 1
#SBATCH -J prokka_cronk
#SBATCH -t 0:15:00

module load prokka/1.14.5-gompi-2024a 

mkdir $SNIC_TMP/canu_pac
mkdir $SNIC_TMP/prokka

cp -r /proj/uppmax2026-1-61/nobackup/work/acronk/canu_pac/pac_e_faecium.contigs.fasta $SNIC_TMP/canu_pac
cd $SNIC_TMP/prokka
prokka $SNIC_TMP/canu_pac/pac_e_faecium.contigs.fasta
mkdir -p /proj/uppmax2026-1-61/nobackup/work/acronk/prokka
cp -r $SNIC_TMP/prokka/* /proj/uppmax2026-1-61/nobackup/work/acronk/prokka
