#!/bin/bash

#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle --mem 32G
#SBATCH -n 1
#SBATCH -J quast_pac_cronk
#SBATCH -t 0:15:00

module load QUAST/5.3.0-gfbf-2024a

mkdir $SNIC_TMP/pac_ill_assembly
mkdir $SNIC_TMP/pac_spades_quast
mkdir $SNIC_TMP/reference
cp -r /proj/uppmax2026-1-61/nobackup/work/acronk/spades/pac/spades_pac/* $SNIC_TMP/pac_ill_assembly
cp /proj/uppmax2026-1-61/nobackup/work/acronk/reference_ncbi/GCF_003071425.1_ASM307142v1_genomic.fna $SNIC_TMP/reference
cd $SNIC_TMP/pac_spades_quast
quast -r $SNIC_TMP/reference/GCF_003071425.1_ASM307142v1_genomic.fna -o $SNIC_TMP/pac_spades_quast $SNIC_TMP/pac_ill_assembly/contigs.fasta 
mkdir -p /proj/uppmax2026-1-61/nobackup/work/acronk/spades/pac/quast/
cp -r $SNIC_TMP/pac_spades_quast/* /proj/uppmax2026-1-61/nobackup/work/acronk/spades/pac/quast 
