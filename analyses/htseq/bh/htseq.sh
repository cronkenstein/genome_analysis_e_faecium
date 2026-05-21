#!/bin/bash

#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle --mem 128G
#SBATCH -n 4
#SBATCH -J htseq_bh_cronk
#SBATCH -t 04:00:00

module load HTSeq/2.1.2-gfbf-2024a

mkdir $SNIC_TMP/paired_aligns
mkdir $SNIC_TMP/single_aligns
mkdir $SNIC_TMP/annotated_assembly
mkdir $SNIC_TMP/paired_counts
mkdir $SNIC_TMP/single_counts

cp -r /proj/uppmax2026-1-61/nobackup/work/acronk/bams/bh/paired/*.bam $SNIC_TMP/paired_aligns
cp -r /proj/uppmax2026-1-61/nobackup/work/acronk/bams/bh/single/*.bam $SNIC_TMP/single_aligns
cp /proj/uppmax2026-1-61/nobackup/work/acronk/prokka/PROKKA_05202026/PROKKA_05202026.gff $SNIC_TMP/annotated_assembly

cd $SNIC_TMP

for sample in $SNIC_TMP/paired_aligns/*.bam; do
	name="${sample##*/}"; name="${name%.*}"; echo "$name"
	htseq-count -f bam -t CDS -i ID -m union $SNIC_TMP/paired_aligns/$name.bam $SNIC_TMP/annotated_assembly/PROKKA_05202026.gff -o $SNIC_TMP/paired_counts/$name.bam > $SNIC_TMP/paired_counts/$name.counts 
done

for sample in $SNIC_TMP/single_aligns/*.bam; do
	name="${sample##*/}"; name="${name%.*}"; echo "$name"
	htseq-count -f bam -t CDS -i ID -m union $SNIC_TMP/single_aligns/$name.bam $SNIC_TMP/annotated_assembly/PROKKA_05202026.gff -o $SNIC_TMP/single_counts/$name.bam > $SNIC_TMP/single_counts/$name.counts
done

mkdir -p /proj/uppmax2026-1-61/nobackup/work/acronk/counts/bh/paired
mkdir -p /proj/uppmax2026-1-61/nobackup/work/acronk/counts/bh/single

cp -r $SNIC_TMP/paired_counts/* /proj/uppmax2026-1-61/nobackup/work/acronk/counts/bh/paired
cp -r $SNIC_TMP/single_counts/* /proj/uppmax2026-1-61/nobackup/work/acronk/counts/bh/single

