#!/bin/bash

#SBATCH -A uppmax2026-1-61
#SBATCH -p pelle --mem 32G
#SBATCH -n 4
#SBATCH -J bwa_cronk
#SBATCH -t 01:15:00

module load bwa-mem2/2.3-GCC-13.3.0

mkdir $SNIC_TMP/assembly
mkdir $SNIC_TMP/rna_paired
mkdir $SNIC_TMP/rna_single
mkdir $SNIC_TMP/rna_paired_aligned
mkdir $SNIC_TMP/rna_single_aligned

cd $SNIC_TMP

# need to copy over the annotated assembly fasta
cp /proj/uppmax2026-1-61/nobackup/work/acronk/prokka/PROKKA_05202026/PROKKA_05202026.fna $SNIC_TMP/assembly
# need to copy over all of the paired end rnaseqs
cp -r /proj/uppmax2026-1-61/Genome_Analysis/1_Zhang_2017/transcriptomics_data/RNA-Seq_Serum/trimmed/*_paired_*.fastq.gz $SNIC_TMP/rna_paired
# need to copy over all of the single end rnaseqs
cp -r /proj/uppmax2026-1-61/Genome_Analysis/1_Zhang_2017/transcriptomics_data/RNA-Seq_Serum/trimmed/*_single_*.fastq.gz $SNIC_TMP/rna_single
# need to then run the bwa-mem2 index on the assembly
bwa-mem2 index -p indexed $SNIC_TMP/assembly/PROKKA_05202026.fna
# run a file search on all files in the rnaseqs for paired end and single separately to compose a space delimited string of rnaseq files
RNA_SEQ_PAIRED=""
for file in $(find ./rna_paired/*_pass_1.fastq.gz -type f); do
    # Append the filename to the string
    RNA_SEQ_PAIRED+="$file "
done

# Remove trailing space
RNA_SEQ_PAIRED=${RNA_SEQ_PAIRED% }
RNA_SEQ_PAIRED=($RNA_SEQ_PAIRED)
echo $RNA_SEQ_PAIRED
echo ${!RNA_SEQ_PAIRED[@]}

# Regex to find the other file for paired bwa
for i in ${!RNA_SEQ_PAIRED[@]}; do
    curr_sample=${RNA_SEQ_PAIRED[$i]}
    echo $curr_sample
    name="${curr_sample##*/}"; name="${name%.*}"; echo "$name"
    echo $name
    if [[ $name =~ ([a-zA-Z]+_[a-zA-Z]+_[a-zA-Z]+[0-9]+) ]];
    then 
      name=${BASH_REMATCH[1]}    
      echo $name
    else
      echo "did not match"
    fi
    pair=./rna_paired/${name}_pass_2.fastq.gz
    echo $pair
    bwa-mem2 mem indexed $curr_sample $pair > $SNIC_TMP/rna_paired_aligned/$name.sam
done

# Iterate over all single reads and run bwa
for file in $(find ./rna_single -type f); do
    # Append the filename to the string
    echo $file
    name="${file##*/}"; name="${name%.*}"; echo "$name"
    echo $name
    if [[ $name =~ ([a-zA-Z]+_[a-zA-Z]+_[a-zA-Z]+[0-9]+_pass_[0-9]{1}) ]];
    then
      name=${BASH_REMATCH[1]}
      echo $name
    else
      echo "did not match"
    fi
    bwa-mem2 mem indexed $file > $SNIC_TMP/rna_single_aligned/$name.sam
done

# copy the results of both seq types back to the proj dir
mkdir -p /proj/uppmax2026-1-61/nobackup/work/acronk/aligned/serum/paired
mkdir -p /proj/uppmax2026-1-61/nobackup/work/acronk/aligned/serum/single

cp -r $SNIC_TMP/rna_paired_aligned/* /proj/uppmax2026-1-61/nobackup/work/acronk/aligned/serum/paired
cp -r $SNIC_TMP/rna_single_aligned/* /proj/uppmax2026-1-61/nobackup/work/acronk/aligned/serum/single
