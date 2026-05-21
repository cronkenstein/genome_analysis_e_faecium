#!/bin/bash

#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle --mem 32G
#SBATCH -n 4
#SBATCH -J bwa_cronk
#SBATCH -t 00:15:00

module load bwa-mem2/2.3-GCC-13.3.0

mkdir $SNIC_TMP/assembly
mkdir $SNIC_TMP/rna_paired
mkdir $SNIC_TMP/rna_single
mkdir $SNIC_TMP/rna_paired_aligned
mkdir $SNIC_TMP/rna_single_aligned

# need to copy over the annotated assembly fasta
cp -r /proj/uppmax2026-1-61/nobackup/work/acronk/prokka/PROKKA_04282026/PROKKA_04282026.fna $SNIC_TMP/assembly
# need to copy over all of the paired end rnaseqs
cp -r /proj/uppmax2026-1-61/Genome_Analysis/1_Zhang_2017/transcriptomics_data/RNA-Seq_BH/trimmed/*_paired_*.fastq.gz $SNIC_TMP/rna_paired
# need to copy over all of the single end rnaseqs
cp -r /proj/uppmax2026-1-61/Genome_Analysis/1_Zhang_2017/transcriptomics_data/RNA-Seq_BH/trimmed/*_single_*.fastq.gz $SNIC_TMP/rna_single
# need to then run the bwa-mem2 index on the assembly
bwa-mem2 index -p indexed $SNIC_TMP/assembly/PROKKA_04282026.fna
# run a file search on all files in the rnaseqs for paired end and single separately to compose a space delimited string of rnaseq files
RNA_SEQ_PAIRED=""
for file in $(find $SNIC_TEMP/rna_paired -type f); do
    # Append the filename to the string
    RNA_SEQ_PAIRED+="$file "
done

# Remove trailing space
RNA_SEQ_PAIRED=${RNA_SEQ_PAIRED% }
echo $RNA_SEQ_PAIRED

RNA_SEQ_SINGLE=""
for file in $(find $SNIC_TEMP/rna_single -type f); do
    # Append the filename to the string
    RNA_SEQ_SINGLE+="$file "
done

# Remove trailing space
RNA_SEQ_SINGLE=${RNA_SEQ_SINGLE% }
echo $RNA_SEQ_SINGLE
# pass the string of rnaseq files as an arg to the bwa-mem2 mem command
bwa-mem2 mem -p indexed $RNA_SEQ_PAIRED -o $SNIC_TMP/rna_paired_aligned
bwa-mem2 mem -p indexed $RNA_SEQ_SINGLE -o $SNIC_TMP/rna_single_aligned
# copy the results of both seq types back to the proj dir
mkdir -p /proj/uppmax2026-1-61/nobackup/work/acronk/aligned/bh/paired
mkdir -p /proj/uppmax2026-1-61/nobackup/work/acronk/aligned/bh/single

cp -r $SNIC_TMP/rna_paired_aligned /proj/uppmax2026-1-61/nobackup/work/acronk/aligned/bh/paired
cp -r $SNIC_TMP/rna_single_aligned /proj/uppmax2026-1-61/nobackup/work/acronk/aligned/bh/single
