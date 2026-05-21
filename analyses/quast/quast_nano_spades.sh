#!/bin/bash

#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle --mem 32G
#SBATCH -n 1
#SBATCH -J quast_nano_spades_cronk
#SBATCH -t 0:15:00

module load QUAST/5.3.0-gfbf-2024a

mkdir $SNIC_TMP/nano_spades_assembly
mkdir $SNIC_TMP/nano_quast_spades
mkdir $SNIC_TMP/reference
cp -r /proj/uppmax2026-1-61/nobackup/work/acronk/spades/nano/spades_nano/* $SNIC_TMP/nano_spades_assembly
cp /proj/uppmax2026-1-61/nobackup/work/acronk/reference_ncbi/GCF_003071425.1_ASM307142v1_genomic.fna $SNIC_TMP/reference
cd $SNIC_TMP/nano_quast_spades
quast -r $SNIC_TMP/reference/GCF_003071425.1_ASM307142v1_genomic.fna -o $SNIC_TMP/nano_quast_spades $SNIC_TMP/nano_spades_assembly/contigs.fasta 
mkdir -p /proj/uppmax2026-1-61/nobackup/work/acronk/nano_spades_assembly/quast
cp -r $SNIC_TMP/nano_quast_spades/* /proj/uppmax2026-1-61/nobackup/work/acronk/nano_spades_assembly/quast
