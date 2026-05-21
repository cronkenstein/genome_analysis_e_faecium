#!/bin/bash

#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle --mem 32G
#SBATCH -n 1
#SBATCH -J mummer_nano_canu_cronk
#SBATCH -t 0:15:00

module load MUMmer/4.0.1-GCCcore-13.3.0 

mkdir $SNIC_TMP/canu_pac
mkdir $SNIC_TMP/mummer_canu
mkdir $SNIC_TMP/reference
cp -r /proj/uppmax2026-1-61/nobackup/work/acronk/canu_pac/pac_e_faecium.contigs.fasta $SNIC_TMP/canu_pac
cp /proj/uppmax2026-1-61/nobackup/work/acronk/reference_ncbi/GCF_003071425.1_ASM307142v1_genomic.fna $SNIC_TMP/reference
cd $SNIC_TMP/mummer_canu
mummer -b -c $SNIC_TMP/reference/GCF_003071425.1_ASM307142v1_genomic.fna $SNIC_TMP/canu_pac/pac_e_faecium.contigs.fasta > $SNIC_TMP/mummer_canu/faecium.mums
mummerplot -R $SNIC_TMP/reference/GCF_003071425.1_ASM307142v1_genomic.fna -Q $SNIC_TMP/canu_pac/pac_e_faecium.contigs.fasta --png --prefix=faecium $SNIC_TMP/mummer_canu/faecium.mums
gnuplot $SNIC_TMP/mummer_canu/faecium.gp
mkdir -p /proj/uppmax2026-1-61/nobackup/work/acronk/canu_pac/mummer
cp -r $SNIC_TMP/mummer_canu/* /proj/uppmax2026-1-61/nobackup/work/acronk/canu_pac/mummer
