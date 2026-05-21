#!/bin/bash

#SBATCH


module load SAMtools/1.22.1-GCC-13.3.0

mkdir $SNIC_TMP/paired_aligns
mkdir $SNIC_TMP/single_aligns
mkdir $SNIC_TMP/paired_bam
mkdir $SNIC_TMP/single_bam

cp -r /proj/uppmax2026-1-61/nobackup/work/acronk/aligned/bh/paired/*.sam $SNIC_TMP/paired_aligns
cp -r /proj/uppmax2026-1-61/nobackup/work/acronk/aligned/bh/single/*.sam $SNIC_TMP/single_aligns

cd $SNIC_TMP

for sample in $SNIC_TMP/paired_aligns/*.sam; do
	name="${sample##*/}"; name="${name%.*}"; echo "$name"
	samtools sort $sample -o $SNIC_TMP/paired_bam/$name.bam
	samtools index $SNIC_TMP/paired_bam/$name.bam
done

for sample in $SNIC_TMP/single_aligns/*.sam; do
	name="${sample##*/}"; name="${name%.*}"; echo "$name"
	samtools sort $sample -o $SNIC_TMP/single_bam/$name.bam
	samtools index $SNIC_TMP/single_bam/$name/bam
done

mkdir -p /proj/uppmax2026-1-61/nobackup/work/acronk/bams/bh/paired
mkdir -p /proj/uppmax2026-1-61/nobackup/work/acronk/bams/bh/single

cp -r $SNIC_TMP/paired_bam/* /proj/uppmax2026-1-61/nobackup/work/acronk/bams/bh/paired
cp -r $SNIC_TMP/single_bam/* /proj/uppmax2026-1-61/nobackup/work/acronk/bams/bh/single

