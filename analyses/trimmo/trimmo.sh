#!/bin/bash

#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle --mem 128G
#SBATCH -n 4
#SBATCH -J trimmo_cronk
#SBATCH -t 4:00:00

# Load the fastqc module
module load FastQC/0.12.1-Java-17 
# Load the trimmer module
module load Trimmomatic/0.39-Java-17 

ADAPTERS=/sw/arch/eb/software/Trimmomatic/0.39-Java-17/adapters/TruSeq3-PE.fa

mkdir -p $SNIC_TMP/bh/rna_seq
mkdir -p $SNIC_TMP/serum/rna_seq
mkdir -p $SNIC_TMP/trimmed/bh
mkdir -p $SNIC_TMP/trimmed/serum
mkdir -p $SNIC_TMP/trimmed/pre/bh
mkdir -p $SNIC_TMP/trimmed/pre/serum
mkdir -p $SNIC_TMP/trimmed/post/bh
mkdir -p $SNIC_TMP/trimmed/post/serum

# need to copy over all of the paired end rnaseqs
cp -r /proj/uppmax2026-1-61/Genome_Analysis/1_Zhang_2017/transcriptomics_data/RNA-Seq_BH/raw/*.fastq.gz $SNIC_TMP/bh/rna_seq
cp -r /proj/uppmax2026-1-61/Genome_Analysis/1_Zhang_2017/transcriptomics_data/RNA-Seq_Serum/raw/*.fastq.gz $SNIC_TMP/serum/rna_seq
cd $SNIC_TMP/trimmed

# First run fastqc on bh
for seq in $(find $SNIC_TMP/bh/rna_seq -type f); do
	fastqc $seq -o $SNIC_TMP/trimmed/pre/bh
done
# Run fastqc on serum
for seq in $(find $SNIC_TMP/serum/rna_seq -type f); do
	fastqc $seq -o $SNIC_TMP/trimmed/pre/serum
done
# Run trimmomatic on bh
for seq in $(find $SNIC_TMP/bh/rna_seq -type f); do
	echo $seq
    	name="${seq##*/}"; name="${name%.*}"; echo "$name"
    	echo $name
	if [[ $name =~ ([a-zA-Z0-9]+)(_1) ]];
    	then
      		name=${BASH_REMATCH[1]}
      		echo $name
		trimmomatic PE $seq "${SNIC_TMP}/bh/rna_seq/${name}_2.fastq.gz" "${SNIC_TMP}/trimmed/bh/${name}_1_paired.fastq.gz" "${SNIC_TMP}/trimmed/bh/${name}_2_paired.fastq.gz" "${SNIC_TMP}/trimmed/bh/${name}_1_single.fastq.gz" "${SNIC_TMP}/trimmed/bh/${name}_2_single.fastq.gz" ILLUMINACLIP:$ADAPTERS:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36
    	else
      		echo "did not match"
    	fi
done
# Run trimmomatic on serum
for seq in $(find $SNIC_TMP/serum/rna_seq -type f); do
	echo $seq
        name="${seq##*/}"; name="${name%.*}"; echo "$name"
        echo $name
        if [[ $name =~ ([a-zA-Z0-9]+)(_1) ]];
        then
                name=${BASH_REMATCH[1]}
                echo $name
                trimmomatic PE $seq "${SNIC_TMP}/serum/rna_seq/${name}_2.fastq.gz" "${SNIC_TMP}/trimmed/serum/${name}_1_paired.fastq.gz" "${SNIC_TMP}/trimmed/serum/${name}_2_paired.fastq.gz" "${SNIC_TMP}/trimmed/serum/${name}_1_single.fastq.gz" "${SNIC_TMP}/trimmed/serum/${name}_2_single.fastq.gz" ILLUMINACLIP:$ADAPTERS:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36
        else
                echo "did not match"
        fi
done
# Run fastqc on bh again
for seq in $(find $SNIC_TMP/trimmed/bh -type f); do
	fastqc $seq -o $SNIC_TMP/trimmed/post/bh
done
# Run fastqc on serum again
for seq in $(find $SNIC_TMP/trimmed/serum -type f); do
	fastqc $seq -o $SNIC_TMP/trimmed/post/serum
done

mkdir -p /proj/uppmax2026-1-61/nobackup/work/acronk/trimmed
cp -r $SNIC_TMP/trimmed/* /proj/uppmax2026-1-61/nobackup/work/acronk/trimmed
